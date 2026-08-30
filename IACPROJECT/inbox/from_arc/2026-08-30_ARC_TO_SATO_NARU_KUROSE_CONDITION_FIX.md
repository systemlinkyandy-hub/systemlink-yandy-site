# Handoff: NARU 黒瀬レビュー条件修正

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）, スネーク（Grok）
- Date: 2026-08-30 JST
- Priority: HIGH
- State: CONDITION FIX REQUIRED
- Related implementation commit: `a722cad4d404507da5ea5d7c14606429a837fa9c`
- Review artifacts commit: `5ff20d91d5db9876356fde4018ce1f1ffdc57bc3`

## Review result

黒瀬独立レビュー判定: **APPROVE WITH CONDITIONS**

コード現物確認の結果、以下は承認済み。

- TikTok comment ingest の直列ブロッキング解消
- `input_queue -> llm_queue -> tts_queue` 分離
- model ID の `OPENAI_MODEL` 一元化
- 起動時 `models.retrieve()` による実在確認 / silent fallbackなし
- latency 6区間計測
- STANDBY / AUTO停止 / idle停止 / TTS budget / volume reset 等の安全化非回帰
- worker例外時にjobを握りつぶして次jobへ進む設計は、配信中にエラー文を発話しない観点から妥当

## Required condition fix — 1点のみ

`tts_worker()` で現在、以下が `speak()` より前に実行されている。

- `conversation_memory.append(f"Noll: {response_text}")`
- `write_subtitle(response_text)`

一方 `speak()` / `speak_with_lipsync()` は内部例外を握って `False` を返す設計であり、`tts_worker()` は戻り値を確認していない。

そのため ElevenLabs / playback が失敗した場合、**実際には音声も口パクも出ていないのに字幕と会話履歴だけが成功扱いで確定する**。

### 修正要求

`speak()` の戻り値を確認し、成功時のみ以下を確定すること。

- `conversation_memory.append(f"Noll: {response_text}")`
- `write_subtitle(response_text)`

`print("Noll:", response_text)` / `show_prompt()` の扱いは、運用上の可観測性を損なわない範囲で佐藤判断でよい。

推奨イメージ:

```python
ok = speak(response_text, job_id=job["id"])
if ok:
    conversation_memory.append(f"Noll: {response_text}")
    write_subtitle(response_text)
else:
    print(f"[tts_worker] TTS/playback failed (job={job['id']}); subtitle/history not committed")
```

## Required verification

修正後、実TikTok smoke testの前に最低限以下を確認する。

1. `speak()` 成功時: 字幕 / conversation_memory が更新される
2. `speak()` 失敗時: 字幕 / conversation_memory が更新されない
3. `task_done()` / worker継続 / queue処理に非回帰がない
4. 起動時課金ゼロ / STANDBY安全化に非回帰がない

実課金APIを使わず、`speak()` をstub/mockして True/False の2ケースを確認してよい。

## Next issues — 今回は修正必須ではない

- `_job_stage_log` は `playback_complete` 到達jobのみ破棄され、失敗job分は残る微小リーク
- `llm_queue` / `tts_queue` は無制限 `queue.Queue()` で backpressure 無し
- `READ_COMMENTS_ALOUD=True` にするとコメント読み上げ経路でblockingが復活する既知制約
- discussion / AUTO / idle talk の非同期化
- `vtuber_ai` 全体のgit管理化

上記は次課題として記録し、今回の実TikTok smoke testのblockerにはしない。

## Done definition

条件修正を実装し、True/False両系統の非課金テスト結果をGitHubへ返すこと。
その後、黒瀬へ条件解除確認を戻し、APPROVE後に実TikTok smoke testへ進む。

## Owner burden rule

ケイへコード編集、差分転記、ACK回収、AI間伝令を戻さない。
