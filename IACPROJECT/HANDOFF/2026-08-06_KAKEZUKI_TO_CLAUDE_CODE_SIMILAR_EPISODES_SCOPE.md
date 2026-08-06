# HANDOFF: Similar Episodes 現状確認と実装範囲固定

送信元：欠月
宛先：Claude Code
日付：2026-08-06
状態：READY_FOR_CLAUDE_CODE

---

## 対象プロジェクト

Residual Capacity Workbench

## 対象ローカルパス

`C:\Users\NY\Desktop\IAC_PROJ_REF\ResidualCapacityWorkbench`

## 終了条件

本日16:00で停止する。
16:00時点で未完了でも、作業を広げず、その時点の成果をコミット・pushし、Handoffを返す。

## 対象Node

`Similar Episodes`

## 本日の目的

既存実装を調査し、現状と未実装を分離し、次回の実装範囲を一つに固定する。
新規機能実装は行わない。

## 作成物

`docs/design/SIMILAR_EPISODES_CURRENT_SCOPE_2026-08-06.md`

`docs/design/` が存在しない場合は新設してよい。

## 記載項目

1. 現在の実装
2. 入力データ
3. 比較条件
4. 画面出力
5. 未実装点
6. 今回の実装対象候補
7. 今回は対象外
8. 次の候補
9. 判断が必要な点

## 主な確認対象

- `app/widgets/body_systems/similar_episodes_panel.py`
- 関連モデル
- データアクセス層
- 関連テスト
- `README.md`
- `CLAUDE.md`
- `docs/ARCHITECTURE.md`
- `docs/DATA_MODEL.md`
- `docs/UI_SPEC.md`
- `docs/BODY_SYSTEMS_SPEC.md`
- `docs/manual/ResidualCapacityWorkbench_Public_Manual_2026-08-03.md`

存在しない資料は「存在しない」と記録し、一般知識で補完しない。

## 禁止

- AI連携実装
- 新しい比較アルゴリズムの実装
- UI全面改修
- 新規Node着手
- サーバー化
- 暗号化実装
- SQLite実データのコミット
- `systemlink-yandy-site` へのRCWコード混入
- SNS作業
- 別リポジトリ操作
- 作業範囲の拡大

## 完了条件

- 設計資料を作成
- 現状と未実装を明確に分離
- 次回実装範囲を一つに絞る
- RCWのPrivateリポジトリへコミット・push
- 16:00で停止
- GitHub Handoffで欠月へ返却

## ケイ確認

途中確認は不要。
最終確認は1回だけ。
ケイを伝令役にしない。
