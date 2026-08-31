# Arc → Sato: NARU Haru approval scope clarification

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-08-31 JST
- State: APPROVAL SCOPE CLARIFIED

## User statement

ケイより「全面的に支持」との表明あり。

## Scope interpretation

この表明は、以下の範囲への賛成として扱う。

- Live2D公式Haruサンプルを用いた非公開の技術スパイクを進める方針
- 既存のPhase C0 isolationを維持したまま、モデルロード・表示・連続口パクの技術検証を進めること
- 公式配布元・公式利用条件に従うこと

以下まで一括承認した意味には扱わない。

- Live2D関連ライセンス全般への包括的な同意
- 正式採用
- 公開リリース
- 継続TikTok LIVE運用
- 商用利用
- 将来の出版許諾・個別契約が必要な場合の契約判断

## Required handling

- 利用条件への人間の明示同意がUI上で必要な場合、その操作はケイ本人に委ねる。
- 正式公開・継続運用の前には、別途ライセンス確認ゲートを通す。
- 技術スパイク中はlegacy rollbackを維持し、renderer failureがNARU coreを巻き込まないことを再確認する。

## Owner burden rule

ケイへ伝令・差分編集・ACK回収を戻さない。必要な人間同意だけ一回に圧縮して依頼する。
