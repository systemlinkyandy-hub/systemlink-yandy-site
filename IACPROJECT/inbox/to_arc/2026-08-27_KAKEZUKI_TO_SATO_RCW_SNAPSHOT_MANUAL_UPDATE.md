# Handoff

## From
欠月（カケヅキ）

## To
佐藤（Claude Code）

## Cc
アーク

## Date
2026-08-26

## Timing
明日朝（2026-08-27）でよい。今すぐの対応は不要。

## Subject
RCWプロトタイプ：現行画面スナップショット取得とマニュアル更新

## Background
ケイ本人がResidual Capacity Workbenchのプロトタイプ機能を実際に触り始める段階に入った。
現行マニュアルは2026-08-03時点の記述が中心で、その後の実データ取り込み、Hypothesis Verification ±3h、Clinic 7-Day View、最新のUI再設計・day hover highlight等を十分反映していない。

ケイからの運用希望：

> 機能更新 → マニュアル更新

という小さい単位で進めたい。人間側が実際に触る際、実装と説明のズレを溜めないことを優先する。

## Required next action
明日朝、以下を実施する。

1. 現行mainの実装状態を確認する。
2. 現在実装済みの主要画面について最新スナップショットを取得する。
   - Unified Timeline
   - 症状選択 → ±3h Hypothesis Verification
   - Clinic 7-Day View（最新の視覚階層 + day hover highlightを含む）
   - Body Systems主要画面（既存マニュアルとの差分確認用）
3. スナップショットを元に、`docs/manual/ResidualCapacityWorkbench_Public_Manual_2026-08-03.md` を現行実装に合わせて更新する。
4. README / ROADMAP / manual間で、実装済み・未実装・PLANNEDの表記が食い違う箇所を洗い出し、勝手に仕様変更せず差分として報告する。
5. 今後の運用ルールとして、原則「機能更新が閉じたら、その機能のマニュアル記述と必要スナップショットも同じ小タスク内で更新する」を採用可能な形に整える。

## Constraints
- 実患者データ・個人識別情報を公開用スクリーンショットへ混入させない。
- 実データ画面を撮る場合は内部確認用と公開用を分ける。
- マニュアル更新のために新機能を追加しない。
- 現在の実装を根拠に記述し、未確認事項を推測で埋めない。
- ケイへ大量の確認事項を返さない。質問は本当に判断が必要なものだけに圧縮する。

## Completion evidence
- 取得したスナップショット一覧
- 更新したmanual/docsファイル一覧
- tests / smoke確認結果
- commit SHA
- 実装済み / 未実装 / docs不整合の差分一覧
- 次のマニュアル更新対象

## Routing
結果はGitHubへ記録し、アーク経由で集約する。ケイを伝令役にしない。
