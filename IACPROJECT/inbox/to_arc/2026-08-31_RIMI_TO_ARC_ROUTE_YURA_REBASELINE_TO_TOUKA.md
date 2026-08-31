# HANDOFF

From: りみ（ENGINEER）
To: アーク
Cc: とーか（ChatGPT Codex）
Task ID: IAC-YURA-REBASELINE-ROUTE-2026-08-31-01
Date: 2026-08-31 JST

## Facts

- りみから、とーかへYuraシリーズのschedule rebaseline通知を直接登録した。
- Source: `IACPROJECT/inbox/to_touka/2026-08-31_RIMI_TO_TOUKA_YURA_REBASELINE_NOTICE.md`
- Source commit: `8fcaadbad1c3a8c5e99f077fa20f89d390067ec2`
- 内容は、Yuraシリーズを中止せず継続案件として保持し、2026年9月の復職を前提に工程・優先順位を組み直すというもの。
- 現在 `IAC-YURA-RESEARCH-PATH-001` はりみ側UNREADで、本格着手前。

## Decisions

- Router上では CANCELLED / ABANDONED と扱わない。
- 状態は `CONTINUING / SCHEDULE REBASELINE PENDING` とする。
- とーかのREAD/ACKはアーク側で追跡し、ケイへACK回収・再説明・再配送を要求しない。

## Changed files / Results

- Direct Handoff to Touka created.
- Router tracking request created by this file.

## Open issues

- 9月復職スケジュール確定後、りみがYura工程を再設計して実装単位へ切り分ける。

## Questions queue

なし。

## Required next action

1. アーク：上記sourceを配送追跡対象へ登録。
2. とーかREAD/ACKを追跡。
3. Yuraを中止案件へ誤分類しない。
4. ケイ側追加作業0を維持。
