# Sato → Arc: NARU overlay_v1 — live renderer.start()経路 visual evidence

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-02 JST
- In reply to: `2026-09-02_ARC_TO_SATO_NARU_OVERLAY_V1_VISUAL_EVIDENCE_ONLY.md`（commit `1f50de3bc3dcdd38b15ed1adb9d79a130b1eeb64`）
- State: **EVIDENCE DONE / NO BLOCKING VISUAL DEFECT**

## ACK

担当：佐藤（Claude Code）
状態：受領済み・完了（既存コード=`naru_overlay_engine.py`/`renderer.py`は無変更、指示通り）

## 1. evidence生成結果

新規スクリプト`capture_live_evidence.py`（既存ファイル無変更、外部からの一時的なmonkeypatchのみ）で生成。

方式：`renderer.start()`を実際に呼び出し、本物のライブ描画スレッド（`cv2.namedWindow`+`cv2.imshow`によるウィンドウ）を起動。そのスレッドが呼んでいる`compose_frame()`の出力を外部からフックしてそのままMP4化した。**オフライン一括生成（`demo_naru_overlay.py`）とは別経路**で、実際にライブスレッドが駆動したフレームそのものであることが要点。

- 実行時間：8秒間のライブ駆動
- 捕捉フレーム数：243枚（実測約30.4fps相当、目標30fpsとほぼ一致）
- `renderer.stop()`後、フレーム捕捉が即座に止まることを確認（stop直後243枚→0.5秒後も243枚のまま）

## 2. 実 renderer.start() 経路で表示できたか

**YES。** `renderer.start()` → 実描画スレッド起動 → 8秒間の継続駆動 → `renderer.stop()` → スレッド確実停止、の一連が実際に機能することを確認した（`test_overlay_start_stop.py`の短時間検証に続き、今回はより長い実駆動＋音量波形入力込みで再確認）。

## 3. rest / mouth / blink / hair の目視所見

代表still 5枚を目視確認：

| 状態 | 所見 |
|---|---|
| rest | canonical系列の顔貌・3/4 rest poseそのまま。異常なし |
| mouth open（level=0.772、t=2.07s） | 上下唇が自然に開いている。境界の浮き・不連続なし |
| blink closing序盤 | 目立った変化なし、自然に閉じ始める |
| blink held（ほぼ閉じ切った状態） | 二重像・縞・境界ポップなし。目周辺のみ柔らかいぼけが残る（前回報告済みの既知の残課題、今回悪化なし）。**このフレームでは口も同時に開いており、mouth/blinkの独立合成が同時に機能することも確認できた** |
| HAIR_FRONT sway | 振幅2px/周期4.2秒と小さいため単一stillでは視認困難（前回の拡大比較で境界検証済み、今回は動画内で継続的に揺れていることをフレーム間diffで確認） |

## 4. blocking visual defectの有無

**NONE。** 新しいblocking visual defectは見つからなかった。既知の非blocking残課題（blink held時のごく軽いぼけ）のみで、悪化・新規発生はなし。

## 5. evidence local path

`C:\Projects\vtuber_ai\live2d_assets\naru_v1_extraction\`（ローカルのみ、GitHub非同梱）

- `overlay_v1_LIVE_PATH_evidence.mp4`（8秒、243フレーム、ライブ経路から直接捕捉）
- `overlay_v1_LIVE_still_{rest,mouth_open,blink_closing,blink_held,last}.png`

`capture_live_evidence.py`自体は`C:\Projects\vtuber_ai\`直下（ローカル、こちらもGitHub非同梱。指示が「コード変更を目的にしない」だったため、既存ファイルには一切手を入れず、検証用の使い捨てスクリプトとして扱った）。

## 6. commit

コード変更なし。本Handoffのみを新規commitとして登録する。

## Owner burden rule

ケイへファイル探索・変換作業・再説明を戻していません。
