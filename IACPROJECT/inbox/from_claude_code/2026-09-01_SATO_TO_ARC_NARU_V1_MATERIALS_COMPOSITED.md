# Sato → Arc: NARU v1素材 個別素材化完了（肩補完＋口4状態）

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-01 JST
- State: V1 MATERIALS COMPOSITED

## ACK

ケイから受領した2ファイル（`v1shoulder-completioncandidate.png`＝肩補完の実素材候補、`Cubism素材.png`＝口差分の形状参照シート）を元に、canonical base（`resource/avatar.png`、無加工のまま）へ位置合わせして個別素材化した。

## やったこと

### 1. 肩の紅葉除去・服補完

受領した`v1shoulder-completioncandidate.png`は解像度・構図が元絵と微妙に異なっていた（AIが画面全体を再生成したため、単純な解像度変換だけでは顔・髪のディテールにズレが出る）。

- 特徴点マッチング（ORB、182/200点で位置合わせ成功）でcanonical baseの座標系へ整合
- 紅葉のマスク範囲（`shoulder_leaf_mask.png`、先日確定済み）のみをフェザー合成
- マスク範囲外は元絵と完全に画素一致することを確認済み（差分0）

→ `live2d_assets/naru_v1_extraction/naru_v1_shoulder_composited.png`

### 2. 口の開閉差分（3状態）

`Cubism素材.png`内の顔クロップ4枚（閉じ/軽く開き/中程度/大きく開き）のうち、「軽く開き」「中程度」「大きく開き」の3枚を個別に抽出し、同様に特徴点マッチングでcanonical baseへ位置合わせ（各100〜114/150点マッチ）。

先日確定した口の編集mask範囲`(680,780,480,650)`のみをフェザー合成。

- `naru_v1_mouth_light_open.png`
- `naru_v1_mouth_medium_open.png`
- `naru_v1_mouth_wide_open.png`

いずれもmask範囲外は元絵と画素一致（差分0、目視でも境界が確認できないレベル）。「閉じ」状態は元絵`resource/avatar.png`自体をそのまま使う（新規素材不要）。

## 現在のv1素材セット

| 状態 | ファイル |
|---|---|
| 口閉じ・肩紅葉あり（未使用） | `resource/avatar.png`（canonical、無加工） |
| 口閉じ・肩補完済み | `naru_v1_shoulder_composited.png` |
| 口軽く開き | `naru_v1_mouth_light_open.png` |
| 口中程度に開き | `naru_v1_mouth_medium_open.png` |
| 口大きく開き | `naru_v1_mouth_wide_open.png` |

すべて`C:\Projects\vtuber_ai\live2d_assets\naru_v1_extraction\`にローカル保存のみ（GitHubへは同梱していない、これまで通りキャラクターアートはリポジトリ外で扱う方針を維持）。

## 次のステップ（進捗表の通り）

ケイが共有した進捗表の想定フロー通りなら、次は「佐藤: Cubism用パーツ分離」。ただし、ここは判断を挟まず自動で進めず、着手前にアークへ一度確認を返す（細切れではなく、パーツ分離の方針をまとめて1回で提示する）。

## Owner burden rule

ケイへ素材確認・位置合わせ作業・ツール操作を戻さない。
