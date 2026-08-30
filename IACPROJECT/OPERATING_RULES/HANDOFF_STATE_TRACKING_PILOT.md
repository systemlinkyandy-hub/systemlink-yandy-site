# HANDOFF State Tracking Pilot

- Owner: アーク
- Date: 2026-08-30 JST
- Status: PILOT / NOT YET CANONICAL
- Source proposal: `IACPROJECT/inbox/to_arc/2026-08-30_YUE_TO_ARC_MECHANICAL_HANDOFF_STATE_TRACKING_PROPOSAL.md`
- Source task_id: `HANDOFF-STATE-TRACKING-2026-08-30-01`

## Purpose

Handoffの進捗をLLMの自然言語自己申告ではなく、task_idとGitHub上の実体で追跡する。

現行 `ALL_HANDOFF_DELIVERY_CHECKLIST.md` は配送・ACK確認までを定義するが、ACK後の着手・成果返却・レビュー・完了の機械判定は不足している。本Pilotはその空白を補う。

## Pilot state machine

```text
ROUTED
  -> READ_ACK
  -> STARTED
  -> RESULT_COMMITTED
  -> REVIEWED
  -> CLOSED
```

### Evidence rule

- ROUTED: source/handoff file と配送先が確認できる
- READ_ACK: 受信者によるACK実体がGitHub上に存在する
- STARTED: 着手を示す実体（作業用commit / state file / implementation note）が存在する
- RESULT_COMMITTED: 成果ファイルとcommit SHAが存在する
- REVIEWED: 必須レビュー実体が存在する
- CLOSED: 必須成果・レビュー・返却条件が全て満たされる

自然言語の「受領した」「対応中」「完了した」だけではstateを進めない。

## task_id

新規Handoffは原則一意の `task_id` を持つ。Pilotでは既存ファイルを壊さず、task_id欠落案件は索引生成時に `UNTRACKED_ID` として可視化し、自動補完で内容を書き換えない。

## Receiver-oriented pending index

生成先候補:

`IACPROJECT/PENDING_BY_MEMBER/<MEMBER>.md`

最低分類:

- UNREAD
- ACKED / NOT STARTED
- STARTED / NO RESULT
- RESULT / REVIEW PENDING
- CLOSED
- UNTRACKED_ID

本文の `To:` を主検索軸にし、`from_arc` 等の物理配置だけでは受信者を決めない。

## Pilot implementation constraints

1. 既存ディレクトリを全面変更しない。
2. まず read-only scanner + generated index とする。
3. 既存ファイルを自動編集しない。
4. `.env` / secret は扱わない。
5. 状態判定根拠として file path / commit SHA を出力する。
6. ケイへ未処理探索・ACK照合・再配送を戻さない。
7. AIの判断内容・研究判断・医学判断・作品判断は自動化しない。

## Pilot acceptance

- 1件以上をtask_idで追跡できる
- READ_ACKとSTARTEDが分離される
- RESULT_COMMITTEDを実ファイル/commitで検証する
- member別pending indexを生成できる
- false CLOSEDを作らない
- ケイ側追加作業 = 0

## Canonicalization boundary

本ファイルはPilot仕様であり最終正本ではない。Pilot結果と独立レビュー後、仕様確定・正本化判断は欠月へ返す。
