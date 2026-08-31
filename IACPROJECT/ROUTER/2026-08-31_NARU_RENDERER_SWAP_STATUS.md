# NARU Renderer Swap Status

- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-08-31 JST
- Coordinator: アーク
- State: `PHASE A/B APPROVED / PHASE C0 PASSED / PHASE C1 REAL RENDER SPIKE APPROVED / FORMAL ADOPTION HARDENING`

## Evidence

- Plan: `IACPROJECT/PROJECTS/NARU/2026-08-31_NARU_RENDERER_SWAP_PLAN.md`
  - commit `a5f3e6f18cf90828492eb17cd1f7dc1fed5f6111`
- Phase A/B implementation:
  - commit `6df23381f1cdf1d0b81f6f91d0177a1c6aa50c50`
- Phase A/B Kurose practical review relay:
  - commit `aa18bc6061844a636746574deb918775479a29df`
- Phase C0 isolation + Phase C1 adapter:
  - commit `d503281a4192d36c2e7597460449ca741450d81d`
- Live2D SDK installed + Core verified:
  - commit `c9c4348e56fae21411c46b4676caba2dea3ea753`
- Haru real-render spike + failure injection:
  - commit `cedabc63fdd90362fa12e9256672379cccdb3fa6`
- Haru approval-scope clarification:
  - commit `23598c166c8516f29608ca391e0b83bb84f81763`
- Kurose Phase C spike review relay:
  - `IACPROJECT/ROUTER/2026-08-31_NARU_PHASE_C_KUROSE_SPIKE_REVIEW_RELAY.md`
  - commit `7c4339ad4dca446b0b6ce2134857c947cc5031a0`
- Formal-adoption hardening route to Sato:
  - `IACPROJECT/inbox/from_arc/2026-08-31_ARC_TO_SATO_NARU_PHASE_C_FORMAL_ADOPTION_CONDITIONS.md`
  - commit `cbdebcaafe68330e352d3d6248b143ffcf0478a7`
- Obsolete Python 3.10 environment decision:
  - CLOSED / SUPERSEDED
  - commit `dd12d883ffecd47301397513fcd6c84fee07c442`

## Current state

- NARU core conversation/TikTok/TTS path: PRESERVED
- Renderer boundary: DONE / APPROVED
- Legacy lipsync + blink polish: DONE / APPROVED
- Phase C0 failure isolation: DONE / TESTED
- Live2D SDK / Cubism Core: INSTALLED / VERIFIED
- Haru official sample asset: LOCAL ONLY / NOT COMMITTED TO GITHUB
- Real model rendering: PASS
- Continuous `ParamMouthOpenY` drive: PASS
- Legacy rollback without code change: PASS
- Kurose Phase C verdict: **APPROVE / SPIKE PASS** (secondary chat relay evidence)
- Live2D formal adoption: NOT YET DECIDED
- Public/commercial/continuous TikTok operation: SEPARATE LICENSE / ADOPTION GATE

## Formal-adoption conditions

1. Integrate renderer internal-thread health into a single externally observable offline/degraded state (`is_offline` or equivalent).
2. Root-fix the process-exit segfault reproducible after deliberate render-loop failure.

These do not invalidate the technical-spike PASS, but are required before formal renderer adoption.

## Known architecture finding

`RendererIsolationProxy` protects interface calls from `app_live2d.py`. A renderer's own internal render-thread exception is a separate observation path and is not automatically visible to the proxy. Core safety (LLM/TTS/queue survival) has nevertheless been verified by failure injection.

## Next

1. Sato implements the two hardening conditions only; do not reopen Phase A/B or redo the spike.
2. Return hardening evidence to Kurose for final pre-adoption review.
3. After technical conditions are cleared, renderer formal-adoption decision goes to the appropriate final decision owner; Arc does not self-adopt.
4. One consolidated visual confirmation from Kei only if/when needed for final appearance behavior.

## Boundary

- Haru is an evaluation model, not NARU's final character design.
- Technical-spike approval does not mean formal adoption, public release, commercial use, or continuous TikTok operation approval.
- Licensed model assets remain local unless redistribution terms and project policy explicitly permit otherwise.

## Owner burden rule

ケイへ進捗監視・ACK照合・コード編集・障害ログ採取・レビュー回収を戻さない。必要な目視確認や最終採否だけ一回に圧縮する。
