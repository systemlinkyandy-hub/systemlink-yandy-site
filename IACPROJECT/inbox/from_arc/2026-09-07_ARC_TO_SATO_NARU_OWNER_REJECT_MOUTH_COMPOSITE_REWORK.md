# Handoff — NARU owner REJECT / mouth composite rework

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Date: 2026-09-07 JST
- Priority: HIGH
- State: OWNER REJECT / VISUAL QUALITY REGRESSION / CLOSE BLOCKED
- Project: NARU / Mini Pavilion
- Previous fix commit: `6fac709ac1ee008dfddf5ab7252fc6f9a7b5cd39`

## 1. Owner verdict

ケイが修正版動画を目視確認し、**REJECT**。

前回の3点（色差 / 座標ずれ感 / 線の甘さ）は、局所的polishでは解決していない。むしろ発話開始時に顔下半分の形状劣化が明確に見える。

ケイから6枚のスクリーンショットが提示された。

- `naru_mouse_nose1.png`
- `naru_mouse_nose2.png`
- `naru_mouse1(1).png`
- `naru_mouse2(1).png`
- `naru_mouse3(1).png`
- `naru_mouse4(1).png`

アーク側でも画像を確認した。owner指摘と整合する。

## 2. Confirmed visual defects

### A. Nose deformation / upper-face contamination

最初の2枚では、発話時に**鼻先から人中・上唇にかけて形が潰れて見える**。

これは「口だけ」の変化ではない。mouth overlayが鼻下まで含む周辺画素を置換または混合しており、canonical faceの鼻形状まで巻き込んでいるように見える。

よって acceptance condition を変更する。

> **Mouth animation must not modify nose geometry / nose shading / philtrum outside the minimum lip region.**

### B. Double mouth / ghost contour

口線が一つの輪郭として動かず、複数の輪郭・陰影が重なった二重像に見えるフレームがある。

前回の sigmoid 化は「二重像区間を短くする」だけで、根本原因である**異なる口形状画像の alpha/addWeighted crossfade**を残している。

owner quality gateでは、短時間でも明瞭な二重口が出るならFAIL。

### C. Color / texture discontinuity

口周辺の肌色と陰影が発話時だけ変化する。LAB統計一致後も、base faceとmouth-state側で局所テクスチャ・線画・陰影構造そのものが異なるため、単純な色統計補正では一体化していない。

### D. Quality regression against source motion

ケイの記憶では、元はImagine由来の動画を基準にしており、現在のcrop+feather/crossfade結果はその自然な口・鼻周辺表現からかなり劣化して見える。

ここを重要な比較基準として扱う。

## 3. Architectural judgment for this subproblem

`overlay_v1` 全体を破棄する必要はないが、**mouthについては現行の「広い矩形crop + 状態画像crossfade + feather」方式をpolishし続けるのを一旦停止**する。

これ以上 blur kernel / sigmoid / LAB / sharpen の数値だけを追い込むのは、owner指摘の構造的欠陥に対して局所最適化になる可能性が高い。

mouthのみ再設計する。

優先候補:

1. canonical BASEは鼻・人中・顎を含めて固定
2. source mouth statesから**唇・口腔・必要最小限の口周囲だけのRGBA patch/mask**を作る
3. nose領域をmaskから明示的に除外する
4. 口形状間の遷移で二つの線画を同時表示しない
   - nearest/discrete state + temporal smoothing
   - または口輪郭landmarkベースの局所warp
   - または既存Imagine動画から自然な中間形状を追加抽出
   のいずれかを比較し、最小で高品質な方式を選ぶ
5. 「色統計を画像全体へ変換してからcrop」ではなく、必要ならpatch内部だけで局所補正する

実装方式の最終選択は佐藤側で一次検証し、黒瀬レビューへ回す。アークは方式を固定しない。

## 4. Imagine reference handling — owner burden rule

ケイは「必要ならImagineで動画を作ってスクショする」と申し出ているが、**現時点では新規作成を依頼しない。**

まず佐藤側で以下を確認すること。

- 既存ローカルに、mouth state抽出元となったImagine動画または元フレームが残っているか
- 既存素材から、自然な口開閉のreference frameを再利用できるか

既存sourceがあるなら、それをquality baselineとして使う。

**既存sourceが見つからない / 比較に必要な中間口形状が不足している場合のみ**、アークへ `SOURCE_REFERENCE_NEEDED` と返す。その時点でケイへ「短いImagine動画1本」または「必要な口形状数枚」のみ依頼する。

ケイに先に新規生成作業をさせない。

## 5. New acceptance criteria

次のowner再確認では、以下をすべて満たすこと。

- 鼻先・鼻孔・鼻下の陰影が発話前後で変形しない
- 人中が潰れない
- 口輪郭は常に一組だけ見える（二重線なし）
- 発話中だけ口周辺の肌色が切り替わって見えない
- closed ↔ open の途中で顔下半分が揺れたり膨張/収縮しない
- 口線はcanonicalの線画密度・シャープさを維持
- blink / hair / speaking path / clean stopは非回帰
- ownerが「元Imagine動画から明確に劣化した」と感じる品質ではCLOSEしない

## 6. Mini Pavilion impact

Mini Pavilion（アーク / ゆいまーる / 田中 3人MVP）は継続目標。

ただしこのmouth defectを3人へコピーしないこと。

NARUでmouth compositeの正しい最小方式を確立してからcharacter profileへ横展開する。

## Required next action

1. 既存Imagine sourceの有無を確認
2. 現行mouth crossfade方式を根本原因ベースで比較
3. noseを完全固定できるmouth-only合成方式の小さなproofを作る
4. 静止画4〜6枚（closed / light / medium / wide / transition）と短い既存音声動画を出す
5. 黒瀬レビュー可能な差分・根拠を返す

Owner visual gate remains **OPEN / REJECTED**.
