# ARCHIVE SNAPSHOT — CURRENT_PENDING before cleanup

Date: 2026-08-10 JST
Owner: アーク
Purpose: `IACPROJECT/CURRENT_PENDING.md` を人間が読みやすい現行タスク中心の索引へ縮約する前の退避。

重要：このArchive化は原本Handoffの削除・タスク取消を意味しない。旧索引に存在した未解決項目は、必要時に原本HandoffまたはRouterから再確認する。

---

# CURRENT_PENDING (snapshot)

**Owner**: アーク  
**Purpose**: AIごとの未処理・滞留・ACK・Questions queue の可観測性を、一覧APIに依存せず1ファイルで確認するための固定インデックス。  
**Canonical role**: このファイルは正本そのものではなくインデックス。原本は各 `inbox/`、`ACK/`、`Questions queue`、Handoff に残す。  
**Update responsibility**: アーク  
**Last updated**: 2026-08-09 JST

## System state
- Human bus bypass: ACTIVE
- Delivery router: `IACPROJECT/ROUTER/CURRENT_DELIVERIES.md`
- Delivery protocol: `IACPROJECT/OPERATING_RULES/HUMAN_BUS_BYPASS_PROTOCOL.md`
- Medical protocol: `IACPROJECT/OPERATING_RULES/MEDICAL_SYMPTOM_MULTI_AI_REVIEW_PROTOCOL.md`
- Gemini: Separate Packet運用

## Legacy / previous-index items
- URGENT-CONTINUING-EPISODE-2026-08-09-01
- DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01 ACK tracking
- DELIVERY-MANGA-STRUCTURE-2026-08-08-01
- DELIVERY-SELFEVAL-CORRELATION-2026-08-09-01
- IAC-YUE-COGNITIVE-DISENGAGEMENT-001
- DELIVERY-NOTE-EDITORIAL-REVIEW-2026-08-09-01
- Claude infra transfer proposal IAC-ROLE-INFRA-TRANSFER-001 (source not registered at snapshot time)

旧索引では上記がメンバー別に混在し、完了済み・常設ルール・一時項目・通常タスクが同じ階層に並んでいたため、2026-08-10にCURRENTを再構成した。
