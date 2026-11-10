# Yura Medical Debug Toolkit

Status: BASELINE / READY FOR USE
Owner: りみ（ENGINEER）
Purpose: 医療・身体・環境・AI利用に関する観測を「再現可能なデバッグ記録」として残すための最小ツールセット。

## 0. 目的

このToolkitは、医療判断をAIへ委ねるためのものではない。

目的は、本人の連続データ、介入、環境、症状、AIや外部情報から得た仮説を分離し、
「何が観測されたか」「何を試したか」「何が変わったか」「どこまで確認済みか」を追跡可能にすること。

Yuraの固定原則を維持する。

- Raw / Observation / Derived-Inference / Presentation を混同しない
- 実測と推定を分離する
- 相関と因果を混同しない
- 元データを失わない
- 不確実性とデータ品質を保持する
- 単一スコアへ潰さない
- 後から別アルゴリズムで再解析できる

## 1. 構成

### debug_event.schema.json
時系列イベントの共通交換形式。
HealthEnvLogger / Cortisol HP / RCW の既存importerを置き換えず、その上に載せる。

### claim_ledger.csv
本人観察、医療者発言、論文、Web情報、AI回答から出た「主張」を1件ずつ管理する台帳。

### ai_answer_audit.md
Google AI Mode / ChatGPT / Claude / Gemini / Grok 等の回答を、採否ではなく検証対象として残すテンプレート。

### medical_debug_packet.md
医療者へ渡すときに、時系列・介入・反応・仮説・未解決点を短く再現可能にまとめるテンプレート。

### redaction_checklist.md
外部共有前に、本人・第三者・医療機関等の個人情報を落とすためのチェック。

## 2. 既存実装との接続

RCW側には既に以下がある。

- ImportedEvent 共通正規化構造
- HealthEnvLogger JSONL importer
- Cortisol HP backup importer
- merge_event_streams()
- 位置情報分離
- raw_payload保持
- operational_date保持

したがって、新しいimporterは作らない。

今後コード化するときは、ImportedEvent等の正規化済みイベントから
Medical Debug Packet用のView/Exportを生成する。

## 3. 最初の実装ターゲット

1. normalized event -> debug event 変換
2. claim ledger loader
3. time range / tag filter
4. before-after / load-no-load比較
5. Markdown packet export
6. 匿名化チェック
7. synthetic fixture test

## 4. 境界

- 診断・治療の正しさを自動決定しない
- AI回答を根拠扱いしない。source / claim / verification_statusを分離する
- 第三者の人物評価や意図推定を確定事実にしない
- 個人の服薬量を一般化しない
- 実データはGitへcommitしない
