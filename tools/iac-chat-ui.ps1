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

状態変数（RepoRoot, ChatGitBusy, KnownRelPaths, ChatMessages, LastFailedPaths, DeliverAction,
SyncAction, PollSeconds, SyncTimer）はすべて $Global: スコープに置く。$Script: スコープ修飾子は
`.GetNewClosure()`で作られたスクリプトブロック（非同期処理の完了ハンドラ）の内部から参照すると、
元のトップレベルスクリプトスコープとは別物として解決され「null値のメソッド呼び出し」エラーになる
（実測で確認済みのPowerShellの既知の挙動）。このプロセスは iac-chat-ui.ps1 専用のSTAプロセスとして
起動され他スクリプトと同居しないため、グローバル汚染のリスクは実質的にない。
#>

# --- WPFはSTAスレッド必須。pwsh(PowerShell 7)はデフォルトMTAのため自己再起動で保証する ---
if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne [System.Threading.ApartmentState]::STA) {
    $argsForRestart = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-STA', '-File', $PSCommandPath)
    Start-Process -FilePath 'powershell.exe' -ArgumentList $argsForRestart
    exit 0
}

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase | Out-Null

$Global:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

$env:IAC_CONSOLE_NO_MAIN = '1'
try {
    . (Join-Path $PSScriptRoot 'iac-handoff-lib.ps1')
    . (Join-Path $PSScriptRoot 'iac-console.ps1')
} finally {
    $env:IAC_CONSOLE_NO_MAIN = ''
}
. (Join-Path $PSScriptRoot 'iac-chat-lib.ps1')

$Global:ChatGitBusy = $false
$Global:KnownRelPaths = New-Object 'System.Collections.Generic.HashSet[string]'

# ---------------------------------------------------------------------------
# 非同期実行ヘルパー
# git pull・iac-deliver呼び出しはいずれも同期的なプロセス実行のためUIスレッドをブロックしうる。
# バックグラウンドRunspaceで実行し、完了は短周期DispatcherTimerでポーリングしてUIスレッドへ戻す
# （DispatcherTimerのTickはUIスレッドで発火するため、Dispatcher.Invokeは不要）。
# ---------------------------------------------------------------------------
function Invoke-ChatBackgroundAction {
    param(
        [scriptblock]$Action,
        [object[]]$ArgumentList,
        [scriptblock]$OnComplete
    )
    $ps = [PowerShell]::Create()
    [void]$ps.AddScript($Action)
    foreach ($a in $ArgumentList) { [void]$ps.AddArgument($a) }
    $asyncResult = $ps.BeginInvoke()

    $watchTimer = New-Object System.Windows.Threading.DispatcherTimer
    $watchTimer.Interval = [TimeSpan]::FromMilliseconds(300)
    $watchTimer.Add_Tick({
        if (-not $asyncResult.IsCompleted) { return }
        $watchTimer.Stop()
        try {
            $result = $ps.EndInvoke($asyncResult)
        } finally {
            $ps.Dispose()
        }
        try {
            & $OnComplete $result
        } catch {
            # OnCompleteハンドラ内の未処理例外はDispatcherのメッセージポンプへ伝播すると
            # アプリ全体がクラッシュしうるため、ここで確実に捕捉してログに残すだけに留める
            # （既存ツール群の「止めない」設計思想を非同期処理でも踏襲する）。
            Write-Host "[エラー] 非同期処理の完了ハンドラで例外: $($_.Exception.Message)"
        }
    }.GetNewClosure())
    $watchTimer.Start()
}

# ---------------------------------------------------------------------------
# XAML読み込み
# ---------------------------------------------------------------------------
$xamlPath = Join-Path $PSScriptRoot 'iac-chat-ui.xaml'
[xml]$xamlDoc = Get-Content -LiteralPath $xamlPath -Raw -Encoding UTF8
$reader = New-Object System.Xml.XmlNodeReader $xamlDoc
$Window = [System.Windows.Markup.XamlReader]::Load($reader)

$MessageList     = $Window.FindName('MessageList')
$MessageScroll   = $Window.FindName('MessageScroll')
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
# 受信表示（起動時フルスキャン）
# ---------------------------------------------------------------------------
$Global:ChatMessages = New-Object System.Collections.ObjectModel.ObservableCollection[object]
$MessageList.ItemsSource = $Global:ChatMessages

function Initialize-ChatMessageList {
    $SyncStatusText.Text = '読込中...'
    $items = Get-ChatInitialMessages -RepoRoot $Global:RepoRoot -DaysBack 7
    foreach ($item in $items) { $Global:ChatMessages.Add($item) }
    if ($MessageScroll.Content) { $MessageScroll.ScrollToBottom() }
    $SyncStatusText.Text = "最終同期 $(Get-Date -Format 'HH:mm') JST（初期表示・直近7日分）"
}
Initialize-ChatMessageList

