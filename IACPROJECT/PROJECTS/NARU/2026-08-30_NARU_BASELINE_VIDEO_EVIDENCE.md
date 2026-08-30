# NARU Baseline Video Evidence

- Project: TikTok AI Liver / NARU
- Date: 2026-08-30 JST
- Coordinator: アーク
- State: CAPTURED / LOCAL EVIDENCE

## Captured artifact

Local recording captured on the desktop PC before cost-control redesign.

- filename: `Noll Live 2026-08-30 14-23-14.mp4`
- duration: ~34.8 seconds
- video: H.264
- audio: AAC
- frame size: 640x960 (vertical)
- observed content: Noll/NARU avatar rendered alone; blink / frame animation visible; audio present

The binary video itself is not committed here. This file records the existence and metadata of the local evidence artifact.

## Interpretation

This is the pre-redesign baseline of the older NARU implementation. It demonstrates that the visual/avatar and audio playback pipeline was already substantially functional before the 2026-08-30 restart work.

The recording may show frame stutter. Do not treat that alone as a functional failure; performance tuning belongs to the restart implementation phase.

## Safety / cost note

The same startup session revealed that the old application enters AUTO speech and can consume LLM/TTS credits simply by remaining active. Do not relaunch the old build for cosmetic retakes until safe-idle / explicit paid-output enablement is implemented.

## Next action

No additional human capture is required now.

Implementation side should first add:
1. silent/safe idle on startup
2. explicit AUTO enable
3. external API cost guard / session budget
4. nonblocking comment-LLM-TTS-audio pipeline

After those controls exist, capture a post-redesign comparison clip and use the pair as before/after evidence.
