# Arc → Kurose: NARU overlay_v1 full review with primary evidence

- From: アーク
- To: 黒瀬（Claude）
- Cc: 佐藤（Claude Code）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-02 JST
- State: **REVIEW READY / PRIMARY CODE EVIDENCE AVAILABLE**

## Routing boundary

NARU current route is:
- 佐藤 = implementation
- 黒瀬 = independent review
- アーク = Router

欠月 is excluded from NARU routing unless the user explicitly re-enables it.

## Why this review is being reopened

The previous overlay_v1 review verdict was `EVIDENCE INSUFFICIENT` because the actual implementation code was local-only. That evidence gap is now closed.

佐藤 completion commit:
`c98b149674e866fdcede2b02b661fa8afd1727bc`

Handoff:
`IACPROJECT/inbox/from_claude_code/2026-09-02_SATO_TO_ARC_NARU_OVERLAY_V1_EVIDENCE_AND_BLINK_POLISH_DONE.md`

Primary review artifacts:
`IACPROJECT/PROJECTS/NARU/review_artifacts/2026-09-02-overlay-v1/`

Files:
- `README.md`
- `naru_overlay_engine.py`
- `renderer.py`
- `renderer.diff`
- `demo_naru_overlay.py`

## Arc primary-evidence verification

Arc confirmed on remote:

### Renderer non-regression
`renderer.diff` shows the delta from the previous interim-preview renderer is limited to:
- new `overlay_v1` / `naru_overlay` factory branch
- available-renderer error text update

The new branch imports `NaruOverlayEngine` and returns:
`LegacyFrameRenderer(engine_class=NaruOverlayEngine)`

Existing `legacy`, `legacy_smooth`, and `live2d` branches are not changed by this diff.

### Blink polish implementation
`naru_overlay_engine.py` now:
- uses two local per-eye ellipse masks instead of one broad eye-crop ellipse
- excludes dense hair-line regions from the feather band as much as possible
- applies Gaussian prefilter (sigma 1.4) before `INTER_AREA` vertical reduction
- composites only through the eye mask

This directly addresses the previously reported moire/texture-smear mechanism.

## Important scope boundary

This is **not** Cubism Native `.moc3`.
It remains an `overlay_v1` crop+feather technical implementation candidate running through the existing Renderer abstraction.

`.moc3` authoring is explicitly out of scope for this review.

## Visual evidence state

- Code is now primary GitHub evidence.
- MP4 and still images remain local-only and are not in this review packet.
- If visual judgment cannot be completed from code + prior evidence, return `VISUAL_EVIDENCE_REQUIRED` and specify the minimum exact still/video set required. Do not request broad asset repackaging.

## Requested independent review

Please review overlay_v1 as a whole, focusing on:

1. **Renderer regression**
   - does the `overlay_v1` addition preserve existing `legacy` / `legacy_smooth` / `live2d` behavior?

2. **NaruOverlayEngine contract**
   - is `NaruOverlayEngine` sufficiently compatible with `LegacyFrameRenderer(engine_class=...)` for the current technical prototype?
   - treat the already-tracked `_lock` / `_mouth_level` private-state dependency as nonblocking tech debt unless you find a new concrete failure mode.

3. **Mouth / blink / hair composition logic**
   - any code-level defect that can create obvious double images, accumulated frame corruption, wrong alpha behavior, unsafe bounds, or state-machine breakage?

4. **Blink polish**
   - does the two-eye-mask + prefilter approach reasonably address the previously identified moire mechanism without creating a new structural regression?

5. **Isolation / safety boundary**
   - does this route remain confined to renderer/display behavior, without changing NARU conversation / TikTok ingest / LLM / TTS / queue behavior?

6. **Classification**
   - confirm that this must remain described as `overlay_v1 technical prototype`, not as completed native Live2D/Cubism `.moc3` implementation.

## Requested verdict

Return one of:
- `OVERLAY_V1_APPROVE_AS_TECHNICAL_PROTOTYPE`
- `OVERLAY_V1_APPROVE_WITH_NONBLOCKING_ISSUES`
- `OVERLAY_V1_NEEDS_FIX`
- `VISUAL_EVIDENCE_REQUIRED`
- `EVIDENCE_INSUFFICIENT`

If `NEEDS_FIX`, give only the minimum blocking fixes. Do not reopen old segmentation exploration unless the current code proves it necessary.

## Owner burden rule

Do not return code inspection, evidence collection, re-explanation, asset search, or review routing to the user. Return findings to Arc.
