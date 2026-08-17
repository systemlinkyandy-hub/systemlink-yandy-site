# cocolifestyle 公開差分チェッカー

公開サイトの変更候補を機械的に検出し、人物評価や医療判断から分離して記録するための小さなツールです。ログイン情報、DM、個人の診療記録は取得しません。

## できること

- `cocolifestyle.net` の主要4ページを取得する。
- 前回確認時の内容ハッシュと比較し、`baseline` / `unchanged` / `changed` / `error` を表示する。
- 結果を `research/cocolifestyle/monitor/latest-site-check.json` に保存する。

## できないこと

- 変更内容の医学的な正しさ、悪意、攻撃性、炎上を自動判定すること。
- 非公開、削除済み、ログイン時限定の投稿を確認すること。
- Xの投稿を安定して自動取得すること。Xは公開画面を人が確認し、URL・確認時刻・表示数等だけを記録してください。

## 使い方

リポジトリ直下で実行します。

```powershell
node tools/cocolifestyle-site-check.mjs
```

初回は比較元がないため `baseline` になります。2回目以降、内容ハッシュが変わったページだけ `changed` と表示されます。

### 公開アカウントの確認状況を見る

```powershell
node tools/cocolifestyle-account-check.mjs list
```

`@stay_sparkle` と `@AIstudylog` の最新記録日時と公開URLを表示します。Xへログインしたり、DMを取得したりはしません。

### 公開投稿の確認結果を追記する

```powershell
node tools/cocolifestyle-account-check.mjs record `
  --url "https://x.com/stay_sparkle/status/投稿ID" `
  --summary "投稿内容の短い要約" `
  --views 100 --likes 5 --reposts 1 --replies 0 `
  --identifiable no
```

同じアカウントの前回記録があれば、表示数・いいね・リポスト・公開返信数の差分を表示します。`--identifiable` は、第三者が特定人物を識別できる公開情報がある場合だけ `yes` にします。

自己テスト：

```powershell
node tools/cocolifestyle-account-check.mjs selftest
```

## 人による確認手順

1. `changed` のURLだけを開く。
2. 追加・削除・言い換えられた主張を短く記録する。本文を大量転載しない。
3. 公開上の個人特定言及は、氏名・ハンドル・リンク・固有の経歴など、第三者が同一人物と識別できる情報がある場合だけ「あり」とする。
4. 表示数、返信、リポスト、いいねは確認時刻と一緒に記録する。
5. 「悪意」「敵意」「炎上」は自動判定せず、確認できた言葉と数値を残す。
6. 医学的主張は `cocolifestyle-reference/data/claims.json` の4分類と原典照合を通してから反映する。

## 保存場所

- 機械チェック結果：`research/cocolifestyle/monitor/latest-site-check.json`
- ローカル比較状態：`research/cocolifestyle/monitor/.site-check-state.json`（Git管理外）
- 公開アカウントの手動確認結果：`cocolifestyle-reference/data/public-monitor.json`
- 閲覧ページ：`cocolifestyle-reference/pages/monitor.html`

## 安全上の注意

- DM、医療記録、住所、名刺、電話番号などをコミットしないでください。
- 公開投稿でも必要以上の全文転載は避け、URL、要約、確認時刻、公開指標を中心に記録してください。
- 緊急の身体症状や薬の調整は、このツールではなく主治医・救急対応の指示を優先してください。
