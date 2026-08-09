#Requires -Version 5.1
<#
Task ID: IAC-OPS-CONSOLE-001
IAC Operations Console (CLI / MVP)

黒瀬レビュー（IACPROJECT/inbox/from_claude/2026-08-09_KUROSE_TO_ARC_OPS_CONSOLE_REVIEW.md）
のMVP確定版3機能のみを実装する。

  inbox      A. Handoff Inbox（読み取り専用。一覧表示＋必須項目欠落の警告）
  wake       B. 起床パケット生成（共通起床文＋最新commit＋対象Handoffの転記）
  questions  C. Questions Queue 集約（機械集約のみ）

設計原則（レビューで確定した制約）:
- 状態推論・Next AI判定・ACK管理・時刻制御は実装しない。
- Handoffに書かれた To / Required next action はそのまま転記する。推論を加えない。
- パース失敗で停止しない。抽出できない項目は空欄＋警告として処理を続行する。
- 二葉（Gemini）はアークの単一Packet方式のため、本ツールでは起床パケットを生成しない。
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)][string]$Command,
    [Parameter(Position = 1)][string]$Member,
    [string]$To,
    [int]$SinceDays = 0,
    [switch]$Push
)

$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'iac-handoff-lib.ps1')

$Script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Script:WakeDir  = Join-Path $Script:RepoRoot 'IACPROJECT\WAKE'
$Script:CommonWakeMessagePath = Join-Path $Script:RepoRoot 'IACPROJECT\OPERATING_RULES\2026-08-09_COMMON_WAKEUP_MESSAGE.md'

function Invoke-ConsoleGit {
    param([string[]]$GitArgs)
    Push-Location $Script:RepoRoot
    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & git @GitArgs 2>&1 | ForEach-Object { $_.ToString() }
        $exit = $LASTEXITCODE
        return [PSCustomObject]@{ ExitCode = $exit; Output = ($output -join "`n") }
    } finally {
        $ErrorActionPreference = $prevEAP
        Pop-Location
    }
}

function Get-HandoffScanRoots {
    param([string]$RepoRoot)
    $roots = @()
    foreach ($rel in 'IACPROJECT\HANDOFF', 'IACPROJECT\HANDOFFS', 'IACPROJECT\inbox') {
        $p = Join-Path $RepoRoot $rel
        if (Test-Path $p) { $roots += $p }
    }
    return $roots
}

function Get-HandoffFiles {
    param([string]$RepoRoot)
    $files = @()
    foreach ($root in (Get-HandoffScanRoots -RepoRoot $RepoRoot)) {
        $files += Get-ChildItem -LiteralPath $root -Recurse -Filter '*.md' -File -ErrorAction SilentlyContinue
    }
    return $files | Sort-Object FullName -Unique
}

function ConvertTo-SectionKey {
    # 見出し文字列を比較用キーへ正規化する（空白・記号の揺れを吸収）。
    param([string]$Title)
    if ($null -eq $Title) { return '' }
    $t = $Title.ToLowerInvariant()
    $t = $t -replace '[\*_:：]', ''
    $t = $t -replace '\s+', ''
    return $t
}

