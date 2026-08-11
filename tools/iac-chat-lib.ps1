#Requires -Version 5.1
<#
Task ID: IAC-CHAT-UI-001
複数人会話用チャットUIのロジック層（Handoff本文組み立て・ファイル名生成・ALL宛先分解）。
paramブロックを持たない（dot-source専用ライブラリ）。iac-chat-ui.ps1 / iac-chat-ui-selftest.ps1 から
dot-sourceされる。iac-handoff-lib.ps1 と併せてdot-sourceされる前提（$Script:MemberAliasMap /
$Script:MemberDisplayMap / Get-MemberDisplayName に依存）。

CLAUDE.md「PowerShellツール実装時の注意（dot-source変数名衝突）」に従い、iac-console.ps1の
param名（Command, Member, To, SinceDays, Push）と同名の変数はこのファイル内で一切使わない。
#>

# ---------------------------------------------------------------------------
# ALL宛先分解の順序（IACPROJECT/OPERATING_RULES/AI_MEMBER_DIRECTORY.md §2-6 の登録順）
# ---------------------------------------------------------------------------
$Script:ChatMemberOrder = @(
    'kakezuki', 'arc', 'tsuzuri', 'uehara', 'yue', 'tanaka', 'yuimaru', 'rimi', 'masaru', 'matome',
    'claude', 'claude_code', 'gemini', 'grok'
)

function Get-ChatAllRecipientTokens {
    <#
    ALL送信時の宛先トークン一覧を返す。$Script:ChatMemberOrder（AI_MEMBER_DIRECTORY.md登録順）を
    基準とし、$Script:MemberAliasMap の正規トークン集合（'all'/'kei'を除く）との差分をアルファベット順で
    末尾に補う。差分（ディレクトリ未登録のトークン）はWarningsとして返す。
    戻り値: @{ Tokens = [string[]]; Warnings = [string[]] }
    #>
    $known = @($Script:MemberAliasMap.Values | Sort-Object -Unique | Where-Object { $_ -ne 'all' -and $_ -ne 'kei' })
    $missing = @($known | Where-Object { $Script:ChatMemberOrder -notcontains $_ } | Sort-Object)
    $warnings = @()
    foreach ($m in $missing) {
        $warnings += "AI_MEMBER_DIRECTORY.md未登録のためALL末尾へ補った: $m（$(Get-MemberDisplayName -Token $m)）"
    }
    $tokens = @($Script:ChatMemberOrder) + $missing
    return @{ Tokens = $tokens; Warnings = $warnings }
}

# ---------------------------------------------------------------------------
# Handoff Markdown 組み立て
# ---------------------------------------------------------------------------
function Get-ChatTaskId {
    param([datetime]$Now)
    return "IAC-CHAT-$($Now.ToString('yyyyMMdd-HHmmss'))"
}

function New-ChatHandoffBody {
    <#
    チャット送信1件分のHandoff Markdown本文を組み立てる。
    本文は ## Required next action セクションへそのまま入れる（iac-console wake の転記元
    セクションと一致させ、追加セクション種別を新設しない設計判断）。
    #>
    param(
        [string]$ToDisplayName,
        [string[]]$CcDisplayNames = @(),
        [string]$TaskId,
        [datetime]$Now,
        [string]$MessageText
    )
    $dateText = $Now.ToString('yyyy-MM-dd HH:mm') + ' JST'
    $lines = @(
        '# HANDOFF',
        '',
        '## From / To',
        '',
        'From: ケイ',
        "To: $ToDisplayName"
    )
    if ($CcDisplayNames.Count -gt 0) {
        $lines += "CC: $($CcDisplayNames -join ', ')"
    }
    $lines += @(
        '',
        '## Task ID',
        '',
        $TaskId,
        '',
        '## Date',
        '',
        $dateText,
        '',
        '## Required next action',
        '',
        $MessageText,
        '',
        '## Status',
        '',
        'CHAT MESSAGE（iac-chat-uiより送信）'
    )
    return ($lines -join "`r`n")
}

