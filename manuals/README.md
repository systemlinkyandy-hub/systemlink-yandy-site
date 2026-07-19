# PDFマニュアルの配置と更新

SystemLink YandYの公開用PDFマニュアルは、この `manuals/` ディレクトリで管理します。トップページのアプリ紹介カードは、次の固定ファイル名を参照しています。ファイル名を変更するとリンク切れになるため、更新時も同じ名前を維持してください。

| 対象アプリ | 配置ファイル | トップページからの相対リンク |
|---|---|---|
| 残コルチゾールHP | `cortisol_hp_manual_v0_1.pdf` | `manuals/cortisol_hp_manual_v0_1.pdf` |
| 体調環境ログ | `HealthEnvLogger_manual_v2.pdf` | `manuals/HealthEnvLogger_manual_v2.pdf` |

## GitHub上で差し替える手順

1. GitHubで公開リポジトリを開き、`manuals/` フォルダへ移動します。
2. 上表の対象ファイルを選び、**Replace file** を実行します。新しいPDFも**同一のASCIIファイル名**でアップロードしてください。
3. コミットメッセージに、対象アプリ名とマニュアル版数を記載してコミットします。
4. GitHub Pagesの更新完了後、トップページの「PDFマニュアルを見る」ボタンとPDFの内容を確認します。

PDFのファイル名に、日本語、空白、全角記号は使用しません。新しい版を別名で残す場合でも、トップページのリンクを変更しない限り利用者向けの導線は更新されません。

## ローカルで追加・更新する場合

リポジトリ直下で、対象PDFを上表の名前で `manuals/` へコピーし、`git status` で追加または変更を確認してからコミット・プッシュしてください。公開前には、以下を確認します。

- PDFがブラウザで開けること
- トップページのボタンが新しいタブで開くこと
- ファイル名とリンク先が完全一致していること
- PDF本文に個人情報や意図しないメタデータが含まれていないこと

## 医療・疾患資料（medical-resources.html）のPDFについて

「医療・疾患資料」ページ（`medical-resources.html`）で使うPDFは、この `manuals/` 直下ではなく `manuals/medical-resources/` サブディレクトリに格納します。対応するサムネイル画像（1ページ目を軽量JPEG化したもの）は `assets/medical-resources/thumbnails/` に置きます。

新しい資料を追加する手順は次のとおりです。管理画面は不要で、HTMLファイルへの追記のみで完結します。

1. 公開用PDFを半角英数字のファイル名にして `manuals/medical-resources/` に置く（内容・ページ順・画質は変更しない）。
2. PDF 1ページ目のサムネイルを作成し、同名で `assets/medical-resources/thumbnails/` に置く（例: `pdftoppm -jpeg -r 150 -f 1 -l 1 対象.pdf` で書き出し後、幅640px程度に縮小・圧縮）。
3. `medical-resources.html` 内の該当カテゴリにある「RESOURCE CARD TEMPLATE」ブロックをコピーし、タイトル・説明・ページ数・ファイルパスを書き換えて追記する。
4. 新しいカテゴリが必要な場合は、同ファイル内の「RESOURCE CATEGORY TEMPLATE」コメントを参照し、セクションとページ内目次（`resources-quicknav`）のリンクを追加する。

`medical-resources.html`・`medical-resources.css` は既存の `index.html` / `index.css` / `main.js` を変更せずに追加した独立ファイルです。既存のPDFマニュアル（本ファイル冒頭の表）とは配置場所を分けているため、混同しないよう注意してください。
