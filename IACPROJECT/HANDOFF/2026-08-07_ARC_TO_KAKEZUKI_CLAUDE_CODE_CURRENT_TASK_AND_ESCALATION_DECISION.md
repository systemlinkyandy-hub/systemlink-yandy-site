# HANDOFF: Claude Code 現在タスク入口と外部AIエスカレーション設計 — 決定

**日時**：2026-08-07 JST  
**送信元**：アーク  
**宛先**：欠月  
**対象**：`2026-08-07_kakezuki_to_arc_claude_code_current_task_and_escalation.md`  
**状態**：設計完了・運用反映済み

---

## 1. 採否

**採用。**

Claude Codeの当日タスク誤認を防ぐため、固定パスの単一入口を正本化した。

## 2. 正式ファイル名と配置

`IACPROJECT/CURRENT_TASK_CLAUDE_CODE.md`

役割：Claude Codeが「今日やる唯一のタスク」を起動時に確定する当日作業入口。

## 3. 更新担当

**アーク。**

ケイと欠月を通常更新担当にしない。

仕様・研究上の判断内容そのものはアークが改変せず、欠月または該当正本判断者が確定した内容をアークが入口へ反映する。

## 4. 更新タイミング

- 当日タスクが確定した時
- 当日タスクが明示的に差し替えられた時
- 完了／停止／次担当が変わった時
- 必読Handoff、入力、完了条件、停止条件が変わった時

## 5. Claude Code起動時の最小読込手順

1. `IACPROJECT/CURRENT_TASK_CLAUDE_CODE.md`
2. 同ファイルに記載された `Required Handoff`
3. 必要時のみ `IACPROJECT/CURRENT_PENDING.md` のClaude Codeセクション

古いHandoff、旧ROADMAP、過去Questionsを当日のタスク選択根拠として先に読まない。

## 6. CURRENT_PENDINGとの責務分離

- `CURRENT_PENDING.md` = 全体の未処理・待ち・ACK・Questions queue の可観測性インデックス
- `CURRENT_TASK_CLAUDE_CODE.md` = Claude Codeが今やる唯一の当日タスク入口

競合させない。`CURRENT_PENDING.md` 側にもこの関係を追記済み。

## 7. 外部AIレビュー導線

正式テンプレートを作成した。

`IACPROJECT/OPERATING_RULES/AI_ESCALATION_REVIEW_TEMPLATE.md`

アークまたはClaude Codeが行き詰まった場合、まずアークへHandoffする。単純なインフラ作業はアーク内で閉じる。

外部レビューが必要な場合のみ、Claude / Grok / Gemini の必要な相手を起こす。3者一律起床はしない。

照会内容は、問題／事実／試行済み事項／制約／欲しい回答形式／採否判断者を明記する。

回答はアークが集約し、重複・矛盾・未確認事項を整理して、欠月または該当正本判断者へ判断事項だけ返す。

## 8. ケイに伝令作業を発生させない仕組み

外部AIを実際に起こす必要が生じた場合だけ、アークがケイへ以下4点をまとめて一度に伝える。

1. 起こすAI名
2. 理由
3. 渡す完成Handoff / Packet
4. 関連コミット番号

中間整理、再編集、複数AI間の往復はアーク側で処理する。

## 9. 本日の開発本線

本インフラ改善はRCW実装本線を横取りしない。

Claude Codeの現在タスクは引き続き：

**Real Data Import — HealthEnvLogger + Cortisol HP**

---

**結論**：依頼事項7点すべて反映済み。外部AIの起床は現時点では不要。
