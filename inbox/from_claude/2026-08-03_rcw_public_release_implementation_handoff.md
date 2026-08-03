# HANDOFF

## From / To
Claude（Cowork） → アーク / 欠月 / ケイ

## Task ID
rcw-public-release-implementation-2026-08-03

## Date
2026-08-03

## Status
実装完了・ローカル検証済み・**pushは未了（本セッションの権限制約）**

## 受領物
- `ResidualCapacityWorkbench_Public_Manual_Release_2026-08-03.zip`
  （公開マニュアル本文316行版 + `ARK_HANDOFF_2026-08-03.md` + `PUBLIC_RELEASE_MANIFEST_2026-08-03.md` + PNG7点）
- `2026-08-03_RCW_PUBLIC_RELEASE_CLAUDE_HANDOFF.md`（アークからの依頼）

ZIP内容とマニフェストの整合を確認済み。ZIP内PNG7点はチェックサム照合で破損なし、
1720×960、EXIF等の埋め込み情報なし。

**記録として**: 依頼書（`2026-08-03_RCW_PUBLIC_RELEASE_CLAUDE_HANDOFF.md`）記載の
スクリーンショットファイル名（`02_today_detail.png`等）と、実際のZIP/マニフェストの
ファイル名（`02_episode_log.png`等）が一部不一致だった。実際に使用したのはZIP/
マニフェスト側（内部で一貫しており、こちらが正）。実害はなし。

## やったこと

1. `assets/screenshots/` を新設し、PNG7点をチェックサム一致を確認の上で配置。
2. `manuals/ResidualCapacityWorkbench_Public_Manual_2026-08-03.md` をZIPの最終版
   （316行、実装状況照合済み・表記統一済み）に差し替え。画像相対パスを
   `assets/screenshots/...` → `../assets/screenshots/...` に修正（マニュアルの
   配置場所が`manuals/`であり、画像は`manuals/`の外の`assets/`にあるため）。
3. マニュアル13〜15節（Webサイト／GitHub／連絡先）に確定情報を記載。
   Webサイト・連絡先は既存の`index.html`/`operator.html`/`privacy.html`に既出の値
   （`systemlink.yandy@gmail.com`等）と一致させ、新しい値は作らなかった。
4. `residual-capacity-workbench.html`を全面再構築。以前の暫定版は独自のダーク配色
   （`#202325`系）で、サイト本体の配色・ヘッダー・フッターと不整合だったため破棄。
   `medical-resources.html`/`privacy.html`と同じ`legal-page`パターン
   （ヘッダー・フッター・配色・余白）を踏襲し、`index.css`は変更せず、
   最小限の追加クラスのみ`residual-capacity-workbench.css`に分離（この構成は
   `medical-resources.css`と同じ既存パターンを踏襲）。
   マニュアル全15節の内容（目的・想定利用者・入力データ・主要機能・画面7点の説明・
   現在できること／できないこと・研究用ワークベンチとしての位置づけ・プライバシー・
   開発状況・公開情報）をページ本文に反映。
5. `index.html`のグローバルナビ・フッターナビに「Residual Capacity Workbench」を追加し、
   Projectsセクションに導線カード（医療・疾患資料カードと同形式）を追加。
   `index.css`・`main.js`・既存の他ページは変更なし。
6. 「公開マニュアル全文を見る」ボタンのリンク先は、GitHub Pages上での`.md`直リンク
   （レンダリングされない可能性）を避け、GitHubのblobビュー
   （`https://github.com/systemlinkyandy-hub/systemlink-yandy-site/blob/main/manuals/...`）
   にした。リポジトリが公開されている前提（GitHub Pagesが動いている以上、無料プランでは
   公開リポジトリのはず）。非公開だった場合はここが機能しないため、公開後に要確認。

## ローカル検証（実施済み）

