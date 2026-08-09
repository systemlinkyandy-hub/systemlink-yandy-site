# HANDOFF: 直近7日・柳瀬先生提示用ビューを最優先

**日時**: 2026-08-10 JST
**送信元**: 欠月
**宛先**: Claude Code
**対象**: ResidualCapacityWorkbench
**状態**: PRIORITY_OVERRIDE

## 優先順位変更
本日の最優先は Hypothesis Verification UI v1 ではなく、**直近7日分の実データを柳瀬先生にその場で提示できる、読みやすい臨床説明用ビューの実装**とする。

Hypothesis Verification UI v1 は、この7日ビューが完成し、09:20 JSTまでに余裕がある場合のみ続行可。

## Goal
直近7日について、ケイ本人の実データを人間が短時間で読める密度に整理する。

最低限、同じ時間軸上で以下を確認できること。
- medication
- symptom / note
- pressure
- illuminance
- temperature
- humidity
- menstrual event

## 表示要件
- 期間は「最新データ日時を終点とする直近7日」を基本にする。
- 7日表示をワンクリック／明示操作で出せること（例: `7D` プリセット）。
- 日ごとの境界が視認できること。
- 症状イベントが密集しても潰れすぎないこと。必要ならイベントレーン高さ、間引かないラベル戦略、hover/detailなど既存UIに安全な範囲で工夫する。
- medication は2件でも明確に識別できること。推定時刻は provenance を維持。
- pressure / illuminance / temperature / humidity は7日範囲で変化が読める縦スケールにする。
- 欠測はGAPとして残す。補間しない。
- 位置情報は表示しない。
- heart_rate は実データ0件のため出さない。
- `tasks/counts` は時刻イベント化しない。

## 柳瀬先生提示を意識した可読性
- 初見の第三者が30秒程度で「何を記録しているか」「いつ症状が起きたか」「その周囲の環境・服薬」が読めることを優先。
- 既存の研究者向け情報を削除する必要はないが、7日ビューでは主要系列を優先して視覚ノイズを減らす。
- 因果関係を自動断定する表示はしない。

## Verification
- 実データで直近7日表示を開く。
- medication / symptoms / pressure / illuminance / temperature / humidity のうち存在する系列が読めることを確認。
- スクリーンショットを1枚保存できるなら保存する（実データ自体はcommitしない）。

## Do not do
- 3D身体モデル
- AI接続
- 自動因果判定
- 統計モデル追加
- Similar Episodes改修
- UI全面刷新

## Timebox
**09:20 JSTで停止。**
その時点で tests / commit / push / 欠月宛Handoff。

## Return report
- 7日ビューの実装内容
- 実データでの確認結果
- 可読性上残る問題
- tests
- commit SHA
- 次に必要な1点
