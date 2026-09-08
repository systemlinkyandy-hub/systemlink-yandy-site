# Sato → Arc: NARU video-hybrid production implementation 結果

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-08 JST
- In reply to: `2026-09-08_ARC_TO_SATO_NARU_VIDEO_HYBRID_PRODUCTION_ONE_SHOT_IMPLEMENTATION.md`（commit `54fd7d3...`）
- State: **IMPLEMENTATION DONE / post-change evidence一式 / 黒瀬レビュー・ケイ最終視認待ち**

## ACK

担当：佐藤（Claude Code）
状態：production実装完了。既存`legacy`/`legacy_smooth`/`live2d`/`overlay_v1`は無変更（`overlay_v1`は共有ヘルパー抽出のためリファクタしたが、テストで無回帰を確認済み）。新規Imagine/ElevenLabs生成は行っていない。

## 1. 変更ファイル一覧

| ファイル | 種別 | 内容 |
|---|---|---|
| `naru_face_fx.py` | 新規 | 瞬き・毛揺れの共有ヘルパー（`build_eye_mask`/`squash_eye_crop`/`composite_hair_front`） |
| `naru_video_hybrid_engine.py` | 新規 | `NaruVideoHybridEngine`本体 |
| `naru_overlay_engine.py` | 変更 | 瞬き・毛揺れの実体を`naru_face_fx`へ委譲するようリファクタ（ロジック自体は無変更、二重管理を解消） |
| `renderer.py` | 変更 | `video_hybrid`分岐を1つ追加。既存分岐は無変更 |

コード変更は本Handoffと同時にローカルcommitする。ハッシュはケイへのpush確認後、Router側の受領記録を参照。

## 2. 新route start/stop/basic draw smoke

`test_video_hybrid_start_stop.py`：`create_isolated_renderer()`→`is_offline=False`確認→`start()`で実描画スレッド起動（1.5秒間で`compose_frame()`45回呼び出しを確認）→`stop()`でスレッド確実停止。**PASS**

## 3. production `speak()` 経路での発話smoke

`test_video_hybrid_speak_smoke.py`：既存ローカル音声(`output.mp3`、新規生成なし)で`app_live2d.speak()`相当の経路（`voice_analyzer.play_with_lipsync`）を実行。観測された状態遷移：`STANDBY → SPEAKING_ARC`。再生完了後も`is_offline=False`。clean stop確認。**PASS**

## 4. C4 non-regression results

`test_c4_non_regression.py`：

| Renderer | 結果 |
|---|---|
| `legacy` | OK（`AvatarEngine`が選択される） |
| `legacy_smooth` | OK（`SmoothFrameRenderer`が選択される） |
| `overlay_v1` | OK（`NaruOverlayEngine`が選択される、共有ヘルパー抽出後も無回帰） |
| `video_hybrid`（新） | OK（`NaruVideoHybridEngine`が選択される） |
| `live2d` | コンストラクタは正常に到達し、既知の環境要因（`NARU_LIVE2D_MODEL_PATH`未設定＝ライセンス済みモデルasset未配置）で`RuntimeError`。**今回の変更に起因する回帰ではない**（`live2d_renderer.py`は無変更、既存の既知の制約） |

## 5. C1 face diff gateの実装・再現性

`NaruVideoHybridEngine.measure_face_diff(canonical, frame0)`として実装。実行結果：`7.25/255`（閾値`<=8/255`内、パス）。前回Handoffでの手動測定値`7.11`とは補間方式の違いによる小差（今回はクラスメソッド内で標準リサイズを使用、前回はLANCZOS4）だが、いずれも閾値内で結論は変わらない。

## 6. 24fps一致・reverse_playback=false の証拠

- 動画フレームはネイティブ24fps抽出（`imagine_frames_native/`）を使用、`PLAYBACK_FPS=24`で時刻ベース（`elapsed * PLAYBACK_FPS`）にフレーム選択。コンポーズ呼び出し頻度（30fps程度）とは独立して実時間速度を保つ
- `grep -n "reversed\|\[::-1\]" naru_video_hybrid_engine.py` で該当なしを確認済み（反転再生ロジックが存在しないことをコードレベルで確認）

## 7. owner visual confirmation用の証拠映像

`PRODUCTION_VIDEO_HYBRID_EVIDENCE_h264.mp4`：**production実装そのもの**（`renderer.start()`の実ライブ経路）から直接捕捉。STANDBY→SPEAKING_ARC→SPEAKING_PAUSE→SPEAKING_ARC(継続)→SPEAKING_PAUSE→STANDBYの全状態遷移を実演。**ケイへ会話内で送付済み。**

C3固着感の再視認は求めていない（承認済み）。求めているのは「実装で新しいvisible regressionが増えていないか」の1点のみ。

## 実装上の補足（設計判断の明示）

瞬き・毛揺れは**STANDBY時のみ**適用する設計とした。SPEAKING中は動画自体が実際の自然な動き（口・顎・頬・髪・陰影すべて）を持っているため、追加で瞬き・毛揺れを合成すると二重に動きが乗って不自然になるリスクがあると判断したため。Arc Handoffの「既存の瞬き・毛揺れは再利用する」はSTANDBYセクションに記載されていたため、この解釈で実装した。もし異なる意図であれば指摘してほしい。

## Evidence（ローカルのみ、GitHub非同梱）

- `PRODUCTION_VIDEO_HYBRID_EVIDENCE_h264.mp4`（ケイへ送付済み）

## Owner burden rule

ケイへ座標計算・コード確認・commit探索・追加素材作成を求めていません。求めているのは証拠映像の目視確認のみ（送付済み）。
