# Sato → Arc: NARU overlay_v1 — speaking-path (audio level → mouth) smoke 結果

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-03 JST
- In reply to: ケイ経由の口頭指示（`overlay_v1` speaking-path smoke。前日`2026-09-02_ARC_NARU_NEXT_THREAD_CURRENT_STATE.md`7節で予告されていた次フェーズ）
- State: **PASS**

## ACK

担当：佐藤（Claude Code）
状態：受領済み・実施完了（コード変更なし）

## 0. 前提確認

今回はケイからの口頭伝達で、特定のcommitハッシュは伴っていなかった。内容は前日`IACPROJECT/HANDOFF/2026-09-02_ARC_NARU_NEXT_THREAD_CURRENT_STATE.md`（commit `aa20b1c`経由でmerge済み、7節「次に検討するのは...喋る経路のsmoke」）と一致しており、既に確認済みの現在地の自然な延長と判断して着手した。

## 1. 実行方法

既存の「喋る → audio level → mouth」経路は`voice_analyzer.py`の`play_with_lipsync()`＋`_play_audio()`（`speak_with_lipsync()`が実際に呼ぶのと同じ順序）。これを、**新規ElevenLabs生成を行わず**、既存のローカル音声ファイル（`output.mp3`、8/30時点で生成済み・今回は読み込むだけ）を使って1回通した。

新規スクリプト`test_speaking_path_smoke.py`（既存ファイル無編集、`NaruOverlayEngine.set_volume`を監視用に一時フックするのみ）：

```
NARU_RENDERER=overlay_v1
create_isolated_renderer() → renderer.start()
voice_analyzer.play_with_lipsync(output.mp3, renderer)
voice_analyzer._play_audio(output.mp3)   # 実再生、speak_with_lipsync()と同じ呼び出し順
renderer.stop()
```

## 2. 結果

| 確認項目 | 結果 |
|---|---|
| `NARU_RENDERER=overlay_v1`選択 | OK（`renderer._real._engine`が`NaruOverlayEngine`であることを確認） |
| 音声解析 | ffmpegで実RMS解析（197チャンク、疑似パターンではない） |
| audio level → mouth 経路 | OK。`set_volume`呼び出し198回、うち非無音（閾値超）168回、最大レベル0.883 |
| renderer offline | なし（再生前・再生後とも`is_offline=False`） |
| clean stop | OK（`stop()`後、描画スレッドが停止していることを確認） |
| 既存経路への回帰 | なし。`voice_analyzer.py`・`naru_overlay_engine.py`・`renderer.py`いずれも無編集 |
| TikTok実配信 | なし |
| 有料API生成 | なし（既存ローカル音声ファイルを読み込んだのみ、新規TTS呼び出しなし） |

## 3. blocker有無

**NONE。**

## 4. code changed

**NO。** 新規テストスクリプト`test_speaking_path_smoke.py`（`C:\Projects\vtuber_ai\`直下、ローカルのみ）を追加しただけで、既存の実装ファイルは無編集。

## 5. commit

コード変更なし。本Handoffのみを新規commitとして登録する。

## Owner burden rule

ケイへ操作・ログ採取・進捗監視を戻していません。