# ---------------------------------------------------------------------------
# ファイル名生成・衝突回避
# ---------------------------------------------------------------------------
function Get-ChatHandoffFileName {
    <#
    命名規約: YYYY-MM-DD_HHmm_KEI_TO_<TOKEN>_CHAT.md
    同一分内の連投は staging/ と inbox/from_kei/ の両方をチェックし _CHAT2, _CHAT3... と連番で回避する。
    #>
    param(
        [string]$RepoRoot,
        [string]$Token,
        [datetime]$Now
    )
    $prefix = $Now.ToString('yyyy-MM-dd_HHmm')
    $tokenUpper = $Token.ToUpperInvariant()
    $stagingDir = Join-Path $RepoRoot 'staging'
    $inboxDir = Join-Path $RepoRoot "IACPROJECT\inbox\from_kei"

    $suffix = ''
    $n = 1
    while ($true) {
        $candidate = "${prefix}_KEI_TO_${tokenUpper}_CHAT${suffix}.md"
        $existsStaging = Test-Path (Join-Path $stagingDir $candidate)
        $existsInbox = Test-Path (Join-Path $inboxDir $candidate)
        if (-not $existsStaging -and -not $existsInbox) { return $candidate }
        $n++
        $suffix = "$n"
    }
}

function Write-ChatUtf8BomFile {
    param([string]$Path, [string]$Content)
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $utf8Bom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8Bom)
}

# ---------------------------------------------------------------------------
# 定期同期（git pull + diffベースの新着検知）
# バックグラウンドRunspace内でも使えるよう、iac-handoff-lib.ps1/iac-console.ps1への依存を持たない。
# ---------------------------------------------------------------------------
function Invoke-ChatGitCommand {
    param([string]$RepoRoot, [string[]]$GitArgs)
    Push-Location $RepoRoot
    try {
        $output = & git @GitArgs 2>&1 | ForEach-Object { $_.ToString() }
        return [PSCustomObject]@{ ExitCode = $LASTEXITCODE; Output = ($output -join "`n") }
    } finally {
        Pop-Location
    }
}

function Sync-ChatInboxFromRemote {
    <#
    git pull --ff-only を実行し、新着（IACPROJECT/inbox配下の.md）の相対パス一覧を返す。
    fast-forwardできない・pull失敗時は自動rebase等をせず失敗理由を返すだけで止める
    （既存ツール群の「勝手に解決しない」原則。iac-chat-ui.ps1側でステータス表示のみ行う）。
    戻り値: @{ Success; Reason('no_change'|'updated'|'pull_failed'); Output; ChangedRelPaths }
    #>
    param([string]$RepoRoot)
    $oldHead = (Invoke-ChatGitCommand -RepoRoot $RepoRoot -GitArgs @('rev-parse', 'HEAD')).Output.Trim()
    $pullResult = Invoke-ChatGitCommand -RepoRoot $RepoRoot -GitArgs @('pull', '--ff-only')
    if ($pullResult.ExitCode -ne 0) {
        return [PSCustomObject]@{ Success = $false; Reason = 'pull_failed'; Output = $pullResult.Output; ChangedRelPaths = @() }
    }
    $newHead = (Invoke-ChatGitCommand -RepoRoot $RepoRoot -GitArgs @('rev-parse', 'HEAD')).Output.Trim()
    if ($oldHead -eq $newHead) {
        return [PSCustomObject]@{ Success = $true; Reason = 'no_change'; Output = ''; ChangedRelPaths = @() }
    }
    $diffResult = Invoke-ChatGitCommand -RepoRoot $RepoRoot -GitArgs @('diff', '--name-only', $oldHead, $newHead)
    $changed = @($diffResult.Output -split "`r?`n" | Where-Object { $_ -like 'IACPROJECT/inbox/*' -and $_ -like '*.md' })
    return [PSCustomObject]@{ Success = $true; Reason = 'updated'; Output = ''; ChangedRelPaths = $changed }
}

