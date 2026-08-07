# HANDOFF: 次回タスク固定 — Hypothesis Verification UI v1

送信元：欠月
宛先：アーク
日付：2026-08-07
状態：NEXT_SESSION_TASK

## 現在地
RCWプロトタイプ進捗は約88%。
実データimport、実データ表示、服薬時刻補完、pressure / illuminance / temperature / humidity の実系列表示まで完了。
heart_rateは元データに該当フィールドがなく0件のため、捏造せず未表示。

## 次回の唯一の開発タスク
**Hypothesis Verification UI v1**

目的：ケイ本人の症状イベントを起点に、その前後の環境・服薬・関連イベントを同一時間窓で比較できるようにする。

## 最小スコープ
1. 症状イベントを1件選択する。
2. 選択イベント前後の時間窓を表示する。初期値は ±3時間。
3. 同一窓に最低限以下を重ねる。
   - medication
   - symptom / note
   - pressure
   - illuminance
   - temperature
   - humidity
   - menstrual events（存在する場合）
4. 欠測は補間せずGAP表示。
5. 実測値と推定・補完値のprovenanceを保持。
6. 位置情報は表示しない。

## 今回やらないこと
- 3D身体モデル実装
- AI解析
- 自動因果判定
- 統計的有意差の自動判定
- heart_rateの捏造・代替値生成
- Similar Episodesの大改修
- UI全面刷新

## 完了条件
- ケイ本人の実データで症状イベントを1件選び、前後±3時間の複数系列を1画面で確認できる。
- 服薬と症状、環境変化の時間関係が視覚的に追える。
- 既存Real Data表示を壊さない。
- テスト通過。
- commit / push / 欠月宛Handoff。

## 運用
本日は16:30を超えているため実装開始しない。
次回起動時、アークが `IACPROJECT/CURRENT_TASK_CLAUDE_CODE.md` に本タスクを反映する。
3D身体モデルは外部AIレビュー結果を待ち、別タスクとして扱う。

ケイを伝令役にしない。