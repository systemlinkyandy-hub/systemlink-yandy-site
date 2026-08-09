# HANDOFF

From: とーか（ChatGPT Codex）
To: りみ、ケイ
Task ID: IAC-COCOLOCAL-REF-001
Date: 2026-08-09
Routing: **DIRECT / NO ARC**
Status: **V2実装完了**

## Result

- 既存8件へ `sourceTitle`、`sourceYear`、`sourceLocator`、`siteLocator`、`checkedAt`、`verificationNote`、`sourceRelation` を追加。
- `sourceRelation` を直接根拠／関連資料／候補資料としてUI表示。
- 病型・病因を `etiology` として構造化し、原発性、中枢性、薬剤性、原因不明、混合集団、個人事例で検索可能にした。
- 個人体験カードは、サイト本文との記載照合を `verified` としつつ、医学的一般化不可を明記。
- `pages/audit.html` に出典・照合ログを追加。
- READMEへV2範囲、追加照合結果、変更履歴を追加。

## Additional verification

### CBG・尿中排泄

一次研究（PMID 29795974）は、20 mg経口ヒドロコルチゾンが完全吸収され、CBG結合が飽和性であることを示す。これは「余剰分が単純に尿へ排出される」「余剰投与が無害」という説明を支持しない。受容体飽和値の主張は引き続き未確認。

### 運動前追加

RCT（PMID 26494876）では、女性Addison病10人に短時間高強度運動の1時間前10 mgを追加しても、運動能力上の利益はなかった。ただし小規模・原発性・短時間高強度という条件であり、中枢性副腎不全、日常運動、2時間超の長時間運動へ一般化できない。

### 回復可能性

2024年ESE/Endocrine Societyガイドラインは薬剤性HPA軸抑制の回復と評価法を扱う。原因不明の中枢性副腎不全やACTH単独欠損症の回復可能性への直接根拠ではない。

## Remaining open items

- 受容体飽和16〜18 µg/dLという数値の一次根拠。
- 全記事・全参考文献の棚卸し。
- 原典本文へアクセスできない引用のページ単位照合。
- 運動条件別のデータ拡充。

## Return route

りみ／ケイへ直接返却。アークは経由しない。
