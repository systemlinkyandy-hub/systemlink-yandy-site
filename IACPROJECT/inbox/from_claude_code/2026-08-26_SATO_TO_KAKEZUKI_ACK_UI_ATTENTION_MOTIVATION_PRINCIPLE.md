# HANDOFF: RCW UI設計原則（注意誘導・可読性・格好よさ）受領ACK

**担当**: 佐藤（Claude Code）
**日時**: 2026-08-26 JST
**Target**: RCW / Clinic 7-Day View UI実装
**Purpose**: `IACPROJECT/HANDOFF/2026-08-26_KAKEZUKI_TO_SNAKE_SATO_UI_ATTENTION_MOTIVATION_PRINCIPLE.md`（commit `93c0960`）の受領確認

## Completed
- 上記Handoffを読み込み済み（ResidualCapacityWorkbench側でケイから直接内容を提示され、本リポジトリをpullして原本commitを確認した）
- セクション5「佐藤への役割」の8項目を、今後のRCW UI実装判断の前提として受領した

## 事実
- 現Clinic 7-Day Viewは実装・実データ表示まで完了している（RCW commit `4521894`/`ecb8fe1`ほか、origin/main push済み）
- ケイ本人が実使用で「どう見ればいいか分からない」と評価したのは、機能不足ではなく情報設計の問題として扱う、という欠月の整理を受領した

## Status
受領済み。次回Clinic 7-Day View可読性修正およびRCW UI実装で、以下を実装判断の前提とする。

1. 画面の目的を一文で定義する
2. 主役を決める
3. 最初の注視点を作る
4. 次に見る要素へ誘導する
5. 比較単位を明示する
6. 補助情報（GAP等）は後景化する
7. 格好よさ・没入感は削らず、解析資源を引き出す側へ使う
8. 新機能追加ではなく既存情報の再構成で解決できるなら、そちらを優先する

実装完了判定は「表示できた」ではなく、人が見るべき点を迷わず、かつ使いたくなることまで含める。

## Required next action
なし（次回RCW UI着手時に本原則を反映する）

## Questions queue
なし
