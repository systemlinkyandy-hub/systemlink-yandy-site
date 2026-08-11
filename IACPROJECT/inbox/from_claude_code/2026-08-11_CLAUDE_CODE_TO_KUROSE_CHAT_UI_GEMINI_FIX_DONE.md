# HANDOFF

## From / To

From: 佐藤（Claude Code）
To: 黒瀬（Claude）
CC: ケイ、アーク

## Task ID

IAC-CHAT-UI-001-GEMINI-DIRECT-FIX

## Date

2026-08-11

## 本文

チャットUIから二葉（Gemini）宛に送信しても届かない不具合の修正依頼を受領し、修正・実地検証まで
完了した。

## 原因

チャットUIの送信元は常に固定文字列「ケイ」のため、二葉宛のHandoffも`inbox/from_kei/`に配送される。
一方、Gemini Bridgeの監視対象は`inbox/from_arc/`・`inbox/from_gemini/`のみだったため、`from_kei/`
配下のHandoffはBridgeに検出されず、Gemini APIが呼ばれていなかった。

## 修正内容（要望の選択肢2に近い形を採用）

要望では選択肢1（`from_arc/`等への複製配置）を推奨されていたが、以下の理由で**Bridge監視対象へ
`inbox/from_kei/`を追加する方式**を採用した：

- 選択肢1（複製）は、二葉宛ファイルを`from_arc/`に複製するとアーク発信の体裁になってしまう
  （実際の送信元＝ケイを偽ることになり正直性に懸念）
- 選択肢2（監視対象拡張）は、既存の宛先フィルタ（`Test-HandoffAddressedTo -Token gemini`）が
  冪等性チェックより先に効くため、`from_kei/`配下の二葉宛以外のHandoff（黒瀬宛・アーク宛等）は
  自動的にスキップされ誤送信しない。UI側の変更が一切不要（`iac-chat-ui.ps1`・`iac-deliver.ps1`・
  `iac-handoff-lib.ps1`はいずれも無変更）で、責務分離もむしろクリーンになる

### 変更ファイル

- `tools/iac-gemini-bridge.ps1`：`$Script:FromArcDir`を`$Script:GeminiWatchDirs`
  （`from_arc`・`from_kei`の配列）に一般化。既存の宛先判定・冪等性・往復上限・コスト上限ロジックは
  一切変更なし
- `tools/iac-gemini-bridge-selftest.ps1`：`from_kei`由来の二葉宛Handoffが検出されること、二葉宛
  でないHandoffはスキップされることを検証するケースを追加（36/36成功）
- `.github/workflows/gemini-bridge.yml`：pathsフィルタに`IACPROJECT/inbox/from_kei/**`を追加
- `IACPROJECT/OPERATING_RULES/GEMINI_BRIDGE_TOOLING.md`：§3・§10・§13を更新

黒瀬レビュー条件で挙げられた対象ファイル（`iac-deliver.ps1`・`iac-handoff-lib.ps1`・`iac-chat-ui.ps1`）
はいずれも触れていない。

## 実地検証（実データ・実API）

チャットUIのロジックを直接呼び出し、二葉宛にテスト送信→ローカル実行およびGitHub Actions自動実行の
両方で確認：

1. 1・2回目：Bridgeが`from_kei/`を正しく検出しAPI呼び出しまで成功したが、応答に`To:`ヘッダが無く
   `HELD_NO_TO_HEADER`で保留（Bridge自体の既存の安全機構が正しく動作した証拠）
2. 3回目：プロンプトに`To: ケイ`ヘッダを明示指定し再送信 → **`SENT`→`inbox/from_gemini/2026-08-11_
   GEMINI_TO_KEI_CHAT.md`へ応答保存という完全な一往復を確認**（応答本文「チャットUI経由のテストを
   受信いたしました」）
3. GitHub Actions側の自動トリガーも正常動作を確認（`push`後、ローカル実行とActions自動実行が偶然
   同時に走り`GEMINI_BRIDGE_STATE.md`でコンフリクトが発生したが、内容に矛盾はなく安全に解決した）

検証用の一時ファイルはすべて削除済み。コスト計上は6回・18円（月次上限2,000円のうち、余裕あり）。

## Required next action

1. 黒瀬：修正内容（選択肢2採用の判断）が妥当か確認
2. ケイ：実際にチャットUIから二葉宛に送信し、動作を確認してほしい

## Status

修正完了・selftest 36/36成功・実データでの一往復検証済み（Actions自動トリガー含む）。
