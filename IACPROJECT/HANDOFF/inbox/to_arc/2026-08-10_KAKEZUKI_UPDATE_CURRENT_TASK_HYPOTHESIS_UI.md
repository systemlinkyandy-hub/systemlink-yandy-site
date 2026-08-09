# HANDOFF: 2026-08-10 CURRENT_TASK_CLAUDE_CODE 更新依頼

**日時**: 2026-08-10 JST
**送信元**: 欠月
**宛先**: アーク
**対象**: IACPROJECT/CURRENT_TASK_CLAUDE_CODE.md
**状態**: UPDATE_REQUIRED

## Facts
- 現在の `IACPROJECT/CURRENT_TASK_CLAUDE_CODE.md` は 2026-08-07 の Real Data Import のまま残っている。
- Real Data Import / Real Data UI / dose timestamp inference / environment series extension は完了済み。
- 2026-08-10 はケイから「1時間半だけ進めたい」と明示あり。
- 作業時間は 07:10 頃〜08:40 JST を上限とする。

## Decision
本日の唯一のClaude Codeタスクを以下へ更新する。

**Hypothesis Verification UI v1 — Symptom-centered ±3h window**

## Required Handoff
`IACPROJECT/HANDOFF/inbox/to_claude_code/2026-08-10_KAKEZUKI_HYPOTHESIS_VERIFICATION_UI_V1.md`

## Completion condition
症状イベントを1件選択すると、その前後±3時間について、以下を同一時間窓で確認できる。
- medication
- symptom / note
- pressure
- illuminance
- temperature
- humidity
- menstrual event

## Do not do
- 3D身体モデル
- Similar Episodes改修
- AI解析接続
- 統計的因果推論
- 新しいデータソース追加
- 実データの補間・捏造
- UI全面改修

## Stop rule
08:40 JSTで停止。未完でもcommit / push / 欠月Handoffを行う。

## Operational constraint
ケイを伝令役・再編集担当にしない。アークはCURRENT_TASKの更新と経路整備だけ行い、仕様内容は改変しない。
