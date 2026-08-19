# HANDOFF

## From / To

From: 佐藤（Claude Code）
To: 田中
CC: 黒瀬（Claude）、ケイ

## Task ID

IAC-CAREER-FIT-001

## Date

2026-08-19

## 本文

ケイから直接受領した「Career Fit Workbench v0.1」仕様（求人スクリーンショット投入 → 抽出 →
条件照合 → 田中形式評価 → 保存の一気通貫フロー）について、最小動作系の実装を完了した。

`tools/career-fit-workbench/` に新規実装：

- `server.ps1` — PowerShell HttpListenerによるローカルHTTPサーバ（`http://localhost:8799/`、外部非公開）
- `lib/career-fit-gemini.ps1` — 求人画像群をGemini Vision（`gemini-3.6-flash`、既存Gemini Bridgeと
  同一既定モデル・`GEMINI_API_KEY`環境変数を共有）へ1回送信し、抽出＋田中形式評価（分類A/B/C/見送り、
  リモート度・適合度・長期継続性の★、合うところ／危ないところ最大3件、不足情報、一言判定）を
  JSONで受け取る
- `lib/career-fit-store.ps1` — `data/jobs.json`（実データ、`.gitignore`済み・GitHub非コミット）への
  永続化。会社名＋求人タイトル完全一致による重複検出（`duplicateOf`）、status更新
  （未判定/A/B/C/見送り/応募候補/応募済/保留）
- `www/` — 依存ライブラリなしのHTML/CSS/JSフロント（ドラッグ＆ドロップ投入、結果カード、一覧＋
  フィルター：Aのみ／A+B／Fully Remote／年収600万円以上／応募候補／情報不足／見送り非表示）
- `selftest.ps1` — ネットワーク不要のロジック自己テスト（重複検出・status更新・JSONパース・
  data URL変換）19/19 pass
- `launch.cmd` — 起動ラッパー（`tools\career-fit-workbench\launch.cmd`）

## 実機検証結果

ブラウザ実機（このミニPCでは `GEMINI_API_KEY` 未設定のため、Gemini実呼び出し以外の全経路）で確認：

1. UI起動・タブ切替（求人を追加 / 一覧）
2. 画像投入 → 解析ボタン活性化
3. `GEMINI_API_KEY`未設定時のエラーメッセージがUI上に正しく表示される（エラーハンドリング経路）
4. `/api/jobs` への保存・重複検出（2件目でduplicateOf付与）・一覧表示・status変更（PATCH）を
   実HTTP経由で確認（日本語データの往復も文字化けなし）
5. カード表示・バッジ・★表示・フィルターボタンの表示を確認

`GEMINI_API_KEY`が未設定のため、実際の画像解析（Gemini Vision呼び出し）は未検証。次回、鍵を
設定できる環境（Surface/Desktop、または本機に新規設定）での確認が必要。

## Required next action

1. 黒瀬：独立レビュー（境界・仕様判断の要否、実装範囲の妥当性）
2. 田中：評価軸・出力スキーマ（`lib/career-fit-gemini.ps1` の `Get-CareerFitSystemPrompt`）が
   仕様意図と一致しているか確認。ズレがあれば佐藤へ修正指示を返す
3. ケイ：`GEMINI_API_KEY`が設定できる環境で実際の求人スクショを投入し、抽出精度・評価の実用性を確認
4. 佐藤：上記フィードバックを受けて調整（v0.1の範囲内。LinkedIn自動化等の対象外機能拡張は行わない）

## Acceptance boundary

佐藤の担当は実装と技術検証まで。評価軸の妥当性・採否判断は田中、境界レビューは黒瀬、実用性の
最終判断はケイに委ねる。

## Status

最小動作系（スクショ投入 → 抽出・評価表示 → 保存 → 一覧 → status変更）完了。commit: ローカルのみ
（push未実施、ケイの確認後に実施）。
