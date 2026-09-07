# Handoff — NARU owner visual fix + Mini Pavilion milestone

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Date: 2026-09-07 JST
- Priority: HIGH
- State: OWNER VISUAL ISSUE FOUND / FIX REQUIRED BEFORE CLOSE
- Project: NARU / IACProject

## 1. Owner visual confirmation result

ケイが実画面を確認し、`overlay_v1` の発話時口元について以下3点を明確に指摘した。

1. 発話時の口元だけ色が周囲と異なって見える
2. 口パーツの座標が少しずれている
3. 口を描く線にシャープさがなく、輪郭が甘い

したがって owner visual confirmation は現時点で **NOT CLOSED / VISUAL POLISH REQUIRED** とする。

技術ゲート（speaking path / production speak / multi-speak / mouth+blink concurrency）は再オープンしない。今回の対象は口元の視覚品質のみ。

## 2. Existing implementation context

現行 `overlay_v1` は crop + feather 合成。

`NaruOverlayEngine` では:
- `MOUTH_CROP = (640, 820, 440, 690)`
- closed / light / medium / wide の4状態
- `_blend_mouth_crop()` で状態間を `cv2.addWeighted()` クロスフェード
- `_mouth_mask = _build_feather_mask(MOUTH_CROP)`
- feather mask は楕円 + `GaussianBlur((35,35), 0)`

この構造上、今回の指摘は少なくとも以下の観点を優先確認すること。

### A. 色差
- BASE と各 mouth state 素材の色調/輝度/ガンマ差
- closed state が `resource/avatar.png`、他3状態が extraction素材であることによる素材系列差
- クロスフェード時の色混合で口周辺だけ明度・彩度が浮いていないか

### B. 座標ずれ
- 4 mouth state の同一 landmark に対する alignment
- `MOUTH_CROP` の位置・サイズ
- 各状態画像そのものの口中心位置差
- cropを丸ごと合成しているため、口以外の周辺画素差が位置ずれとして見えていないか

### C. 線のシャープさ
- 35px Gaussian feather が口線まで侵食していないか
- state間クロスフェードで線画が二重化/平均化され、輪郭が鈍っていないか
- 必要以上に広い `MOUTH_CROP` と楕円maskが、口周辺の輪郭をぼかしていないか

## 3. Required fix strategy

大改修は禁止。`overlay_v1` のまま最小差分で修正する。

優先順位:
1. mouth state素材の基準座標を揃える
2. BASEとの色差をmouth crop単位で抑える
3. feather範囲を口周辺の必要最小限へ縮める
4. 線画が二重化しないよう、必要ならクロスフェード方式/マスクを局所調整する

`voice_analyzer.py`、TTS、LLM、queue、TikTok ingest、安全系、blink、hair swayは触らない。

## 4. Acceptance criteria

既存ローカル音声のみで確認。ElevenLabs新規生成不要。

ケイの目視で以下を満たすこと。

- 発話中、口元だけ色が浮かない
- closed → light → medium → wide で口中心が跳ねない
- 口線が静止画と同程度にシャープに見える
- 発話後に正しいclosedへ戻る
- blink / hair sway / speaking pathに回帰なし
- 数回発話しても累積破損なし

修正後、短い画面録画または連続フレーム evidence を出し、黒瀬へ独立レビュー可能な形にする。

## 5. Next milestone — Mini Pavilion

ケイは **来週までにミニパビリオン的なデモ**を行いたい。

第一目標は、カードゲーム主要3人:
- アーク
- ゆいまーる
- 田中

がそれぞれ話せる状態。

ただし今この修正と同時に3人対応を混ぜない。

順序:
1. NARU owner visual polish CLOSE
2. 現行 `speak()` / Renderer abstraction を壊さず、character/profile切替の最小設計
3. 3人分の表示・音声ルーティングをMVP化
4. Mini Pavilion用に、3人が順番に話せるデモを成立させる

3D、TikTok実配信、`.moc3` authoring、renderer redesignは今回のミニパビリオン条件に含めない。

## 6. Owner burden rule

ケイへ以下を戻さない。
- コード確認
- 座標値の手計測
- commit探索
- Handoff配送
- テストログ採取
- 次担当判断

必要な視覚判断だけ、最終確認としてケイへ返す。

## Required next action

まず口元3点（色差 / 座標 / シャープさ）を修正し、差分・原因・evidence・commitをアークへ返すこと。
