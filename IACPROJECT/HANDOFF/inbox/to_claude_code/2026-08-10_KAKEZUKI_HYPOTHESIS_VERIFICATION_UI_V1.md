# HANDOFF: Hypothesis Verification UI v1

**日時**: 2026-08-10 JST
**送信元**: 欠月
**宛先**: Claude Code
**対象プロジェクト**: ResidualCapacityWorkbench
**ローカルパス**: `C:\Users\NY\Desktop\IAC_PROJ_REF\ResidualCapacityWorkbench`
**状態**: READY_FOR_IMPLEMENTATION

## Goal
ケイ本人の実データを使い、症状イベントを中心に前後の負荷・環境・服薬を同じ時間窓で確認できる最小の仮説検証UIを作る。

これは因果関係を自動判定する機能ではない。観測を比較し、仮説を支持／反証する材料を人間が読める形にするUIである。

## Scope — v1 only
症状イベントを1件選択したとき、その時刻を中心に **±3時間** の時間窓へ切り替え、同じ窓内で以下を確認できるようにする。

- medication
- symptom / note
- pressure
- illuminance
- temperature
- humidity
- menstrual event

既存の Real Data import / Unified Timeline / provenance / GAP 表示を再利用すること。

## Minimum interaction
優先順：
1. 症状イベントを選択できる
2. 選択イベント時刻を中心に±3h表示へ移る
3. 選択中イベントを視覚的に識別できる
4. `Back to overview` などで全体表示へ戻れる

既存UIに安全に追加できるなら、`±3h / 24h / 3d` の時間窓プリセットまで可。ただし90分制約内で優先度は低い。

## Data integrity rules
- recorded timestamp と inferred timestamp を混同しない
- inferred medication time は既存 provenance を保持し、必要ならラベルで分かるようにする
- 欠測を補間しない。既存GAP表示を維持する
- heart_rate は実データ0件なので追加しない
- `tasks/counts` を時刻イベントに偽装しない
- 位置情報を表示しない
- 実データ本体をGitHubへcommitしない

## Do not implement today
- 3D身体モデル
- Similar Episodes変更
- 自動因果判定
- 相関係数／統計モデル
- AI要約・AI推論接続
- UI全面刷新
- 新規データソース

## Verification
実データで最低1件の症状イベントを選択し、±3h表示へ遷移できることを確認する。
その時間窓に存在する系列のみ表示し、データがない系列を作らない。

## Tests
既存テストを壊さないこと。選択イベント中心の時間窓計算、境界、overview復帰について可能な範囲でテスト追加。

## Timebox / Stop
**08:40 JSTで必ず停止。**
完成していなくても、その時点で：
- 現状を保存
- tests
- commit / push（安全な状態なら）
- 欠月宛Handoff

を行う。

## Return report
- 実装できたこと
- 実データでの確認結果
- 未完部分
- tests
- commit SHA
- 次に必要な1点だけ

ケイへの途中確認は原則不要。仕様矛盾・安全性問題で停止した場合のみ、アーク経由でエスカレーションする。
