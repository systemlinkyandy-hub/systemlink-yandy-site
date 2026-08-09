#Requires -Version 5.1
<#
Task ID: IAC-OPS-CONSOLE-001
起床パケット作成の対話ランチャー（デスクトップのダブルクリック用）。
相手をローマ字で入力させ、iac-console wake <member> -Push を実行する。
cmdバッチは日本語表示が文字化けするため、表示・入力はこのPowerShell側で行う。
#>
$ErrorActionPreference = 'Stop'

Write-Host '起床パケットを作る相手を入力してください（ローマ字）。'
Write-Host '  kurose(黒瀬) / snake(スネーク) / sato(佐藤) / codex(とーか)'
Write-Host '  arc(アーク) / kakezuki(欠月) / uehara(上原さん) / yue(ユエ) / tanaka(田中)'
Write-Host '  ※二葉(Gemini)はアークの単一Packet方式のため対象外です'
Write-Host ''
$member = Read-Host '相手'
if (-not $member) {
    Write-Host '入力がなかったため中止しました。'
    exit 0
}
& (Join-Path $PSScriptRoot 'iac-console.ps1') wake $member.Trim() -Push
