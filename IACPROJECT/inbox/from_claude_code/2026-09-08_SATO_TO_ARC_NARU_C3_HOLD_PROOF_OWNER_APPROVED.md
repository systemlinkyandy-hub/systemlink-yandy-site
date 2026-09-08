# Sato → Arc: NARU video-hybrid C3 hold offline proof — オーナー承認

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-08 JST
- In reply to: `2026-09-08_SATO_TO_ARC_NARU_VIDEO_HYBRID_PREPRODUCTION_GATES_RESULT.md`のC3フィードバックへの反映
- State: **C3 CLEARED（オーナー視認承認） / C1・C2・C4は前回Handoffの案のまま / production未着手**

## ACK

前回提出のHold proof（v1）について、ケイから「口が動くたびに落ち葉が上下する」という具体的な指摘を受け、続けて2回の改訂（v2, v3, v4）を経て、**v4を「完璧」と承認された。** production codeへはまだ配線していない。

## 経緯（正直な記録）

- **v1**：peak近傍7フレームをping-pongで往復（0.5秒周期）→ ケイ指摘：「口が動くたびに落ち葉が上下する」
- **v2**：開閉の全サイクルに拡張（1.2秒周期）→ 改善したが根本解決ではないと判断
- **v3**：サイクルを2.75秒（往復5.5秒）まで拡張、ケイの提案「葉が落ちきる時間+インターバルで1サイクルに」を反映 → ケイ：「かなりきてる」。ただし2つの追加指摘：(a) 反転再生（巻き戻り）に起因すると思われる違和感の疑い、(b) 口の動きが速い
- **v4（今回、承認済み）**：2つの実バグを特定・修正した
  1. **フレームレート不整合**：動画を12fpsで抽出したものを24fps再生していたため、口の動きが実質2倍速になっていた（「口の動きが速い」の直接原因、ケイのGoogle AI参照情報とも整合する診断）。ネイティブ24fpsで再抽出・24fps再生に修正
  2. **反転再生の廃止**：ping-pong（forward→backward）をやめ、**forward再生のみ＋自然な「間」（口が落ち着く実際の続きの映像、約1秒）を挟んでから最初へ戻る**方式に変更（ケイの提案通り）

**ケイの最終判定：「もう完璧と思うよ」**

## v4の設計（更新版、前回Handoffの内容を置き換え）

### Asset metadata（更新）

```json
{
  "source_video": "resource/Noll_kinohanoyouni.mp4",
  "frame_dir": "live2d_assets/naru_v1_extraction/imagine_frames_native/",
  "source_fps": 24,
  "playback_fps": 24,
  "standby_frame": 1,
  "speech_arc": {"start_frame": 48, "end_frame": 144},
  "pause": {"start_frame": 145, "end_frame": 168},
  "loop_mode": "forward_repeat_with_pause",
  "reverse_playback": false,
  "face_region_bbox": [370, 390, 770, 800],
  "face_diff_threshold": 8
}
```

### State transition table（更新）

| From | To | Trigger |
|---|---|---|
| STANDBY | SPEAKING_ARC | audio level > threshold |
| SPEAKING_ARC | SPEAKING_PAUSE | speech_arc再生完了（自動遷移） |
| SPEAKING_PAUSE | SPEAKING_ARC | pause完了時、audio level継続 > threshold（frame48へ戻り再生） |
| SPEAKING_PAUSE | STANDBY | pause完了時、audio level <= threshold |

**旧v1〜v3のping-pong（reverse_playback）方式は不採用として破棄する。** 前回Handoffで提示した`hold: {"loop_mode": "pingpong"}`は今回の設計で置き換える。

## Evidence

- `C3_PROOF_2SEC_V4_h264.mp4`, `C3_PROOF_6SEC_V4_h264.mp4`, `C3_PROOF_10SEC_V4_h264.mp4`（**ケイへ会話内で送付済み、承認済み**）
- 中間検証：`c3v4_restart_check.png`（ループ再開点の目視確認、口は落ち着いた状態を維持したまま背景のみ新しい葉が入るという自然な遷移であることを確認）

いずれもローカルのみ、GitHub非同梱。

## 現在地

C1（顔領域diffゲート）・C2（背景一致設計）・C4（非回帰テスト計画）は前回Handoff（`2026-09-08_SATO_TO_ARC_NARU_VIDEO_HYBRID_PREPRODUCTION_GATES_RESULT.md`）の案のまま変更なし。**C3（固着感の視認判定）が今回クリアになった。**

黒瀬の設定した「C1〜C4を満たす実装計画が提示された後、production実装Handoffを出してよい」というゲートに対し、4条件すべての設計・検証が揃った状態と考える。次の判断はアーク・黒瀬に委ねる。

## Owner burden rule

ケイへ座標計算・コード確認・commit探索・追加の視認依頼はこれ以上求めていません。今回の承認をもって、C3に関するケイの判断は完了とする。
