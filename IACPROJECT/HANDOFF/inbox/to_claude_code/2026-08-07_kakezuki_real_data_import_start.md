# HANDOFF: RCW Real Data Import — HealthEnvLogger + Cortisol HP

送信元：欠月
宛先：Claude Code
日付：2026-08-07
状態：START_AUTHORIZED

## 今日の対象
Residual Capacity Workbench
Node: `Real Data Import — HealthEnvLogger + Cortisol HP`

## 今日の目的
ケイの実データ2種類を、RCWが同一時間軸で扱える内部データへ読み込めるところまで進める。

対象形式：
1. `health_log.jsonl` — HealthEnvLogger
2. `cortisol_hp_backup_20260806.json` — 残コルチゾールHP backup v3

重要：実データそのものはGitHubへコミットしない。位置情報・個人メモ・医療情報を含み得るため、ローカル入力としてのみ扱う。

## 既知の入力構造
### Cortisol HP backup v3
トップレベル：
- `format: cortisol-hp-backup`
- `version: 3`
- `exportedAt`
- `main`
- `history`

`main`には少なくとも：
- `doses[]`: `time`, `mg`, `taken`
- `tasks[]`: emoji/name/cost/count/spike
- `counts[]`
- `hp`
- `doneToday`
- `spentToday`
- `basalConsumed`
- `depletionMs`
- `savedDay`
- `memos[]`: epoch ms `t`, `time`, `text`

`history[]` は日ごとの `day`, `savedAt`, `text` を持つ。`text`内には服薬、活動、症状メモ等が文章形式で格納される。

### HealthEnvLogger JSONL
1行1レコードの時系列ログとして扱う。実データでは環境・症状・メモ・月経周期・取得エラー等を含み、位置情報を含む可能性がある。

## 時刻ルール
- 可能な限り timezone-aware datetime に正規化する。
- ケイの運用上の日付境界は午前4時起点の記録があるため、calendar date と cycle day を混同しない。
- 元データの原時刻は保持する。
- 不明・曖昧な時刻は勝手に補完しない。`parse_status` 等で未確定を残してよい。

## 今日の完了条件
最低限、以下まで。

1. 2形式の importer / parser を実装する。
2. RCW内部の共通イベント構造へ正規化する。
3. 同一タイムラインへ結合できる。
4. 少なくとも次の event kind を区別できる：
   - medication
   - activity
   - symptom_or_note
   - environment
   - measurement
   - menstrual
   - error_or_missing
5. raw location は内部解析でも別扱いとし、通常の共通イベントへ不用意に露出させない。
6. 実データ本体をGit commitしない。
7. importer単体テストを追加する。個人情報を含まない人工fixtureのみ使用。
8. 読込件数・parse失敗件数・時刻範囲を返せる summary を用意する。
9. commit / push / 欠月向けHandoff。

## 実装方針
- 既存RCWのデータモデル、importer、repository層があれば必ず再利用する。
- 既存設計を無視して新しい並列データモデルを作らない。
- 最初にコードベースを調べ、既存の取り込み経路・SQLite schema・timeline/event model を確認する。
- 互換性が不明なら、最小変更で adapter 層を置く。
- Cortisol HP の `history.text` の完全な自然言語抽出は今日の必須条件ではない。確実に構造化できる項目を優先し、未解析textは raw note として保持してよい。
- HealthEnvLoggerは unknown fields を捨てず、必要なら `raw_payload` / extras に保持する。ただし location は通常表示から分離する。

## 今日やらないこと
- Similar Episodes改善
- AI解析接続
- Graph RAG
- 豪華なグラフ/UI改修
- 外部API接続
- 公開GitHubへの実データ配置
- 他リポジトリの機能開発

## 実ファイルの探索
ケイのPC上に同名ファイルがある場合、Downloads / Desktop 等の通常のユーザー領域から exact filename で探してよい。
ただし広範囲な個人ファイルスキャンはしない。
見つからない場合は、実装と人工fixtureテストまで進め、欠月へ「実ファイルだけ未接続」と返す。ケイへ途中で探させない。

## 停止条件
今日はこの1 Nodeのみ。
16:00以降は新しい機能へ着手しない。
16:30までに commit / push / Handoff して閉じる。

## Handoffで必ず返すこと
- 変更ファイル
- 追加した内部イベント構造
- 2形式それぞれの読込結果
- 実データが読めた場合：件数、時刻範囲、parse失敗数
- locationの扱い
- 未実装・曖昧な点
- 次の1タスク候補
- commit SHA

ケイへの途中確認は不要。判断が必要な事項だけ欠月へ返すこと。
