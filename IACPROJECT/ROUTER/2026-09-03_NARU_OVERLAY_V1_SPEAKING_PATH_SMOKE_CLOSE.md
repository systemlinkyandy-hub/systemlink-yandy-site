# NARU overlay_v1 speaking-path smoke — Router CLOSE

- From: アーク
- Reviewed by: 黒瀬（Claude）
- Implement/Test evidence: 佐藤（Claude Code）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-03 JST
- State: **CLOSED / PASS**

## 0. Verdict

`SPEAKING_PATH_SMOKE_APPROVE`

`overlay_v1` の既存 speaking path（audio level → mouth）smoke は blocker なしでCLOSEする。

## 1. Evidence

佐藤 result:
`IACPROJECT/inbox/from_claude_code/2026-09-03_SATO_TO_ARC_NARU_OVERLAY_V1_SPEAKING_PATH_SMOKE_RESULT.md`

Remote commit:
`2771cf8b8e024bab534057494b48c7a3c1580250`

確認済み:
- `NARU_RENDERER=overlay_v1` が実際に `NaruOverlayEngine` を選択
- `voice_analyzer.play_with_lipsync()` + `_play_audio()` を既存ローカル音声で実行
- ffmpeg実RMS解析 197 chunks
- `set_volume()` 198 calls
- 非無音 168 calls
- max level 0.883
- renderer offlineなし
- clean stop
- TikTok実配信なし
- 新規ElevenLabs生成なし
- production実装ファイルの変更なし

## 2. Kurose independent review

黒瀬は `voice_analyzer.py` を独立確認し、佐藤が踏んだ

`play_with_lipsync()` → `_play_audio()`

の順序が `speak_with_lipsync()` production関数内部と一致することを確認した。

さらにコード構造上、`play_with_lipsync()` は解析チャンクごとに `set_volume()` を1回呼び、ループ終了後の無音化で1回追加する。

したがって:

`set_volume calls = analyzed chunks + 1`

報告値 `198 = 197 + 1` は実装構造と厳密に一致する。

これは実測ログの整合性を強く裏付ける。

## 3. Additional evidence gained

今回のsmokeでは、前回修正した `start()/stop()` が、

- lipsync側の `set_volume()` 呼び出しスレッド
- renderer側の `compose_frame()` 描画スレッド

の並行稼働下でも blocker なく動作した。

前回の単体 start/stop テストを越える追加の実地裏付けとして記録する。

## 4. Remaining classification

- `overlay_v1`: technical prototype
- `.moc3`: 未着手
- TikTok実配信: 未実施
- renderer redesign: 開かない
- `_mouth_level` private-state dependency: 既知nonblocking tech debtのまま

## 5. Next minimum gate

黒瀬指定の次ゲートは1つだけ:

**ElevenLabs新規生成込みで `speak_with_lipsync()` 自体を1回通す。**

制約:
- TikTokを開かない
- `.moc3`を開かない
- renderer redesignを開かない
- 不要なコード変更をしない
- 1回の短いTTS生成に限定し、課金量を最小化する

次工程は別Handoffとして佐藤へroutingする。

## Owner burden rule

ケイへコード探索、ログ採取、ACK追跡、再説明、レビュー配送を戻さない。
