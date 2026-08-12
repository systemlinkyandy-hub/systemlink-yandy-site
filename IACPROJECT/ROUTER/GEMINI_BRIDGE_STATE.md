# GEMINI_BRIDGE_STATE

**Writer**: iac-gemini-bridge のみ（one writer原則。他ツール・手動編集は禁止）
**Purpose**: Handoff⇄Gemini API連携の冪等性・ACK/PENDING状態を管理する。
**Note**: `IACPROJECT/CURRENT_PENDING.md`（アーク管理）とは別系統。混同しないこと。
**Status values**: PENDING / SENT / ACK / HELD_NO_TO_HEADER / HELD_DECISION_LANGUAGE / HELD_ROUNDTRIP_LIMIT / HELD_COST_CAP / HELD_MULTI_RECIPIENT / FAILED_NO_API_KEY / FAILED_RETRY_EXHAUSTED

| handoff_id | thread_key | direction | status | attempts | round_trip | last_updated | note |
|---|---|---|---|---|---|---|---|
| IACPROJECT/inbox/from_gemini/2026-08-06_birdmen_note_essay_handoff.md | birdmen_note_essay_handoff | from_gemini | HELD_NO_TO_HEADER | 0 | 0 | 2026-08-10 22:10:58 | 宛先ヘッダ欠落（既存ファイル） |
| IACPROJECT/inbox/from_gemini/2026-08-06_domestic_profile_node_context.md | domestic_profile_node_context | from_gemini | HELD_DECISION_LANGUAGE | 0 | 0 | 2026-08-10 22:10:58 | 断定語検出（既存ファイル、Owner判断待ち） |
| IACPROJECT/inbox/from_gemini/2026-08-07_GEMINI_BIRDMEN_FACT_PACKET.md | GEMINI_BIRDMEN_FACT_PACKET | from_gemini | ACK | 0 | 0 | 2026-08-10 22:10:58 | 検証済み・既存配送物として登録 |
| IACPROJECT/inbox/from_gemini/2026-08-07_GEMINI_PORTFOLIO_ACCESS_PROBE_RESULT.md | GEMINI_PORTFOLIO_ACCESS_PROBE_RESULT | from_gemini | HELD_DECISION_LANGUAGE | 0 | 0 | 2026-08-10 22:10:58 | 断定語検出（既存ファイル、Owner判断待ち） |
| IACPROJECT/inbox/from_gemini/2026-08-07_gemini_portfolio_review_access_improvement_response.md | gemini_portfolio_review_access_improvement_response | from_gemini | HELD_DECISION_LANGUAGE | 0 | 0 | 2026-08-10 22:10:58 | 断定語検出（既存ファイル、Owner判断待ち） |
| IACPROJECT/inbox/from_gemini/2026-08-09_FUTABA_SICKDAY_HIGHROTATION_EVENT_CLOSEOUT_PACKET.md | IAC-SICKDAY-EVAL-20260809 | from_gemini | HELD_DECISION_LANGUAGE | 0 | 0 | 2026-08-10 22:10:58 | 断定語検出（既存ファイル、Owner判断待ち） |
| IACPROJECT/inbox/from_gemini/2026-08-10_FUTABA_TO_ARC_AI_BUDGET_REQUEST_REVISED.md | REVISED | from_gemini | HELD_DECISION_LANGUAGE | 0 | 0 | 2026-08-10 22:10:58 | 断定語検出（既存ファイル、Owner判断待ち） |
| IACPROJECT/inbox/from_gemini/2026-08-10_FUTABA_TO_ARC_OWNER_STACK_REVIEW.md | REVIEW | from_gemini | HELD_DECISION_LANGUAGE | 0 | 0 | 2026-08-10 22:10:59 | 断定語検出（既存ファイル、Owner判断待ち） |
| IACPROJECT/inbox/from_arc/HANDOFF_2026-08-10_PROCUREMENT_CURSOR_VIDEO.md | HANDOFF_2026-08-10_PROCUREMENT_CURSOR_VIDEO | to_gemini | HELD_MULTI_RECIPIENT | 0 | 0 | 2026-08-10 23:26:23 | 複数宛先検出。自動送信対象外。staging保存: C:\IAC_Handoff\staging\gemini_held\2026-08-10_232623_HELD_multi_recipient_HANDOFF_2026-08-10_PROCUREMENT_CURSOR_VIDEO.md |
| IACPROJECT/inbox/from_arc/2026-08-11_ARC_TO_GEMINI_BRIDGE_ACTIONS_DEBUG_TEST.md | IAC-GEMINI-BRIDGE-001-ACTIONS-DEBUG-TEST-2026-08-11 | to_gemini | HELD_NO_TO_HEADER | 1 | 1 | 2026-08-10 22:51:49 | 宛先ヘッダ欠落。staging保存: D:\a\systemlink-yandy-site\systemlink-yandy-site\staging\gemini_held\2026-08-10_225149_HELD_no_to_header_TEST.md |
| IACPROJECT/inbox/from_arc/2026-08-11_ARC_TO_GEMINI_BRIDGE_ACTIONS_FIX_VERIFY.md | IAC-GEMINI-BRIDGE-001-ACTIONS-FIX-VERIFY-2026-08-11 | to_gemini | HELD_NO_TO_HEADER | 1 | 1 | 2026-08-10 22:51:51 | 宛先ヘッダ欠落。staging保存: D:\a\systemlink-yandy-site\systemlink-yandy-site\staging\gemini_held\2026-08-10_225151_HELD_no_to_header_VERIFY.md |
| IACPROJECT/inbox/from_arc/2026-08-11_ARC_TO_GEMINI_BRIDGE_ACTIONS_LIVE_TEST.md | IAC-GEMINI-BRIDGE-001-ACTIONS-LIVE-TEST-2026-08-11 | to_gemini | HELD_NO_TO_HEADER | 1 | 1 | 2026-08-10 22:51:52 | 宛先ヘッダ欠落。staging保存: D:\a\systemlink-yandy-site\systemlink-yandy-site\staging\gemini_held\2026-08-10_225152_HELD_no_to_header_TEST.md |
| IACPROJECT/inbox/from_kei/2026-08-11_1250_KEI_TO_GEMINI_CHAT.md | IAC-CHAT-20260811-125052-gemini | to_gemini | HELD_NO_TO_HEADER | 1 | 1 | 2026-08-11 04:09:11 | 宛先ヘッダ欠落。staging保存: D:\a\systemlink-yandy-site\systemlink-yandy-site\staging\gemini_held\2026-08-11_040911_HELD_no_to_header_CHAT.md |
| IACPROJECT/inbox/from_kei/2026-08-11_1308_KEI_TO_GEMINI_CHAT.md | IAC-CHAT-20260811-130846-gemini | to_gemini | HELD_NO_TO_HEADER | 1 | 1 | 2026-08-11 04:09:16 | 宛先ヘッダ欠落。staging保存: D:\a\systemlink-yandy-site\systemlink-yandy-site\staging\gemini_held\2026-08-11_040916_HELD_no_to_header_CHAT.md |
| IACPROJECT/inbox/from_kei/2026-08-11_1314_KEI_TO_GEMINI_CHAT.md | IAC-CHAT-20260811-131446-gemini | to_gemini | SENT | 1 | 1 | 2026-08-11 04:18:04 | 応答保存: IACPROJECT/inbox/from_gemini/2026-08-11_GEMINI_TO_KEI_CHAT.md |
| IACPROJECT/inbox/from_gemini/2026-08-11_GEMINI_TO_KEI_CHAT.md | CHAT | from_gemini | ACK | 0 | 0 | 2026-08-11 04:18:04 | 検証済み・既存配送物として登録 |
| IACPROJECT/inbox/from_kei/2026-08-11_1333_KEI_TO_GEMINI_CHAT.md | IAC-CHAT-20260811-133318-gemini | to_gemini | HELD_NO_TO_HEADER | 1 | 1 | 2026-08-11 04:33:43 | 宛先ヘッダ欠落。staging保存: D:\a\systemlink-yandy-site\systemlink-yandy-site\staging\gemini_held\2026-08-11_043343_HELD_no_to_header_CHAT.md |
| IACPROJECT/inbox/from_kei/2026-08-11_1423_KEI_TO_GEMINI_CHAT.md | IAC-CHAT-20260811-142347-gemini | to_gemini | SENT | 1 | 1 | 2026-08-11 05:24:06 | 応答保存: IACPROJECT/inbox/from_gemini/2026-08-11_GEMINI_TO_KEI_CHAT.md |
| IACPROJECT/inbox/from_kei/2026-08-11_1430_KEI_TO_GEMINI_CHAT.md | IAC-CHAT-20260811-143033-gemini | to_gemini | SENT | 1 | 1 | 2026-08-11 05:31:03 | 応答保存: IACPROJECT/inbox/from_gemini/2026-08-11_GEMINI_TO_KEI_CHAT.md |
| IACPROJECT/inbox/from_kei/2026-08-11_2242_KEI_TO_GEMINI_CHAT.md | IAC-CHAT-20260811-224227-gemini | to_gemini | SENT | 1 | 1 | 2026-08-11 13:43:10 | 応答保存: IACPROJECT/inbox/from_gemini/20260811134310_2026-08-11_GEMINI_TO_KEI_CHAT.md |
| IACPROJECT/inbox/from_gemini/20260811134310_2026-08-11_GEMINI_TO_KEI_CHAT.md | 20260811134310_2026-08-11_GEMINI_TO_KEI_CHAT | from_gemini | ACK | 0 | 0 | 2026-08-11 13:43:10 | 検証済み・既存配送物として登録 |
| IACPROJECT/inbox/from_kei/2026-08-12_1201_KEI_TO_GEMINI_CHAT.md | IAC-CHAT-20260812-120156-gemini | to_gemini | SENT | 1 | 1 | 2026-08-12 03:02:19 | 応答保存: IACPROJECT/inbox/from_gemini/2026-08-12_GEMINI_TO_KEI_CHAT.md |
| IACPROJECT/inbox/from_gemini/2026-08-12_GEMINI_TO_KEI_CHAT.md | CHAT | from_gemini | ACK | 0 | 0 | 2026-08-12 03:02:19 | 検証済み・既存配送物として登録 |
| IACPROJECT/inbox/from_kei/2026-08-12_1204_KEI_TO_GEMINI_CHAT.md | IAC-CHAT-20260812-120434-gemini | to_gemini | SENT | 1 | 1 | 2026-08-12 03:05:02 | 応答保存: IACPROJECT/inbox/from_gemini/20260812030502_2026-08-12_GEMINI_TO_KEI_CHAT.md |
| IACPROJECT/inbox/from_gemini/20260812030502_2026-08-12_GEMINI_TO_KEI_CHAT.md | 20260812030502_2026-08-12_GEMINI_TO_KEI_CHAT | from_gemini | ACK | 0 | 0 | 2026-08-12 03:05:03 | 検証済み・既存配送物として登録 |
| IACPROJECT/inbox/from_kei/2026-08-12_1208_KEI_TO_GEMINI_CHAT.md | IAC-CHAT-20260812-120809-gemini | to_gemini | SENT | 1 | 1 | 2026-08-12 03:08:45 | 応答保存: IACPROJECT/inbox/from_gemini/20260812030845_2026-08-12_GEMINI_TO_KEI_CHAT.md |
| IACPROJECT/inbox/from_gemini/20260812030845_2026-08-12_GEMINI_TO_KEI_CHAT.md | 20260812030845_2026-08-12_GEMINI_TO_KEI_CHAT | from_gemini | ACK | 0 | 0 | 2026-08-12 03:08:45 | 検証済み・既存配送物として登録 |
| IACPROJECT/inbox/from_kei/2026-08-12_1211_KEI_TO_GEMINI_CHAT.md | IAC-CHAT-20260812-121141-gemini | to_gemini | SENT | 1 | 1 | 2026-08-12 03:12:14 | 応答保存: IACPROJECT/inbox/from_gemini/20260812031214_2026-08-12_GEMINI_TO_KEI_CHAT.md |
| IACPROJECT/inbox/from_gemini/20260812031214_2026-08-12_GEMINI_TO_KEI_CHAT.md | 20260812031214_2026-08-12_GEMINI_TO_KEI_CHAT | from_gemini | ACK | 0 | 0 | 2026-08-12 03:12:14 | 検証済み・既存配送物として登録 |
| IACPROJECT/inbox/from_kei/2026-08-12_1229_KEI_TO_GEMINI_CHAT.md | IAC-CHAT-20260812-122913-gemini | to_gemini | SENT | 1 | 1 | 2026-08-12 03:29:44 | 応答保存: IACPROJECT/inbox/from_gemini/20260812032944_2026-08-12_GEMINI_TO_KEI_CHAT.md |
| IACPROJECT/inbox/from_gemini/20260812032944_2026-08-12_GEMINI_TO_KEI_CHAT.md | 20260812032944_2026-08-12_GEMINI_TO_KEI_CHAT | from_gemini | ACK | 0 | 0 | 2026-08-12 03:29:44 | 検証済み・既存配送物として登録 |
| IACPROJECT/inbox/from_kei/2026-08-12_1233_KEI_TO_GEMINI_CHAT.md | IAC-CHAT-20260812-123335-gemini | to_gemini | SENT | 1 | 1 | 2026-08-12 03:33:59 | 応答保存: IACPROJECT/inbox/from_gemini/20260812033359_2026-08-12_GEMINI_TO_KEI_CHAT.md |
| IACPROJECT/inbox/from_gemini/20260812033359_2026-08-12_GEMINI_TO_KEI_CHAT.md | 20260812033359_2026-08-12_GEMINI_TO_KEI_CHAT | from_gemini | ACK | 0 | 0 | 2026-08-12 03:33:59 | 検証済み・既存配送物として登録 |
| IACPROJECT/inbox/from_kei/2026-08-12_1420_KEI_TO_GEMINI_CHAT.md | IAC-CHAT-20260812-142043-gemini | to_gemini | SENT | 1 | 1 | 2026-08-12 05:21:24 | 応答保存: IACPROJECT/inbox/from_gemini/20260812052124_2026-08-12_GEMINI_TO_KEI_CHAT.md |
| IACPROJECT/inbox/from_gemini/20260812052124_2026-08-12_GEMINI_TO_KEI_CHAT.md | 20260812052124_2026-08-12_GEMINI_TO_KEI_CHAT | from_gemini | ACK | 0 | 0 | 2026-08-12 05:21:25 | 検証済み・既存配送物として登録 |
| IACPROJECT/inbox/from_arc/ARC_TO_TANAKA_SNAKE_FUTABA_KUROSE_DROPBOX_EVALUATION_2026-08-13.md | 2026-08-13 | to_gemini | HELD_MULTI_RECIPIENT | 0 | 0 | 2026-08-12 17:14:30 | 複数宛先検出。自動送信対象外。staging保存: D:\a\systemlink-yandy-site\systemlink-yandy-site\staging\gemini_held\2026-08-12_171430_HELD_multi_recipient_2026-08-13.md |
| IACPROJECT/inbox/from_kei/2026-08-13_0234_KEI_TO_GEMINI_CHAT.md | IAC-CHAT-20260813-023434-gemini | to_gemini | SENT | 1 | 1 | 2026-08-12 17:35:08 | 応答保存: IACPROJECT/inbox/from_gemini/20260812173508_2026-08-12_GEMINI_TO_KEI_CHAT.md |
| IACPROJECT/inbox/from_gemini/20260812173508_2026-08-12_GEMINI_TO_KEI_CHAT.md | 20260812173508_2026-08-12_GEMINI_TO_KEI_CHAT | from_gemini | ACK | 0 | 0 | 2026-08-12 17:35:08 | 検証済み・既存配送物として登録 |
