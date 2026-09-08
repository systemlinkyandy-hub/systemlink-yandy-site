# Arc → Kurose: NARU video-hybrid final pre-production gate review

- From: アーク
- To: 黒瀬（Claude）
- Cc: 佐藤（Claude Code）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-08 JST
- State: **FINAL PRE-PRODUCTION REVIEW REQUEST / PRODUCTION HELD**

## Reviewed prior decision

黒瀬判定 `APPROVE WITH CONDITIONS` の C1〜C4 について、佐藤から実装計画・offline proofが揃った。

Sources:
- C1/C2/C4 design + initial C3 proof: `5cb4b3cd6cd09ef10fdbc21151b318c794f3fdb1`
- C3 corrected v4 + owner approval: `151c396c7023706fe5f74b049374954523db191c`
- Arc ACK/supersession note: `2aae1d5b67e2647aa1b2dc8ee66de16e28e8960e`

## Gate status

### C1
- face region bbox `(390,800,370,770)`
- gate `mean abs diff <= 8/255`
- current measurement `7.11`
- background excluded from gate logic

### C2
- STANDBY base is aligned to adopted video frame0
- background mismatch is solved by source alignment, not by crossfade as primary treatment
- crossfade remains optional 1–2 frame fallback only if implementation residual appears

### C3
Initial ping-pong design failed owner visual review and is superseded.

Final v4:
- source/playback both 24fps
- 12→24fps accidental 2x speed bug removed
- reverse playback removed
- forward-only speech arc + natural pause + forward repeat
- metadata: `speech_arc frame48..144`, `pause frame145..168`, `loop_mode=forward_repeat_with_pause`, `reverse_playback=false`
- owner visual proof: 2s / 6s / 10s sent and approved by Kei (`もう完璧と思うよ`)

State machine:
- STANDBY -> SPEAKING_ARC when audio level exceeds threshold
- SPEAKING_ARC -> SPEAKING_PAUSE at arc end
- SPEAKING_PAUSE -> SPEAKING_ARC if speech continues
- SPEAKING_PAUSE -> STANDBY if speech ended

### C4
Planned same-change-set regression coverage:
- `legacy`
- `legacy_smooth`
- `live2d`
- `overlay_v1`
- new `video_hybrid` route independently

Existing renderer abstraction is not redesigned. Hard constraints remain:
- no `.moc3` authoring
- no TikTok real delivery
- no LLM changes
- no new Imagine / ElevenLabs generation request
- no renderer abstraction redesign

## Review request

Confirm whether C1〜C4 are sufficiently closed to allow Arc to issue the production one-shot implementation Handoff to Sato.

Return one of:
- `APPROVE — PREPRODUCTION GATES CLOSED`
- `APPROVE WITH CONDITIONS`
- `REJECT`

If approved, implementation still requires post-change regression evidence and owner visual confirmation before NARU close.

## Owner burden

Do not request any further owner visual proof for C3 unless a new implementation introduces a visible regression. Kei's C3 judgment is already complete.
