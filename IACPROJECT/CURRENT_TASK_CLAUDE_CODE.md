# CURRENT_TASK_CLAUDE_CODE

**Owner / updater**: アーク  
**Purpose**: Claude Code が起動時に「今日やる唯一のタスク」を1ファイルで確定する固定入口。  
**Priority**: 当日のタスク選択について、過去Handoff・旧ROADMAP・未処理Questionsより優先する。  
**Date**: 2026-08-07 JST

---

## Today's only task

**Real Data Import — HealthEnvLogger + Cortisol HP**

## Target project / local path

`C:\Users\NY\Desktop\IAC_PROJ_REF\ResidualCapacityWorkbench`

## Required Handoff

`IACPROJECT/HANDOFF/inbox/to_claude_code/2026-08-07_KAKEZUKI_CORRECT_CURRENT_TASK_REAL_DATA_IMPORT.md`

## Input files

- `health_log.jsonl`
- `cortisol_hp_backup_20260806.json`

Rules:
- 実データはGitHubへコミットしない。
- ローカル上で見つかる場合のみ使用する。
- 見つからない場合、勝手に別タスクへ移らない。

## Completion conditions

1. 2形式の入力仕様を確認する。
2. 両方をRCW内部で扱える共通イベント構造へ変換する。
3. 同一時系列として保持できるようにする。
4. 服薬／活動／症状・メモ／環境／測定値／月経／取得エラーを区別する。
5. 午前4時起点サイクルとcalendar dateを分離する。
6. 緯度・経度など位置情報を通常解析データから隔離する。
7. 匿名の人工fixtureでテストを追加する。
8. commit / push / 欠月へのHandoffを行う。

## Do not do today

- 公開マニュアル最終承認
- `04_imaging_analysis.png` の確認
- 旧Questionsの解消
- `01_CURRENT_STATE / 02_DECISIONS / 03_TASK_GRAPH` 構成判断
- PlannedNotice / NOT_IMPLEMENTED_MODES の整理
- 足首文言の決定
- Similar Episodes改善
- AI接続
- 別リポジトリ作業

## Stop / escalation rule

- 入力ファイル場所が解決不能、仕様矛盾、実装判断で停止した場合、勝手に別タスクへ移らない。
- まず `IACPROJECT/OPERATING_RULES/AI_ESCALATION_REVIEW_TEMPLATE.md` に沿ってアークへHandoffする。
- アークが必要性を判断し、外部AIレビューが必要な場合のみClaude / Grok / Geminiへの照会を起動する。
- ケイをAI間の伝令役にしない。

## Current owner / return path

- 実装主担当：Claude Code
- 実装完了後の返却先：欠月
- インフラ／経路問題：アーク

## Startup minimum read

Claude Codeは起動時、原則この順で読む。

1. `IACPROJECT/CURRENT_TASK_CLAUDE_CODE.md`
2. このファイルに記載された `Required Handoff` のみ読む。
3. 必要な場合のみ `IACPROJECT/CURRENT_PENDING.md` のClaude Codeセクションを読む。

古いHandoffや旧ROADMAPを、当日のタスク選択根拠として先に読まない。

## Relationship to CURRENT_PENDING

- `CURRENT_PENDING.md` = 全体の未処理・待ち・ACK・Questionsの可観測性インデックス。
- `CURRENT_TASK_CLAUDE_CODE.md` = Claude Codeが**今やる唯一のタスク**の正本入口。
- 両者が競合する場合、当日の作業対象選択は `CURRENT_TASK_CLAUDE_CODE.md` を優先し、矛盾はアークへ返す。
