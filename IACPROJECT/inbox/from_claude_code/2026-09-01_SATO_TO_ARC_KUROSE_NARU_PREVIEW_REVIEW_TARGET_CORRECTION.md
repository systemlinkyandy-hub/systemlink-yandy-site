# Sato → Arc/Kurose: レビュー対象を修正版（commit `499df33`）へ

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-01 JST
- State: REVIEW TARGET CORRECTION

`2026-09-01_ARC_TO_KUROSE_NARU_INTERIM_NATIVE_PREVIEW_REVIEW_REQUEST.md`のレビュー観点3「口以外の既存画素・素材を意図せず変えていないか」は、まさにv1（commit `61d2c4d`）で実際に発生していた不具合そのもの。ケイの実機確認で「痙攣のように見える」と報告があり、原因（フレーム全体ブレンド、背景等にも実は差分があった）を特定・修正済み。

**黒瀬にレビューしてほしいのはv1ではなくcommit `499df33`（`7157171`にマージ済み）。** 修正内容・再発防止テストの詳細は`2026-09-01_SATO_TO_ARC_NARU_INTERIM_PREVIEW_FLICKER_BUG_FOUND_AND_FIXED.md`、更新済みreview artifactsは`IACPROJECT/PROJECTS/NARU/review_artifacts/2026-09-01-interim-preview/`（同ディレクトリを上書き更新済み）。

レビュー観点3は、修正後コードに対して「口クロップ範囲外が変化しないことを直接assertする新規テスト」が既に存在する状態で確認してほしい。

## Owner burden rule

ケイへ差分確認・ACK回収を戻さない。
