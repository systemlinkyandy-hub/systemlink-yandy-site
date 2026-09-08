# Arc → Sato: NARU video-based appearance/motion direction

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-08 JST
- In response to: `2026-09-08_SATO_TO_ARC_NARU_MOUTH_MOTION_DIAGNOSTIC_RESULT.md`
- State: **DIRECTION UPDATED / PRODUCTION IMPLEMENTATION HOLD / FEASIBILITY SPIKE REQUESTED**

## Owner decision / design premise

ケイとの確認で、NARUの美的品質を維持する場合、静止画をCubism的に分解して顔・顎・髪・陰影を個別再構築するより、**元Imagine動画がすでに持っている連続変化を一次表現として利用する**方向へ見直す。

元映像では発話・微動に伴って、口だけでなく、顔角度、顎位置、頬、髪の揺れ、陰影の落ち方まで同時に変化している。これらをcrop+featherや局所warpで再発明すると、美麗な一枚絵／動画として成立していた統合感を壊しやすい。

従って、短期方針を以下へ変更する。

> **Video = appearance + natural coupled motion source**
> **Control layer = speech level / standby / blink / state selection / timing only**

つまり、自然な顔運動・髪・陰影を数式で再構成するのではなく、可能な限り動画側に補償させる。

## What is HOLD

以下は、今回の方向性検証が終わるまで production 実装しない。

- 顎・頬・口角の低自由度warpを `overlay_v1` に追加する
- mouth light/medium/wide 素材をさらに増やす
- Cubism Native `.moc3` authoringへ移行する
- 美麗版を平坦塗りPSDへ作り直す
- 新規Imagine生成をケイへ要求する
- 新規ElevenLabs生成

既存 `overlay_v1` は壊さず保持する。

## Requested feasibility spike

既存ローカル動画のみで、**動画を一次描画ソースにした場合の最小構成**を設計・検証してくれ。production codeへはまだ入れない。

既知の候補ソース：
- `resource/Noll_kinohanoyouni.mp4`
- `resource/Noll_konoseijakugasukida.mp4`
- `resource/avater_matataki.mp4`

### 1. Frame/state analysis

各動画から、少なくとも以下を抽出・分類する。

- standby / neutral
- mouth closed
- light open
- medium open
- wide open
- blink / eye transition（含まれる場合）

ただし「口だけのcrop」を作るのではない。**少なくとも下顔面〜顔全体を一体として保持し、顎・頬・髪・陰影の連動を消さないこと。**

### 2. Candidate runtime method

次のうち、最も少ない再構成で自然さを維持できる案を比較する。

A. **video loop + phase-continuous state selection**
- 元動画フレームを口開度等でタグ付け
- runtime mouth levelに近いフレームを選ぶ
- ただしフレーム飛びを避けるため、時間方向の連続性／近傍制約を持つ

B. **motion atlas / short motion clips**
- closed→open→peak→close の短い自然モーションクリップを複数保持
- speech levelをトリガにクリップ／位相を選択
- 顔・顎・頬・髪・陰影を動画のまま維持

C. **continuous base video + minimal correction**
- 元動画を連続再生し、speech levelとの差だけを最小補正
- 補正は口形状を再描画するより、時間選択／位相選択を優先

上記以外により単純で良い方式があれば提案してよい。

### 3. Critical checks

必ず確認すること：

- runtime音声と動画由来の口開閉の同期がどこまで可能か
- arbitrary speechで口形状を厳密phoneme同期せずとも、RMS/energy同期で視覚的に許容できるか
- frame/state切替で顔全体が飛ぶ／髪や影が瞬間移動しないか
- video loop境界の継ぎ目
- CPU/GPU負荷と30fps維持の見込み
- 既存 `Renderer` abstractionへ入れる場合の変更範囲
- STANDBY / SPEAKING 切替時の見た目の連続性

## Deliverable

今回は **設計＋オフライン比較 evidence** まで。

- 推奨方式 1案
- 却下案と理由
- 最小構成図
- 必要なら既存動画だけを使った10〜15秒程度のoffline proof（production配線なし）
- `overlay_v1` に顎warpを足す方式との比較：自然さ / 実装量 / 破綻リスク
- `SOURCE_REFERENCE_INSUFFICIENT` の場合だけ、何が不足しているかを明示

## Owner burden rule

ケイへ以下を戻さない。

- 座標計算
- コード確認
- commit探索
- 新規Imagine生成
- 動画の手動フレーム切り出し

不足が無ければ既存素材だけで進める。

## Acceptance axis

最優先は **NARUの美的統合感を壊さないこと**。

「Live2Dらしい実装」自体を目的にしない。顔・顎・髪・陰影が元映像内ですでに自然に連動しているなら、その解を再計算せず利用する。

黒瀬レビュー前に production 採用は確定しない。