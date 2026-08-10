#Requires -Version 5.1
<#
Task ID: IAC-GEMINI-BRIDGE-001
Gemini Bridgeの共有関数ライブラリ。iac-gemini-bridge.ps1 / selftest から dot-source される。
正本レビュー: staging/delivered/2026-08-10_KUROSE_TO_SATO_GEMINI_BRIDGE_REVIEW.md（黒瀬 APPROVE WITH CONDITIONS）

自動化境界（レビュー確定事項。実装で越えないこと）:
- 自動でよい: Handoff検出／API呼び出し／応答の生保存／ACK・PENDING更新／規定回数までのリトライ
- 止める:     正本(02_DECISIONS等)への直接書き込み／二葉の応答内容の要約整形／
             コスト上限到達時の続行可否／既存正本との矛盾の解決
#>

# メンバー名解決・接続ログ関数を再利用する
. (Join-Path $PSScriptRoot 'iac-handoff-lib.ps1')

# ---------------------------------------------------------------------------
# 定数・パス
# ---------------------------------------------------------------------------

# 月次コスト上限（円）。2026-08-10 ケイ確定。
$Script:GeminiBridgeCostCapYen = 2000

# 1回のAPI呼び出しあたりの推定コスト（円）。実測ではなく暫定値。
# 実コストが確認でき次第、Owner判断で見直すこと（このスクリプトが独断確定しない）。
$Script:GeminiBridgeCostPerCallYen = 3

# 往復上限（同一スレッドでの Arc→Gemini→Arc… の回数）
$Script:GeminiBridgeMaxRoundTrips = 3

# リトライ上限・バックオフ（秒）
$Script:GeminiBridgeMaxRetries = 3
$Script:GeminiBridgeRetryBackoffSeconds = @(2, 4, 8)

# 既定モデル（環境変数 GEMINI_BRIDGE_MODEL で上書き可能）
$Script:GeminiBridgeDefaultModel = 'gemini-2.0-flash'

# ロック有効期限（分）。これを超えたロックは停止プロセスの残骸とみなし奪取する。
$Script:GeminiBridgeLockStaleMinutes = 15

# 決定・確定を示す断定語（機械的検出。誤検知は許容、見逃しより安全側 — レビュー要件10）
$Script:GeminiBridgeDecisionPattern = '(決定|確定|採用|正式に|方針とする|decide[ds]?|finali[sz]e[ds]?|adopt(?:ed|ion)?)'

function Get-GeminiBridgeRouterRoot {
    param([string]$RepoRoot)
    $p = Join-Path $RepoRoot 'IACPROJECT\ROUTER'
    New-Item -ItemType Directory -Force -Path $p | Out-Null
    return $p
}

function Get-GeminiBridgeStatePath {
    param([string]$RepoRoot)
    return Join-Path (Get-GeminiBridgeRouterRoot -RepoRoot $RepoRoot) 'GEMINI_BRIDGE_STATE.md'
}

function Get-GeminiBridgeCostLogPath {
    param([string]$RepoRoot)
    return Join-Path (Get-GeminiBridgeRouterRoot -RepoRoot $RepoRoot) 'GEMINI_BRIDGE_COST_LOG.md'
}

function Get-GeminiBridgeLockPath {
    param([string]$RepoRoot)
    return Join-Path (Get-GeminiBridgeRouterRoot -RepoRoot $RepoRoot) '.gemini_bridge.lock'
}

function Write-Utf8BomLines {
    param([string]$Path, [string[]]$Lines)
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $utf8Bom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllLines($Path, $Lines, $utf8Bom)
}

# ---------------------------------------------------------------------------
# ログredact（要件5: APIキーをログへ混入させない）
# ---------------------------------------------------------------------------
function Protect-GeminiBridgeSecret {
    param([string]$Text)
    if (-not $Text) { return $Text }
    $key = $env:GEMINI_API_KEY
    if ($key -and $Text.Contains($key)) {
        $Text = $Text.Replace($key, '***REDACTED***')
    }
    return $Text
}

function Write-GeminiBridgeLog {
    param([string]$Message)
    Write-Host (Protect-GeminiBridgeSecret $Message)
}

