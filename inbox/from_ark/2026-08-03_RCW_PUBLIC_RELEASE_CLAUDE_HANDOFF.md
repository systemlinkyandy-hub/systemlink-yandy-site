# Handoff: Residual Capacity Workbench 公開実装のClaude移管

- From: アーク
- To: Claude / Claude Code
- Date: 2026-08-03
- Priority: 緊急
- Status: 未受領

## 結論
解析用デスクトップアプリ（Residual Capacity Workbench／AIなしプロトタイプ）の公開実装をClaudeへ移管する。
アーク側の先行公開は、スクリーンショット未配置かつ既存サイト統合が不十分で、ケイの承認対象にならない。

## 入力物
ケイ提供ZIP:
`ResidualCapacityWorkbench_Public_Manual_Release_2026-08-03.zip`

ZIP内の公開対象:
- 公開マニュアル本文
- `assets/screenshots/01_main_dashboard.png` ～ `07_cervical_approx_model.png`

## 実施内容
1. ZIPを展開し、公開対象を既存サイトの適切なディレクトリへ配置する
2. PNG 7点を実ファイルとしてGitHubへ追加する
3. 既存サイトのデザイン・構造を維持したまま、Residual Capacity Workbenchの導線を追加する
4. 公開ページに以下を含める
   - アプリの目的
   - 入力データ
   - 主要な解析機能
   - 画面出力
   - 現在できること
   - 未実装点
   - 研究用ワークベンチとしての位置づけ
   - AIなしプロトタイプであること
   - Webサイト、GitHub、連絡先
5. 画像表示、リンク、モバイル表示、GitHub Pages公開状態を確認する
6. 完了後、`inbox/from_claude/` へ完了Handoffを返す

## 現在mainにある不完全な先行公開
以下はアーク側が作成した未承認の先行版。完成版で置換または不要なら削除すること。
- `residual-capacity-workbench.html`
- `manuals/ResidualCapacityWorkbench_Public_Manual_2026-08-03.md`
- アーク作成の完了Handoff

## 完了条件
- スクリーンショット7点が実際に表示される
- 既存トップページから公開ページへ到達できる
- 公開ページからマニュアル、GitHub、連絡先へ到達できる
- 「AIなしプロトタイプ」「研究用ワークベンチ」「診断・治療支援ではない」の境界が明確
- GitHub Pages上で404、画像欠落、表示崩れがない
- ケイの最終確認は完成後の1回だけ

## 今回やらないこと
- 新機能実装
- AI機能追加
- 別リポジトリ操作
- SNS投稿
- ケイへの途中確認

## ACK
受領後、本ファイルのStatus更新または所定のACKを返すこと。
