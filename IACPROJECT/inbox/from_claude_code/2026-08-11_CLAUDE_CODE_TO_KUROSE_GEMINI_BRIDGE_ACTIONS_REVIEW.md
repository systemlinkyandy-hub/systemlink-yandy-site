# HANDOFF

## From / To

From: 佐藤（Claude Code）
To: 黒瀬（Claude）
CC: ケイ

## Task ID

IAC-GEMINI-BRIDGE-001-ACTIONS-2026-08-11

## Date

2026-08-11

## 背景

黒瀬から「Gemini Bridgeのトリガーをローカル手動実行からGitHub Actionsへ移す」要件（ケイ経由で受領）。
要点：
- スマホから`inbox/from_*`へGitHub Pushするだけで完結させる
- 既存Bridge（冪等性・誤配送防止・コスト上限・宛先ヘッダ必須化）のロジックは流用し、トリガーだけ変更
- 実行環境がSurface/PCからActionsのクラウド環境に変わるため `GEMINI_API_KEY` をGitHub Secretsへ登録し直す必要がある
- コスト上限監視の状態ファイルの永続化設計が要る（Actions環境は使い捨てのため）

この2点（Secrets移行・状態永続化）が要件上の主な論点として佐藤へ投げられた。

## 実装内容

1. **`.github/workflows/gemini-bridge.yml`（新規）**
   `push`イベント、対象パス`IACPROJECT/inbox/from_arc/**`・`IACPROJECT/inbox/from_gemini/**`のみを
   監視（`GEMINI_BRIDGE_TOOLING.md` §3の監視対象と一致。他の`from_*`はBridge内部ロジックで対象外に
   なるため監視しない）。windows-latest runner上で`iac-gemini-bridge.ps1 run -Push`を実行。
   `concurrency: group gemini-bridge, cancel-in-progress: false`で同時実行を直列化。

2. **`tools/iac-gemini-bridge.ps1`に`-Push`スイッチを追加**
   commit後に`git push`まで行う。失敗時は`pull --rebase`→再pushを1回試行し、それでも失敗したら
   `throw`でジョブを失敗させる（Actions環境は使い捨てのため、pushできなければローカルcommitは失われる
   ことを明示する目的）。**ローカル運用は従来通り無指定＝commitのみ**で、`-Push`はActions実行時のみ使う
   切り分け。既存selftest（33件）は本変更後も全件成功、既存ロジックへの影響なし。

3. **状態永続化について（要件で論点に挙がっていたが、調査の結果すでに解決済みだった）**
   `GEMINI_BRIDGE_STATE.md`・`GEMINI_BRIDGE_COST_LOG.md`は元々`IACPROJECT/ROUTER/`配下のリポジトリ
   管理ファイル（`.gitignore`対象外）で、Bridge自身がcommitする設計になっている。Actions環境が使い捨て
   でも、commit後に`push`するだけでリポジトリ側に状態が残る。新規の永続化機構は不要と判断し、上記の
   `-Push`追加のみで対応した。

4. **`GEMINI_BRIDGE_TOOLING.md` §13に今回の設計判断・未検証事項を追記**（正本更新）

## ケイ側でのみ実施可能な残作業（実装スコープ外）

- リポジトリ Settings → Secrets and variables → Actions で `GEMINI_API_KEY` を新規登録
  （Windows環境変数の値はActions環境から参照できないため、Secretsへの登録が別途必要）
- リポジトリ Settings → Actions → General → Workflow permissions を「Read and write
  permissions」に変更（`-Push`での`git push`に必要。既定は読み取り専用でpush権限エラーになる）

両方揃うまでworkflowはpushされても`FAILED_NO_API_KEY`または権限エラーで失敗する（実害なし、
実データの誤送信は起きない）。

## 未検証（要相談）

- **Actions runner上での実行そのものが未検証**：windows-latest runnerでの`pwsh`実行・`checkout`・
  `push`は、ローカルのselftest（人工fixture・モックAPIのみ）の範囲外。Secrets登録・Workflow
  permissions変更後、実際に`from_arc`へテストHandoffをpushして一往復確認する必要がある
  （2026-08-10の実APIライブテストと同様の手順を、Actions環境で再実施するイメージ）。
- 無限ループの懸念は検討済み：GITHUB_TOKENによるpushはデフォルトで新たなworkflow runを
  トリガーしないため、`from_gemini/`への応答保存commit&pushが自己再帰する事態にはならない
  （ただしActions実行そのものでの確認はできていない）。
- 前回報告済み・未解決の不具合2（複数宛先Handoffの誤爆、`staging/delivered/2026-08-10_
  CLAUDE_CODE_TO_KUROSE_GEMINI_BRIDGE_LIVE_TEST_REPORT.md`参照）は今回のスコープに含めていない。
  Actions化でトリガー頻度が上がる（スマホからのPush一つで即実行）ため、この不具合が残ったままだと
  誤爆の再現機会も増える点は留意されたい。

## Required next action

1. 黒瀬：今回のActions化設計（トリガー範囲・`-Push`の切り分け・状態永続化の扱い）がレビュー要件の
   範囲内か確認
2. ケイ：Secrets登録・Workflow permissions変更を実施
3. 上記2点が揃い次第、佐藤がActions環境での実疎通テストを実施し報告
4. 未解決の複数宛先誤爆（不具合2）をActions化前に対応するか、現状のまま様子見するか、黒瀬・ケイで判断

## Status

コード実装完了・selftest全件成功（33/33）。Actions環境での実行は未検証（Secrets未登録のため）。
