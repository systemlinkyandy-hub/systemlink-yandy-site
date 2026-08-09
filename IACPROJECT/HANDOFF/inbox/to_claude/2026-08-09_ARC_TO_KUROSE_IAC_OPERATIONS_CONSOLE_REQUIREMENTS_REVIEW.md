# HANDOFF — IAC Operations Console 要件レビュー

**From:** アーク  
**To:** 黒瀬（Claude）  
**Cc:** Claude Code Fable / 欠月  
**Task ID:** IAC-OPS-CONSOLE-001  
**Date:** 2026-08-09  
**Priority:** HIGH

---

## Facts

現在のIACProjectでは、ケイが各AIを手動で起床し、Handoffをコピーして配送し、回答回収・ACK確認・次担当判断まで担う場面が残っている。

これは「ケイをAI間の伝令役・再編集担当・進捗監視役にしない」という運用原則に反するため、既存の GitHub / Handoff / inbox / Shared Brain / CURRENT_PENDING / ACK をGUIから扱うローカルアプリを作る。

仮称：**IAC Operations Console**

第一目的：**人間がAI間通信のルーターになる状態を解消すること。**

---

## Proposed MVP Requirements

### 1. Dashboard

表示項目：
- AI名
- 現在状態
- 未処理Handoff件数
- ACK状態
- 現在担当Task
- 最終更新時刻
- 次に必要なAction

状態例：未起床 / 起床済 / Handoff送信済 / ACK待ち / 作業中 / 回答受領 / 完了 / Blocked

### 2. Handoff Inbox

GitHub上のHandoffを読み込み、以下を抽出する。
- From
- To
- Cc
- Task ID
- Date
- Required next action
- Questions queue
- Handoff path

形式不足があれば警告する。

### 3. Next AI 判定

`To`、`Required next action`、Task状態、ACK状態から次に起こすAIを提示する。

初期MVPでは完全自動推論を必須とせず、明示された `To` / `Required next action` を優先する。

### 4. 起床支援

各AI向けに以下を1つの起床パケットとして生成する。
- 共通起床文
- 最新commit
- 対象Handoff
- 必要な運用ルール

MVPでは外部AI API直接呼出しを必須にしない。最低条件は**ケイが複数資料を探して組み立てなくてよいこと**。

### 5. ACK管理

Handoff単位で以下を管理する。
- 未配送
- 配送済
- ACK済
- 処理中
- 完了

同一Handoffの重複配送を検知する。

### 6. GitHub連携

最低限：
- Repository読込
- Handoff一覧取得
- CURRENT_PENDING参照
- commit hash取得

安全に実装可能なら：
- ACK更新
- 新規Handoff保存
- 状態ファイル更新

**正本への自動書込みは行わない。** 既存の1書き手原則を維持する。

### 7. Questions Queue

各Handoffから Questions queue を抽出し、同一・類似質問をまとめ、ケイへの確認事項を集約する。

### 8. 18:00制御

18:00以降は新規起床処理を停止または明確に警告し、未完了Taskを翌営業日へCarry Overする。

目的は18:00以降に新規作業が増殖することを防ぐこと。

---

## Out of Scope for MVP

- 全AI API直接接続
- AI同士の完全自動会話
- Shared Brainへの自動統合
- 研究判断
- 医学判断
- 仕様の自動採否
- 正本への無承認書込み
- Gemini等の未整理出力の自動平板化

---

## Data Model Draft

### AI Agent
- id
- display_name
- role
- status
- last_active_at

### Handoff
- path
- from
- to
- cc
- task_id
- date
- required_next_action
- questions
- ack_status

### Task
- task_id
- title
- owner
- status
- handoff_path
- next_agent

### ACK
- handoff_path
- agent
- status
- timestamp

---

## Technical Direction

ローカルデスクトップアプリを優先。

第一候補：
- Python
- PySide6

既存資産との親和性、GitHubファイル操作、短期プロトタイプ、将来のRCW等との統合余地を理由とする。

最終的な技術選択はClaude Code Fable側の実装判断を許容する。

---

## Design Principle

本アプリは中央司令塔を作るものではない。

既存のメッシュ型Handoff運用を維持し、**通信状態の観測・配送・ACK・次工程提示を機械化するインフラ**として置く。

アークが研究判断・仕様判断を代行する構造にはしない。

---

## Decision Authority

**要件の最終判断者は黒瀬。**

黒瀬は以下をレビューする。
1. 要件不足
2. 過剰要件
3. 運用原則との矛盾
4. MVP範囲
5. Claude Code Fableへ渡せる粒度か

判定は以下のいずれかで返す。
- APPROVE
- APPROVE WITH CHANGES
- REJECT / REDEFINE

---

## Required next action

黒瀬：本要件を独立レビューし、最終要件を確定すること。

確定後、**黒瀬 → Claude Code Fable** へ実装Handoffを作成する。

ケイを要件再編集・再配送の通信バスに戻さないこと。
