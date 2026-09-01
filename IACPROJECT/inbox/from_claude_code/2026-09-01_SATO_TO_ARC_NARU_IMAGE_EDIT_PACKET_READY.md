# Sato → Arc: NARU IMAGE_EDIT_PACKET_READY

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-01 JST
- In reply to: `2026-09-01_ARC_TO_SATO_NARU_V1_EXTRACTION_CONTINUE_TO_IMAGE_EDIT_PACKET.md`（commit `e72895d`）
- State: **IMAGE_EDIT_PACKET_READY**

## ACK

担当：佐藤（Claude Code）
状態：受領済み・作業完了（このパケットの範囲まで）

## Canonical base 参照ファイルパス

`C:\Projects\vtuber_ai\resource\avatar.png`（896×1344、無加工のまま保持）

## 背景除去済み人物ファイルパス

`C:\Projects\vtuber_ai\live2d_assets\naru_v1_extraction\naru_bg_removed_v1.png`

オープンソースの背景除去ツール（`rembg`、既存画素からの抽出のみ、新規生成なし）を適用。背景の樹木・葉は概ね良好に除去できた。

## 1. 肩の前景紅葉

**結論：服の補完が必要（YES）。**

古典的な画像修復（`cv2.inpaint`、周辺画素のぼかし合成のみで新規生成はしない手法）を試したが、結果は明らかに滲んだような質感になり、服の光沢・折り目を再現できなかった（`live2d_assets/naru_v1_extraction/`に検証結果あり、採用しない）。既存画素だけでは自然に成立しないと判断する。

- **服の補完が必要か**：**YES**
- **最小mask範囲**：`C:\Projects\vtuber_ai\live2d_assets\naru_v1_extraction\shoulder_leaf_mask.png`（葉の輪郭に沿った手動マスク、`resource/avatar.png`と同じ896×1344の座標系）
- 補完方針：マスク範囲内のみ、既存の服（黒っぽい艶のある生地、単純な折り目）の続きとして自然に繋がるよう最小限で補完する。服の色・素材・光の当たり方は隣接領域から踏襲する。新しいデザイン要素は追加しない。

## 2. 口

**結論：口パク用の編集範囲を確定済み。**

- **抽出済みcontext crop**（参照用、広め）：`(y0,y1,x0,x1) = (600,840,400,740)`
- **編集対象mask範囲**（最小、口内＋上下唇の可動に必要な範囲のみ）：`(y0,y1,x0,x1) = (680,780,480,650)`
- 現状のcanonical base閉口表情は変更しない。編集は口内・上下唇の開閉差分を新たに用意するためのみ。顎・鼻・頬・目には一切及ばない（座標範囲で機械的に保証される）。

## 3. 既存画素で抽出済みのv1パーツ一覧

| パーツ | 状態 |
|---|---|
| 人物全体（背景除去済み） | 抽出済み（`naru_bg_removed_v1.png`） |
| 手前側の目（前髪込み） | 座標特定済み: `(390,670,370,770)`（訂正後、両目を含む範囲） |
| 口（閉口、現状） | 座標特定済み: `(600,840,400,740)` |
| 首・肩の可視部分 | 抽出済み（背景除去の一部として） |

## 4. 生成／補完を行ってはいけない領域

- 顔貌・輪郭・鼻・頬・顎（口の編集mask範囲外は一切触れない）
- 目・眉（今回のv1パケットに含まれない）
- 髪の形・色・量感
- 服の色・素材・デザインそのもの（肩の欠損補完は「同じ服の続き」であり新デザインではない）
- 元絵 `resource/avatar.png` 自体（無加工のまま保持）

## 5. Ready状態

**`IMAGE_EDIT_PACKET_READY`**

上記2件（肩の服補完・口の開閉差分）を、指定したmask範囲・制約のもとで次工程（画像補完）へ渡せる状態。

## Owner burden rule

ケイへ素材確認・ツール操作・差分比較を戻さない。
