# cocolifestyle research workspace

`cocolifestyle.net` に関する調査・検証素材の標準保存先です。

閲覧用成果物は [`../../cocolifestyle-reference/`](../../cocolifestyle-reference/) にあり、このディレクトリへ移動しません。

## Structure

- `sources/`: Webページ、論文、ガイドラインのメタデータと原典確認
- `comments/`: コメント、SNS・コミュニティ投稿。`raw/` と `classified/` を分離
- `analysis/`: 主張分類、原典照合、差分・適用範囲分析
- `handoff/`: りみ↔とーかの案件内作業メモと終了ログ

## Workflow

1. `comments/raw/` または `sources/` に取得元・取得日付きで保存する。
2. rawを変更せず、分類結果を `comments/classified/` に別ファイルで作る。
3. `analysis/` で主張と根拠、個人体験、解釈、未検証を分離する。
4. 閲覧価値が確定した内容だけを `cocolifestyle-reference/` に反映する。
5. 作業の受領・返却は `handoff/` とIACPROJECTの正式Handoffへ記録する。

## Evidence classes

- `literature`: 論文・ガイドラインで確認できる知見
- `interpretation`: 著者・投稿者の解釈や推論
- `experience`: 個人体験・自己観察
- `unresolved`: 未検証、出典不足、適用範囲注意

`experience` やコメントの件数・支持数を、研究エビデンスの強さへ自動変換しません。