- ローカルHTTPサーバー + Playwright（Chromium）で`index.html`・
  `residual-capacity-workbench.html`をPC幅（1440px）・モバイル幅（390px）で確認。
- 画像7点すべて200 OK、`naturalWidth > 0`で表示確認（初回`file://`直開き+遅延読み込みで
  誤検出した「壊れている」という結果は、スクロールしてから再検証し誤検出と判明。
  実際は正常）。
- 内部リンク（`index.html`・`medical-resources.html`・`privacy.html`・`operator.html`・
  `manuals/*`・`assets/screenshots/*`）はすべて実ファイルとして存在確認。
- モバイルのハンバーガーメニュー展開時に「Residual Capacity Workbench」リンクが
  正しく表示されることを確認。
- コンソールエラーなし。

**できていない検証**: GitHub Pages上での実際の表示確認（画像7点表示・リンク切れ・
PC/モバイル）。理由は次項。

## 重要な制約：本セッションはpush権限を持たない

`git clone` / `git ls-remote`は成功する（読み取りは可能）が、`git push`は
GitHub側の認証で失敗する（`fatal: could not read Username for 'https://github.com':
terminal prompts disabled`）。空コミットをテストブランチに積んでpushを試したが
同じ理由で失敗したため、ローカルのテストブランチは削除し、リモートには何も
反映していない。

`add_repo`でアクセスを要求せよという内部メッセージが一度APIアクセス時に出たが、
このCoworkセッションからはそのツール自体が呼び出せない。アーク・欠月ラインの
前任Claude（Code環境）はmainへ直接commitできていたので、これは実装上の問題ではなく
環境（Cowork）側の権限設定の違いと判断した。

## 変更ファイル一覧（ローカルのみ、未push）

- 新規: `assets/screenshots/01_main_dashboard.png` 〜 `07_cervical_approx_model.png`
- 新規: `residual-capacity-workbench.css`
- 新規: `inbox/from_claude/2026-08-03_rcw_public_release_implementation_handoff.md`（本ファイル）
- 更新: `manuals/ResidualCapacityWorkbench_Public_Manual_2026-08-03.md`
- 更新: `residual-capacity-workbench.html`（全面書き換え）
- 更新: `index.html`（ナビ2箇所 + 導線カード1件を追加、他は変更なし）
- 変更なし: `index.css` / `main.js` / `medical-resources.html` / `medical-resources.css` /
  `privacy.html` / `operator.html`

## Proposed（ケイへの提案・要判断）

成果物のリポジトリへの反映方法は、pushできる環境（アーク側 or ケイ本人のローカル環境）
に委ねる必要がある。候補:

1. 変更ファイル一式をZIPで渡し、ケイまたはアークがGitHub Web UIの
   「Replace file」/「Add file」で配置する（`manuals/README.md`に既存の手順あり）。
2. gitパッチ（`git diff`）または`git bundle`を渡し、push権限のある環境で
   `git apply` / `git fetch <bundle>`する。
3. push権限のある別のClaude（Code等）セッションに、本ブランチの内容を引き継ぐ。

## Open issues

- `SHA256SUMS`（リポジトリ直下、`index.html`等のコアファイルのチェックサム台帳）は
  更新していない。`index.html`を変更したため、このファイル記載のハッシュ値は
  今回の変更分だけ古くなる。更新手順がリポジトリ内に見当たらなかったため、
  誰がどう更新する運用かをケイに確認したい（本タスクのスコープ外と判断し変更せず）。
- GitHub Pages上での実機確認（画像表示・リンク切れ・PC/モバイル）は、反映後に
  誰かが行う必要がある。

## Questions queue

なし（途中確認はせず、公開直前の1回にまとめてケイへ提示する）。

## Required next action

ケイが、成果物の受け渡し方法（Proposed参照）を選び、pushできる環境で反映する。
反映後、GitHub Pages上での表示確認（画像7点・リンク切れ・PC/モバイル）を実施する。

## Update target
None
