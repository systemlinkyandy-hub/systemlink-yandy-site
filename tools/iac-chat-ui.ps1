#Requires -Version 5.1
<#
Task ID: IAC-CHAT-UI-001
複数人会話用チャットUI（PowerShell + WPF）。起動エントリ。paramブロックを持たない
（Get-ChildItem等の相対パス解決に依存する既存iac-*.cmdとの一貫性のため、常に .cmd 経由での
起動を想定するが、直接 powershell.exe -File での起動にも対応する）。

使い方: tools\iac-chat-ui.cmd をダブルクリックするか、
  powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File tools\iac-chat-ui.ps1

CLAUDE.md「PowerShellツール実装時の注意（dot-source変数名衝突）」に従い、iac-console.ps1の
param名（Command, Member, To, SinceDays, Push）と同名の変数はこのファイル内で一切使わない。
#>

# --- WPFはSTAスレッド必須。pwsh(PowerShell 7)はデフォルトMTAのため自己再起動で保証する ---
if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne [System.Threading.ApartmentState]::STA) {
    $argsForRestart = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-STA', '-File', $PSCommandPath)
    Start-Process -FilePath 'powershell.exe' -ArgumentList $argsForRestart
    exit 0
}

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase | Out-Null

$Script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

$env:IAC_CONSOLE_NO_MAIN = '1'
try {
    . (Join-Path $PSScriptRoot 'iac-handoff-lib.ps1')
    . (Join-Path $PSScriptRoot 'iac-console.ps1')
} finally {
    $env:IAC_CONSOLE_NO_MAIN = ''
}
. (Join-Path $PSScriptRoot 'iac-chat-lib.ps1')

$Script:ChatGitBusy = $false

# ---------------------------------------------------------------------------
# XAML読み込み
# ---------------------------------------------------------------------------
$xamlPath = Join-Path $PSScriptRoot 'iac-chat-ui.xaml'
[xml]$xamlDoc = Get-Content -LiteralPath $xamlPath -Raw -Encoding UTF8
$reader = New-Object System.Xml.XmlNodeReader $xamlDoc
$Window = [System.Windows.Markup.XamlReader]::Load($reader)

$MessageList     = $Window.FindName('MessageList')
$SyncStatusText  = $Window.FindName('SyncStatusText')
$ResyncButton    = $Window.FindName('ResyncButton')
$FailureBanner   = $Window.FindName('FailureBanner')
$FailureBannerText = $Window.FindName('FailureBannerText')
$RetryButton     = $Window.FindName('RetryButton')
$ToCombo         = $Window.FindName('ToCombo')
$WakeButton      = $Window.FindName('WakeButton')
$ChatButton      = $Window.FindName('ChatButton')
$InputBox        = $Window.FindName('InputBox')
$SendButton      = $Window.FindName('SendButton')
$CharCountText   = $Window.FindName('CharCountText')

# ---------------------------------------------------------------------------
# 宛先ドロップダウンの初期化（ALL先頭＋AI_MEMBER_DIRECTORY.md登録順＋差分末尾補完）
# ---------------------------------------------------------------------------
function Initialize-ChatToCombo {
    $ToCombo.Items.Clear()

    $allItem = New-Object System.Windows.Controls.ComboBoxItem
    $allItem.Content = '全員（ALL）'
    $allItem.Tag = 'all'
    $ToCombo.Items.Add($allItem) | Out-Null

    $orderResult = Get-ChatAllRecipientTokens
    foreach ($w in $orderResult.Warnings) { Write-Host "[起動時警告] $w" }

    foreach ($token in $orderResult.Tokens) {
        $item = New-Object System.Windows.Controls.ComboBoxItem
        $item.Content = (Get-MemberDisplayName -Token $token)
        $item.Tag = $token
        $ToCombo.Items.Add($item) | Out-Null
    }
    $ToCombo.SelectedIndex = 0
}
Initialize-ChatToCombo

