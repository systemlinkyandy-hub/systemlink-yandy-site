# Arc Router CLOSE — NARU overlay_v1 production speak full smoke

- From: アーク
- Review verdict source: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-03 JST
- State: **CLOSED / APPROVED**

## Verdict

`PRODUCTION_SPEAK_FULL_SMOKE_APPROVE`

CLOSEしてよい。

## Evidence accepted

佐藤 result:
`IACPROJECT/inbox/from_claude_code/2026-09-03_SATO_TO_ARC_NARU_OVERLAY_V1_FULL_SPEAK_WITH_LIPSYNC_SMOKE_RESULT.md`

Remote commit:
`5aee4ed6bf9048781d94d084878333e485da9c18`

Verified path:
- `app_live2d.speak()` production entry
- existing cost guard
- `speak_with_lipsync()`
- ElevenLabs actual generation
- output audio generation
- ffmpeg real RMS analysis
- audio level -> renderer mouth path
- playback complete
- renderer clean stop

Observed:
- ElevenLabs request: 1
- retry: 0
- input: 20 chars after normalize
- result: `speak()` returned True
- ffmpeg chunks: 50
- `set_volume()` calls: 51
- non-silent calls: 44
- max level: 0.741
- renderer offline: none
- blocker: none
- code change: none

## Independent review notes

黒瀬 confirmed that this test exercised the production top-level `speak()` entry, not only the lower-level speaking-path helper.

The structural identity `chunks + 1 == set_volume call count` reproduced again:
- prior speaking-path smoke: `197 + 1 = 198`
- production full smoke: `50 + 1 = 51`

This repeated structure is accepted as strong independent support that the reported numbers came from the actual intended path.

## Evidence classification

- Code/log validation: independent review by 黒瀬
- Owner visual confirmation: ケイ personally observed NARU speaking, mouth movement, and blinking
- These evidence classes remain distinct; they are not conflated.

## Close state

The renderer layer -> speaking-path -> production `speak()` entry is now connected end-to-end for this local smoke scope.

No TikTok production run was performed.
No `.moc3` work was opened.
No renderer redesign was opened.

## Next phase

One next local gate is permitted:

**multiple consecutive `speak()` calls within a single renderer lifetime**

Purpose:
- verify state across multiple turns
- blink state across turns
- hair motion state across turns
- volume EMA / mouth state across turns
- confirm no cumulative corruption, stuck mouth, renderer offline transition, or stop failure

This remains local-only. TikTok production is still out of scope.

## Owner burden rule

Do not return code inspection, log collection, ACK tracking, or review routing to ケイ.
