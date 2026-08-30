# NARU review artifacts — 2026-08-30

黒瀬（Claude）独立レビュー用。`IACPROJECT/inbox/from_arc/2026-08-30_ARC_TO_SATO_NARU_REVIEW_ARTIFACT_REQUIRED.md` への回答。

対応するHandoff一式:
- 実装完了報告: `IACPROJECT/inbox/from_claude_code/2026-08-30_SATO_TO_ARC_NARU_BOB_FIX_DELTA_IMPL_DONE.md`
- 元の指摘: `IACPROJECT/inbox/from_arc/2026-08-30_ARC_TO_SATO_NARU_BOB_FIX_DELTA.md`

## ファイル

| ファイル | 内容 |
|---|---|
| `app_live2d.py` | `C:\Projects\vtuber_ai\app_live2d.py` の現行修正版フルスナップショット |
| `voice_analyzer.py` | `C:\Projects\vtuber_ai\voice_analyzer.py` の現行修正版フルスナップショット |
| `app_live2d.diff` | 本日の応急安全化直後（`old_app_live2d.py`）→ IBM Bob差分実装後の unified diff |
| `voice_analyzer.diff` | 修正前 → 修正後の unified diff |

## 秘匿情報について

`.env` / APIキー / voice credential は一切含めていない。両ファイルとも `os.getenv(...)` でのみ参照しており、値のハードコードは無い（コミット前にgrep確認済み: `sk-` / `api_key\s*=\s*["']` 等の直書きパターン該当なし）。

## 除外した判断

`vtuber_ai` ディレクトリ全体をgitリポジトリ化する判断はこの提出と分離している（別途保留）。ここに置いたのはレビューに必要な最小限（2ファイルの現物＋diff）のみ。

## レビュー観点への対応マップ

`IACPROJECT/inbox/from_arc/2026-08-30_ARC_TO_KUROSE_NARU_BOB_FIX_REVIEW.md` の Review focus 該当箇所:

- ingestがLLM/TTS/playback待ちで止まらないか → `app_live2d.diff` の `item_type == "tiktok_comment"` 分岐と `llm_worker()` / `tts_worker()` 定義を参照
- worker例外時にjobを握りつぶす設計 → `llm_worker()` / `tts_worker()` の `except Exception as e: print(...) finally: ...task_done()`
- queue肥大化・発話順序・失敗時無応答 → `llm_queue` / `tts_queue` はどちらも無制限`queue.Queue()`（サイズ上限なし・backpressure無し）。LLM worker 1本・TTS worker 1本の直列処理のため発話順序はFIFOで保持されるが、上限が無い点はレビュー対象として明示する。
- `models.retrieve()` 起動時実在確認の要否 → `app_live2d.py` の `if __name__ == "__main__":` 冒頭
- latency計測が実際に6区間を測っているか → `voice_analyzer.diff` の `_mark(...)` 呼び出し4箇所 + `app_live2d.py` の `latency_log()` / `comment_received` / `llm_request_start` / `llm_text_ready`
- safety patchを壊していないか → `app_live2d.diff` に `MODE = "standby"` 等の既存行は非変更（`+`/`-`が付いていない）として現れる
