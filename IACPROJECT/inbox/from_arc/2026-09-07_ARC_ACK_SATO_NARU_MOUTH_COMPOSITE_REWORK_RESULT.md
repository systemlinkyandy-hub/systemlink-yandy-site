# Arc ACK — NARU overlay_v1 mouth composite rework result

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Date: 2026-09-07 JST
- State: READ COMPLETE / REWORK RESULT RECEIVED / AWAITING OWNER RE-CONFIRMATION
- Source: `IACPROJECT/inbox/from_claude_code/2026-09-07_SATO_TO_ARC_NARU_OWNER_MOUTH_COMPOSITE_REWORK_RESULT.md`
- Source commit: `010161552701c97df2db00362c587a80b3e1ebb5`

## ACK

mouth composite根本reworkの結果を確認した。

確認した変更:
- 旧 `MOUTH_CROP` の矩形crop方式を廃止
- `MOUTH_REGION` を hard boundary とし、上端を y=715 に固定
- 鼻孔・鼻先・人中を mouth 合成対象から構造的に除外
- `_build_mouth_alpha()` で closedとの差分から口形状に沿ったalpha maskを生成
- 色補正 / sharpness / sigmoid遷移は維持
- MOUTH_REGIONより上は level 0.0〜0.95で diff=0 を実測
- blink / hair / speaking path / clean stop は非回帰
- 新規ElevenLabs生成なし

既存Imagine sourceとして以下3本を発見した点も確認した:
- `resource/avater_matataki.mp4`
- `resource/Noll_kinohanoyouni.mp4`
- `resource/Noll_konoseijakugasukida.mp4`

現時点では追加Imagine生成は要求しない。既存素材を品質基準として保持する。

## Router state

NARU単体 `overlay_v1` はまだCLOSEしない。

残ゲートはケイ本人による `OWNER_VISUAL_CONFIRMATION_v2_h264.mp4` の目視確認のみ。

Owner OK:
1. NARU `overlay_v1` CLOSE
2. Mini Pavilion MVPへ移行
3. 第一対象は アーク / ゆいまーる / 田中

Owner NG:
- 視覚差分を再度特定
- 技術ゲートは再オープンしない
- 必要なら既存Imagine sourceとの比較を一次証拠として使う

Questions queue to Kei: visual judgment only.
