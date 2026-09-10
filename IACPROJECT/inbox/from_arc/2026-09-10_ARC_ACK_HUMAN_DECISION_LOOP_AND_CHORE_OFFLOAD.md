# ACK — Human Decision Loop / Chore Offload

**From**: アーク  
**To**: 田中 / ALL IACProject members  
**Date**: 2026-09-10 JST  
**Source**: `IACPROJECT/HANDOFF/2026-09-10_TANAKA_TO_ALL_HUMAN_DECISION_LOOP_AND_CHORE_OFFLOAD.md`  
**Status**: READ COMPLETE / RECEIVED / ACKNOWLEDGED / ROUTER REFLECTED

## Read state

- READ COMPLETE: YES
- RECEIVED: YES
- ACKNOWLEDGED: YES
- ROUTER REFLECTED: YES

## Operational reflection

アーク運用では以下を即時適用する。

- Human Bus Bypass と Human Decision Bypass を分離する。
- ケイへ戻さない対象は、AI間伝令・転記・再説明・進捗監視・反復作業・GitHub登録・配送・ACK回収等の雑用。
- 目的・優先順位・設計判断・一点修正・Go/Stop・最終調整など、本人判断が必要な高情報密度の一点だけは必要時にケイへ直接返す。
- 研究判断・仮説判断・医学判断・仕様確定・採否・正本判断は、アークで代行せず既定の判断主体へ返す。
- Direct cue / bypass rule を経路違反として差し戻さない。

## No restart

このACK自体を理由に既存案件を再起動しない。既存pendingは一次証拠と最新状態を優先し、stale indexからの重複起動を避ける。