# ---------------------------------------------------------------------------
# 送信処理
# ---------------------------------------------------------------------------
function Invoke-ChatDeliver {
    <# iac-deliver.ps1 をサブプロセスとして実行する（NO_MAINガードが無いためdot-source禁止）。
       戻り値: @{ ExitCode; Output } #>
    param([string[]]$Paths)
    $deliverScript = Join-Path $Script:RepoRoot 'tools\iac-deliver.ps1'
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $deliverScript) + $Paths
    $outLog = [System.IO.Path]::GetTempFileName()
    $errLog = [System.IO.Path]::GetTempFileName()
    try {
        $proc = Start-Process -FilePath 'powershell.exe' -ArgumentList $argList -Wait -PassThru `
            -WindowStyle Hidden -RedirectStandardOutput $outLog -RedirectStandardError $errLog
        $output = (Get-Content -LiteralPath $outLog -Raw -ErrorAction SilentlyContinue) + "`n" + (Get-Content -LiteralPath $errLog -Raw -ErrorAction SilentlyContinue)
        return @{ ExitCode = $proc.ExitCode; Output = $output }
    } finally {
        Remove-Item -LiteralPath $outLog, $errLog -ErrorAction SilentlyContinue
    }
}

$Script:LastFailedPaths = @()

function Send-ChatMessage {
    if ($Script:ChatGitBusy) { return }
    $selectedItem = $ToCombo.SelectedItem
    if (-not $selectedItem) {
        [System.Windows.MessageBox]::Show('宛先を選択してください', 'IAC Chat') | Out-Null
        return
    }
    $text = $InputBox.Text.Trim()
    if (-not $text) { return }

    $Script:ChatGitBusy = $true
    $SendButton.IsEnabled = $false
    try {
        $token = $selectedItem.Tag
        $now = Get-Date
        $result = Build-ChatOutgoingHandoffs -RepoRoot $Script:RepoRoot -TargetToken $token -MessageText $text -Now $now
        Save-ChatOutgoingHandoffs -Items $result.Items

        $paths = @($result.Items | ForEach-Object { $_.FullPath })
        $deliverResult = Invoke-ChatDeliver -Paths $paths

        if ($deliverResult.ExitCode -eq 0) {
            $InputBox.Text = ''
            $CharCountText.Text = '0 / 300'
            $FailureBanner.Visibility = 'Collapsed'
            $Script:LastFailedPaths = @()
            foreach ($w in $result.Warnings) {
                Write-Host "[送信時警告] $w"
            }
        } else {
            $Script:LastFailedPaths = $paths
            $FailureBannerText.Text = "配送失敗。ローカルcommitは保持されています。詳細: $($deliverResult.Output.Trim())"
            $FailureBanner.Visibility = 'Visible'
        }
    } finally {
        $Script:ChatGitBusy = $false
        $SendButton.IsEnabled = $true
    }
}

$SendButton.Add_Click({ Send-ChatMessage })

$RetryButton.Add_Click({
    if ($Script:ChatGitBusy -or $Script:LastFailedPaths.Count -eq 0) { return }
    $Script:ChatGitBusy = $true
    try {
        $deliverResult = Invoke-ChatDeliver -Paths @()
        if ($deliverResult.ExitCode -eq 0) {
            $FailureBanner.Visibility = 'Collapsed'
            $Script:LastFailedPaths = @()
        } else {
            $FailureBannerText.Text = "再送信も失敗しました。詳細: $($deliverResult.Output.Trim())"
        }
    } finally {
        $Script:ChatGitBusy = $false
    }
})

$InputBox.Add_TextChanged({
    $len = $InputBox.Text.Length
    $CharCountText.Text = "$len / 300"
    if ($len -gt 300) {
        $CharCountText.Foreground = 'Red'
    } else {
        $CharCountText.Foreground = 'Gray'
    }
})

$Window.ShowDialog() | Out-Null
