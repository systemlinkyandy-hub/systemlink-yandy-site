# AI Escalation Review Template

**Owner / route manager**: アーク  
**Purpose**: アークまたはClaude Codeが行き詰まった時、ケイへ丸投げせず、必要な外部AIレビューを最小回数で起動するための正式テンプレート。

---

## Escalation trigger

このテンプレートを使うのは、以下のいずれかに該当する場合のみ。

- インフラ判断で複数案があり、既存運用だけでは解けない。
- 実装判断でClaude Codeが停止し、独立レビューが有効。
- 仕様・研究判断に触れ、アークが勝手に確定できない。
- 重複・矛盾・経路不全があり、複数AIの実測比較が必要。

単純なファイル移動、形式修正、ACK更新、担当振り分けはアーク内で閉じる。

---

# HANDOFF: AI Escalation Review Request

**日時**：YYYY-MM-DD JST  
**送信元**：アーク  
**宛先**：Claude / Grok / Gemini のうち必要なAIのみ  
**対象**：<project / task>  
**状態**：REVIEW REQUEST

## 1. 問題

<何が止まっているかを1段落で記載>

## 2. 現在分かっている事実

- <fact 1>
- <fact 2>

## 3. 試したこと

- <attempt 1 + result>
- <attempt 2 + result>

## 4. 制約

- ケイを伝令・再編集・再説明役にしない。
- 既存正本を勝手に変更しない。
- 回答AIは採否決定権を持たない。
- GeminiはGitHub Pullを前提にしない。必要情報は単一Packetへ同梱する。

## 5. 欲しい回答形式

1. 推奨案
2. 根拠
3. 主要リスク
4. 代替案（必要な場合のみ）
5. 実測が必要な点

## 6. 採否判断者

<欠月 / ケイ / 該当正本判断者>

回答AIはレビュー担当であり、最終決定者ではない。

---

## Return route

- Claude / Grok / Geminiの回答はアークが受領する。
- アークが重複・矛盾・未確認事項を整理する。
- 欠月または該当正本判断者へ、判断事項だけを圧縮して返す。
- ケイをAI間の伝令役にしない。

## External AI wake-up rule

外部AIを実際に起こす必要がある場合、アークはケイへ次の4点だけ伝える。

1. 起こすAI名
2. 理由
3. 渡す完成Handoff / Packet
4. 関連コミット番号

それ以外の中間整理はアーク側で閉じる。
