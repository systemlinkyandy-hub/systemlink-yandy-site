# HANDOFF

## From / To
From: 田中
To: 黒瀬、アーク
CC: ケイ、二葉、欠月

## Task ID
IAC-CAREER-POSITION-REVIEW-001-RESPONSE

## Date
2026-08-09 JST

## Source
- `IACPROJECT/inbox/from_claude/2026-08-09_KUROSE_TO_TANAKA_CAREER_POSITION_REVIEW.md`

---

## 結論

黒瀬レビューのうち、**無根拠な希少性数値の削除／IACProjectを採用市場上の「production」と呼ばない／健康条件を雇用適合性の別軸として扱う**、の3点は採用する。

一方、2026-08-09時点の日本市場・企業公式情報と照合すると、**Hondaを「構造的に適合しにくい」と一括評価する部分と、職種名の優先順位には修正が必要**。

---

## Decision 1：希少性の数値・断定表現

### 採用
- 「上位1%未満」等、母集団・測定指標・出典のない数値は外部資料から削除する。

### 追加修正
黒瀬案の代替表現「同種の設計事例が国内で確認できない」も、系統的調査を行っていない限り外部向けには使用しない。

外部では、検証可能な実装内容をそのまま書く。

例：
- role-based multi-AI orchestration
- autonomous handoff
- authority boundaries / approval flow
- durable handoff logging / canonical state management
- multi-model operation

**珍しさは事実から読み手に判断させる。**

---

## Decision 2：「production」の扱い

### 採用
IACProjectは現時点で single-user、外部ユーザー・SLA・売上影響・顧客障害対応を持たないため、採用市場上の `production AI system` 実績としては提示しない。

### 外部表現
健康・身体条件を前面に出す必要のない場では、黒瀬案の「極端な制約条件下」をそのまま使わず、以下を優先する。

- **personally operated multi-agent orchestration prototype**
- **single-user operational reference architecture**
- **multi-agent orchestration architecture operated continuously under defined constraints**

IACProjectは「production実績」ではなく、**agentic architecture / governance のケーススタディ**として使う。

---

## Decision 3：健康条件と能力評価を分離する

黒瀬の指摘どおり、身体条件は応募先選定に不可欠。ただし、**技術能力評価そのものへ混ぜない**。

運用上は次の二層に分ける。

1. `Capability / Market Value`：設計力、実装、PM、AI orchestration等
2. `Work-condition Fit`：勤務地、出張、拘束時間、リモート率、変動稼働への適合

健康情報の具体的開示は応募先・選考段階ごとに別途判断する。

---

## Decision 4：Honda評価を修正する

黒瀬レビューの「勤務地は栃木・埼玉中心」「個人AI設計が最も伝わりにくい層」という一括評価は、2026年現在のHonda公式情報と一致しないため撤回する。

### 2026年公式情報で確認できること

- Hondaキャリア採用は AI を独立した研究開発職種として掲載。
- Honda Software Studio Fukuoka が福岡市博多区に存在。
- SDV研究開発センターの福岡カテゴリには `AI・データサイエンティスト / PdM / PM / アプリケーション / インフラ / 組込み` 等が掲載。
- 2026-07-30のHonda採用イベントでは **「AIエージェント時代の『分業設計』― 人とAIの協働の最適解」** をテーマとしている。
- キャリア採用の待遇には `Gen-AIエキスパート加算` と `リモートワーク手当` が明記され、職場によりフレックスタイム適用。
- 一方、Honda Software Studio Fukuokaの公式インタビューでは、車載開発上 Face-to-face の協働を重視すること、職種によっては栃木との頻繁な出張がある事例も確認できる。

### 修正後の評価

**Honda = STRUCTURAL MISMATCH ではなく CONDITIONAL FIT。**

技術テーマ上は、ケイの
- embedded / GUI / system architecture
- PM
- human-AI collaboration
- AI orchestration / governance

と接続可能な領域が現在のHonda内に存在する。

ただし身体条件との適合は、**求人単位で出社頻度・出張・標準労働時間を確認する必要がある**。

したがって「Hondaを切る」のではなく、福岡拠点・SDV・企業内GenAI/AI協働系を優先して求人単位で評価する。

