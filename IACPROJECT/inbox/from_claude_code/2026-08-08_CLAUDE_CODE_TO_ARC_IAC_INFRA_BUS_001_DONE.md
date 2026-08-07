# Handoff: IAC-INFRA-BUS-001 実装完了報告

送信元：Claude Code
宛先：アーク（CC：ケイ／欠月）
日時：2026-08-08 JST
Task ID：IAC-INFRA-BUS-001

---

## モデルに関する注記

指示書は「モデル：Claude Fable 5 を明示選択すること」となっていたが、実際にこのタスクを
実行したのは Claude Sonnet 5（このセッションのモデル）である。モデル選択はこちらから
制御できないため、実行者が指示と異なっている点をここで明示する。内容面での判断が
必要であれば、あらためて確認してほしい。

## 実装先パスの変更（重要）

Facts記載の `C:\IAC_Project` は、実際にはケイの別プロジェクト（HealthEnvLogger 解析ツール、
Gitリポジトリではない）がすでに使用しているフォルダだった。`systemlinkyandy-hub/systemlink-yandy-site`
とは無関係。ケイに確認のうえ、新規に `C:\IAC_Handoff` を作成し、そこへ本リポジトリを
`git clone` して実装した。

- 実装先：`C:\IAC_Handoff`（`.git` あり、origin = `systemlinkyandy-hub/systemlink-yandy-site`）
- ツール本体：`C:\IAC_Handoff\tools\iac-deliver.ps1`
- 起動短縮形：`C:\IAC_Handoff\tools\iac-deliver.cmd`、および Windows PowerShellプロファイルに
  `iac-deliver` 関数を追加済み（PowerShellを開けば `iac-deliver` の1語で実行可能）
- staging：`C:\IAC_Handoff\staging\`（リポジトリ非追跡。`.gitignore` に追加済み）
- Gmail取り込み手順書：`C:\IAC_Handoff\tools\README_GMAIL_TO_STAGING.md`

## 実構造との相違点

Facts記載のパスと実構造には以下の相違があった。実構造を優先して実装した。

- `IACPROJECT/HANDOFF/inbox/from_*` ではなく、実際は `IACPROJECT/inbox/from_*`（HANDOFF配下ではない）
- `IACPROJECT/HANDOFF/inbox/to_*` という別系統（TO別）のinboxも存在するが、今回の配送先には使用していない
- 既存の `inbox/from_*` フォルダ（arc, chatgpt, claude, claude_code, gemini, grok, tsuzuri, uehara）を
  そのままFROM別振り分け先として使用した

## 処理2（Router / CURRENT_PENDING 自動更新）を実装しなかった理由

`CURRENT_DELIVERIES.md` と `CURRENT_PENDING.md` は、単純な1行追記ではなく、
DELIVERY-ID・状態遷移・メンバー別pendingカウントなどを含む手動運用前提の
構造化フォーマットだった。誤った自動更新はpendingカウントの不整合や
状態の誤登録につながるリスクが高いと判断し、指示書の縮小フォールバック規定
（「処理2を丸ごと捨てて、処理1＋3＋4のみで完成とする」）を適用した。

**この2ファイルへの自動書き込みは一切行っていない。** Router/Pendingへの反映は
引き続きアークの手動運用に委ねる。

## 実装した処理（1・3・4・5）

1. ファイル名 `YYYY-MM-DD_<FROM>[_<FROM2>]_...` からFROMを判定し、
   `inbox/from_<from>/` へ配置。判定できない場合は `inbox/unsorted/` へ配置して続行する。
   - Claude / Claude Code のような2語FROM名も正しく区別する（後述の不具合修正済み）。
3. 配送ファイルごとに `git add` → `git commit -m "deliver: <ファイル名>"`（ファイル単位でコミットを分離）。
   全件処理後に1回 `git push`。失敗時は `git pull --rebase` を1回試行して再push。
   それでも失敗したらローカルを壊さず停止し、エラー内容と次の1手を表示する。
4. push成功時のみ、stagingの元ファイルを `staging\delivered\` へ移動する（push失敗時はstagingに残し、
   次回実行で自動的に再送される＝再コミットではなくpushの再試行になる）。
5. 実行結果（配送N件／失敗M件、配置先一覧、commit hash）を表示する。

## 実装中に見つけて修正した不具合（開発時のみ発生。最終成果物には影響なし）

- Windows PowerShell 5.1 で `2>&1` によりgitの警告出力（LF/CRLF警告等）がErrorRecord化し、
  `$ErrorActionPreference = 'Stop'` の影響で正常終了のはずのgit操作が例外扱いされていた。
  → git呼び出し中のみ `ErrorActionPreference = 'Continue'` に変更して解消。
- `git commit` にパススペックを指定していなかったため、1ファイル分のつもりが
  ステージ済みの他ファイルまで巻き込んで1コミットにまとまってしまっていた。
  → `git commit -m ... -- <対象ファイル>` に修正し、ファイル単位のコミットに分離。
- FROM判定が1語目だけを見ていたため `CLAUDE_CODE_TO_ARC_...` が `claude`（別人格）に
  誤分類されるおそれがあった。→ 2語結合を先に試し、一致すればそちらを優先するよう修正。
- スクリプトファイルにUTF-8 BOMが無く、Windows PowerShell 5.1が既定コードページで
  誤読してパースエラーになっていた。→ BOM付きUTF-8で保存し直して解消。

上記はすべて受け入れテスト中に発見し、テスト内で修正・再検証済み。

## 受け入れテスト結果（すべてClaude Codeが実際に実行）

- [x] staging に正常名2件・規約外名1件の計3件を置いて `iac-deliver` を引数なし実行
      → 正常2件がそれぞれ `inbox/from_claude/`・`inbox/from_grok/` へ、規約外1件が
      `inbox/unsorted/` へ配送され、全件 `staging\delivered\` へ退避されることを確認。
- [x] staging が空の状態で実行 → `配送対象なし` で正常終了（exit 0）することを確認。
- [x] Router / Pending への追記が無いこと → そもそも自動更新を実装していないため、
      両ファイルへの差分はゼロ（`git diff` で確認済み）。
- [x] push失敗時の挙動 → 一時的にoriginを存在しないリポジトリへ向けてpushを失敗させ、
      ローカルのcommitとstagingのファイルが壊れず残ることを確認。origin復旧後に
      再実行し、重複コミットなしで正常にpush・退避まで完了することを確認（idempotent retry）。
- [x]（追加確認）Claude / Claude Code の2語FROM名誤分類バグの修正を、専用テストで再確認。

テストに使用した計5件のファイルは、配送・push後にすべて `IACPROJECT/inbox/` から
revertまたは削除コミットで除去済み（本文書提出時点で本番コンテンツへの残留なし）。

## Questions queue

なし。

## Update target

None（正本反映はアークが行う）。

---

**Copyright: ケイ**
