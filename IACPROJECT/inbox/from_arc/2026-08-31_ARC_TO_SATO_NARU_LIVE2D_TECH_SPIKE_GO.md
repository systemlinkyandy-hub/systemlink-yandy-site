# Handoff: NARU Live2D Technical Spike — GO / Publication Gate Separate

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-08-31 JST
- State: TECHNICAL SPIKE AUTHORIZED / PUBLIC RELEASE NOT YET AUTHORIZED

## Decision

ケイから、Live2D SDK / Cubism Core の非公開技術検証としての導入を進めてよい旨のGOを受領した。

ただし、以下を分離する。

1. **Technical spike / development**
   - SDK / Coreを正式な利用規約に同意した上で導入してよい
   - Live2D renderer adapterを実動作させる
   - Phase C0で定義したfailure isolationを維持し、rendererを故意に壊す障害注入テストを必ず行う
   - legacy rendererへの即時ロールバックを維持する

2. **Public release / continuous TikTok LIVE operation**
   - まだ正式採用・公開運用許可とは扱わない
   - Live2D公式のSDK Release License / AI・chatbot / Expandable Application区分を公開前に再確認する
   - 開発記録・短い技術デモ投稿まで一律禁止とは扱わないが、SDK組込みアプリを正式リリース／継続運用する段階ではライセンスゲートを通す

## Important clarification

昨日公開候補として扱っている旧NARUは、6枚画像切替のlegacy rendererでありLive2D SDKを使用していない。したがって今回のLive2D SDKライセンス論点とは別である。

## Required next action

- 先にローカルcommit `d503281` をpushしてよい
- その後、Live2D SDK / Cubism Coreを公式ルート・正式利用規約に従って技術検証環境へ導入
- ライセンス不明な第三者モデルassetは取得しない
- 公式または利用条件が明確なサンプルassetのみでrenderer実動作確認
- failure injection / legacy fallback / LLM-TTS-queue非回帰を検証
- 結果をレビューartifactとしてGitHubへ提出
- 黒瀬レビュー後に正式採用判断へ進む

## Owner burden rule

ケイへインストール手順探索、SDK差分確認、ACK回収、ライセンス文面の再編集を戻さない。ケイ本人に必要な同意画面が発生した場合のみ、その1回の操作へ圧縮して案内する。
