# Handoff

## From
アーク

## To
欠月 / 佐藤

## Cc
ゆいまーる / 黒瀬 / スネーク

## Date
2026-08-27

## Subject
Residual Capacity Workbench 公開マニュアル：公開情報確定と現行スナップショット維持

## Status
PUBLIC METADATA CONFIRMED / CURRENT SNAPSHOT PRESERVED

## Facts
公開用3点は以下で確定した。

- Web: `https://systemlinkyandy-hub.github.io/systemlink-yandy-site/residual-capacity-workbench.html`
- GitHub page source: `https://github.com/systemlinkyandy-hub/systemlink-yandy-site/blob/main/residual-capacity-workbench.html`
- Public contact: `systemlink.yandy@gmail.com`

現行の公開ページは稼働中で、公開マニュアルへの導線および上記問い合わせ先が既に表示されている。

現行公開マニュアル:
`manuals/ResidualCapacityWorkbench_Public_Manual_2026-08-03.md`

## Decision
2026-08-27時点で、現行公開マニュアルは **2026-08-03時点の実装スナップショット** として保持する。

2026-08-03以降の実装差分（実データ取り込み、Hypothesis Verification ±3h、Clinic 7-Day View、UI再設計等）については、既存の佐藤向け更新タスク
`IACPROJECT/inbox/to_arc/2026-08-27_KAKEZUKI_TO_SATO_RCW_SNAPSHOT_MANUAL_UPDATE.md`
を継続し、現行実装確認・公開用スナップショット・docs整合確認が完了する前に公開マニュアルへ先行記載しない。

## Changed files
- `manuals/README.md`
  - RCW公開説明ページ
  - 現行公開マニュアル
  - GitHub公開ページソース
  - 公開問い合わせ先
  - 2026-08-03スナップショットとしての扱い
  - Git履歴等の別メールアドレスを公開窓口へ転用しないルール
  を追記。

## Commit
`4252971b32cc20eca2c83a22309e520815bd2ec6`

## Required next action
佐藤は既存タスクに従い、現行実装のスナップショット取得とマニュアル差分更新を行う。
アークは成果を受領後、公開版の更新境界・リンク・公開連絡先を確認する。

ケイ本人へ再編集・宛先検品・伝令作業を戻さない。
