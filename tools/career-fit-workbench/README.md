# Career Fit Workbench v0.1

求人票のスクリーンショットを投入するだけで、抽出・条件照合・田中形式評価・保存までを行うローカルWebアプリ。
仕様書：`IACPROJECT` 経由でケイから受領した「Career Fit Workbench v0.1」Handoff。

外部公開はv0.1では行わない。ミニPC上でのみ動作する（HttpListenerは `http://localhost:<port>/` にのみ束縛）。

## 起動方法

```
tools\career-fit-workbench\launch.cmd
```

既定ポートは `8799`。変更する場合：

```
tools\career-fit-workbench\launch.cmd -Port 8800
```

起動後、ブラウザで `http://localhost:8799/` を開く。

## 前提：GEMINI_API_KEY

求人スクリーンショットの解析（抽出＋評価）は Gemini Vision API（`gemini-3.6-flash`、既存の
Gemini Bridgeと同じ既定モデル）を1求人あたり1回呼び出す。環境変数 `GEMINI_API_KEY` が必要
（`tools/iac-gemini-bridge*` と同じ変数を共有する。リポジトリ・ログへの直書き禁止）。

未設定でもサーバ自体は起動するが、「求人を追加」タブでの解析はエラーになる。

モデルを変更したい場合は `GEMINI_CAREER_FIT_MODEL` で上書き可能。

## データの扱い

- 求人の抽出結果・スクリーンショット由来のデータは `tools/career-fit-workbench/data/jobs.json`
  にのみ保存する（`.gitignore` 済み、GitHubへはコミットしない — 実データ非コミット原則）。
- スクリーンショット画像そのものはブラウザ→サーバ間のAPI呼び出しにのみ使用し、解析後は保存しない
  （抽出結果のテキストのみ保持する）。

## 構成

- `server.ps1` — HttpListenerベースのローカルHTTPサーバ（静的配信 + `/api/*`）
- `lib/career-fit-gemini.ps1` — 抽出・評価プロンプトとGemini Vision呼び出し
- `lib/career-fit-store.ps1` — `data/jobs.json` への読み書き・重複検出・status更新
- `www/` — フロントエンド（依存ライブラリなしのHTML/CSS/JS）
- `selftest.ps1` — ネットワーク不要なロジック（重複検出・status更新・JSON保存）のセルフテスト

## API

| Method | Path | 内容 |
|---|---|---|
| POST | `/api/analyze` | `{ images: [dataUrl,...] }` → Gemini Visionで抽出・評価したJSONを返す（未保存） |
| POST | `/api/jobs` | 解析結果を保存。会社名＋求人タイトル完全一致で重複検出し `duplicateOf` を付与 |
| GET | `/api/jobs` | 保存済み求人一覧 |
| PATCH | `/api/jobs/{id}` | `{ status }` のみ更新（未判定/A/B/C/見送り/応募候補/応募済/保留） |

## v0.1でやらないこと（仕様書どおり）

LinkedIn自動ログイン・自動巡回・自動応募・採用担当者への自動DM・求人サイトのスクレイピング・
企業評判の自動Web調査・市場給与調査・履歴書自動送信・面接スケジュール管理。
