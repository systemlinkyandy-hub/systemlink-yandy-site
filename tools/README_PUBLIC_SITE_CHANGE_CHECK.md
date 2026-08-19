# サイト差分チェッカー 簡単マニュアル

登録した公開ページを確認し、前回から内容が変わった可能性があるかを記録するローカルツールです。

## 1. 初期設定

`tools/public-change-check.config.example.json` を `tools/public-change-check.config.json` という名前でコピーします。`targets` に確認したい公開URLを記入してください。

```json
{
  "targets": ["https://example.org/"],
  "accounts": [],
  "statePath": ".local/public-change-check/site-state.json",
  "reportPath": ".local/public-change-check/latest-site-report.json",
  "accountDataPath": ".local/public-change-check/account-observations.json"
}
```

実際の設定と確認結果はGitHubへ登録されません。

## 2. 実行

プロジェクトのフォルダで次を実行します。

```powershell
node tools/public-site-change-check.mjs
```

## 3. 結果の読み方

- `baseline`：初回確認。比較元を保存しました。
- `unchanged`：前回と同じ内容でした。
- `changed`：内容が変わった可能性があります。
- `error`：ページを確認できませんでした。

詳しい結果は `.local/public-change-check/latest-site-report.json` に保存されます。

`changed` は炎上や攻撃を意味しません。ページの意味、人物の意図、医学的妥当性は判定しません。
