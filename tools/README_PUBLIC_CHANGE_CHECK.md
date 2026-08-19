# 公開差分チェッカー（一般配布版）

公開サイトの変更候補と、公開SNS投稿の確認結果を、人物評価や医療判断から分離して記録するための汎用ツールです。特定の疾患、サイト、アカウントには依存しません。

個別の手順は、次の簡単マニュアルでも確認できます。

- `tools/README_PUBLIC_SITE_CHANGE_CHECK.md`
- `tools/README_PUBLIC_ACCOUNT_CHECK.md`

## 初期設定

`tools/public-change-check.config.example.json` を `tools/public-change-check.config.json` へコピーし、自分が確認する公開URLと公開アカウント名を設定します。実際の設定ファイルはGit管理されません。

## 公開サイトの差分確認

```powershell
node tools/public-site-change-check.mjs
```

初回は `baseline`、2回目以降は `unchanged` または `changed` と表示されます。変更の意味や正しさは自動判定しません。

## 公開アカウントの記録

記録状況：

```powershell
node tools/public-account-check.mjs list
```

公開投稿の確認結果を追加：

```powershell
node tools/public-account-check.mjs record `
  --url "https://x.com/example_account/status/123" `
  --summary "公開投稿の短い要約" `
  --views 100 --likes 5 --reposts 1 --replies 0 `
  --identifiable no
```

## プライバシーと限界

- ログイン情報、DM、診療記録、住所、名刺、電話番号は取得・保存しません。
- Xの投稿本文は安定して自動取得できないため、公開画面を人が確認して記録します。
- 非公開、削除済み、ログイン時限定の投稿は確認できません。
- 悪意、攻撃性、炎上、医学的妥当性を自動判定しません。
- 公開情報でも全文転載を避け、URL、短い要約、確認時刻、公開指標を中心に記録してください。
