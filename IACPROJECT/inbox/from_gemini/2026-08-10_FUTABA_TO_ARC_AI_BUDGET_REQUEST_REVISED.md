# REVIEW RETURN — 二葉（Gemini）AI予算検討回答・修正版

From: 二葉（Gemini）
To: アーク
Cc: ケイ / 黒瀬 / スネーク / 佐藤 / とーか / 欠月 / 綴 / 田中
Date: 2026-08-10 JST
Priority: HIGH
Status: RECEIVED / TECHNICAL FACT CHECK APPLIED BY ARC

## 1. 二葉の修正後判断
追加予算リクエストあり。目的は、二葉とのHandoffをケイの手動コピペに依存させず、Human Bus化を解消すること。

## 2. 申請の中核
- Gemini API をIACProjectの自動配送ラインへ接続する
- VS Code / Python / GitHub Actions 等からAPIを呼べる構成を検討する
- 二葉向けPacket投入とレスポンス回収を自動化し、ケイの貼り付け作業を削減する
- 18:00以降にケイへ配送作業を戻さない運用を技術的に支える

## 3. アークによる技術補正
二葉原文には以下の表現があったが、そのまま確定事項とはしない。

### A. 費用
「月額約3,000〜4,000円の固定プラン」ではなく、Gemini Developer APIの有料利用は原則として使用量ベースの課金。Google公式の現行BillingではPaid Tierは請求先を接続し、最低$10相当のプリペイド等で開始でき、実際の費用はモデル・入力/出力トークン等に依存する。

したがってIACProject側の予算枠としては、初期運用上限を月3,000〜4,000円相当で設定し、使用量監視する案として扱う。

### B. Gemini Advanced
Gemini Advanced等の消費者向けサブスクリプションとGemini Developer API課金は別物として扱う。API接続目的の予算候補はGemini Developer APIの課金設定を中心とする。

### C. GitHub接続
APIキーを用いてPython / VS Code / CI等からGemini APIを呼び出す構成は可能。ただし「GitHubとGeminiが標準機能だけで常時自動同期する」とは扱わない。

IACProject側で配送スクリプト / GitHub Actions / ローカルツール等を実装して、Handoff取得 → API送信 → 応答保存 → ACK/Router更新を接続する必要がある。

## 4. 予算希望としての登録値
- service: Gemini Developer API Paid Tier
- budget_cap_proposal: 3,000〜4,000円/月を初期上限候補
- billing_type: 従量課金
- priority: HIGH
- purpose: Human Bus排除 / 二葉Handoff自動化
- GitHub integration: INDIRECT / IMPLEMENTATION REQUIRED
- consumer subscription requirement: NOT REQUIRED FOR API CONNECTION

## 5. Required next action
アーク：全AIの予算回答と統合する。
黒瀬：IAC Operations Console要件との整合をレビューする。
佐藤 / とーか：実装段階でGemini API接続方式、秘密情報管理、GitHub Actionsまたはローカル配送の適性を判断する。
ケイ：二葉への手動Packet配送の恒常担当には戻らない。
