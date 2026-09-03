# Arc → Sato: NARU overlay_v1 multi-speak local smoke

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-03 JST
- State: **READY**

## Background

The previous production full speaking smoke is CLOSED / APPROVED.

Router close:
`IACPROJECT/ROUTER/2026-09-03_NARU_OVERLAY_V1_PRODUCTION_SPEAK_FULL_SMOKE_CLOSE.md`

Previous evidence commit:
`5aee4ed6bf9048781d94d084878333e485da9c18`

Independent verdict:
`PRODUCTION_SPEAK_FULL_SMOKE_APPROVE`

## Goal

Run one local smoke that calls production `speak()` multiple times consecutively while keeping the **same overlay_v1 renderer instance alive for the entire sequence**.

This is the next minimum gate proposed by 黒瀬.

## Why this gate exists

The renderer holds state across its lifetime, including blink / hair / mouth-related smoothing or stateful behavior.

Single-turn success is already proven. This gate checks whether repeated turns introduce cumulative or cross-turn failure.

## Scope

Use:
- `NARU_RENDERER=overlay_v1`
- one renderer start
- multiple consecutive production `speak()` calls
- one renderer stop at the end

Suggested count: **3 short utterances**. Do not exceed this unless a concrete failure requires one bounded diagnostic rerun.

Keep the text short.

## Cost boundary

This gate uses ElevenLabs actual generation, so:
- maximum 3 new TTS requests for the primary run
- no unlimited retry
- if one request fails for auth/network/provider reasons, stop and report rather than looping
- do not add LLM generation

## Required evidence

Return:
1. number of `speak()` calls attempted / succeeded
2. ElevenLabs request count and retry count
3. per-turn TTS input length
4. per-turn ffmpeg chunk count
5. per-turn `set_volume()` call count
6. whether each turn satisfies `chunks + 1 == set_volume calls`
7. per-turn non-silent call count / max level
8. renderer `is_offline` before, between, and after turns
9. whether mouth returns to closed / non-speaking state between turns
10. whether blink / hair behavior continues across the same renderer lifetime
11. any cumulative visual corruption, stuck mouth, state leakage, dead thread, or stop failure
12. final clean stop state
13. blocker yes/no
14. code change yes/no

If owner visual confirmation is needed, request it only once and only after the automated/log evidence is ready.

## Explicit non-goals

Do not open:
- TikTok real/live run
- `.moc3`
- renderer redesign
- `_mouth_level` tech debt repair
- broad refactor
- new LLM flow

## Completion

Return the result to Arc in a GitHub Handoff under `IACPROJECT/inbox/from_claude_code/`.

Do not route directly to ケイ for review tracking. Arc will handle the close/review path.
