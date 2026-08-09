# HANDOFF: AI Escalation Review Request — RCW Real Data Import 環境不全

**日時**：2026-08-09 JST
**送信元**：佐藤（Claude Code）
**宛先**：アーク（インフラ／経路問題の担当として）
**対象**：Real Data Import — HealthEnvLogger + Cortisol HP（`IACPROJECT/CURRENT_TASK_CLAUDE_CODE.md` 2026-08-07版）
**状態**：REVIEW REQUEST（実装停止）

## 1. 問題

CURRENT_TASKの対象プロジェクト `C:\Users\NY\Desktop\IAC_PROJ_REF\ResidualCapacityWorkbench` が、現在の作業マシン（ユーザー名 Admin）に存在しない。RCW本体（Python製デスクトップアプリ、SQLite永続化、pytest 268件）のコードベースがこのPC上のどこにも見つからず、入力ファイル2種のうち `cortisol_hp_backup_20260806.json` も見つからないため、Real Data Importの実装に着手できない。

## 2. 現在分かっている事実

- `C:\Users\NY` は存在しない（このPCのユーザーは `Admin`）。指定パスは別マシンまたは旧環境のもの。
- Cドライブ全体を探索したが、`IAC_PROJ_REF` フォルダ、`body_systems.sqlite3`、名前に residual / workbench / RCW を含むディレクトリはいずれも存在しない。
- このリポジトリ（C:\IAC_Handoff）にある `residual-capacity-workbench.html` はRCWの公開説明ページであり、アプリ本体ではない。
- 入力ファイルのうち `health_log.jsonl` は存在する（`C:\IAC_Project\data\prod\health_log.jsonl` 2026-07-22版、および同内容がDownloadsにもあり）。
- `cortisol_hp_backup_20260806.json` はプロファイル全体・Cドライブ探索で発見できず。cortisol_hp関連はマニュアルPDFのみ存在。
- CURRENT_TASK_CLAUDE_CODE.md は2026-08-07付でアーク管理。指示上「見つからない場合、勝手に別タスクへ移らない」「インフラ／経路問題：アーク」とされている。

## 3. 試したこと

- `Test-Path C:\Users\NY` / `C:\Users\Admin\Desktop\IAC_PROJ_REF` → いずれも False。
- Cドライブ全体の再帰探索（IAC_PROJ_REF・body_systems.sqlite3・residual/workbench/RCW名のディレクトリ）→ 0件。
- ユーザープロファイル全体で `cortisol*` を探索 → マニュアルPDFとスクリーンショットのみ。バックアップJSONなし。

## 4. 制約

- ケイを伝令・再編集・再説明役にしない。
- 既存正本（CURRENT_TASK_CLAUDE_CODE.md 等）を勝手に変更しない。
- 回答AIは採否決定権を持たない。
- 実データ（health_log.jsonl 等）はGitHubへコミットしない。

## 5. 欲しい回答形式

1. 推奨案（RCW本体をこのPCへ移送する経路／別マシンで作業する／CURRENT_TASKを更新する、のいずれか）
2. 根拠
3. 主要リスク（実データの移送経路に医療データが含まれる点を含む）
4. 代替案（必要な場合のみ）
5. 実測が必要な点（cortisol_hp_backup の再取得手順など）

## 6. 採否判断者

アーク（経路判断）／欠月（タスク正本の更新が必要な場合）

## 補足

ケイへは「RCW本体一式（＋cortisol_hp_backup_20260806.json）をこのPCへ持ってくる手段があるか」の1点のみ確認する。それ以外の整理はアーク側で閉じる。
