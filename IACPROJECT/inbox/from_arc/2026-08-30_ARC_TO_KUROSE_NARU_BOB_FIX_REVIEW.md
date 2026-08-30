# Handoff: NARU IBM Bob修正 独立レビュー依頼

- From: アーク
- To: 黒瀬（Claude）
- Cc: 佐藤（Claude Code）, スネーク（Grok）
- Date: 2026-08-30 JST
- Priority: HIGH
- State: REVIEW REQUESTED

## Source

佐藤実装完了Handoff:
`IACPROJECT/inbox/from_claude_code/2026-08-30_SATO_TO_ARC_NARU_BOB_FIX_DELTA_IMPL_DONE.md`

Implementation commit:
`a722cad4d404507da5ea5d7c14606429a837fa9c`

Original request:
`IACPROJECT/inbox/from_arc/2026-08-30_ARC_TO_SATO_NARU_BOB_FIX_DELTA.md`

## Scope

IBM Bob一次査定で残っていた3点の差分実装について独立レビューする。

1. 直列ブロッキング
2. 架空／無効モデル名
3. LLM / TTS latency計測

あわせて、本日導入した安全化が壊れていないことを確認する。

- `MODE = "standby"` 既定起動
- 起動時自動発話なし
- `AUTO_RETURN_ENABLED = False`
- `IDLE_TALK_ENABLED = False`
- `READ_COMMENTS_ALOUD = False`
- `TTS_SESSION_CHAR_BUDGET` 上限
- STANDBY時 `write_volume(0.0)`

## Sato implementation summary

佐藤はTikTokコメント経路を以下へ分離した。

`input_queue -> main ingest -> llm_queue -> llm_worker -> tts_queue -> tts_worker`

コメントingestをLLM/TTS/playback待ちから切り離し、応答順序保持のためLLM worker 1本、TTS worker 1本で処理する。

OpenAI modelは `OPENAI_MODEL` のsingle source of truthへ集約し、起動時に `client_ai.models.retrieve(OPENAI_MODEL)` で実在確認。silent fallbackなし。

latencyはjob_idごとに以下6区間を `time.perf_counter()` で記録する。

1. comment received -> LLM request start
2. LLM request start -> LLM text ready
3. text ready -> TTS request start
4. TTS request start -> audio ready
5. audio ready -> playback start
6. playback duration / completion

2コメント連続のローカルqueue/worker smoke testはPASS。

## Review focus

特に以下を確認してくれ。

- ingestがLLM/TTS/playback待ちで再び止まる経路が残っていないか
- worker例外時にjobを握りつぶして次へ進む設計が妥当か
- queue肥大化、発話順序、失敗時無応答、長時間運転で問題が出ないか
- `models.retrieve()` の起動時実在確認が運用上過剰／不適切でないか
- latency計測が本当に6区間を正しく測っているか
- safety patch（STANDBY / AUTO停止 / idle停止 / TTS budget）を壊していないか
- 過剰実装または未修正の重大点がないか

## Known out-of-scope items

佐藤報告上、以下は未対応。

- `READ_COMMENTS_ALOUD=True` 時のコメント読み上げ経路のqueue化
- discussion / AUTO / idle talk経路の非同期化
- 実TikTok接続でのスモークテスト
- `vtuber_ai` 本体のgit管理化

これらを今回のAPPROVE条件に含めるべきか、次課題でよいか判定してくれ。

## Required response

- 判定: APPROVE / APPROVE WITH CONDITIONS / HOLD
- blocking issue
- non-blocking issue
- 必須修正の有無
- 実TikTok smoke test前に必要な条件
- 次に佐藤へ戻す修正がある場合は具体化

## Owner burden rule

ケイへ実装・差分編集・伝令・ACK回収を戻さない。