# 黒瀬提案文などの「コピー→入力欄へ」ボタンは各メッセージ吹き出しに複製されるため、
# 個別にFindNameでは取得できない。ItemsControlの親でClickイベントをバブリング捕捉する
# （WPFのRoutedEventはツリーを上へバブリングするため、親でAddHandlerすれば子孫のボタンも拾える）。
$MessageList.AddHandler(
    [System.Windows.Controls.Button]::ClickEvent,
    [System.Windows.RoutedEventHandler]{
        param($sender, $e)
        $source = $e.OriginalSource
        if ($source -isnot [System.Windows.Controls.Button]) { return }
        $msg = $source.Tag
        if (-not $msg) { return }
        $text = if ($msg.Body) { $msg.Body } else { '' }
        if (-not $text) { return }
        try { [System.Windows.Clipboard]::SetText($text) } catch { }
        $InputBox.Text = $text
        $InputBox.Focus() | Out-Null
    }
)

# ---------------------------------------------------------------------------
# 送信処理（非同期）
# ---------------------------------------------------------------------------
$Global:DeliverAction = {
    <# バックグラウンドRunspaceで実行。iac-deliver.ps1をサブプロセスとして呼ぶ
       （NO_MAINガードが無いためdot-source禁止）。 #>
    param([string[]]$Paths, [string]$DeliverScript)
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $DeliverScript) + $Paths
    $outLog = [System.IO.Path]::GetTempFileName()
    $errLog = [System.IO.Path]::GetTempFileName()
    try {
        $proc = Start-Process -FilePath 'powershell.exe' -ArgumentList $argList -Wait -PassThru `
            -WindowStyle Hidden -RedirectStandardOutput $outLog -RedirectStandardError $errLog
        $output = (Get-Content -LiteralPath $outLog -Raw -ErrorAction SilentlyContinue) + "`n" + (Get-Content -LiteralPath $errLog -Raw -ErrorAction SilentlyContinue)
        return [PSCustomObject]@{ ExitCode = $proc.ExitCode; Output = $output }
    } finally {
        Remove-Item -LiteralPath $outLog, $errLog -ErrorAction SilentlyContinue
    }
}

$Global:LastFailedPaths = @()

function Send-ChatMessage {
    if ($Global:ChatGitBusy) { return }
    $selectedItem = $ToCombo.SelectedItem
    if (-not $selectedItem) {
        [System.Windows.MessageBox]::Show('宛先を選択してください', 'IAC Chat') | Out-Null
        return
    }
    $text = $InputBox.Text.Trim()
    if (-not $text) { return }

    $Global:ChatGitBusy = $true
    $SendButton.IsEnabled = $false

    $token = $selectedItem.Tag
    $now = Get-Date
    $result = Build-ChatOutgoingHandoffs -RepoRoot $Global:RepoRoot -TargetToken $token -MessageText $text -Now $now
    Save-ChatOutgoingHandoffs -Items $result.Items
    foreach ($w in $result.Warnings) { Write-Host "[送信時警告] $w" }

    $paths = @($result.Items | ForEach-Object { $_.FullPath })
    $deliverScript = Join-Path $Global:RepoRoot 'tools\iac-deliver.ps1'
    # $paths（文字列配列）を1個の要素としてArgumentListに積む。@(...)で単純に並べると
    # 配列サブ式演算子がフラット化してしまい要素数がずれるため、単項カンマ演算子で明示的にラップする。
    $deliverArgs = (, $paths) + $deliverScript

    Invoke-ChatBackgroundAction -Action $Global:DeliverAction -ArgumentList $deliverArgs -OnComplete {
        param($results)
        $deliverResult = $results[0]
        try {
            if ($deliverResult.ExitCode -eq 0) {
                $InputBox.Text = ''
                $CharCountText.Text = '0 / 300'
                $FailureBanner.Visibility = 'Collapsed'
                $Global:LastFailedPaths = @()
                # 楽観的更新: 実際のpush確認（定期同期）を待たず、送信内容をその場でバブル表示する。
                # 対応するRelInboxPathを既知セットへ登録し、後続ポーリングで同じファイルを検知しても
                # 重複追加せず既知セットから外すだけにする（4.5節）。
                foreach ($item in $result.Items) {
                    $Global:KnownRelPaths.Add($item.RelInboxPath) | Out-Null
                    $msgItem = ConvertTo-ChatOutgoingMessageItem -OutgoingItem $item -Now $now -MessageText $text
                    $Global:ChatMessages.Add($msgItem)
                }
                if ($MessageScroll.Content) { $MessageScroll.ScrollToBottom() }
            } else {
                $Global:LastFailedPaths = $paths
                $FailureBannerText.Text = "配送失敗。ローカルcommitは保持されています。詳細: $($deliverResult.Output.Trim())"
                $FailureBanner.Visibility = 'Visible'
            }
        } finally {
            $Global:ChatGitBusy = $false
            $SendButton.IsEnabled = $true
        }
    }.GetNewClosure()
}

