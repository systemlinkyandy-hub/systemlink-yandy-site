# NARU Renderer Swap Status

- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-08-31 JST
- Coordinator: アーク
- State: PHASE A/B APPROVED / PHASE C0-C1 ROUTED

## Evidence

- Plan: `IACPROJECT/PROJECTS/NARU/2026-08-31_NARU_RENDERER_SWAP_PLAN.md`
  - commit `a5f3e6f18cf90828492eb17cd1f7dc1fed5f6111`
- Initial implementation route:
  - `IACPROJECT/inbox/from_arc/2026-08-31_ARC_TO_SATO_NARU_RENDERER_SWAP_IMPLEMENTATION.md`
  - commit `19ae78fa3eafb02312b8a87a9b420c39b0fcb622`
- Phase A/B implementation:
  - commit `6df23381f1cdf1d0b81f6f91d0177a1c6aa50c50`
- Kurose practical review relay:
  - `IACPROJECT/inbox/from_claude_code/2026-08-31_SATO_TO_ARC_NARU_RENDERER_SWAP_KUROSE_APPROVE_RELAYED.md`
  - commit `aa18bc6`
- Phase C0/C1 route:
  - `IACPROJECT/inbox/from_arc/2026-08-31_ARC_TO_SATO_NARU_RENDERER_PHASE_C0_C1.md`
  - commit `7f79bbc5915424a100f261e1fa23c9637254a313`

## Current state

- NARU core conversation/TikTok/TTS path: PRESERVE
- Renderer boundary (Phase A): DONE / APPROVED
- Legacy lipsync + blink polish (Phase B): DONE / APPROVED
- Kurose primary review artifact: NOT YET ON GITHUB
- Kurose practical verdict via relay: Phase A/B APPROVE
- Phase C condition: deliberately break renderer and prove LLM/TTS/core survives
- Phase C0 renderer failure isolation: ROUTED TO SATO
- Phase C1 Live2D technical spike: ROUTED TO SATO
- Live2D final adoption: NOT DECIDED
- VRM final rejection: NOT DECIDED
- Kei visual confirmation: DEFERRED until a real renderer candidate is locally visible

## Phase C strategy

Do not treat the current technical preference as a final specification decision.

1. C0: isolate renderer failures from NARU core and prove it with injected failures.
2. C1: test Live2D as the first reversible candidate because it preserves the current 2D visual direction and can plausibly remain in-process.
3. Keep `legacy` renderer available as immediate rollback.
4. If the Live2D spike succeeds, return evidence before any formal adoption decision.

## Next

1. Sato ACK / C0 isolation implementation
2. paid-API-free failure injection tests
3. Live2D technical spike or explicit ASSET BLOCKED report
4. Arc evidence check
5. Kurose review of Phase C evidence
6. one consolidated visual confirmation from Kei only after a real candidate is visible
7. formal renderer adoption decision after evidence

## Owner burden rule

ケイへ進捗監視・ACK照合・コード編集・SDK testを戻さない。
