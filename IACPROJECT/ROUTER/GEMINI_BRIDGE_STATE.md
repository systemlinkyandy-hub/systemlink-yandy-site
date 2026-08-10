# GEMINI_BRIDGE_STATE

**Writer**: iac-gemini-bridge のみ（one writer原則。他ツール・手動編集は禁止）
**Purpose**: Handoff⇄Gemini API連携の冪等性・ACK/PENDING状態を管理する。
**Note**: `IACPROJECT/CURRENT_PENDING.md`（アーク管理）とは別系統。混同しないこと。
**Status values**: PENDING / SENT / ACK / HELD_NO_TO_HEADER / HELD_DECISION_LANGUAGE / HELD_ROUNDTRIP_LIMIT / HELD_COST_CAP / FAILED_NO_API_KEY / FAILED_RETRY_EXHAUSTED

| handoff_id | thread_key | direction | status | attempts | round_trip | last_updated | note |
|---|---|---|---|---|---|---|---|
| IACPROJECT/inbox/from_arc/2026-08-10_ARC_TO_GEMINI_BRIDGE_LIVE_TEST.md | IAC-GEMINI-BRIDGE-001-LIVE-TEST-2026-08-10 | to_gemini | SENT | 1 | 1 | 2026-08-10 22:10:58 | 応答保存: IACPROJECT/inbox/from_gemini/2026-08-10_GEMINI_TO_CLAUDE_CODE_TEST.md |
| IACPROJECT/inbox/from_gemini/2026-08-06_birdmen_note_essay_handoff.md | birdmen_note_essay_handoff | from_gemini | HELD_NO_TO_HEADER | 0 | 0 | 2026-08-10 22:10:58 | 宛先ヘッダ欠落（既存ファイル） |
| IACPROJECT/inbox/from_gemini/2026-08-06_domestic_profile_node_context.md | domestic_profile_node_context | from_gemini | HELD_DECISION_LANGUAGE | 0 | 0 | 2026-08-10 22:10:58 | 断定語検出（既存ファイル、Owner判断待ち） |
| IACPROJECT/inbox/from_gemini/2026-08-07_GEMINI_BIRDMEN_FACT_PACKET.md | GEMINI_BIRDMEN_FACT_PACKET | from_gemini | ACK | 0 | 0 | 2026-08-10 22:10:58 | 検証済み・既存配送物として登録 |
| IACPROJECT/inbox/from_gemini/2026-08-07_GEMINI_PORTFOLIO_ACCESS_PROBE_RESULT.md | GEMINI_PORTFOLIO_ACCESS_PROBE_RESULT | from_gemini | HELD_DECISION_LANGUAGE | 0 | 0 | 2026-08-10 22:10:58 | 断定語検出（既存ファイル、Owner判断待ち） |
| IACPROJECT/inbox/from_gemini/2026-08-07_gemini_portfolio_review_access_improvement_response.md | gemini_portfolio_review_access_improvement_response | from_gemini | HELD_DECISION_LANGUAGE | 0 | 0 | 2026-08-10 22:10:58 | 断定語検出（既存ファイル、Owner判断待ち） |
| IACPROJECT/inbox/from_gemini/2026-08-09_FUTABA_SICKDAY_HIGHROTATION_EVENT_CLOSEOUT_PACKET.md | IAC-SICKDAY-EVAL-20260809 | from_gemini | HELD_DECISION_LANGUAGE | 0 | 0 | 2026-08-10 22:10:58 | 断定語検出（既存ファイル、Owner判断待ち） |
| IACPROJECT/inbox/from_gemini/2026-08-10_FUTABA_TO_ARC_AI_BUDGET_REQUEST_REVISED.md | REVISED | from_gemini | HELD_DECISION_LANGUAGE | 0 | 0 | 2026-08-10 22:10:58 | 断定語検出（既存ファイル、Owner判断待ち） |
| IACPROJECT/inbox/from_gemini/2026-08-10_FUTABA_TO_ARC_OWNER_STACK_REVIEW.md | REVIEW | from_gemini | HELD_DECISION_LANGUAGE | 0 | 0 | 2026-08-10 22:10:59 | 断定語検出（既存ファイル、Owner判断待ち） |
| IACPROJECT/inbox/from_gemini/2026-08-10_GEMINI_TO_CLAUDE_CODE_TEST.md | TEST | from_gemini | ACK | 0 | 0 | 2026-08-10 22:10:59 | 検証済み・既存配送物として登録 |
