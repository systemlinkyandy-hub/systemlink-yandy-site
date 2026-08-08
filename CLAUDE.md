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

黒瀬（Claude）／二葉（Gemini）／スネーク（Grok）／佐藤（Claude Code）。ChatGPT Codexは呼称未確定（仮名を付けない）。
ClaudeとClaude Codeは別担当。自分は佐藤＝Claude Code（実装・Git担当）。

## 禁止事項

- `CURRENT_PENDING.md` の per-member 状態を独断更新しない（一時代理スネークまたはアークの担当）
- アーク権限復帰・閾値アルゴリズム・Codex呼称を独断確定しない
- 実データ（health_log等）をGitHubへコミットしない
- ケイをAI間の伝令役にしない
