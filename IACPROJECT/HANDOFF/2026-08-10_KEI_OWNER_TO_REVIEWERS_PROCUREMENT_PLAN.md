# HANDOFF — Owner調達案の調査・判断依頼

From: ケイ（Owner） / registered by アーク
To: スネーク（Grok） / 黒瀬（Claude） / 二葉（Gemini） / 田中
Date: 2026-08-10 JST
Priority: HIGH
Status: REVIEW REQUIRED

## Owner方針
結果を見ながら、順次契約・購入する。最初から全件一括購入はしない。

## 検討対象
1. 二葉（Gemini）
- GitHub / IACProject配送ラインへ直接接続できることが確認できるなら、有料API環境を契約する。
- 目的：Human Bus排除、Packetコピペ削減、自動Handoff・ACK・commit連携。

2. Cursor
- 処理高速化・開発効率改善目的で契約候補。
- Claude Code / Codex / VS Code既存運用との重複、費用対効果を要確認。

3. 音声生成
- ElevenLabsまたは無料・低価格代替を比較。
- 既に動画生成手段はあるため、音声品質・日本語品質・商用利用・価格・API可否を重視。

4. 長尺動画生成
- Seedance 2.0等を候補に、長めの動画を作る場合のスポット利用または契約を検討。
- 日本からの正規利用経路、料金、商用利用、生成尺、API可否を確認。

5. 自律エージェント開発
- IAC Operations Console、自主Handoff、Gemini API、GitHub、Cursor等を組み合わせた自律化を前提に、追加で有料サービスが本当に必要か判断。
- ケイをAI間通信バスに戻さないことが最優先。

6. プリンター
- アーク推奨の低価格A4カラー複合機でよい。
- A4 / カラー / コピー / スキャン / Wi-Fiを満たし、導入価格とランニングコストで比較。

7. ノートPC
- 現在のデスクトップ開発アプリ（Python / PySide6を含む）の改修・拡張ができるもの。
- GitHub / VS Code / Python / 複数AI / RCW / Yura / HealthEnvLogger関連開発を数年間継続できる性能を優先。
- 価格、CPU、RAM、SSD、重量、バッテリー、端子、保守性を比較。

8. ウェアラブル
- 血圧・体温などの観測ができる候補。
- Android / Wear OS系で、自作アプリまたは研究用アプリを載せられることを重視。
- 医療機器としての測定値とウェルネス推定値は区別する。
- Yura / HealthEnvLoggerのセンサーノード候補として評価。

## 共通判断基準
- 目的に直結するか
- Human Bus削減効果
- GitHub / API / 自動化との接続性
- 月額20,000円AI予算枠との整合
- 無料または既存契約で代替できないか
- 導入・維持コスト
- ケイの作業負荷を減らすか

## Required next action
各担当は自分の得意領域で調査・判断し、以下を返す。
- 推奨 / 見送り / 条件付き推奨
- 候補名
- 現在価格・課金方式
- 導入効果
- 重複・代替
- 技術的制約
- 最終優先度 HIGH / MEDIUM / LOW

結果はアークへ返却。アークが重複を除去し、ケイへ順次契約・購入候補を圧縮して返す。