# ---------------------------------------------------------------------------
# ロック（要件: claim。二重起動防止）
# ---------------------------------------------------------------------------
function Lock-GeminiBridge {
    param([string]$RepoRoot)
    $lockPath = Get-GeminiBridgeLockPath -RepoRoot $RepoRoot

    if (Test-Path $lockPath) {
        $age = (Get-Date) - (Get-Item $lockPath).LastWriteTime
        if ($age.TotalMinutes -lt $Script:GeminiBridgeLockStaleMinutes) {
            $holder = Get-Content -LiteralPath $lockPath -Raw -ErrorAction SilentlyContinue
            return [PSCustomObject]@{ Acquired = $false; Reason = "既存ロックが有効期限内です（保持者: $holder）" }
        }
        # stale lock: 奪取する
    }
    $payload = "pid=$PID`nhost=$env:COMPUTERNAME`nacquired=$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Utf8BomLines -Path $lockPath -Lines @($payload)
    return [PSCustomObject]@{ Acquired = $true; Reason = $null }
}

function Unlock-GeminiBridge {
    param([string]$RepoRoot)
    $lockPath = Get-GeminiBridgeLockPath -RepoRoot $RepoRoot
    if (Test-Path $lockPath) { Remove-Item -LiteralPath $lockPath -Force -ErrorAction SilentlyContinue }
}

# ---------------------------------------------------------------------------
# 状態ファイル（ACK/PENDING。Bridgeのみが書き込む — one writer原則）
# 列: handoff_id(相対パス) | thread_key | direction | status | attempts | round_trip | last_updated | note
# ---------------------------------------------------------------------------
function Initialize-GeminiBridgeState {
    param([string]$StatePath)
    if (Test-Path $StatePath) { return }
    $header = @(
        '# GEMINI_BRIDGE_STATE',
        '',
        '**Writer**: iac-gemini-bridge のみ（one writer原則。他ツール・手動編集は禁止）',
        '**Purpose**: Handoff⇄Gemini API連携の冪等性・ACK/PENDING状態を管理する。',
        '**Note**: `IACPROJECT/CURRENT_PENDING.md`（アーク管理）とは別系統。混同しないこと。',
        '**Status values**: PENDING / SENT / ACK / HELD_NO_TO_HEADER / HELD_DECISION_LANGUAGE / HELD_ROUNDTRIP_LIMIT / HELD_COST_CAP / FAILED_NO_API_KEY / FAILED_RETRY_EXHAUSTED',
        '',
        '| handoff_id | thread_key | direction | status | attempts | round_trip | last_updated | note |',
        '|---|---|---|---|---|---|---|---|'
    )
    Write-Utf8BomLines -Path $StatePath -Lines $header
}

function Get-GeminiBridgeStateEntries {
    param([string]$StatePath)
    if (-not (Test-Path $StatePath)) { return @() }
    $entries = @()
    foreach ($line in [System.IO.File]::ReadAllLines($StatePath)) {
        if ($line -notmatch '^\|') { continue }
        $cells = ($line.Trim('|') -split '\|') | ForEach-Object { $_.Trim() }
        if ($cells.Count -lt 8) { continue }
        if ($cells[0] -eq 'handoff_id' -or $cells[0] -match '^-+$') { continue }
        $entries += [PSCustomObject]@{
            HandoffId = $cells[0]; ThreadKey = $cells[1]; Direction = $cells[2]
            Status = $cells[3]; Attempts = $cells[4]; RoundTrip = $cells[5]
            LastUpdated = $cells[6]; Note = $cells[7]
        }
    }
    return $entries
}

function Get-GeminiBridgeStateEntry {
    param([string]$StatePath, [string]$HandoffId)
    $entries = Get-GeminiBridgeStateEntries -StatePath $StatePath
    return @($entries | Where-Object { $_.HandoffId -eq $HandoffId }) | Select-Object -First 1
}

function Get-GeminiBridgeRoundTripCount {
    <# 同一スレッド(thread_key)で、direction=to_geminiの試行回数を数える(往復上限判定用) #>
    param([string]$StatePath, [string]$ThreadKey)
    if (-not $ThreadKey) { return 0 }
    $entries = Get-GeminiBridgeStateEntries -StatePath $StatePath
    return @($entries | Where-Object { $_.ThreadKey -eq $ThreadKey -and $_.Direction -eq 'to_gemini' }).Count
}

