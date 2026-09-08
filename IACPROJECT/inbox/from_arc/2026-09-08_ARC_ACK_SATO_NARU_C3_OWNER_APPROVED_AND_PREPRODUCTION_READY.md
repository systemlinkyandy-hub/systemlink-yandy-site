# Arc ACK: NARU C3 owner-approved / pre-production gates ready

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-08 JST
- Sources:
  - `5cb4b3cd6cd09ef10fdbc21151b318c794f3fdb1`
  - `151c396c7023706fe5f74b049374954523db191c`
- State: **READ COMPLETE / C1-C4 DESIGN+PROOF RECEIVED / C3 OWNER APPROVED / PRODUCTION STILL HELD FOR FINAL REVIEW GATE**

## ACK

佐藤の pre-production gates 結果と C3 v4 owner-approved 結果を受領した。

確認した現在地：

- C1: 顔領域 bbox `(y0,y1,x0,x1)=(390,800,370,770)`、顔領域diff gate `<= 8/255`、現行実測 `7.11` で閾値内。
- C2: STANDBY表示ベースを採用動画frame0へ合わせ、背景ポップインをソース一致で根本対策する設計。crossfadeは主対策にしない。
- C3: 旧ping-pong/hold方式は破棄。v4で `source_fps=24 / playback_fps=24` に揃え、reverse playbackを廃止し、`forward_repeat_with_pause` を採用。2秒/6秒/10秒 proof をケイが視認し「もう完璧と思うよ」と承認済み。
- C4: 既存 `legacy / legacy_smooth / live2d / overlay_v1` の非回帰テスト計画あり。新設routeは独立分岐とし、既存処理の二重管理を避ける設計。

## Important supersession

`5cb4b3c` に記載された旧C3 metadata/state machine（ping-pong / reverse tail）は **不採用**。
以後のC3正は `151c396` の以下とする。

- `speech_arc: frame48..144`
- `pause: frame145..168`
- `loop_mode: forward_repeat_with_pause`
- `reverse_playback: false`
- state: `STANDBY -> SPEAKING_ARC -> SPEAKING_PAUSE -> (SPEAKING_ARC | STANDBY)`

## Decision boundary

佐藤の実装作業はここでは再開させない。
黒瀬へ C1-C4 の最終pre-production gate close確認を回す。黒瀬判定後、アークからproduction一発実装Handoffを出す。

## Owner burden

ケイへの追加視認・commit探索・コード確認・素材作成要求は出さない。C3 owner gateは完了扱いとする。
