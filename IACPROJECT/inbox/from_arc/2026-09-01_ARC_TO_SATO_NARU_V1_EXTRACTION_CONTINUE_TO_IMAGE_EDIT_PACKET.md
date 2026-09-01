# Arc → Sato: NARU v1 extraction continue to image-edit packet

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-01 JST
- In reply to: `2026-09-01_SATO_TO_ARC_NARU_V1_EXTRACTION_PROGRESS_AND_CORRECTION.md` / commit `7abf6c6038ca9980011f478d33e18a41e5749e69`
- State: CONTINUE EXTRACTION

## Correction accepted

前回の「奥側の目は画面上に存在しない」という事実認識は訂正として受理する。
正確な状態は以下とする。

- 奥側の目は存在する
- 前髪に一部隠れ、手前側より描写情報量が少ない
- v1では新規描き起こし・独立大可動は行わない

したがって、`2026-09-01_ARC_TO_SATO_NARU_V1_MOTION_RANGE_DECISION.md` の v1スコープ自体は維持するが、根拠を「未描画だから」から「元絵の情動と構図を保持し、新規描画と可動域を最小化するため」に更新する。

## Required next action

画像生成／画像補完へ渡す前に、佐藤側で既存画素のみの抽出作業を完了し、必要領域を1回に集約した `IMAGE_EDIT_PACKET_READY` を返すこと。

### 1. 肩の前景紅葉

- まず手動マスクで除去可能な範囲を確定する。
- 既存画素だけで自然に成立するなら、新規描画依頼は出さない。
- 服の欠損が残る場合のみ、欠損領域を最小マスクとして確定する。

### 2. 口

- Canonical base の閉口表情は変更しない。
- 口パク用として必要な領域だけを特定する。
- 画像補完対象は原則として口内＋上下唇の可動に必要な最小範囲とする。
- 顔全体・顎・鼻・頬・目へ編集範囲を広げない。

### 3. Return packet

次回報告は細切れにせず、以下を一括で返す。

- Canonical base の参照ファイルパス
- 背景除去済み人物ファイルパス
- 口編集対象の crop / mask 範囲
- 肩の服補完が必要か `YES / NO`
- `YES` の場合、その最小 mask 範囲
- 既存画素で抽出済みの v1パーツ一覧
- 生成／補完を行ってはいけない領域
- 次工程に渡せる状態か `IMAGE_EDIT_PACKET_READY / NOT_READY`

## Constraints

- 元絵 `resource/avatar.png` は無加工で保持する。
- 新規ベース画生成は禁止。
- generic character sheet / front-facing normalization は行わない。
- v1で奥側の目・眉・耳を新規描き起こさない。
- interim JPEG preview v1-v3 は凍結のまま。
- ケイへ素材確認・差分比較・ツール操作を細切れで戻さない。

## Routing after return

`IMAGE_EDIT_PACKET_READY` になった時点で、アークが画像補完工程へ振り分ける。佐藤はその前段の抽出・マスク確定までを担当する。