function Get-HandoffDocument {
    <#
    Handoffファイル1件をパースする。フォーマットの揺れ（# HANDOFF / # HANDOFF PACKET、
    英語見出し / 日本語ラベル）を許容し、どんな入力でも例外を出さずにオブジェクトを返す。
    抽出できなかった項目は空欄とし、Warningsに記録する。
    #>
    param([System.IO.FileInfo]$File, [string]$RepoRoot)

    $doc = [PSCustomObject]@{
        Path = $File.FullName
        RelPath = ''
        FileName = $File.Name
        Date = ''; From = ''; ToRaw = ''; Cc = ''; TaskId = ''
        FromToken = $null; ToToken = $null
        RequiredNextAction = ''; Questions = @(); Status = ''
        Warnings = @()
    }
    if ($File.FullName.StartsWith($RepoRoot, [StringComparison]::OrdinalIgnoreCase)) {
        $doc.RelPath = $File.FullName.Substring($RepoRoot.Length).TrimStart('\')
    } else {
        $doc.RelPath = $File.FullName
    }

    try {
        $lines = [System.IO.File]::ReadAllLines($File.FullName, [System.Text.Encoding]::UTF8)
    } catch {
        $doc.Warnings += "読み込み失敗: $($_.Exception.Message)"
        return $doc
    }

    try {
        # セクション分割
        $sections = @{}
        $current = ''
        $sections[$current] = New-Object System.Collections.Generic.List[string]
        foreach ($line in $lines) {
            if ($line -match '^\s{0,3}#{1,6}\s+(.+?)\s*$') {
                $current = ConvertTo-SectionKey $Matches[1]
                if (-not $sections.ContainsKey($current)) {
                    $sections[$current] = New-Object System.Collections.Generic.List[string]
                }
            } else {
                $sections[$current].Add($line)
            }
        }

        # key: value 形式の行（半角/全角コロン、**強調**、日英ラベルを許容）
        $kvPattern = '^\s*(?:[-*]\s+)?(?:\*\*)?(From|To|CC|Cc|Date|Task ID|送信元|宛先|日時)(?:\*\*)?\s*[:：]\s*(.+?)\s*$'
        foreach ($line in $lines) {
            if ($line -match $kvPattern) {
                $key = $Matches[1]; $value = $Matches[2]
                switch -Regex ($key) {
                    '^(From|送信元)$' { if (-not $doc.From)  { $doc.From  = $value } }
                    '^(To|宛先)$'     { if (-not $doc.ToRaw) { $doc.ToRaw = $value } }
                    '^(CC|Cc)$'       { if (-not $doc.Cc)    { $doc.Cc    = $value } }
                    '^(Date|日時)$'   { if (-not $doc.Date)  { $doc.Date  = $value } }
                    '^Task ID$'       { if (-not $doc.TaskId){ $doc.TaskId= $value } }
                }
            }
        }

        # セクション本文からの補完
        function Get-FirstNonEmpty([object]$list) {
            if ($null -eq $list) { return '' }
            foreach ($l in $list) { if ($l.Trim()) { return $l.Trim() } }
            return ''
        }
        if (-not $doc.TaskId -and $sections.ContainsKey('taskid')) { $doc.TaskId = Get-FirstNonEmpty $sections['taskid'] }
        if (-not $doc.Date   -and $sections.ContainsKey('date'))   { $doc.Date   = Get-FirstNonEmpty $sections['date'] }
        if ($sections.ContainsKey('status')) { $doc.Status = Get-FirstNonEmpty $sections['status'] }

        foreach ($key in $sections.Keys) {
            if ($key -like 'requirednextaction*' -and -not $doc.RequiredNextAction) {
                $body = @($sections[$key] | ForEach-Object { $_.TrimEnd() } | Where-Object { $_ -ne '' })
                $doc.RequiredNextAction = ($body -join "`n").Trim()
            }
            if ($key -like 'questionsqueue*' -and $doc.Questions.Count -eq 0) {
                $items = @()
                foreach ($l in $sections[$key]) {
                    if ($l -match '^\s*(?:\d+[\.\)]|[-*])\s+(.+?)\s*$') { $items += $Matches[1] }
                }
                if ($items.Count -eq 0) {
                    $items = @($sections[$key] | ForEach-Object { $_.Trim() } | Where-Object { $_ -and $_ -notmatch '^-{3,}$' })
                }
                $doc.Questions = $items
            }
        }

        # ファイル名からの補完（既存libの命名規約パーサ）
        $parsed = Get-HandoffFromTo -FileBaseName ([IO.Path]::GetFileNameWithoutExtension($File.Name))
        if (-not $doc.Date -and $parsed.Date) { $doc.Date = $parsed.Date }
        $doc.FromToken = $parsed.From
        $doc.ToToken = $parsed.To
        if (-not $doc.From -and $parsed.From) { $doc.From = $parsed.From }

        # 必須項目の欠落警告（空欄のまま続行する）
        if (-not $doc.From)               { $doc.Warnings += 'From が特定できません' }
        if (-not $doc.ToRaw -and -not $doc.ToToken) { $doc.Warnings += 'To が特定できません' }
        if (-not $doc.TaskId)             { $doc.Warnings += 'Task ID がありません' }
        if (-not $doc.Date)               { $doc.Warnings += 'Date が特定できません' }
        if (-not $doc.RequiredNextAction) { $doc.Warnings += 'Required next action がありません' }
    } catch {
        $doc.Warnings += "パース失敗（内容は未抽出のまま続行）: $($_.Exception.Message)"
    }
    return $doc
}

function Get-ToFieldTokens {
    <#
    To欄の文字列から正規メンバートークンの一覧を得る。
    英数字部分は単語分割して既存libのResolve-MemberTokenで解決する（2語結合を優先するため、
    「Claude Code」が claude に部分一致する誤判定を防ぐ）。日本語呼称は表示名の包含で判定する。
    #>
    param([string]$ToRaw)
    $tokens = New-Object System.Collections.Generic.List[string]
    if (-not $ToRaw) { return $tokens }
    $lower = $ToRaw.ToLowerInvariant()

    # 英数字トークン列をスライドしながら解決（2語結合優先）
    $words = @([regex]::Split($lower, '[^a-z0-9]+') | Where-Object { $_ })
    $i = 0
    while ($i -lt $words.Count) {
        $r = Resolve-MemberToken -Tokens @($words[$i..($words.Count - 1)])
        if ($r.Token) {
            if (-not $tokens.Contains($r.Token)) { $tokens.Add($r.Token) }
            $i += $r.Consumed
        } else {
            $i++
        }
    }

    # 日本語呼称（表示名とその括弧前の部分）
    foreach ($t in $Script:MemberDisplayMap.Keys) {
        $display = $Script:MemberDisplayMap[$t]
        $name = $display -replace '（.+?）$', ''
        if ($name -and $name -match '[^\u0020-\u007E]' -and $ToRaw.Contains($name)) {
            if (-not $tokens.Contains($t)) { $tokens.Add($t) }
        }
    }
    return $tokens
}

function Test-HandoffAddressedTo {
    # 宛先判定は「to_フォルダ名」と「To欄の名前一致」のみ。内容からの推論は行わない。
    param($Doc, [string]$Token)

    foreach ($segment in ($Doc.RelPath -split '\\')) {
        if ($segment.ToLowerInvariant().StartsWith('to_')) {
            $rest = $segment.Substring(3) -split '_'
            $resolved = Resolve-MemberToken -Tokens $rest
            if ($resolved.Token -eq $Token) { return $true }
        }
    }
    if ($Doc.ToToken -eq $Token) { return $true }
    if ($Doc.ToRaw) {
        # 配列化＋-contains（完全一致）。List直参照だと単一要素時にstringへアンロールされ
        # 部分一致のString.Containsが呼ばれてしまう。
        $toTokens = @(Get-ToFieldTokens -ToRaw $Doc.ToRaw)
        if ($toTokens -contains $Token) { return $true }
    }
    return $false
}

function Get-DocDate {
    param($Doc)
    $d = [datetime]::MinValue
    if ($Doc.Date -match '(\d{4}-\d{2}-\d{2})') {
        [void][datetime]::TryParse($Matches[1], [ref]$d)
    }
    return $d
}

function Select-DocsSince {
    param([object[]]$Docs, [int]$Days)
    if ($Days -le 0) { return $Docs }
    $cutoff = (Get-Date).Date.AddDays(-1 * $Days)
    return @($Docs | Where-Object { (Get-DocDate $_) -ge $cutoff })
}

function Write-Utf8BomFile {
    param([string]$Path, [string[]]$Lines)
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $utf8Bom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllLines($Path, $Lines, $utf8Bom)
}

function Push-GeneratedFile {
    param([string]$RelPath, [string]$Message)
    $add = Invoke-ConsoleGit @('add', $RelPath)
    if ($add.ExitCode -ne 0) { Write-Host "git add 失敗: $($add.Output)"; return $false }
    $commit = Invoke-ConsoleGit @('commit', '-m', $Message, '--', $RelPath)
    if ($commit.ExitCode -ne 0 -and $commit.Output -notmatch 'nothing to commit|nothing added to commit') {
        Write-Host "git commit 失敗: $($commit.Output)"; return $false
    }
    $push = Invoke-ConsoleGit @('push')
    if ($push.ExitCode -ne 0) {
        $rebase = Invoke-ConsoleGit @('pull', '--rebase')
        if ($rebase.ExitCode -eq 0) { $push = Invoke-ConsoleGit @('push') }
    }
    if ($push.ExitCode -ne 0) {
        Write-Host 'push に失敗しました。ローカルcommitは残っています。ネットワーク/認証確認後にもう一度実行してください。'
        Write-Host $push.Output
        return $false
    }
    return $true
}

# ---------------------------------------------------------------------------
# A. Handoff Inbox（読み取り専用）
# ---------------------------------------------------------------------------
function Show-Inbox {
    param([string]$ToFilter, [int]$SinceDays)

    $docs = @(Get-HandoffFiles -RepoRoot $Script:RepoRoot | ForEach-Object { Get-HandoffDocument -File $_ -RepoRoot $Script:RepoRoot })
    if ($ToFilter) {
        $resolved = Resolve-MemberToken -Tokens ($ToFilter -split '_')
        if (-not $resolved.Token) { Write-Host "宛先フィルタを解決できません: $ToFilter"; return }
        $docs = @($docs | Where-Object { Test-HandoffAddressedTo -Doc $_ -Token $resolved.Token })
    }
    $docs = Select-DocsSince -Docs $docs -Days $SinceDays
    $docs = @($docs | Sort-Object { Get-DocDate $_ } -Descending)

    if ($docs.Count -eq 0) { Write-Host '該当するHandoffはありません。'; return }

    $docs | ForEach-Object {
        $to = $_.ToRaw; if (-not $to) { $to = $_.ToToken }; if (-not $to) { $to = '-' }
        $warn = ''; if ($_.Warnings.Count -gt 0) { $warn = "!$($_.Warnings.Count)" }
        [PSCustomObject]@{
            Date = ($_.Date -replace '\s+JST.*$', '')
            From = $(if ($_.From) { $_.From } else { '-' })
            To = $to
            TaskId = $(if ($_.TaskId) { $_.TaskId } else { '-' })
            Warn = $warn
            Path = $_.RelPath
        }
    } | Format-Table -AutoSize -Wrap | Out-String -Width 260 | Write-Host

    $warned = @($docs | Where-Object { $_.Warnings.Count -gt 0 })
    if ($warned.Count -gt 0) {
        Write-Host "必須項目の欠落・パース警告（$($warned.Count)件。表示のみ・処理は継続済み）:"
        foreach ($d in $warned) {
            Write-Host "  $($d.RelPath)"
            foreach ($w in $d.Warnings) { Write-Host "    - $w" }
        }
    }
    Write-Host ''
    Write-Host "合計 $($docs.Count) 件（読み取り専用。本コマンドはファイルを変更しません）"
}

# ---------------------------------------------------------------------------
# B. 起床パケット生成
# ---------------------------------------------------------------------------
function New-WakePacket {
    param([string]$MemberName, [int]$SinceDays, [bool]$DoPush)

    if (-not $MemberName) { Write-Host '使い方: iac-console wake <member> [-SinceDays N] [-Push]'; return }
    $resolved = Resolve-MemberToken -Tokens ($MemberName -split '_')
    if (-not $resolved.Token) { Write-Host "メンバー名を解決できません: $MemberName"; return }
    $token = $resolved.Token
    $display = Get-MemberDisplayName -Token $token

    if ($token -eq 'gemini') {
        Write-Host '二葉（Gemini）はGitHub Pullを前提にしない運用のため、本ツールでは起床パケットを生成しません。'
        Write-Host 'アークの単一Packet方式で配送してください（IACPROJECT/OPERATING_RULES/2026-08-09_COMMON_WAKEUP_MESSAGE.md 例外規定）。'
        return
    }

    if ($SinceDays -le 0) { $SinceDays = 7 }

    # 最新commit hash
    $head = Invoke-ConsoleGit @('rev-parse', 'HEAD')
    $headHash = '-'
    if ($head.ExitCode -eq 0) { $headHash = $head.Output.Trim() }

    # 共通起床文（登録済み正本を転記し、commit hashのみ最新へ差し替える）
    $commonLines = @()
    if (Test-Path $Script:CommonWakeMessagePath) {
        $raw = [System.IO.File]::ReadAllLines($Script:CommonWakeMessagePath, [System.Text.Encoding]::UTF8)
        foreach ($l in $raw) {
            $commonLines += ($l -replace '最新コミット：`[0-9a-f]+`', "最新コミット：``$headHash``")
        }
    } else {
        $commonLines = @('（共通起床文の正本 2026-08-09_COMMON_WAKEUP_MESSAGE.md が見つかりません）')
    }

    # 対象Handoff（宛先一致のみ。To / Required next action は転記であり推論しない）
    $docs = @(Get-HandoffFiles -RepoRoot $Script:RepoRoot | ForEach-Object { Get-HandoffDocument -File $_ -RepoRoot $Script:RepoRoot })
    $targets = @($docs | Where-Object { Test-HandoffAddressedTo -Doc $_ -Token $token })
    $targets = Select-DocsSince -Docs $targets -Days $SinceDays
    $targets = @($targets | Sort-Object { Get-DocDate $_ } -Descending)

    $today = Get-Date -Format 'yyyy-MM-dd'
    $out = New-Object System.Collections.Generic.List[string]
    $out.Add("# WAKE PACKET — $display")
    $out.Add('')
    $out.Add("**Generated**: $(Get-Date -Format 'yyyy-MM-dd HH:mm') JST by iac-console（機械生成。推論・優先順位付けなし）")
    $out.Add("**Latest commit**: ``$headHash``")
    $out.Add("**対象範囲**: 過去 $SinceDays 日の $display 宛Handoff（to_フォルダ / To欄の一致のみ）")
    $out.Add('')
    $out.Add('---')
    $out.Add('')
    $out.Add('## 共通起床文')
    $out.Add('')
    foreach ($l in $commonLines) { $out.Add($l) }
    $out.Add('')
    $out.Add('---')
    $out.Add('')
    $out.Add("## 対象Handoff（$($targets.Count)件）")
    $out.Add('')
    if ($targets.Count -eq 0) {
        $out.Add("期間内に $display 宛のHandoffはありません。")
    }
    foreach ($t in $targets) {
        $out.Add("### $($t.RelPath -replace '\\', '/')")
        $out.Add('')
        $out.Add("- Date: $(if ($t.Date) { $t.Date } else { '-' }) / From: $(if ($t.From) { $t.From } else { '-' }) / Task ID: $(if ($t.TaskId) { $t.TaskId } else { '-' })")
        if ($t.Status) { $out.Add("- Status（転記）: $($t.Status)") }
        $out.Add('- Required next action（転記）:')
        if ($t.RequiredNextAction) {
            foreach ($l in ($t.RequiredNextAction -split "`n")) { $out.Add("  > $l") }
        } else {
            $out.Add('  > （記載なし）')
        }
        if ($t.Questions.Count -gt 0) {
            $out.Add('- Questions queue（転記）:')
            foreach ($q in $t.Questions) { $out.Add("  - $q") }
        }
        if ($t.Warnings.Count -gt 0) {
            $out.Add("- 警告: $($t.Warnings -join ' / ')")
        }
        $out.Add('')
    }

    $fileName = "${today}_$($token.ToUpper())_WAKE_PACKET.md"
    $outPath = Join-Path (Join-Path $Script:WakeDir 'packets') $fileName
    Write-Utf8BomFile -Path $outPath -Lines $out
    $relOut = $outPath.Substring($Script:RepoRoot.Length).TrimStart('\')
    Write-Host "起床パケットを出力しました: $relOut（対象Handoff $($targets.Count)件）"

    if ($DoPush) {
        if (Push-GeneratedFile -RelPath $relOut -Message "wake: packet for $token ($today)") {
            Write-Host 'push 完了。スマートフォンからはGitHub上の同パスで参照できます。'
        }
    } else {
        Write-Host 'スマートフォンから参照するには -Push を付けて再実行するか、iac-deliver等で通常どおりpushしてください。'
    }
}

# ---------------------------------------------------------------------------
# C. Questions Queue 集約
# ---------------------------------------------------------------------------
function ConvertTo-QuestionKey {
    # 同一質問の判定用正規化。表記の空白・記号揺れのみを吸収する（意味的な類似判定はしない）。
    param([string]$Question)
    $q = $Question.ToLowerInvariant()
    $q = $q -replace '\*\*', ''
    $q = $q -replace '\s+', ''
    $q = $q -replace '[。．.、,]$', ''
    return $q
}

function Show-Questions {
    param([int]$SinceDays, [bool]$DoPush)

    $docs = @(Get-HandoffFiles -RepoRoot $Script:RepoRoot | ForEach-Object { Get-HandoffDocument -File $_ -RepoRoot $Script:RepoRoot })
    $docs = Select-DocsSince -Docs $docs -Days $SinceDays

    $groups = [ordered]@{}
    foreach ($d in ($docs | Sort-Object { Get-DocDate $_ } -Descending)) {
        foreach ($q in $d.Questions) {
            $key = ConvertTo-QuestionKey $q
            if (-not $key) { continue }
            # 「質問なし」を表す定型のみ機械的に除外する（それ以外の内容判断はしない）
            if ($key -match '^(なし|特になし|none|n/?a|-)$') { continue }
            if (-not $groups.Contains($key)) {
                $groups[$key] = [PSCustomObject]@{ Text = $q; Sources = New-Object System.Collections.Generic.List[string] }
            }
            $groups[$key].Sources.Add(($d.RelPath -replace '\\', '/'))
        }
    }

    $out = New-Object System.Collections.Generic.List[string]
    $out.Add('# QUESTIONS QUEUE 集約')
    $out.Add('')
    $out.Add("**Generated**: $(Get-Date -Format 'yyyy-MM-dd HH:mm') JST by iac-console")
    $out.Add('**Rule**: 各HandoffのQuestions queueを機械集約したもの。正規化後に同一の質問のみをまとめる。優先順位付け・要否判断は行わない。')
    if ($SinceDays -gt 0) { $out.Add("**対象範囲**: 過去 $SinceDays 日") }
    $out.Add('')
    $out.Add("## 未整理の質問（$($groups.Count)件）")
    $out.Add('')
    $i = 0
    foreach ($key in $groups.Keys) {
        $i++
        $g = $groups[$key]
        $out.Add("$i. $($g.Text)")
        foreach ($s in ($g.Sources | Sort-Object -Unique)) { $out.Add("   - source: $s") }
        if ($g.Sources.Count -gt 1) { $out.Add("   - （同一質問が $($g.Sources.Count) 件のHandoffに出現）") }
        $out.Add('')
    }
    if ($groups.Count -eq 0) { $out.Add('抽出できたQuestions queueはありません。') }

    foreach ($l in $out) { Write-Host $l }

    $outPath = Join-Path $Script:WakeDir 'QUESTIONS_SUMMARY.md'
    Write-Utf8BomFile -Path $outPath -Lines $out
    $relOut = $outPath.Substring($Script:RepoRoot.Length).TrimStart('\')
    Write-Host "集約結果を出力しました: $relOut"

    if ($DoPush) {
        if (Push-GeneratedFile -RelPath $relOut -Message 'questions: aggregate questions queue summary') {
            Write-Host 'push 完了。'
        }
    }
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
function Show-Usage {
    Write-Host 'IAC Operations Console (MVP) — 使い方:'
    Write-Host '  iac-console inbox [-To <member>] [-SinceDays N]   Handoff一覧（読み取り専用）'
    Write-Host '  iac-console wake <member> [-SinceDays N] [-Push]  起床パケット生成（既定: 過去7日）'
    Write-Host '  iac-console questions [-SinceDays N] [-Push]      Questions queue 集約'
    Write-Host ''
    Write-Host '詳細・フォールバック手順: tools\README_IAC_CONSOLE.md'
}

if ($env:IAC_CONSOLE_NO_MAIN -ne '1') {
    switch (($Command + '').ToLowerInvariant()) {
        'inbox'     { Show-Inbox -ToFilter $To -SinceDays $SinceDays }
        'wake'      { New-WakePacket -MemberName $Member -SinceDays $SinceDays -DoPush $Push.IsPresent }
        'questions' { Show-Questions -SinceDays $SinceDays -DoPush $Push.IsPresent }
        default     { Show-Usage }
    }
}
