# NARU Renderer Swap Status

- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-08-31 JST
- Coordinator: アーク
- State: `PHASE A/B APPROVED / PHASE C0 PASSED / PHASE C1 SDK VERIFIED / MODEL ASSET HUMAN GATE`

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
- Phase C0/C1 isolation + adapter implementation:
  - commit `d503281a4192d36c2e7597460449ca741450d81d`
- Live2D preflight report:
  - commit `4a863d9da123880f9906bb6e560c235c69ca8156`
  - note: its claim that Windows wheel was cp310-only is superseded by later direct PyPI/pip verification
- Arc correction/install GO:
  - `IACPROJECT/inbox/from_arc/2026-08-31_ARC_TO_SATO_NARU_LIVE2D_PREFLIGHT_CORRECTION_AND_INSTALL_GO.md`
  - commit `9bcd3d3d7b08d8f0a67a44381a5bdbb4e92b0f6d`
- Live2D SDK installed + verified:
  - commit `c9c4348e56fae21411c46b4676caba2dea3ea753`

## Current state

- NARU core conversation/TikTok/TTS path: PRESERVED
- Renderer boundary (Phase A): DONE / APPROVED
- Legacy lipsync + blink polish (Phase B): DONE / APPROVED
- Kurose practical verdict for A/B: APPROVE
- Kurose Phase C condition: deliberately break renderer and prove LLM/TTS/core survives
- Phase C0 renderer failure isolation: DONE / TESTED
- Failure injection evidence: factory failure / start exception / audio-level exception while LLM/TTS queue workers continue / stop exception all contained; 0 paid API calls
- Python environment blocker: CLEARED
  - current NARU venv Python 3.14.3
  - `live2d-py` 0.7.0.4 cp314-win_amd64 wheel directly resolved before install
- Phase C1 Live2D SDK: INSTALLED / VERIFIED
- Cubism Native Core: INITIALIZATION VERIFIED
- `StandardParams.ParamMouthOpenY`: VERIFIED
- Live2D model asset: NOT YET ACQUIRED
- Phase C0 isolation re-test against real missing-model failure: PASS
- Official Live2D sample Haru: candidate for integration test; Live2D official site explicitly describes it as usable for Cubism SDK integration testing, subject to the Free Material License Agreement and Cubism Sample Data Terms of Use
- Live2D final adoption: NOT DECIDED
- VRM final rejection: NOT DECIDED
- Kei visual confirmation: DEFERRED until a real renderer candidate is locally visible

## Next

1. Do not reopen Phase A/B; APPROVE stands.
2. Treat Phase C0 failure-isolation condition as satisfied at implementation/test level.
3. Human-only gate: review/accept the official Live2D sample-data terms and obtain a license-cleared official sample model such as Haru.
4. After the official sample asset is available locally, Sato implements model load + OpenGL window + continuous `ParamMouthOpenY` drive without touching NARU core paths.
5. Re-run renderer failure isolation and legacy rollback after the real model path works.
6. Return Phase C evidence to Kurose before formal renderer adoption.
7. One consolidated visual confirmation from Kei only after the real Live2D candidate is visible.

## Boundary

Arc and Sato do not accept third-party license terms on Kei's behalf. They may verify primary-source terms, prepare integration code, and continue automatically after a license-cleared local asset exists.

## Owner burden rule

ケイへ進捗監視・ACK照合・コード編集・SDK差分探索・ライセンス文面の再編集を戻さない。ケイへ返すのは、実際に必要な人間同意・ダウンロード操作・最終採否判断だけに圧縮する。
