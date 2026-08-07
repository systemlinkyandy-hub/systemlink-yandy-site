# HANDOFF: Real Data Import — HealthEnvLogger + Cortisol HP 完了報告

送信元：Claude Code
宛先：欠月
対象タスク：`2026-08-07_kakezuki_real_data_import_start.md` /
`2026-08-07_KAKEZUKI_CORRECT_CURRENT_TASK_REAL_DATA_IMPORT.md` への応答
日付：2026-08-07
状態：COMPLETE_RETURN_TO_KETSUGETSU（実ファイルのみ未接続）

---

## 対象プロジェクト

Residual Capacity Workbench — Real Data Import Node

## 対象ローカルパス

`C:\Users\NY\Desktop\IAC_PROJ_REF\ResidualCapacityWorkbench`

## 完了したこと

指定された完了条件1〜8をすべて満たした（9は本Handoff）。

- コミットSHA：`a6a34c28f74fa9380aae6e90b7cef96bb7ac0574`
- RCW Privateリポジトリへpush済み（`origin/main`と一致確認済み）
- テスト：303 passed（既存268 + 新規35、0 failed）

## 変更ファイル

新規:
- `app/data/import_events.py` — 共通正規化イベント構造（後述）
- `app/data/health_env_logger_import.py` — HealthEnvLogger JSONL importer
- `app/data/cortisol_hp_import.py` — Cortisol HP backup v3 importer
- `app/data/real_data_locator.py` — 実ファイル探索ヘルパー（`local_data/` →
  Downloads → Desktop → Documents の順、浅い探索のみ）
- `tests/test_import_events.py`, `tests/test_health_env_logger_import.py`,
  `tests/test_cortisol_hp_import.py`（匿名の人工fixtureのみ使用）

変更:
- `.gitignore` — `local_data/`、`health_log*.jsonl`、`cortisol_hp_backup*.json`
  を除外に追加（実データを誤ってcommitできないようにする安全網）

アプリ本体（UI/main_window等）・既存モデル・既存DBスキーマへの変更なし
（今回は既存の取り込み経路・timeline/event modelを調査したうえで、
Unified Timeline側の`TimelineEvent`（デモ専用・永続化なし）ともBody Systems側の
`BodyObservation`等（症状観測に特化）とも意味的に合わないと判断し、独立した
正規化レイヤーとして追加した。並列モデルの無秩序な追加を避けるため、
既存の`body_analysis.py`と同じ「Qt非依存の純粋関数モジュール」設計パターンを
踏襲している）。

## 追加した内部イベント構造

`app/data/import_events.py::ImportedEvent`（frozen dataclass）。

- `kind`: `medication` / `activity` / `symptom_or_note` / `environment` /
  `measurement` / `menstrual` / `error_or_missing` の7種を区別。
- `timestamp`: timezone-aware datetimeのみ許容。確定できない場合は`None`
  （オフセット不明のISO文字列は補完せずNoneのまま、`timestamp_raw`に原文を保持）。
- `calendar_date` / `operational_date`: 深夜0時境界と午前4時起点の運用日を
  別々に保持（`compute_calendar_and_operational_dates`）。混同していない。
- `has_location` + 別型`LocationRecord`: 緯度経度等の生位置情報は
  `ImportedEvent`本体にも`extras`にも入らない（`__post_init__`でバリデーション）。
  位置情報が必要な場合は`ImportResult.locations`を別途参照する。
- `extras["raw_payload"]`: 分類・値抽出に使わなかった未知フィールドを含む
  元レコード全体（位置情報キーのみ除く）を保持。実データのキー名が
  今回の推測と違っていた場合も、後から再分類できる。
- `merge_event_streams()`: 複数importerの出力を時刻順の1本のタイムラインへ
  結合（timestamp未確定のイベントは末尾）。永続化はしない（純粋関数）。

DB永続化（新規テーブル/リポジトリ）は今回のスコープに含めなかった
（完了条件1〜8に明記なし、次タスク候補として下記に記載）。

