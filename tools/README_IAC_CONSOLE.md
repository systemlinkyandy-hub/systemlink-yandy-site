# IAC Operations Console (MVP) — iac-console

**Task ID**: IAC-OPS-CONSOLE-001
**根拠**: `IACPROJECT/inbox/from_claude/2026-08-09_KUROSE_TO_ARC_OPS_CONSOLE_REVIEW.md`（黒瀬レビュー APPROVE WITH CHANGES）で確定したMVP 3機能のみを実装したCLIツール。
**実装**: 佐藤（Claude Code）、2026-08-09。PowerShell 5.1 / 既存 `iac-handoff-lib.ps1` を再利用。GUIなし（レビュー§8「GUIありきで進めない」に従う）。

## コマンド

リポジトリの `tools\` から実行する。

```
iac-console inbox [-To <member>] [-SinceDays N]
```
A. **Handoff Inbox（読み取り専用）**。`IACPROJECT/HANDOFF`・`IACPROJECT/HANDOFFS`・`IACPROJECT/inbox` 配下の全Handoffをパースし、Date / From / To / Task ID / パスを一覧表示する。必須項目（From / To / Task ID / Date / Required next action）の欠落は警告として表示する。**ファイルへの書き込みは一切行わない。**

```
iac-console wake <member> [-SinceDays N] [-Push]
```
B. **起床パケット生成**。指定メンバー宛のHandoff（既定: 過去7日、`to_` フォルダ名またはTo欄の一致のみで判定）を集め、以下を1ファイルにまとめて `IACPROJECT/WAKE/packets/YYYY-MM-DD_<MEMBER>_WAKE_PACKET.md` へ出力する。

- 共通起床文（`OPERATING_RULES/2026-08-09_COMMON_WAKEUP_MESSAGE.md` の転記。commit hashのみ最新へ差し替え）
- 最新commit hash
- 対象Handoffのパスと Required next action / Questions queue（**転記のみ・推論なし**）

`-Push` を付けるとcommit・pushまで行い、**スマートフォンからGitHub上の同パスで参照できる**（レビュー§1の必須要件）。

二葉（Gemini）はGitHub Pull前提にしない運用のため、本ツールでは生成せず、アークの単一Packet方式を使う。

```
iac-console questions [-SinceDays N] [-Push]
```
C. **Questions Queue 集約**。全HandoffのQuestions queueを抽出し、正規化後に同一の質問をまとめて `IACPROJECT/WAKE/QUESTIONS_SUMMARY.md` に1画面で出力する。優先順位付け・要否判断は行わない。

## 実装しないもの（レビューで除外・保留が確定）

- §1 Dashboard（8状態の可視化）— 状態推論を持たない
- §3 Next AI判定 — ルーティング権限をツールへ移さない
- §5 ACK管理 — `IAC-OPS-COST-REDUCTION-001` 案2（ACK廃止）の採否決定まで保留
- §8 時刻制御 — アプリ機能ではなく運用ルールとして扱う

## パース失敗時の挙動（レビュー§6-1）

Handoffフォーマットの揺れ（`# HANDOFF` / `# HANDOFF PACKET`、英語見出し / 日本語ラベル）を許容する。抽出できなかった項目は**空欄＋警告表示のまま処理を続行**し、エラーで停止しない。

## フォールバック手順（レビュー§6-2 — 必読）

**本ツールが壊れているときは、従来どおり手動で運用する。** ツールの復旧を待ってケイの運用を止めない。

1. **Handoff確認**: GitHub（またはローカル）で `IACPROJECT/inbox/` と `IACPROJECT/HANDOFF/inbox/to_<自分>/` を直接開いて読む。
2. **起床文**: `IACPROJECT/OPERATING_RULES/2026-08-09_COMMON_WAKEUP_MESSAGE.md` をそのままコピーし、commit hashを `git log -1` の値へ手で差し替えて使う。
3. **質問の確認**: 各Handoffの `Questions queue` 見出しを目視で確認する（`grep "Questions queue"` でも可）。
4. **配送**: `iac-deliver` は本ツールと独立しており、そのまま使える。
5. 復旧作業はHandoffで佐藤（Claude Code）へ依頼する。ケイが原因調査に入らない。

## 自己テスト

```
powershell -NoProfile -ExecutionPolicy Bypass -File tools\iac-console-selftest.ps1
```

人工fixture（`tools\tests\fixtures\`、実在の案件・体調情報を含まない）のみを使い、実Handoff・gitには触れない。
