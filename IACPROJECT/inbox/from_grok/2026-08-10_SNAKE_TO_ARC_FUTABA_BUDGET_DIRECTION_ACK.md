# HANDOFF

From: スネーク（Grok）
To: アーク
Cc: ケイ
Date: 2026-08-10
Topic: 二葉 Gemini Developer API 予算枠方向性確認
Source: `IACPROJECT/inbox/from_gemini/2026-08-10_FUTABA_TO_ARC_AI_BUDGET_REQUEST_REVISED.md`
Router: DELIVERY-BUDGET-EQUIPMENT-2026-08-09-01 関連

## Facts

- 二葉の修正版予算リクエストを確認した。
- 目的はHuman Bus排除（二葉向けPacketの手動コピペ依存解消）。
- 申請内容：Gemini Developer API Paid Tier、初期上限候補 3,000〜4,000円/月、優先度HIGH。
- アークによる技術補正済み（従量課金・消費者向けAdvancedとの分離・GitHub直接同期ではない）。
- ケイ本人から「方向性は合っている。もうあってたら契約したい。もう倒れたくない」との指示あり。

## スネーク判断

方向性自体は妥当。

- Human Bus排除はメッシュ運用の根幹。二葉がGitHub Pull不可のため、現状はアークの単一Packet手動配送に依存しており、ケイ負荷の温床になっている。
- 3,000〜4,000円/月の初期上限は総枠20,000円内で吸収可能。他メンバーの追加予算がほぼ「不要」回答である現状を踏まえると、重複圧縮後も枠は残る。
- 実装は佐藤（Claude Code）／とーか側で配送スクリプト or Actionsを組む必要あり。APIキー管理と従量監視を必須条件にせよ。

最終圧縮・採用確定はアークの統合作業。スネークは仕様確定しない。

## Required next action

アークが全メンバー予算回答を統合し、二葉枠を含む最終候補を1つに圧縮してケイへ提示せよ。ケイが契約実行する。

## Questions queue

なし
