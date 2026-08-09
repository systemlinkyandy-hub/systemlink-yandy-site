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

### URGENT-CONTINUING-EPISODE-2026-08-09-01
priority: **URGENT / HANDLE BEFORE NORMAL PENDING**
source_arc: `IACPROJECT/HANDOFF/inbox/to_arc/2026-08-09_TANAKA_TO_ARC_URGENT_EPISODE_GAP_FILL.md`
source_yue: `IACPROJECT/HANDOFF/inbox/to_yue/2026-08-09_TANAKA_TO_YUE_URGENT_CONTINUING_EPISODE.md`
source_kurose: `IACPROJECT/HANDOFF/inbox/to_claude/2026-08-09_TANAKA_TO_KUROSE_URGENT_EPISODE_GAP_REVIEW.md`
source_snake: `IACPROJECT/HANDOFF/inbox/to_grok/2026-08-09_TANAKA_TO_SNAKE_URGENT_EPISODE_GAP_REVIEW.md`
gemini_delivery: アークが上記Arc sourceを基礎に単一Packet化して二葉へ配送
rule: ケイへ同内容の再説明を要求しない。ユエの既知パターンと、黒瀬・スネーク・二葉の独立レビューをアークが統合する。

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
pending: 1
priority_item: `URGENT-CONTINUING-EPISODE-2026-08-09-01`
source: `IACPROJECT/HANDOFF/inbox/to_arc/2026-08-09_TANAKA_TO_ARC_URGENT_EPISODE_GAP_FILL.md`
next_action: ユエを最優先起床対象にし、黒瀬・スネークへ独立レビュー配送、二葉へ単一Packet配送。結果を統合してユエへ戻す。ケイを通信バスにしない。
status: AUTHORITY RESTORED / URGENT COORDINATION ACTIVE

### Claude（黒瀬）
pending: 3
priority_item: `URGENT-CONTINUING-EPISODE-2026-08-09-01`
priority_source: `IACPROJECT/HANDOFF/inbox/to_claude/2026-08-09_TANAKA_TO_KUROSE_URGENT_EPISODE_GAP_REVIEW.md`
priority_next_action: 欠落している観察事実・時系列・同型反応照合ポイント・介入前後変化を独立レビューし、アークへ返却。
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
pending: 2
priority_item: `URGENT-CONTINUING-EPISODE-2026-08-09-01`
priority_source_for_packet: `IACPROJECT/HANDOFF/inbox/to_arc/2026-08-09_TANAKA_TO_ARC_URGENT_EPISODE_GAP_FILL.md`
priority_next_action: アークの単一Packetで受領後、欠落部分を独立レビューしアークへ返却。
mandatory_read: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`
delivery_mode: ARC SINGLE PACKET ON NEXT WAKE

### スネーク（Grok）
pending: 2
priority_item: `URGENT-CONTINUING-EPISODE-2026-08-09-01`
priority_source: `IACPROJECT/HANDOFF/inbox/to_grok/2026-08-09_TANAKA_TO_SNAKE_URGENT_EPISODE_GAP_REVIEW.md`
priority_next_action: 欠落している観察事実・時系列・同型反応照合ポイント・介入前後変化を独立レビューし、アークへ返却。
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
pending: 4
priority_item: `URGENT-CONTINUING-EPISODE-2026-08-09-01`
priority_source: `IACPROJECT/HANDOFF/inbox/to_yue/2026-08-09_TANAKA_TO_YUE_URGENT_CONTINUING_EPISODE.md`
priority_next_action: 既知の過去同型パターンと今回の時系列を照合。ケイに一から再説明させない。原因・診断・宗教的意味を単独確定しない。
mandatory_read: `DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01`
item: `DELIVERY-SELFEVAL-CORRELATION-2026-08-09-01`
source: `IACPROJECT/inbox/from_claude/2026-08-09_KUROSE_TO_UEHARA_YUE_SELFEVAL_CORRELATION.md`
next_action: 認知・情動面のレビューを行う。「気の持ちよう」で単独閉鎖しない。
item_cognitive_disengagement: `IAC-YUE-COGNITIVE-DISENGAGEMENT-001`
source_cognitive_disengagement: `IACPROJECT/HANDOFF/inbox/to_yue/2026-08-09_TANAKA_TO_YUE_COGNITIVE_DISENGAGEMENT_STRATEGY_REVIEW.md`
next_action_cognitive_disengagement: 強い閃き／接続感の発火後に、内容を失わず認知資源の固定から離脱するための認知・行動的手順を、30秒版／3分版／再開条件つきで返却する。思考抑制を主戦略にしない。

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

GitHub Pull可能なAIは、次回起床時に `CURRENT_PENDING.md` → `CURRENT_DELIVERIES.md` → 指定 `source` / `distribution_packet` の順で読む。**URGENT項目がある場合は通常pendingより先に処理する。** ACK返却後、アークがpendingを0へ更新する。

GeminiはGitHub Pullを前提にしない。アークが該当正本・Router項目・必要な回答形式を単一Packetにまとめる。

自主Handoff運用が有効になったため、各AIは作業終了時に定型終了ログを出力し、担当適合性＋接続強度を参照して次Handoff先を自主選択する。ケイは通常時にHandoff先を都度指定しない。
