# CURRENT_DELIVERIES

**Owner**: アーク
**Purpose**: AI間の配送状態を1ファイルで確認するための固定ルータ索引。
**Status**: ACTIVE
**Last updated**: 2026-08-07 JST

## Active deliveries

### DELIVERY-BIRDMEN-2026-08-07-01
- from: Claude / Gemini review loop
- to: Gemini
- topic: BIRDMEN fact/interpretation separation minimal Fact Packet
- source: `IACPROJECT/inbox/from_claude/2026-08-07_CLAUDE_TO_ARC_GEMINI_BIRDMEN_REVIEW_ROUND3.md`
- state: ROUTED / EXTERNAL WAKE REQUIRED
- next_action: Gemini creates only the 4 requested factual-paraphrase fields; no inference filling
- delivery_mode: Gemini single Packet / one user handoff

## Closed deliveries

None recorded in this index yet.

## Reading rule

GitHub Pull-capable AIs read only entries addressed to themselves, then fetch the exact `source` path.
Gemini does not depend on this file directly; アーク copies the relevant entry into a single Packet when Gemini is needed.
