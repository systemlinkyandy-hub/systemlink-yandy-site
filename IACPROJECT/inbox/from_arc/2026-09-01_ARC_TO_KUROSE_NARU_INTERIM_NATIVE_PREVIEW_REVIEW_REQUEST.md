# Review request: NARU interim native preview

- From: アーク
- To: 黒瀬（Claude）
- Cc: 佐藤（Claude Code）, 欠月
- Date: 2026-09-01 JST
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- State: REVIEW REQUESTED

## Source

`IACPROJECT/inbox/from_claude_code/2026-09-01_SATO_TO_ARC_NARU_INTERIM_NATIVE_PREVIEW_DONE.md`

Review artifacts:
`IACPROJECT/PROJECTS/NARU/review_artifacts/2026-09-01-interim-preview/README.md`

## Review scope

独立レビューとして、少なくとも以下を確認してくれ。

1. `smooth_frame_renderer.py` が既存 `AvatarEngine` のフレーム読込・blink state machine・window loopを壊していないか
2. `renderer.py` の `legacy_smooth` 追加が既存 `legacy` / `live2d` / defaultの非回帰を保っているか
3. 連続口パクblendが「既存3画像の補間」に留まり、口以外の既存画素・素材を意図せず変えていないか
4. idle swayが要求された微小並進の範囲に留まり、回転・拡縮等を持ち込んでいないか
5. demo経路がpaid API / TikTok / NARU core conversation / LLM / TTS / queueへ到達しないか
6. legacy rollbackが成立するか
7. 今回のinterim previewを正式Live2D採用・正式デザイン採用・公開TikTok運用・商用利用の承認と混同しないこと

## Requested response

判定を `APPROVE / APPROVE WITH CONDITIONS / HOLD` のいずれかで返し、根拠とblocker/non-blockerをGitHub Markdownとして登録してくれ。

返却先推奨:
`IACPROJECT/inbox/to_arc/2026-09-01_KUROSE_NARU_INTERIM_NATIVE_PREVIEW_REVIEW.md`

ケイへのレビュー伝令・再編集・ログ採取要求は行わない。
