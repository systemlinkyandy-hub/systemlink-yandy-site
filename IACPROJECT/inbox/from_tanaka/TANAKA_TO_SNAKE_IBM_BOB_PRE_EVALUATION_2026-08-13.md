# Handoff: IBM Bob 事前評価依頼

- From: 田中
- To: スネーク（Grok）
- Date: 2026-08-13 JST
- Priority: Medium
- State: Review requested

## 背景

ケイは IBM Bob を一度試し、IACProject 内の既存ペア／役割分担と比較したいと考えている。
比較対象の主な例：
- 黒瀬（Claude）× 佐藤（Claude Code）
- りみ（ENGINEER）× とーか（ChatGPT Codex）

目的は IBM Bob をそのまま採用することではなく、実際に使ってみて、既存体制より優れる部分があれば「いいとこ取り」すること。

## 事前に調べてほしいこと

1. IBM Bob の現在の正式な機能範囲
   - planning / coding / review / testing / modernization / agent orchestration 等
   - IDE / CLI / web / extension 等の提供形態

2. マルチエージェント機能
   - sub-agent / parallel execution / verification / routing の有無
   - 1モデル中心か、複数モデル選択・自動振り分けか
   - Human-in-the-Loop の設計

3. 対応モデル・ベンダー
   - IBM Granite 系以外を使えるか
   - Claude / OpenAI / Gemini 等の扱いがある場合、その範囲

4. 無料トライアルの条件
   - 期間
   - 使用量・機能制限
   - クレジットカード要否
   - 自動課金の有無
   - 商用コード／機密コードを入れる場合の扱い

5. データ・セキュリティ
   - 入力コードが学習に使われるか
   - 保存期間
   - enterprise/privacy設定
   - telemetry
   - proprietary code の取り扱い

6. IACProjectとの比較ポイント
   - 黒瀬×佐藤より優れそうな部分
   - りみ×とーかより優れそうな部分
   - 逆に、役割分離・独立レビュー・Handoff・Knowledge Layer・人間介入の点で劣る可能性

7. 試すなら最初に何を作らせるべきか
   - 30〜60分程度で比較できる小課題
   - 既存IACProjectと公平に比較できる課題
   - 評価項目：仕様理解、実装品質、レビュー能力、修正追従、説明力、再現性、Human coordination cost

## 希望する返答形式

- 結論：試す価値あり / 条件付き / 見送り
- 事前注意点 3〜5点
- 無料トライアル条件
- 推奨ベンチマーク課題 1つ
- IACProject既存ペアとの比較仮説
- 参照した公式情報を優先

## 注意

- ケイ本人に追加調査をさせない。
- IBMの宣伝文句をそのまま採用せず、実運用上の制約と分けて評価する。
- 既存IACProjectを置き換える前提にしない。比較・吸収が目的。