$SendButton.Add_Click({ Send-ChatMessage })

$RetryButton.Add_Click({
    if ($Global:ChatGitBusy -or $Global:LastFailedPaths.Count -eq 0) { return }
    $Global:ChatGitBusy = $true
    $RetryButton.IsEnabled = $false
    $retryArgs = (, [string[]]@()) + (Join-Path $Global:RepoRoot 'tools\iac-deliver.ps1')
    Invoke-ChatBackgroundAction -Action $Global:DeliverAction -ArgumentList $retryArgs -OnComplete {
        param($results)
        $deliverResult = $results[0]
        try {
            if ($deliverResult.ExitCode -eq 0) {
                $FailureBanner.Visibility = 'Collapsed'
                $Global:LastFailedPaths = @()
            } else {
                $FailureBannerText.Text = "再送信も失敗しました。詳細: $($deliverResult.Output.Trim())"
            }
        } finally {
            $Global:ChatGitBusy = $false
            $RetryButton.IsEnabled = $true
        }
    }.GetNewClosure()
})

# ---------------------------------------------------------------------------
# 定期同期（git pull + diffベースの新着検知）
# FileSystemWatcherは使わない（リモートpushは検知不可能、pull中の一時書き込みで誤発火するため）。
# ---------------------------------------------------------------------------
$Global:SyncAction = {
    param([string]$RepoRoot, [string]$LibPath)
    . $LibPath
    return Sync-ChatInboxFromRemote -RepoRoot $RepoRoot
}

function Start-ChatSync {
    if ($Global:ChatGitBusy) { return }
    $Global:ChatGitBusy = $true
    $SyncStatusText.Text = '同期中...'
    $libPath = Join-Path $PSScriptRoot 'iac-chat-lib.ps1'

    Invoke-ChatBackgroundAction -Action $Global:SyncAction -ArgumentList @($Global:RepoRoot, $libPath) -OnComplete {
        param($results)
        $syncResult = $results[0]
        try {
            $nowStr = Get-Date -Format 'HH:mm'
            if (-not $syncResult.Success) {
                $SyncStatusText.Text = "同期スキップ（ローカルに未push差分の疑い） $nowStr JST"
                return
            }
            if ($syncResult.Reason -eq 'no_change') {
                $SyncStatusText.Text = "最終同期 $nowStr JST"
                return
            }
            $added = 0
            foreach ($relPath in $syncResult.ChangedRelPaths) {
                if ($Global:KnownRelPaths.Contains($relPath)) {
                    # 自分が送信した分（楽観的更新で既に表示済み）。確認済みとして既知セットから外すのみ。
                    [void]$Global:KnownRelPaths.Remove($relPath)
                    continue
                }
                $fullPath = Join-Path $Global:RepoRoot ($relPath -replace '/', '\')
                if (-not (Test-Path -LiteralPath $fullPath)) { continue }
                $doc = Get-HandoffDocument -File (Get-Item -LiteralPath $fullPath) -RepoRoot $Global:RepoRoot
                $item = ConvertTo-ChatMessageItem -Doc $doc
                $Global:ChatMessages.Add($item)
                $added++
            }
            if ($added -gt 0 -and $MessageScroll.Content) { $MessageScroll.ScrollToBottom() }
            $SyncStatusText.Text = "最終同期 $nowStr JST"
        } catch {
            $SyncStatusText.Text = "同期失敗 $(Get-Date -Format 'HH:mm') JST"
        } finally {
            $Global:ChatGitBusy = $false
        }
    }.GetNewClosure()
}

$Global:PollSeconds = if ($env:IAC_CHAT_POLL_SECONDS) { [int]$env:IAC_CHAT_POLL_SECONDS } else { 90 }
$Global:SyncTimer = New-Object System.Windows.Threading.DispatcherTimer
$Global:SyncTimer.Interval = [TimeSpan]::FromSeconds($Global:PollSeconds)
$Global:SyncTimer.Add_Tick({ Start-ChatSync })
$Global:SyncTimer.Start()

$ResyncButton.Add_Click({ Start-ChatSync })

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
