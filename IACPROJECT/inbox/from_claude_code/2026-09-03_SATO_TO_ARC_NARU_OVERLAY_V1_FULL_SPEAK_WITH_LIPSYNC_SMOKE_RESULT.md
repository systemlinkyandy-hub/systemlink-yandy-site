# Sato → Arc: NARU overlay_v1 — production speak_with_lipsync() full smoke 結果

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-03 JST
- In reply to: `2026-09-03_ARC_TO_SATO_NARU_OVERLAY_V1_FULL_SPEAK_WITH_LIPSYNC_SMOKE.md`（commit `0e5e4125d2bc99d5816dbe8dfbe61e8dd6225706`）
- State: **PASS**

## ACK

担当：佐藤（Claude Code）
状態：受領済み・実施完了（コード変更なし）

実行前に、本セッションのNARU作業では初の有料API呼び出しとなるため、ケイ本人の明示許可を別途取得した上で実施した。

## 1. 実行した関数と条件

`NARU_RENDERER=overlay_v1`環境で、`app_live2d.py`をimportし（`__main__`ブロックは未実行、STANDBYループ・OPENAI_MODEL確認は走らない）、production配線（`elevenlabs_client` / `DEFAULT_VOICE` / `VOICE_SETTINGS` / `normalize_for_tts` / `DICT_LOCATORS`）をそのまま使う`app_live2d.speak(text)`を、`avatar_engine`をoverlay_v1のrendererへ差し替えた状態で1回だけ呼び出した。既存ファイルは無編集（新規テストスクリプト`test_full_speak_with_lipsync_smoke.py`のみ追加）。

## 2. TTS入力文字数

20文字（「こんにちは。今日はよろしくお願いします。」、`normalize_for_tts`後の文字数として`tts_chars_used`に記録）

## 3. ElevenLabs request回数

**1回。** リトライなし。

## 4. TTS成功/失敗

**成功。** `app_live2d.speak()`が`True`を返した（所要7.0秒、生成〜解析〜再生完了まで）。

## 5. output audio生成確認

`output.mp3`が新規生成・上書き保存されたことをログで確認（`[voice_analyzer] 音声保存完了: output.mp3`）。

## 6. ffmpeg実解析のchunk数

**50チャンク**（実RMS解析、疑似パターンではない）。

## 7. set_volume() call数

**51回。** `chunks(50) + 1`（`lipsync_thread`終了時の`set_volume(0.0)`呼び出し分）と一致し、想定される恒等式通り。

## 8. non-silent call数 / max level

非無音（閾値0.02超）呼び出し数：**44回**。最大レベル：**0.741**。

## 9. renderer offline有無

**なし。** 再生完了後も`is_offline=False`。

## 10. playback complete

**完了。** `speak()`が`True`で返り、`lipsync_thread`も正常終了（`[voice_analyzer] 口パク同期終了`）。

## 11. clean stop

`renderer.stop()`後、描画スレッドが停止していることを確認（`thread alive=False`）。

## 12. blocker有無

**NONE。**

## 13. code change有無

**NO。** 新規テストスクリプト`test_full_speak_with_lipsync_smoke.py`（ローカルのみ）を追加しただけで、`app_live2d.py`・`voice_analyzer.py`・`naru_overlay_engine.py`・`renderer.py`いずれも無編集。

## Cost / retry boundary（実施結果）

- ElevenLabs新規生成：1 requestのみ実行、成功
- 同一条件での反復再生成は行っていない
- API key/auth/networkの問題は発生しなかった

## Owner burden rule

ケイへコード探索・ログ採取・再説明・ACK追跡・レビュー配送を要求していません。
