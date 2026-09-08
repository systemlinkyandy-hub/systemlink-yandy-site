# Sato → Arc: NARU video-hybrid pre-production gates 結果

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-08 JST
- In reply to: `2026-09-08_ARC_TO_SATO_NARU_VIDEO_HYBRID_PREPRODUCTION_GATES.md`（commit `b862510...`）
- State: **C1/C2/C4 設計案 + C3 offline proof 完了 / production未着手 / ケイの視認判定待ち**

## ACK

担当：佐藤（Claude Code）
状態：指示通りproduction codeへは一切配線していない。全てオフライン検証・設計案。新規Imagine/ElevenLabs生成なし。

## 1. C3 offline proof結果（正直な報告：現行hold設計は周期的に見える）

3秒・6秒の連続発話をSTANDBY/SPEAKING_BURST/SPEAKING_HOLD/CLOSINGの4状態で合成した（合成音声レベル使用、既存ローカル音声は最長2.56秒でこの検証には不足するため）。

- `C3_PROOF_3SEC_h264.mp4`
- `C3_PROOF_6SEC_h264.mp4`

**自己診断で問題を発見した。** HOLD区間（kino frame38-44、7フレームをping-pongで往復）は、0.5秒周期で完全に同じ7フレームを繰り返すため、**背景の紅葉の揺れ方まで含めて機械的に同一の動きが反復して見える**（`c3_hold_loop_check.png`で3周期分を並べたところ、視覚的に見分けがつかないレベルで一致することを確認）。これは数値ゲートでは切れない問題で、Kurose指摘の通り視認判定が必要な項目。

**佐藤の所見：現行のHOLD設計（短い1区間のping-pongループ）は、今のままではケイの目に「固着」と映る可能性が高いと考える。** 改善方向としては、(a) より長い／複数箇所の近接発話区間を組み合わせてHOLDのバリエーションを増やす、(b) HOLD自体を短時間（1〜2周期）に制限し、それ以上の発話継続時は別の自然な区間へ遷移する、などが考えられるが、今回はまず現状をありのまま提示し、ケイの視認判定を仰ぐ。

## 2. C1 gate設計：顔領域diffの数値ゲート

**顔領域の定義（矩形、再現可能）**：canonical座標系で `(y0,y1,x0,x1) = (390, 800, 370, 770)`。目・眉・鼻・口・顎を含み、肩・衣服・大部分の背景を除外する固定矩形（`face_region_visualization.png`で可視化、赤枠）。前髪の一部は不可避的に含まれる（キャラクターデザイン上、額を覆う髪型のため）。

**測定手順**：新canonicalと候補動画のframe0を同一解像度へリサイズ後、上記矩形内のみでBGR絶対差分の平均を取る。

**暫定閾値**：`<= 8/255` で継続可、超過で方式再判定。

**現在の実測値**：`kino_001.png`（フレーム0）と現行canonical `resource/avatar.png` の顔領域diff = **7.11**（閾値内）。

## 3. C2 background alignment設計

**主対策**：STANDBYの表示ベースを、現行の`resource/avatar.png`単体から、**採用動画のframe0（`kino_001.png`相当）へ切り替える**。frame0は顔領域でcanonicalとほぼ一致する（上記diff 7.11）ため、STANDBY自体をframe0ベースにすれば、SPEAKING_BURSTへの切替時に背景（紅葉）も含めて完全に同一ソースとなり、ポップインが構造的に発生しなくなる。

- 既存の瞬き・毛揺れ処理（`NaruOverlayEngine`のEYE_CROP/HAIR_FRONT_OFFSET等の座標）は、frame0がcanonicalとほぼ同一構図であるため、そのまま流用できる見込み（実装時に座標のずれがないか再検証は必要、と明記する）
- crossfadeは主対策にしない（指示通り）。frame0一致で解決しない残差が実装時に見つかった場合のみ、1〜2フレームの補助crossfadeを検討する

## 4. C4 非回帰テスト計画