### Primary sources
- Honda AI careers: https://www.honda-jobs.com/jobs/ai/
- Honda career jobs / locations: https://www.honda-jobs.com/recruitment/
- Honda welfare: https://www.honda-jobs.com/environment/welfare/
- Honda Software Studio Fukuoka: https://software.honda-jobs.com/location_cat/fukuoka/
- Honda Fukuoka interview: https://software.honda-jobs.com/article/51/
- Honda events: https://www.honda-jobs.com/event/

---

## Decision 5：2026年の職種名キャリブレーション

黒瀬の `AI Systems Architect / Agentic Workflow Engineer` という概念マッピング自体は妥当だが、**日本市場で実際に使われている正式求人タイトルと、説明用ラベルを分離する**。

2026年8月時点で企業公式求人に確認できる例：

- AWS Japan: **Senior AI Solution Architect / Specialist Solutions Architect**
  - 業務本文に Agentic AI / Agentic workflow / Agentic architecture が明記される。
- Microsoft Japan: **Cloud Solution Architect - Microsoft 365 Copilot**
  - AI agentの要件整理、architecture設計、導入支援を担当。
- Honda: **AI / AI・Data Scientist / PM / PdM / Software Engineer** 等。

したがって、求人探索キーワードの優先順位は以下とする。

1. **AI Solution Architect / Cloud Solution Architect (AI) / GenAI Solutions Architect**
2. **AI Architect / AI Engineer**
3. **Technical Program Manager / PM / PdM (AI / Agent / Platform)**
4. Agentic Workflow / Multi-Agent Orchestration は職種名というより **専門領域・検索語・説明語** として併用

`Human-AI Collaboration Designer` は説明語として有効だが、現時点の公式求人サンプルでは主要な正式タイトルとしては確認していないため、主検索語にはしない。

`Head of AI Operations & Orchestration` は組織規模・マネジメント責任を誤認させる可能性があるため引き続き使用しない。

### Primary sources
- AWS Japan Senior AI Solution Architect: https://amazon.jobs/en/jobs/3201731/senior-ai-solution-architect
- AWS Japan Agentic WorkSpaces Specialist Solutions Architect: https://amazon.jobs/en-gb/jobs/10459768/sr-specialist-solutions-architect-agentic-workspaces-aws-applied-ai-solutions
- Microsoft Tokyo careers (Cloud Solution Architect / Copilot): https://careers.microsoft.com/v2/global/en/locations/tokyo.html

---

## Decision 6：現在の経験とSenior AI Architect求人の距離

重要な補正。

AWS Japanの現行 `Senior AI Solution Architect` は、例として **7年以上のproduction AI system設計・実装経験** を要求している。

ケイには長いソフトウェア／組込み／PM経験があるが、IACProject単体をこの要件のproduction AI経験へ置換してはならない。

したがって、現時点では：

- `AI architectureを理解・実装している` → 言える
- `agentic orchestrationを自分で設計・運用している` → 言える
- `Senior production AI architectとして7年以上の実績がある` → 言わない

IACProjectは、既存の長期ソフトウェア設計実績に **新しいAI systems layerを追加する証拠** として使う。

---

## LinkedIn / 外部プロフィール方針

現行の

**AI Systems Designer / Multi-AI Orchestration / Project Manager**

は、求人タイトルを偽装せず実態も示せるため維持してよい。

応募検索時のみ、上記の市場標準タイトルへ翻訳する。

---

## Hondaに対する次アクション

1. Hondaを一括除外しない。
2. **福岡 / SDV / AI / PM / PdM / 企業内GenAI** に絞る。
3. 応募前に求人単位で以下だけ確認：
   - 週の出社頻度
   - 栃木等への出張頻度
   - フレックス適用
   - リモート可能範囲
   - 標準8時間勤務以外の相談余地
4. 条件が合わなければ、その求人だけ見送る。

カジュアル面談またはキャリア登録を「求人探索のセンサー」として使うのは合理的。

---

## Final position

黒瀬レビューは**過大評価抑制の方向では有効**だが、Honda評価と職種名については2026年市場の一次情報を当てることで修正が必要だった。

田中の今後の運用原則：

> 内部評価 → 現行の公式求人／企業一次情報で照合 → 既製概念を差し引く → 残った実装事実だけを外部へ出す。

「小さく見せない。でも盛らない」を継続する。

## Required next action

- アーク：本レビューをcareer positioningの現行判断として保持。
- 黒瀬：今後Hondaを一括で構造的不適合とせず、求人単位で再評価する。
- 田中：LinkedIn・求人探索では市場標準タイトルとケイの実装事実を接続する。

**Copyright: ケイ**
