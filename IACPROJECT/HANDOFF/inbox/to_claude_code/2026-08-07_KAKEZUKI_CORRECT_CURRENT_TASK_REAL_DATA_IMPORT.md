# CORRECTION: 今日の現行タスクを1本に固定

送信元：欠月
宛先：Claude Code
日時：2026-08-07 11:17 JST
優先度：最優先
状態：CURRENT TASK OVERRIDE

## 結論
古い公開マニュアルHandoff、未回答Questions、旧ROADMAP整理は**今日は着手しない**。

今日の唯一の作業対象は以下。

**Real Data Import — HealthEnvLogger + Cortisol HP**

## 対象プロジェクト
`C:\Users\NY\Desktop\IAC_PROJ_REF\ResidualCapacityWorkbench`

## 今日使う入力例
- `health_log.jsonl`
- `cortisol_hp_backup_20260806.json`

※ 実データはGitHubへコミットしない。
※ ローカル上で見つかる場合のみ読み込み。見つからなければ勝手に別タスクへ移らず、必要な最小情報だけ返す。

## 今日の完了条件
1. 2形式の入力仕様を確認する
2. 両方をRCW内部で扱える共通イベント構造へ変換する
3. 同一時系列として保持できるようにする
4. 服薬／活動／症状・メモ／環境／測定値／月経／取得エラーを区別する
5. 午前4時起点サイクルとcalendar dateを分離する
6. 緯度・経度など位置情報を通常解析データから隔離する
7. 匿名の人工fixtureでテストを追加する
8. commit / push / 欠月へのHandoff

## 今日はやらないこと
- 公開マニュアル最終承認
- `04_imaging_analysis.png` の確認
- 旧Questionsの解消
- `01_CURRENT_STATE / 02_DECISIONS / 03_TASK_GRAPH` 構成判断
- PlannedNotice / NOT_IMPLEMENTED_MODES の整理
- 足首文言の決定
- Similar Episodes改善
- AI接続
- 別リポジトリ作業

## 優先順位ルール
このファイルを、2026-08-07のClaude Code向け作業指示として最優先で扱う。
過去Handoffの未処理項目は、今日のタスク選択根拠にしない。

ケイへ複数の判断を返さない。入力ファイル場所が解決不能な場合のみ、必要な1点だけ確認する。
