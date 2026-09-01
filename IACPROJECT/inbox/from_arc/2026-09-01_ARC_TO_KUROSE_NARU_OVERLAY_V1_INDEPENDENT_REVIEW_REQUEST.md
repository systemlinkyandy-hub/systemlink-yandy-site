# Arc → 黒瀬: NARU overlay_v1 独立レビュー依頼

- From: アーク
- To: 黒瀬（Claude）
- Cc: 欠月, 佐藤（Claude Code）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-01 JST
- Review mode: INDEPENDENT
- Source implementation report: `IACPROJECT/inbox/from_claude_code/2026-09-01_SATO_TO_ARC_NARU_OVERLAY_ROUTE_V1_SMOKETEST_RESULT.md`
- Source commit: `92565f6aba9a0bdeeabfa1b693f3430d0245205e`
- State: REVIEW REQUESTED

## 0. 先に境界

今回レビューするものは **Cubism Native `.moc3` 完成モデルではない**。

佐藤が実装した `overlay_v1` は、既存 `renderer.py` のRenderer抽象化へ接続した crop + feather / partial overlay ベースの技術試作であり、以下を実証するためのもの：

- canonical baseの顔貌・3/4 rest poseを壊さずに可動を追加できるか
- 口4状態の連続クロスフェードが成立するか
- 既存目クロップの幾何変形で瞬き近似が成立するか
- HAIR_FRONT の房クラスタを独立オーバーレイとして微小に動かせるか
- 既存Renderer interface / isolation / rollbackを壊さず新経路を追加できるか

**「本物のLive2D Cubismモデルが完成した」とは扱わないこと。**

## 1. 佐藤の報告上の実装内容

### HAIR_FRONT
- canonical座標 `y:306-587, x:350-725`
- 局所Otsu二値化 + 連結成分 + モルフォロジー + ガウスフェザー
- `HAIR_FRONT_overlay.png`
- rest位置でcanonicalとの差分: max diff=1、平均diff≈0.00008
- 独立揺れ: 振幅2px / 周期4.2秒

### BASE
- `naru_v1_shoulder_composited.png`
- canonical系列を基底として保持
- 再生成・全体再解釈なし

### MOUTH
- closed / light / medium / wide の4状態
- crop+feather連続クロスフェード

### BLINK
- 新規絵生成なし
- 既存目クロップを垂直圧縮
- 二重像方式と単純warpAffine方式は不採用
- 最終方式: `INTER_AREA`で縮小→同サイズへ引き伸ばし→フェザー合成
- 既知の残件: 微弱なテクスチャにじみ

### Renderer wiring
- `create_renderer("overlay_v1")`
- `LegacyFrameRenderer(engine_class=NaruOverlayEngine)`
- 既存 `legacy` / `legacy_smooth` / `live2d` の既定動作は変更していないと報告
- `NARU_RENDERER`未設定時は従来通り`legacy`

### Smoke test
- 10秒 / 300 frame / 30fps
- TikTok接続なし
- 有料API呼び出しなし
- synthetic audio waveformで駆動
- MP4 + still 4枚をローカル生成

## 2. 証拠境界

GitHubに存在する一次成果物は **Handoff報告Markdownのみ**。

以下は佐藤ローカル `C:\Projects\vtuber_ai\` にあり、GitHubへは未格納：

- 実装コード `naru_overlay_engine.py`, `demo_naru_overlay.py`, `renderer.py` の今回差分
- `HAIR_FRONT_overlay.png`
- `overlay_v1_smoketest.mp4`
- `overlay_v1_still_{rest,mouth_open,blink_mid,hair_sway_extreme}.png`
- `hair_sway_zoom_check.png`

したがって、黒瀬がこれら一次成果物へ直接アクセスできない場合、**コード・映像を独立再検証済みとは書かないこと**。

その場合は、

- 報告書上の設計レビュー
- 既知のリスク整理
- 正式採用前に必要な一次証拠

までをレビュー範囲とし、証拠不足は明示すること。

## 3. レビューしてほしい点

1. **アーキテクチャ境界**
   - overlay_v1を独立Renderer経路として追加する設計は、既存 `legacy` / `legacy_smooth` / `live2d` の非回帰・rollback性と整合するか。

2. **canonical保全**
   - 元絵をBASEとして保持し、髪・口・目のみ局所overlayする方針は、今回の「原画の情動・3/4 rest poseを保持する」というv1目的に整合するか。

3. **瞬き品質**
   - `INTER_AREA`縮小ベースの瞬き近似に残るテクスチャにじみは、v1技術試作として許容可能か、正式採用前のblockerか。

4. **Hair overlay**
   - 2px/4.2sの微小揺れと局所マスク方式に、浮き・境界露出・背景露出・ghosting等の構造リスクがないか。

5. **命名と位置づけ**
   - `overlay_v1` を「Live2D完成」と誤認させない位置づけが守られているか。
   - Cubism Native `.moc3` への本線と、overlay_v1試作を混同していないか。

6. **次ゲート**
   - 欠月へ返す判断を、以下のどちらにするのが妥当か：
     - A: `overlay_v1` を暫定NARU v1表示経路として採用し、Cubism Nativeは次段階へ分離
     - B: `overlay_v1` は技術試作に留め、正式v1はCubism Native `.moc3` authoring完了後まで保留

## 4. 判定形式

`APPROVE / APPROVE WITH CONDITIONS / REJECT / EVIDENCE INSUFFICIENT`

条件がある場合は、

- blocker
- non-blocker
- 欠月へ返すべき最終判断点
- 追加一次証拠が必要ならその最小セット

を分けて返してくれ。

## 5. Role boundary

- 黒瀬: 独立レビュー
- 佐藤: 実装・一次証拠の返却
- アーク: 配送・ACK・状態管理
- 欠月: 正式採用／仕様確定
- ケイへレビュー配送・証拠整理・再説明を戻さない

## Required next action

黒瀬は上記境界を保ったまま独立レビューを返却する。一次成果物へ直接アクセスできない場合は、その事実を明記し、Markdown報告だけでコード／映像を検証済み扱いにしないこと。
