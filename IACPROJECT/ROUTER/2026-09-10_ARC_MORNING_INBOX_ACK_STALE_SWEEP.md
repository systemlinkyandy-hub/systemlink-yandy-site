# ARC Morning Inbox / ACK / Stale Sweep — 2026-09-10

**Owner**: アーク  
**Date**: 2026-09-10 JST  
**Scope**: 新着Handoff / inbox / ACK漏れ / 未処理 / 滞留  
**Decision boundary**: 研究判断・仮説判断・医学判断・仕様確定・採否・正本判断は代行しない。

## 1. New inbound

### Tanaka → ALL: Human Decision Loop / Chore Offload

Source:
`IACPROJECT/HANDOFF/2026-09-10_TANAKA_TO_ALL_HUMAN_DECISION_LOOP_AND_CHORE_OFFLOAD.md`

State:
- REGISTERED: YES
- READ COMPLETE BY ARC: YES
- RECEIVED BY ARC: YES
- ACKNOWLEDGED BY ARC: YES
- ROUTER REFLECTED: YES

ACK:
`IACPROJECT/inbox/from_arc/2026-09-10_ARC_ACK_HUMAN_DECISION_LOOP_AND_CHORE_OFFLOAD.md`

Applied rule:
- ケイに判断は聞く。雑用はさせない。
- Human Bus Bypass ≠ Human Decision Bypass.
- アークは必要な一点判断だけ本人または正本判断者へ返し、調査・配送・ACK・記録・進捗管理は引き取る。

## 2. Recent commit sweep after previous Arc sweep

Previous Arc sweep commit:
`fbd4ea173871c6878996d04d0b4c9687a3c09172`

New commits inspected:
- `0db5a6a48d5724dc65d580bb06a945dd480d8100` — human bus protocol revision
- `c1d2adfc34ae64e1e0630c1c534f98910c0b6c45` — ALL-member handoff
- `dc7f100ba1289a948a4484b007626255e235298f` — common wakeup rule update

No additional Arc-directed implementation/review result was found in this interval.

## 3. Outstanding ACK / stalled routing

### Arc → Tanaka external-contact load boundary

Existing stale item remains unresolved in GitHub evidence.

State:
- SENT: YES
- RECEIVED BY TANAKA: NOT CONFIRMED
- ACK BY TANAKA: NOT CONFIRMED
- ACTION: TRACK ONLY

Do not route ACK collection through Kei. Do not infer delivery from file registration alone.

## 4. Stale indexes

`IACPROJECT/CURRENT_PENDING.md` remains stamped `Last updated: 2026-09-02 JST` and contains NARU states superseded by later close evidence.

`IACPROJECT/ROUTER/CURRENT_DELIVERIES.md` remains stamped `Last updated: 2026-08-30 JST` and contains stale NARU restart state.

Safety rule for routing:
- Do not restart work from these stale rows without checking newer primary artifacts/commits.
- This sweep records the stale-index condition; it does not rewrite the large ledgers from a partial view.

## 5. Decision escalation

No new research / hypothesis / medical / specification / adoption / canonical decision requires escalation in this sweep.

Kei work returned: NONE.
