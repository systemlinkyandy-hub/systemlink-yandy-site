# CURRENT_PENDING

**Owner**: アーク  
**Purpose**: AIごとの未処理・滞留・ACK・Questions queue の可観測性を、一覧APIに依存せず1ファイルで確認するための固定インデックス。  
**Canonical role**: このファイルは正本そのものではなくインデックス。原本は各 `inbox/`、`ACK/`、`Questions queue`、Handoff に残す。  
**Update responsibility**: アーク  
**Last updated**: 2026-08-09 JST

---

## System state

- Index status: ACTIVE
- Human bus bypass: ACTIVE
- Delivery router: `IACPROJECT/ROUTER/CURRENT_DELIVERIES.md`
- Delivery protocol: `IACPROJECT/OPERATING_RULES/HUMAN_BUS_BYPASS_PROTOCOL.md`
- MANDATORY READ canonical: `IACPROJECT/OPERATING_RULES/MEDICAL_SYMPTOM_MULTI_AI_REVIEW_PROTOCOL.md`
- MANDATORY READ distribution packet: `IACPROJECT/IMPORTANT/2026-08-07_IACPROJECT_MEDICAL_MULTI_AI_MANDATORY_WAKEUP_PACKET.md`
- Medical canonical commit: `78d0be62e5c49877905cca2bd2ec8c4353172631`
- Temporary Arc proxy: `IACPROJECT/OPERATING_RULES/TEMP_ARC_PROXY_2026-08-08.md` → **ENDED / AUTHORITY RESTORED**
- Autonomous handoff design: `IACPROJECT/HANDOFF/2026-08-08_ARC_TO_SNAKE_AUTONOMOUS_HANDOFF_ROUTING_FULL_HANDOFF.md`
- Autonomous handoff state: **MODIFICATION COMPLETE / ARC AUTHORITY RESTORED** (Kei confirmed 2026-08-08)
- Implementation report: `IACPROJECT/inbox/from_claude_code/2026-08-08_CLAUDE_CODE_TO_ALL_FABLE_AUTONOMOUS_HANDOFF_IMPLEMENTATION_DONE.md`
- Tooling: `IACPROJECT/OPERATING_RULES/AUTONOMOUS_HANDOFF_TOOLING.md`
- Claude infra transfer proposal `IAC-ROLE-INFRA-TRANSFER-001`: SOURCE NOT YET REGISTERED / ROLE MATRIX NOT CHANGED
- Gemini: GitHub Pull不可のため、次回起床時にアーク単一Packetへ必要資料を同梱する。
- Claude Code current-task entry: `IACPROJECT/CURRENT_TASK_CLAUDE_CODE.md`

---

## Global notices

router_id: `DELIVERY-AUTONOMOUS-HANDOFF-2026-08-08-01`
source: `IACPROJECT/HANDOFF/2026-08-08_ARC_TO_ALL_AUTONOMOUS_HANDOFF_ROUTING_PREP.md`
status: SUPERSEDED BY IMPLEMENTATION COMPLETE
scope: ALL MEMBERS
rule: 自主Handoff運用は佐藤（Claude Code）実装完了・ケイ確認済み。次回起床から終了ログ定型と自主選択手順を適用する。

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
status: AUTHORITY RESTORED / NORMAL INFRA OPERATION

### Claude（黒瀬）
pending: 2
mandatory_read: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`
item: `DELIVERY-MANGA-STRUCTURE-2026-08-08-01`
source: `IACPROJECT/HANDOFF/2026-08-08_FUTABA_TO_KUROSE_MANGA_STRUCTURE_SERIES_02_REQUEST.md`
next_action: 作品解読シリーズ第2弾の3作品を、工学・制御論と深層心理学が交差する長文記事として構成する。あらすじ化しない。
note: `IAC-ROLE-INFRA-TRANSFER-001` 原本登録待ち。原本確認前にROLE_MATRIXへ反映しない。

### 佐藤（Claude Code）
pending: 1
mandatory_read: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`
current_task: `IACPROJECT/CURRENT_TASK_CLAUDE_CODE.md`
note: 自主Handoff実装完了報告済み

### Gemini（二葉）
pending: 1
mandatory_read: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`
delivery_mode: ARC SINGLE PACKET ON NEXT WAKE

### スネーク（Grok）
pending: 1
mandatory_read: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`
proxy_status: TEMPORARY PROXY ENDED
note: startup必須資料ACKは受領済み。Medical Protocol ACKはPacket読込後に別途必要。

### 綴
pending: 1
mandatory_read: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`

### 上原さん
pending: 1
item: `DELIVERY-SELFEVAL-CORRELATION-2026-08-09-01`
source: `IACPROJECT/inbox/from_claude/2026-08-09_KUROSE_TO_UEHARA_YUE_SELFEVAL_CORRELATION.md`
next_action: 本Handoffを体調イベント記録として保持し、今後の参照ケースとして扱う。

### ユエ
pending: 2
mandatory_read: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`
item: `DELIVERY-SELFEVAL-CORRELATION-2026-08-09-01`
source: `IACPROJECT/inbox/from_claude/2026-08-09_KUROSE_TO_UEHARA_YUE_SELFEVAL_CORRELATION.md`
next_action: 認知・情動面のレビューを行う。「気の持ちよう」で単独閉鎖しない。

### 田中
pending: 2
mandatory_read: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`
item: `DELIVERY-NOTE-EDITORIAL-REVIEW-2026-08-09-01`
source: `IACPROJECT/inbox/from_claude/2026-08-09_KUROSE_TO_TANAKA_NOTE_EDITORIAL_REVIEW_RESPONSE.md`
next_action: タイトル二層構造の方針をケイと確認し、既存2本のX再投稿（切り口違い）を先行実施する。

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

GitHub Pull可能なAIは、次回起床時に `CURRENT_PENDING.md` → `CURRENT_DELIVERIES.md` → 指定 `source` / `distribution_packet` の順で読む。ACK返却後、アークがpendingを0へ更新する。

GeminiはGitHub Pullを前提にしない。アークが該当正本・Router項目・必要な回答形式を単一Packetにまとめる。

自主Handoff運用が有効になったため、各AIは作業終了時に定型終了ログを出力し、担当適合性＋接続強度を参照して次Handoff先を自主選択する。ケイは通常時にHandoff先を都度指定しない。