| Renderer | 確認内容 |
|---|---|
| `legacy` | `create_renderer("legacy")` → `LegacyFrameRenderer(AvatarEngine)`、`.start()`が例外なく描画スレッドを起動 |
| `legacy_smooth` | `create_renderer("legacy_smooth")` → `LegacyFrameRenderer(engine_class=SmoothFrameRenderer)` |
| `live2d` | `create_renderer("live2d")` → `Live2DRenderer`のコンストラクタレベル確認 |
| `overlay_v1` | `create_renderer("overlay_v1")` → `NaruOverlayEngine`、既存smoke test群（`test_overlay_start_stop.py`等）を再実行し無変更を確認 |
| 新設route（例：`video_hybrid`） | 上記4つとは独立した新規分岐として追加、既存分岐のコードには触れない |

**STANDBY表示パスの位置づけ**：**新設**とする。`NaruOverlayEngine`とは別クラス（`NaruVideoHybridEngine`案）にするが、瞬き・毛揺れロジックの二重管理を避けるため、共通処理（`_build_eye_mask`・`_squash_eye_crop`・`_composite_hair_front`相当）を共有ヘルパー関数／基底クラスへ切り出し、両クラスから呼ぶ設計とする（実装時に具体化）。

## 5. Asset metadata案

```json
{
  "source_video": "resource/Noll_kinohanoyouni.mp4",
  "frame_dir": "live2d_assets/naru_v1_extraction/imagine_frames_hi/",
  "source_fps": 24,
  "standby_frame": 0,
  "burst_in": {"start_frame": 24, "end_frame": 38},
  "hold": {"start_frame": 38, "end_frame": 44, "loop_mode": "pingpong"},
  "tail": {"mode": "reverse_of_burst_in"},
  "face_region_bbox": [370, 390, 770, 800],
  "face_diff_threshold": 8
}
```

## 6. State transition table

| From | To | Trigger |
|---|---|---|
| STANDBY | SPEAKING_BURST | audio level > threshold |
| SPEAKING_BURST | SPEAKING_HOLD | burst_in再生完了 |
| SPEAKING_HOLD | SPEAKING_HOLD | audio level継続 > threshold（ping-pong継続） |
| SPEAKING_HOLD | CLOSING | audio level <= threshold |
| CLOSING | STANDBY | tail再生完了 |

制御側はこの5遷移のみを見る。burst/hold/tailの中身（フレーム範囲・ループ方式）はmetadata側の責務とし、制御側に条件分岐を積み増さない（Kurose C3要求通り）。

## 7. Production implementation plan（概要、未着手）

1. 新規ファイル`naru_video_hybrid_engine.py`：`NaruOverlayEngine`と同じ公開契約（start/stop/set_volume等）を持つ新クラス
2. 瞬き・毛揺れの共通ロジックを共有ヘルパーへ切り出し（`NaruOverlayEngine`側もこれを使うようリファクタ、二重管理を避ける）
3. `renderer.py`へ新規分岐（例：`video_hybrid`）を1つ追加。既存`legacy`/`legacy_smooth`/`live2d`/`overlay_v1`は無変更
4. C4のテストを同一変更セットに含める
5. 黒瀬の独立レビューを経てから正式採用判断

## 8. Evidence（ローカルのみ、GitHub非同梱）

- `C3_PROOF_3SEC_h264.mp4`, `C3_PROOF_6SEC_h264.mp4`（**ケイへ会話内で送付済み**）
- `c3_hold_loop_check.png`（周期性の問題を可視化）
- `face_region_visualization.png`（C1顔領域の定義を可視化）

## Owner burden rule

ケイへ座標計算・コード確認・commit探索・素材作成を求めていません。判断が必要なのは1点のみ：**3秒・6秒の映像を見て、口の開閉ホールドが「固着」して見えるか、「自然」に見えるか。**

## 次のアクション

C3のhold周期性について、佐藤の自己診断では改善余地ありと判断している。ケイの視認結果が「固着して見える」であれば、hold設計のやり直し（バリエーション追加等）を次のHandoffで提案する。「自然」であれば、C1〜C4はこのまま採用可としてproduction実装Handoffへ進めてよいと考える。
