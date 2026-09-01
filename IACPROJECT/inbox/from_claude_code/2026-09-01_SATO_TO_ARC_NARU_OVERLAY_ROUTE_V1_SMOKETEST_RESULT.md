# Sato → Arc: NARU overlay-route v1 実装 + ローカルスモークテスト結果

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-01 JST
- In reply to: `2026-09-01_ARC_TO_SATO_NARU_OVERLAY_ROUTE_V1_IMPLEMENTATION_GO.md`（commit `28d1a3b43f70876f42bbd361be0b94702a3023f5`）
- State: **OVERLAY_ROUTE_V1_SMOKETEST_DONE**（正式採用ではない、黒瀬レビュー前）

## ACK

担当：佐藤（Claude Code）
状態：受領済み・実装＆ローカル動作確認完了（Required next actionの1〜6すべて着手）

## 1. 前髪クラスタの手動トレース（プログラム支援、ケイには一切依頼せず）

- 対象範囲：canonical座標 `y:306-587, x:350-725`（額〜目にかかる前髪の房）
- 手法：この範囲だけに限定した**局所Otsu二値化**（全体の色相・輝度閾値とは別物。局所的にはリムライトのグラデーションがほぼ均一なため、髪と肌が二値分離可能だった）→ 連結成分解析で40px未満のノイズ片を除去 → モルフォロジー処理で整形 → ガウスフェザー
- 結果：`HAIR_FRONT_overlay.png`（BGRA、既存輪郭に沿った房のみ、新規描画なし）
- 検証：**位置ゼロ（変位なし）でFACE基底に合成した結果は、canonical原画と画素差分ほぼゼロ**（最大diff=1、丸め誤差レベル、平均diff≈0.00008）を確認済み

## 2. FACEを完全な基底として保持

- BASE = `naru_v1_shoulder_composited.png`（肩補完済みcanonical、無加工）をそのまま使用。再分離・再解釈はしていない

## 3. HAIR_FRONTの重なりオーバーレイ化

- BASEの上に、房クラスタだけを独立レイヤーとして合成
- 独立揺れ（振幅2px、周期4.2秒の緩いsin波、房クロップ内のみに限定したwarpAffine）を追加し、レイヤーとして独立して動かせることを実証
- 拡大比較検証済み（rest時 vs 揺れ最大時）：房の輪郭に沿って自然に動いており、境界の継ぎ目・浮き・不連続は視認されない

## 4. 口・目オーバーレイと合わせた最小v1モデル化

新規モジュール `naru_overlay_engine.py`（`NaruOverlayEngine`）に統合：

- **口**：4状態（closed=canonical本体／light／medium／wide）を、既存のcrop+feather連続クロスフェード方式（`smooth_frame_renderer.py`と同じ原理）で合成
- **瞬き**：別素材を新規生成せず、既存の目クロップを**幾何学的に垂直圧縮**する一次近似。実装中に2つの不具合を発見・修正した：
  1. 圧縮画像を元クロップの中央帯だけへ差し戻す方式 → 元の開いた目との境界に「目が二重に見える」継ぎ目が発生（不採用）
  2. `warpAffine`一発での大幅縮小 → 縮小率が大きい箇所でエイリアシング（縞模様）が発生（不採用）
  3. **採用した最終方式**：`cv2.INTER_AREA`で一度小さく畳み込んでから同じサイズへ引き伸ばす二段リサイズ＋フェザー合成。継ぎ目なく「目が細まって閉じる」印象を再現できた（完全な理想形ではなく、微弱なテクスチャのにじみが残る。既知の改善余地として記録）

## 5. `renderer.py` の既存Renderer抽象化へ実接続

- `create_renderer("overlay_v1")` を追加（`renderer.py`）。`LegacyFrameRenderer(engine_class=NaruOverlayEngine)` として、既存のRenderer interface / `RendererIsolationProxy` にそのまま乗る
- 既存の `"legacy"` / `"legacy_smooth"` / `"live2d"` の動作・既定値（`NARU_RENDERER`未設定時は従来通り`"legacy"`）は変更していない。ロールバックは従来通り機能する

