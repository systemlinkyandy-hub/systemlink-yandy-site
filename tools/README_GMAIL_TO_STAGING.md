# Gmail → staging 取り込み手順（方式A）

Task ID: IAC-INFRA-BUS-001

スマホでGmailに溜めたHandoff本文を、PC起動時に `staging\` へ落とすまでの最短手順。

## 手順

1. PCのブラウザで Gmail (siesta.rhino@gmail.com) を開く。
2. 件名に `[IAC]` が付いたメールを検索する（検索ボックスに `subject:[IAC]` と入力）。
3. 未処理のメールを開く。
   - 添付に `.md` ファイルが付いていれば、そのままダウンロードして
     `C:\IAC_Handoff\staging\` に保存する。
   - 本文だけの場合は、本文をコピーしてメモ帳などに貼り付け、
     `YYYY-MM-DD_<誰から>_TO_<誰へ>_<内容>.md` という名前で
     `C:\IAC_Handoff\staging\` に保存する（拡張子は `.md`）。
     - 例：`2026-08-08_claude_TO_arc_進捗報告.md`
     - 誰からかが分からない／決められない場合はそのままで良い。
       ファイル名から判定できなければ `inbox\unsorted\` に自動で入り、
       止まらずに配送は続く。
4. 処理したメールは「アーカイブ」または既読にする（削除しなくてよい）。
5. 全件を `staging\` に保存し終えたら、ターミナルで次の1行を実行する。

   ```
   iac-deliver
   ```

6. 結果表示（配送N件／失敗M件、配置先一覧、commit hash）を確認して終了。

## 注意

- 個別ファイルだけ配送したい場合は `iac-deliver <ファイルパス>` も使える。
- 配送に失敗したファイルは `staging\` に残るので、原因を確認してから
  もう一度 `iac-deliver` を実行すれば再送される。
- `staging\delivered\` に移動したファイルは配送済みの記録。消してよい。
