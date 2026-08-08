#Requires -Version 5.1
<#
Task ID: IAC-INFRA-BUS-001
staging\ の .md を inbox\from_<from>\ へ振り分け、commit/push まで自動化する。
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Files
)

$ErrorActionPreference = 'Stop'

# メンバー名の判定・接続ログ関数は共有ライブラリに集約（iac-handoff-log.ps1 と共通）
. (Join-Path $PSScriptRoot 'iac-handoff-lib.ps1')

$RepoRoot      = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$StagingRoot   = Join-Path $RepoRoot "staging"
$DeliveredRoot = Join-Path $StagingRoot "delivered"
$InboxRoot     = Join-Path $RepoRoot "IACPROJECT\inbox"
$UnsortedDir   = Join-Path $InboxRoot "unsorted"
$LogPath       = Get-HandoffLogPath -RepoRoot $RepoRoot

function Invoke-Git {
    param([string[]]$GitArgs)
    Push-Location $RepoRoot
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

New-Item -ItemType Directory -Force -Path $StagingRoot, $DeliveredRoot, $UnsortedDir | Out-Null

if ($Files -and $Files.Count -gt 0) {
    $targets = $Files | ForEach-Object { Get-Item -LiteralPath $_ -ErrorAction SilentlyContinue }
    if (-not $targets) {
        Write-Host "指定ファイルが見つかりません。"
        exit 1
    }
} else {
    $targets = @(Get-ChildItem -LiteralPath $StagingRoot -Filter '*.md' -File -ErrorAction SilentlyContinue)
}

if (-not $targets -or $targets.Count -eq 0) {
    Write-Host "配送対象なし"
    exit 0
}

$results = @()

foreach ($file in $targets) {
    $base   = [IO.Path]::GetFileNameWithoutExtension($file.Name)
    $parsed = Get-HandoffFromTo -FileBaseName $base
    $alias  = $parsed.From

    if ($alias) {
        $destDir = Join-Path $InboxRoot "from_$alias"
    } else {
        $destDir = $UnsortedDir
        $alias   = 'unsorted'
    }
    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    $destPath = Join-Path $destDir $file.Name
    $relPath  = $destPath.Substring($RepoRoot.Length).TrimStart('\')

    try {
        Copy-Item -LiteralPath $file.FullName -Destination $destPath -Force

        $addResult = Invoke-Git @('add', $relPath)
        if ($addResult.ExitCode -ne 0) { throw "git add failed: $($addResult.Output)" }

        $commitResult = Invoke-Git @('commit', '-m', "deliver: $($file.Name)", '--', $relPath)
        if ($commitResult.ExitCode -ne 0 -and $commitResult.Output -notmatch 'nothing to commit|nothing added to commit') {
            throw "git commit failed: $($commitResult.Output)"
        }

        $hashResult = Invoke-Git @('rev-parse', '--short', 'HEAD')
        $fileCommit = if ($hashResult.ExitCode -eq 0) { $hashResult.Output.Trim() } else { '-' }

        $results += [PSCustomObject]@{
            File = $file.Name; Original = $file.FullName; Dest = $relPath
            Alias = $alias; Success = $true; Error = $null
            Commit = $fileCommit; ToMember = $parsed.To; Task = $parsed.Task; FileDate = $parsed.Date
        }
    } catch {
        $results += [PSCustomObject]@{
            File = $file.Name; Original = $file.FullName; Dest = $null
            Alias = $alias; Success = $false; Error = $_.Exception.Message
        }
    }
}

$succeeded = @($results | Where-Object { $_.Success })
$failed    = @($results | Where-Object { -not $_.Success })

$pushOk = $false
$commitHash = $null

# 接続ログ（HANDOFF_CONNECTION_LOG.md）へ自動追記する。
# FROMが判定できた配送のみ記録する（unsorted行きは接続として数えない）。
# 同じhandoff_pathは追記されないため、push失敗→再実行でも重複しない。
if ($succeeded.Count -gt 0) {
    $logChanged = $false
    foreach ($r in ($succeeded | Where-Object { $_.Alias -ne 'unsorted' })) {
        $toValue   = if ($r.ToMember) { $r.ToMember } else { '-' }
        $dateValue = if ($r.FileDate) { $r.FileDate } else { Get-Date -Format 'yyyy-MM-dd' }
        $added = Add-HandoffLogEntry -LogPath $LogPath -Date $dateValue -From $r.Alias -To $toValue `
            -Task $r.Task -HandoffPath $r.Dest -Commit $r.Commit
        if ($added) { $logChanged = $true }
    }
    if ($logChanged) {
        $logRel = $LogPath.Substring($RepoRoot.Length).TrimStart('\')
        $addLog = Invoke-Git @('add', $logRel)
        if ($addLog.ExitCode -eq 0) {
            $commitLog = Invoke-Git @('commit', '-m', 'log: record handoff connections', '--', $logRel)
            if ($commitLog.ExitCode -ne 0 -and $commitLog.Output -notmatch 'nothing to commit') {
                Write-Host "警告: 接続ログのcommitに失敗しました（配送自体は継続します）: $($commitLog.Output)"
            }
        }
    }
}

if ($succeeded.Count -gt 0) {
    $pushResult = Invoke-Git @('push')
    if ($pushResult.ExitCode -ne 0) {
        $rebaseResult = Invoke-Git @('pull', '--rebase')
        if ($rebaseResult.ExitCode -eq 0) {
            $pushResult = Invoke-Git @('push')
        }
    }

    if ($pushResult.ExitCode -eq 0) {
        $pushOk = $true
        $hashResult = Invoke-Git @('rev-parse', '--short', 'HEAD')
        $commitHash = $hashResult.Output.Trim()
    } else {
        Write-Host ""
        Write-Host "push に失敗しました。ローカルのcommitとstagingのファイルはそのまま残っています。"
        Write-Host $pushResult.Output
        Write-Host ""
        Write-Host "次に打つ1行： iac-deliver   （ネットワーク/認証を確認後にもう一度実行すれば再送されます）"
        exit 1
    }
}

if ($pushOk) {
    foreach ($r in $succeeded) {
        if ($r.Original.StartsWith($StagingRoot, [StringComparison]::OrdinalIgnoreCase)) {
            $deliveredPath = Join-Path $DeliveredRoot $r.File
            if (Test-Path $deliveredPath) {
                $deliveredPath = Join-Path $DeliveredRoot ("{0}_{1}" -f (Get-Date -Format 'yyyyMMddHHmmss'), $r.File)
            }
            Move-Item -LiteralPath $r.Original -Destination $deliveredPath -Force
        }
    }
}

Write-Host ""
Write-Host "配送 $($succeeded.Count)件 / 失敗 $($failed.Count)件"
foreach ($r in $succeeded) { Write-Host "  OK  $($r.File) -> $($r.Dest)" }
foreach ($r in $failed)    { Write-Host "  NG  $($r.File) : $($r.Error)" }
if ($commitHash) { Write-Host "commit: $commitHash" }

if ($failed.Count -gt 0) { exit 1 } else { exit 0 }
