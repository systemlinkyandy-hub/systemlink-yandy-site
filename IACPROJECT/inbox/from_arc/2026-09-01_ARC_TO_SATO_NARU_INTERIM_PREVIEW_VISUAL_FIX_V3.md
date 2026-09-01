# Arc → Sato: NARU interim preview visual fix v3

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-01 JST
- State: VISUAL REJECT / V3 FIX REQUIRED

## User visual finding

ケイが現行previewを目視し、以下を確認。

- 口が高速でぱくつく
- 全体が震えるように見える

この目視結果を現行previewの visual acceptance としては **FAIL** とする。
ケイへ追加の長時間目視・原因切り分けを戻さない。

## Code-level findings confirmed by Arc

Current source:
`IACPROJECT/PROJECTS/NARU/review_artifacts/2026-09-01-interim-preview/smooth_frame_renderer.py`

### 1. Mouth input has no temporal smoothing

`set_volume()` stores `volume` directly into `_raw_audio_level` and `_compose_frame()` uses it directly as blend ratio.
Input updates at short intervals therefore become immediate visual mouth changes.

Required:
- add temporal smoothing / envelope between input level and displayed mouth level
- separate attack and release or equivalent low-pass behavior is acceptable
- avoid 50 ms input jitter becoming 1:1 visual jitter
- add a test using intentionally noisy level input and assert displayed level has bounded frame-to-frame delta

Do not alter NARU LLM/TTS/queue paths.

### 2. Whole-frame idle sway is unsuitable for flattened background JPEG

Current `_idle_sway_offset()` + `cv2.warpAffine()` resamples the entire finished illustration every frame, including background.
Subpixel translation of a detailed JPEG can visually crawl/shimmer even with small amplitude.

Required for this interim flattened-image preview:
- disable whole-frame idle sway by default
- do not replace it with another whole-frame affine/scale/rotation trick
- identity preservation and visual stability take priority over artificial motion

If a future motion layer is attempted, it requires separated foreground/background or a different asset structure; not part of this v3 fix.

### 3. Blink path still swaps whole JPEG frames

Current `_compose_frame()` uses `self._eye_frames[eye_idx].copy()` during blink.
These independently encoded JPEGs contain differences outside the eye region, so the earlier whole-frame flicker bug can still recur during blink.

Required:
- use the same fixed base frame strategy as the mouth fix
- determine an eye-only crop/mask from actual frame differences + visual confirmation
- composite only the eye region onto the fixed base frame
- no whole-frame switch between eye JPEGs
- regression test: blink frames must not alter pixels outside the permitted eye crop/mask area

## Acceptance target

The interim preview is intentionally modest. Required visible behavior is only:

- stable still body/background
- restrained natural blink
- mouth opens/closes smoothly without rapid chatter
- no whole-frame shimmer/tremor
- no character redraw / no new generated art

Do not attempt to fake Live2D body motion from the flattened JPEG.

## Safety / scope

- no TikTok
- no paid API
- existing 6 source images remain byte-identical
- legacy renderer rollback preserved
- no new artwork

## Required return

Return one Handoff with:
- changed files
- exact smoothing method/parameters
- eye crop/mask derivation
- noisy-input regression test
- outside-eye/mouth unchanged-pixel regression tests
- one short local visual demo only after automated checks pass

ケイへの次の目視依頼は、v3を佐藤自身が静止・自動試験で確認した後、一回だけにする。
