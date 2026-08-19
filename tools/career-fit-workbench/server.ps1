#Requires -Version 5.1
<#
Task ID: IAC-CAREER-FIT-001
Career Fit Workbench v0.1 — ローカルHTTPサーバ（HttpListener）。
起動: tools\career-fit-workbench\launch.cmd （または `powershell -File server.ps1 -Port 8799`）
ブラウザで http://localhost:<Port>/ を開いて操作する。外部公開はv0.1では行わない
（HttpListenerは既定で http://localhost:<Port>/ のみに束縛し、LAN/外部からは到達しない）。

前提: 環境変数 GEMINI_API_KEY にAPIキーを設定しておくこと（リポジトリ・ログへの直書き禁止。
既存のGemini Bridgeと同じ変数を共有する）。未設定でもサーバ自体は起動し、/api/analyze 呼び出し時に
エラーメッセージを返す。
#>
param(
    [int]$Port = 8799
)

$Root = $PSScriptRoot
. (Join-Path $Root 'lib\career-fit-gemini.ps1')
. (Join-Path $Root 'lib\career-fit-store.ps1')

$WwwRoot = Join-Path $Root 'www'

$MimeTypes = @{
    '.html' = 'text/html; charset=utf-8'
    '.css'  = 'text/css; charset=utf-8'
    '.js'   = 'application/javascript; charset=utf-8'
    '.json' = 'application/json; charset=utf-8'
}

function Write-CareerFitJsonResponse {
    param($Context, [int]$StatusCode, $Body)
    $json = $Body | ConvertTo-Json -Depth 20
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    $Context.Response.StatusCode = $StatusCode
    $Context.Response.ContentType = 'application/json; charset=utf-8'
    $Context.Response.ContentLength64 = $bytes.Length
    $Context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $Context.Response.OutputStream.Close()
}

function Write-CareerFitStaticFile {
    param($Context, [string]$RelPath)
    $full = Join-Path $WwwRoot $RelPath
    $full = [System.IO.Path]::GetFullPath($full)
    if (-not $full.StartsWith([System.IO.Path]::GetFullPath($WwwRoot))) {
        Write-CareerFitJsonResponse -Context $Context -StatusCode 403 -Body @{ error = 'forbidden' }
        return
    }
    if (-not (Test-Path $full -PathType Leaf)) {
        Write-CareerFitJsonResponse -Context $Context -StatusCode 404 -Body @{ error = 'not found' }
        return
    }
    $ext = [System.IO.Path]::GetExtension($full)
    $contentType = if ($MimeTypes.ContainsKey($ext)) { $MimeTypes[$ext] } else { 'application/octet-stream' }
    $bytes = [System.IO.File]::ReadAllBytes($full)
    $Context.Response.StatusCode = 200
    $Context.Response.ContentType = $contentType
    $Context.Response.ContentLength64 = $bytes.Length
    $Context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $Context.Response.OutputStream.Close()
}

function Read-CareerFitRequestBody {
    param($Context)
    $reader = New-Object System.IO.StreamReader($Context.Request.InputStream, [System.Text.Encoding]::UTF8)
    $text = $reader.ReadToEnd()
    $reader.Close()
    if (-not $text -or $text.Trim() -eq '') { return $null }
    return $text | ConvertFrom-Json
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
try {
    $listener.Start()
} catch {
    Write-Host "サーバを起動できませんでした（ポート $Port が使用中の可能性があります）: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "Career Fit Workbench: http://localhost:$Port/ を開いてください（Ctrl+Cで終了）" -ForegroundColor Green
if (-not $env:GEMINI_API_KEY) {
    Write-Host "警告: GEMINI_API_KEY が未設定です。求人解析（画像投入）はエラーになります。" -ForegroundColor Yellow
}

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $req = $context.Request
        $path = $req.Url.AbsolutePath
        $method = $req.HttpMethod

        try {
            if ($method -eq 'GET' -and $path -eq '/') {
                Write-CareerFitStaticFile -Context $context -RelPath 'index.html'
            }
            elseif ($method -eq 'GET' -and $path -eq '/app.js') {
                Write-CareerFitStaticFile -Context $context -RelPath 'app.js'
            }
            elseif ($method -eq 'GET' -and $path -eq '/style.css') {
                Write-CareerFitStaticFile -Context $context -RelPath 'style.css'
            }
            elseif ($method -eq 'POST' -and $path -eq '/api/analyze') {
                $body = Read-CareerFitRequestBody -Context $context
                $images = @($body.images)
                $result = Invoke-CareerFitAnalyze -ImageDataUrls $images
                if ($result.Success) {
                    Write-CareerFitJsonResponse -Context $context -StatusCode 200 -Body @{ success = $true; data = $result.Data }
                } else {
                    Write-CareerFitJsonResponse -Context $context -StatusCode 502 -Body @{ success = $false; error = $result.Error }
                }
            }
            elseif ($method -eq 'POST' -and $path -eq '/api/jobs') {
                $body = Read-CareerFitRequestBody -Context $context
                $record = Add-CareerFitJob -Root $Root -AnalyzedData $body
                Write-CareerFitJsonResponse -Context $context -StatusCode 201 -Body @{ success = $true; data = $record }
            }
            elseif ($method -eq 'GET' -and $path -eq '/api/jobs') {
                $jobs = Read-CareerFitJobs -Root $Root
                Write-CareerFitJsonResponse -Context $context -StatusCode 200 -Body @{ success = $true; data = @($jobs) }
            }
            elseif ($method -eq 'PATCH' -and $path -match '^/api/jobs/([^/]+)$') {
                $id = $Matches[1]
                $body = Read-CareerFitRequestBody -Context $context
                $updated = Update-CareerFitJobStatus -Root $Root -Id $id -Status $body.status
                Write-CareerFitJsonResponse -Context $context -StatusCode 200 -Body @{ success = $true; data = $updated }
            }
            else {
                Write-CareerFitJsonResponse -Context $context -StatusCode 404 -Body @{ success = $false; error = 'not found' }
            }
        } catch {
            try {
                Write-CareerFitJsonResponse -Context $context -StatusCode 500 -Body @{ success = $false; error = $_.Exception.Message }
            } catch {
                # レスポンスが既に閉じている場合は無視
            }
        }
    }
} finally {
    $listener.Stop()
    $listener.Close()
}
