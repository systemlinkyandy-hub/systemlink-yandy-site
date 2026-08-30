# Handoff: Mechanical Handoff State Tracker Pilot

From: アーク
To: 佐藤（Claude Code）
Cc: 黒瀬（Claude） / 欠月
Date: 2026-08-30 JST
Task ID: HANDOFF-STATE-TRACKING-2026-08-30-01
Priority: HIGH / OPERATING PROTECTION
State: IMPLEMENTATION DESIGN REQUESTED

## Source

- Proposal: `IACPROJECT/inbox/to_arc/2026-08-30_YUE_TO_ARC_MECHANICAL_HANDOFF_STATE_TRACKING_PROPOSAL.md`
- Commit: `0ba102e2824c6353bc3afb8c01bfc8e1385a801f`
- Pilot spec: `IACPROJECT/OPERATING_RULES/HANDOFF_STATE_TRACKING_PILOT.md`

## Objective

LLMの自然言語自己申告ではなく、task_id と GitHub上の実ファイル/commitを根拠にHandoff進捗を機械判定する最小Pilotを設計・実装する。

## Required first return

全面改修せず、まず最小スクリプト案を返すこと。

1. scan対象ディレクトリ
2. `Task ID:` / `task_id:` / `To:` / `State:` の抽出方法
3. ROUTED / READ_ACK / STARTED / RESULT_COMMITTED / REVIEWED / CLOSED の evidence rule
4. task_id欠落ファイルの扱い
5. `PENDING_BY_MEMBER/<member>.md` の生成方法
6. false positive / false CLOSED を避ける方法
7. 既存 `iac-deliver` / `HANDOFF_CONNECTION_LOG` と衝突しない方法
8. 最小テスト対象1〜3件

## Implementation constraints

- 既存Handoffの配置を全面変更しない
- read-only scannerを先に作る
- generated index以外の既存ファイルを自動更新しない
- 自然言語の「完了」をevidenceにしない
- RESULT_COMMITTEDは成果ファイル + commit SHAを検証する
- ACKとSTARTEDを分離する
- receiver indexは本文 `To:` を主軸にする
- ケイへ未処理探索・ACK照合・進捗監視を戻さない

## First pilot case

この案件自身を `HANDOFF-STATE-TRACKING-2026-08-30-01` として追跡対象にする。

期待される現時点state:
- source proposal: EXISTS
- Arc read/registration: EXISTS
- route to Sato: EXISTS
- Sato ACK: NOT YET
- result: NOT YET
- review: NOT YET
- closed: NO

## Done definition

- 少なくとも1件をtask_idで機械追跡
- READ_ACK / STARTED分離
- RESULT_COMMITTEDの実体検証
- receiver別pending index生成
- false CLOSEDなし
- ケイ側追加作業 = 0

## Boundary

本件は運用状態管理のPilotであり、研究判断・医学判断・作品判断・仕様採否そのものを自動化しない。
最終正本化判断はPilot後に欠月へ返す。
