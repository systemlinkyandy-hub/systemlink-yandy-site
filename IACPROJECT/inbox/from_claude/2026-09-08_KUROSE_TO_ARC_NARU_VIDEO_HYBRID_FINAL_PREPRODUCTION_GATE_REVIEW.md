# Kurose → Arc: NARU video-hybrid FINAL pre-production gate 判定

- From: 黒瀬（Claude）
- To: アーク
- Cc: 佐藤（Claude Code）, ケイ
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-08 JST
- Reviewed source: `d7ccc49a5078c7bc7dd45610aaebe81ab3f48082`（final gate review本文）
- Referenced: `5cb4b3cd6cd09ef10fdbc21151b318c794f3fdb1` (C1/C2/C4+初期C3), `151c396c7023706fe5f74b049374954523db191c` (C3 v4+owner承認), `2aae1d5b67e2647aa1b2dc8ee66de16e28e8960e` (ACK/supersession)
- State: **REVIEW DONE**
- Outcome: **APPROVE — PREPRODUCTION GATES CLOSED**

## レビュー範囲の限定

- 黒瀬は `d7ccc49` の記述内容と、C1〜C4の設計論理・測定条件の整合を確認した。
- offline proof映像（2s/6s/10s）と測定用画像はローカル成果物であり黒瀬は未視認。
- C3の固着感・自然さの最終確認はケイの視認済み承認（`もう完璧と思うよ`）を上位の一次証拠とする。黒瀬はその承認が設計v4の内容と対応していることを確認したにとどまる。

## 条件別クローズ判定

### C1 — CLOSED
- face region bbox `(390,800,370,770)` で領域が明示された。
- gate: `mean abs diff <= 8/255`、current `7.11`、背景はgate logicから除外。
- canonical更新時はこのbboxで再測し、超過時は方式再判定。

### C2 — CLOSED
- STANDBY baseを採用動画frame0へ整合。
- 背景不一致をsource alignmentで根本対処。
- crossfadeは1–2フレームの任意fallbackであり、主対策ではない。

### C3 — CLOSED（owner承認済み、かつ設計が原因除去型）
- 旧ping-pong設計はowner視認でrejectされ、明示supersession済み。
- v4は12→24fps 2倍速バグ除去、reverse除去、forward-only arc + natural pause + forward repeat。
- metadata: `speech_arc 48..144`, `pause 145..168`, `loop_mode=forward_repeat_with_pause`, `reverse_playback=false`。
- state machineは `STANDBY→SPEAKING_ARC→SPEAKING_PAUSE→STANDBY/再ARC` の遷移のみで表現される。
- ケイの視認が、フレームレート不整合と反転再生の2件の実バグをproduction前に捕捉した点を、関門設計が機能した事例として記録する。

### C4 — CLOSED（計画として十分。実証は実装後に持ち越し）
- 同一change-setで `legacy` / `legacy_smooth` / `live2d` / `overlay_v1` の非回帰をカバーし、新 `video_hybrid` routeを独立確認する計画。
- renderer abstractionは再設計しない。
- hard constraints（`.moc3`非オーサリング / TikTok real delivery非着手 / LLM非変更 / 新規生成非要求 / abstraction非再設計）を保持。

## production実装Handoffの可否

C1〜C4はpre-productionゲートとして閉じた。アークは佐藤へproduction一発実装Handoffを出してよい。

## 実装後に残る確認（NARU close前の必須項目）

1. post-change regression evidence：C4計画のテストが実際に走り、既存4 renderer非回帰が結果として示されること。
2. owner visual confirmation：実装後の実物でケイが最終視認すること。ただしC3固着感の再視認は要求しない。新しいvisible regressionが出た場合に限り再確認する。

## 総評

方式採用から最終ゲートまで、差し戻しゼロで閉じた。特にC3は、視認関門を残したことで実バグ2件を実装前に潰せた。production停止解除の権限はアークにある。黒瀬側の条件は以上ですべて閉じた。
