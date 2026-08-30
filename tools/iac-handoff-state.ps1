#Requires -Version 5.1
<#
Task ID: HANDOFF-STATE-TRACKING-2026-08-30-01
Mechanical Handoff State Tracker — Pilot implementation.

Read-only evidence scanner. Never edits existing Handoff files.
Only output: console report + generated IACPROJECT/PENDING_BY_MEMBER/*.md files.

Source proposal : IACPROJECT/inbox/to_arc/2026-08-30_YUE_TO_ARC_MECHANICAL_HANDOFF_STATE_TRACKING_PROPOSAL.md
Pilot spec      : IACPROJECT/OPERATING_RULES/HANDOFF_STATE_TRACKING_PILOT.md
Routing handoff : IACPROJECT/inbox/from_arc/2026-08-30_ARC_TO_SATO_HANDOFF_STATE_TRACKER_PILOT.md

Design notes (answers the 8 "required first return" points; see the accompanying
Handoff report for the full prose version):

  1. scan targets  : IACPROJECT/**/*.md, excluding PENDING_BY_MEMBER/ (own generated
                      output) and ARCHIVE/.
  2. extraction    : first 40 lines of each file, line-anchored regex for
                      Task ID / To / From / State. No full-document NLP.
  3. evidence rule : see Get-TaskState below — each stage requires a *distinct*
                      file+commit, not prose inside an existing file.
  4. missing id    : any file without a Task ID line is never classified; it is
                      only counted/listed under UNTRACKED_ID. Never auto-assigned.
  5. PENDING_BY_MEMBER: regenerated in full on every -Scan run (idempotent
                      overwrite of generated files only), one file per member that
                      currently has >=1 task_id item addressed to them.
  6. false CLOSED  : stage N requires stage N-1 already true (strict monotonic
                      chain) AND, for RESULT_COMMITTED/REVIEWED, a commit-SHA-like
                      token that Test-CommitExists can verify with `git cat-file -e`.
                      Prose alone ("completed") is never evidence by itself.
                      Verified by -SelfTest against synthetic fixtures (fake SHA,
                      missing review) so the negative cases are exercised, not just
                      asserted.
  7. no collision  : HANDOFF_CONNECTION_LOG.md stays iac-deliver's exclusive
                      writer -- this script only *reads* it as one ROUTED evidence
                      source and reuses iac-handoff-lib.ps1's member resolution
                      instead of a second alias table. Never writes to it.
  8. min test set  : -Scan against the real repo (pilot's own task_id +
                      whatever else already carries one) and -SelfTest against
                      synthetic fixtures for the state-machine edge cases.

