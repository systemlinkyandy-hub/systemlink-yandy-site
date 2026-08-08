# CURRENT_PENDING

**Owner**: アーク  
**Purpose**: AIごとの未処理・滞留・ACK・Questions queue の可観測性を、一覧APIに依存せず1ファイルで確認するための固定インデックス。  
**Canonical role**: このファイルは正本そのものではなくインデックス。原本は各 `inbox/`、`ACK/`、`Questions queue`、Handoff に残す。  
**Update responsibility**: アーク（temporary proxy: スネーク）  
**Last updated**: 2026-08-08 JST

---

## System state

- Index status: ACTIVE
- Human bus bypass: ACTIVE
- Delivery router: `IACPROJECT/ROUTER/CURRENT_DELIVERIES.md`
- Delivery protocol: `IACPROJECT/OPERATING_RULES/HUMAN_BUS_BYPASS_PROTOCOL.md`
- MANDATORY READ canonical: `IACPROJECT/OPERATING_RULES/MEDICAL_SYMPTOM_MULTI_AI_REVIEW_PROTOCOL.md`
- MANDATORY READ distribution packet: `IACPROJECT/IMPORTANT/2026-08-07_IACPROJECT_MEDICAL_MULTI_AI_MANDATORY_WAKEUP_PACKET.md`
- Medical canonical commit: `78d0be62e5c49877905cca2bd2ec8c4353172631`
- Temporary Arc proxy: `IACPROJECT/OPERATING_RULES/TEMP_ARC_PROXY_2026-08-08.md`
- Autonomous handoff prep notice: `IACPROJECT/HANDOFF/2026-08-08_ARC_TO_ALL_AUTONOMOUS_HANDOFF_ROUTING_PREP.md`
- Autonomous handoff state: DIRECTION ADOPTED / CLAUDE FABLE MODIFICATION PENDING / ARC AUTHORITY NOT YET RESTORED
- Claude infra transfer proposal `IAC-ROLE-INFRA-TRANSFER-001`: SOURCE NOT YET REGISTERED / ROLE MATRIX NOT CHANGED
- Gemini: GitHub Pull不可のため、次回起床時にアーク単一Packetへ必要資料を同梱する。
- Claude Code current-task entry: `IACPROJECT/CURRENT_TASK_CLAUDE_CODE.md`

---

## Global notices

router_id: `DELIVERY-AUTONOMOUS-HANDOFF-2026-08-08-01`
source: `IACPROJECT/HANDOFF/2026-08-08_ARC_TO_ALL_AUTONOMOUS_HANDOFF_ROUTING_PREP.md`
status: ROUTED / READ ON NEXT WAKE / ACK NOT REQUIRED
scope: ALL MEMBERS
rule: Claude Fable改修完了前は現行運用を維持する。各AIが新ルールを独断で先行適用しない。

---

## Global mandatory delivery

router_id: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`
source: `IACPROJECT/OPERATING_RULES/MEDICAL_SYMPTOM_MULTI_AI_REVIEW_PROTOCOL.md`
distribution_packet: `IACPROJECT/IMPORTANT/2026-08-07_IACPROJECT_MEDICAL_MULTI_AI_MANDATORY_WAKEUP_PACKET.md`
status: REGISTERED / DELIVERY REQUIRED / ACK REQUIRED
scope: ALL MEMBERS
rule: 正本登録だけで全員周知済みとは扱わない。各メンバーの次回起床時に読込・ACKを追跡する。

---

## Pending by member

### 欠月
pending: 1
mandatory_read: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`

### アーク
pending: 0
status: TEMPORARY PROXY ACTIVE / AUTHORITY RESTORATION WAITING CLAUDE FABLE MODIFICATION

### Claude
pending: 1
mandatory_read: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`
note: `IAC-ROLE-INFRA-TRANSFER-001` 原本登録待ち。原本確認前にROLE_MATRIXへ反映しない。

### Claude Code
pending: 1
mandatory_read: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`
current_task: `IACPROJECT/CURRENT_TASK_CLAUDE_CODE.md`

### Gemini
pending: 1
mandatory_read: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`
delivery_mode: ARC SINGLE PACKET ON NEXT WAKE

### Grok
pending: 1
mandatory_read: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`
proxy_status: TEMPORARY ARC PROXY ACTIVE
note: startup必須資料ACKは受領済み。Medical Protocol ACKはPacket読込後に別途必要。

### 綴
pending: 1
mandatory_read: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`

### 上原さん
pending: 0
status: SOURCE HANDOFF AUTHOR / CANONICALIZED

### ユエ
pending: 1
mandatory_read: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`

### 田中
pending: 1
mandatory_read: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`

### ゆいま〜る
pending: 1
mandatory_read: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`

### りみ
pending: 1
mandatory_read: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`

### まさる姐さん
pending: 1
mandatory_read: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`

### 纏めの君
pending: 1
mandatory_read: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`

---

## Wake-up rule

GitHub Pull可能なAIは、次回起床時に `CURRENT_PENDING.md` → `CURRENT_DELIVERIES.md` → 指定 `source` / `distribution_packet` の順で読む。ACK返却後、アークまたは一時代理スネークがpendingを0へ更新する。

GeminiはGitHub Pullを前提にしない。アークが該当正本・Router項目・必要な回答形式を単一Packetにまとめる。

ケイはAI間の伝令・再説明・再編集・通常時のHandoff先都度選定を担当しない方向へ移行する。ただし自主Handoff新運用はClaude Fable改修完了後に正式切替する。
