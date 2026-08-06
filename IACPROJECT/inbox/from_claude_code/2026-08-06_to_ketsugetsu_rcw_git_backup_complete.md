# HANDOFF: Residual Capacity Workbench 初回Private Git保全 完了報告

送信元：Claude Code
宛先：欠月
対象タスク：RCWコードベースのGit未管理状態を解消し、非公開GitHubリポジトリへ初回保存する（ケイ指示、本日最優先タスク）
日付：2026-08-06
状態：COMPLETE_RETURN_TO_KETSUGETSU

---

## 1. 対象プロジェクト

Residual Capacity Workbench（RCW）ローカルコードベースのGit保全

## 2. 現在の目的

`C:\Users\NY\Desktop\IAC_PROJ_REF\ResidualCapacityWorkbench` がGit未管理だったため、削除・上書き事故から復旧可能な状態にする。非公開GitHubリポジトリへの初回バックアップ。

## 3. 完了したこと

対象パス：`C:\Users\NY\Desktop\IAC_PROJ_REF\ResidualCapacityWorkbench`
作成したリポジトリ：`https://github.com/systemlinkyandy-hub/ResidualCapacityWorkbench`
Visibility：**Private**（API応答で `"private": true, "visibility": "private"` を確認済み）
除外した機密・ローカルデータ：
- `body_systems.sqlite3`（内容未確認のまま無条件除外。以前から`.gitignore`済みだったものを維持・強化）
- `.claude/`（`settings.local.json` にローカル絶対パス `C:\Users\NY\...` を含むため全体除外）
- `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12`, `*.crt`
- `__pycache__/`, `*.pyc`, `.pytest_cache/`, `.mypy_cache/`, `.ruff_cache/`
- `.venv/` ほか仮想環境ディレクトリ
- ログファイル（`*.log`, `_stdout.log`, `_stderr.log`）、一時ファイル、OS/IDEキャッシュ、`nul`（0バイトの誤生成ファイル）

事前調査で以下を確認：APIキー・トークン・パスワード・`.env`・秘密鍵・実患者データ・ケイ本人の未匿名化ログは**検出されなかった**。`docs/manual/`配下のスクリーンショットは既存の公開マニュアル審査（2026-08-03付）で架空データ（Sample Subject）と確認済みのものを再利用。トップレベル`screenshots/rcw_showcase_2026-08-01.png`も目視確認済みでDEMO DATA表示のみ、実データなし。

初回コミットSHA：`9902a75b32679f372fbbcffd57c545eb193b2c54`
remote：`origin` → `https://github.com/systemlinkyandy-hub/ResidualCapacityWorkbench.git`
branch：`main`（デフォルトブランチもmain）
push結果：成功（`main -> main`, 追跡設定済み）
ローカルとremoteのHEAD一致：**一致**（両者とも `9902a75b32679f372fbbcffd57c545eb193b2c54`）
問題点：なし
状態：完了

## 4. 未完了のこと

なし（本タスクの完了条件はすべて満たした）。

## 5. 次に必要な作業

特になし。以後の変更は通常の実装フローでコミット・pushを継続する。

## 6. 次の主担当候補

なし（正本判断が必要な事項が生じた場合のみ欠月）

## 7. 使用する正本・素材・URL

- 対象ディレクトリ：`C:\Users\NY\Desktop\IAC_PROJ_REF\ResidualCapacityWorkbench`（そのまま存置、移動・削除なし）
- 新規リポジトリ：`https://github.com/systemlinkyandy-hub/ResidualCapacityWorkbench`（Private）

## 8. ケイへ確認が必要か

不要（ケイより事前に確認不要の指示あり）。

## 9. 状態

完了・引継ぎ（欠月へ）
