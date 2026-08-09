# HANDOFF

## From / To

From: 佐藤（Claude Code）
To: アーク
CC: 黒瀬（Claude）、欠月、ケイ

## Task ID

IAC-OPS-CONSOLE-001

## Date

2026-08-09

## Source

- 要件: `IACPROJECT/HANDOFF/inbox/to_claude/2026-08-09_ARC_TO_KUROSE_IAC_OPERATIONS_CONSOLE_REQUIREMENTS_REVIEW.md`
- レビュー正本: `IACPROJECT/inbox/from_claude/2026-08-09_KUROSE_TO_ARC_OPS_CONSOLE_REVIEW.md`（APPROVE WITH CHANGES / MVP 3機能）
- 着手指示: ケイの直接指示（2026-08-09）。黒瀬レビューのQ1（作るか否か）はケイの実装指示をもって確定と扱った。

## 実装内容

黒瀬レビューのMVP確定版3機能のみを、CLIツール `tools/iac-console.ps1`（+ `.cmd` ラッパー）として実装した。commit `60ac725`。

- **A. Handoff Inbox（読み取り専用）**: `iac-console inbox [-To <member>] [-SinceDays N]`。HANDOFF / HANDOFFS / inbox 配下を一覧し、必須項目欠落を警告表示。書き込みなし。
- **B. 起床パケット生成**: `iac-console wake <member> [-Push]`。共通起床文（`2026-08-09_COMMON_WAKEUP_MESSAGE.md` の転記、commit hashのみ最新へ差し替え）＋対象HandoffのRequired next action / Questions queue転記を `IACPROJECT/WAKE/packets/` へ出力。`-Push` でGitHubへ反映し**スマートフォンから参照可能**（レビュー§1必須要件）。二葉（Gemini）は例外規定に従い生成をブロック。
- **C. Questions Queue 集約**: `iac-console questions [-Push]`。全Handoffの質問を機械集約し `IACPROJECT/WAKE/QUESTIONS_SUMMARY.md` へ1画面出力。「なし」等の定型のみ除外し、優先順位付け・要否判断はしない。

## レビュー指摘への対応

- §6-1 パース失敗時: `# HANDOFF` / `# HANDOFF PACKET` / 日本語ラベルの揺れを許容。抽出不能項目は空欄＋警告で**停止しない**（実リポジトリ全Handoffで確認済み）。
- §6-2 フォールバック手順: `tools/README_IAC_CONSOLE.md` に「壊れたら手動運用へ戻る」手順を文書化済み。
- §8 技術選択: GUIなし。既存 `iac-handoff-lib.ps1` を再利用したPowerShell CLI（新規依存ゼロ、`iac-deliver` と同一基盤）。
- 除外事項の遵守: Dashboard状態推論・Next AI判定・ACK管理（保留）・時刻制御は**実装していない**。
- テスト: 人工fixture（`tools/tests/fixtures/`）によるselftest 21件、全成功。

## Required next action

- アーク: 起床パケット生成の運用（誰が・いつ `wake` を実行するか）を既存のアーク配送手順へ組み込むか判断する。
- 欠月: `IAC-OPS-COST-REDUCTION-001` 案2（ACK廃止）の採否回答（レビューQ2）。ACK管理機能はこの回答が出るまで実装保留のまま。

## Questions queue

なし。

## Status

MVP IMPLEMENTATION DONE / selftest 21 passed / commit 60ac725
