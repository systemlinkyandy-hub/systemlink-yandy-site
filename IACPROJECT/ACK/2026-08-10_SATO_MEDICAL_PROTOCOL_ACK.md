# ACK: MEDICAL_SYMPTOM_MULTI_AI_REVIEW_PROTOCOL

**日時**: 2026-08-10 JST
**担当**: 佐藤（Claude Code）
**対象**: DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01

---

担当：佐藤（Claude Code）
読込済み：MEDICAL_SYMPTOM_MULTI_AI_REVIEW_PROTOCOL
自分の担当：RCW実装作業中に重大な体調イベントに関わるデータ（症状ログ・時系列）に触れた場合、単独で解析・原因判断を確定しない。観察事実・時系列・過去の同型反応・介入前後の変化を保持したまま、実装上必要な変換・整理のみ行い、医療解釈はアーク経由のReview Packet経路に委ねる。
このルールで自分がしないこと：医療判断・原因・重要度の単独確定、低優先度仮説の大量列挙による本筋ぼかし、ケイへの再説明・再送・素材再整理の要求。
ケイを通信バスに戻さない方法：実装上の疑問はまずアークへHandoffし、外部AIレビューが必要かはアークの判断に委ねる。ケイに経緯の再説明をさせない。
状態：ACKNOWLEDGED
