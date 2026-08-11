# IAC Chat UI — iac-chat-ui

**Task ID**: IAC-CHAT-UI-001
**根拠**: 黒瀬起案・ケイ確定のHandoff（2026-08-11、複数人会話用チャットUIの新規実装依頼）。既存の
Handoff手動整形・commit・push作業を、チャット形式のローカルUIに集約する。
**実装**: 佐藤（Claude Code）。PowerShell + WPF。既存 `iac-handoff-lib.ps1` / `iac-console.ps1` /
`iac-deliver.ps1` を再利用。

## 起動方法

```
tools\iac-chat-ui.cmd
```

ダブルクリック起動、または `powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File tools\iac-chat-ui.ps1`。
MTA（PowerShell 7/pwsh）で起動された場合は自動的に`-STA`で自己再起動する。

## できること

- **宛先ドロップダウン**：`AI_MEMBER_DIRECTORY.md`登録順＋差分末尾補完で全メンバーを表示。先頭に「全員（ALL）」。
- **送信**：入力するとHandoff形式のMarkdownへ自動整形→`staging/`へ書き出し→`iac-deliver.ps1`を
  サブプロセス実行してcommit・pushまで自動化。送信内容は`## Required next action`セクションへそのまま
  入る（`iac-console wake`の転記元セクションと一致させ、追加セクション種別を新設しない設計）。
- **ALL送信**：1通の複数宛先Handoffにはせず、`AI_MEMBER_DIRECTORY.md`登録順に1人ずつ個別Handoffへ分解
  する。各Handoffの本文`To:`行は常に単一メンバー名のみ（誤配送防止ルールとの整合）。二葉（Gemini）宛は
  個別配送はされるが、Gemini Bridgeの自動処理対象（`inbox/from_arc`・`from_gemini`）には入らないため、
  実際に届けるには別途アークによる単一Packet工程が必要（UI上に注記あり）。
- **受信表示**：起動時に`IACPROJECT/inbox`配下を直近7日分フルスキャンして時系列表示。以降は90秒間隔
  （`IAC_CHAT_POLL_SECONDS`環境変数で上書き可）で`git pull --ff-only`＋diffベースの新着検知を行い、
  新着Handoffをそのまま吹き出しに追加する。宛先での絞り込みはしない（誰から誰宛かに関わらず全件表示）。
- **黒瀬提案文のコピー**：各メッセージ吹き出しの「コピー→入力欄へ」ボタンで、本文をクリップボードと
  入力欄の両方へ転記する。黒瀬（Claude）はこのUIから書き込めない（Fromは常に固定文字列「ケイ」）ため、
  黒瀬発Handoffの内容を見ながらケイが自分の指示として送る導線として使う。
- **wake**：単一メンバー選択時のみ活性（ALL・二葉は無効）。`iac-console.ps1 wake <token> -Push`を
  サブプロセス実行し、対象メンバー宛の起床パケットを生成・push する。
- **chat**：軽量な定型文を入力欄に挿入するだけ（Handoff化・配送は通常の送信フローに乗る）。

## 実装しないもの（要件でスコープ外と確定）

- 既読管理
- 返信スレッド化
- 通知音などの装飾機能
- 状態推論・Next AI自動判定・ACK管理（`iac-console`と同じ既存方針を踏襲）

## dot-source / サブプロセスの切り分け（実装上の注意）

| 呼び出し先 | 方式 | 理由 |
|---|---|---|
| `iac-handoff-lib.ps1` | dot-source | paramブロックなし。衝突リスクゼロ |
| `iac-console.ps1` | dot-source（`IAC_CONSOLE_NO_MAIN=1`で保護） | 受信表示のパース関数を毎回のポーリングで使うため |
| `iac-console.ps1 wake` | サブプロセス | 書き込みを伴う重い操作 |
| `iac-deliver.ps1` | サブプロセス（必須） | メイン処理にNO_MAINガードが無く、dot-sourceすると即座に配送処理が走るため |

新しいparamを追加する場合、または新しいdot-source関係を作る場合は`CLAUDE.md`「PowerShellツール
実装時の注意（dot-source変数名衝突）」に従うこと。

**`$Global:`スコープについて**：状態変数（`RepoRoot`, `ChatGitBusy`, `KnownRelPaths`, `ChatMessages`,
`LastFailedPaths`, `DeliverAction`, `SyncAction`, `PollSeconds`, `SyncTimer`）はすべて`$Global:`に
置いている。`.GetNewClosure()`で作った非同期処理の完了ハンドラの内部から`$Script:`スコープ変数を
参照すると、元のトップレベルスクリプトスコープとは別物として解決され「null値のメソッド呼び出し」
エラーになることを実機検証で確認したため（詳細は`iac-chat-ui.ps1`冒頭コメント）。このプロセスは
`iac-chat-ui.ps1`専用のSTAプロセスとして起動され他スクリプトと同居しないため、グローバル汚染の
リスクは実質的にない。

## 非同期処理

`git pull`・`iac-deliver.ps1`呼び出しはいずれも同期的なプロセス実行のためUIスレッドをブロックしうる。
`Invoke-ChatBackgroundAction`（バックグラウンドRunspace＋短周期`DispatcherTimer`によるポーリング）で
非同期化している。送信処理と定期同期は`$Global:ChatGitBusy`フラグで排他制御する。

## エラーハンドリング方針（既存ツール群の「止めない」思想を踏襲）

- Handoffパース失敗・必須項目欠落：例外を投げず警告バッジ表示のみで継続
- `iac-deliver.ps1`失敗：バナー表示＋再送信ボタン（ローカルcommit・stagingは保全される）
- `git pull --ff-only`失敗：警告表示のみ、自動rebase・自動マージはしない（人間判断が必要な異常系として扱う）

## 自己テスト

```
powershell -NoProfile -ExecutionPolicy Bypass -File tools\iac-chat-ui-selftest.ps1
```

人工fixture・一時ディレクトリのみを使い、実Handoff・staging・gitには一切触れない。
`iac-console.ps1`のparam名との衝突を静的にチェックする自己防御テストを含む。

## フォールバック手順

本ツールが壊れているときは、従来どおり`iac-console` / `iac-deliver` / 手動Markdown編集で運用する。
ツールの復旧を待ってケイの運用を止めない。復旧作業はHandoffで佐藤（Claude Code）へ依頼する。
