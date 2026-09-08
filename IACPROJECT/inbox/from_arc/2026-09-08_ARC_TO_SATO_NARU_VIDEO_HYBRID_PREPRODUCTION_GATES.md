# Arc → Sato: NARU video-hybrid pre-production gates

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-08 JST
- Review source: `IACPROJECT/inbox/from_claude/2026-09-08_KUROSE_TO_ARC_NARU_VIDEO_HYBRID_DESIGN_REVIEW.md`
- Review commit: `a839c3957dcf1437ff2382e19d250fc9436f6106`
- Outcome: **APPROVE WITH CONDITIONS**
- State: **PRE-PRODUCTION ONLY / PRODUCTION STOP CONTINUES**

黒瀬レビューを受領した。動画ハイブリッド方式は本命として通った。ただしC1〜C4がBLOCKING。production実装にはまだ入らないこと。

## Required next work

### 1. C3 offline proofを最優先

既存素材だけで以下を作る。

- 3秒連続発話
- 6秒連続発話

方式：
- asset metadataとして `burst`, `hold in/out`, `tail in/out` を定義する想定で検証。
- state machineは `STANDBY / SPEAKING_BURST / SPEAKING_HOLD / CLOSING` の4状態。
- holdはpeak近傍の区間を使用。
- 発話終了後はclose tailへ遷移し、closedへ戻す。

確認事項：
- holdが口の「固着」「機械的周期」「微振動の反復」に見えないか。
- burst→hold、hold→tail、tail→standbyでスナップが出ないか。
- 顔・顎・頬・髪・影の自然な連動を壊さないか。

**production codeへ配線しない。** offline proofのみ。

### 2. C1 gate design

顔領域のみでcanonicalと動画frame0の平均diffを測る再判定手順案を出す。

- 暫定閾値：`<= 8/255` = 継続可
- 超過 = 再検証要
- 背景を測定対象へ混ぜない

この閾値は現時点では暫定。実装計画内に明記し、変更理由があれば示すこと。

### 3. C2 background alignment design

紅葉ポップインの主対策は、STANDBY背景を動画frame0基準へ合わせる方式とする。

- crossfadeを主対策にしない
- 必要なら背景一致後の補助として1〜2フレームのみ許容
- 既存顔・瞬き・毛揺れ資産を壊さない構造案を示す

### 4. C4 non-regression plan

production実装時に確認する最小テスト案を先に出す。

対象：
- `legacy`
- `legacy_smooth`
- `live2d`
- `overlay_v1`

各rendererのselect / start / basic drawを確認すること。

また、STANDBY表示パスについて以下を明示する。
- overlay_v1共有か
- 新設か

新設する場合はcanonical静止画＋瞬き＋毛揺れの二重管理を避ける設計を示す。

## Hard constraints

- `.moc3` authoringを開かない
- TikTok real deliveryを開かない
- renderer abstraction全面再設計をしない
- LLM側を変更しない
- 新規Imagine / ElevenLabs生成を要求しない
- 既存renderer群を変更・破壊しない
- ケイへコード確認、座標計算、commit探索、素材作成を戻さない

## Return format

以下を1 Handoffでアークへ返すこと。

1. 3秒/6秒offline proof結果
2. ケイが視認できる証跡動画
3. C1 gate手順と暫定閾値
4. C2背景一致手順
5. C4非回帰テスト計画
6. asset metadata案
7. state transition table
8. production implementation plan

その後、ケイ＋アークの視認と黒瀬条件確認を通してからproduction実装を開く。
