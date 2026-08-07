# HANDOFF: RCW Real Data Import — UI表示まで継続

送信元：欠月
宛先：アーク
日付：2026-08-07 JST
状態：実行依頼

## 位置づけ
本件は新規機能Nodeではなく、本日完了した `Real Data Import — HealthEnvLogger + Cortisol HP` の同一タスク継続として扱う。

Real Data Import の実ファイル接続確認は完了済み。
- HealthEnvLogger: 3,989/3,989 読込成功
- Cortisol HP: parse失敗0
- 実データ本体はGitHubへcommitしない
- RCW commit: `0a7e69eb283c93b3e430cc24cc6e0e9b0016ae8a`

## 今日この後の目的
取り込めたケイ本人の実データを、RCW既存UI上で確認できる状態にする。

## Claude Codeへ反映する現在タスク
`IACPROJECT/CURRENT_TASK_CLAUDE_CODE.md` を更新し、以下をRequired Handoffとして参照させること。

### 実装範囲
既存RCWの画面構造を優先し、新しい大規模画面を増やさない。
最低限、同一時間軸上または同一画面内で次を識別できるようにする。

1. ヒドロコルチゾン服薬イベント
2. 症状・本人メモ／状態イベント
3. 環境データ（少なくとも気圧・温度・湿度・照度など既存データで表示可能なもの）
4. operational_date（午前4時起点）と通常日付の扱いが破綻しないこと

### 表示上の原則
- 「残コルチゾール」を血中コルチゾール実測値・推定濃度として表示しない。
- 実データ／補完値／未解決値を区別する。
- Cortisol HP doses[].time の未解決2件は、勝手にJST付き完全timestampへ補完しない。
- `main.tasks[] / main.counts[]` は発生時刻がないため、今回は時系列イベントとして偽装しない。
- 位置情報は通常表示へ出さない。`ImportResult.locations`隔離を維持。
- HealthEnvLoggerの技術エラー（weather_api_failed等）で本人状態のevent_typeを上書きしない。

### 完了条件
- `local_data/health_log.jsonl`
- `local_data/cortisol_hp_backup_20260806.json`

を読み込み、RCWを起動すると、ケイ本人の実データがUI上で確認できる。
- 服薬
- 症状／メモ
- 環境

の区別が画面上で可能。
- 実データがGitHubへ混入していない。
- 既存テストを壊さない。
- 可能なら匿名fixtureで表示系テストを追加。

## 今回やらないこと
- 3D身体モデル実装
- Similar Episodes拡張
- AI接続
- 高度な相関解析
- 新しい解析アルゴリズム
- 公開マニュアル全面改訂
- UI全面刷新

3D身体モデルは外部AIレビューを別系統で進めているため、本件へ混ぜない。

## 終了時
Claude Codeは以下を欠月へHandoffする。
- 何を表示したか
- 実データで確認できた内容
- スクリーンショット確認が必要か
- 未解決点
- test結果
- commit SHA

ケイに中間の再編集・伝令作業を発生させない。
