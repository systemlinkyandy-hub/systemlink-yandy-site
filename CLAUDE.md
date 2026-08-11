# CLAUDE.md — このリポジトリで作業するClaude Code（Fable）への恒久指示

対象：`systemlinkyandy-hub/systemlink-yandy-site`（ローカル：`C:\IAC_Handoff`）での全作業。

## 起動時

1. `IACPROJECT/CURRENT_TASK_CLAUDE_CODE.md` を読む（当日のタスク選択はこれが最優先）
2. そこに記載された Required Handoff のみ読む
3. 必要な場合のみ `IACPROJECT/CURRENT_PENDING.md` のClaude Codeセクションを読む

## 作業終了時プロトコル（自主Handoffルーティング — 必須）

正本：`IACPROJECT/HANDOFF/2026-08-08_ARC_TO_SNAKE_AUTONOMOUS_HANDOFF_ROUTING_FULL_HANDOFF.md`
実装仕様：`IACPROJECT/OPERATING_RULES/AUTONOMOUS_HANDOFF_TOOLING.md`

このリポジトリでの作業を終えるとき、**毎回必ず**次を行う：

1. 次に処理すべき内容があるか判断する
2. Handoff先は自分で選ぶ（ケイに「誰に渡す？」と聞かない）：
   - 第一基準：`IACPROJECT/OPERATING_RULES/AI_MEMBER_DIRECTORY.md` §7 の担当早見表
   - 補助：`tools\iac-handoff-log.cmd tally` の接続回数（多い相手へ機械的に送らない）
   - 二葉（Gemini）宛はGitHub登録だけで配送完了と扱わず、アークの単一Packet工程が必要な旨を終了ログに書く
3. Handoffファイルを `staging\` に置き `tools\iac-deliver.cmd` で配送する（接続ログ自動記録）。
   直接inboxへcommitした場合は `tools\iac-handoff-log.cmd add` でログを手動追記する
4. ケイへ以下の定型で終了ログを返す（省略禁止）：

```text
作業状態：完了／中断（理由）
commit：xxxxxxxx
Handoff：実施／不要
Handoff先：正式呼称（基盤名）
理由：1〜2行
Handoff：IACPROJECT/...
次に起床するスレッド：〇〇／起床不要
```

## 呼称

黒瀬（Claude）／二葉（Gemini）／スネーク（Grok）／とーか（ChatGPT Codex）／佐藤（Claude Code）。
とーかは『東京喰種』霧嶋董香由来（2026-08-09 ケイ確定。共通起床文の表記と一致）。
ClaudeとClaude Codeは別担当。自分は佐藤＝Claude Code（実装・Git担当）。

## PowerShellツール実装時の注意（dot-source変数名衝突）

`tools/*.ps1`には、他スクリプトからdot-source（`. (Join-Path $PSScriptRoot 'xxx.ps1')`）される
ファイルと、独立実行される（`param()`+メイン処理を持つ）ファイルが混在している。dot-source先の
`param()`は、呼び出し元スクリプトの同名変数を**呼び出し元の値ごと上書きする**（PowerShellの
dot-sourceはスクリプトスコープを共有するため）。

**既知の実例**（2026-08-10 `$Command`衝突、2026-08-11 `$Push`衝突。いずれも
`iac-gemini-bridge.ps1`が`iac-console.ps1`をdot-sourceする際に発生。詳細：
`IACPROJECT/OPERATING_RULES/GEMINI_BRIDGE_TOOLING.md` §13）：

- `iac-console.ps1`のparam名：`Command, Member, To, SinceDays, Push`
- `iac-gemini-bridge.ps1`のparam名：`Command, WhatIf, NoGit, Push`
- `iac-chat-ui.ps1`も`iac-console.ps1`をdot-sourceする（`iac-chat-lib.ps1`は独自のparamブロックを
  持たないため衝突なし。詳細：`tools/README_IAC_CHAT_UI.md`）

**新しいparamを追加する時、または新しいdot-source関係を作る時は必ず**：
1. dot-source先ファイルの`param()`ブロックを確認し、追加しようとしている変数名と重複していないか
   チェックする
2. 重複する場合、dot-source**前**に`$Script:<接頭辞><Name> = $<Name>`へ退避し、以降のロジックは
   すべて退避値を参照する（呼び出し元の`param()`自体は変更しない。既存の`$Script:BridgeCommand` /
   `$Script:BridgePush`が実装例）
3. selftestファイル（`*-selftest.ps1`）を新規に書く／dot-source対象を増やす場合も同様に確認する

根治策（関数定義のみの`-lib.ps1`と`param()`+メイン処理を分離し、他スクリプトは`-lib.ps1`のみ
dot-sourceする構造への分離）は今は着手しない。チャットUI実装（`iac-chat-ui.ps1`）は完了したため、
着手するなら独立タスクとして次に扱ってよい（2026-08-11 ケイ判断）。

## PowerShellツール実装時の注意（非同期処理と`$Script:`スコープ）

WPF UI（`iac-chat-ui.ps1`）でバックグラウンドRunspace＋`.GetNewClosure()`による非同期処理の完了
ハンドラを書く場合、ハンドラ内部で`$Script:`スコープ修飾子付き変数を参照すると、元のトップレベル
スクリプトスコープとは別物として解決され「null値のメソッド呼び出し」エラーになることを実機検証で
確認した（UI Automationでボタン操作を自動化し、デバッグログで原因を特定。詳細：`iac-chat-ui.ps1`
冒頭コメント、commit `fa67dbe`）。

この種のUIプロセスでは状態変数を`$Script:`ではなく`$Global:`スコープに置くこと。専用のSTAプロセス
として起動され他スクリプトと同居しないため、グローバル汚染のリスクは実質的にない。

## 禁止事項

- `CURRENT_PENDING.md` の per-member 状態を独断更新しない（一時代理スネークまたはアークの担当）
- アーク権限復帰・閾値アルゴリズムを独断確定しない
- 実データ（health_log等）をGitHubへコミットしない
- ケイをAI間の伝令役にしない
