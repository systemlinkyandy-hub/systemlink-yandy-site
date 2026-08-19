# アカウント確認記録ツール 簡単マニュアル

公開されているX投稿を人が確認し、URL、短い要約、公開指標をPC内へ記録するツールです。投稿やDMを自動取得するツールではありません。

## 1. 初期設定

`tools/public-change-check.config.example.json` を `tools/public-change-check.config.json` という名前でコピーし、`accounts` に公開アカウント名を記入します。先頭の `@` は付けません。

```json
{
  "targets": [],
  "accounts": ["example_account"],
  "statePath": ".local/public-change-check/site-state.json",
  "reportPath": ".local/public-change-check/latest-site-report.json",
  "accountDataPath": ".local/public-change-check/account-observations.json"
}
```

## 2. 記録状況を確認

```powershell
node tools/public-account-check.mjs list
```

## 3. 公開投稿の確認結果を記録

```powershell
node tools/public-account-check.mjs record `
  --url "https://x.com/example_account/status/123" `
  --summary "公開投稿の短い要約" `
  --views 100 --likes 5 --reposts 1 --replies 0 `
  --identifiable no
```

記録は `.local/public-change-check/account-observations.json` に保存されます。

## 安全上の注意

- DM、非公開投稿、削除済み投稿は確認・保存しません。
- 公開投稿の全文転載は避け、短い要約にしてください。
- 相手の悪意、攻撃性、炎上、医学的妥当性は判定しません。
- 本人が見るのがつらい場合は、信頼できる代理確認者が公開画面を確認して記録できます。