function Set-GeminiBridgeStateEntry {
    <#
    行を書き換える(既存なら置換、なければ追記)。Bridgeプロセス以外はこの関数を経由しない前提。
    #>
    param(
        [string]$StatePath,
        [string]$HandoffId,
        [string]$ThreadKey,
        [string]$Direction,
        [string]$Status,
        [int]$Attempts,
        [int]$RoundTrip,
        [string]$Note = '-'
    )
    Initialize-GeminiBridgeState -StatePath $StatePath
    $now = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $noteEsc = ($Note -replace '\|', '/') -replace '[\r\n]+', ' '
    $threadEsc = if ($ThreadKey) { $ThreadKey } else { '-' }
    $newRow = "| $HandoffId | $threadEsc | $Direction | $Status | $Attempts | $RoundTrip | $now | $noteEsc |"

    $lines = [System.IO.File]::ReadAllLines($StatePath)
    $out = New-Object System.Collections.Generic.List[string]
    $replaced = $false
    foreach ($line in $lines) {
        if ($line -match '^\|') {
            $cells = ($line.Trim('|') -split '\|') | ForEach-Object { $_.Trim() }
            if ($cells.Count -ge 1 -and $cells[0] -eq $HandoffId) {
                $out.Add($newRow)
                $replaced = $true
                continue
            }
        }
        $out.Add($line)
    }
    if (-not $replaced) { $out.Add($newRow) }
    $utf8Bom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllLines($StatePath, $out, $utf8Bom)
}

function Test-GeminiBridgeAlreadyTerminal {
    <# 冪等性チェック: 既に終端状態(SENT/ACK/HELD_*/FAILED_RETRY_EXHAUSTED)なら再処理しない #>
    param([string]$StatePath, [string]$HandoffId)
    $entry = Get-GeminiBridgeStateEntry -StatePath $StatePath -HandoffId $HandoffId
    if (-not $entry) { return $false }
    $terminal = @('SENT', 'ACK', 'HELD_NO_TO_HEADER', 'HELD_DECISION_LANGUAGE', 'HELD_ROUNDTRIP_LIMIT', 'FAILED_RETRY_EXHAUSTED', 'FAILED_NO_API_KEY')
    return $terminal -contains $entry.Status
}

# ---------------------------------------------------------------------------
# コスト上限（要件4）
# ---------------------------------------------------------------------------
function Initialize-GeminiBridgeCostLog {
    param([string]$CostLogPath)
    if (Test-Path $CostLogPath) { return }
    $header = @(
        '# GEMINI_BRIDGE_COST_LOG',
        '',
        "**Cap**: 月次 $Script:GeminiBridgeCostCapYen 円（2026-08-10 ケイ確定）",
        "**Per-call estimate**: $Script:GeminiBridgeCostPerCallYen 円（暫定値。実コスト確認後にOwnerが見直す）",
        '**Writer**: iac-gemini-bridge のみ',
        '**Rule**: 上限到達で自動停止。続行可否はケイ判断（Bridgeは独断で上限を上書きしない）',
        '',
        '| month | calls | est_cost_yen | cap_yen | cap_status |',
        '|---|---|---|---|---|'
    )
    Write-Utf8BomLines -Path $CostLogPath -Lines $header
}

function Get-GeminiBridgeCostMonthRow {
    param([string]$CostLogPath, [string]$Month)
    Initialize-GeminiBridgeCostLog -CostLogPath $CostLogPath
    foreach ($line in [System.IO.File]::ReadAllLines($CostLogPath)) {
        if ($line -notmatch '^\|') { continue }
        $cells = ($line.Trim('|') -split '\|') | ForEach-Object { $_.Trim() }
        if ($cells.Count -lt 5) { continue }
        if ($cells[0] -eq $Month) {
            return [PSCustomObject]@{ Month = $cells[0]; Calls = [int]$cells[1]; EstCostYen = [int]$cells[2]; CapYen = [int]$cells[3]; CapStatus = $cells[4] }
        }
    }
    return $null
}

function Test-GeminiBridgeCostCapExceeded {
    param([string]$CostLogPath, [string]$Month = (Get-Date -Format 'yyyy-MM'))
    $row = Get-GeminiBridgeCostMonthRow -CostLogPath $CostLogPath -Month $Month
    if (-not $row) { return $false }
    return ($row.EstCostYen -ge $Script:GeminiBridgeCostCapYen)
}

