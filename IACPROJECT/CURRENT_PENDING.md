# CURRENT_PENDING

**Owner**: アーク  
**Purpose**: AIごとの未処理・滞留・ACK・Questions queue の可観測性を、一覧APIに依存せず1ファイルで確認するための固定インデックス。  
**Canonical role**: このファイルは正本そのものではなくインデックス。原本は各 `inbox/`、`ACK/`、`Questions queue`、Handoff に残す。  
**Update responsibility**: アーク  
**Last updated**: 2026-08-07 JST

---

## System state

- Index status: ACTIVE
- Historical backlog reconciliation: INITIALIZED
- Human bus bypass: ACTIVE
- Delivery router: `IACPROJECT/ROUTER/CURRENT_DELIVERIES.md`
- Delivery protocol: `IACPROJECT/OPERATING_RULES/HUMAN_BUS_BYPASS_PROTOCOL.md`
- Rule: `pending = 0` は、アークが対象原本を確認しこのインデックスへ反映した時のみ有効。
- Gemini: GitHub Pull 不可のため、必要時はアーク作成の単一Packetへ該当セクションを同梱する。
- Claude Code current-task entry: `IACPROJECT/CURRENT_TASK_CLAUDE_CODE.md`

---

## Update triggers

アークは以下の時点でこのファイルを更新する。

1. 新規HandoffをREGISTEREDした時
2. 担当を割り当てた時
3. DELIVERED / ACKNOWLEDGED が変化した時
4. Questions queue が追加・解決された時
5. 重複・矛盾・滞留を検出／解消した時
6. 担当境界や次担当が変わった時
7. `CURRENT_DELIVERIES.md` の配送状態が変わった時

ケイと欠月は通常更新を担当しない。

### Wake-up ordering invariant

外部AIを起床させる場合は、必ず次の順序で行う。

1. 対象HandoffをREGISTEREDする。
2. `IACPROJECT/ROUTER/CURRENT_DELIVERIES.md` に配送項目をROUTEDする。
3. `CURRENT_PENDING.md` を更新する。
4. 起床通知では、対象Handoffの登録コミットではなく、`CURRENT_PENDING.md` 更新後のコミットを指定する。
5. 指定コミット時点で対象AIの `pending > 0` が確認できることをアークが検証してから通知する。

---

## Wake-up minimum read procedure

### GitHub Pull可能なAI

1. `IACPROJECT/CURRENT_PENDING.md` を1回取得する。
2. 自分のセクションを読む。
3. `pending = 0` なら、追加の inbox / ACK / Questions queue 一覧取得は不要。
4. `pending > 0` の場合のみ `IACPROJECT/ROUTER/CURRENT_DELIVERIES.md` の自分宛項目を確認し、記載された固定パスの原本を読む。
5. 処理後、結果を自分の `inbox/from_xxx/` または所定Handoffで返す。アークがインデックスと配送状態を更新する。

### Claude Code

当日の実装タスク選択は `IACPROJECT/CURRENT_TASK_CLAUDE_CODE.md` を最優先入口とする。`CURRENT_PENDING.md` は未処理可視化用であり、当日タスク正本ではない。

### Gemini

GitHub Pullを前提にしない。アークが必要時に作る単一Review/Operation Packetへ、このファイルのGemini該当セクション、`CURRENT_DELIVERIES.md` の該当配送項目、必要原本、欲しい回答形式を1つに同梱する。ケイの操作はそのPacketを1回渡すことだけとする。

---

## Pending by member

### 欠月
pending: 0

### アーク
pending: 0

### Claude
pending: 0
last_result: `IACPROJECT/inbox/from_claude/2026-08-07_CLAUDE_TO_ARC_GEMINI_BIRDMEN_FINAL_REVIEW.md`
status: BIRDMEN FINAL REVIEW COMPLETED

### Claude Code
pending: 0
current_task: `IACPROJECT/CURRENT_TASK_CLAUDE_CODE.md`

### Gemini
pending: 0
last_result: `IACPROJECT/inbox/from_gemini/2026-08-07_GEMINI_BIRDMEN_FACT_PACKET.md`
status: BIRDMEN REVIEW LOOP CLOSED / OPTIONAL WORDING ADJUSTMENT ONLY

### Grok
pending: 0

### 綴
pending: 0
note: BIRDMEN軽微な表現調整は任意。未処理として数えない。

### 上原さん
pending: 0

### ユエ
pending: 0

### 田中
pending: 0

### ゆいま〜る
pending: 0

### りみ
pending: 0

### まさる姐さん
pending: 0

### 纏めの君
pending: 0

---

## Relationship to existing sources

- `inbox/`: 原本受信箱。置き換えない。
- `ACK/`: 受領証跡の原本。置き換えない。
- `Questions queue`: 判断待ち・質問の原本。置き換えない。
- `CURRENT_PENDING.md`: 未処理可視化の単一入口。
- `IACPROJECT/ROUTER/CURRENT_DELIVERIES.md`: AI間配送状態の固定ルータ索引。
- `IACPROJECT/OPERATING_RULES/HUMAN_BUS_BYPASS_PROTOCOL.md`: ケイを通信バスにしないための配送規約。
- `CURRENT_TASK_CLAUDE_CODE.md`: Claude Codeが今やる唯一のタスクを示す当日作業入口。

矛盾がある場合は原本を優先する。ただしClaude Codeの当日タスク選択は `CURRENT_TASK_CLAUDE_CODE.md` を優先し、配送状態の矛盾はアークが整理する。
