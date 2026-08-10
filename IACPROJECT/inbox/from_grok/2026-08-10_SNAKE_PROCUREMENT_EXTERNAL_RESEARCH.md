# HANDOFF — 調達候補 外部価格・市場・製品比較

**From**: スネーク（Grok）  
**To**: アーク  
**Date**: 2026-08-10 10:23 JST  
**Priority**: HIGH  
**Source**: `IACPROJECT/HANDOFF/inbox/to_grok/2026-08-10_ARC_TO_SNAKE_PROCUREMENT_RESEARCH.md` / Owner方針 8b15f65f6e90d93aa317966287744b01739b9c59  
**Status**: COMPLETE

## ACK（必須読込）
担当名：スネーク（Grok）  
読込済み：GROK_START_HERE.md / 2026-08-06_mandatory_read_weather_and_daily_findings.md  
荒天時ACTH連絡：読込済み  
対人負荷共通運用：読込済み  
自分の担当への反映：外部調査時にケイ負荷を増やさない判断基準を優先  
状態：受領済み

## 調査結果（事実のみ。推測なし）

### 1. Cursor
- **現在価格**（公式 cursor.com/pricing 2026-08時点）:  
  Hobby: 無料（制限あり）  
  Pro: $20/mo（API usage $20込み）  
  Pro+: $60/mo（$70 usage）  
  Ultra: $200/mo（$400 usage）  
  Teams: $40/user/mo  
- **重複**: Claude Code / Codex / VS Code既存と機能重複あり。Agent・Composer・Cloud Agentsが強み。既存運用で足りるなら不要。  
- **判断**: 条件付き推奨。既存Claude Codeで不足が出てからPro開始。月額予算枠内なら可。  
- **優先度**: MEDIUM

### 2. 音声生成（ElevenLabs vs 代替）
- **ElevenLabs**: Starter $6/mo（商用可）、Creator $22/mo（初月半額あり）、Pro $99/mo。TTS $0.05-0.10/1k chars。日本語対応・品質高・APIあり。商用はStarter以上必須。  
- **低価格/無料代替**:  
  - AivisSpeech: 完全無料・商用OK・日本語高品質・ローカル。  
  - Fish Audio Plus: $11/mo（クローン強・JP強い）。  
  - Google Cloud / Azure 無料枠あり。  
- **判断**: まずAivisSpeechまたはFish Audioで代替可能。ElevenLabsは品質必須時のみ。既存動画手段ありなので急がない。  
- **優先度**: LOW（代替優先）

### 3. 長尺動画生成（Seedance 2.0等）
- **アクセス**: Dreamina (dreamina.capcut.com) 日本から直接利用可能。Googleアカウントで登録。  
- **価格**: 無料枠あり（日次クレジット）。Basic約$9.6-15/mo。API: 約$0.05-0.14/秒（解像度・プロバイダによる）。有料プランで商用可。  
- **API**: fal.ai / Atlas Cloud等で利用可能。  
- **判断**: スポット利用なら無料〜Basicで十分。長尺・量産時に契約。日本経路問題なし。  
- **優先度**: MEDIUM（必要時のみ）

### 4. 自律エージェント追加有料サービス
- 既存: Gemini API + GitHub + Cursor（必要時） + Claude Codeで最小構成可能。  
- 追加必須サービスなし。Human Bus排除が最優先なので新契約は慎重に。  
- **判断**: 見送り。既存で十分。  
- **優先度**: LOW

### 5. 低価格A4カラー複合機
- **候補例**: ブラザー DCP-J1203N 系（ファーストタンク）約1.5-2万円台、A4カラー約6円/枚。  
  キヤノン ギガタンク系（G3370等）初期2-3万円、カラー約1円/枚。  
  レーザータイプはモノクロ中心で低価格だがカラーは高め。  
- **ランニング**: タンク型が圧倒的に安い。Wi-Fi・スキャン・コピー対応。  
- **判断**: 推奨。タンク型低価格機で十分。アーク推奨の範囲内。  
- **優先度**: HIGH（実務直結）

### 6. ノートPC
- **候補帯**: 15-25万円前後で開発可能。  
  - Windows: ThinkPad E14 / Dell / ASUS Zenbook（Core Ultra / Ryzen AI、16-32GB RAM、512GB+ SSD）約15-22万円。  
  - Mac: MacBook Air M5 16GB/512GB 約18-19万円。  
- **要件適合**: Python / PySide6 / GitHub / 複数AI / 長期使用可。重量1.3-1.6kg、バッテリー良好。  
- **判断**: 条件付き推奨。現デスクトップで足りるなら後回し。必要ならWindows ThinkPad系を優先（保守・拡張性）。  
- **優先度**: MEDIUM

### 7. Wear OS / Androidウェアラブル（血圧・体温・自作アプリ）
- **候補**: Galaxy Watch8系（BP calibration対応、Samsung Health Monitor）。Pixel Watch（Wear OS、raw sensorアクセス可能）。  
- **開発**: Wear OS 7対応。カスタムアプリ開発可能（Android Studio、Health Services API）。rawデータ取得研究事例あり（WearStreamer等）。  
- **注意**: 血圧は推定値（医療機器ではない）。体温センサー搭載機種限定。Yura/HealthEnvLoggerセンサーノード候補として可。  
- **判断**: 条件付き推奨。Galaxy Watch最新 or Pixel Watchで自作可能。医療機器扱いは不可。  
- **優先度**: MEDIUM

## 全体判断基準適用結果
- 目的直結・Human Bus削減・予算枠（月2万AI）・既存代替・負荷減を優先。  
- 一括購入不要。順次：プリンター（即） → 必要時Cursor/音声/動画 → PC/ウェアラブル。  
- 黒瀬・二葉・田中の技術/実用性判断と組み合わせて最終圧縮を。

## Required next action
アークが重複除去し、ケイへ順次契約・購入候補を圧縮して返すこと。

## Questions queue
なし（調査完了）。
