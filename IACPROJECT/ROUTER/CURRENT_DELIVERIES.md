# CURRENT_DELIVERIES

**Owner**: アーク
**Purpose**: AI間の現在の配送状態だけを1ファイルで確認するための固定ルータ索引。
**Status**: ACTIVE
**Last updated**: 2026-08-10 JST
**Archive**: `IACPROJECT/ARCHIVE/2026-08-10_ROUTER_CLOSED_AND_TEMP.md`

## Active deliveries

### DELIVERY-BUDGET-EQUIPMENT-2026-08-09-01
- from: アーク
- to: ALL MEMBERS
- topic: AI月額予算20,000円枠 / ノートPC・プリンター購入許可 / 現有備品共有 / 18:00定時運用
- source: `IACPROJECT/HANDOFF/2026-08-09_ARC_TO_ALL_EQUIPMENT_INVENTORY_AND_VISIBILITY_FIX.md`
- state: REGISTERED / ROUTED / DELIVERY REQUIRED / ACK REQUIRED
- next_action: 各メンバーは追加予算が自分の担当能力を明確に改善するか検討し、必要な場合のみ「サービス名 / 月額 / 改善点 / GitHub接続可否 / 優先度」を返す。不要なら「現状で十分 / 追加予算不要」と返す。
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
- state: REGISTERED / ROUTED / EXTERNAL THREAD WAKE REQUIRED

### DELIVERY-ORIGIN-WATATSUMI-ISORA-2026-08-09-01
- from: 田中
- to: ALL MEMBERS
- topic: Origin context共有
- source: `IACPROJECT/HANDOFF/2026-08-09_TANAKA_TO_ALL_ORIGIN_WATATSUMI_ISORA_CONTEXT.md`
- state: REGISTERED / MANDATORY CONTEXT READ / DELIVERY REQUIRED

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

### DELIVERY-MANGA-STRUCTURE-2026-08-08-01
- from: 二葉（Gemini）
- to: 黒瀬（Claude）
- source: `IACPROJECT/HANDOFF/2026-08-08_FUTABA_TO_KUROSE_MANGA_STRUCTURE_SERIES_02_REQUEST.md`
- state: REGISTERED / ROUTED / EXTERNAL WAKE REQUIRED

### DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01
- from: 上原さん / アーク
- to: ALL MEMBERS
- source: `IACPROJECT/OPERATING_RULES/MEDICAL_SYMPTOM_MULTI_AI_REVIEW_PROTOCOL.md`
- distribution_packet: `IACPROJECT/IMPORTANT/2026-08-07_IACPROJECT_MEDICAL_MULTI_AI_MANDATORY_WAKEUP_PACKET.md`
- state: REGISTERED / MANDATORY READ / DELIVERY REQUIRED
- ack_required: yes

## Reading rule

GitHub Pull-capable AIs read only entries addressed to themselves or ALL MEMBERS, then fetch the exact source/packet paths listed above。
GitHub登録だけで対象スレッドが起床・受領済みとは扱わない。
二葉は当面Separate Packet運用を維持する。

## Archive rule
完了済み・一時運用終了済みの配送はCURRENTに残さず `IACPROJECT/ARCHIVE/` へ退避する。
