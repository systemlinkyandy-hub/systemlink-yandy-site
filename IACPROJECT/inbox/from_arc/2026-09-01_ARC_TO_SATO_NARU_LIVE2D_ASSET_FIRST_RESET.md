# Arc → Sato: NARU Live2D asset-first reset

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-01 JST
- State: INTERIM JPEG PREVIEW STOP / LIVE2D ASSET-FIRST RESET

## User correction

目的は既存JPEGをLive2D風に補間することではなく、NARU本人を本物のLive2D/Cubismモデルとして成立させること。

現行interim preview v1-v3は技術的な探索として十分。これ以上のJPEGクロスフェード／クロップ補間／全画面変形／疑似揺れ調整には工数を入れない。

## Facts

- 既存NARU視覚素材は背景込みの完成イラストで、Cubismリグ用のレイヤー分離素材ではない。
- Cubism公式ドキュメントでは、魅力的に動かすには最低限の素材分けが必要。
- 基本工程は、基準絵 → 素材分け → 隠れ部分の描き足し → import PSD → Cubism rig → renderer接続。
- 既存Live2D SDK/Core/render pathの技術スパイクは既にPASSしており、Haruで実描画・口パラメータ駆動まで確認済み。

## Required next work

### 1. Freeze interim JPEG preview

- `legacy_smooth` は探索成果として保持してよいが、追加改修しない。
- user visual feedback「瞬き時に目周辺が飛び出す」「口が開いた状態が消えるように閉じる」を最終FAIL evidenceとして残す。
- legacy renderer本体はrollback用に保持。

### 2. Prepare Live2D asset specification only

佐藤は新規絵を勝手に生成・再解釈しない。
次に必要なものを技術仕様として整理する：

- 基準正面イラスト 1枚
- 推奨キャンバス／解像度
- 必須レイヤー一覧
  - face base / contour
  - brows L/R
  - eyelashes / eyelids L/R
  - eye whites L/R
  - irises/pupils L/R
  - upper/lower lips
  - mouth interior / teeth / tongue as needed
  - nose
  - ears L/R
  - bangs / side hair L/R / back hair
  - neck
  - torso / clothing major groups
- 動作時に必要な隠れ部分の補完領域
- layer naming convention
- material-separation PSD と import PSD の分離
- Cubismへ入れた後の最小parameter set
  - ParamAngleX/Y/Z
  - ParamEyeLOpen / ParamEyeROpen
  - ParamEyeBallX/Y
  - ParamMouthOpenY
  - ParamMouthForm
  - breath / hair physics は後段でよい

### 3. Copyright / identity boundary

- ユーザーが提示する「本の絵」が第三者著作物の場合、その画像自体をトレース・分解・モデル資産化する前提にしない。
- その場合は視覚参照として特徴を抽出し、NARUとして新規原画を起こす工程へ分離する。
- ユーザー自身が権利を持つ絵なら、その絵を素材分けの基準にできる。
- NARUの顔立ち・髪型・雰囲気を勝手に別人化しない。

## Do not do

- interim JPEG previewの追加調整
- Haruを正式NARU外観に採用
- 第三者画像の無断トレース／配布
- Live2D正式採用・公開・商用判断の代行
- ケイへ細切れで素材要求を返す

## Return format

基準絵受領前に、必要素材一覧を1回に圧縮した `NARU_LIVE2D_ASSET_SPEC` を返す。
基準絵が来たら、その1枚を基準に「残す特徴／変更不可点／レイヤー分離計画／不足描画」を整理する。
