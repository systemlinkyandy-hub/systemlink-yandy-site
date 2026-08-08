#Requires -Version 5.1
<#
Task ID: IAC-FABLE-AUTONOMOUS-HANDOFF-001
Handoff接続ログのCLI。

使い方:
  iac-handoff-log tally               接続回数の集計を表示（from→to 降順）
  iac-handoff-log backfill            IACPROJECT配下の既存Handoffファイル名からログを補完
  iac-handoff-log add -From claude_code -To arc -Task xxx -HandoffPath IACPROJECT/... [-Commit hash] [-Date YYYY-MM-DD]
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('tally', 'backfill', 'add')]
    [string]$Command = 'tally',
    [string]$From,
    [string]$To,
    [string]$Task,
    [string]$HandoffPath,
    [string]$Commit = '-',
    [string]$Date
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'iac-handoff-lib.ps1')

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$LogPath  = Get-HandoffLogPath -RepoRoot $RepoRoot

function Invoke-GitQuiet {
    param([string[]]$GitArgs)
    Push-Location $RepoRoot
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

switch ($Command) {

    'add' {
        if (-not $From -or -not $To -or -not $HandoffPath) {
            Write-Host "add には -From / -To / -HandoffPath が必要です。"
            exit 1
        }
        if (-not $Date) { $Date = Get-Date -Format 'yyyy-MM-dd' }
        $added = Add-HandoffLogEntry -LogPath $LogPath -Date $Date -From $From -To $To `
            -Task $Task -HandoffPath $HandoffPath -Commit $Commit
        if ($added) { Write-Host "追記しました: $From -> $To ($HandoffPath)" }
        else        { Write-Host "既に記録済みのためスキップ: $HandoffPath" }
        exit 0
    }

    'backfill' {
        $iacRoot = Join-Path $RepoRoot 'IACPROJECT'
        $candidates = Get-ChildItem -Path $iacRoot -Recurse -Filter '*.md' -File |
            Where-Object { $_.Name -imatch '_TO_' }

        $added = 0; $skipped = 0; $unparsed = 0
        foreach ($file in $candidates) {
            $base   = [IO.Path]::GetFileNameWithoutExtension($file.Name)
            $parsed = Get-HandoffFromTo -FileBaseName $base
            if (-not $parsed.From -and $file.DirectoryName -match 'from_([a-z_]+)$') {
                # inbox\from_<X>\ 配下ならフォルダ名からFROMを補完する
                $folderResult = Resolve-MemberToken -Tokens @($Matches[1])
                if ($folderResult.Token) { $parsed.From = $folderResult.Token }
            }
            if (-not $parsed.From -or -not $parsed.To) {
                $unparsed++
                Write-Host "  解析不能（記録せず）: $($file.Name)"
                continue
            }
            $relPath = $file.FullName.Substring($RepoRoot.Length).TrimStart('\') -replace '\\', '/'

            # そのファイルを最初に追加したcommitを取得（取れなければ '-'）
            $hashResult = Invoke-GitQuiet @('log', '--diff-filter=A', '--format=%h', '-n', '1', '--', $relPath)
            $hash = if ($hashResult.ExitCode -eq 0 -and $hashResult.Output.Trim()) { $hashResult.Output.Trim() } else { '-' }

            $date = if ($parsed.Date) { $parsed.Date } else { '-' }
            $ok = Add-HandoffLogEntry -LogPath $LogPath -Date $date -From $parsed.From -To $parsed.To `
                -Task $parsed.Task -HandoffPath $relPath -Commit $hash
            if ($ok) { $added++ } else { $skipped++ }
        }
        Write-Host ""
        Write-Host "バックフィル完了: 追記 $added 件 / 記録済みスキップ $skipped 件 / 解析不能 $unparsed 件"
        Write-Host "ログ: $LogPath"
        exit 0
    }

    'tally' {
        $entries = Get-HandoffLogEntries -LogPath $LogPath
        if (-not $entries -or $entries.Count -eq 0) {
            Write-Host "接続ログが空です。まず iac-handoff-log backfill を実行してください。"
            exit 0
        }
        Write-Host ""
        Write-Host "AI間Handoff接続回数（from → to、降順）"
        Write-Host "※接続回数は補助指標。Handoff先の選択は担当適合性（AI_MEMBER_DIRECTORY.md）を優先する。"
        Write-Host ""
        $groups = $entries | Group-Object -Property { "$($_.From)`t$($_.To)" } | Sort-Object Count -Descending
        foreach ($g in $groups) {
            $pair = $g.Name -split "`t"
            $fromDisp = Get-MemberDisplayName -Token $pair[0]
            $toDisp   = Get-MemberDisplayName -Token $pair[1]
            Write-Host ("  {0,-22} → {1,-22} : {2}回" -f $fromDisp, $toDisp, $g.Count)
        }
        Write-Host ""
        Write-Host "総Handoff数: $($entries.Count)件（ログ: IACPROJECT/ROUTER/HANDOFF_CONNECTION_LOG.md）"
        exit 0
    }
}
