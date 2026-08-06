# HANDOFF: Residual Capacity Workbench ローカル作業ディレクトリ確認 完了報告

送信元：Claude Code
宛先：欠月
対象タスク：ケイ指示によるResidual Capacity Workbenchのローカル作業ディレクトリ特定（コード変更なし・調査のみ）
日付：2026-08-06
状態：COMPLETE_RETURN_TO_KETSUGETSU

---

## 1. 対象プロジェクト

Residual Capacity Workbench（RCW）

## 2. 現在の目的

ケイが以前使用していたパス `C:\Users\NY\Desktop\ResidualCapacityWorkbench` が現存しなくなったため、PC内を検索し、現在の実体ある作業ディレクトリを特定する。コード変更・Git初期化・新規作成は行わない前提での調査タスク。

## 3. 完了したこと

PC全体を検索し、`ResidualCapacityWorkbench` を含むフォルダを洗い出した結果、実体のあるコードベースは以下1件のみだった。

### 現在の作業パス
`C:\Users\NY\Desktop\IAC_PROJ_REF\ResidualCapacityWorkbench`

### 確認結果

| 項目 | 内容 |
|---|---|
| 最終更新日時 | `body_systems.sqlite3` が最新（2026-08-06頃）。ドキュメント類は2026-08-03が最終 |
| Git管理の有無 | **なし**（`.git` フォルダが存在せず、Git未初期化。`git status` は "not a git repository" を返す） |
| Git remote | 該当なし |
| 現在のブランチ | 該当なし |
| 主要ファイル | `README.md`（あり）、`CLAUDE.md`、`app/`、`tests/`、`docs/manual/`（あり）、`docs/design/`（**なし**）、`body_systems.sqlite3` |
| Similar Episodes関連ファイル | `app/widgets/body_systems/similar_episodes_panel.py`（存在確認済み） |

他に見つかった候補（`Desktop\ResidualCapacityWorkbench_Public_Manual_Release_2026-08-03\` 配下）はマニュアル配布用ZIPの展開物のみで、コード本体・README・.gitを含まないため対象外と判断した。

旧パス `Desktop\ResidualCapacityWorkbench`（`.claude`キャッシュ名にのみ痕跡あり）は現存しない。

## 4. 未完了のこと／要判断（正本判断が必要な点）

1. **RCW本体がGit管理下にない。** 実装・修正作業を継続するなら、いずれ `git init` とリモート接続が必要になる。実施の要否・タイミングは欠月の正本判断に委ねる。
2. **`docs/design/` が存在しない。** `docs/manual/`（公開マニュアル）はあるが設計文書用ディレクトリはない。新設するか、既存の `docs/ARCHITECTURE.md` 等（`DATA_MODEL.md`、`UI_SPEC.md`、`BODY_SYSTEMS_SPEC.md` など個別ファイルとして既に存在）で代替とみなすかの判断が必要。

いずれも実装作業は不要で、**方針判断のみ**。Claude Codeからは提案しない（CLAUDE.md記載のスコープ外）。

## 5. 次に必要な作業

- 欠月が上記2点について方針を判断する。
- Git初期化・リモート接続が必要と判断された場合、実行はClaude Codeが担当する（実装・Git操作はClaude Codeの担当範囲）。

## 6. 次の主担当候補

欠月（正本判断）→ 必要なら実行はClaude Codeへ差し戻し

## 7. 使用する正本・素材・URL

- 対象ディレクトリ：`C:\Users\NY\Desktop\IAC_PROJ_REF\ResidualCapacityWorkbench`
- 参照した既存ドキュメント：`README.md`、`CLAUDE.md`、`docs/manual/ResidualCapacityWorkbench_Public_Manual_2026-08-03.md`

## 8. ケイへ確認が必要か

現時点では不要。欠月の判断後、Git初期化等の実行前にケイへの確認が必要になる可能性あり。

## 9. 状態

完了・引継ぎ（欠月へ）
