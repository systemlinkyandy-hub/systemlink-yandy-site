#Requires -Version 5.1
<#
Task ID: IAC-CHAT-UI-001
iac-chat-lib.ps1 のロジック自己テスト。人工fixture・一時ディレクトリのみを使用し、
リポジトリ内の実Handoff・staging・gitには一切触れない。
実行: powershell -NoProfile -ExecutionPolicy Bypass -File tools\iac-chat-ui-selftest.ps1
#>
$ErrorActionPreference = 'Stop'

$Script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

$env:IAC_CONSOLE_NO_MAIN = '1'
try {
    . (Join-Path $PSScriptRoot 'iac-handoff-lib.ps1')
    . (Join-Path $PSScriptRoot 'iac-console.ps1')
} finally {
    $env:IAC_CONSOLE_NO_MAIN = ''
}
. (Join-Path $PSScriptRoot 'iac-chat-lib.ps1')

$pass = 0; $fail = 0
function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) {
        $Script:pass++
        Write-Host "  OK  $Name"
    } else {
        $Script:fail++
        Write-Host "  NG  $Name"
    }
}

$tempRoot = Join-Path $env:TEMP "iac_chat_ui_selftest_$([guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

try {
    Write-Host '--- 0. dot-source変数衝突の自己防御チェック ---'
    $collisions = Test-ChatDotSourceVariableCollision -RepoRoot $Script:RepoRoot
    Assert-True ($collisions.Count -eq 0) "iac-console.ps1のparam名との衝突なし（検出: $($collisions -join ', '))"

    Write-Host '--- 1. New-ChatHandoffBody 往復テスト（単一宛先） ---'
    $now = [datetime]'2026-08-11 21:00:00'
    $taskId = (Get-ChatTaskId -Now $now) + '-claude'
    $body = New-ChatHandoffBody -ToDisplayName '黒瀬（Claude）' -CcDisplayNames @() -TaskId $taskId -Now $now -MessageText 'テストメッセージ本文'
    $f1 = Join-Path $tempRoot 'roundtrip_single.md'
    Write-ChatUtf8BomFile -Path $f1 -Content $body
    $doc1 = Get-HandoffDocument -File (Get-Item $f1) -RepoRoot $tempRoot
    Assert-True ($doc1.From -eq 'ケイ') 'From=ケイ を抽出'
    Assert-True ($doc1.ToRaw -eq '黒瀬（Claude）') 'To=黒瀬（Claude） を抽出'
    Assert-True ($doc1.TaskId -eq $taskId) 'Task ID を抽出'
    Assert-True ($doc1.RequiredNextAction -eq 'テストメッセージ本文') 'Required next action にメッセージ本文がそのまま入る'
    Assert-True (Test-HandoffAddressedTo -Doc $doc1 -Token 'claude') '宛先判定（claude）が真'
    Assert-True (-not (Test-HandoffAddressedTo -Doc $doc1 -Token 'gemini')) '無関係な宛先には一致しない'

    Write-Host '--- 2. New-ChatHandoffBody 往復テスト（CC付き） ---'
    $bodyCc = New-ChatHandoffBody -ToDisplayName '二葉（Gemini）' -CcDisplayNames @('アーク', 'スネーク（Grok）') -TaskId 'IAC-CHAT-TEST-gemini' -Now $now -MessageText '複数宛先の1通'
    $f2 = Join-Path $tempRoot 'roundtrip_cc.md'
    Write-ChatUtf8BomFile -Path $f2 -Content $bodyCc
    $doc2 = Get-HandoffDocument -File (Get-Item $f2) -RepoRoot $tempRoot
    Assert-True ($doc2.ToRaw -eq '二葉（Gemini）') 'CC付きでもTo欄は単一宛先のまま'
    $ccTokens = @(Get-ToFieldTokens -ToRaw $doc2.ToRaw)
    Assert-True ($ccTokens.Count -eq 1 -and $ccTokens[0] -eq 'gemini') 'CC欄はToRawに含まれずTo欄トークン数は1のまま（誤配送防止ロジックに無害）'

    Write-Host '--- 3. Get-ChatHandoffFileName 衝突回避 ---'
    $stagingDir = Join-Path $tempRoot 'staging'
    New-Item -ItemType Directory -Force -Path $stagingDir | Out-Null
    $name1 = Get-ChatHandoffFileName -RepoRoot $tempRoot -Token 'claude' -Now $now
    Assert-True ($name1 -eq '2026-08-11_2100_KEI_TO_CLAUDE_CHAT.md') '初回はサフィックスなしのファイル名'
    New-Item -ItemType File -Force -Path (Join-Path $stagingDir $name1) | Out-Null
    $name2 = Get-ChatHandoffFileName -RepoRoot $tempRoot -Token 'claude' -Now $now
    Assert-True ($name2 -eq '2026-08-11_2100_KEI_TO_CLAUDE_CHAT2.md') '同名衝突時は連番2が振られる'
    New-Item -ItemType File -Force -Path (Join-Path $stagingDir $name2) | Out-Null
    $name3 = Get-ChatHandoffFileName -RepoRoot $tempRoot -Token 'claude' -Now $now
    Assert-True ($name3 -eq '2026-08-11_2100_KEI_TO_CLAUDE_CHAT3.md') '3件目の連投は連番3が振られる'

    Write-Host '--- 4. Get-ChatAllRecipientTokens ---'
    $allResult = Get-ChatAllRecipientTokens
    $knownCount = @($Script:MemberAliasMap.Values | Sort-Object -Unique | Where-Object { $_ -ne 'all' -and $_ -ne 'kei' }).Count
    Assert-True ($allResult.Tokens.Count -eq $knownCount) '既知メンバー数と一致（重複なし）'
    Assert-True (($allResult.Tokens | Sort-Object -Unique).Count -eq $allResult.Tokens.Count) 'トークン重複なし'
    Assert-True ($allResult.Tokens[0] -eq 'kakezuki') '先頭はAI_MEMBER_DIRECTORY.md登録順トップの欠月'
    Assert-True ($allResult.Tokens -contains 'chatgpt') 'ディレクトリ未登録のchatgpt（とーか）も末尾へ補われる'
    Assert-True ($allResult.Warnings.Count -gt 0) 'ディレクトリ未登録分の警告が出る'

    Write-Host '--- 5. Build-ChatOutgoingHandoffs（単一宛先） ---'
    $singleResult = Build-ChatOutgoingHandoffs -RepoRoot $tempRoot -TargetToken 'claude' -MessageText '単一宛先テスト' -Now $now
    Assert-True ($singleResult.Items.Count -eq 1) '単一宛先は1件のみ生成'
    Assert-True ($singleResult.Items[0].Token -eq 'claude') 'トークンが一致'
    $singleDoc = Get-HandoffDocument -File ([System.IO.FileInfo]::new((Join-Path $tempRoot 'dummy_not_written.md'))) -RepoRoot $tempRoot
    # 実際にパースして確認（一時ファイルへ書き出してから読む）
    $singlePath = Join-Path $tempRoot 'single_out.md'
    Write-ChatUtf8BomFile -Path $singlePath -Content $singleResult.Items[0].Content
    $singleParsed = Get-HandoffDocument -File (Get-Item $singlePath) -RepoRoot $tempRoot
    Assert-True ($singleParsed.RequiredNextAction -eq '単一宛先テスト') '単一宛先の本文が正しく載る'

    Write-Host '--- 6. Build-ChatOutgoingHandoffs（ALL宛先分解） ---'
    $allOut = Build-ChatOutgoingHandoffs -RepoRoot $tempRoot -TargetToken 'all' -MessageText 'ALL送信テスト' -Now $now
    Assert-True ($allOut.Items.Count -eq $knownCount) 'ALL送信は既知メンバー数ぶん個別ファイルが生成される'
    $uniqueFileNames = @($allOut.Items | ForEach-Object { $_.FileName } | Sort-Object -Unique)
    Assert-True ($uniqueFileNames.Count -eq $allOut.Items.Count) '生成ファイル名がすべて重複しない'
    foreach ($item in $allOut.Items) {
        $p = Join-Path $tempRoot "all_$($item.Token).md"
        Write-ChatUtf8BomFile -Path $p -Content $item.Content
        $parsed = Get-HandoffDocument -File (Get-Item $p) -RepoRoot $tempRoot
        $toks = @(Get-ToFieldTokens -ToRaw $parsed.ToRaw)
        if ($toks.Count -ne 1 -or $toks[0] -ne $item.Token) {
            $Script:fail++
            Write-Host "  NG  ALL分解: $($item.Token) の本文To欄が単一宛先になっていない"
        } else {
            $Script:pass++
        }
    }
    $geminiItem = $allOut.Items | Where-Object { $_.Token -eq 'gemini' } | Select-Object -First 1
    Assert-True ($geminiItem.Content -match 'To: ケイ') 'ALL送信の二葉宛のみ、返信にTo:ヘッダを付けるよう自動で指示文が追記される'
    $claudeItem = $allOut.Items | Where-Object { $_.Token -eq 'claude' } | Select-Object -First 1
    Assert-True ($claudeItem.Content -notmatch 'To: ケイ.{0,20}書いてください') '二葉宛以外には指示文が追記されない'

    Write-Host '--- 6b. Build-ChatOutgoingHandoffs（単一宛先=二葉） ---'
    $singleGemini = Build-ChatOutgoingHandoffs -RepoRoot $tempRoot -TargetToken 'gemini' -MessageText '単一宛先で二葉に送るテスト' -Now $now
    Assert-True ($singleGemini.Items.Count -eq 1) '単一宛先(gemini)は1件のみ生成'
    Assert-True ($singleGemini.Items[0].Content -match '単一宛先で二葉に送るテスト') '元のメッセージ本文がそのまま含まれる'
    Assert-True ($singleGemini.Items[0].Content -match 'To: ケイ.{0,20}書いてください') '単一宛先での二葉宛にも指示文が自動追記される'

    Write-Host '--- 7. ConvertTo-ChatMessageItem / Get-ChatInitialMessages（受信表示） ---'
    $inboxDir = Join-Path $tempRoot 'IACPROJECT\inbox\from_claude'
    New-Item -ItemType Directory -Force -Path $inboxDir | Out-Null
    $recentFile = Join-Path $inboxDir "$((Get-Date).ToString('yyyy-MM-dd'))_KUROSE_TO_KEI_TEST_RECEIVE.md"
    $recentBody = New-ChatHandoffBody -ToDisplayName 'ケイ' -TaskId 'IAC-CHAT-TEST-RECEIVE' -Now (Get-Date) -MessageText '受信表示テスト用メッセージ'
    Write-ChatUtf8BomFile -Path $recentFile -Content $recentBody
    $oldFile = Join-Path $inboxDir '2020-01-01_KUROSE_TO_KEI_TEST_OLD.md'
    $oldBody = New-ChatHandoffBody -ToDisplayName 'ケイ' -TaskId 'IAC-CHAT-TEST-OLD' -Now ([datetime]'2020-01-01') -MessageText '期間外メッセージ'
    Write-ChatUtf8BomFile -Path $oldFile -Content $oldBody

    $doc = Get-HandoffDocument -File (Get-Item $recentFile) -RepoRoot $tempRoot
    $msgItem = ConvertTo-ChatMessageItem -Doc $doc
    Assert-True ($msgItem.DisplayName -eq 'ケイ') 'ConvertTo-ChatMessageItem: From欄からDisplayNameを設定'
    Assert-True ($msgItem.Body -eq '受信表示テスト用メッセージ') 'ConvertTo-ChatMessageItem: Bodyに本文が入る'
    Assert-True (-not $msgItem.HasWarning) '警告なしのHandoffはHasWarning=false'

    $brokenFile = Join-Path $inboxDir "$((Get-Date).ToString('yyyy-MM-dd'))_broken_no_structure.md"
    Write-ChatUtf8BomFile -Path $brokenFile -Content 'これは構造を持たない壊れたファイルです。'
    $brokenDoc = Get-HandoffDocument -File (Get-Item $brokenFile) -RepoRoot $tempRoot
    $brokenItem = ConvertTo-ChatMessageItem -Doc $brokenDoc
    Assert-True ($brokenItem.HasWarning) '構造なしファイルはHasWarning=trueで、例外を投げず変換される'
    Assert-True ($null -ne $brokenItem.DisplayName) '構造なしファイルでもDisplayNameがnullにならない（フォールバック）'

    $initial = Get-ChatInitialMessages -RepoRoot $tempRoot -DaysBack 7
    Assert-True (@($initial | Where-Object { $_.TaskId -eq 'IAC-CHAT-TEST-RECEIVE' }).Count -eq 1) '直近7日以内のHandoffが初期表示に含まれる'
    Assert-True (@($initial | Where-Object { $_.TaskId -eq 'IAC-CHAT-TEST-OLD' }).Count -eq 0) '期間外(2020年)のHandoffは初期表示から除外される'

    Write-Host ''
    Write-Host "selftest: 成功 $pass / 失敗 $fail"
} finally {
    Remove-Item -Recurse -Force $tempRoot -ErrorAction SilentlyContinue
}

if ($fail -gt 0) { exit 1 } else { exit 0 }
