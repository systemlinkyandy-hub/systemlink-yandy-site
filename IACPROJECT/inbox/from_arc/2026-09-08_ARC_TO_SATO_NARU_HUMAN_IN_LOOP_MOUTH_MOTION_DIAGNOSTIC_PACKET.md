# Arc → Sato: NARU human-in-the-loop mouth motion diagnostic packet

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Date: 2026-09-08 JST
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- State: **OWNER REJECT HELD / DIAGNOSTIC ONLY / NO IMPLEMENTATION YET**
- Source rework commit: `010161552701c97df2db00362c587a80b3e1ebb5`
- Previous owner finding: nose/philtum spill was reduced by hard mouth boundary, but the mouth itself still visibly jitters / changes shape unnaturally. Owner and Arc will review the motion model together before the next implementation.

## Purpose

Do not continue parameter tuning yet. Prepare a compact visual comparison packet so Kei + Arc can identify what makes the original Imagine motion feel natural and what makes current `overlay_v1` mouth motion feel unstable.

## Existing source candidates

Use the already found local Imagine references where available:
- `resource/avater_matataki.mp4`
- `resource/Noll_kinohanoyouni.mp4`
- `resource/Noll_konoseijakugasukida.mp4`

Use current owner evidence:
- `OWNER_VISUAL_CONFIRMATION_v2_h264.mp4`

No new Imagine generation and no new ElevenLabs request.

## Required diagnostic packet

Create visual evidence only; do not modify production code in this step.

1. **Matched contact sheet**
   - Original Imagine: 6–10 representative frames across one visible speech/mouth-motion sequence if speech-like mouth motion exists; otherwise choose the clearest facial motion sequence.
   - Current overlay_v1 v2: 6–10 representative frames from rest → opening → peak → closing.
   - Same display scale and face crop where practical.
   - Preserve full lower face so jaw/cheek/chin movement can be seen.

2. **Landmark-motion note**
   For both source and overlay, record only observable movement direction/relative amount for:
   - upper lip center
   - lower lip center
   - left/right mouth corner
   - chin/jaw silhouette
   - philtrum / nose base
   - cheek immediately beside mouth

   Pixel-perfect tracking is not required. This is a human-perception diagnostic, not a new technical acceptance gate.

3. **State-transition note**
   Identify whether current overlay jitter appears mainly from:
   - discrete source-state changes,
   - crossfade overlap / double contour,
   - alpha-mask shape changes,
   - color/line-density switching,
   - or face parts failing to co-move with the mouth.

   If more than one is plausible, label as hypotheses. Do not force a single root cause.

4. **No redesign yet**
   Do not implement jaw/cheek motion, state-count changes, warping, optical-flow transfer, or source-video extraction until Kei + Arc choose the direction from this packet.

## Owner burden rule

Kei must not be asked to inspect code, calculate coordinates, search commits, or create a new Imagine clip at this stage. Return only the compact comparison evidence and a short diagnostic note. If the existing source clips are insufficient for a meaningful comparison, return `SOURCE_REFERENCE_INSUFFICIENT` with the exact missing visual information; only then will Arc decide whether to ask Kei for one new reference clip.

## Next routing

Sato → Arc with evidence path(s) + short note. Arc + Kei decide motion model. Then Arc routes one implementation direction to Sato. Kurose independent review follows only after the next implementation candidate exists.
