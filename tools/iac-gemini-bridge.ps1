#Requires -Version 5.1
<#
Task ID: IAC-GEMINI-BRIDGE-001
Gemini Bridge — Handoff(inbox/from_arc)⇄Gemini API⇄応答保存(inbox/from_gemini)の自動連携。
正本レビュー: staging/delivered/2026-08-10_KUROSE_TO_SATO_GEMINI_BRIDGE_REVIEW.md（黒瀬 APPROVE WITH CONDITIONS）
実装仕様: IACPROJECT/OPERATING_RULES/GEMINI_BRIDGE_TOOLING.md

使い方:
  iac-gemini-bridge run           inbox/from_arc・inbox/from_gemini を1回スキャンして処理する
  iac-gemini-bridge run -WhatIf   送信対象を表示するだけで、API呼び出し・書き込みを行わない
  iac-gemini-bridge run -Push     commit後にgit pushまで行う（GitHub Actions等、使い捨て実行環境向け。
                                   通常のローカル運用ではケイ/佐藤が内容を見てから手動pushするためデフォルトでは付けない）
  iac-gemini-bridge status        状態ファイル・コストログの要約を表示する（読み取り専用）

前提: 環境変数 GEMINI_API_KEY にAPIキーを設定しておくこと（リポジトリ・ログへの直書き禁止）。
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)][string]$Command = 'run',
    [switch]$WhatIf,
    [switch]$NoGit,
    [switch]$Push
)

$ErrorActionPreference = 'Stop'

# iac-console.ps1 は同名の $Command / $Push param を持つため、dot-source時に呼び出し元の
# $Command / $Push を上書きしてしまう（$Pushはswitchのデフォルト$falseで上書きされる）。
# dot-source前に退避し、以降は退避値を使う。
$Script:BridgeCommand = $Command
$Script:BridgePush    = [bool]$Push

. (Join-Path $PSScriptRoot 'iac-handoff-lib.ps1')
. (Join-Path $PSScriptRoot 'iac-gemini-bridge-lib.ps1')

$env:IAC_CONSOLE_NO_MAIN = '1'
try {
    . (Join-Path $PSScriptRoot 'iac-console.ps1')
} finally {
    $env:IAC_CONSOLE_NO_MAIN = ''
}

$Script:RepoRoot       = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Script:StatePath      = Get-GeminiBridgeStatePath -RepoRoot $Script:RepoRoot
$Script:CostLogPath    = Get-GeminiBridgeCostLogPath -RepoRoot $Script:RepoRoot
$Script:InboxRoot      = Join-Path $Script:RepoRoot 'IACPROJECT\inbox'
$Script:FromArcDir     = Join-Path $Script:InboxRoot 'from_arc'
$Script:FromGeminiDir  = Join-Path $Script:InboxRoot 'from_gemini'

function Invoke-GeminiBridgeGit {
    param([string[]]$GitArgs)
    Push-Location $Script:RepoRoot
    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & git @GitArgs 2>&1 | ForEach-Object { $_.ToString() }
        return [PSCustomObject]@{ ExitCode = $LASTEXITCODE; Output = ($output -join "`n") }
    } finally {
        $ErrorActionPreference = $prevEAP
        Pop-Location
    }
}

function Publish-GeminiBridgeFile {
    <# inbox/from_gemini へ保存したファイルをcommitする（stateファイル・costログと合わせて1コミット） #>
    param([string[]]$RelPaths, [string]$Message)
    if ($NoGit) { return }
    foreach ($rel in $RelPaths) {
        $add = Invoke-GeminiBridgeGit @('add', $rel)
        if ($add.ExitCode -ne 0) { Write-GeminiBridgeLog "git add失敗: $rel : $($add.Output)" }
    }
    $commit = Invoke-GeminiBridgeGit @('commit', '-m', $Message)
    if ($commit.ExitCode -ne 0 -and $commit.Output -notmatch 'nothing to commit|nothing added to commit') {
        Write-GeminiBridgeLog "git commit失敗: $($commit.Output)"
        return
    }
    if (-not $Script:BridgePush) { return }

    $pushResult = Invoke-GeminiBridgeGit @('push')
    if ($pushResult.ExitCode -ne 0) {
        $rebase = Invoke-GeminiBridgeGit @('pull', '--rebase')
        if ($rebase.ExitCode -eq 0) { $pushResult = Invoke-GeminiBridgeGit @('push') }
    }
    if ($pushResult.ExitCode -ne 0) {
        Write-GeminiBridgeLog "git push失敗: $($pushResult.Output)"
        throw "Gemini Bridge: git pushに失敗しました。実行環境は使い捨てのためローカルcommitは失われます。ジョブを失敗として扱います。"
    }
}

