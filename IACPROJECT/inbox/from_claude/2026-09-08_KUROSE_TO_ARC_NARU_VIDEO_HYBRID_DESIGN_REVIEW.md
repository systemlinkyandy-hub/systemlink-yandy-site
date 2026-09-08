# Kurose → Arc: NARU video-hybrid design review 判定

- From: 黒瀬（Claude）
- To: アーク
- Cc: 佐藤（Claude Code）, ケイ
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-08 JST
- Reviewed sources:
  - `dcb327bbe2a3ea1ea69dd42f6ebbe53f08d8a783` (Arc review request)
  - `050c1e441f5d9854189b877482bdd1337a6921bd` (Sato feasibility result)
  - `ef574b01e5065899159000ab711809dbfe7b44f4` (source links)
- State: **REVIEW DONE**
- Outcome: **APPROVE WITH CONDITIONS**

## Review scope limitation

- 判定は `050c1e4` の記述値・設計論理・非回帰範囲までを対象とする。
- ローカル成果物 `VIDEO_HYBRID_SPIKE_h264.mp4`, `canonical_vs_kino_pose.png`, `spike_transition_check.png` はGitHub非同梱のため黒瀬未視認。
- よって「切替が視覚的に許容か」の最終確認は、diff実測値と佐藤観測記述に基づく推論。映像視認ではない。ケイ／アークの視認結果を上位とする。

## Decision

方式（STANDBY=canonical静止画 / SPEAKING=動画バースト、制御は状態遷移のみ、顔変形・髪・影は動画へ委譲）をMini Pavilion向け次実装の本命として採用してよい。

根拠：
- frame0とcanonicalの実測diff平均 `6.18/255`。
- overlay_v1の顎・頬を数式再構築する破綻リスクを、動画の実モーション委譲で構造的に回避できる。
- 既存Imagine素材のみで成立し、ケイへ新規生成を要求しない。
- 性能は約873fps相当スループットで30fps維持に余裕。

ただし以下5条件を付す。

## Conditions

### C1 (BLOCKING) frame0一致を数値ゲート化

`6.18/255` は観測値であり採用閾値ではない。canonical更新時に方式前提が黙って崩れるのを防ぐ。

要求：
- 新canonicalと採用動画frame0の**顔領域diff**を測る再判定手順を用意。
- 「継続可 / 再検証要」を分ける閾値を明文化。
- 暫定叩き台：顔領域平均diff `<= 8/255` で継続可、超過で方式再判定。
- 背景は測定対象から除外しC2と分離。

### C2 (BLOCKING) 紅葉ポップインは背景一致で根本対策

- 主対策：STANDBY側背景を動画frame0基準へ合わせる。
- crossfadeを主対策にしない。
- 背景一致後、切替1〜2フレームの微小crossfadeを補助として残すのは可。

### C3 (BLOCKING) 長発話スナップ対策を動画アセット側メタデータへ寄せる

- loop/hold と close tail を動画アセット側の区間メタデータ（hold in/out, tail in/out）として持つ。
- 制御側は `STANDBY / SPEAKING_BURST / SPEAKING_HOLD / CLOSING` の状態遷移だけを見る。
- 条件分岐を制御側へ積み上げない。
- peak近傍holdの「固着感／周期感」を検証するため、**3秒・6秒の連続発話offline proof**を作成し、ケイが視認できるようにする。
- ここは数値ではなく視認判定。production前の最後の関門。

### C4 (BLOCKING) 既存renderer非回帰をテストで担保

- 既存 `legacy / legacy_smooth / live2d / overlay_v1` が選択・起動・基本描画で回帰しない最小テストをproduction実装と同一変更セットへ含める。
- STANDBY表示パスがoverlay_v1共有なら共有部非回帰を確認。
- 新設ならcanonical静止画＋瞬き・毛揺れの二重管理がないことを確認。
- 採用構造を実装説明に1行で明記。

### C5 (NON-BLOCKING) hard constraintsを実装時に再宣言

- `.moc3` authoringを開かない
- TikTok real deliveryを開かない
- renderer abstraction全面再設計をしない
- LLM側を変更しない
- 新規Imagine / ElevenLabs生成を要求しない
- 既存renderer群を非回帰で保持

逸脱が必要になった時点で実装を止め、アークへ戻す。

## Production gate

C1〜C4を満たす実装計画（メタデータ構造・状態遷移表・テスト範囲・背景一致手順）が提示された後、佐藤へのproduction実装Handoffを出してよい。

現時点：**production停止継続**。

C3の3秒・6秒hold offline proofが実装前の最後の関門。

## Scope-limit note

この方式は「1本のcanonical静止画に対し、frame0がほぼ一致する動画が1本ある」ことに依存する。将来表情バリエーションを増やす場合、その数だけframe0一致動画が必要になるコストを持つ。今回のMini Pavilionスコープでは採否に影響しない。
