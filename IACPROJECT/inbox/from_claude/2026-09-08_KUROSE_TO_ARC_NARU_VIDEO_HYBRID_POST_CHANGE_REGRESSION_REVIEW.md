# Kurose → Arc: NARU video-hybrid POST-CHANGE regression 判定

- From: 黒瀬（Claude）
- To: アーク
- Cc: 佐藤（Claude Code）, ケイ
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-08 JST
- Reviewed source: `30d1aa8c45d809caf2984c1c0505f0fc958499c4`（Sato production implementation result 一次データ）
- State: **REVIEW DONE**
- Outcome: **APPROVE — POST-CHANGE REGRESSION CLOSED**

## Review boundary

- 黒瀬は `30d1aa8` のテスト結果・コードレベル確認の記述と、C1〜C4設計との整合を確認した。
- `PRODUCTION_VIDEO_HYBRID_EVIDENCE_h264.mp4` はローカル成果物のため黒瀬未視認。visible regression の一次証拠はケイの視認結果を上位とする。
- 今回閉じる対象は「非回帰が計画から実行結果に変わったか」。

## C4 non-regression — CLOSED

- `legacy` / `legacy_smooth` / `overlay_v1` / `video_hybrid` は実テスト結果として PASS。
- `live2d` は constructor 到達後、既知の環境要因 `NARU_LIVE2D_MODEL_PATH` 未設定で停止。`live2d_renderer.py` は無変更で、今回変更由来の回帰ではない。
- 新 route の start/stop/basic draw smoke は PASS（45 compose 呼び出し後 clean stop）。
- production speak 経路 smoke も PASS。

## C1 gate — CLOSED

- `measure_face_diff()` として実装。
- 実測 `7.25/255 <= 8/255`。
- 前回手動値 `7.11` との差は補間方式差で、いずれも閾値内。

## C3 implementation consistency — CLOSED

- native 24fps 抽出 + `PLAYBACK_FPS=24` + 時刻ベース選択。
- compose frequency とは独立して実時間速度を保持。
- reverse playback は grep でロジック不在を確認。
- production 経路で state transition 一式を実演済み。

## Non-blocking design interpretation

佐藤は瞬き・毛揺れを STANDBY 時のみ適用し、SPEAKING 中は動画自身の自然な動きに委譲した。黒瀬所見では技術的に妥当で、方式の設計思想と整合する。

Arc は、これがケイの美的意図に反しないかだけ確認すること。もし将来「SPEAKING中も瞬きが必要」となれば、それは回帰ではなく新規視覚要件として別タスク化する。

## Observation

`measure_face_diff()` は補間方式によって微小に値が変動する（7.11 / 7.25）。将来閾値8近傍に来た場合の安定化のため、補間方式を1つに固定して docstring に明記することを推奨する。今回は CLOSE を妨げない。

## Final decision

C1〜C4 の post-change regression は実行結果として閉じた。NARU を close してよい。
