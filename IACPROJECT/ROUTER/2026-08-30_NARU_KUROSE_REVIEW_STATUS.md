# NARU / Kurose Review + Real Smoke Test Status

- Date: 2026-08-30 / updated 2026-08-31 JST
- Coordinator: アーク
- Target: NARU IBM Bob fix delta -> condition fix -> real TikTok smoke test
- Implementation commit: `a722cad4d404507da5ea5d7c14606429a837fa9c`
- Review artifacts commit: `5ff20d91d5db9876356fde4018ce1f1ffdc57bc3`
- Condition fix commit: `819d905d6a0e1fd21a785ae27d2a8df5bd79f37e`
- Real smoke report commit: `296ae81b518f700b633ca64b8bbb6a1010cfdb0a`

## Current state

- 佐藤 implementation: DONE
- Review artifacts submission: DONE
- 黒瀬 independent code review work: DONE
- 黒瀬 original review Markdown in GitHub: NOT YET CONFIRMED
- 黒瀬 verdict (secondary relay record): APPROVE after condition clear
- Mandatory condition count: 1
- Condition fix implementation: DONE
- Non-paid True/False path verification: DONE
- Real TikTok smoke test: DONE (controlled test, user-operated)
- NARU restart functional smoke milestone: PASSED WITH EVIDENCE LIMITATIONS

## Real smoke evidence

佐藤報告:
`IACPROJECT/inbox/from_claude_code/2026-08-30_SATO_TO_ARC_KUROSE_NARU_REAL_TIKTOK_SMOKE_TEST_DONE.md`
commit `296ae81b518f700b633ca64b8bbb6a1010cfdb0a`

Reported flow:
`start_live2d.bat` -> STANDBY -> TikTok LIVE Studio Go Live -> `C/` CHAT -> controlled own comments -> response/avatar/lipsync observed -> `S/` STANDBY -> end.

Evidence discipline:
- Conversation/avatar/lipsync operation and clean STANDBY return are user-reported from the live run.
- No live terminal latency log was captured/submitted for this run.
- Exact API cost was not verified.
- Viewer-side TikTok audio delivery was not independently captured/verified in the submitted evidence.

## Recording-audio finding

The local Windows Game Bar recording had effectively silent audio. Sato directly checked the file with ffprobe/ffmpeg (`mean/max ~ -91 dB`).

Current explanation: `voice_analyzer.py` uses `os.startfile()` and an OS-default player process for playback, while per-app Game Bar capture does not capture that separate process audio. Treat this as a recording-path issue, not proof of NARU response-path failure.

Deferred:
- next recording attempt can use OBS/Desktop Audio or another capture path
- possible future replacement of `os.startfile()` playback remains a separate implementation decision

## Bob findings / review condition status

Confirmed implementation scope:
- TikTok ingest separated from synchronous response work
- one configured OpenAI model source + existence check
- six-stage latency instrumentation
- startup/STANDBY safety retained
- subtitle/history commit only on `speak()` success

## Deferred / known issues

- failed-job `_job_stage_log` cleanup micro-leak
- unbounded `llm_queue` / `tts_queue`
- `READ_COMMENTS_ALOUD=True` reintroduces blocking path
- discussion/AUTO/idle async work
- whole `vtuber_ai` git management decision
- viewer-side audio/capture evidence on a future live test if needed

## Routing

NARU restart smoke milestone itself does not require another implementation round now.
Future work is deferred unless a new test or requirement reopens it.

## Owner burden rule

ケイへ実装・レビュー転記・ACK回収・進捗監視を戻さない。