function Add-GeminiBridgeCostCall {
    <# API呼び出し1回を記録し、更新後の月間コストを返す #>
    param([string]$CostLogPath, [string]$Month = (Get-Date -Format 'yyyy-MM'))
    Initialize-GeminiBridgeCostLog -CostLogPath $CostLogPath

    $lines = [System.IO.File]::ReadAllLines($CostLogPath)
    $out = New-Object System.Collections.Generic.List[string]
    $found = $false
    $updatedCost = $Script:GeminiBridgeCostPerCallYen
    foreach ($line in $lines) {
        if ($line -match '^\|') {
            $cells = ($line.Trim('|') -split '\|') | ForEach-Object { $_.Trim() }
            if ($cells.Count -ge 5 -and $cells[0] -eq $Month) {
                $calls = [int]$cells[1] + 1
                $cost = [int]$cells[2] + $Script:GeminiBridgeCostPerCallYen
                $updatedCost = $cost
                $capStatus = if ($cost -ge $Script:GeminiBridgeCostCapYen) { 'CAP_REACHED' } else { 'OK' }
                $out.Add("| $Month | $calls | $cost | $Script:GeminiBridgeCostCapYen | $capStatus |")
                $found = $true
                continue
            }
        }
        $out.Add($line)
    }
    if (-not $found) {
        $capStatus = if ($Script:GeminiBridgeCostPerCallYen -ge $Script:GeminiBridgeCostCapYen) { 'CAP_REACHED' } else { 'OK' }
        $out.Add("| $Month | 1 | $Script:GeminiBridgeCostPerCallYen | $Script:GeminiBridgeCostCapYen | $capStatus |")
    }
    $utf8Bom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllLines($CostLogPath, $out, $utf8Bom)
    return $updatedCost
}

# ---------------------------------------------------------------------------
# 宛先ヘッダ検証・断定語検出（要件2・6・8・10）
# ---------------------------------------------------------------------------
function Get-GeminiResponseToToken {
    <#
    Gemini生応答テキストから宛先(To:/宛先:)行を抽出し、既知メンバートークンへ解決する。
    推測はしない: 行が無い、または解決できない場合は $null。
    #>
    param([string]$ResponseText)
    if (-not $ResponseText) { return $null }
    foreach ($line in ($ResponseText -split "`r?`n")) {
        if ($line -match '^\s*(?:[-*]\s+)?(?:\*\*)?(To|宛先)(?:\*\*)?\s*[:：]\s*(.+?)\s*$') {
            $value = $Matches[2]
            $words = @([regex]::Split($value.ToLowerInvariant(), '[^a-z0-9]+') | Where-Object { $_ })
            if ($words.Count -gt 0) {
                $resolved = Resolve-MemberToken -Tokens $words
                if ($resolved.Token) { return $resolved.Token }
            }
            foreach ($tok in $Script:MemberDisplayMap.Keys) {
                $display = $Script:MemberDisplayMap[$tok]
                $name = $display -replace '（.+?）$', ''
                if ($name -and $name -match '[^ -~]' -and $value.Contains($name)) { return $tok }
            }
            return $null
        }
    }
    return $null
}

function Test-GeminiResponseHasDecisionLanguage {
    param([string]$ResponseText)
    if (-not $ResponseText) { return $false }
    return ($ResponseText -match $Script:GeminiBridgeDecisionPattern)
}

# ---------------------------------------------------------------------------
# Gemini API呼び出し（要件3: リトライ上限つき／要件5: キーは環境変数のみ）
# ---------------------------------------------------------------------------
function Invoke-GeminiBridgeHttpCall {
    <# 実HTTP呼び出し。テストでは -ApiCallOverride で差し替える。 #>
    param([string]$ApiKey, [string]$Model, [string]$PromptText)

    $uri = "https://generativelanguage.googleapis.com/v1beta/models/${Model}:generateContent?key=$ApiKey"
    $body = @{ contents = @(@{ parts = @(@{ text = $PromptText }) }) } | ConvertTo-Json -Depth 10
    $resp = Invoke-RestMethod -Uri $uri -Method Post -ContentType 'application/json; charset=utf-8' -Body ([System.Text.Encoding]::UTF8.GetBytes($body))
    $text = $resp.candidates[0].content.parts[0].text
    if (-not $text) { throw 'Gemini APIレスポンスにテキストが含まれていません' }
    return $text
}

