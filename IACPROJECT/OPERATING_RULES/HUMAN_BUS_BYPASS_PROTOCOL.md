# HUMAN_BUS_BYPASS_PROTOCOL

**Owner**: アーク
**Purpose**: ケイをAI間の伝令・再編集・進捗監視の通信バスにしないための固定配送規約。
**Status**: ACTIVE

## Core rule

AI間の受け渡しは、原則として GitHub 上の Handoff 原本と `IACPROJECT/ROUTER/CURRENT_DELIVERIES.md` で管理する。
ケイは本文の再編集・再説明・複数AIへの個別再送を担当しない。

## Delivery states

- REGISTERED: Handoff原本がGitHubへ登録済み
- ROUTED: `CURRENT_DELIVERIES.md` に宛先・原本パス・次アクションが登録済み
- DELIVERED: 宛先AIが取得可能な状態で起床通知済み、またはそのAI自身が取得したことを確認済み
- ACKNOWLEDGED: 宛先AIの返答・ACKが原本として登録済み
- CLOSED: 後続処理が完了し配送項目を閉じた

## Standard route for GitHub Pull-capable AIs

1. アークがHandoff原本をREGISTEREDする。
2. アークが `IACPROJECT/ROUTER/CURRENT_DELIVERIES.md` に配送項目を追加する。
3. アークが `IACPROJECT/CURRENT_PENDING.md` を更新する。
4. 起床が必要な場合、ケイには「誰を起こすか」と最新コミット番号だけを伝える。
5. 起床したAIは `CURRENT_PENDING.md` → `CURRENT_DELIVERIES.md` → 指定原本の順で読む。
6. 返答は各AIの所定 inbox/Handoff に残し、アークが ACKNOWLEDGED/CLOSED を更新する。

## Gemini exception

GeminiはGitHub Pullを前提にしない。
Geminiが必要な時だけ、アークが関連原本・該当pending・欲しい回答形式を1つのPacketにまとめる。
ケイの操作は、そのPacketをGeminiへ1回渡すことだけとする。
Geminiの返答は全文をそのままアークへ戻し、アークがGitHub登録・後続配送を行う。

## Prohibited operations

- ケイにAIごとの本文再編集を求めること
- ケイに同一素材を複数AIへ個別再送させること
- ケイにACK一覧や未処理一覧を手作業で管理させること
- REGISTEREDのみでDELIVERED扱いにすること
- 不明な欠落をケイへ丸投げする前に、GitHub原本・CURRENT_PENDING・CURRENT_DELIVERIESを確認しないこと

## Escalation

外部AIレビューが必要になった場合、アークが対象・理由・完成Handoff/Packet・最新コミット番号を一度に提示する。
採否・研究・仕様判断は該当正本判断者へ返し、回答AIに決定権を移さない。
