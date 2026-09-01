# Arc → Sato: NARU interim native preview GO

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-01 JST
- State: INTERIM PREVIEW AUTHORIZED / FORMAL LIVE2D ASSET DECISION DEFERRED

## Basis

Asset inventory result:
- commit `21c5f1cee8f1e395558f594cfb88db05ab87f271`
- existing NARU/Noll visual assets are flattened/composited images or baked video
- no layered PSD/equivalent suitable for genuine Cubism rigging was found

## Decision boundary

This Handoff does **not** decide final renderer adoption and does **not** abandon the genuine Live2D track.

For immediate visual confirmation only, proceed with a reversible interim preview using existing NARU assets.

The genuine Live2D/Cubism path remains separately blocked on identity-preserving layered source artwork. That later artwork/redesign decision is not delegated to Sato.

## Required implementation: interim native preview

Use only existing NARU assets. Do not redraw, regenerate, reinterpret, or replace the character design.

Minimum target:
1. Preserve current NARU/Noll identity and existing frame assets.
2. Replace abrupt 3-step mouth switching with visually smoother interpolation/crossfade using existing mouth-state frames where technically feasible.
3. Add only a very small affine idle sway / breathing-like drift that does not deform the face into another person.
4. Preserve existing blink behavior unless a minimal non-destructive improvement is obvious.
5. Keep legacy renderer rollback available with zero irreversible conversion.
6. Do not touch NARU core conversation / TikTok ingest / LLM / TTS / queue design.
7. No TikTok connection and no paid API calls for this preview.
8. Provide a one-action local demo path for Kei; do not return command assembly, logs, environment setup, or troubleshooting steps to Kei.

## Visual restraint

NARU is restrained/cool. Do not add exaggerated bounce, cartoon squash/stretch, large head bob, or expressive motion merely to prove movement.

The purpose is only:
**"the old NARU itself is visibly alive, with smoother mouth movement and tiny idle motion."**

## Required evidence

Return:
- changed files
- exact preview startup method
- before/after description of mouth-state behavior
- proof that original assets remain unmodified
- legacy rollback result
- 0 paid API / no TikTok confirmation

If the implementation is viable, stop at a locally viewable demo and ask Arc for visual-confirmation routing. Do not require Kei to choose any Live2D asset strategy before seeing this interim preview.

## Owner burden rule

Do not return asset inventory, implementation decisions, command editing, test logs, or ACK tracking to Kei. The next user-facing action should ideally be one click / one launch to see NARU move.
