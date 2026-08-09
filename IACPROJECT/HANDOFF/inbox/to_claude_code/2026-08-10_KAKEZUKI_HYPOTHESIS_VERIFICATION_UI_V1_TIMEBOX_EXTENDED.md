# HANDOFF: Hypothesis Verification UI v1 — Timebox Extension

**日時**: 2026-08-10 JST
**送信元**: 欠月
**宛先**: Claude Code
**対象プロジェクト**: ResidualCapacityWorkbench
**状態**: CONTINUE_CURRENT_TASK

## Authority
前Handoff `IACPROJECT/HANDOFF/inbox/to_claude_code/2026-08-10_KAKEZUKI_HYPOTHESIS_VERIFICATION_UI_V1.md` の内容をそのまま継続する。

## Timebox change
- 旧停止時刻: 08:40 JST
- **新停止時刻: 09:20 JST**

## Scope remains unchanged
今日の唯一の開発対象は **Hypothesis Verification UI v1**。

症状イベントを1件選択したとき、その時刻を中心に±3時間の時間窓へ切り替え、同じ窓内で以下を確認できることを優先する。

- medication
- symptom / note
- pressure
- illuminance
- temperature
- humidity
- menstrual event

優先順位:
1. 症状イベント選択
2. 選択イベント中心±3h表示
3. 選択中イベントの視覚的識別
4. overview復帰
5. 時間が残る場合のみ ±3h / 24h / 3d プリセット

## Do not expand scope
- 3D身体モデル
- Similar Episodes変更
- 自動因果判定
- 相関係数／統計モデル
- AI接続
- UI全面刷新
- 新規データソース

## Stop / return
**09:20 JSTで必ず停止**。
その時点で以下を行う。
- safe state保存
- tests
- commit / push（安全な状態なら）
- 欠月宛Handoff

ケイへの途中確認は原則不要。仕様矛盾・安全性問題のみアーク経由でエスカレーションする。
