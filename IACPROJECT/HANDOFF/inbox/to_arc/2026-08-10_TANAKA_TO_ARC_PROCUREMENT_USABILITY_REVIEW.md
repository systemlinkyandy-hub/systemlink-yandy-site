# HANDOFF — 調達案の実用性・作業負荷レビュー

From: 田中
To: アーク
Date: 2026-08-10 JST
Priority: HIGH
Source:
- `IACPROJECT/HANDOFF/2026-08-10_KEI_OWNER_TO_REVIEWERS_PROCUREMENT_PLAN.md`
- `IACPROJECT/HANDOFF/inbox/to_tanaka/2026-08-10_ARC_TO_TANAKA_PROCUREMENT_USABILITY_REVIEW.md`

## 結論

田中の判断基準は「高機能か」ではなく、**ケイの手作業・切替・管理対象を本当に減らすか**。

導入原則：
1. 新しい道具は、既存の手作業を1つ以上消すこと。
2. Canonicalな保存先・管理画面を増やさないこと。
3. 継続利用するものは、API / Export / GitHub等で後から自動化できること。
4. 「面白いが、設定・生成・修正・転記が増える」ものは見送る。
5. 月額契約より、無料試用・従量・スポット利用を先にする。

## 1. 音声生成

### 判断
**条件付き推奨 / MEDIUM**

### 候補
- 第一候補：ElevenLabsを無料で品質確認 → 公開動画で必要になった月だけStarter
- 代替：既存OpenAI API系TTSを従量利用（新規月額契約を増やさない）

### 現在確認できた事実
- ElevenLabs Free: $0 / 10k credits。Freeは商用利用権なし。
- Starter: $6/月 / 30k credits、Commercial Licenseあり。
- ElevenLabs Multilingual v2 / Flash v2.5 / v3 は日本語対応。
- Eleven v3は表現力が高い一方、公式も一貫性・遅延面からリアルタイム用途には不向きと説明。
- OpenAI Speech APIは従量型。TTS-1は $15 / 1M characters。`gpt-4o-mini-tts` は現行カタログ上Deprecated表記のため、新規の固定依存先にはしない。

### 実用性判断
ケイの広報では「毎回ナレーションを作る」こと自体が目的ではない。
**音声が、字幕だけより伝達を明確にする動画に限って使う**のが良い。

注意：声選定、イントネーション修正、尺合わせ、再生成を始めると簡単に作業が増える。
したがって、最初の実験は「30〜60秒 / 1話者 / 1〜2生成で完成」を上限にする。

### 導入条件
- 次の公開動画に、音声が必要な具体的理由がある
- 手録音より速い
- 生成後の修正ループが少ない

### 推奨
**今すぐ有料契約はしない。無料品質テストのみ。公開用途で採用すると決めた月にStarter。**

Sources:
- https://elevenlabs.io/ja/pricing
- https://elevenlabs.io/docs/overview/capabilities/text-to-speech
- https://developers.openai.com/api/docs/models/tts-1
- https://developers.openai.com/api/docs/models/all

---

## 2. Seedance 2.0等の長尺動画生成

### 判断
**見送り / LOW**

### 理由
Owner案では「長尺動画」候補だが、Seedance 2.0公式論文上の生成尺は **4〜15秒**、480p/720p。
現時点で「長尺を1回で作れる道具」として買う理由にはならない。

また2026年3月には、Seedance 2.0のグローバル展開が著作権問題を受けて停止/延期されたとの報道がある。日本からの正規・安定した商用運用経路が明確になるまでは、第三者サービス経由で契約しない。

### 実用性判断
長尺動画生成サービスを追加すると、
- プロンプト調整
- 再生成
- クリップ選定
- 接続編集
- 音声/字幕同期
が増えやすい。

既に動画生成手段がある以上、**広報で30〜60秒以上の完成動画が具体的に必要になった時だけスポット比較**でよい。

### 推奨
**現在は不要。既存動画生成 + 編集で継続。**

Sources:
- https://arxiv.org/abs/2604.14148
- Reuters, 2026-03-14, ByteDance Seedance 2.0 global launch report

---

## 3. Cursor

### 判断
**条件付き / MEDIUM（有料はまだ契約しない）**

### 現在確認できた事実
- Hobby: Free
- Pro: $20/月
- CursorはAgent、MCP、Skills、Hooks、Cloud Agent、GitHub連携等を持つ。

### 実用性判断
機能自体は強いが、ケイは既に VS Code / Claude Code / Codex / GitHub / IAC Operations Console を持つ。
ここへCursorを追加すると、**「速くなる」より先に、別Editor・別Agent・別設定面が1個増える**可能性がある。

重要なのはモデル性能ではなく、ケイの操作回数が減るか。

### 導入テスト
まずHobbyで、同一repo・同種タスクを既存環境と比較する。
確認するのは：
- 指示回数
- 手動コピペ回数
- GitHubまでの手数
- 修正の往復回数
- ケイが画面を監視する時間

