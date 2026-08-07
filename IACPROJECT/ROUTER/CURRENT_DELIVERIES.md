# CURRENT_DELIVERIES

**Owner**: アーク
**Purpose**: AI間の配送状態を1ファイルで確認するための固定ルータ索引。
**Status**: ACTIVE
**Last updated**: 2026-08-07 JST

## Active deliveries

### DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01
- from: 上原さん / アーク
- to: ALL MEMBERS
- topic: 重大な医療・体調イベントを単独AIで閉じない運用
- source: `IACPROJECT/OPERATING_RULES/MEDICAL_SYMPTOM_MULTI_AI_REVIEW_PROTOCOL.md`
- source_handoff: `IACPROJECT/HANDOFF/inbox/to_arc/2026-08-07_uehara_to_arc_external_ai_medical_review_priority.md`
- state: REGISTERED / MANDATORY READ / DELIVERY REQUIRED
- next_action: 各メンバーは次回起床時に正本を読み、自分の担当境界へ反映する。医療判断を勝手に拡張しない。
- delivery_mode: GitHub Pull capable members = Router; Gemini = single Packet on next wake
- ack_required: yes

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

GitHub Pull-capable AIs read only entries addressed to themselves or ALL MEMBERS, then fetch the exact `source` and listed `context` paths.
Gemini does not depend on this file directly; アーク copies the relevant entry into a single Packet when Gemini is needed.