# ---------------------------------------------------------------------------
# 送信対象の組み立て（単一宛先 / ALL宛先分解）
# ---------------------------------------------------------------------------
function Build-ChatOutgoingHandoffs {
    <#
    送信ボタン押下時に呼ぶメイン組み立て関数。単一宛先なら1件、ALLなら
    Get-ChatAllRecipientTokens の順序で1トークン1ファイルに分解する。
    本文の To: 行には常に単一メンバー表示名のみを書く（誤配送防止ルールとの整合、
    Test-GeminiBridgeSingleRecipient と同じ「単一宛先のみ」原則をここでも踏襲）。
    戻り値: @{ Items = [PSCustomObject[]](FileName, RelPath, FullPath, Content, Token, DisplayName);
               Warnings = [string[]] }
    #>
    param(
        [string]$RepoRoot,
        [string]$TargetToken,
        [string]$MessageText,
        [datetime]$Now
    )
    $warnings = @()
    if ($TargetToken -eq 'all') {
        $allResult = Get-ChatAllRecipientTokens
        $tokens = $allResult.Tokens
        $warnings += $allResult.Warnings
        if ($tokens -contains 'gemini') {
            $warnings += '二葉（Gemini）宛は個別配送されますが、Gemini Bridgeの自動処理対象（inbox/from_arc・from_gemini）には入りません。実際に届けるには別途アークによる単一Packet工程が必要です。'
        }
    } else {
        $tokens = @($TargetToken)
    }

    $items = New-Object System.Collections.Generic.List[object]
    foreach ($token in $tokens) {
        $displayName = Get-MemberDisplayName -Token $token
        $ccNames = @()
        if ($TargetToken -eq 'all') {
            $ccNames = @($tokens | Where-Object { $_ -ne $token } | ForEach-Object { Get-MemberDisplayName -Token $_ })
        }
        $taskId = (Get-ChatTaskId -Now $Now) + "-$token"
        $body = New-ChatHandoffBody -ToDisplayName $displayName -CcDisplayNames $ccNames -TaskId $taskId -Now $Now -MessageText $MessageText
        $fileName = Get-ChatHandoffFileName -RepoRoot $RepoRoot -Token $token -Now $Now
        $fullPath = Join-Path (Join-Path $RepoRoot 'staging') $fileName
        $relInboxPath = "IACPROJECT/inbox/from_kei/$fileName"
        $items.Add([PSCustomObject]@{
            FileName        = $fileName
            FullPath        = $fullPath
            RelInboxPath    = $relInboxPath
            Content         = $body
            Token           = $token
            DisplayName     = $displayName
        })
    }
    return @{ Items = $items; Warnings = $warnings }
}

function Save-ChatOutgoingHandoffs {
    <# Build-ChatOutgoingHandoffs の結果を staging/ へ実際に書き出す。 #>
    param([object[]]$Items)
    foreach ($item in $Items) {
        Write-ChatUtf8BomFile -Path $item.FullPath -Content $item.Content
    }
}

# ---------------------------------------------------------------------------
# 受信表示（Get-HandoffDocumentの結果 → WPFバインド用オブジェクトへの変換）
# ---------------------------------------------------------------------------
if (-not ([System.Management.Automation.PSTypeName]'IacChat.ChatMessageItem').Type) {
    Add-Type -Language CSharp -TypeDefinition @'
namespace IacChat {
    public class ChatMessageItem {
        public string DisplayName { get; set; }
        public string DateText { get; set; }
        public string TaskId { get; set; }
        public string Body { get; set; }
        public bool HasWarning { get; set; }
        public string WarningText { get; set; }
        public string RelPath { get; set; }
        public string FromToken { get; set; }
    }
}
'@
}

