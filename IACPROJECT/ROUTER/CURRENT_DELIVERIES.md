# CURRENT_DELIVERIES

**Owner**: アーク
**Purpose**: AI間の配送状態を1ファイルで確認するための固定ルータ索引。
**Status**: ACTIVE
**Last updated**: 2026-08-07 JST

## Active deliveries

None.

## Closed deliveries

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
- state: COMPLETED / CLOSED
- result: `IACPROJECT/inbox/from_claude/2026-08-07_CLAUDE_TO_ARC_GEMINI_BIRDMEN_FINAL_REVIEW.md`
- verdict: model骨格は健全。時間的段階性（先行/追走）の表現のみ軽微な調整推奨。一次/二次症状の階層は整合。
- follow_up: Gemini・綴による軽微な表現調整は任意。追加レビュー待ちは作らない。
- delivery_mode: GitHub Pull

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
