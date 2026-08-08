#Requires -Version 5.1
<#
Task ID: IAC-FABLE-AUTONOMOUS-HANDOFF-001
Handoff接続ログの共有関数ライブラリ。iac-deliver.ps1 / iac-handoff-log.ps1 から dot-source される。
正本設計: IACPROJECT/HANDOFF/2026-08-08_ARC_TO_SNAKE_AUTONOMOUS_HANDOFF_ROUTING_FULL_HANDOFF.md
#>

# メンバー名トークンの正規化マップ。
# 表記ゆれ（ARK/ARC、SNAKE/GROK、KUROSE/CLAUDE 等）をひとつの正規トークンへ寄せる。
# kakezuki / ketsugetsu はどちらも欠月の romanization とみなして統合する（誤りならケイが指摘して戻す）。
$Script:MemberAliasMap = @{
    'claude'      = 'claude'
    'kurose'      = 'claude'
    'claudecode'  = 'claude_code'
    'claude_code' = 'claude_code'
    'gemini'      = 'gemini'
    'futaba'      = 'gemini'
    'grok'        = 'grok'
    'snake'       = 'grok'
    'chatgpt'     = 'chatgpt'
    'codex'       = 'chatgpt'
    'arc'         = 'arc'
    'ark'         = 'arc'
    'tsuzuri'     = 'tsuzuri'
    'uehara'      = 'uehara'
    'yue'         = 'yue'
    'tanaka'      = 'tanaka'
    'kaduki'      = 'ketsugetsu'
    'ketsugetsu'  = 'ketsugetsu'
    'ketsuzuki'   = 'ketsugetsu'
    'ketsuki'     = 'ketsugetsu'
    'kakezuki'    = 'ketsugetsu'
    'yuimaru'     = 'yuimaru'
    'rimi'        = 'rimi'
    'masaru'      = 'masaru'
    'matome'      = 'matome'
    'yura'        = 'yura'
    'all'         = 'all'
    'kei'         = 'kei'
}

# 正式表示名（2026-08-08 正本で確定した呼称）。集計表示にのみ使用し、ログには正規トークンを保存する。
$Script:MemberDisplayMap = @{
    'claude'      = '黒瀬（Claude）'
    'claude_code' = 'Claude Code'
    'gemini'      = '二葉（Gemini）'
    'grok'        = 'スネーク（Grok）'
    'chatgpt'     = 'ChatGPT Codex'
    'arc'         = 'アーク'
    'ketsugetsu'  = '欠月'
    'tsuzuri'     = '綴'
    'uehara'      = '上原さん'
    'yue'         = 'ユエ'
    'tanaka'      = '田中'
    'yuimaru'     = 'ゆいま〜る'
    'rimi'        = 'りみ'
    'masaru'      = 'まさる姐さん'
    'matome'      = '纏めの君'
    'yura'        = 'ユラ'
    'all'         = '全員'
    'kei'         = 'ケイ'
}

function Get-MemberDisplayName {
    param([string]$Token)
    if ($Script:MemberDisplayMap.ContainsKey($Token)) { return $Script:MemberDisplayMap[$Token] }
    return $Token
}

function Resolve-MemberToken {
    # トークン列の先頭から、2語結合（claude+code等）を優先してメンバー名を解決する。
    # 戻り値: @{ Token = 正規トークン or $null; Consumed = 消費したトークン数 }
    param([string[]]$Tokens)
    if (-not $Tokens -or $Tokens.Count -eq 0) { return @{ Token = $null; Consumed = 0 } }
    $t1 = $Tokens[0].ToLowerInvariant()
    if ($Tokens.Count -ge 2) {
        $combined = $t1 + $Tokens[1].ToLowerInvariant()
        if ($Script:MemberAliasMap.ContainsKey($combined)) {
            return @{ Token = $Script:MemberAliasMap[$combined]; Consumed = 2 }
        }
    }
    if ($Script:MemberAliasMap.ContainsKey($t1)) {
        return @{ Token = $Script:MemberAliasMap[$t1]; Consumed = 1 }
    }
    return @{ Token = $null; Consumed = 0 }
}

