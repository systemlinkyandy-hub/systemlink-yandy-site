#Requires -Version 5.1
<#
Task ID: IAC-CAREER-FIT-001
求人レコードの永続化。1ファイルJSON配列（career-fit-workbench/data/jobs.json）。
実データ（求人内容・画像）はGitHubへコミットしない（data/ は .gitignore 対象）。
#>

function Get-CareerFitDataPath {
    param([string]$Root)
    $dataDir = Join-Path $Root 'data'
    New-Item -ItemType Directory -Force -Path $dataDir | Out-Null
    return Join-Path $dataDir 'jobs.json'
}

function Read-CareerFitJobs {
    param([string]$Root)
    $path = Get-CareerFitDataPath -Root $Root
    if (-not (Test-Path $path)) { return @() }
    $raw = Get-Content -Path $path -Raw -Encoding UTF8
    if (-not $raw -or $raw.Trim() -eq '') { return @() }
    $parsed = $raw | ConvertFrom-Json
    if ($null -eq $parsed) { return @() }
    if ($parsed -isnot [System.Array]) { return @($parsed) }
    return $parsed
}

function Save-CareerFitJobs {
    param([string]$Root, $Jobs)
    $path = Get-CareerFitDataPath -Root $Root
    $json = @($Jobs) | ConvertTo-Json -Depth 20
    [System.IO.File]::WriteAllText($path, $json, [System.Text.Encoding]::UTF8)
}

function Find-CareerFitDuplicate {
    <# 同一会社名・同一求人タイトル（前後空白を無視した完全一致）の既存レコードを1件返す #>
    param($Jobs, [string]$Company, [string]$Title)
    if (-not $Company -or -not $Title) { return $null }
    $c = $Company.Trim()
    $t = $Title.Trim()
    foreach ($job in @($Jobs)) {
        if ($job.company -and $job.title -and $job.company.Trim() -eq $c -and $job.title.Trim() -eq $t) {
            return $job
        }
    }
    return $null
}

function New-CareerFitJobId {
    return [Guid]::NewGuid().ToString('N').Substring(0, 12)
}

function Add-CareerFitJob {
    <# 解析結果(PSCustomObject)を保存レコードへ変換して追加する。戻り値: 保存済みレコード（duplicateOf含む） #>
    param([string]$Root, $AnalyzedData)

    $jobs = @(Read-CareerFitJobs -Root $Root)
    $dup = Find-CareerFitDuplicate -Jobs $jobs -Company $AnalyzedData.company -Title $AnalyzedData.title

    $now = (Get-Date).ToString('o')
    $record = [PSCustomObject]@{
        id            = New-CareerFitJobId
        createdAt     = $now
        updatedAt     = $now
        company       = $AnalyzedData.company
        title         = $AnalyzedData.title
        location      = $AnalyzedData.location
        employmentType = $AnalyzedData.employmentType
        postedDate    = $AnalyzedData.postedDate
        url           = $AnalyzedData.url
        workStyle     = $AnalyzedData.workStyle
        compensation  = $AnalyzedData.compensation
        role          = $AnalyzedData.role
        missingInfo   = @($AnalyzedData.missingInfo)
        scoring       = $AnalyzedData.scoring
        status        = '未判定'
        duplicateOf   = if ($dup) { $dup.id } else { $null }
    }

    $jobs = @($jobs) + $record
    Save-CareerFitJobs -Root $Root -Jobs $jobs
    return $record
}

function Update-CareerFitJobStatus {
    param([string]$Root, [string]$Id, [string]$Status)
    $validStatuses = @('未判定', 'A', 'B', 'C', '見送り', '応募候補', '応募済', '保留')
    if ($validStatuses -notcontains $Status) {
        throw "不正なstatus値です: $Status"
    }
    $jobs = @(Read-CareerFitJobs -Root $Root)
    $found = $null
    $updated = @()
    foreach ($job in $jobs) {
        if ($job.id -eq $Id) {
            $job.status = $Status
            $job.updatedAt = (Get-Date).ToString('o')
            $found = $job
        }
        $updated += $job
    }
    if (-not $found) { throw "指定されたIDの求人が見つかりません: $Id" }
    Save-CareerFitJobs -Root $Root -Jobs $updated
    return $found
}
