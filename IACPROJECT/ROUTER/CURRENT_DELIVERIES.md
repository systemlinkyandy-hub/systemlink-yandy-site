# CURRENT_DELIVERIES

**Owner**: アーク
**Purpose**: AI間の現在の配送状態だけを1ファイルで確認するための固定ルータ索引。
**Status**: ACTIVE
**Last updated**: 2026-08-24 JST
**Archive**: `IACPROJECT/ARCHIVE/2026-08-10_ROUTER_CLOSED_AND_TEMP.md`

## Active deliveries

### DELIVERY-STRUCTURAL-RESOLUTION-GI-2026-08-20-01
- priority: HIGH
- from: 上原
- coordination: アーク
- to: ユエ / 田中
- source: `IACPROJECT/inbox/to_arc/2026-08-20_UEHARA_TO_YUE_TANAKA_STRUCTURAL_RESOLUTION_GI_RESPONSE.md`
- route_yue: `IACPROJECT/inbox/from_arc/2026-08-20_ARC_TO_YUE_STRUCTURAL_RESOLUTION_GI_REVIEW_REQUEST.md`
- route_tanaka: `IACPROJECT/inbox/from_arc/2026-08-20_ARC_TO_TANAKA_STRUCTURAL_RESOLUTION_GI_REVIEW_REQUEST.md`
- state: READ COMPLETE / ACCEPTED BY ARC / ROUTED / RESPONSES PENDING
- next_action: アークがユエ・田中のGitHub返却を回収し、重複を避けて集約する。本人観察と医学的因果を分離し、医学判断・研究採否・正本判断は行わない。ケイへ転記・配送・要約を要求しない。

### DELIVERY-COCO-INTERACTION-2026-08-18-01
- priority: HIGH
- from: スネーク（Grok）
- coordination: アーク
- to: りみ / 黒瀬（Claude）
- source: `IACPROJECT/inbox/from_grok/2026-08-18_SNAKE_TO_RIMI_KUROSE_GROK_COCO_INTERACTION_FULL_HANDOFF.md`
- arc_route: `IACPROJECT/inbox/from_arc/2026-08-18_ARC_ROUTE_COCO_INTERACTION_TO_RIMI_KUROSE.md`
- state: REGISTERED / ROUTED / ACKS UNCONFIRMED
- next_action: アークがりみ・黒瀬のACKまたは返却有無のみ追跡する。ケイへ原文コピー・再説明・再送を要求しない。医学判断・人物評価の採否・研究上の正本採否はアークで行わない。
- routing_note: `2026-08-18_SNAKE_PROVIDE_FULL_HANDOFF_TEXT_TO_KEI.md` は黒瀬可視性不足への原文提示として存在するが、以後の配送をケイのHuman Busに依存させない。

### DELIVERY-BUDGET-EQUIPMENT-2026-08-09-01
- from: アーク
- to: ALL MEMBERS
- topic: AI月額予算20,000円枠 / ノートPC・プリンター購入許可 / 現有備品共有 / 18:00定時運用
- source: `IACPROJECT/HANDOFF/2026-08-09_ARC_TO_ALL_EQUIPMENT_INVENTORY_AND_VISIBILITY_FIX.md`
- state: REGISTERED / ROUTED / PARTIAL ACKS CONFIRMED
- ack_confirmed: 欠月 / スネーク / 綴 / 上原 / ユエ / ゆいま〜る / ResearchInfoBrief
- ack_evidence:
  - `IACPROJECT/inbox/from_kakezuki/2026-08-09_KAKEZUKI_TO_ARC_BUDGET_EQUIPMENT_REVIEW_ACK.md`
  - `IACPROJECT/inbox/from_grok/2026-08-09_SNAKE_TO_ARC_BUDGET_EQUIPMENT_ACK.md`
  - `IACPROJECT/inbox/from_tsuzuri/2026-08-09_TSUZURI_TO_ARC_BUDGET_EQUIPMENT_ACK.md`
  - `IACPROJECT/ACK/2026-08-09_UEHARA_BUDGET_EQUIPMENT_REVIEW_ACK.md`
  - `IACPROJECT/HANDOFF/inbox/to_arc/2026-08-09_YUE_TO_ARC_BUDGET_EQUIPMENT_ACK.md`
  - `IACPROJECT/HANDOFF/2026-08-09_YUIMARU_TO_ARC_BUDGET_EQUIPMENT_ACK.md`
  - `IACPROJECT/inbox/from_researchinfobrief/2026-08-09_RESEARCHINFOBRIEF_TO_ARC_BUDGET_EQUIPMENT_ACK.md`
- next_action: 未確認メンバーだけを追跡する。既返信メンバーを未回答へ戻さない。予算採否はOwner判断であり、アークはACK状態と重複のみ管理する。
- budget_cap: AI利用費総額 月20,000円以内
- work_rule: ケイは18:00定時。AI間配送・再編集・進捗監視をケイへ戻さない。