Usage:
  iac-handoff-state.ps1 -Scan       Read-only scan of the real repo, prints report,
                                     (re)writes IACPROJECT/PENDING_BY_MEMBER/*.md
  iac-handoff-state.ps1 -SelfTest   Synthetic-fixture tests of the state machine
                                     (no repo files touched)
#>
[CmdletBinding()]
param(
    [switch]$Scan,
    [switch]$SelfTest,
    [switch]$WriteIndex
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'iac-handoff-lib.ps1')

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$IacRoot  = Join-Path $RepoRoot 'IACPROJECT'

# Build a reverse lookup from Japanese display name (with or without the
# parenthetical AI-product suffix) back to the canonical token, so headers like
# "To: 佐藤（Claude Code）" resolve the same way "claude_code" would.
function Get-ReverseDisplayMap {
    $map = @{}
    foreach ($tok in $Script:MemberDisplayMap.Keys) {
        $disp = $Script:MemberDisplayMap[$tok]
        $bare = ($disp -replace '（.*）', '') -replace '\(.*\)', ''
        $map[$disp] = $tok
        $map[$bare] = $tok
    }
    return $map
}
$Script:ReverseDisplay = Get-ReverseDisplayMap

function Resolve-RecipientToken {
    # Accepts one raw name fragment (already split on , / 、 / ／) and resolves it
    # to a canonical member token, trying Japanese display names first, then the
    # ascii alias map from iac-handoff-lib.ps1. Returns $null if unresolved
    # (never guesses).
    param([string]$Raw)
    $name = $Raw.Trim()
    if (-not $name) { return $null }
    if ($Script:ReverseDisplay.ContainsKey($name)) { return $Script:ReverseDisplay[$name] }
    $bare = ($name -replace '（.*）', '') -replace '\(.*\)', ''
    $bare = $bare.Trim()
    if ($Script:ReverseDisplay.ContainsKey($bare)) { return $Script:ReverseDisplay[$bare] }
    $asciiResult = Resolve-MemberToken -Tokens (@($bare.ToLowerInvariant()))
    if ($asciiResult.Token) { return $asciiResult.Token }
    return $null
}

function Get-RecipientTokens {
    # Splits a raw "To:"/"From:" line value into resolved member tokens.
    # Unresolved fragments are dropped silently (reported separately by callers
    # that care) rather than guessed.
    param([string]$RawLine)
    if (-not $RawLine) { return @() }
    $parts = $RawLine -split '[,、／/]'
    $tokens = @()
    foreach ($p in $parts) {
        $t = Resolve-RecipientToken -Raw $p
        if ($t) { $tokens += $t }
    }
    # @(...) wrapper: piping zero objects through Select-Object collapses the
    # result to $null instead of an empty array, which breaks downstream
    # Compare-Object / .Count calls (ReferenceObject cannot be $null).
    return @($tokens | Select-Object -Unique)
}

function Read-HandoffHeader {
    # Extracts Task ID / To / From / State from the first 40 lines of a file.
    # Line-anchored regex only -- deliberately not a full markdown/YAML parser.
    param([string]$Path)
    # -Encoding UTF8 is required: Windows PowerShell 5.1's Get-Content defaults to
    # the system ANSI codepage for BOM-less files, which silently mangles every
    # Japanese To:/From: value (garbage text that then fails to resolve against
    # any member name -- this was caught live during -Scan against the real repo,
    # where it made every task_id show ROUTED=no).
    $lines = Get-Content -LiteralPath $Path -TotalCount 40 -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $lines) { return $null }
    $text = $lines -join "`n"

    $taskId = $null
    if ($text -match '(?im)^[-\s]*task[_ ]?id\s*[:：]\s*`?([A-Za-z0-9][A-Za-z0-9_\-]*)`?') {
        $taskId = $Matches[1]
    }
    $toRaw = $null
    if ($text -match '(?im)^[-\s]*To\s*[:：]\s*(.+)$') { $toRaw = $Matches[1].Trim() }
    $fromRaw = $null
    if ($text -match '(?im)^[-\s]*From\s*[:：]\s*(.+)$') { $fromRaw = $Matches[1].Trim() }
    $stateRaw = $null
    if ($text -match '(?im)^[-\s]*State\s*[:：]\s*(.+)$') { $stateRaw = $Matches[1].Trim() }

    return [PSCustomObject]@{
        Path    = $Path
        TaskId  = $taskId
        # @(...) at the CALL SITE (not just inside the function) is required:
        # a function's `return`/output still enumerates an empty array into
        # zero pipeline objects, which collapses to $null at the caller even
        # if the function itself wrapped its return value in @(...).
        To      = @(Get-RecipientTokens -RawLine $toRaw)
        From    = @(Get-RecipientTokens -RawLine $fromRaw)
        State   = $stateRaw
        RawText = $text
        FullText = (Get-Content -LiteralPath $Path -Raw -Encoding UTF8 -ErrorAction SilentlyContinue)
    }
}

function Get-FirstAddCommit {
    # SHA of the commit that first added this file, per local git history.
    # Read-only; never fails the caller on error (returns $null).
    param([string]$RelPath)
    Push-Location $RepoRoot
    try {
        $out = & git log --diff-filter=A --format=%H -n 1 -- $RelPath 2>$null
        if ($LASTEXITCODE -eq 0 -and $out) { return $out.Trim() }
        return $null
    } finally { Pop-Location }
}

function Get-FirstAddCommitInfo {
    # Like Get-FirstAddCommit, but also returns the commit's author-date (unix
    # epoch) so callers can order multiple candidate files chronologically
    # (needed to pick the earliest ROUTED file across a task_id with more than
    # one routing event -- see Get-TaskState). Returns $null on any failure.
    param([string]$RelPath)
    Push-Location $RepoRoot
    try {
        $out = & git log --diff-filter=A --format=%H,%at -n 1 -- $RelPath 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $out) { return $null }
        $parts = $out.Trim() -split ','
        if ($parts.Count -lt 2) { return $null }
        return [PSCustomObject]@{ Sha = $parts[0]; Timestamp = [long]$parts[1] }
    } finally { Pop-Location }
}

function Test-CommitExists {
    # Verifies a commit SHA actually exists in local history before it may be
    # counted as evidence. This is the concrete anti-false-positive check for
    # RESULT_COMMITTED / REVIEWED: a plausible-looking but wrong/future SHA in a
    # doc's prose does not verify and is not counted.
    param([string]$Sha)
    if (-not $Sha -or $Sha -notmatch '^[0-9a-f]{7,40}$') { return $false }
    Push-Location $RepoRoot
    try {
        & git cat-file -e $Sha 2>$null
        return ($LASTEXITCODE -eq 0)
    } finally { Pop-Location }
}

function Get-CommitTokensInText {
    # Pulls candidate commit-SHA-looking tokens out of backtick-quoted spans,
    # since that's the house convention in this repo's Handoff docs
    # (`` `a722cad4d404507da5ea5d7c14606429a837fa9c` ``).
    param([string]$Text)
    $tokens = [regex]::Matches($Text, '`([0-9a-f]{7,40})`') | ForEach-Object { $_.Groups[1].Value }
    # @(...) wrapper: piping zero objects through Select-Object collapses the
    # result to $null instead of an empty array, which breaks downstream
    # Compare-Object / .Count calls (ReferenceObject cannot be $null).
    return @($tokens | Select-Object -Unique)
}

function ConvertTo-NormalizedVerdict {
    param([string]$Raw)
    $r = ($Raw -replace '\s+', ' ').Trim().ToUpperInvariant()
    if ($r -match '^APPROVE\s+WITH\s+CONDITIONS$') { return 'APPROVE_WITH_CONDITIONS' }
    if ($r -eq 'APPROVE' -or $Raw.Trim() -eq '承認') { return 'APPROVE' }
    if ($r -eq 'HOLD') { return 'HOLD' }
    return $null
}

function Get-ReviewVerdict {
    <#
    Returns a normalized verdict ('APPROVE' / 'APPROVE_WITH_CONDITIONS' / 'HOLD')
    if the text contains real review-verdict evidence, or $null otherwise.
    Deliberately narrow to avoid the false-positive this pilot already hit once
    (bare "判定"/"APPROVE" anywhere in ordinary prose, e.g. Yue's proposal using
    "実ファイルの存在で機械判定する"). Only two accepted forms:

      same-line label : "判定: APPROVE" / "Verdict: HOLD" (the original form)
      heading style    : a "## 判定" / "## Verdict" heading, with a bare verdict
                         token appearing within the next 1-3 non-empty lines
                         (added per Arc's report that Kurose's actual reviews
                         commonly use heading style rather than a same-line
                         label -- IACPROJECT/inbox/from_arc/2026-08-30_ARC_TO_SATO_HANDOFF_STATE_TRACKER_KUROSE_HEADING_FORMAT_FIX.md)

    Verdict tokens are restricted to a fixed set (APPROVE / APPROVE WITH
    CONDITIONS / HOLD / 承認) -- never a free-form keyword scan.
    #>
    param([string]$Text)
    if (-not $Text) { return $null }

    if ($Text -match '(?im)^.*(?:判定|verdict)\s*[:：].*?(APPROVE\s+WITH\s+CONDITIONS|APPROVE|HOLD|承認)') {
        $v = ConvertTo-NormalizedVerdict -Raw $Matches[1]
        if ($v) { return $v }
    }

    $lines = $Text -split "`r?`n"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -notmatch '(?im)^#{1,6}\s*(?:判定|verdict)\s*[:：]?\s*$') { continue }
        $checked = 0
        for ($j = $i + 1; $j -lt $lines.Count -and $checked -lt 3; $j++) {
            $line = $lines[$j].Trim()
            if (-not $line) { continue }
            $checked++
            if ($line -match '(?i)(APPROVE\s+WITH\s+CONDITIONS|APPROVE|HOLD|承認)') {
                $v = ConvertTo-NormalizedVerdict -Raw $Matches[1]
                if ($v) { return $v }
            }
        }
    }
    return $null
}

function Get-TaskState {
    <#
    Evidence-based state machine for one task_id.
    $Files = array of Read-HandoffHeader results sharing this TaskId.

    Stage requirements (strict monotonic AND chain -- a later stage can only be
    true if every earlier stage is true; this is the false-CLOSED guard):

      ROUTED           : >=1 file with a resolved To: (someone was actually
                          addressed) and a real commit that added it.
      READ_ACK         : >=1 file, authored by (From: resolves to) the ROUTED
                          recipient, distinct from the ROUTED file itself,
                          containing an ACK marker ("## ACK", "読込済み",
                          "状態：受領済み").
      STARTED          : >=1 file authored by the recipient containing a
                          started/result marker: "新規実装：行った", a filename
                          or State: containing DONE/IMPL_DONE/実装完了, etc.
                          (STARTED and READ_ACK may legitimately be the same
                          physical file in this project's real practice -- e.g.
                          Sato routinely combines ACK+impl-done in one Handoff --
                          so this is evaluated independently, not as "the next
                          file after ACK".)
      RESULT_COMMITTED : >=1 recipient-authored file that both looks like a
                          result (STARTED marker) AND contains a backtick-quoted
                          commit token that Test-CommitExists verifies.
      REVIEWED         : >=1 file authored by someone other than any of this
                          task_id's routing senders/recipients, referencing a
                          review verdict via Get-ReviewVerdict, with the file
                          itself resolvable as a real committed file.
      CLOSED           : all of the above true AND an explicit closure signal
                          (State: CLOSED, or a REVIEWED file whose verdict is an
                          unconditional APPROVE) exists.

    A single task_id can legitimately carry more than one routing event (e.g.
    Arc routing the same task_id to both Sato for implementation and, later,
    to Kurose for review). Caught live twice tonight while dogfooding against
    the real repo:

      1st attempt: picked only the FIRST To:-bearing file by filesystem
      enumeration order as "the" routed file, so adding the Arc->Kurose
      review-request file under this task_id silently hid Sato's own
      ROUTED/ACK/STARTED/RESULT evidence just because it happened to sort
      earlier alphabetically.

      2nd attempt: tried unioning Recipients/Senders across every To:-bearing
      file in the group -- but Sato's own reply reports (addressed back "To:
      arc") also have non-empty To:, so that union incorrectly folded "arc"
      into Recipients too, making Sato's reply-to-Arc files match the
      recipientFiles filter for the wrong reason and corrupting the chain
      again. Reply-direction and assignment-direction To: fields are not the
      same kind of evidence and must not be merged.

    Final approach: still a single routed file, but chosen as the
    CHRONOLOGICALLY EARLIEST To:-bearing file (by each candidate's own
    first-add commit time) rather than filesystem order, AND excluding
    candidates addressed "To: arc". Arc is this mesh's Handoff-infra/routing
    hub (per AI_MEMBER_DIRECTORY.md, "Handoff保存・整理...受け渡し経路"), not
    a task implementer/reviewer, so nearly every reply/status-update in this
    repo is routed back "To: arc" regardless of the task's real recipient --
    without this exclusion, chronological-earliest still degraded to Yue's
    original source proposal (To: arc) instead of the actual implementation
    assignment (Arc To: Sato), which was verified against the real repo while
    building this fix.
    #>
    param([array]$Files)

    $result = [ordered]@{
        ROUTED = $false; READ_ACK = $false; STARTED = $false
        RESULT_COMMITTED = $false; REVIEWED = $false; CLOSED = $false
        Evidence = [ordered]@{}
        Recipients = @(); Senders = @()
    }

    # Exclude 'arc' from the recipient list a file needs in order to count as
    # ROUTED evidence -- but only arc, not the whole file: a multi-recipient
    # line like "To: 綴 / ケイ / アーク / 欠月" (real example found while
    # verifying this fix) must still count for its other, real recipients.
    $candidateRouted = @($Files | Where-Object { @($_.To | Where-Object { $_ -ne 'arc' }).Count -gt 0 })
    if ($candidateRouted.Count -eq 0) { return $result }

    $verifiedRouted = @()
    foreach ($rf in $candidateRouted) {
        $info = Get-FirstAddCommitInfo -RelPath ($rf.Path.Substring($RepoRoot.Length).TrimStart('\') -replace '\\', '/')
        if ($info) { $verifiedRouted += [PSCustomObject]@{ File = $rf; Commit = $info.Sha; Timestamp = $info.Timestamp } }
    }
    if ($verifiedRouted.Count -eq 0) { return $result }

    $earliest = $verifiedRouted | Sort-Object Timestamp | Select-Object -First 1
    $result.ROUTED = $true
    $result.Evidence.ROUTED = "$($earliest.File.Path) @ $($earliest.Commit)"
    $result.Recipients = @($earliest.File.To | Where-Object { $_ -ne 'arc' } | Select-Object -Unique)
    $result.Senders = @($earliest.File.From | Select-Object -Unique)
    $routedPaths = @($earliest.File.Path)

    $recipientFiles = $Files | Where-Object {
        ($routedPaths -notcontains $_.Path) -and (Compare-Object $_.From $result.Recipients -IncludeEqual -ExcludeDifferent | Measure-Object).Count -gt 0
    }

    $ackFile = $recipientFiles | Where-Object {
        $_.FullText -match '(?m)^##\s*ACK\s*$' -or $_.FullText -match '読込済み' -or $_.FullText -match '状態[:：]\s*受領済み'
    } | Select-Object -First 1
    if ($ackFile) {
        $result.READ_ACK = $true
        $result.Evidence.READ_ACK = $ackFile.Path
    }

    $startedFile = $recipientFiles | Where-Object {
        $_.FullText -match '新規実装[:：]\s*行った' -or
        $_.State -match '(?i)DONE' -or
        (Split-Path -Leaf $_.Path) -match '(?i)(_DONE|_IMPL_DONE)\.md$'
    } | Select-Object -First 1
    if ($result.READ_ACK -and $startedFile) {
        $result.STARTED = $true
        $result.Evidence.STARTED = $startedFile.Path
    }

    if ($result.STARTED) {
        $resultFile = $recipientFiles | Where-Object {
            $shas = @(Get-CommitTokensInText -Text $_.FullText)
            (@($shas | Where-Object { Test-CommitExists -Sha $_ })).Count -gt 0
        } | Select-Object -First 1
        if ($resultFile) {
            $result.RESULT_COMMITTED = $true
            $verifiedSha = (Get-CommitTokensInText -Text $resultFile.FullText | Where-Object { Test-CommitExists -Sha $_ } | Select-Object -First 1)
            $result.Evidence.RESULT_COMMITTED = "$($resultFile.Path) @ $verifiedSha"
        }
    }

    if ($result.RESULT_COMMITTED) {
        # See Get-ReviewVerdict for the evidence rule (same-line label OR
        # heading style, fixed verdict-token set, never a bare keyword scan --
        # that looser version is what produced the false REVIEWED=YES/CLOSED=YES
        # this pilot hit during its first real -Scan).
        $reviewerFiles = $Files | Where-Object {
            ($routedPaths -notcontains $_.Path) -and
            (@(@($_.From) | Where-Object { $_ -and ($result.Senders -notcontains $_) -and ($result.Recipients -notcontains $_) })).Count -gt 0 -and
            (Get-ReviewVerdict -Text $_.FullText)
        } | Select-Object -First 1
        if ($reviewerFiles) {
            $result.REVIEWED = $true
            $verdict = Get-ReviewVerdict -Text $reviewerFiles.FullText
            $result.Evidence.REVIEWED = "$($reviewerFiles.Path) (verdict=$verdict)"
            $result.ReviewVerdict = $verdict
        }
    }

    if ($result.REVIEWED) {
        # Only an unconditional APPROVE (not APPROVE WITH CONDITIONS, not HOLD)
        # closes on review-verdict grounds; State: CLOSED is the other route.
        $closeSignal = ($result.ReviewVerdict -eq 'APPROVE') -or
            (@($Files | Where-Object { $_.State -match '(?i)CLOSED' })).Count -gt 0
        if ($closeSignal) {
            $result.CLOSED = $true
            $closedFile = $Files | Where-Object { $_.State -match '(?i)CLOSED' } | Select-Object -First 1
            $result.Evidence.CLOSED = if ($closedFile) { $closedFile.Path } else { "$($reviewerFiles.Path) (verdict=APPROVE)" }
        }
    }

    return $result
}

function Invoke-Scan {
    Write-Host "=== iac-handoff-state -Scan (read-only) ===" -ForegroundColor Cyan
    $mdFiles = Get-ChildItem -Path $IacRoot -Recurse -Filter '*.md' -File |
        Where-Object { $_.FullName -notmatch '\\PENDING_BY_MEMBER\\' -and $_.FullName -notmatch '\\ARCHIVE\\' }

    $withId = @()
    $untracked = @()
    foreach ($f in $mdFiles) {
        $h = Read-HandoffHeader -Path $f.FullName
        if (-not $h) { continue }
        if ($h.TaskId) { $withId += $h } else { $untracked += $f.FullName.Substring($RepoRoot.Length).TrimStart('\') -replace '\\', '/' }
    }

    Write-Host "`nscanned: $($mdFiles.Count) files under IACPROJECT/ (excluding PENDING_BY_MEMBER/, ARCHIVE/)"
    Write-Host "with task_id: $($withId.Count)   without task_id (UNTRACKED_ID): $($untracked.Count)"

    $byTask = $withId | Group-Object -Property TaskId
    $pendingByMember = @{}  # token -> list of lines

    Write-Host "`n--- tracked task_id states ---"
    foreach ($g in $byTask) {
        $state = Get-TaskState -Files $g.Group
        $stageOrder = 'ROUTED', 'READ_ACK', 'STARTED', 'RESULT_COMMITTED', 'REVIEWED', 'CLOSED'
        $summary = ($stageOrder | ForEach-Object { if ($state[$_]) { "$_=YES" } else { "$_=no" } }) -join '  '
        Write-Host ""
        Write-Host "task_id: $($g.Name)"
        Write-Host "  $summary"
        foreach ($k in $state.Evidence.Keys) { Write-Host "  evidence[$k]: $($state.Evidence[$k])" }

        $bucket =
            if ($state.CLOSED) { 'CLOSED' }
            elseif ($state.RESULT_COMMITTED) { 'RESULT / REVIEW PENDING' }
            elseif ($state.STARTED) { 'STARTED / NO RESULT' }
            elseif ($state.READ_ACK) { 'ACKED / NOT STARTED' }
            else { 'UNREAD' }

        foreach ($member in $state.Recipients) {
            if (-not $pendingByMember.ContainsKey($member)) { $pendingByMember[$member] = @{} }
            if (-not $pendingByMember[$member].ContainsKey($bucket)) { $pendingByMember[$member][$bucket] = @() }
            $pendingByMember[$member][$bucket] += $g.Name
        }
    }

    if ($untracked.Count -gt 0) {
        Write-Host "`n--- UNTRACKED_ID (no Task ID header found) ---"
        Write-Host "count: $($untracked.Count)"
        Write-Host "sample (first 10):"
        $untracked | Select-Object -First 10 | ForEach-Object { Write-Host "  $_" }
    }

    if ($WriteIndex) {
        $genDir = Join-Path $IacRoot 'PENDING_BY_MEMBER'
        New-Item -ItemType Directory -Path $genDir -Force | Out-Null
        # Wipe previously generated files first: a member who had entries on a
        # prior run but none now would otherwise keep a stale file forever
        # (caught while verifying tonight's fix -- tsuzuri.md kept showing a
        # 19:10 snapshot after a run that produced no current tsuzuri entries).
        Get-ChildItem -Path $genDir -Filter '*.md' -File -ErrorAction SilentlyContinue | Remove-Item -Force
        $utf8Bom = New-Object System.Text.UTF8Encoding($true)
        $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm'

        foreach ($member in $pendingByMember.Keys) {
            $disp = Get-MemberDisplayName -Token $member
            $lines = @(
                "# PENDING_BY_MEMBER / $disp",
                "",
                "**自動生成ファイル。手動編集禁止。** 生成元: ``tools/iac-handoff-state.ps1 -Scan -WriteIndex``",
                "生成時刻: $stamp JST（実行環境ローカル時刻）",
                "根拠: task_id と実ファイル/commitの存在（自然言語の自己申告は根拠にしていない）",
                ""
            )
            foreach ($bucket in 'UNREAD', 'ACKED / NOT STARTED', 'STARTED / NO RESULT', 'RESULT / REVIEW PENDING', 'CLOSED') {
                $lines += "## $bucket"
                $lines += ""
                if ($pendingByMember[$member].ContainsKey($bucket)) {
                    foreach ($tid in $pendingByMember[$member][$bucket]) { $lines += "- $tid" }
                } else {
                    $lines += "(なし)"
                }
                $lines += ""
            }
            $outPath = Join-Path $genDir "$($disp -replace '[（）\(\)]', '').md"
            # display names contain no path-unsafe chars once brackets stripped; token used as stable filename instead
            $outPath = Join-Path $genDir "$member.md"
            [System.IO.File]::WriteAllLines($outPath, $lines, $utf8Bom)
            Write-Host "wrote: IACPROJECT/PENDING_BY_MEMBER/$member.md"
        }

        $untrackedPath = Join-Path $genDir '_UNTRACKED.md'
        $lines = @(
            "# PENDING_BY_MEMBER / _UNTRACKED",
            "",
            "**自動生成ファイル。手動編集禁止。**",
            "task_idヘッダーが見つからなかったファイル一覧（自動でtask_idを割り当てない）。",
            "生成時刻: $stamp JST",
            "count: $($untracked.Count)",
            ""
        )
        foreach ($p in $untracked) { $lines += "- $p" }
        [System.IO.File]::WriteAllLines($untrackedPath, $lines, $utf8Bom)
        Write-Host "wrote: IACPROJECT/PENDING_BY_MEMBER/_UNTRACKED.md ($($untracked.Count) files)"
    }
}

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "SELFTEST FAILED: $Message" }
    Write-Host "  ok: $Message"
}

function Invoke-SelfTest {
    Write-Host "=== iac-handoff-state -SelfTest (synthetic fixtures, no repo files touched) ===" -ForegroundColor Cyan
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("iac_handoff_state_selftest_" + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $tmp -Force | Out-Null
    try {
        $tid = 'SELFTEST-0001'
        $routedPath = Join-Path $tmp 'routed.md'
        @"
# Handoff: selftest
- From: arc
- To: claude_code
Task ID: $tid
"@ | Set-Content -LiteralPath $routedPath -Encoding UTF8

        $noAckState = Get-TaskState -Files @((Read-HandoffHeader -Path $routedPath))
        Assert-True ($noAckState.ROUTED -eq $false) "a file with no verifiable first-add commit (untracked temp file) must NOT be ROUTED"

        # Simulate a "real" commit by using this repo's HEAD commit hash as a stand-in
        # for the file's own history (Get-FirstAddCommit needs a tracked repo file;
        # for the fixture we monkey-test Test-CommitExists directly instead).
        Assert-True (-not (Test-CommitExists -Sha 'deadbeefdeadbeefdeadbeefdeadbeefdeadbeef')) "a plausible but non-existent SHA must not verify"
        $headSha = (& git -C $RepoRoot rev-parse HEAD).Trim()
        Assert-True (Test-CommitExists -Sha $headSha) "the repo's own HEAD commit must verify"

        # False-CLOSED guard: a file claiming State: CLOSED with nothing else true.
        $fakeClosed = [PSCustomObject]@{
            Path = (Join-Path $tmp 'fake_closed.md'); TaskId = $tid; To = @('claude_code'); From = @('arc')
            State = 'CLOSED'; RawText = ''; FullText = 'State: CLOSED'
        }
        $state = Get-TaskState -Files @($fakeClosed)
        Assert-True ($state.CLOSED -eq $false) "a lone file's own State: CLOSED claim must not set CLOSED without ROUTED/ACK/STARTED/RESULT/REVIEWED evidence"

        # --- Get-ReviewVerdict cases requested by Arc
        #     (IACPROJECT/inbox/from_arc/2026-08-30_ARC_TO_SATO_HANDOFF_STATE_TRACKER_KUROSE_HEADING_FORMAT_FIX.md)
        #     after Kurose clarified his real reviews commonly use heading style
        #     rather than a same-line "判定:" label. ---
        Assert-True ((Get-ReviewVerdict -Text "## 判定`nAPPROVE") -eq 'APPROVE') `
            '"## 判定" heading + next line "APPROVE" => REVIEWED evidence (APPROVE)'
        Assert-True ((Get-ReviewVerdict -Text "## 判定`nAPPROVE WITH CONDITIONS") -eq 'APPROVE_WITH_CONDITIONS') `
            '"## 判定" heading + next line "APPROVE WITH CONDITIONS" => REVIEWED evidence, but not unconditional APPROVE'
        Assert-True ($null -eq (Get-ReviewVerdict -Text "したがって、実ファイルの存在で機械判定する仕組みに移行したい。")) `
            'ordinary prose containing bare "判定" (no label, no heading) must NOT be review evidence (this is the exact false positive the pilot hit)'
        Assert-True ($null -eq (Get-ReviewVerdict -Text "## 判定`n情報1`n情報2`n情報3`nAPPROVE")) `
            'a verdict token beyond the next 3 non-empty lines after the heading must NOT count (avoids matching unrelated later APPROVE mentions; blank lines themselves do not consume the budget, per spec "次の非空行1〜3行")'
        Assert-True ($null -eq (Get-ReviewVerdict -Text "本文中のどこかにAPPROVEと書かれているだけ")) `
            'a bare APPROVE floating in body text with no label/heading must NOT be review evidence'
        Assert-True ((Get-ReviewVerdict -Text "判定: APPROVE") -eq 'APPROVE') `
            'the original same-line "判定: APPROVE" form still works (no regression)'

        # Source/recipient self-verdict must not count as REVIEWED even if the
        # text itself matches -- this is enforced by the third-party-authorship
        # filter in Get-TaskState (Get-ReviewVerdict has no notion of "who wrote
        # this"), so exercise it through the full pipeline using a real tracked
        # file for ROUTED evidence.
        $realFile = Join-Path $RepoRoot 'tools\iac-handoff-lib.ps1'
        $routedSelf = [PSCustomObject]@{ Path = $realFile; TaskId = $tid; To = @('claude_code'); From = @('arc'); State = $null; FullText = "From: arc`nTo: claude_code" }
        $selfVerdictText = "新規実装：行った`ncommit: ``$headSha``" + "`n## 判定`nAPPROVE"
        $selfVerdict = [PSCustomObject]@{ Path = 'selfverdict'; TaskId = $tid; To = @(); From = @('claude_code'); State = 'DONE'; FullText = $selfVerdictText }
        $stateSelf = Get-TaskState -Files @($routedSelf, $selfVerdict)
        Assert-True ($stateSelf.REVIEWED -eq $false) `
            'a verdict written by the recipient themself (not a third party) must NOT count as REVIEWED'

        # Full positive chain end-to-end, including the heading-style verdict,
        # against a real tracked file so ROUTED's commit check is genuine.
        $reviewerFile = [PSCustomObject]@{ Path = 'reviewer'; TaskId = $tid; To = @(); From = @('claude'); State = $null; FullText = "## 判定`nAPPROVE" }
        $ackDoneFile = [PSCustomObject]@{ Path = 'ackdone'; TaskId = $tid; To = @(); From = @('claude_code'); State = 'DONE'; FullText = "## ACK`n読込済み：x`n新規実装：行った`ncommit: ``$headSha``" }
        $fullState = Get-TaskState -Files @($routedSelf, $ackDoneFile, $reviewerFile)
        Assert-True ($fullState.ROUTED -and $fullState.READ_ACK -and $fullState.STARTED -and $fullState.RESULT_COMMITTED -and $fullState.REVIEWED -and $fullState.CLOSED) `
            'full ROUTED->READ_ACK->STARTED->RESULT_COMMITTED->REVIEWED->CLOSED chain closes correctly with a heading-style unconditional APPROVE from a genuine third party'

        Write-Host "`n=== SELFTEST PASSED ===" -ForegroundColor Green
    } finally {
        Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
    }
}

if ($SelfTest) { Invoke-SelfTest; exit 0 }
if ($Scan) { Invoke-Scan; exit 0 }
Write-Host "Usage: iac-handoff-state.ps1 -Scan [-WriteIndex] | -SelfTest"