## 2形式それぞれの読込結果

**実データは見つからなかったため、人工fixtureでの動作確認のみ。** 探索は
`local_data/` → `Downloads` → `Desktop` → `Documents`（いずれも直下のみ、
広範囲スキャンはしていない）で `health_log.jsonl` /
`cortisol_hp_backup_20260806.json` を探したが、このマシン上には存在しなかった。

- HealthEnvLogger: 実データのフィールド名は未確認のため、複数の妥当な
  キー名候補を試す寛容な分類ロジックにした（`_classify_kind`）。
  人工fixture（11行、7種すべて+位置情報混在+epoch ms+オフセット不明+
  分類不能ケースを含む）で7種すべての判定・位置情報の分離・不正JSON行の
  スキップ（他行を止めない）を確認済み。
- Cortisol HP: 構造が明記されていたため実装の確度は高い。`doses[]`→
  medication、`memos[]`+`history[]`→symptom_or_note、`main`のスナップショット
  （hp/doneToday/spentToday/basalConsumed/depletionMs）→measurement
  （`exportedAt`時点の値として各1件）。`format`/`version`不一致時も処理を
  止めず`error_or_missing`イベントとして可視化する設計にした。

## `main.tasks[]` / `main.counts[]` について（判断が必要）

この2つは個別の発生時刻を持たない（`tasks`はコスト表のようなカタログ、
`counts`は構造不明のカウンタ）ため、今回はタイムラインイベント化していない
（意図的な除外、取りこぼしではない）。実ファイルが手に入った時点で
実際の中身を見て、どう扱うか（別カタログ扱いのまま/一部を集計値として
measurement化する等）を判断する必要がある。

## locationの扱い

`ImportedEvent`は`has_location`フラグのみ保持し、実際の緯度経度等は
`ImportResult.locations`（`LocationRecord`のタプル、`event_id`で紐づけ）に
分離される。`extras`へ緯度経度キーが混入した場合は`ImportedEvent`の
バリデーションで例外になる（テストで確認済み）。

## 未実装・曖昧な点

1. **実ファイル未接続**（最大の未完了点）。人工fixtureでの動作確認までは
   完了しているが、実データでの動作は未検証。
2. HealthEnvLoggerのキー名は推測。実ファイルが見つかり次第、
   `_TIMESTAMP_KEYS`/`_KIND_ALIASES`等を実データに合わせて調整が必要
   （`raw_payload`は保持済みのため再分類は可能）。
3. `main.tasks[]`/`main.counts[]`の扱いは未判断（上記参照）。
4. SQLiteへの永続化・リポジトリ層は未着手（完了条件外だったため）。
5. Cortisol HPの`doses[].time`が時刻のみ（日付なし）等の形式だった場合、
   `parse_flexible_timestamp`は解釈できず`timestamp=None`/`partial`になる
   （補完しない設計はそのまま維持、テストで確認済み）。

## 次の1タスク候補

実ファイル（`health_log.jsonl` / `cortisol_hp_backup_20260806.json`）を
`ResidualCapacityWorkbench/local_data/`（新設、.gitignore済み）へケイが
直接配置したうえで、実データに対して今回のimporterを実行し、
（a）キー名推測のズレ修正、（b）`tasks[]`/`counts[]`の扱い判断、
（c）必要ならSQLite永続化層の追加、を行うNode。

## commit SHA

`a6a34c28f74fa9380aae6e90b7cef96bb7ac0574`（RCW Privateリポジトリ、
`origin/main`へpush済み）

## ケイへ確認が必要か

不要（欠月Handoffで「途中確認は不要、判断が必要な事項だけ欠月へ返す」と
指定済み。実ファイル所在も、ケイに探させず本Handoffへ「未接続」とだけ返す
運用どおりにした）。

## 状態

完了・引継ぎ（欠月へ）。実ファイル接続とtasks/counts判断のみ次Node持ち越し。
