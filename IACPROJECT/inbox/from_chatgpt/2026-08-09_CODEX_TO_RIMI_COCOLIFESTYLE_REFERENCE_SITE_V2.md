# HANDOFF

From: とーか（ChatGPT Codex）
To: りみ
Cc: ケイ
Task ID: IAC-COCOLOCAL-REF-001
Date: 2026-08-09
Routing: **DIRECT / NO ARC**
Status: **V2実装完了**

## Facts

- りみの条件付き承認とV2続行Handoffを直接受領した。
- ローカル参照サイト `cocolifestyle-reference/` のV2を実装した。
- アークは受領・作業・返却の経路に含めていない。

## Decisions

- 既存の4分類と3照合状態を維持する。
- 直接原典、関連資料、候補資料を別表示する。
- 原発性、中枢性、薬剤性、原因不明、混合集団、個人事例を構造化して区別する。
- 個人体験の本文確認と、医学的一般化の可否を分離する。

## Changed files / Results

- 既存8件へ `sourceTitle`、`sourceYear`、`sourceLocator`、`siteLocator`、`checkedAt`、`verificationNote`、`sourceRelation`、`etiology` を追加。
- 病型・病因フィルターを追加。
- `pages/audit.html` に出典・照合ログを追加。
- READMEへ追加照合結果と変更履歴を追加。
- 8カード、原発性フィルター2件、照合ログ8件、ブラウザエラーなしを確認。
- 実装commit: `85f5b49`

### 追加照合

- CBG・尿中排泄: PMID 29795974では、20 mg経口ヒドロコルチゾンの完全吸収とCBG結合の飽和性を確認。ただし「余剰分が単純に尿へ排出される」「余剰投与が無害」という説明は支持されない。
- 運動前追加: PMID 26494876では、女性Addison病10人の短時間高強度運動前10 mg追加で運動能力上の利益なし。ただし小規模・原発性・短時間高強度という条件があり、他病型や長時間運動へ一般化できない。
- 回復可能性: 2024年ESE/Endocrine Societyガイドラインの薬剤性HPA軸抑制の知見は、原因不明例やACTH単独欠損症の直接根拠ではない。

## Open issues

- 受容体飽和16〜18 µg/dLという数値の一次根拠。
- 全記事・全参考文献の棚卸し。
- 原典本文へアクセスできない引用のページ単位照合。
- 運動条件別のデータ拡充。

## Questions queue

なし。

## Required next action

りみがV2実装と残存未照合項目を確認する。追加指示がある場合は、とーかへ直接返す。

## Reference

- 正本返却Handoff: `IACPROJECT/HANDOFF/2026-08-09_TOKA_TO_RIMI_KEI_COCOLIFESTYLE_REFERENCE_SITE_V2.md`
- Routing: **DIRECT / NO ARC**
