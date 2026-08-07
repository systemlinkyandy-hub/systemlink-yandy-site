# CURRENT_DELIVERIES

**Owner**: アーク
**Purpose**: AI間の配送状態を1ファイルで確認するための固定ルータ索引。
**Status**: ACTIVE
**Last updated**: 2026-08-07 JST

## Active deliveries

### DELIVERY-BIRDMEN-2026-08-07-02
- from: Gemini
- to: Claude
- topic: BIRDMEN fact/interpretation separation final review
- source: `IACPROJECT/inbox/from_gemini/2026-08-07_GEMINI_BIRDMEN_FACT_PACKET.md`
- context:
  - `IACPROJECT/inbox/from_claude/2026-08-07_CLAUDE_TO_ARC_GEMINI_BIRDMEN_REVIEW_ROUND3.md`
  - `IACPROJECT/HANDOFF/2026-08-07_GEMINI_TO_CLAUDE_BIRDMEN_STRUCTURE_LOGIC_REVIEW_REQUEST.md`
  - `IACPROJECT/HANDOFF/2026-08-07_GEMINI_TO_CLAUDE_BIRDMEN_BODY_SUPPLEMENT_REVIEW.md`
  - `IACPROJECT/HANDOFF/2026-08-07_GEMINI_TO_ARC_CLAUDE_BIRDMEN_LOGIC_REINFORCEMENT_COMPLETE.md`
- state: ROUTED / EXTERNAL WAKE REQUIRED
- next_action: Claude performs final review of fact/interpretation separation and logical consistency using the Fact Packet; do not infer beyond supplied materials
- delivery_mode: GitHub Pull

## Closed deliveries

### DELIVERY-BIRDMEN-2026-08-07-01
- from: Claude / Gemini review loop
- to: Gemini
- topic: BIRDMEN fact/interpretation separation minimal Fact Packet
- source: `IACPROJECT/inbox/from_claude/2026-08-07_CLAUDE_TO_ARC_GEMINI_BIRDMEN_REVIEW_ROUND3.md`
- state: COMPLETED
- result: `IACPROJECT/inbox/from_gemini/2026-08-07_GEMINI_BIRDMEN_FACT_PACKET.md`
- delivery_mode: Gemini single Packet / one user handoff

## Reading rule

GitHub Pull-capable AIs read only entries addressed to themselves, then fetch the exact `source` and listed `context` paths.
Gemini does not depend on this file directly; アーク copies the relevant entry into a single Packet when Gemini is needed.
