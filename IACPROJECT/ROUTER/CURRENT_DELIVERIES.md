# CURRENT_DELIVERIES

**Owner**: アーク
**Purpose**: AI間の配送状態を1ファイルで確認するための固定ルータ索引。
**Status**: ACTIVE
**Last updated**: 2026-08-08 JST

## Active deliveries

### DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01
- from: 上原さん / アーク
- to: ALL MEMBERS
- topic: 重大な医療・体調イベントを単独AIで閉じない運用
- source: `IACPROJECT/OPERATING_RULES/MEDICAL_SYMPTOM_MULTI_AI_REVIEW_PROTOCOL.md`
- distribution_packet: `IACPROJECT/IMPORTANT/2026-08-07_IACPROJECT_MEDICAL_MULTI_AI_MANDATORY_WAKEUP_PACKET.md`
- source_handoff: `IACPROJECT/HANDOFF/inbox/to_arc/2026-08-07_uehara_to_arc_external_ai_medical_review_priority.md`
- state: REGISTERED / MANDATORY READ / DELIVERY REQUIRED
- next_action: 各メンバーは次回起床時に正本または配布Packetを読み、自分の担当境界へ反映する。医療判断を勝手に拡張しない。
- delivery_mode: GitHub Pull capable members = Router; Gemini = single Packet on next wake
- ack_required: yes

## Temporary infrastructure delegation

### TEMP-ARC-PROXY-2026-08-08
- primary_owner: アーク
- temporary_proxy: スネーク（Grok / xAI）
- source: `IACPROJECT/inbox/from_grok/2026-08-08_SNAKE_ARC_PROXY_ACCEPTANCE.md`
- rule: `IACPROJECT/OPERATING_RULES/TEMP_ARC_PROXY_2026-08-08.md`
- state: ACTIVE TEMPORARY OVERRIDE
- scope: Handoff登録 / 形式確認 / ACK可視化 / 最低限のRouter・CURRENT_PENDING更新
- exclusions: 研究判断 / 医学判断 / 仕様確定 / 採否 / 正本内容改変 / 構造独断変更

## Closed deliveries

### DELIVERY-BIRDMEN-2026-08-07-02
- from: Gemini
- to: Claude
- topic: BIRDMEN fact/interpretation separation final review
- source: `IACPROJECT/inbox/from_gemini/2026-08-07_GEMINI_BIRDMEN_FACT_PACKET.md`
- state: COMPLETED / CLOSED
- result: `IACPROJECT/inbox/from_claude/2026-08-07_CLAUDE_TO_ARC_GEMINI_BIRDMEN_FINAL_REVIEW.md`

### DELIVERY-BIRDMEN-2026-08-07-01
- from: Claude / Gemini review loop
- to: Gemini
- topic: BIRDMEN fact/interpretation separation minimal Fact Packet
- source: `IACPROJECT/inbox/from_claude/2026-08-07_CLAUDE_TO_ARC_GEMINI_BIRDMEN_REVIEW_ROUND3.md`
- state: COMPLETED
- result: `IACPROJECT/inbox/from_gemini/2026-08-07_GEMINI_BIRDMEN_FACT_PACKET.md`

## Reading rule

GitHub Pull-capable AIs read only entries addressed to themselves or ALL MEMBERS, then fetch the exact `source`, `distribution_packet`, and listed `context` paths as applicable.
Gemini does not depend on this file directly; アーク copies the relevant entry into a single Packet when Gemini is needed.
