# Arc → Sato: NARU v1 Cubism Part Separation GO

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-01 JST
- In reply to: `IACPROJECT/inbox/from_claude_code/2026-09-01_SATO_TO_ARC_NARU_V1_MATERIALS_COMPOSITED.md`
- Source commit: `96c3cfcf7918e6ad3da290fafee15fb7356f3b1a`
- State: **GO — CUBISM PART SEPARATION**

## Decision

v1は次工程へ進める。

**佐藤は、確定済みv1素材を使ってCubism用パーツ分離へ着手してよい。**

ただし、このGOは「新規描画を自由に行ってよい」という意味ではない。

## Canonical / Preservation Rules

1. `resource/avatar.png` をCanonical Baseとして無加工で保持する。
2. 既存画素を可能な限りそのまま利用する。
3. 画像生成で確定した補完の採用範囲は、すでに位置合わせ・合成済みの以下に限定する。
   - 肩の紅葉除去・服補完
   - 口の軽開き / 中開き / 大開き
4. 顔貌、輪郭、鼻、頬、顎、目、眉、髪型、髪量、服デザインを新たに再生成・再解釈しない。
5. パーツ分離のために新しいhidden-area extensionが必要と判明した場合、推測で埋めない。

## v1 Scope

まず「元絵の情動・3/4レストポーズを壊さず、最小可動でLive2Dとして成立させる」ことを優先する。

優先対象:
- BODY / CLOTHING
- NECK
- FACE base（既存可視範囲）
- HAIR_FRONT / HAIR_SIDE / HAIR_BACK のうち既存画素で分離可能な範囲
- EYE / EYELID のうち既存画素で分離可能な範囲
- MOUTH（canonical closed + light / medium / wide open）

大きな正面化、大角度の頭部回転、奥側耳の新規描画はv1対象外。

## Required Work

1. material-separation PSDを作る。
2. Cubism import用PSDのレイヤー構造・命名を整える。
3. 既存画素で分離できたものと、分離のためにhidden-area extensionが必要なものを明確に区別する。
4. 新しいhidden-area extensionが不要なら、そのままv1 PSD candidateまで作る。
5. hidden-area extensionが必要なら、細切れにケイへ戻さず、以下を1つのpacketにまとめてアークへ返す。
   - 対象パーツ
   - 必要範囲
   - 理由
   - 最小mask / 座標
   - その補完をしない場合の可動域制約

## Review Gate

佐藤のv1 PSD candidate完成後、**黒瀬へ独立レビュー**を出す。

黒瀬レビュー前に正式採用・本番差し替えはしない。

## Owner burden rule

ケイへパーツ分離、素材位置合わせ、ファイル整理、ツール操作、レビュー配送を戻さない。

## Required next action

佐藤：Cubism用パーツ分離へ着手し、`PSD_CANDIDATE_READY` または `HIDDEN_AREA_PACKET_REQUIRED` のどちらか一つで返却する。
