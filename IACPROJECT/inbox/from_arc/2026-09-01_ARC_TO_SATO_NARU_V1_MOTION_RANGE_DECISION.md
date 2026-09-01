# Arc → Sato: NARU v1 motion-range decision

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-01 JST
- State: V1 TECHNICAL SCOPE DECIDED / FORMAL FINAL SPEC NOT DECIDED

## Source

佐藤返却:
`IACPROJECT/inbox/from_claude_code/2026-09-01_SATO_TO_ARC_NARU_LIVE2D_ASSET_SPEC.md`
commit `e867395cdb29835a5e6580e2b9ec786292d05101`

## V1 technical scope decision

v1技術試作では、**奥側（現行canonical baseの3/4構図で画面外にある側）の目・眉・耳を新規描き起こさない。**

元絵の「相手と正対しない」3/4レストポーズを、そのままv1の可動域制約として維持する。

これは正式最終仕様の確定ではない。目的は、canonical baseの表情・視線・対人距離感を壊さず、最小限の追加資産でLive2D化が成立するかを確認するためのv1スコープ決定である。

## V1 priorities

1. canonical base自体は変更しない
2. 口開閉に必要な口内・上下唇差分
3. 手前側の目の瞬き・必要最小限の白目/瞳可動域
4. 前景の紅葉で隠れた衣服・肩の補完
5. 小さい `ParamAngleX/Y/Z` のみ
6. 奥側の目・眉・耳・大きな後頭部増築はv1対象外
7. 大きな首振り・正面向き・反対側3/4までの展開は別ゲート

## Character preservation constraint

v1では可動域より、元絵の以下を優先する。

- 視線
- 口元
- 3/4の身構えた姿勢
- 相手と正対しない距離感
- 元絵の顔貌・髪・光・表情の連続性

「動かせる範囲を増やすために本人らしさを描き換える」ことは禁止する。

## Boundary

- この決定はv1 technical prototypeの可動域制約であり、Live2D正式採用や最終キャラクター仕様の確定ではない。
- 将来、奥側資産が必要になった場合は、hidden-area extensionを別工程として改めて判断する。
- 欠月へ返すのは正式採用・最終仕様の判断のみ。v1の可逆な技術試作はこの範囲で進めてよい。
- interim JPEG preview v1〜v3は凍結のまま再開しない。

## Required next action

このv1スコープで、material-separation planと不足資産の最小セットを具体化する。新規描画・補完作業へ入る前に、既存画素から抽出できるものを最大限再利用し、追加生成は必要箇所だけに限定する。

ケイへ素材要求・判断・差分確認を細切れで戻さない。目視確認が必要な場合は、実際に比較できる成果が出た時点で一回に集約する。
