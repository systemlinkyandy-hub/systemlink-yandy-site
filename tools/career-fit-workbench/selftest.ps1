#Requires -Version 5.1
<#
Task ID: IAC-CAREER-FIT-001
Career Fit Workbench のロジック自己テスト。人工fixture・一時ディレクトリのみを使用し、
実データ（data/jobs.json）やGemini APIへの実通信には一切触れない（-ApiCallOverride でスタブ化）。
実行: powershell -NoProfile -ExecutionPolicy Bypass -File tools\career-fit-workbench\selftest.ps1
#>
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib\career-fit-gemini.ps1')
. (Join-Path $PSScriptRoot 'lib\career-fit-store.ps1')

$pass = 0; $fail = 0
function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) { $Script:pass++; Write-Host "  OK  $Name" }
    else { $Script:fail++; Write-Host "  NG  $Name" }
}

$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("career_fit_selftest_" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $TempRoot | Out-Null

try {
    # --- Read-CareerFitJobs: 空状態 ---
    $jobs = @(Read-CareerFitJobs -Root $TempRoot)
    Assert-True ($jobs.Count -eq 0) 'data/jobs.json 未作成時は空配列を返す'

    # --- Add-CareerFitJob: 新規保存 ---
    $sample1 = [PSCustomObject]@{
        company = 'サンプル株式会社'
        title   = '組込みエンジニア'
        location = '福岡'
        employmentType = '正社員'
        postedDate = '2026-08-01'
        url = ''
        workStyle = [PSCustomObject]@{ type = 'Fully Remote'; officeFrequency = '不明'; flex = 'あり'; hours = '不明' }
        compensation = [PSCustomObject]@{ minAnnual = '600'; maxAnnual = '800'; monthly = '不明'; bonus = '不明' }
        role = [PSCustomObject]@{
            mainDuties = 'BSP開発'; requiredSkills = 'C/C++, Linux'; preferredSkills = 'AI活用'
            techStack = 'SoC'; management = '不明'; design = 'あり'; implementation = 'あり'; clientFacing = '不明'
        }
        missingInfo = @('出社頻度')
        scoring = [PSCustomObject]@{
            classification = 'A'; remoteStars = 5; fitStars = 4; sustainabilityStars = 4
            applicationValue = '高'; goodPoints = @('BSP経験と一致'); riskPoints = @('報酬上限不明瞭')
            oneLiner = 'BSP/Linux経験との接続が強く、技術適合は高い。A判定。'
        }
    }
    $saved1 = Add-CareerFitJob -Root $TempRoot -AnalyzedData $sample1
    Assert-True ([bool]$saved1.id) '保存すると id が採番される'
    Assert-True ($saved1.status -eq '未判定') '新規保存時の status は未判定'
    Assert-True ($null -eq $saved1.duplicateOf) '1件目は duplicateOf が null'

    $jobsAfter1 = @(Read-CareerFitJobs -Root $TempRoot)
    Assert-True ($jobsAfter1.Count -eq 1) '保存後 jobs.json から1件読み込める'

    # --- 重複検出（同一会社名・同一タイトル） ---
    $sample2 = $sample1.PSObject.Copy()
    $saved2 = Add-CareerFitJob -Root $TempRoot -AnalyzedData $sample2
    Assert-True ($saved2.duplicateOf -eq $saved1.id) '同一会社名・タイトルは duplicateOf に元IDが入る'

    # --- 重複しないケース ---
    $sample3 = [PSCustomObject]@{ company = '別会社'; title = '別職種'; workStyle=[PSCustomObject]@{}; compensation=[PSCustomObject]@{}; role=[PSCustomObject]@{}; missingInfo=@(); scoring=[PSCustomObject]@{ classification='B' } }
    $saved3 = Add-CareerFitJob -Root $TempRoot -AnalyzedData $sample3
    Assert-True ($null -eq $saved3.duplicateOf) '会社名・タイトルが異なれば重複扱いしない'

    $jobsAfter3 = @(Read-CareerFitJobs -Root $TempRoot)
    Assert-True ($jobsAfter3.Count -eq 3) '3件とも保存される（重複も削除せず残す）'

    # --- Update-CareerFitJobStatus ---
    $updated = Update-CareerFitJobStatus -Root $TempRoot -Id $saved1.id -Status '応募候補'
    Assert-True ($updated.status -eq '応募候補') 'status を応募候補へ更新できる'
    $reread = @(Read-CareerFitJobs -Root $TempRoot | Where-Object { $_.id -eq $saved1.id })[0]
    Assert-True ($reread.status -eq '応募候補') '更新後、再読込しても status が保持される'

    try {
        Update-CareerFitJobStatus -Root $TempRoot -Id $saved1.id -Status '不正な値' | Out-Null
        Assert-True $false '不正なstatus値は例外を投げる（到達してはいけない）'
    } catch {
        Assert-True $true '不正なstatus値は例外を投げる'
    }

    try {
        Update-CareerFitJobStatus -Root $TempRoot -Id 'not-exist' -Status 'A' | Out-Null
        Assert-True $false '存在しないIDは例外を投げる（到達してはいけない）'
    } catch {
        Assert-True $true '存在しないIDは例外を投げる'
    }

    # --- Invoke-CareerFitAnalyze: 画像未指定 ---
    $noImages = Invoke-CareerFitAnalyze -ImageDataUrls @()
    Assert-True (-not $noImages.Success) '画像未指定はSuccess=false'

    # --- Invoke-CareerFitAnalyze: APIスタブでJSON解析成功パス ---
    $stubJson = '{"company":"スタブ会社","title":"スタブ職","scoring":{"classification":"B"}}'
    $override = { param($images, $attempt) return $Script:StubJson }
    $Script:StubJson = $stubJson
    $result = Invoke-CareerFitAnalyze -ImageDataUrls @('data:image/png;base64,AAAA') -ApiCallOverride $override
    Assert-True $result.Success 'スタブ応答でSuccess=trueになる'
    Assert-True ($result.Data.company -eq 'スタブ会社') 'スタブ応答のJSONが正しくパースされる'

    # --- Invoke-CareerFitAnalyze: APIスタブで不正JSON ---
    $badOverride = { param($images, $attempt) return 'これはJSONではない' }
    $badResult = Invoke-CareerFitAnalyze -ImageDataUrls @('data:image/png;base64,AAAA') -ApiCallOverride $badOverride
    Assert-True (-not $badResult.Success) '不正なJSON応答はSuccess=falseになる'

    # --- ConvertTo-CareerFitImagePart: 不正なdata URL ---
    try {
        ConvertTo-CareerFitImagePart -DataUrl 'not-a-data-url' | Out-Null
        Assert-True $false '不正なdata URLは例外を投げる（到達してはいけない）'
    } catch {
        Assert-True $true '不正なdata URLは例外を投げる'
    }

    # --- ConvertTo-CareerFitImagePart: 正常系 ---
    $part = ConvertTo-CareerFitImagePart -DataUrl 'data:image/png;base64,AAAA'
    Assert-True ($part.inline_data.mime_type -eq 'image/png') 'data URLからmime_typeを正しく抽出する'
    Assert-True ($part.inline_data.data -eq 'AAAA') 'data URLからbase64本体を正しく抽出する'

} finally {
    Remove-Item -Recurse -Force -Path $TempRoot -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "PASS: $pass  FAIL: $fail"
if ($fail -gt 0) { exit 1 }
