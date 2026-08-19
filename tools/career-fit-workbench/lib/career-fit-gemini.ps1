#Requires -Version 5.1
<#
Task ID: IAC-CAREER-FIT-001
Career Fit Workbench の求人スクリーンショット解析。Gemini Vision (multimodal generateContent) を
1回呼び出し、抽出と評価（田中形式）を同時に行いJSONで受け取る。

キーは既存のGemini Bridgeと同じ環境変数のみを見る（リポジトリ・ログへの直書き禁止）。
このツール専用のモデル上書きは GEMINI_CAREER_FIT_MODEL、既定は Gemini Bridge と同じ固定IDを使う。
#>

$Script:CareerFitDefaultModel = 'gemini-3.6-flash'
$Script:CareerFitMaxRetries = 2
$Script:CareerFitRetryBackoffSeconds = @(2, 5)

function Get-CareerFitSystemPrompt {
    <# 抽出項目・評価軸・出力スキーマを固定する。仕様: Handoffで受領したCareer Fit Workbench v0.1。 #>
    @'
あなたは求人票のスクリーンショット画像から情報を抽出し、あらかじめ決まった評価軸で判定するアシスタントです。
複数枚の画像は同一の1求人として扱ってください。

# 抽出ルール
- 求人票に明記されていない項目は絶対に推測で埋めない。値が読み取れない場合は文字列 "不明" を入れる。
- 「Remote」としか書かれておらず出社頻度の記載がない場合、officeFrequencyは "不明" とする。
- 「情報不足」と「条件不適合」は別物として扱う。読み取れないだけの項目をmissingInfoへ列挙する。

# 本人の固定条件（評価の前提。動かさない）
- 希望年収：600万円以上
- 技術背景：組込み / C / C++ / Linux / SoC / GUI / LVGL / OpenCV / 車載 / システム設計 / アーキテクチャ
  / AI活用 / AIオーケストレーション / 技術ディレクション / PM・PL経験。20年以上の技術経験。
- キャリア方向：AI Director / AI Orchestration方向への接続
- 活動余力（Activity Sustainability）＝ 現在の活動余力 − 通勤 − 常駐 − 対人調整 − 時間拘束 − 環境負荷
  + Remote + フレックス + 自律性。長期継続性の判定に反映する。数値的な医学指標とは結びつけない。

# Remote評価の固定ルール
- "Fully Remote" 明記 → 原則remoteStars=5
- "Remote" のみで出社頻度不明 → officeFrequencyを"不明"とし、missingInfoへ「出社頻度」を追加。
  remoteStarsを4にはしない（情報不足のまま高評価を出さない）。
- "Remote可（要相談）" → 原則remoteStars<=3
- "Hybrid" → 出社頻度に応じて評価
- "Office" → 原則低評価（remoteStars<=2）

# 分類ルール（classification）
- "A": 能力・働き方・報酬・継続性が高水準で一致
- "B": 企業が求める人物像とかなり近いが一部確認事項あり
- "C": 完全一致ではないがキャリア上狙う価値がある
- "見送り": 重要条件との衝突が大きい

# 出力
以下のJSONオブジェクトのみを出力してください。説明文・Markdownのコードフェンス・前後の余計な文字は一切
含めないこと。読み取れない項目は "不明"、該当なしの配列は空配列 [] にしてください。

{
  "company": "string",
  "title": "string",
  "location": "string",
  "employmentType": "string",
  "postedDate": "string",
  "url": "string",
  "workStyle": {
    "type": "Fully Remote" | "Remote" | "Hybrid" | "Office" | "不明",
    "officeFrequency": "string",
    "flex": "string",
    "hours": "string"
  },
  "compensation": {
    "minAnnual": "string",
    "maxAnnual": "string",
    "monthly": "string",
    "bonus": "string"
  },
  "role": {
    "mainDuties": "string",
    "requiredSkills": "string",
    "preferredSkills": "string",
    "techStack": "string",
    "management": "string",
    "design": "string",
    "implementation": "string",
    "clientFacing": "string"
  },
  "missingInfo": ["string"],
  "scoring": {
    "classification": "A" | "B" | "C" | "見送り",
    "remoteStars": 1,
    "fitStars": 1,
    "sustainabilityStars": 1,
    "applicationValue": "高" | "中" | "低",
    "goodPoints": ["string"],
    "riskPoints": ["string"],
    "oneLiner": "string"
  }
}

goodPoints・riskPointsは最大3件まで。oneLinerは田中形式で1〜3文、技術適合と不足情報を簡潔に述べること。
'@
}

