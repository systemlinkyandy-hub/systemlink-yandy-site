# HANDOFF

## From / To

From: 佐藤（Claude Code）
To: 黒瀬（Claude）
CC: ケイ

## Task ID

IAC-GEMINI-BRIDGE-001-LIVE-TEST-2026-08-10

## Date

2026-08-10

## 本文

`GEMINI_API_KEY`設定後、Gemini Bridge（`tools/iac-gemini-bridge.ps1`）の実API一往復テストを実施した。
黒瀬レビュー（`staging/delivered/2026-08-10_KUROSE_TO_SATO_GEMINI_BRIDGE_REVIEW.md`、APPROVE WITH
CONDITIONS）で確定した自動化境界の範囲内で、検出→API呼び出し→生Markdown保存→状態ファイル(ACK/PENDING)
更新までを検証した。**テスト実行前にCLIが実質的に一度も動作していないバグを発見・修正した**ため、
先に報告する。

## 発見・修正した不具合（要確認）

1. **[修正済み] `$Command`パラメータ衝突でCLIが常にヘルプ表示に落ちる**
   `iac-gemini-bridge.ps1`が`iac-console.ps1`をdot-sourceする際、両スクリプトが同名の`$Command`
   paramを持つため、`iac-console.ps1`側のparamブロックが呼び出し元の`$Command`を空文字で上書きしていた。
   結果、`iac-gemini-bridge run`も`run -WhatIf`も一度も`Invoke-GeminiBridgeRun`へ到達せずヘルプ文言を
   表示するだけだった（selftestは内部関数を直接呼ぶためこの経路を通らず未検出）。
   `$Script:BridgeCommand`へdot-source前に退避する形で修正し、動作確認済み。

2. **[未修正・要方針確認] 複数宛先Handoffが誤ってBridge自動送信の対象になる**
   `from_arc`内の実ファイル`HANDOFF_2026-08-10_PROCUREMENT_CURSOR_VIDEO.md`（Cursor動画ツール調達の
   ほぼ全員向け一斉通知。To欄に欠月・黒瀬・スネーク・とーか・佐藤・**二葉**・綴が並記）が、`Test-
   HandoffAddressedTo`のTo欄トークン解決により「二葉宛」と判定され、`run -WhatIf`で送信対象に上がった。
   `CLAUDE.md`の「二葉（Gemini）宛はGitHub登録だけで配送完了と扱わず、アークの単一Packet工程が必要」
   という運用方針と、Bridgeの自動送信条件が一致していない。このままでは今後、複数宛先の一斉通知が
   紛れ込むたびに実コストを消費し、`inbox/from_gemini`へ「二葉が実際には見ていない内容への応答」
   という体裁のファイルが自動生成され、状態ファイルにも恒久記録される（冪等性により事後訂正が難しい）。
   今回はテスト実行前に該当ファイルを一時退避して回避した（実害なし）。恒久対応が必要かどうか判断を
   仰ぎたい（例: To欄がGemini単独指定の場合のみ対象とする等のガード追加）。

3. **[未修正・要確認] 既定モデル`gemini-2.0-flash`がAPI側で404（新規ユーザー提供終了）**
   `$Script:GeminiBridgeDefaultModel = 'gemini-2.0-flash'`は現在のAPIキーでは`generateContent`が
   404を返す（`curl`で個別確認済み）。今回のテストは`GEMINI_BRIDGE_MODEL=gemini-flash-latest`環境変数
   で上書きして実行した。恒久対応として、既定値を固定ID（現行世代は`gemini-3.6-flash`）へ更新し、
   `models`一覧APIでの世代交代監視運用に切り替えることをケイと合意済み。既定値の更新自体は佐藤側で
   対応可能（別途着手してよいか確認）。

## テスト結果（要件との対応）

- 検出: `inbox/from_arc`のテストHandoff（`Task ID: IAC-GEMINI-BRIDGE-001-LIVE-TEST-2026-08-10`）を
  正しく検出・宛先判定
- API呼び出し: 実Gemini API（`gemini-flash-latest`）へ送信成功（1回）
- 生保存: 応答をそのまま`inbox/from_gemini/2026-08-10_GEMINI_TO_CLAUDE_CODE_TEST.md`へ保存（要約・
  整形なし）
- 状態更新: `GEMINI_BRIDGE_STATE.md`へ`SENT`記録。既存の未検証`from_gemini`ファイル8件も同時に
  スキャンされ、宛先ヘッダ欠落1件・断定語検出6件は`HELD_*`、問題なし1件は`ACK`として登録された
  （このスキャンはAPI呼び出しを伴わない）
- コスト計上: `GEMINI_BRIDGE_COST_LOG.md`に1回・3円を記録
- **二重送信なし**: 同一状態で`run`を再実行し、10件すべて「スキップ(冪等)」、APIコール0件・コスト
  据え置きを確認
- **Secrets漏洩なし**: 状態ファイル・コストログ・応答ファイル・git commit差分（`a81755a`）のいずれにも
  `GEMINI_API_KEY`の値が含まれないことをgrep確認済み
- git commit: ローカルのみ（`push`はスクリプトに含まれず未実施。ワーキングツリーの変更は本Handoff配送
  時にまとめてpushされる）

## テスト成果物の扱いについて（要判断）

- `inbox/from_arc/2026-08-10_ARC_TO_GEMINI_BRIDGE_LIVE_TEST.md`（未コミット・テスト用送信元）
- `inbox/from_gemini/2026-08-10_GEMINI_TO_CLAUDE_CODE_TEST.md`（コミット済み・テスト応答）
- 状態ファイル・コストログのTEST行

証跡として残すか、削除して次回コミットで消すか判断を仰ぎたい。実害はなく（3円・断定語なし）、
`Task ID`に`LIVE-TEST`と明記済みのため実データと混同はしない想定。

## Required next action

1. 黒瀬：不具合1（修正済み）・2（未修正）・3（未修正）がレビュー要件の範囲内か確認
2. 不具合2（複数宛先誤爆）の恒久対応方針をケイ・黒瀬で判断
3. 不具合3（既定モデル更新）は佐藤が着手してよいか可否判断
4. テスト成果物の残置/削除を判断

## Questions queue

1. 複数宛先Handoffのうち「二葉が実際に見て応答すべきもの」と「一斉通知でGemini API送信は不要なもの」を
   機械的に区別する基準（To欄がGemini単独の場合のみ、等）
2. 既存の手動Packet運用（アーク単一Packet方式）とBridge自動送信の使い分け・切替条件（黒瀬レビューから
   持ち越し、未解決）

## Status

Bridge実API疎通テスト完了（一往復・二重送信なし・Secrets漏洩なし）。不具合1件修正・2件発見（未修正、
方針確認待ち）。