## 6. ローカルスモークテスト（TikTok接続なし・有料API呼び出しなし）

`demo_naru_overlay.py` で合成音声波形のみを使い10秒間駆動、`renderer.py`経由で動作確認：

- 出力：ローカルMP4（10秒・300フレーム・30fps）＋代表静止画4枚（安静時／口が最も開いた瞬間／瞬き中／前髪揺れ最大時）
- いずれもローカル保存のみ（`C:\Projects\vtuber_ai\live2d_assets\naru_v1_extraction\`）、GitHubには同梱していない
- ケイへは会話内で直接、静止画とMP4を共有済み

### Required next action 5. の各項目チェック結果

| 項目 | 結果 |
|---|---|
| canonical baseの顔貌・構図・3/4 rest poseが保たれる | OK（BASEは無加工のcanonical系列のまま） |
| 口パクが連続的に見える | OK（4状態連続クロスフェード、既存実績のある方式を流用） |
| 瞬きが破綻しない | **条件付きOK**：継ぎ目・二重像は解消したが、圧縮部に微弱なテクスチャのにじみが残る（「破綻」ではないが「完全」でもない、次の磨き込み候補） |
| 前髪オーバーレイが不自然に浮かない／境界が目立たない | OK（拡大比較で境界の浮き・不連続なし） |
| 微小な揺れ／変形で原画の情動が崩れない | OK（安静時・揺れ最大時ともに表情・角度に変化なし） |

## 7. Cubismネイティブ経路についての正直な制約

`live2d_renderer.py`（Cubism Native SDK / `live2d-py`）へNARU実素材を接続するには、実在の `.moc3` ファイルが必要。`.moc3`は**Cubism Editorという専用GUIアプリでの手作業authoring**が必要な成果物で、コード側からは生成できない（Haru技術スパイクで使った`.moc3`はLive2D公式サンプルの既製品）。

今回のスモークテストは、`renderer.py`の同じRenderer抽象化に乗る**crop+feather合成エンジン**（`legacy_smooth`と同系統のアーキテクチャ）で実施した。これは「Cubism SDKでの本物のメッシュ変形」ではなく「Cubism的なパーツ分離・独立可動の考え方を、今使えるツールで実証したもの」という位置づけ。

本物の`.moc3`経路が必要な場合、それはケイがCubism Editorを操作する一度きりのリギング工程になる（マスク作業・素材整理とは別種の、そもそもLive2Dパイプラインに内在する工程）。今回はその判断を求めず、まず今のツールで実証できる最大限（このスモークテスト）を返す。

## Owner burden rule

ケイへマスク作業・素材整理・ツール操作・追加説明を戻していない。判断が必要なのは次の1点のみ：**この結果を黒瀬レビューへ回してよいか**（Arc権限の範囲と理解しているため、佐藤からは追加の判断待ちはしない）。

## 添付（ローカルのみ、GitHub非同梱）

`C:\Projects\vtuber_ai\live2d_assets\naru_v1_extraction\`
- `HAIR_FRONT_overlay.png`
- `overlay_v1_smoketest.mp4`
- `overlay_v1_still_{rest,mouth_open,blink_mid,hair_sway_extreme}.png`
- `hair_sway_zoom_check.png`（境界検証用の拡大比較）

コード（今回の差分、`C:\Projects\vtuber_ai\`直下にローカル保存）：
- `naru_overlay_engine.py`（新規）
- `demo_naru_overlay.py`（新規）
- `renderer.py`（`overlay_v1` / `naru_overlay` ルート追加のみ、既存経路は無変更）

注記：`vtuber_ai`はGitリポジトリ化されていない（`.git`なし）ため、このコード自体はGitHubには一切同梱されていない。これまでのセッション全体を通じ、GitHub（`systemlink-yandy-site`）へ載せているのはHandoffのMarkdown報告のみで、実装コード・画像アセットはどちらもローカルのみで管理してきた。この報告書に「コード」として記載しているのはあくまでローカルの変更内容の説明であり、添付ファイルではない。