function ConvertTo-ChatMessageItem {
    <# Get-HandoffDocument の返すHandoffドキュメントを、WPFにバインドするChatMessageItemへ変換する。
       From欄が空の場合はFromTokenから表示名を解決し、それも無ければファイル名を使う（止めない設計）。 #>
    param($Doc)
    $displayName = if ($Doc.From) { $Doc.From }
        elseif ($Doc.FromToken) { Get-MemberDisplayName -Token $Doc.FromToken }
        else { $Doc.FileName }
    $body = if ($Doc.RequiredNextAction) { $Doc.RequiredNextAction }
        elseif ($Doc.Status) { $Doc.Status }
        else { '(本文を抽出できませんでした)' }
    $item = New-Object IacChat.ChatMessageItem
    $item.DisplayName = $displayName
    $item.DateText    = $Doc.Date
    $item.TaskId      = $Doc.TaskId
    $item.Body        = $body
    $item.HasWarning  = ($Doc.Warnings.Count -gt 0)
    $item.WarningText = if ($Doc.Warnings.Count -gt 0) { '警告: ' + ($Doc.Warnings -join ' / ') } else { '' }
    $item.RelPath     = $Doc.RelPath
    $item.FromToken   = $Doc.FromToken
    return $item
}

function ConvertTo-ChatOutgoingMessageItem {
    <# 送信直後の楽観的UI更新用。Build-ChatOutgoingHandoffsの1アイテムから簡易的にChatMessageItemを作る。
       受信ポーリングが同一RelPathを検知した際は重複追加せず、既知セットから外すだけにする（4.5節）。 #>
    param($OutgoingItem, [datetime]$Now, [string]$MessageText)
    $item = New-Object IacChat.ChatMessageItem
    $item.DisplayName = "ケイ → $($OutgoingItem.DisplayName)"
    $item.DateText    = $Now.ToString('yyyy-MM-dd HH:mm') + ' JST'
    $item.TaskId      = ''
    $item.Body        = $MessageText
    $item.HasWarning  = $false
    $item.WarningText = ''
    $item.RelPath     = $OutgoingItem.RelInboxPath
    $item.FromToken   = 'kei'
    return $item
}

function Get-ChatInitialMessages {
    <# 起動時フルスキャン。Get-HandoffFiles / Get-HandoffDocument / Get-DocDate / Select-DocsSince
       （いずれも iac-console.ps1 由来、事前にdot-source済みであること）を使い、直近DaysBack日分を
       日付昇順でChatMessageItemのリストとして返す。宛先での絞り込みはしない（要件通りの簡易表示）。 #>
    param([string]$RepoRoot, [int]$DaysBack = 7)
    $files = Get-HandoffFiles -RepoRoot $RepoRoot
    $docs = @($files | ForEach-Object { Get-HandoffDocument -File $_ -RepoRoot $RepoRoot })
    $filtered = @(Select-DocsSince -Docs $docs -Days $DaysBack)
    $sorted = $filtered | Sort-Object { Get-DocDate $_ }
    return @($sorted | ForEach-Object { ConvertTo-ChatMessageItem -Doc $_ })
}

function Test-ChatDotSourceVariableCollision {
    <#
    iac-console.ps1 の param() ブロックにある変数名が、iac-chat-lib.ps1 / iac-chat-ui.ps1 の
    ソース中で「素の $Name」として使われていないかを静的にチェックする（$Script:Name 接頭辞付きは
    誤検知しない）。衝突していれば変数名の配列を返す（空配列なら問題なし）。
    #>
    param([string]$RepoRoot)
    $consolePath = Join-Path $RepoRoot 'tools\iac-console.ps1'
    $consoleSrc = [System.IO.File]::ReadAllText($consolePath)
    $paramMatch = [regex]::Match($consoleSrc, '(?ms)^param\((.*?)^\)')
    if (-not $paramMatch.Success) { return @('iac-console.ps1のparamブロックを検出できませんでした') }
    $paramBlock = $paramMatch.Groups[1].Value
    $names = @([regex]::Matches($paramBlock, '\$(\w+)') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)

    $targets = @('tools\iac-chat-lib.ps1', 'tools\iac-chat-ui.ps1')
    $collisions = New-Object System.Collections.Generic.List[string]
    foreach ($rel in $targets) {
        $p = Join-Path $RepoRoot $rel
        if (-not (Test-Path $p)) { continue }
        $src = [System.IO.File]::ReadAllText($p)
        foreach ($n in $names) {
            if ([regex]::IsMatch($src, "(?<!Script:)(?<!\w)\`$$n\b")) {
                $collisions.Add("$rel : `$$n")
            }
        }
    }
    return @($collisions)
}
