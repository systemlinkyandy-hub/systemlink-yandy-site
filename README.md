# SystemLink YandY 静的サイト退避

このリポジトリは、Manusで公開している **SystemLink YandY** の静的サイトを、外部ストレージに依存せず単独で保存・表示できる形にした退避用コピーです。掲載内容、日付、版数、文言、デザインは、保存元の公開チェックポイント `df0556e5` から変更していません。

| 項目 | 内容 |
|---|---|
| 保存元 | Manus公開チェックポイント `df0556e5` |
| ページ | `index.html`、`privacy.html`、`operator.html` |
| スタイル | `index.css` |
| スクリプト | `main.js` |
| 画像 | `assets/` 内に3点 |
| フォント | `fonts/` 内にIBM Plex SansおよびNoto Sans JP |
| フォントライセンス | `licenses/` |

表示確認は、リポジトリのルートで任意の静的HTTPサーバーを起動して行えます。たとえばPythonが利用できる環境では `python3 -m http.server 8000` を実行し、ブラウザで `http://localhost:8000/` を開きます。

この移行では、Manusストレージ画像参照、Google Fonts CDN参照、Manusのアクセス解析参照をローカルファイルへ置換または除去しています。メールリンクは通常の `mailto:` リンクとして維持しています。
