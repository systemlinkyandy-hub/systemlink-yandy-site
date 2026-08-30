# Mechanical Handoff State Tracking — Pilot Case

- task_id: `HANDOFF-STATE-TRACKING-2026-08-30-01`
- owner: アーク
- date: 2026-08-30 / updated 2026-08-31 JST
- current_state: `RESULT_COMMITTED / REVIEW_EXECUTED_OFF_GITHUB / PARSER_FIX_DONE / REVIEW_EVIDENCE_PENDING`

## Evidence

| Stage | Status | Evidence |
|---|---|---|
| SOURCE | YES | `IACPROJECT/inbox/to_arc/2026-08-30_YUE_TO_ARC_MECHANICAL_HANDOFF_STATE_TRACKING_PROPOSAL.md` @ `0ba102e2824c6353bc3afb8c01bfc8e1385a801f` |
| ROUTED | YES | `IACPROJECT/inbox/from_arc/2026-08-30_ARC_TO_SATO_HANDOFF_STATE_TRACKER_PILOT.md` @ `7e4ad8fc4e7e65772bcd47d458a89cf040a7790d` |
| READ_ACK (Arc) | YES | Pilot registered by Arc @ `b344739d6b6230c353cf42cf905edd1132bca420` |
| READ_ACK (Sato) | YES | Sato implementation report |
| STARTED | YES | `tools/iac-handoff-state.ps1` implementation |
| RESULT_COMMITTED | YES | implementation `d19b551`, follow-up evidence, and parser-fix `7e39019664047672a1b3d76818115d2b89f860d3` |
| REVIEWED (practical) | YES | Kurose review work completed in chat |
| REVIEWED (machine evidence) | NO | Kurose original State Tracker review Markdown is still not present as a source-authored GitHub artifact |
| CLOSED | NO | machine review evidence + canonicalization decision still required |

## Pilot incident 1 — false REVIEWED/CLOSED

Initial real-data scan incorrectly accepted ordinary prose containing `判定` as review evidence and marked this task REVIEWED/CLOSED.
Sato corrected the parser to require explicit review structure.

Post-fix state returned to:
`ROUTED=YES / READ_ACK=YES / STARTED=YES / RESULT_COMMITTED=YES / REVIEWED=no / CLOSED=no`.

## Parser compatibility fix — DONE

Arc request:
`IACPROJECT/inbox/from_arc/2026-08-30_ARC_TO_SATO_HANDOFF_STATE_TRACKER_KUROSE_HEADING_FORMAT_FIX.md`
commit `1b01e6af225b3dc14ce531e76fae503c9cd26b75`

Sato implementation:
commit `7e39019664047672a1b3d76818115d2b89f860d3`

Implemented `Get-ReviewVerdict` and supports only structured review forms:
- same-line `判定: APPROVE` / `Verdict: HOLD`
- heading `## 判定` / `## Verdict`, then verdict within the next 1-3 non-empty lines
- fixed verdict token set including APPROVE / APPROVE WITH CONDITIONS / HOLD
- bare prose `判定` or floating body `APPROVE` does not count
- recipient self-verdict does not count as third-party REVIEWED evidence

Sato reports all requested synthetic tests passing, with real repository re-scan also executed.

## Additional bugs found and fixed in `7e39019`

### ROUTED evidence selection
Previous implementation could select whichever `To:` file enumerated first, allowing a later Arc->Kurose review route to hide the original task route/evidence.
Fix: exclude `arc` only from recipient candidacy and choose the chronologically earliest remaining routing candidate by first-add commit author date.

### Stale PENDING_BY_MEMBER output
Previous `-WriteIndex` could leave files from an earlier generation even when a member no longer had entries.
Fix: generated `PENDING_BY_MEMBER/*.md` is cleared before regeneration.

## Machine-tracking note

This file is a bootstrap/manual ledger, not source of truth. Repository evidence and scanner output take precedence over prose here.

## Remaining gate

1. Kurose original State Tracker review Markdown is committed as a GitHub artifact.
2. Re-scan must detect that artifact with the updated parser and must not create a false positive/false CLOSED.
3. After machine REVIEWED evidence is confirmed, return canonicalization decision to 欠月.

NARU's review artifact and State Tracker's review artifact are separate evidence problems; do not substitute secondary relay records for source-authored review evidence.

## Owner burden rule

ケイへregex修正、再Scan、未処理探索、ACK照合、進捗監視を戻さない。
