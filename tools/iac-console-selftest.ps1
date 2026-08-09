#Requires -Version 5.1
<#
Task ID: IAC-OPS-CONSOLE-001
iac-console.ps1 のパーサ自己テスト。人工fixture（tools\tests\fixtures）のみを使用し、
リポジトリ内の実Handoffやgitには一切触れない。
実行: powershell -NoProfile -ExecutionPolicy Bypass -File tools\iac-console-selftest.ps1
#>
$ErrorActionPreference = 'Stop'

$env:IAC_CONSOLE_NO_MAIN = '1'
try {
    . (Join-Path $PSScriptRoot 'iac-console.ps1')
} finally {
    $env:IAC_CONSOLE_NO_MAIN = ''
}

$fixtureDir = Join-Path $PSScriptRoot 'tests\fixtures'
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

Write-Host '--- 1. フル形式（# HANDOFF / 英語見出し） ---'
$f1 = Get-Item (Join-Path $fixtureDir '2026-01-01_ARC_TO_CLAUDE_TEST_FULL_FORMAT.md')
$d1 = Get-HandoffDocument -File $f1 -RepoRoot $fixtureDir
Assert-True ($d1.From -eq 'アーク') 'From を抽出'
Assert-True ($d1.ToRaw -eq '黒瀬（Claude）') 'To を抽出'
Assert-True ($d1.TaskId -eq 'TEST-FIXTURE-001') 'Task ID を抽出'
Assert-True ($d1.Date -like '2026-01-01*') 'Date を抽出'
Assert-True ($d1.RequiredNextAction.Length -gt 0) 'Required next action を抽出'
Assert-True ($d1.Questions.Count -eq 2) 'Questions queue 2件を抽出'
Assert-True ($d1.FromToken -eq 'arc' -and $d1.ToToken -eq 'claude') 'ファイル名からFrom/Toトークンを解決'
Assert-True (Test-HandoffAddressedTo -Doc $d1 -Token 'claude') '宛先判定（claude）'

Write-Host '--- 2. PACKET形式（日本語ラベル・Task IDなし） ---'
$f2 = Get-Item (Join-Path $fixtureDir '2026-01-02_KAKEZUKI_TO_SATO_TEST_PACKET_VARIANT.md')
$d2 = Get-HandoffDocument -File $f2 -RepoRoot $fixtureDir
Assert-True ($d2.From -eq '欠月') '送信元ラベルからFromを抽出'
Assert-True ($d2.ToRaw -eq '佐藤（Claude Code）') '宛先ラベルからToを抽出'
Assert-True ($d2.RequiredNextAction.Length -gt 0) 'PACKET形式でもRequired next actionを抽出'
Assert-True (@($d2.Warnings | Where-Object { $_ -match 'Task ID' }).Count -eq 1) 'Task ID欠落を警告'
Assert-True (Test-HandoffAddressedTo -Doc $d2 -Token 'claude_code') '宛先判定（表示名 佐藤（Claude Code）→ claude_code）'

Write-Host '--- 3. 構造なしファイル（停止しないこと） ---'
$f3 = Get-Item (Join-Path $fixtureDir 'broken_no_structure.md')
$crashed = $false
try { $d3 = Get-HandoffDocument -File $f3 -RepoRoot $fixtureDir } catch { $crashed = $true }
Assert-True (-not $crashed) 'パーサが例外で停止しない'
Assert-True ($d3.Warnings.Count -gt 0) '欠落項目が警告として記録される'
Assert-True ($d3.RequiredNextAction -eq '') '未抽出項目は空欄のまま'

Write-Host '--- 4. 宛先判定の誤一致防止 ---'
Assert-True (-not (Test-HandoffAddressedTo -Doc $d2 -Token 'claude')) '「佐藤（Claude Code）」宛が claude に誤一致しない'
$dMulti = [PSCustomObject]@{ RelPath = 'x.md'; ToToken = $null; ToRaw = 'ケイ / 欠月 / Claude / Claude Code' }
Assert-True ((Test-HandoffAddressedTo -Doc $dMulti -Token 'claude') -and (Test-HandoffAddressedTo -Doc $dMulti -Token 'claude_code')) '複数宛先で claude と claude_code を両方判定'
Assert-True (-not (Test-HandoffAddressedTo -Doc $dMulti -Token 'grok')) '記載のないメンバーには一致しない'

Write-Host '--- 5. Questions 正規化・同一判定 ---'
$q1 = $d1.Questions | Where-Object { $_ -match '共通質問A' } | Select-Object -First 1
$q2 = $d2.Questions | Where-Object { $_ -match '共通質問A' } | Select-Object -First 1
Assert-True ((ConvertTo-QuestionKey $q1) -eq (ConvertTo-QuestionKey $q2)) '同一文面の質問が同一キーへ正規化される'
Assert-True ((ConvertTo-QuestionKey $d1.Questions[1]) -ne (ConvertTo-QuestionKey $q1)) '異なる質問は別キーになる'

Write-Host ''
Write-Host "selftest: 成功 $pass / 失敗 $fail"
if ($fail -gt 0) { exit 1 } else { exit 0 }
