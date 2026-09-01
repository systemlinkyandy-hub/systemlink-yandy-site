# Arc → Sato: NARU Live2D canonical base = original artwork

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-01 JST
- State: CANONICAL BASE DIRECTION FIXED / ASSET-FIRST

## User decision

ケイより、NARUのLive2D化について以下を承認。

- 新規に「似たベース画」を描き直す方式は採らない。
- 既存のオリジナルNARUイラストそのものを、Live2Dのcanonical base / rest poseとして扱う。
- 元絵の3/4姿勢・視線・口元・身構え方・髪の落ち方・表情の微細な緊張感をキャラクター要件として保持する。
- 以後は元絵の再生成ではなく、asset extraction + hidden-area extensionで進める。

## Why

このNARUは、単なる外見一致ではなく、微細な表情・視線・姿勢にキャラクター内面が強く入っている。

したがって、別のイラストとして再生成してからLive2D化すると、人物同一性だけでなく情動表現が失われるリスクが高い。

今回までの生成試行で、一般的な美麗キャラクター絵・設定画方向への正規化が強く、元絵固有の描画文法・表情が上書きされることも確認済み。

## Canonical asset policy

1. **Original artwork is immutable reference**
   - 元絵そのものは加工上書きしない。
   - 作業用コピーを用いる。
   - 元絵をNARUのvisual canonical referenceとして保持する。

2. **Rest pose remains 3/4 / guarded posture**
   - 正面化を前提条件にしない。
   - 現在の非対称・身構えた姿勢を基本ポーズとして許容する。
   - Cubism側の可動域は、このrest poseから必要な範囲だけ追加する。

3. **Asset extraction first**
   - 作業コピーから、前髪 / 横髪 / 後髪 / 顔 / 眉 / 目 / 瞳 / 口 / 首 / 服等を分離候補として整理する。
   - 既存画素を可能な限り保持する。
   - 不要な再描画・再解釈をしない。

4. **Hidden-area extension only where required**
   - 前髪の下の額・眉・目
   - 視線移動に必要な白目
   - 口開閉に必要な口内・上下唇
   - 髪揺れ・小角度回転で露出するこめかみ・耳・後頭部
   - 首・衣服の重なりの裏側
   を、必要箇所だけ補完する。

5. **Image generation is a repair/extension tool, not lead artist**
   - 新規キャラクターシート生成を主工程にしない。
   - 元絵の顔・表情・描画文法を置き換える生成は禁止。
   - 補完箇所ごとに、元画像をアンカーとして局所編集する。

## Visual acceptance requirement

最重要要件は「NARU本人に見える」ではなく、**元絵にある微細な表情・視線・距離感が保持されていること**。

特に保持対象:
- 相手へ100%正対しない視線
- ほんの少し身構えた緊張
- 口元が感情を確定させないこと
- 怒りではないが、対人迎合もほぼないこと
- 細身だが弱々しくしないこと
- 元絵固有の髪の束・光・エッジ密度・低彩度の暖色感

## Stop condition

以下が起きたら、その工程は止める。
- 一般的なアニメ美青年・VTuber設定画へ寄る
- 顔つきが健康的 / 弱々しい / 冷酷キャラ等の別記号へ再解釈される
- 目・口元・姿勢の微細情報が平板化される
- 元絵を再現するために大量の新規生成ガチャへ戻る

## Required next action

佐藤は次に、**このcanonical base方針に基づくLive2D asset decomposition plan**を作成する。

最低限返すもの:
- 分離対象パーツ一覧
- 既存画素で切り出せるもの / 補完が必要なもの
- hidden-area extension優先順位
- 最小可動域で必要なPSD/Cubism構成
- 画像補完が必要な箇所を一回に集約したリスト

実装・補完・再レビューの細切れ質問をケイへ戻さない。

## Boundary

- Arc does not decide final Live2D adoption or artistic canon beyond this user-approved base policy.
- 佐藤は元絵の再設計・別人化を独断で行わない。
- 黒瀬は独立レビューで「元絵の情動・距離感の保持」を確認する。
- 欠月へ返すのは、正式採用・正本判断が必要になった段階のみ。
