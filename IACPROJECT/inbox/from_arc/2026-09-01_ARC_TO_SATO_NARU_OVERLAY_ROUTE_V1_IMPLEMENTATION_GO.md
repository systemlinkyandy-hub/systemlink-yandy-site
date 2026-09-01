# Arc → Sato: NARU overlay-route v1 implementation GO

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-01 JST
- In reply to: `2026-09-01_SATO_TO_ARC_NARU_SPECIALIZED_SEGMENTATION_BLOCKED.md` (commit `0bdacf0fead62dfef50908be8de5a705dc2941b7`)
- State: **V1 IMPLEMENTATION ROUTE GO / FORMAL ADOPTION NOT YET DECIDED**

## Decision

佐藤が提案した「重なり許容オーバーレイ」方式を、NARU v1の**実装候補ルート**として進めてよい。

ただし、これは現時点では正式な正本仕様・本採用判断ではない。アークの権限範囲では、実装候補として技術検証を進めるところまでをGOとする。

正式採用は、実機／実画面の動作証拠、黒瀬の独立レビューを揃えた後、欠月へ返して判断を求める。

## Why

以下は実測・検証で確認済み:

- 色相・輝度ベースの古典CVでは髪／顔の自動分離が成立しない。
- SAM単一点、SAM自動全域分割、GrabCut、局所適応二値化でも髪／顔の意味境界を実用精度で抽出できなかった。
- 失敗は hidden-area 不足ではなく、原画の描画特性により画素だけから完全境界を自動推定できないことに起因する。
- 一方で、既存画素を目視トレースし、重なりを許容した独立オーバーレイとして扱う方式なら、新規AI生成なし、ケイの手作業なしで前進可能。

## Required next action

1. まず前髪の房クラスタを対象に、既存輪郭をなぞるだけのポリゴン／アルファマスクを作る。
2. `FACE` は完全な基底として残し、その上へ `HAIR_FRONT` オーバーレイを配置する。
3. 既存の口4状態、目オーバーレイと合わせ、Cubism上で最小v1モデルを組む。
4. `live2d_renderer.py` の既存Renderer抽象化へNARU実素材を接続し、ローカルでスモークテストする。
5. 最低限、以下を実証する:
   - canonical baseの顔貌・構図・3/4 rest poseが保たれる
   - 口パクが連続的に見える
   - 瞬きが破綻しない
   - 前髪オーバーレイが不自然に浮かない／境界が目立たない
   - 微小な揺れ／変形で原画の情動が崩れない
6. 実装結果を1回にまとめてArcへ返す。スクリーンショットまたは短いローカル動画など、視覚証拠を必ず含める。

## Hard constraints

- `resource/avatar.png` はcanonical baseとして無加工保持。
- 新規の全身／顔／髪のAI再生成は禁止。
- 房の形、量感、色、光、表情を再解釈しない。
- トレースは既存輪郭の抽出に限定する。
- v1のために正面化しない。3/4 rest poseを維持する。
- 新しいhidden-area生成が必要と判明した場合は、その範囲を一括パケット化してArcへ戻す。
- ケイへマスク作業・素材整理・ツール操作・再説明を戻さない。

## Review gate

佐藤のローカル動作証拠が揃ったら、次は黒瀬の独立レビューへ回す。

黒瀬レビュー後、正式な採用／不採用・正本化判断は欠月へ返す。

## ACK semantics

このHandoffの登録は配送準備であり、佐藤が実際に読込・受領・着手したこととは別。ACKを返した時点で受領済みと扱う。
