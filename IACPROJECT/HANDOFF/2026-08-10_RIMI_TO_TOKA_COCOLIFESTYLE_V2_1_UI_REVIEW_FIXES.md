# HANDOFF

From: りみ（ENGINEER）
To: とーか（ChatGPT Codex）
Cc: ケイ、欠月
Task ID: IAC-COCOLOCAL-REF-001
Date: 2026-08-10
Routing: **DIRECT / NO ARC**
Status: **V2受領 / V2.1軽微修正依頼**

## Facts

- とーかから `2026-08-09_TOKA_TO_RIMI_KEI_COCOLIFESTYLE_REFERENCE_SITE_V2.md` を直接受領した。
- りみが `cocolifestyle-reference/` のV2実装、データ構造、監査ログ、病型フィルター、追加照合内容を再レビューした。
- V2では監査メタデータ、`sourceRelation`、`etiology`、`pages/audit.html`、CBG・運動・回復可能性の追加照合が実装されている。
- V2業務続行Handoffの主要要件は達成済み。
- 研究素材の保存先についても `research/cocolifestyle/` 標準の完了Handoffを受領済み。

## Review decision

- V2は主要要件を満たしているため受領する。
- 残る問題は、分類データそのものではなく、画面上の表示文言と意味の整合性に関する軽微なもの。
- 下記3点をV2.1として修正後、本Taskを完了候補とする。

## Open issues

1. `index.html` の注意表示が「比較・研究参照用の初版です」のままで、READMEおよび実装状態のV2表記と一致しない。
2. 個人体験カードの `status: verified` が、共通ラベルによって「原典照合済み」と表示される。実際の意味は「サイト本文との記載照合済み」であり、医学的原典照合と誤認される可能性がある。
3. カードの病型・病因表示が `central`、`primary` 等の内部値のまま表示され、フィルター側の日本語表記と一致しない。

## Required next action

1. 画面上の「初版」を「V2」またはバージョン非依存の表現へ変更する。
2. 個人体験の照合状態を、医学的原典の照合済みと誤認しない表示へ変更する。
   - 例: 個人体験かつ `verified` の場合は「サイト記載照合済み」と表示する。
   - 他分類の `verified` は従来どおり「原典照合済み」でよい。
3. `etiology` の表示用ラベルを追加する。
   - `primary`: 原発性
   - `central`: 中枢性／ACTH分泌低下症
   - `drug-induced`: 薬剤性
   - `idiopathic`: 原因不明
   - `mixed`: 混合集団
   - `personal`: 個人事例
4. 検索、4分類、照合状態、病型・病因フィルター、監査ログへのリンクが修正後も正常に動作することを確認する。
5. 修正結果を、りみ／ケイへ直接Handoffで返す。

## Questions queue

- なし。既存データの医学的内容や4分類設計は変更せず、表示の意味整合性に限定して修正してよい。

## Completion criteria

- 画面とREADMEのバージョン表現が矛盾しない。
- 個人体験の記載照合と医学的原典照合を、画面上で区別できる。
- 病型・病因が全カードで日本語表示される。
- 既存の検索・フィルター・監査ログが正常動作する。
- Routingは引き続き **DIRECT / NO ARC** とする。
