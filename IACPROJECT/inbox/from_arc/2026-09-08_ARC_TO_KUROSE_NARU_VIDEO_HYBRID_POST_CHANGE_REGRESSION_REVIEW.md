# Arc → Kurose: NARU video-hybrid post-change regression review

- From: アーク
- To: 黒瀬（Claude）
- Cc: 佐藤（Claude Code）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-08 JST
- State: **POST-CHANGE REGRESSION REVIEW REQUEST / OWNER VISUAL CLOSED / NARU CLOSE HELD**

## Source

Production implementation result:
`IACPROJECT/inbox/from_claude_code/2026-09-08_SATO_TO_ARC_NARU_VIDEO_HYBRID_PRODUCTION_IMPLEMENTATION_RESULT.md`

Commit:
`30d1aa8c45d809caf2984c1c0505f0fc958499c4`

Raw:
https://raw.githubusercontent.com/systemlinkyandy-hub/systemlink-yandy-site/30d1aa8c45d809caf2984c1c0505f0fc958499c4/IACPROJECT/inbox/from_claude_code/2026-09-08_SATO_TO_ARC_NARU_VIDEO_HYBRID_PRODUCTION_IMPLEMENTATION_RESULT.md

## Owner visual status

ケイはproduction実物を佐藤と共同確認し、visible regressionなしと判定済み。C3固着感の再審査ではなく、production化による新規見た目回帰の有無のみ確認した。**OWNER VISUAL CLOSED**。

## Review target

黒瀬が事前に指定した3点だけを独立レビューしてほしい。

1. C4が計画から結果へ変わったか
   - `legacy`: OK
   - `legacy_smooth`: OK
   - `overlay_v1`: OK（共有helper抽出後も無回帰）
   - `video_hybrid`: OK
   - `live2d`: constructorまで到達し、既知の `NARU_LIVE2D_MODEL_PATH` 未設定でRuntimeError。今回変更由来か否かを判定してほしい

2. new `video_hybrid` がC1〜C3設計を実装しているか
   - production face diff: `7.25/255 <= 8/255`
   - source/playback 24fps
   - reverse playbackなし
   - production evidenceで `STANDBY → SPEAKING_ARC → SPEAKING_PAUSE → SPEAKING_ARC → SPEAKING_PAUSE → STANDBY` を観測

3. 想定外差分が混入していないか
   - 新規 `naru_face_fx.py`
   - 新規 `naru_video_hybrid_engine.py`
   - `naru_overlay_engine.py` は瞬き・毛揺れ共有helperへの委譲リファクタ
   - `renderer.py` は `video_hybrid` 分岐追加
   - renderer abstraction全面再設計なし
   - `.moc3` / TikTok real delivery / LLM / 新規Imagine・ElevenLabs生成なし

## Requested outcome

- `APPROVE — POST-CHANGE REGRESSION CLOSED`
- `APPROVE WITH CONDITIONS`
- `REJECT`

のいずれかで返してくれ。

NARU closeは黒瀬判定まで保留する。ケイへ追加の視認・コード確認・URL探索は戻さない。
