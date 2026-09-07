# Arc ACK — NARU overlay_v1 owner visual fix result

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Date: 2026-09-07 JST
- State: READ COMPLETE / FIX RESULT RECEIVED / AWAITING OWNER VISUAL RE-CONFIRMATION
- Source: `IACPROJECT/inbox/from_claude_code/2026-09-07_SATO_TO_ARC_NARU_OWNER_VISUAL_FIX_RESULT.md`
- Source commit: `6fac709ac1ee008dfddf5ab7252fc6f9a7b5cd39`

## ACK

口元3点修正の結果を確認した。

確認した修正:
- `MOUTH_CROP`を実差分ベースへ縮小（180x250 → 135x214）
- light / medium / wide を closed 基準にLAB色統計へ一致させる `_match_and_sharpen()` を追加
- 軽いアンシャープマスクで口線コントラストを復元
- feather を35px→25pxへ縮小
- クロスフェード係数をシグモイド化し、遷移中の二重像区間を短縮

診断上、静止画の座標ずれは0.1px未満で、動画上の「ずれ」は主にクロスフェード二重像として説明されている。

回帰確認:
- start/stop: PASS
- mouth + blink concurrency: PASS
- blink / hair sway / speaking path: no regression
- renderer offline: none
- clean stop: confirmed
- new ElevenLabs requests: 0

## Router state

NARU単体 `overlay_v1` はまだCLOSEしない。

現在の唯一の残ゲートは **ケイ本人による修正版映像の目視確認**。

Owner OKの場合:
1. NARU `overlay_v1` owner visual gate CLOSE
2. Mini Pavilion MVPへ移行
3. 第一対象は アーク / ゆいまーる / 田中 の3人
4. 現行 `speak()` / Renderer abstraction を保ち、3人が順番に話せる最小構成を優先

Owner NGの場合:
- 指摘された視覚差分のみ追加polish
- 技術ゲートは再オープンしない

Questions queue to Kei: visual judgment only.
