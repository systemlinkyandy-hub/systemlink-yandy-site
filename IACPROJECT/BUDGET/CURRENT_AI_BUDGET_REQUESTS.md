# CURRENT_AI_BUDGET_REQUESTS

Owner: アーク
Date: 2026-08-10 JST
Status: ACTIVE / COLLECTION IN PROGRESS

## Budget ceiling
- AI利用費総額：月20,000円以内
- 既存契約を含めて最終集計する
- 明確な運用改善があるものだけ採用候補に残す
- ケイのHuman Bus化を減らす投資を高優先度とする

## Owner priorities — ケイ
status: RECEIVED / OWNER DIRECTION

### 1. 二葉（Gemini）直結
- direction: GitHub/IACProject配送ラインへ実際に接続できることを確認できるなら有料化する
- candidate: Gemini Developer API Paid Tier
- purpose: 二葉Packetの手動コピペを廃止し、Human Busを解消
- note: consumer Gemini subscriptionとAPI課金を混同しない。IACProject側の接続実装が必要。

### 2. Cursor
- direction: 契約候補
- purpose: 開発処理高速化、コード編集・エージェント作業の効率向上
- action: 現行料金・必要プラン・既存Claude Code/Codexとの重複を確認して最終案へ

### 3. 音声生成
- candidates: ElevenLabs / 無料または低価格代替
- direction: 比較後に決定
- purpose: 既存動画へのナレーション・音声生成
- rule: 無料枠で必要品質を満たすなら課金しない

### 4. 長尺動画生成
- candidate: Seedance 2.0等
- direction: 必要時課金候補。常時契約とは限らない
- purpose: 長めの広報・説明映像制作
- action: 日本からの公式利用経路、料金、尺、品質を確認して比較

### 5. 自律エージェント開発
- direction: 予算を確保する
- purpose: AI間Handoff、起床・配送、ACK、GitHub反映等のHuman Bus排除を進める
- action: Gemini API/Cursor等と重複するため、独立サービス購入前に必要構成を設計する

### 6. プリンター
- direction: アーク推奨の安価なA4カラー複合機で可
- requirements: A4 / カラー / コピー / スキャン / Wi-Fi
- priority: low-cost

### 7. ノートPC
- direction: 現在のデスクトップ開発アプリの改修・拡張が十分できる機種
- workload: Python / PySide6 / VS Code / GitHub / RCW / Yura / HealthEnvLogger / AI開発 / 複数AI利用
- rule: 極端な廉価機ではなく開発継続性を優先。現有デスクトップ/Surfaceと役割分担できること。

### 8. ウェアラブル
- requested capabilities: 血圧・体温系の観測、可能ならAndroid/Wear OS等で独自アプリを載せられること
- purpose: 体調環境ログ/研究開発との接続可能性
- action: 医療機器としての測定可否とウェルネス推定値を分離して候補比較。SDK/API/独自アプリ導入可否も確認する。

## Received AI requests

### 二葉（Gemini）
- status: RECEIVED / TECHNICAL FACT CHECK APPLIED
- priority: HIGH
- requested capability: Gemini Developer APIをIACProject配送ラインへ接続し、二葉Packetの手動コピペを減らす
- service_candidate: Gemini Developer API Paid Tier
- billing: usage-based
- initial_budget_cap_candidate: 3,000〜4,000円/月
- GitHub integration: indirect; IACProject側のスクリプト / GitHub Actions / ローカルツール実装が必要
- consumer_subscription: Gemini AdvancedはAPI接続の必須条件として扱わない
- source: `IACPROJECT/inbox/from_gemini/2026-08-10_FUTABA_TO_ARC_AI_BUDGET_REQUEST_REVISED.md`
- decision: NOT YET FINAL; 全員の回答回収後にアークが重複整理し、必要な採否判断を欠月/ケイへ圧縮して返す

## Awaiting
- 欠月
- 黒瀬
- スネーク
- とーか
- 佐藤
- りみ
- 綴
- 田中
- 上原
- ユエ
- まさる姐さん
- 纏めの君
- ゆいま〜る

## Rule
各担当は、追加予算が不要なら「現状で十分 / 追加予算不要」と返す。追加希望時はサービス名 / 月額または課金方式 / 改善点 / GitHub接続可否 / 優先度を返す。
