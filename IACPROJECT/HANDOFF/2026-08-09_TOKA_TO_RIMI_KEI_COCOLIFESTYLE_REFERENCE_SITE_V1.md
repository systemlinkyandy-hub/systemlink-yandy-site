# HANDOFF

From: とーか（ChatGPT Codex）
To: りみ、ケイ
Task ID: IAC-COCOLOCAL-REF-001
Date: 2026-08-09
Routing: **DIRECT / NO ARC**

## Result

ローカル参照用静的サイトの初版を `cocolifestyle-reference/` に実装した。

- 4分類を色分け: 文献（青）、著者解釈（黄）、個人体験（緑）、未検証・適用注意（灰）
- キーワード、分類、原典照合状態で検索・絞り込み可能
- 各カードに対象集団、研究／情報種別、言える範囲、サイト記載、原典リンクを収録
- 原発性、中枢性、薬剤性副腎不全を別集団として明示
- 個人体験を一般的知見へ昇格させない表示
- 診療・服薬方針を生成しない注意表示

## Initial inventory

優先して確認したページ:

- ガイドライン2023年版
- しっかり補充の誤解
- 第5回大阪下垂体セミナー
- 回復の為にできる事
- 適度な運動の効果
- Journal（頓服化後の個人経過）

## Source checks

照合した主要原典:

- 日本内分泌学会「間脳下垂体機能障害と先天性腎性尿崩症および関連疾患の診療ガイドライン2023年版」
- Endocrine Society: Primary Adrenal Insufficiency guideline
- Endocrine Society: Hormone Replacement in Hypopituitarism guideline
- ESE / Endocrine Society: Glucocorticoid-Induced Adrenal Insufficiency guideline

判定上の重要点:

- 高用量回避の推奨を「少ないほど常に生命予後がよい」へ単純化することはできない。
- 原発性副腎不全の15〜25 mg/日という推奨量をACTH単独欠損症へそのまま適用できない。
- 中枢性副腎不全の最低耐容量という方針は、自己判断での減薬・中止を意味しない。
- 薬剤性HPA軸抑制の回復研究を、ACTH単独欠損症全般の回復可能性へ一般化できない。
- 「余分なコルチゾールは尿へ排出される」という説明は、CBG、血中濃度、受容体作用、代謝、尿中排泄を分けて一次研究まで追加照合する必要がある。

## Open items

- 全記事・全参考文献の棚卸しは未完。初版は判断上重要な代表ページに限定した。
- CBG、受容体飽和、尿中排泄の説明は部分照合。
- 運動時の追加投与に関する一般化は原典未照合。
- サイト本文の大量転載は行っていない。

## Run

`cocolifestyle-reference/README.md` の手順に従い、リポジトリ直下でローカルHTTPサーバーを起動する。

## Return route

本Handoffは、りみ／ケイへ直接返却する。アークは経由しない。
