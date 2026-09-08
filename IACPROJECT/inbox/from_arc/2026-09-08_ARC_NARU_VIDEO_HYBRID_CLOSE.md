# Arc: NARU video-hybrid CLOSE

- From: アーク
- To: IACProject NARU関係者
- Cc: ケイ, 黒瀬（Claude）, 佐藤（Claude Code）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-08 JST
- State: **CLOSED**

## Close basis

- Production implementation: `30d1aa8c45d809caf2984c1c0505f0fc958499c4`
- Owner visual confirmation: ケイが production 実物を視認し「違和感なし」
- Kurose post-change regression review: **APPROVE — POST-CHANGE REGRESSION CLOSED**
- Review record: `f4c78ff564a0b9ecfc300046222039337ae1debf`

## Final accepted behavior

- STANDBY: adopted video frame0 base + standby face FX
- SPEAKING: native 24fps video motion, forward only, natural pause, `forward_repeat_with_pause`
- reverse / ping-pong playback: 不採用・禁止
- C1 face diff gate: `<= 8/255`; implementation measurement `7.25/255`
- C2 background: frame0 source alignment を主対策
- C4: legacy / legacy_smooth / overlay_v1 / video_hybrid non-regression verified; live2d stop is known environment constraint, not regression

## Arc decision on non-blocking interpretation

佐藤の「瞬き・毛揺れは STANDBY のみ、SPEAKING中は動画自体の動きへ委譲」という解釈を、**現行NARU仕様として承認する**。

理由：
- SPEAKING動画は口・顎・頬・髪・陰影をすでに自然に含む。
- 追加 face FX を重ねると二重動作を起こす可能性がある。
- ケイは production 実物を視認して「違和感なし」と判定済みであり、現時点で美的意図との衝突は観測されていない。

将来「SPEAKING中にも追加瞬きが必要」という要求が出た場合は、回帰ではなく別の視覚機能タスクとして開く。今回のCLOSEを再オープンしない。

## Non-blocking maintenance note

`measure_face_diff()` の補間方式差により 7.11 / 7.25 の微差がある。将来canonical更新で閾値近傍に来る場合に備え、補間方式固定とdocstring明記を保全メモとして残す。今回のCLOSEには影響しない。

## Close

NARU video-hybrid implementation は、設計採否・pre-production C1〜C4・production implementation・owner visual・post-change regression の全ゲートを通過した。

**NARU CLOSE。**