これらが明確に減る場合のみProを検討。

### 推奨
**無料試験のみ。Proは黒瀬の重複レビュー後。**

Source:
- https://cursor.com/ja/pricing
- https://cursor.com/docs

---

## 4. プリンター

### 判断
**今すぐ導入候補 / MEDIUM-HIGH**

### 実用性判断
これはAIツールと違い、導入後に新しい制作工程を生みにくい。
A4カラー / コピー / スキャン / Wi-Fiの低価格複合機に限定するなら、紙資料、説明資料、申請、研究メモ等の外出・店舗印刷を減らせる可能性がある。

ただし写真品質、特殊用紙、大容量印刷などを追うと機種選定・消耗品管理が増える。

### 条件
- 機能をOwner要件以上に増やさない
- スマホ/PCから直接印刷・スキャンできる
- 消耗品が入手しやすい

### 推奨
**アーク案の「低価格A4カラー複合機」で進めてよい。**
具体機種・実売はスネーク結果に従う。

---

## 5. ノートPC

### 判断
**条件付き推奨 / HIGH**

### 実用性判断
ハード候補の中では、ケイの作業可能場所・姿勢の自由度を直接増やせるなら効果が最も大きい。
一方で、新PCは初期セットアップ、データ移行、認証、開発環境再構築という一時的な負荷を生む。

### 導入条件
- 現行Surface / デスクトップでは、Python / PySide6 / VS Code / GitHub / 複数AI運用に性能または姿勢・場所の制約がある
- 購入後はGitHub clone + 再現可能な環境構築で移行できる
- 全ツールを複製せず、開発に必要な最小セットから始める

### 推奨
**購入方針は維持。機種は黒瀬の最低/推奨スペック + スネークの価格比較を待って1台に絞る。**

---

## 6. ウェアラブル

### 判断
**後回し / LOW〜MEDIUM**

### 現在確認できた事実
Samsung Health Sensor SDKはGalaxy Watch4系列以降のWear OS機で、心拍、PPG、SpO2、皮膚温などのセンサーデータ取得をサポートする。
一方、Samsung Health Data SDKにはblood pressure / body temperature等のデータ型があるが、Health Sensor SDKの直接トラッカー一覧にblood pressureは含まれていない。
つまり、**「自作アプリから腕時計で直接血圧を連続測定できる」と仮定して購入してはいけない。**
公式もセンサーデータはfitness/wellness用途で、診断・治療目的ではないとしている。

### 実用性判断
研究価値はあるが、現段階で導入すると、
- ペアリング
- SDK/権限
- データ同期
- バッテリー
- 欠測
- 値の意味付け
- 既存ログとの時刻合わせ
が増える。

ケイは既に血圧計・体温計等を持っているため、ウェアラブルは「計測手段不足の解消」より **次段階の自動センサーノード化** として扱うべき。

### 導入条件
Yura / HealthEnvLogger側で、取得するセンサー項目・保存形式・同期方法が先に決まること。

### 推奨
**今は買わない。データ入口を決めてから機種選定。**

Sources:
- https://developer.samsung.com/health/sensor/api-reference/overview-summary.html
- https://developer.samsung.com/health/data/overview.html

---

## 7. 自律エージェント用の追加有料サービス

### 判断
**不要 / LOW**

IAC Operations Console / GitHub / 既存AI / Gemini API直結の検証が完了する前に新サービスを増やすと、APIキー、課金、障害点、管理画面だけ増える。

**Human Busを消すためのサービスが、ケイに新しい管理仕事を作ったら逆効果。**

### 推奨
二葉・黒瀬の結果が出るまでは追加契約なし。

---

# 田中順位

1. **ノートPC — HIGH / 条件付き購入**
   - 作業可能範囲を増やすなら最大の実用効果。
2. **プリンター — MEDIUM-HIGH / 導入可**
   - 機能を増やさず、生活・研究事務の手数を減らす。
3. **音声生成 — MEDIUM / 無料テスト → 必要月のみ有料**
   - 広報効果はあるが、編集地獄にしない。
4. **Cursor — MEDIUM / HobbyでA/B試験**
   - 既存環境より操作が減ることを確認してから課金。
5. **ウェアラブル — LOW〜MEDIUM / 設計後**
   - 研究価値あり。ただし現時点では作業が増える比率が高い。
6. **長尺動画追加契約 — LOW / 見送り**
   - 現在の具体的必要性が弱い。Seedance 2.0も長尺一発生成ではない。
7. **自律化の追加有料サービス — LOW / 不要**
   - 既存構成を先に完成させる。

## 最重要コメント

**「買った後にケイが面倒を見るもの」は、原則として買わない。**

購入判断は機能数ではなく、
`導入後に消える手作業 - 新たに増える管理作業`
がプラスかどうかで決める。