function Get-GeminiBridgeThreadKey {
    param($Doc)
    if ($Doc.TaskId) { return $Doc.TaskId }
    return (Get-GeminiBridgeTopicFromRel -RelPath $Doc.RelPath)
}

function Invoke-GeminiBridgeRun {
    param([switch]$WhatIf, [scriptblock]$ApiCallOverride = $null)

    Initialize-GeminiBridgeState -StatePath $Script:StatePath
    Initialize-GeminiBridgeCostLog -CostLogPath $Script:CostLogPath

    $processed = 0; $skipped = 0; $held = 0; $failed = 0
    $touchedRelPaths = New-Object System.Collections.Generic.List[string]

    # === 1. inbox/from_arc: 二葉宛のHandoffをAPIへ送る ===
    if (Test-Path $Script:FromArcDir) {
        $files = Get-ChildItem -LiteralPath $Script:FromArcDir -Filter '*.md' -File -ErrorAction SilentlyContinue
        foreach ($f in $files) {
            $rel = $f.FullName.Substring($Script:RepoRoot.Length).TrimStart('\') -replace '\\', '/'
            $doc = Get-HandoffDocument -File $f -RepoRoot $Script:RepoRoot

            if (-not (Test-HandoffAddressedTo -Doc $doc -Token 'gemini')) { continue }

            if (Test-GeminiBridgeAlreadyTerminal -StatePath $Script:StatePath -HandoffId $rel) {
                $skipped++
                continue
            }

            $threadKey = Get-GeminiBridgeThreadKey -Doc $doc

            if (-not (Test-GeminiBridgeSingleRecipient -Doc $doc)) {
                if (-not $WhatIf) {
                    $heldPath = Save-GeminiBridgeHeldResponse -RepoRoot $Script:RepoRoot -SourceRel $rel `
                        -ResponseText ([System.IO.File]::ReadAllText($f.FullName)) -Reason 'multi_recipient'
                    Set-GeminiBridgeStateEntry -StatePath $Script:StatePath -HandoffId $rel -ThreadKey $threadKey `
                        -Direction 'to_gemini' -Status 'HELD_MULTI_RECIPIENT' -Attempts 0 -RoundTrip 0 `
                        -Note "複数宛先検出。自動送信対象外。staging保存: $heldPath"
                }
                Write-GeminiBridgeLog "HELD（複数宛先検出。自動送信対象外）: $rel"
                $held++
                continue
            }

            $roundTrip = (Get-GeminiBridgeRoundTripCount -StatePath $Script:StatePath -ThreadKey $threadKey) + 1

            if ($roundTrip -gt $Script:GeminiBridgeMaxRoundTrips) {
                if (-not $WhatIf) {
                    Set-GeminiBridgeStateEntry -StatePath $Script:StatePath -HandoffId $rel -ThreadKey $threadKey `
                        -Direction 'to_gemini' -Status 'HELD_ROUNDTRIP_LIMIT' -Attempts 0 -RoundTrip $roundTrip `
                        -Note "往復上限($Script:GeminiBridgeMaxRoundTrips)超過。Owner確認へ"
                }
                Write-GeminiBridgeLog "HELD（往復上限超過 round=$roundTrip）: $rel"
                $held++
                continue
            }

            if (Test-GeminiBridgeCostCapExceeded -CostLogPath $Script:CostLogPath) {
                if (-not $WhatIf) {
                    Set-GeminiBridgeStateEntry -StatePath $Script:StatePath -HandoffId $rel -ThreadKey $threadKey `
                        -Direction 'to_gemini' -Status 'HELD_COST_CAP' -Attempts 0 -RoundTrip $roundTrip `
                        -Note '月次コスト上限到達。続行はケイ判断'
                }
                Write-GeminiBridgeLog "HELD（月次コスト上限到達）: $rel"
                $held++
                continue
            }

            if ($WhatIf) {
                Write-GeminiBridgeLog "[WhatIf] 送信予定: $rel (thread=$threadKey, round=$roundTrip)"
                continue
            }

            $promptText = if ($doc.RequiredNextAction) { $doc.RequiredNextAction } else { [System.IO.File]::ReadAllText($f.FullName) }
            $result = Send-GeminiBridgeRequest -PromptText $promptText -ApiCallOverride $ApiCallOverride

            if (-not $result.Success) {
                $status = if ($result.Error -eq 'GEMINI_API_KEY未設定') { 'FAILED_NO_API_KEY' } else { 'FAILED_RETRY_EXHAUSTED' }
                Set-GeminiBridgeStateEntry -StatePath $Script:StatePath -HandoffId $rel -ThreadKey $threadKey `
                    -Direction 'to_gemini' -Status $status -Attempts $result.Attempts -RoundTrip $roundTrip -Note $result.Error
                Write-GeminiBridgeLog "FAILED: $rel ($($result.Error))"
                $failed++
                continue
            }

            Add-GeminiBridgeCostCall -CostLogPath $Script:CostLogPath | Out-Null

            $toToken = Get-GeminiResponseToToken -ResponseText $result.Text
            if (-not $toToken) {
                $heldPath = Save-GeminiBridgeHeldResponse -RepoRoot $Script:RepoRoot -SourceRel $rel -ResponseText $result.Text -Reason 'no_to_header'
                Set-GeminiBridgeStateEntry -StatePath $Script:StatePath -HandoffId $rel -ThreadKey $threadKey `
                    -Direction 'to_gemini' -Status 'HELD_NO_TO_HEADER' -Attempts $result.Attempts -RoundTrip $roundTrip `
                    -Note "宛先ヘッダ欠落。staging保存: $heldPath"
                Write-GeminiBridgeLog "HELD（宛先ヘッダ欠落）: $rel → $heldPath"
                $held++
                continue
            }

            if (Test-GeminiResponseHasDecisionLanguage -ResponseText $result.Text) {
                $heldPath = Save-GeminiBridgeHeldResponse -RepoRoot $Script:RepoRoot -SourceRel $rel -ResponseText $result.Text -Reason 'decision_language'
                Set-GeminiBridgeStateEntry -StatePath $Script:StatePath -HandoffId $rel -ThreadKey $threadKey `
                    -Direction 'to_gemini' -Status 'HELD_DECISION_LANGUAGE' -Attempts $result.Attempts -RoundTrip $roundTrip `
                    -Note "断定語検出。staging保存: $heldPath（Owner判断待ち）"
                Write-GeminiBridgeLog "HELD（断定語検出）: $rel → $heldPath"
                $held++
                continue
            }

            $destPath = Save-GeminiBridgeResponseToInbox -RepoRoot $Script:RepoRoot -FromGeminiDir $Script:FromGeminiDir -SourceRel $rel -ToToken $toToken -ResponseText $result.Text
            $destRel = $destPath.Substring($Script:RepoRoot.Length).TrimStart('\') -replace '\\', '/'
            Set-GeminiBridgeStateEntry -StatePath $Script:StatePath -HandoffId $rel -ThreadKey $threadKey `
                -Direction 'to_gemini' -Status 'SENT' -Attempts $result.Attempts -RoundTrip $roundTrip -Note "応答保存: $destRel"
            Write-GeminiBridgeLog "SENT: $rel → $destRel"
            $touchedRelPaths.Add($destRel)
            $processed++
        }
    } else {
        Write-GeminiBridgeLog "警告: $Script:FromArcDir が存在しません"
    }

    # === 2. inbox/from_gemini: 既存/手動投入分の検証・登録（APIは呼ばない） ===
    if (Test-Path $Script:FromGeminiDir) {
        $files = Get-ChildItem -LiteralPath $Script:FromGeminiDir -Filter '*.md' -File -ErrorAction SilentlyContinue
        foreach ($f in $files) {
            $rel = $f.FullName.Substring($Script:RepoRoot.Length).TrimStart('\') -replace '\\', '/'
            if (Test-GeminiBridgeAlreadyTerminal -StatePath $Script:StatePath -HandoffId $rel) { $skipped++; continue }

            if ($WhatIf) {
                Write-GeminiBridgeLog "[WhatIf] 検証予定（from_gemini既存）: $rel"
                continue
            }

            $doc = Get-HandoffDocument -File $f -RepoRoot $Script:RepoRoot
            $text = [System.IO.File]::ReadAllText($f.FullName)
            $threadKey = Get-GeminiBridgeThreadKey -Doc $doc

            if (-not $doc.ToRaw -and -not $doc.ToToken) {
                Set-GeminiBridgeStateEntry -StatePath $Script:StatePath -HandoffId $rel -ThreadKey $threadKey `
                    -Direction 'from_gemini' -Status 'HELD_NO_TO_HEADER' -Attempts 0 -RoundTrip 0 -Note '宛先ヘッダ欠落（既存ファイル）'
                Write-GeminiBridgeLog "HELD（宛先ヘッダ欠落・既存）: $rel"
                $held++
                continue
            }
            if (Test-GeminiResponseHasDecisionLanguage -ResponseText $text) {
                Set-GeminiBridgeStateEntry -StatePath $Script:StatePath -HandoffId $rel -ThreadKey $threadKey `
                    -Direction 'from_gemini' -Status 'HELD_DECISION_LANGUAGE' -Attempts 0 -RoundTrip 0 -Note '断定語検出（既存ファイル、Owner判断待ち）'
                Write-GeminiBridgeLog "HELD（断定語検出・既存）: $rel"
                $held++
                continue
            }
            Set-GeminiBridgeStateEntry -StatePath $Script:StatePath -HandoffId $rel -ThreadKey $threadKey `
                -Direction 'from_gemini' -Status 'ACK' -Attempts 0 -RoundTrip 0 -Note '検証済み・既存配送物として登録'
            $processed++
        }
    }

    if (-not $WhatIf -and ($processed -gt 0 -or $held -gt 0 -or $failed -gt 0)) {
        $stateRel = $Script:StatePath.Substring($Script:RepoRoot.Length).TrimStart('\') -replace '\\', '/'
        $costRel  = $Script:CostLogPath.Substring($Script:RepoRoot.Length).TrimStart('\') -replace '\\', '/'
        $touchedRelPaths.Add($stateRel)
        $touchedRelPaths.Add($costRel)
        Publish-GeminiBridgeFile -RelPaths ($touchedRelPaths | Select-Object -Unique) -Message "gemini-bridge: run $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    }

    Write-GeminiBridgeLog ''
    Write-GeminiBridgeLog "Bridge実行結果: 送信 $processed 件 / 保留 $held 件 / 失敗 $failed 件 / スキップ(冪等) $skipped 件"
}

function Show-GeminiBridgeStatus {
    Initialize-GeminiBridgeState -StatePath $Script:StatePath
    Initialize-GeminiBridgeCostLog -CostLogPath $Script:CostLogPath

    $entries = Get-GeminiBridgeStateEntries -StatePath $Script:StatePath
    Write-Host "状態ファイル: $Script:StatePath（$($entries.Count)件）"
    if ($entries.Count -gt 0) {
        $entries | Group-Object Status | Sort-Object Count -Descending | ForEach-Object {
            Write-Host ("  {0,-28} : {1}件" -f $_.Name, $_.Count)
        }
    }
    Write-Host ''
    $month = Get-Date -Format 'yyyy-MM'
    $row = Get-GeminiBridgeCostMonthRow -CostLogPath $Script:CostLogPath -Month $month
    if ($row) {
        Write-Host "今月($month)のコスト: $($row.EstCostYen)円 / 上限$($row.CapYen)円 / 呼び出し$($row.Calls)回 / 状態$($row.CapStatus)"
    } else {
        Write-Host "今月($month)のコスト記録なし"
    }
}

if ($env:IAC_GEMINI_BRIDGE_NO_MAIN -ne '1') {
    switch (($Script:BridgeCommand + '').ToLowerInvariant()) {
        'run'    { Invoke-GeminiBridgeRun -WhatIf:$WhatIf }
        'status' { Show-GeminiBridgeStatus }
        default  {
            Write-Host 'iac-gemini-bridge run [-WhatIf] [-NoGit]   inbox/from_arc・from_gemini をスキャンして処理'
            Write-Host 'iac-gemini-bridge status                   状態・コストログの要約（読み取り専用）'
        }
    }
}
