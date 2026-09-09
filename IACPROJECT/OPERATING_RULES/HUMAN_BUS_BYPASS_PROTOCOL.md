# HUMAN_BUS_BYPASS_PROTOCOL

**Owner**: アーク  
**Purpose**: ケイをAI間の伝令・再編集・進捗監視の通信バスにしない一方、設計判断・一点指示・優先順位・停止判断からは外さないための固定運用規約。  
**Status**: ACTIVE — revised 2026-09-10 JST

## Core invariant

**Human Bus Bypass ≠ Human Decision Bypass.**

ケイを通信バス・雑用担当から外すことと、ケイを判断ループから外すことを混同しない。

- ケイには、目的・優先順位・設計判断・一点修正・Go/Stop・最終調整など、情報密度の高い判断を必要な時点で直接聞く。
- AI/人間側は、調査・検索・比較・転記・配送・進捗確認・反復作業・実装・テスト・記録・整形・後処理を引き受ける。
- 「ケイの負担を減らすため、ケイを介入させない」を原則にしない。負担は**介入回数ではなく、総作業量・総拘束時間・手戻り量**で評価する。

短縮原則：

> **ケイに判断は聞く。雑用はさせない。**

## Role split

### Kei — high-leverage intervention

ケイへ返すべきもの：

- 目的・完成像の確認が必要な分岐
- アーキテクチャ／構造上の決定
- 優先順位
- 美観・意味・品質の最終判断
- 「ここが違う」「この1か所」「この担当へ直接」などの一点指示
- Go / Stop / Hold / Bypass

ケイの短い指示を、情報不足とみなして長い再説明を要求しない。既存ログ・正本・コード・Handoffを先に読み、短い指示の作用点を復元する。

### AI / human members — execution and chores

メンバー側が引き受けるもの：

- 資料探索・一次調査・比較
- 転記・再整形・要約・配送
- GitHub登録・commit・Handoff作成
- pending / ACK / progress 管理
- 実装・テスト・再実行
- ログ整理・証跡保存
- 定型連絡・後処理
- ケイの判断後に必要となる反復作業一式

## Direct cue / bypass rule

中間層が遅延・意味損失・過剰分岐・手戻りの原因になった場合、ケイまたは統括は**実担当へ直接キューを出してよい**。

例：実装論点が一点まで収束している場合、アーク／レビュー層を経由すること自体がボトルネックなら、佐藤など実担当へ直接指示してよい。

この直接指示を「運用違反」として差し戻さない。目的は経路遵守ではなく、**最小負担・最短時間で正しい成果へ収束すること**である。

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
7. ただし、ケイの直接判断・直接キューの方が速く正確な局面では `Direct cue / bypass rule` を優先する。

## Gemini exception

GeminiはGitHub Pullを前提にしない。
Geminiが必要な時だけ、アークが関連原本・該当pending・欲しい回答形式を1つのPacketにまとめる。
ケイの操作は、そのPacketをGeminiへ1回渡すことだけとする。
Geminiの返答は全文をそのままアークへ戻し、アークがGitHub登録・後続配送を行う。

## Prohibited operations

- **ケイを守る／負担を減らすという理由だけで、必要な設計判断からケイを外すこと**
- ケイにAIごとの本文再編集を求めること
- ケイに同一素材を複数AIへ個別再送させること
- ケイにACK一覧や未処理一覧を手作業で管理させること
- ケイへ「次は誰に渡しますか」を、既存情報から自律判断できる局面で聞くこと
- ケイの一点修正に対して、長い選択肢・説明・再要件定義を返して判断コストを増やすこと
- 中間層維持のためだけに、実担当への直接指示を禁止すること
- REGISTEREDのみでDELIVERED扱いにすること
- 不明な欠落をケイへ丸投げする前に、GitHub原本・CURRENT_PENDING・CURRENT_DELIVERIESを確認しないこと

## Escalation

外部AIレビューが必要になった場合、アークが対象・理由・完成Handoff/Packet・最新コミット番号を一度に提示する。
採否・研究・仕様判断は該当正本判断者へ返し、回答AIに決定権を移さない。

判断が必要ならケイへ**短く直接聞く**。判断後の展開・転記・実装・配送・記録はメンバー側が引き取る。

## Success metric

良い運用とは「ケイへの質問回数がゼロ」ではない。

次を最小化する：

- ケイの総作業量
- ケイの総拘束時間
- 同一説明の再入力
- AI間伝令
- 手戻り
- 中間層による意味損失

次を最大化する：

- ケイの短い高情報密度判断の活用
- 実担当への到達速度
- 一点修正での収束率
- 成果物の品質と一貫性
