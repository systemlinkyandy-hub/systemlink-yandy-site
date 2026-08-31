# Handoff: NARU Renderer Swap Phase C0/C1 — failure isolation + Live2D technical spike

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-08-31 JST
- Priority: HIGH / REVERSIBLE TECHNICAL SPIKE
- State: IMPLEMENTATION REQUESTED

## Evidence accepted

Phase A/B implementation:
- commit `6df23381f1cdf1d0b81f6f91d0177a1c6aa50c50`
- Renderer interface + LegacyFrameRenderer + factory
- legacy lipsync hysteresis + blink timing jitter

Kurose practical review relay:
- `IACPROJECT/inbox/from_claude_code/2026-08-31_SATO_TO_ARC_NARU_RENDERER_SWAP_KUROSE_APPROVE_RELAYED.md`
- commit `aa18bc6`
- Phase A/B: APPROVE
- Phase C condition: renderer failure must be deliberately injected and must not take down LLM/TTS core

Important evidence note:
Kurose original review Markdown is not yet a GitHub-native primary artifact. Treat the relay as secondary evidence; do not rewrite it as a native Kurose commit.

## Decision boundary

This is NOT final adoption of Live2D/Cubism.

Proceed as:
- Phase C0 = renderer failure isolation
- Phase C1 = Live2D technical spike

VRM remains a comparison candidate. Formal adoption/rejection is deferred until spike evidence exists.

## Phase C0 — failure isolation

Goal: renderer failure must not terminate or poison the NARU core conversation/TikTok/LLM/TTS path.

Implement the smallest isolation layer compatible with the current Renderer boundary.

Required failure injection tests, with no paid APIs:
1. renderer factory failure
2. renderer.start() exception
3. renderer.set_audio_level()/set_volume() exception while core workers are alive
4. renderer stop/cleanup exception

Expected behavior:
- failure is logged clearly
- renderer is marked unavailable/offline
- LLM/TTS/queue objects remain alive and process synthetic jobs
- no silent fallback to a different renderer unless explicitly designed and logged
- `legacy` remains selectable for immediate rollback
- STANDBY safety remains unchanged

A headless/null renderer may be used only as an explicit degraded mode if the mode transition is logged and testable. Do not disguise failure as success.

## Phase C1 — Live2D technical spike

Goal: prove that the new Renderer interface can drive a real Live2D/Cubism-compatible renderer without changing NARU core logic.

Constraints:
- do not modify OpenAI/TikTok/TTS/queue/latency behavior except the minimal renderer connection point
- no autonomous LIVE test in this phase
- no paid API calls required for the renderer spike
- use a legally usable local/sample model only if already available and licensing is clear; do not download or commit third-party model assets without explicit license confirmation
- if no safe model asset exists, complete SDK/runtime connection + renderer adapter + synthetic parameter test and report ASSET BLOCKED rather than inventing an asset

Required adapter surface:
- `start()`
- `stop()`
- `set_audio_level(level)` mapped to mouth parameter(s)
- `set_expression(name)` where supported
- `set_motion(name)` where supported

Required tests:
1. renderer boots independently from NARU core
2. synthetic 0→mid→high→0 audio values produce continuous/meaningful mouth parameter change
3. blink/idle motion can run without touching LLM/TTS
4. deliberate renderer exception invokes Phase C0 isolation and core synthetic job still completes
5. switching back to `NARU_RENDERER=legacy` restores current renderer without code rollback

## Comparison evidence to return

Return a short evidence table:
- dependency/runtime footprint
- process boundary (in-process / IPC)
- mouth parameter resolution
- blink/expression/motion support
- asset requirement
- licensing uncertainty
- rollback cost
- observed failure behavior

Do not declare final Live2D adoption. Return: `SPIKE PASS`, `SPIKE PASS / ASSET BLOCKED`, or `SPIKE HOLD`.

## Owner burden rule

ケイへコード編集、SDK調査の転記、failure test、ACK回収を戻さない。