function Get-HandoffFromTo {
    <#
    ファイル名（拡張子なし）から date / from / to / task を推定する。
    命名規約: YYYY-MM-DD_<FROM>_TO_<TO>_<内容>
    - TO は「_TO_ 直後の最初のメンバー名」1名のみ（複数宛の2人目以降は内容扱い。数え漏れは許容し、
      本文まで解析しない。接続強度は補助指標であり厳密さより止まらないことを優先する）
    - 判定不能な項目は $null
    #>
    param([string]$FileBaseName)

    $date = $null
    if ($FileBaseName -match '(\d{4}-\d{2}-\d{2})') { $date = $Matches[1] }

    $from = $null; $to = $null; $task = $FileBaseName

    # 日付・時刻プレフィックスを除去してトークン化
    $stripped = $FileBaseName -replace '^\d{4}-\d{2}-\d{2}(_\d{3,4})?_', ''
    $toSplit = [regex]::Split($stripped, '(?i)_TO_', 'None')
    if ($stripped -match '^(?i)to_') {
        # "2026-08-06_to_ketsugetsu_..." のようにTOだけが書かれた形式。FROMは呼び出し側で補完する。
        $toTokens = $stripped.Substring(3) -split '_'
        $toResult = Resolve-MemberToken -Tokens $toTokens
        $to = $toResult.Token
        if ($toResult.Consumed -gt 0 -and $toTokens.Count -gt $toResult.Consumed) {
            $task = ($toTokens[$toResult.Consumed..($toTokens.Count - 1)] -join '_')
        }
    } elseif ($toSplit.Count -ge 2) {
        $fromTokens = $toSplit[0] -split '_'
        $fromResult = Resolve-MemberToken -Tokens $fromTokens
        $from = $fromResult.Token

        $toTokens = ($toSplit[1..($toSplit.Count - 1)] -join '_TO_') -split '_'
        $toResult = Resolve-MemberToken -Tokens $toTokens
        $to = $toResult.Token
        if ($toResult.Consumed -gt 0 -and $toTokens.Count -gt $toResult.Consumed) {
            $task = ($toTokens[$toResult.Consumed..($toTokens.Count - 1)] -join '_')
        }
    } else {
        $fromResult = Resolve-MemberToken -Tokens ($stripped -split '_')
        $from = $fromResult.Token
    }

    return [PSCustomObject]@{ Date = $date; From = $from; To = $to; Task = $task }
}

function Get-HandoffLogPath {
    param([string]$RepoRoot)
    return Join-Path $RepoRoot 'IACPROJECT\ROUTER\HANDOFF_CONNECTION_LOG.md'
}

function Initialize-HandoffLog {
    param([string]$LogPath)
    if (Test-Path $LogPath) { return }
    $header = @(
        '# HANDOFF_CONNECTION_LOG',
        '',
        '**Purpose**: AI間Handoffの接続履歴（誰→誰）を機械集計可能な形で1ファイルに記録する。',
        '**Writer**: iac-deliver（配送時に自動追記）／iac-handoff-log add（手動追記）',
        '**Reader**: iac-handoff-log tally（接続強度の集計）',
        '**Rule**: 接続回数は自主Handoff先選択の補助指標。担当適合性（AI_MEMBER_DIRECTORY.md）が常に優先。',
        '**Note**: 過去分はファイル名からのバックフィルであり、複数宛Handoffは先頭宛先のみ記録される。',
        '',
        '| date | from | to | task | handoff_path | commit |',
        '|---|---|---|---|---|---|'
    )
    $utf8Bom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllLines($LogPath, $header, $utf8Bom)
}

function Add-HandoffLogEntry {
    <#
    接続ログへ1行追記する。同じ handoff_path の行が既にあれば追記しない（再実行時の重複防止）。
    戻り値: 追記したら $true、スキップなら $false
    #>
    param(
        [string]$LogPath,
        [string]$Date,
        [string]$From,
        [string]$To,
        [string]$Task,
        [string]$HandoffPath,
        [string]$Commit
    )
    Initialize-HandoffLog -LogPath $LogPath

    $pathKey = $HandoffPath -replace '\\', '/'
    $existing = [System.IO.File]::ReadAllText($LogPath)
    if ($existing.Contains("| $pathKey |")) { return $false }

    foreach ($v in 'Date', 'From', 'To', 'Task', 'Commit') {
        if (-not (Get-Variable $v -ValueOnly)) { Set-Variable $v '-' }
    }
    $Task = $Task -replace '\|', '/'
    $row = "| $Date | $From | $To | $Task | $pathKey | $Commit |"
    $utf8Bom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::AppendAllText($LogPath, ($row + "`r`n"), $utf8Bom)
    return $true
}

function Get-HandoffLogEntries {
    param([string]$LogPath)
    if (-not (Test-Path $LogPath)) { return @() }
    $entries = @()
    foreach ($line in [System.IO.File]::ReadAllLines($LogPath)) {
        if ($line -notmatch '^\|') { continue }
        $cells = ($line.Trim('|') -split '\|') | ForEach-Object { $_.Trim() }
        if ($cells.Count -lt 6) { continue }
        if ($cells[0] -eq 'date' -or $cells[0] -match '^-+$') { continue }
        $entries += [PSCustomObject]@{
            Date = $cells[0]; From = $cells[1]; To = $cells[2]
            Task = $cells[3]; HandoffPath = $cells[4]; Commit = $cells[5]
        }
    }
    return $entries
}
