# Arc → Sato: NARU overlay_v1 evidence packaging + blink polish

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-02 JST
- State: **IMPLEMENTATION CONTINUE / REVIEW EVIDENCE PREP**

## Current routing boundary

NARUの標準ルートは以下とする。

- 実装: 佐藤
- 独立レビュー: 黒瀬
- Router: アーク
- 欠月: NARU案件から除外。採否依頼・ACK追跡を行わない。

Source:
`IACPROJECT/OPERATING_RULES/NARU_ROUTING_BOUNDARY_NO_KAKEZUKI.md`

## Current state

- `overlay_v1` implementation + local smoke: DONE
- 先行黒瀬レビュー: `EVIDENCE INSUFFICIENT`
- shared `LegacyFrameRenderer(engine_class=...)` concern: targeted reviewで `SHARED_RENDERER_CHANGE_OK`（ケイ経由secondary evidence）
- shared renderer一次コード証拠: GitHub上でArc確認済み
- overlay_v1全体: **技術試作として継続可 / 全体独立レビューは未完了**

## Required next action

次は以下の2点だけ進めること。

### 1. overlay_v1 実コードを review artifact 化

黒瀬がGitHub一次証拠として読める形で、必要最小限の実装コード／差分を `IACPROJECT/PROJECTS/NARU/review_artifacts/` 配下へ登録する。

最低限:
- `naru_overlay_engine.py`
- `renderer.py` の overlay_v1 該当差分、または比較可能な該当版
- 必要なら `demo_naru_overlay.py`

目的はコード保管ではなく**独立レビュー可能な一次証拠化**である。
秘密情報、`.env`、API key、個人情報、不要なローカル絶対パスは含めないこと。
画像・動画は必須ではない。視覚挙動の主張に追加証拠が必要なら、最小の代表静止画または短い比較結果のみ検討する。

### 2. blink texture smear のみ磨き込み

現在の瞬き実装で残っている「圧縮部の微弱なテクスチャにじみ」を対象にする。

Hard constraints:
- canonical NARU画像・顔貌・3/4 rest poseを変更しない
- 目以外の顔、髪、輪郭、口、衣装を触らない
- 新規AI再生成をしない
- overlay_v1の既存hair/mouthロジックを不要に変更しない
- legacy / legacy_smooth / live2d の既定経路を変更しない
- NARU core conversation / TikTok / LLM / TTS / queueを変更しない

改善後は、rest / blink-mid / closed近傍で二重像・縞・境界ポップ・過度なぼかしがないことをローカル確認する。

## Do NOT start yet

- Cubism `.moc3` authoring
- 新しいbase portrait生成
- 大規模な髪・顔segmentation再探索
- 旧interim JPEG previewへの回帰
- ユーザーへのマスク作業・素材整理・Cubism GUI操作の差し戻し

`.moc3` は別工程として、overlay_v1レビュー完了後に改めて判断する。

## Return packet

完了時は1本のHandoffで以下を返すこと。

1. review artifact path一覧
2. commit
3. blink polishの変更点
4. 非回帰確認結果
5. ローカルsmoke結果
6. 黒瀬へレビュー可能か: YES / NO
7. Open issues（あれば）

完了後、Arcが黒瀬へ overlay_v1 全体の独立レビューを一本でRoutingする。

## Owner burden rule

ケイへコード確認・レビュー依頼文作成・素材探索・進捗監視を戻さない。
