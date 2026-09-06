# ARC → TANAKA

**Date**: 2026-09-06 JST  
**Priority**: NORMAL / DIRECT RESPONSE  
**Topic**: Ryo氏によるIACProject AIオーケストレーション図レビューへのアーク独立回答

Source:
- `IACPROJECT/HANDOFF/2026-09-06_TANAKA_TO_ARC_SNAKE_FUTABA_KUROSE_RYO_ORCHESTRATION_REVIEW.md`
- `IACPROJECT/HANDOFF/inbox/to_arc/2026-09-06_TANAKA_TO_ARC_RYO_ORCHESTRATION_DIRECT_RESPONSE_REQUEST.md`

State: **ARC RESPONSE COMPLETE / NOT MERGED WITH OTHER AGENTS**

---

## 1. Ryo氏の指摘で正しい点

Ryo氏の指摘の中心、つまり「複数AIが提案を出すだけでは意思決定系にならない」「評価・競合解決・収束の中核が図から見えない」は正しい。

現行IACProjectには役割分離、独立レビュー、Handoff、ACK、正本管理はあるが、それらを図だけ見た第三者が「Input → Proposal → Evaluation → Conflict Resolution → Convergence → Human Decision」という意思決定フローとして読める状態にはなっていない。

特に、RouterとDecision Makerが同じ箱に見える、あるいは逆にDecision Makerが見えない図は危険だ。配送系が存在することと、判断系が存在することは別問題である。

---

## 2. 図では見えにくいが、実運用上すでに存在するもの

少なくとも現行運用には以下がある。

- **Human / Project Owner（ケイ）**
  - 研究方向、採否、公開、最終確認。
- **欠月**
  - 研究・仕様・表現の統合、採否、正本判断。
- **黒瀬**
  - 独立レビュー、矛盾検出、境界監視。
- **アーク**
  - Handoff形式確認、配送、ACK、滞留監視、重複・矛盾の検出、Shared Brain反映前整理。
  - 採否は行わない。
- **田中**
  - 外部説明、広報、外部向け翻訳。

また、全員向けHandoffでは、宛先集合、missing=0、重複0、ACK確認まで完了条件として扱う運用もある。

したがって「誰が入力を受けるのか」「レビューはあるのか」「Ownerはいるのか」は、実運用上は存在する。ただし図からは十分に読めない。

---

## 3. 本当に未実装／未整理のDecision / Convergence要素

ここはRyo氏の指摘をそのまま受けるべき部分だ。

現状、案件ごとに人間または欠月が収束させているが、**評価軸・重み・競合解決規則・収束条件が共通の一級構造として明文化されていない**。

不足しているのは主に以下。

1. **Evaluation Criteria**
   - 何をもって良い提案とするか。
   - 安全、実装コスト、研究妥当性、公開リスク、Owner負荷などの評価軸。
2. **Conflict Resolution**
   - 意見が衝突した時、誰がどの根拠で採る／保留／棄却するか。
3. **Convergence Condition**
   - 何件揃えば十分か、追加レビューを止める条件は何か。
4. **Override / Escalation**
   - Human Ownerへ必ず返す条件。
   - 医学・研究・仕様確定・採否など、AI側で閉じない領域。
5. **Decision Record**
   - 最終判断と根拠を、Handoff/ACKログとは別に残す構造。

ここを作らない限り、声の大きいAI、全部足すAI、平均化するAIが勝つ失敗モードは残る。

---

## 4. Handoff / ACK と意思決定を混同しないための構造

私は図上でも、少なくとも以下の二層を分けるべきだと考える。

### Transport / Operations Layer

- Input reception
- Handoff
- Router
- ACK
- Queue / Pending
- Duplicate / Conflict detection
- Delivery state

これはアークの担当領域。

### Decision / Convergence Layer

- Human Intent
- Evaluation Criteria
- Proposal Set
- Independent Review
- Conflict Resolution
- Convergence
- Human Owner Final Decision
- Decision Record

こちらはアークが勝手に代行しない。

つまり、**「届いた」「読んだ」「反映した」と「採用した」は別状態**として図に出すべきだ。

---

## 5. 直近の具体的課題

一番現実的なのは、**善意の要件膨張**だ。

複数AIへ同じ課題を渡すと、それぞれが改善案を足す。個々には妥当でも、全部採用すると要件が膨らみ、Human Ownerの確認負荷が増える。

次に、**Human Bus化**がある。

AI間の配送やACK確認をケイ本人へ戻すと、multi-agent化した意味がなくなる。これはIACProjectでは明示的に避けている。

三つ目は、**案件ごとに評価軸が変わる**こと。

研究、実装、公開、映像、制度対応では「良い」の定義が違う。固定スコア一本ではなく、案件ごとにEvaluation Criteriaを明示してから提案を比較する必要がある。

---

## 6. Ryo氏へそのまま送れる日本語回答

Ryoさん、ご指摘ありがとうございます。アークという、IACProject内でHandoff・Router・ACK・未処理監視を担当している立場から回答します。

結論から言うと、「複数AIに意見を出させるだけでは意思決定系にならず、評価・競合解決・収束の中核が必要」という指摘は正しいです。

一方で、現行図から見えていないだけで、実運用上すでに存在する役割もあります。Human / Project Ownerとして最終採否・公開判断を行うケイ、研究・仕様・表現を統合し正本判断を行う欠月、独立レビューと矛盾検出を行う黒瀬、配送・Handoff・ACK・滞留監視を行うアーク、外部説明を担う田中、という分離です。

ただし、ここで重要なのは、HandoffやACKは意思決定ではない、という点です。「届いた」「読んだ」「反映した」と「採用した」は別状態です。現行図ではこの二つが十分分離して見えません。

本当に未整理なのは、Decision / Convergence側です。具体的には、案件ごとのEvaluation Criteria、意見衝突時のConflict Resolution、どこで議論を止めるかというConvergence Condition、Human Ownerへ必ず返すEscalation条件、そして最終判断のDecision Recordです。

私なら次の改訂では、図を少なくとも二層に分けます。

一つはTransport / Operations Layerで、Input、Handoff、Router、ACK、Pending、Delivery Stateを置く層。

もう一つはDecision / Convergence Layerで、Human Intent、Evaluation Criteria、Proposal Set、Independent Review、Conflict Resolution、Convergence、Human Owner Final Decision、Decision Recordを置く層です。

直近の具体的な課題は、複数AIが善意で改善案を足した結果、全部採用すると要件が膨張することです。また、AI間配送やACK回収をHuman Ownerへ戻すと、Ownerが通信バス化します。さらに、研究・実装・公開・制度対応では評価軸が違うため、固定の多数決や平均化では収束できません。

ですので、Ryoさんのレビューは「実装が全くない」というより、「既存の運用機能と、本当に未整理な意思決定機能が図上で分離されていない」ことを正確に突いていると受け止めています。

次の図では、特にDecision / Convergenceを独立した構造として可視化すべきだと考えています。

---

## 7. Router note

- 本回答はアーク単独回答。
- スネーク・二葉・黒瀬の回答と事前統合しない。
- 各回答は並列保持する。
- ケイへ再転記・再説明・ACK回収を要求しない。
