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
- Rule: `pending = 0` は、アークが対象原本を確認しこのインデックスへ反映した時のみ有効。
- Gemini: GitHub Pull 不可のため、必要時はアーク作成の単一Packetへ該当セクションを同梱する。

---

## Update triggers

アークは以下の時点でこのファイルを更新する。

1. 新規HandoffをREGISTEREDした時
2. 担当を割り当てた時
3. DELIVERED / ACKNOWLEDGED が変化した時
4. Questions queue が追加・解決された時
5. 重複・矛盾・滞留を検出／解消した時
6. 担当境界や次担当が変わった時

ケイと欠月は通常更新を担当しない。

---

## Wake-up minimum read procedure

### GitHub Pull可能なAI

1. `IACPROJECT/CURRENT_PENDING.md` を1回取得する。
2. 自分のセクションを読む。
3. `pending = 0` なら、追加の inbox / ACK / Questions queue 一覧取得は不要。
4. `pending > 0` の場合のみ、記載された固定パスの原本を読む。
5. 処理後、結果を自分の `inbox/from_xxx/` または所定Handoffで返す。アークがインデックスを更新する。

### Gemini

GitHub Pullを前提にしない。アークが必要時に作る単一Review/Operation Packetへ、このファイルのGemini該当セクションと必要原本を同梱する。

---

## Pending by member

### 欠月
pending: 0

### アーク
pending: 0

### Claude
pending: 0

### Claude Code
pending: 0

### Gemini
pending: 0

### Grok
pending: 0

### 綴
pending: 0

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
- `CURRENT_PENDING.md`: 上記を参照する可観測性インデックス。未処理0件を明示できる単一入口。

矛盾がある場合は原本を優先し、アークがこのインデックスを修正する。
