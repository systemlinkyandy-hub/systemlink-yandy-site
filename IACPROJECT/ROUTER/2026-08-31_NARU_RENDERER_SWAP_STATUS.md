# NARU Renderer Swap Status

- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-08-31 JST
- Coordinator: アーク
- State: PHASE A/B APPROVED / PHASE C0 PASSED / PHASE C1 PREFLIGHT HOLD

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
  - commit `aa18bc6061844a636746574deb918775479a29df`
- Phase C0/C1 implementation:
  - commit `d503281a4192d36c2e7597460449ca741450d81d`
- Live2D preflight:
  - `IACPROJECT/inbox/from_claude_code/2026-08-31_SATO_TO_ARC_NARU_LIVE2D_PREFLIGHT_REPORT.md`
  - commit `4a863d9da123880f9906bb6e560c235c69ca8156`

## Current state

- NARU core conversation/TikTok/TTS path: PRESERVED
- Renderer boundary (Phase A): DONE / APPROVED
- Legacy lipsync + blink polish (Phase B): DONE / APPROVED
- Kurose practical verdict: APPROVE
- Kurose condition for Phase C: deliberately break renderer and prove LLM/TTS/core survives
- Phase C0 renderer failure isolation: DONE / TESTED
- Failure injection evidence: factory failure / start exception / audio-level exception while real LLM/TTS queue workers process jobs / stop exception all contained by renderer isolation; 0 paid API calls
- Phase C1 Live2D adapter spike: CODE PATH PREPARED / SDK+CORE+MODEL NOT INSTALLED
- Live2D SDK/Core/model asset: INSTALL HOLD
- Preflight finding: current NARU venv is Python 3.14.3, while `live2d-py` v0.7.0.4 Windows wheel is cp310 only; direct install into current venv is not viable
- Lowest-risk technical option proposed by Sato: separate Python 3.10 venv for the Live2D spike, leaving NARU main venv untouched
- License gate: Cubism Core/Framework and any model asset acquisition remain human-consent gated; AI must not accept license terms on Kei's behalf
- Live2D final adoption: NOT DECIDED
- VRM final rejection: NOT DECIDED
- Kei visual confirmation: DEFERRED until a real renderer candidate is locally visible

## Next

1. Do not reopen Phase A/B; Kurose APPROVE stands.
2. Treat Phase C0 failure-isolation condition as satisfied at implementation/test level.
3. Keep Live2D install blocked until two separate gates are resolved:
   - human license/asset consent
   - technical environment decision for the Python 3.10 isolated spike versus another binding/defer
4. Arc must not decide renderer adoption, license acceptance, or the technical-spec adoption question.
5. After a permitted Live2D spike exists, return evidence to Kurose for Phase C review before any formal adoption.
6. One consolidated visual confirmation from Kei only after a real candidate is visible.

## Owner burden rule

ケイへ進捗監視・ACK照合・コード編集・SDK差分探索・ライセンス文面の再編集を戻さない。ケイへ返すのは、実際に必要となった人間同意または採否判断だけに圧縮する。
