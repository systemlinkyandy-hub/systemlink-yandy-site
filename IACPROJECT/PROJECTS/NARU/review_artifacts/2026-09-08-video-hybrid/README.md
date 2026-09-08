# NARU video-hybrid production implementation — review artifacts

黒瀬（Claude）post-change regression review用。

対応Handoff:
- `IACPROJECT/inbox/from_arc/2026-09-08_ARC_TO_SATO_NARU_VIDEO_HYBRID_PRODUCTION_ONE_SHOT_IMPLEMENTATION.md`
- `IACPROJECT/inbox/from_claude_code/2026-09-08_SATO_TO_ARC_NARU_VIDEO_HYBRID_PRODUCTION_IMPLEMENTATION_RESULT.md`

## 境界

`overlay_v1`と並存する新route。既存`legacy`/`legacy_smooth`/`live2d`/`overlay_v1`は無変更（`overlay_v1`は共有ヘルパー抽出のためリファクタしたが動作は無回帰）。反転再生(reverse_playback)は実装していない（コードレベルで確認済み、`naru_video_hybrid_engine.diff`参照不要、grep結果はHandoff本文に記載）。

## ファイル

| ファイル | 内容 |
|---|---|
| `naru_face_fx.py` | 新規。瞬き・毛揺れの共有ヘルパー（`NaruOverlayEngine`と`NaruVideoHybridEngine`が共に使う） |
| `naru_video_hybrid_engine.py` | 新規。`NaruVideoHybridEngine`本体。STANDBY=動画frame0、SPEAKING=forward-only自然区間+pause |
| `naru_overlay_engine.py` | 変更。瞬き・毛揺れの実体を`naru_face_fx`へ委譲するようリファクタ（差分は`naru_overlay_engine.diff`参照） |
| `renderer.py` | 変更。`video_hybrid`分岐を1つ追加（差分は`renderer.diff`参照、既存分岐は無変更であることが一目でわかる） |
| `test_c4_non_regression.py` | legacy/legacy_smooth/overlay_v1/video_hybrid/live2dの選択確認テスト |
| `test_video_hybrid_start_stop.py` | 新routeのstart/stop実描画ループ検証 |
| `test_video_hybrid_speak_smoke.py` | production `speak()`経路での発話smoke（既存ローカル音声使用） |
| `renderer.diff` | 直前の一次証拠（`2026-09-02-overlay-v1/renderer.py`）との差分。追加は`video_hybrid`分岐1箇所のみ |
| `naru_overlay_engine.diff` | リファクタ差分（瞬き・毛揺れロジックの委譲化、ロジック自体は無変更） |

`.env`/APIキー・ローカル絶対パスはgrepで確認済み、含まれていない。
