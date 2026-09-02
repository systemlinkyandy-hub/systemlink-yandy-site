# Arc morning inbox / stale-state sweep — 2026-09-02

- Owner: アーク
- Date: 2026-09-02 JST
- Scope: Router / inbox / ACK / stale-state maintenance only

## New arrivals

- New Arc-addressed Handoff / inbox / ACK since the latest Arc routing activity on 2026-09-01: **none confirmed**.
- Latest repository activity before this sweep was Arc's targeted Kurose review request for the NARU shared renderer blocker.

## NARU state correction

`IACPROJECT/CURRENT_PENDING.md` was stale for `0C-2 NARU本人 Live2D body prototype` and still showed `SATO RESPONSE PENDING`.

Verified repository evidence now shows:

- NARU material extraction / shoulder fix / mouth-state composition: done
- part-separation experiments: done; full precise split blocked with available methods
- `overlay_v1` implementation + local smoke: done at `92565f6aba9a0bdeeabfa1b693f3430d0245205e`
- Kurose review relayed via Kei remains secondary evidence and is not treated as source-authored GitHub review
- formal adoption remains HOLD because the shared `LegacyFrameRenderer(engine_class=...)` change needs targeted review
- primary code evidence for that shared renderer change exists in the repository
- targeted review was routed to Kurose at `c052c3756307c592e9ad1c398900430d21ca525e`

`CURRENT_PENDING.md` was synchronized accordingly. No implementation or formal-adoption decision was made by Arc.

## Stale delivery index note

`IACPROJECT/ROUTER/CURRENT_DELIVERIES.md` still contains the old NARU restart state `SATO RESPONSE PENDING`. Treat that line as stale and do **not** restart repository discovery / baseline implementation from it. The current NARU state is the `CURRENT_PENDING.md` state above plus the source artifacts.

A later safe full-file synchronization of `CURRENT_DELIVERIES.md` remains an infrastructure cleanup item; this sweep does not rewrite the large delivery ledger from partial content.

## Other tracked pending items

No new source-authored return was confirmed during this sweep for:

- Handoff State Tracker source-authored Kurose review artifact
- Member Continuity / Identity Envelope reviews
- COCO Kurose independent review
- Structural Resolution GI Yue / Tanaka returns
- ALL-Handoff pending ACKs
- RCW public-manual implementation return

Low-load comparison week period ended on 2026-09-01; only outstanding artifacts / ACKs remain a Router tracking concern. Research or medical interpretation is outside Arc scope.

## Boundary

- No research / hypothesis / medical / specification / adoption / canon decision made.
- No user relay / re-edit / progress-monitoring task created.
- READ / RECEIVED / REFLECTED remain separate states.