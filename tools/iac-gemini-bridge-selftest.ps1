#Requires -Version 5.1
<#
Task ID: IAC-GEMINI-BRIDGE-001
iac-gemini-bridge.ps1 のロジック自己テスト。人工fixture・一時ディレクトリのみを使用し、
実リポジトリの IACPROJECT/inbox・IACPROJECT/ROUTER・git には一切触れない。
Gemini APIへの実通信は行わない（-ApiCallOverride でスタブ化する）。
実行: powershell -NoProfile -ExecutionPolicy Bypass -File tools\iac-gemini-bridge-selftest.ps1
#>
$ErrorActionPreference = 'Stop'

$env:IAC_GEMINI_BRIDGE_NO_MAIN = '1'
try {
    . (Join-Path $PSScriptRoot 'iac-gemini-bridge.ps1')
} finally {
    $env:IAC_GEMINI_BRIDGE_NO_MAIN = ''
}

$pass = 0; $fail = 0
function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) { $Script:pass++; Write-Host "  OK  $Name" }
    else { $Script:fail++; Write-Host "  NG  $Name" }
}

$fixtureDir = Join-Path $PSScriptRoot 'tests\fixtures\gemini_bridge'

function New-TestHandoffFile {
    param([string]$Path, [string]$TaskId, [string]$RequiredAction = 'selftest request')
    @(
        '# HANDOFF', '', '## From / To', '', 'From: アーク', 'To: 二葉（Gemini）', '',
        '## Task ID', '', $TaskId, '',
        '## Required next action', '', $RequiredAction, ''
    ) | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Get-BridgeEntry {
    param([string]$Pattern, [string]$Direction = 'to_gemini')
    return @(Get-GeminiBridgeStateEntries -StatePath $Script:StatePath |
        Where-Object { $_.HandoffId -match $Pattern -and $_.Direction -eq $Direction }) | Select-Object -First 1
}

# --- 一時リポジトリ構造（実リポジトリには一切触れない） ---
$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("iac_gemini_bridge_selftest_" + [guid]::NewGuid().ToString('N'))
$TempFromArc = Join-Path $TempRoot 'IACPROJECT\inbox\from_arc'
$TempFromKei = Join-Path $TempRoot 'IACPROJECT\inbox\from_kei'
$TempFromGemini = Join-Path $TempRoot 'IACPROJECT\inbox\from_gemini'
$TempRouter = Join-Path $TempRoot 'IACPROJECT\ROUTER'
New-Item -ItemType Directory -Force -Path $TempFromArc, $TempFromKei, $TempFromGemini, $TempRouter | Out-Null

# dot-source済みのため $Script: スコープが共有されている。実パスを一時ディレクトリへ差し替える。
$Script:RepoRoot      = $TempRoot
$Script:StatePath     = Join-Path $TempRouter 'GEMINI_BRIDGE_STATE.md'
$Script:CostLogPath   = Join-Path $TempRouter 'GEMINI_BRIDGE_COST_LOG.md'
$Script:FromArcDir    = $TempFromArc
$Script:FromKeiDir    = $TempFromKei
$Script:FromGeminiDir = $TempFromGemini
$Script:GeminiWatchDirs = @($Script:FromArcDir, $Script:FromKeiDir)
$NoGit = $true

try {
    Write-Host '--- 0. fixture健全性（既存パーサ Get-HandoffDocument / Test-HandoffAddressedTo の再利用） ---'
    $f0a = Get-Item (Join-Path $fixtureDir '2026-01-03_ARC_TO_GEMINI_TEST_BRIDGE_REQUEST.md')
    $d0a = Get-HandoffDocument -File $f0a -RepoRoot $fixtureDir
    Assert-True (Test-HandoffAddressedTo -Doc $d0a -Token 'gemini') 'fixture1: 二葉宛と判定される'
    $f0b = Get-Item (Join-Path $fixtureDir '2026-01-03_ARC_TO_CLAUDE_TEST_NOT_FOR_GEMINI.md')
    $d0b = Get-HandoffDocument -File $f0b -RepoRoot $fixtureDir
    Assert-True (-not (Test-HandoffAddressedTo -Doc $d0b -Token 'gemini')) 'fixture2: 二葉宛ではないと判定される'

    Write-Host '--- 1. 宛先ヘッダ抽出（Get-GeminiResponseToToken） ---'
    Assert-True ((Get-GeminiResponseToToken -ResponseText "本文`nTo: アーク`n続き") -eq 'arc') 'To: 行からarcを解決'
    Assert-True ((Get-GeminiResponseToToken -ResponseText "本文`n宛先：黒瀬（Claude）`n続き") -eq 'claude') '宛先：行から黒瀬を解決'
    Assert-True ($null -eq (Get-GeminiResponseToToken -ResponseText "宛先の行がない本文だけ")) '宛先行なしはnull（推測しない）'
    Assert-True ($null -eq (Get-GeminiResponseToToken -ResponseText "To: 誰だかわからない人`n")) '解決不能な宛先はnull（推測しない）'

    Write-Host '--- 2. 断定語検出（Test-GeminiResponseHasDecisionLanguage） ---'
    Assert-True (Test-GeminiResponseHasDecisionLanguage -ResponseText '仕様をこのように決定する') '「決定」を検出'
    Assert-True (Test-GeminiResponseHasDecisionLanguage -ResponseText 'We have finalized the approach') '「finalized」を検出'
    Assert-True (-not (Test-GeminiResponseHasDecisionLanguage -ResponseText '案として比喩を提示するだけです')) '断定語なしは検出しない'

    Write-Host '--- 3. 正常系: 送信→生保存→state SENT ---'
    New-TestHandoffFile -Path (Join-Path $TempFromArc '2026-02-01_ARC_TO_GEMINI_TEST_NORMAL.md') -TaskId 'TEST-NORMAL-001'
    $mockOk = { param($prompt, $attempt) "To: アーク`n`n比喩：これは橋である。まだ結論は出ていない。" }
    Invoke-GeminiBridgeRun -ApiCallOverride $mockOk
    $e1 = Get-BridgeEntry -Pattern 'TEST_NORMAL'
    Assert-True ($e1.Status -eq 'SENT') '正常系: state=SENT'
    $savedFiles = @(Get-ChildItem $TempFromGemini -Filter '*.md' -File)
    Assert-True ($savedFiles.Count -eq 1) '正常系: from_geminiへ1件保存'
    Assert-True ((Get-Content $savedFiles[0].FullName -Raw) -match '比喩：これは橋である') '正常系: 生Markdownのまま保存（要約されていない）'

    Write-Host '--- 4. 冪等性: SENT済みは再実行してもAPIを呼ばない ---'
    $callCount = 0
    Invoke-GeminiBridgeRun -ApiCallOverride { param($prompt, $attempt) $Script:callCount++; "To: アーク`n応答" }
    Assert-True ($callCount -eq 0) '冪等性: SENT済みのHandoffは再送しない'

    Write-Host '--- 5. 宛先ヘッダ欠落 → HELD_NO_TO_HEADER・stagingへ保存 ---'
    Remove-Item (Join-Path $TempFromArc '*') -Force
    New-TestHandoffFile -Path (Join-Path $TempFromArc '2026-02-02_ARC_TO_GEMINI_TEST_NOHEADER.md') -TaskId 'TEST-NOHEADER-001'
    Invoke-GeminiBridgeRun -ApiCallOverride { param($prompt, $attempt) '宛先を書き忘れた応答本文です。' }
    $e2 = Get-BridgeEntry -Pattern 'TEST_NOHEADER'
    Assert-True ($e2.Status -eq 'HELD_NO_TO_HEADER') '宛先欠落: state=HELD_NO_TO_HEADER'
    $stagingDir = Join-Path $TempRoot 'staging\gemini_held'
    Assert-True ((Test-Path $stagingDir) -and (@(Get-ChildItem $stagingDir -Filter '*no_to_header*').Count -eq 1)) '宛先欠落: stagingへ生保存'
    Assert-True (@(Get-ChildItem $TempFromGemini -Filter '*NOHEADER*').Count -eq 0) '宛先欠落: inboxへは送信しない'

    Write-Host '--- 6. 断定語検出 → HELD_DECISION_LANGUAGE・stagingへ保存 ---'
    Remove-Item (Join-Path $TempFromArc '*') -Force
    New-TestHandoffFile -Path (Join-Path $TempFromArc '2026-02-03_ARC_TO_GEMINI_TEST_DECISION.md') -TaskId 'TEST-DECISION-001'
    Invoke-GeminiBridgeRun -ApiCallOverride { param($prompt, $attempt) "To: アーク`n`nこの仕様を正式に採用することを決定する。" }
    $e3 = Get-BridgeEntry -Pattern 'TEST_DECISION'
    Assert-True ($e3.Status -eq 'HELD_DECISION_LANGUAGE') '断定語検出: state=HELD_DECISION_LANGUAGE'
    Assert-True (@(Get-ChildItem $TempFromGemini -Filter '*DECISION*').Count -eq 0) '断定語検出: 正本へ影響しうる応答は自動送信しない'

    Write-Host '--- 7. リトライ上限: 常に失敗 → FAILED_RETRY_EXHAUSTED、試行回数=上限 ---'
    Remove-Item (Join-Path $TempFromArc '*') -Force
    New-TestHandoffFile -Path (Join-Path $TempFromArc '2026-02-04_ARC_TO_GEMINI_TEST_RETRYFAIL.md') -TaskId 'TEST-RETRYFAIL-001'
    $origBackoff = $Script:GeminiBridgeRetryBackoffSeconds
    $Script:GeminiBridgeRetryBackoffSeconds = @(0, 0, 0)
    try {
        Invoke-GeminiBridgeRun -ApiCallOverride { param($prompt, $attempt) throw 'simulated network error' }
    } finally {
        $Script:GeminiBridgeRetryBackoffSeconds = $origBackoff
    }
    $e4 = Get-BridgeEntry -Pattern 'TEST_RETRYFAIL'
    Assert-True ($e4.Status -eq 'FAILED_RETRY_EXHAUSTED') 'リトライ上限: state=FAILED_RETRY_EXHAUSTED'
    Assert-True ([int]$e4.Attempts -eq $Script:GeminiBridgeMaxRetries) "リトライ上限: 試行回数が上限($Script:GeminiBridgeMaxRetries)で停止"

    Write-Host '--- 8. APIキー未設定 → FAILED_NO_API_KEY・リトライを消費しない ---'
    Remove-Item (Join-Path $TempFromArc '*') -Force
    New-TestHandoffFile -Path (Join-Path $TempFromArc '2026-02-05_ARC_TO_GEMINI_TEST_NOKEY.md') -TaskId 'TEST-NOKEY-001'
    $savedKey = $env:GEMINI_API_KEY
    $env:GEMINI_API_KEY = $null
    try {
        # overrideを渡さない＝実呼び出し経路。キー欠落チェックで止まり、実HTTP呼び出しには到達しない。
        Invoke-GeminiBridgeRun
    } finally {
        $env:GEMINI_API_KEY = $savedKey
    }
    $e5 = Get-BridgeEntry -Pattern 'TEST_NOKEY'
    Assert-True ($e5.Status -eq 'FAILED_NO_API_KEY') 'APIキー未設定: state=FAILED_NO_API_KEY'
    Assert-True ([int]$e5.Attempts -eq 0) 'APIキー未設定: リトライを消費しない'

    Write-Host '--- 9. 往復上限: 同一スレッドで4回目はHELD_ROUNDTRIP_LIMIT、APIを呼ばない ---'
    Remove-Item (Join-Path $TempFromArc '*') -Force
    $threadKey = 'TEST-ROUNDTRIP-THREAD'
    for ($i = 1; $i -le 3; $i++) {
        Set-GeminiBridgeStateEntry -StatePath $Script:StatePath -HandoffId "fake/roundtrip/$i.md" -ThreadKey $threadKey `
            -Direction 'to_gemini' -Status 'SENT' -Attempts 1 -RoundTrip $i -Note 'seed'
    }
    New-TestHandoffFile -Path (Join-Path $TempFromArc '2026-02-06_ARC_TO_GEMINI_TEST_ROUNDTRIP.md') -TaskId $threadKey
    $rtCallCount = 0
    Invoke-GeminiBridgeRun -ApiCallOverride { param($prompt, $attempt) $Script:rtCallCount++; "To: アーク`n応答" }
    $e6 = Get-BridgeEntry -Pattern 'TEST_ROUNDTRIP'
    Assert-True ($e6.Status -eq 'HELD_ROUNDTRIP_LIMIT') '往復上限: 4回目はHELD_ROUNDTRIP_LIMIT'
    Assert-True ($rtCallCount -eq 0) '往復上限: 上限超過時はAPIを呼ばない'

    Write-Host '--- 10. コスト上限: 到達済みならAPIを呼ばずHELD_COST_CAP ---'
    Remove-Item (Join-Path $TempFromArc '*') -Force
    New-TestHandoffFile -Path (Join-Path $TempFromArc '2026-02-07_ARC_TO_GEMINI_TEST_COSTCAP.md') -TaskId 'TEST-COSTCAP-001'
    # 本番と同じ関数で上限まで積み上げる（手書き行だと既存月行との重複で誤読するため）
    while (-not (Test-GeminiBridgeCostCapExceeded -CostLogPath $Script:CostLogPath)) {
        Add-GeminiBridgeCostCall -CostLogPath $Script:CostLogPath | Out-Null
    }
    $costCallCount = 0
    Invoke-GeminiBridgeRun -ApiCallOverride { param($prompt, $attempt) $Script:costCallCount++; "To: アーク`n応答" }
    $e7 = Get-BridgeEntry -Pattern 'TEST_COSTCAP'
    Assert-True ($e7.Status -eq 'HELD_COST_CAP') 'コスト上限: state=HELD_COST_CAP'
    Assert-True ($costCallCount -eq 0) 'コスト上限: 到達済みならAPIを呼ばない'

    Write-Host '--- 11. 二葉宛でないHandoffはBridgeの対象外 ---'
    Remove-Item (Join-Path $TempFromArc '*') -Force
    Copy-Item (Join-Path $fixtureDir '2026-01-03_ARC_TO_CLAUDE_TEST_NOT_FOR_GEMINI.md') $TempFromArc
    $offCallCount = 0
    Invoke-GeminiBridgeRun -ApiCallOverride { param($prompt, $attempt) $Script:offCallCount++; 'unused' }
    Assert-True ($offCallCount -eq 0) '対象外: 二葉宛でないHandoffは処理しない（APIを呼ばない）'

    Write-Host '--- 12. inbox/from_gemini 既存ファイルの検証（APIは呼ばない） ---'
    Remove-Item (Join-Path $TempFromArc '*') -Force
    $validExisting = Join-Path $TempFromGemini '2026-02-08_GEMINI_TO_ARC_TEST_EXISTINGVALID.md'
    @('To: アーク', '', '比喩：波は止まらない。') | Set-Content -LiteralPath $validExisting -Encoding UTF8
    $noHeaderExisting = Join-Path $TempFromGemini '2026-02-08_GEMINI_TEST_EXISTINGNOHEADER.md'
    @('宛先を書いていない既存ファイル') | Set-Content -LiteralPath $noHeaderExisting -Encoding UTF8
    Invoke-GeminiBridgeRun -ApiCallOverride { param($prompt, $attempt) 'unused' }
    $eValid = Get-BridgeEntry -Pattern 'EXISTINGVALID' -Direction 'from_gemini'
    Assert-True ($eValid.Status -eq 'ACK') '既存ファイル検証: 宛先ヘッダありはACK'
    $eNoHeader = Get-BridgeEntry -Pattern 'EXISTINGNOHEADER' -Direction 'from_gemini'
    Assert-True ($eNoHeader.Status -eq 'HELD_NO_TO_HEADER') '既存ファイル検証: 宛先ヘッダなしはHELD_NO_TO_HEADER'

    Write-Host '--- 13. 複数宛先Handoff → HELD_MULTI_RECIPIENT・自動送信しない（2026-08-10追加） ---'
    Remove-Item (Join-Path $TempFromArc '*') -Force
    $multiPath = Join-Path $TempFromArc '2026-02-09_ARC_TO_GEMINI_TEST_MULTIRECIPIENT.md'
    @(
        '# HANDOFF', '', '## From / To', '',
        'From: アーク', 'To: 黒瀬（Claude）, 二葉（Gemini）, スネーク（Grok）', '',
        '## Task ID', '', 'TEST-MULTIRECIPIENT-001', '',
        '## Required next action', '', 'selftest request', ''
    ) | Set-Content -LiteralPath $multiPath -Encoding UTF8
    $multiCallCount = 0
    Invoke-GeminiBridgeRun -ApiCallOverride { param($prompt, $attempt) $Script:multiCallCount++; "To: アーク`n応答" }
    $e8 = Get-BridgeEntry -Pattern 'TEST_MULTIRECIPIENT'
    Assert-True ($e8.Status -eq 'HELD_MULTI_RECIPIENT') '複数宛先: state=HELD_MULTI_RECIPIENT'
    Assert-True ($multiCallCount -eq 0) '複数宛先: APIを呼ばない'
    Assert-True (@(Get-ChildItem $TempFromGemini -Filter '*MULTIRECIPIENT*').Count -eq 0) '複数宛先: inboxへは送信しない'
    $multiStagingFiles = @(Get-ChildItem (Join-Path $TempRoot 'staging\gemini_held') -Filter '*multi_recipient*' -ErrorAction SilentlyContinue)
    Assert-True ($multiStagingFiles.Count -eq 1) '複数宛先: stagingへ生保存'

    Write-Host '--- 14. inbox/from_kei（チャットUI送信元）も監視対象・二葉宛のみ処理（2026-08-11追加） ---'
    Remove-Item (Join-Path $TempFromArc '*') -Force -ErrorAction SilentlyContinue
    Remove-Item (Join-Path $TempFromKei '*') -Force -ErrorAction SilentlyContinue
    # テスト10でコストログを月次上限まで積み上げているため、このテスト専用にリセットする
    Remove-Item -LiteralPath $Script:CostLogPath -Force -ErrorAction SilentlyContinue

    $keiGeminiPath = Join-Path $TempFromKei '2026-08-11_KEI_TO_GEMINI_TEST_CHAT.md'
    @(
        '# HANDOFF', '', '## From / To', '',
        'From: ケイ', 'To: 二葉（Gemini）', '',
        '## Task ID', '', 'IAC-CHAT-TEST-GEMINI-001', '',
        '## Required next action', '', 'selftest request from chat ui', ''
    ) | Set-Content -LiteralPath $keiGeminiPath -Encoding UTF8

    $keiClaudePath = Join-Path $TempFromKei '2026-08-11_KEI_TO_CLAUDE_TEST_CHAT.md'
    @(
        '# HANDOFF', '', '## From / To', '',
        'From: ケイ', 'To: 黒瀬（Claude）', '',
        '## Task ID', '', 'IAC-CHAT-TEST-CLAUDE-001', '',
        '## Required next action', '', 'selftest request not for gemini', ''
    ) | Set-Content -LiteralPath $keiClaudePath -Encoding UTF8

    $keiCallCount = 0
    Invoke-GeminiBridgeRun -ApiCallOverride { param($prompt, $attempt) $Script:keiCallCount++; "To: ケイ`n応答" }
    $eKeiGemini = Get-BridgeEntry -Pattern 'KEI_TO_GEMINI_TEST_CHAT'
    Assert-True ($eKeiGemini.Status -eq 'SENT') 'from_kei: 二葉宛は正しく検出されSENTになる（チャットUIからの直接到達）'
    Assert-True ($keiCallCount -eq 1) 'from_kei: 二葉宛のみAPIが1回呼ばれる（黒瀬宛は呼ばれない）'
    $eKeiClaude = Get-BridgeEntry -Pattern 'KEI_TO_CLAUDE_TEST_CHAT'
    Assert-True ($null -eq $eKeiClaude) 'from_kei: 二葉宛でないHandoffは宛先フィルタでスキップされstateに登録されない'

    Write-Host ''
    Write-Host "selftest: 成功 $pass / 失敗 $fail"
} finally {
    Remove-Item -Recurse -Force -LiteralPath $TempRoot -ErrorAction SilentlyContinue
}

if ($fail -gt 0) { exit 1 } else { exit 0 }
