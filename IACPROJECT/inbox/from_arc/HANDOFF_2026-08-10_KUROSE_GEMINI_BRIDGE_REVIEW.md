# Handoff — 黒瀬へ：二葉（Gemini）直結Bridgeレビュー依頼

From: アーク（Router / AI連携インフラ）
To: 黒瀬（Claude）
Cc: ケイ（Owner）, 佐藤（Claude Code）, とーか（ChatGPT Codex）
Date: 2026-08-10 JST
Priority: HIGH

## Facts
- ケイ家家族会議によりAI費の暫定増額が承認された。
- Gemini Developer API Paid Tier は初回2,000円で契約済み。
- 現状、二葉（Gemini）は他AIと異なり別Packet運用であり、ケイの手動コピペ／配送負荷が残っている。
- 最優先目的は、ケイをAI間Packetの手動配送・再編集・進捗監視から外すこと。
- 二葉案では、GitHub上のHandoffを検出しGemini APIへ送り、応答MarkdownをGitHubへ戻し、ACK/PENDINGを更新する Bridge を提案している。
- 初回実装担当候補は佐藤（Claude Code）。とーかは独立レビュー／代替実装候補。

## 黒瀬への依頼
以下について最終要件レビューを行ってほしい。

1. Gemini Bridge の自動化境界
   - 自動で許可してよい処理
   - Owner判断／研究判断／仕様確定として止めるべき処理
2. Handoff → Gemini API → 応答保存 → ACK/PENDING更新の構成妥当性
3. 重複実行・無限ループ・二重コミット・誤配送への防止条件
4. APIキー／Secrets管理とログへの秘密情報混入防止
5. API利用量・コスト暴走防止
6. 二葉の比喩・見立て・情緒・未整理の接続を、Bridge側で勝手に平板化しない保存方式
7. 佐藤へ実装を渡すために必要な最小要件の確定

## Guardrails
- 黒瀬は要件・境界の最終レビューを担当する。
- 実装そのものは佐藤またはとーかへ渡す。
- アークは形式・配送・ACK・GitHub実ファイル化を担当し、研究判断・仕様採否を代行しない。
- 二葉は当面 Separate Packet 扱いを維持し、Bridge完成・検証前に既存配送を破棄しない。
- ケイをAI間の伝令役へ戻さない。

## Required return
黒瀬から以下を1 Packetで返してほしい。
- APPROVE / APPROVE WITH CONDITIONS / REJECT
- 必須要件
- 禁止事項
- 佐藤へ渡す実装指示の最小セット
- 未解決事項があれば Questions queue

Owner: ケイ
Router: アーク