function Send-GeminiBridgeRequest {
    <#
    リトライ付きでGemini APIを呼び出す。
    戻り値: @{ Success; Text; Attempts; Error }
    -ApiCallOverride を渡すとHTTP呼び出しをスタブ化できる（selftest専用）。
    #>
    param(
        [string]$PromptText,
        [scriptblock]$ApiCallOverride = $null
    )

    # キー必須チェックは実呼び出し経路(override無し)のみに適用する。
    # override指定時(selftest専用)はキーの有無に関わらずロジックを検証できる。
    $apiKey = $null
    if (-not $ApiCallOverride) {
        $apiKey = $env:GEMINI_API_KEY
        if (-not $apiKey) {
            return [PSCustomObject]@{ Success = $false; Text = $null; Attempts = 0; Error = 'GEMINI_API_KEY未設定' }
        }
    }
    $model = if ($env:GEMINI_BRIDGE_MODEL) { $env:GEMINI_BRIDGE_MODEL } else { $Script:GeminiBridgeDefaultModel }

    $attempts = 0
    $lastError = $null
    while ($attempts -lt $Script:GeminiBridgeMaxRetries) {
        $attempts++
        try {
            if ($ApiCallOverride) {
                $text = & $ApiCallOverride $PromptText $attempts
            } else {
                $text = Invoke-GeminiBridgeHttpCall -ApiKey $apiKey -Model $model -PromptText $PromptText
            }
            return [PSCustomObject]@{ Success = $true; Text = $text; Attempts = $attempts; Error = $null }
        } catch {
            $lastError = Protect-GeminiBridgeSecret $_.Exception.Message
            if ($attempts -lt $Script:GeminiBridgeMaxRetries) {
                $wait = $Script:GeminiBridgeRetryBackoffSeconds[$attempts - 1]
                Write-GeminiBridgeLog "  呼び出し失敗（試行 $attempts/$Script:GeminiBridgeMaxRetries）: $lastError → ${wait}秒後に再試行"
                Start-Sleep -Seconds $wait
            }
        }
    }
    return [PSCustomObject]@{ Success = $false; Text = $null; Attempts = $attempts; Error = $lastError }
}

# ---------------------------------------------------------------------------
# 応答の生保存（要件6: 生Markdownのまま。要約・整形をしない）
# ---------------------------------------------------------------------------
function Get-GeminiBridgeTopicFromRel {
    param([string]$RelPath)
    $base = [IO.Path]::GetFileNameWithoutExtension(($RelPath -split '[\\/]')[-1])
    $stripped = $base -replace '^\d{4}-\d{2}-\d{2}(_\d{3,4})?_', ''
    $stripped = $stripped -replace '(?i)^[a-z_]+_TO_[a-z_]+_', ''
    if (-not $stripped) { $stripped = 'RESPONSE' }
    return $stripped
}

function New-GeminiBridgeResponseFileName {
    param([string]$SourceRel, [string]$ToToken)
    $topic = Get-GeminiBridgeTopicFromRel -RelPath $SourceRel
    $toUpper = $ToToken.ToUpper()
    $today = Get-Date -Format 'yyyy-MM-dd'
    return "${today}_GEMINI_TO_${toUpper}_${topic}.md"
}

function Save-GeminiBridgeResponseToInbox {
    <# 宛先ヘッダ検証済み・断定語なしの応答を inbox/from_gemini へ生保存する #>
    param([string]$RepoRoot, [string]$FromGeminiDir, [string]$SourceRel, [string]$ToToken, [string]$ResponseText)
    New-Item -ItemType Directory -Force -Path $FromGeminiDir | Out-Null
    $fileName = New-GeminiBridgeResponseFileName -SourceRel $SourceRel -ToToken $ToToken
    $destPath = Join-Path $FromGeminiDir $fileName
    if (Test-Path $destPath) {
        $destPath = Join-Path $FromGeminiDir ("{0}_{1}" -f (Get-Date -Format 'yyyyMMddHHmmss'), $fileName)
    }
    $utf8Bom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($destPath, $ResponseText, $utf8Bom)
    return $destPath
}

function Save-GeminiBridgeHeldResponse {
    <# 宛先ヘッダ欠落・断定語検出のいずれかで保留になった応答を staging へ生保存する（inboxへは置かない） #>
    param([string]$RepoRoot, [string]$SourceRel, [string]$ResponseText, [string]$Reason)
    $stagingDir = Join-Path $RepoRoot 'staging\gemini_held'
    New-Item -ItemType Directory -Force -Path $stagingDir | Out-Null
    $topic = Get-GeminiBridgeTopicFromRel -RelPath $SourceRel
    $today = Get-Date -Format 'yyyy-MM-dd_HHmmss'
    $fileName = "${today}_HELD_${Reason}_${topic}.md"
    $destPath = Join-Path $stagingDir $fileName
    $utf8Bom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($destPath, $ResponseText, $utf8Bom)
    return $destPath
}