function ConvertTo-CareerFitImagePart {
    <# フロントから届く data URL ("data:image/png;base64,XXXX") を Gemini inline_data partへ変換する #>
    param([string]$DataUrl)
    if ($DataUrl -notmatch '^data:(?<mime>image/[a-zA-Z0-9.+-]+);base64,(?<data>.+)$') {
        throw "画像データの形式が不正です（data URL形式ではありません）"
    }
    return @{
        inline_data = @{
            mime_type = $Matches['mime']
            data      = $Matches['data']
        }
    }
}

function Invoke-CareerFitGeminiHttpCall {
    <# 実HTTP呼び出し。selftestでは -ApiCallOverride で差し替える。 #>
    param([string]$ApiKey, [string]$Model, [string[]]$ImageDataUrls)

    $uri = "https://generativelanguage.googleapis.com/v1beta/models/${Model}:generateContent?key=$ApiKey"

    $parts = @(@{ text = 'この求人スクリーンショット群を抽出・評価してください。' })
    foreach ($dataUrl in $ImageDataUrls) {
        $parts += ConvertTo-CareerFitImagePart -DataUrl $dataUrl
    }

    $body = @{
        systemInstruction = @{ parts = @(@{ text = Get-CareerFitSystemPrompt }) }
        contents          = @(@{ role = 'user'; parts = $parts })
        generationConfig  = @{ responseMimeType = 'application/json' }
    } | ConvertTo-Json -Depth 20

    $resp = Invoke-RestMethod -Uri $uri -Method Post -ContentType 'application/json; charset=utf-8' `
        -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -TimeoutSec 90
    $text = $resp.candidates[0].content.parts[0].text
    if (-not $text) { throw 'Gemini APIレスポンスにテキストが含まれていません' }
    return $text
}

function Invoke-CareerFitAnalyze {
    <#
    求人画像群を解析する。
    戻り値: @{ Success; Data (PSCustomObject|$null); Error }
    -ApiCallOverride があればHTTP呼び出しをそれに差し替える（selftest専用、$ImageDataUrls -> テキストを返す関数）。
    #>
    param(
        [string[]]$ImageDataUrls,
        [scriptblock]$ApiCallOverride = $null
    )

    if (-not $ImageDataUrls -or $ImageDataUrls.Count -eq 0) {
        return [PSCustomObject]@{ Success = $false; Data = $null; Error = '画像が指定されていません' }
    }

    $apiKey = $null
    if (-not $ApiCallOverride) {
        $apiKey = $env:GEMINI_API_KEY
        if (-not $apiKey) {
            return [PSCustomObject]@{ Success = $false; Data = $null; Error = 'GEMINI_API_KEY未設定です。環境変数を設定してください（IACPROJECT/tools/README_IAC_GEMINI_BRIDGE参照）。' }
        }
    }
    $model = if ($env:GEMINI_CAREER_FIT_MODEL) { $env:GEMINI_CAREER_FIT_MODEL } else { $Script:CareerFitDefaultModel }

    $attempts = 0
    $lastError = $null
    while ($attempts -lt $Script:CareerFitMaxRetries) {
        $attempts++
        try {
            if ($ApiCallOverride) {
                $text = & $ApiCallOverride $ImageDataUrls $attempts
            } else {
                $text = Invoke-CareerFitGeminiHttpCall -ApiKey $apiKey -Model $model -ImageDataUrls $ImageDataUrls
            }
            try {
                $parsed = $text | ConvertFrom-Json -ErrorAction Stop
            } catch {
                throw "Gemini応答をJSONとして解釈できませんでした: $($_.Exception.Message)"
            }
            return [PSCustomObject]@{ Success = $true; Data = $parsed; Error = $null }
        } catch {
            $lastError = $_.Exception.Message
            if ($attempts -lt $Script:CareerFitMaxRetries) {
                Start-Sleep -Seconds $Script:CareerFitRetryBackoffSeconds[$attempts - 1]
            }
        }
    }
    return [PSCustomObject]@{ Success = $false; Data = $null; Error = $lastError }
}
