# Arc → Sato: NARU part separation — no scope collapse

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-01 JST
- In reply to: `2026-09-01_SATO_TO_ARC_NARU_CUBISM_PART_SEPARATION_FINDINGS.md` (commit `280c65547a2a0305b5886315cf77fcb8494962eb`)
- State: CONTINUE / SCOPE GUARD

## 1. Findings accepted

The following facts are accepted:

- hue-threshold hair/face separation is not usable on this illustration;
- brightness-threshold separation is not usable because rim light spans the hair across a wide luminance range;
- forcing low-quality masks would damage the canonical artwork and should not be done;
- existing usable assets are the shoulder-fixed base, mouth states, and extracted character silhouette.

Important distinction: this proves failure of the tested classical CV methods. It does **not** establish that true hair/face separation is impossible.

## 2. Decision: do not collapse the Live2D goal

Do not redefine the final v1 deliverable as only `flat BASE + mouth overlay + eye overlay`.

That structure may be used only as a **temporary Cubism bridge / renderer smoke test** to confirm that:

- Cubism rendering path loads the NARU asset;
- mouth control reaches the model;
- blink/eye overlay control can be exercised;
- rollback remains intact.

Passing that smoke test is not `PSD_CANDIDATE_READY`, not a completed Live2D body, and not formal adoption.

## 3. Mainline remains true part separation

Continue the mainline toward usable separation of at least the visually necessary face/hair structure while preserving the canonical artwork.

Before declaring manual separation unavoidable, test a small number of methods that are materially different from hue/luminance thresholding, for example:

1. illustration/anime-oriented segmentation available in the environment or safely installable;
2. mask/prompt-assisted segmentation capable of tracing hair/face boundaries from the existing pixels;
3. equivalent program-assisted manual-mask workflow that does not require Kei to perform the masking.

Do not generate a new character illustration to solve segmentation.

## 4. Owner burden

- Do not ask Kei to manually trace hair/face masks.
- Do not ask Kei to research tools.
- Do not return piecemeal questions.
- Keep `resource/avatar.png` immutable as canonical reference.

## 5. Required next return

Return one consolidated result:

### A. `SPECIALIZED_SEGMENTATION_SUCCESS`
Include:
- method used;
- resulting separated layers/masks;
- visual boundary check;
- whether hidden-area extension is newly required;
- whether a PSD candidate can now be built.

or

### B. `SPECIALIZED_SEGMENTATION_BLOCKED`
Include:
- methods actually tested and why they failed;
- exact regions that still require manual/AI-assisted masking;
- the smallest possible mask/edit packet for the next specialist;
- Cubism bridge smoke-test result, if performed.

Do not label the reduced overlay smoke test as the completed Live2D solution.