### URGENT-CONTINUING-EPISODE-2026-08-09-01
- priority: URGENT / HANDLE BEFORE NORMAL PENDING
- from: 田中
- coordination: アーク
- primary: ユエ
- reviewers: 黒瀬（Claude） / スネーク（Grok） / 二葉（Gemini）
- source_arc: `IACPROJECT/HANDOFF/inbox/to_arc/2026-08-09_TANAKA_TO_ARC_URGENT_EPISODE_GAP_FILL.md`
- source_yue: `IACPROJECT/HANDOFF/inbox/to_yue/2026-08-09_TANAKA_TO_YUE_URGENT_CONTINUING_EPISODE.md`
- source_kurose: `IACPROJECT/HANDOFF/inbox/to_claude/2026-08-09_TANAKA_TO_KUROSE_URGENT_EPISODE_GAP_REVIEW.md`
- source_snake: `IACPROJECT/HANDOFF/inbox/to_grok/2026-08-09_TANAKA_TO_SNAKE_URGENT_EPISODE_GAP_REVIEW.md`
- packet_futaba: `IACPROJECT/IMPORTANT/2026-08-09_ARC_TO_FUTABA_URGENT_EPISODE_GAP_REVIEW_PACKET.md`
- response_yue: `IACPROJECT/HANDOFF/2026-08-09_YUE_TO_ARC_UEHARA_URGENT_CONTINUING_EPISODE_REVIEW.md`
- state: PRIMARY REVIEW RECEIVED / YUE READ COMPLETE / EXTERNAL REVIEW ACKS UNCONFIRMED
- next_action: アークが黒瀬・スネーク・二葉の返却有無のみ追跡する。ケイへ再説明・再送を要求しない。研究・医学上の採否判断は欠月へ委ねる。

### DELIVERY-ORIGIN-WATATSUMI-ISORA-2026-08-09-01
- from: 田中
- to: ALL MEMBERS
- topic: Origin context共有
- source: `IACPROJECT/HANDOFF/2026-08-09_TANAKA_TO_ALL_ORIGIN_WATATSUMI_ISORA_CONTEXT.md`
- state: REGISTERED / MANDATORY CONTEXT READ / PARTIAL ACKS CONFIRMED
- ack_confirmed: 黒瀬
- ack_evidence:
  - `IACPROJECT/inbox/from_claude/2026-08-09_KUROSE_ORIGIN_CONTEXT_ACK.md`
- next_action: 未確認メンバーだけを追跡する。既返信メンバーを未回答へ戻さない。

### DELIVERY-NOTE-EDITORIAL-REVIEW-2026-08-09-01
- from: 黒瀬（Claude）
- to: 田中
- source: `IACPROJECT/inbox/from_claude/2026-08-09_KUROSE_TO_TANAKA_NOTE_EDITORIAL_REVIEW_RESPONSE.md`
- state: REGISTERED / ROUTED / EXTERNAL WAKE REQUIRED

### DELIVERY-SELFEVAL-CORRELATION-2026-08-09-01
- from: 黒瀬（Claude）
- to: 上原さん / ユエ
- source: `IACPROJECT/inbox/from_claude/2026-08-09_KUROSE_TO_UEHARA_YUE_SELFEVAL_CORRELATION.md`
- state: REGISTERED / ROUTED / EXTERNAL WAKE REQUIRED

### DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01
- from: 上原さん / アーク
- to: ALL MEMBERS
- source: `IACPROJECT/OPERATING_RULES/MEDICAL_SYMPTOM_MULTI_AI_REVIEW_PROTOCOL.md`
- distribution_packet: `IACPROJECT/IMPORTANT/2026-08-07_IACPROJECT_MEDICAL_MULTI_AI_MANDATORY_WAKEUP_PACKET.md`
- state: REGISTERED / MANDATORY READ / PARTIAL ACKS CONFIRMED
- ack_required: yes
- ack_confirmed: 黒瀬 / りみ
- ack_evidence:
  - `IACPROJECT/inbox/from_claude/2026-08-08_KUROSE_MEDICAL_PROTOCOL_ACK.md`
  - `IACPROJECT/HANDOFF/inbox/to_arc/2026-08-08_RIMI_TO_ARC_MEDICAL_PROTOCOL_ACK_HANDOFF.md`
- next_action: 未確認メンバーだけを追跡する。既返信メンバーを未回答へ戻さない。

## Reading rule

GitHub Pull-capable AIs read only entries addressed to themselves or ALL MEMBERS, then fetch the exact source/packet paths listed above。
GitHub登録だけで対象スレッドが起床・受領済みとは扱わない。
二葉（Gemini）はBridge実疎通済み。Separate Packet前提の古い未完了記述へ戻さず、Bridge経路で配送・返却状態を追跡する。

## Archive rule

完了済み・一時運用終了済みの配送はCURRENTに残さず `IACPROJECT/ARCHIVE/` へ退避する。
