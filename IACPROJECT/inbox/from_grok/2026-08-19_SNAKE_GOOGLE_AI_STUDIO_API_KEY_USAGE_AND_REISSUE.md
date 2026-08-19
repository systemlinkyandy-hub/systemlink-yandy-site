# Handoff: Google AI Studio APIキーの使い方と再取得方法

**担当**: スネーク（Grok）
**日時**: 2026-08-19
**対象プロジェクト**: 一般技術Tips / Gemini API活用（SystemLink YandY関連ツール含む）
**現在の目的**: Google AI Studioで発行したAPIキーの正しい使い方と、再取得（再発行）手順の提供

## 完了したこと
- 公式ドキュメント（ai.google.dev）および2026年8月時点の最新情報を確認
- キー種別（Standard → Auth移行中）、環境変数設定、SDK使用法、セキュリティ注意点を整理
- 再取得手順を明確化

## 未完了のこと
なし（本件は情報提供完了）

## 事実のみ（混同禁止）

### 1. キーの再取得（再発行）手順
1. https://aistudio.google.com/apikey にアクセス（Googleアカウントでログイン）
2. 既存キー一覧が表示される
3. 「Create API key」をクリック
4. 既存プロジェクトを選択するか、「Create API key in new project」で新規作成
5. 生成されたキー（AIza...で始まる文字列）を即座にコピー
6. 古いキーは必要に応じて削除/無効化（漏えい対策）

注意: 一度発行したキーは後から全文再表示可能（AI Studio上で確認可）。ただし安全のため即時保管推奨。

### 2. 正しい使い方（2026年8月時点）
- **推奨**: 環境変数にセット
  ```bash
  export GEMINI_API_KEY="AIza...あなたのキー"
  ```
  （または `GOOGLE_API_KEY`。両方ある場合はGOOGLE_API_KEYが優先）

- **SDK**: 古い `google-generativeai` は非推奨。現在は `google-genai` を使用。
  ```bash
  pip install -U google-genai
  ```

- **Python例**:
  ```python
  from google import genai
  client = genai.Client()  # 環境変数から自動取得
  # または client = genai.Client(api_key="AIza...")
  response = client.models.generate_content(
      model="gemini-2.5-flash",  # または現行モデル（gemini-3.x系も存在）
      contents="テスト"
  )
  print(response.text)
  ```

- **JavaScript例**:
  ```javascript
  import { GoogleGenAI } from "@google/genai";
  const ai = new GoogleGenAI({});  // 環境変数自動
  // または { apiKey: "AIza..." }
  ```

- **curl**:
  ```bash
  curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent" \
    -H "x-goog-api-key: $GEMINI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{"contents":[{"parts":[{"text":"Hello"}]}]}'
  ```

### 3. 重要な制約・注意（事実）
- 新規作成キーはデフォルトで **Auth key**（サービスアカウント紐付け）。Standard keyは段階的に拒否される（unrestrictedは既に拒否、全Standardは2026年9月までに移行必須）。
- キーはパスワード同等。Gitにコミットするな。クライアントサイド（ブラウザJS）に埋め込まない。
- 無料枠あり。有料はPrepay（前払い）へ移行中（2026年10月期限の案内あり）。
- 制限追加推奨: AI Studio上でGemini APIのみに制限可能。

### 使用した正本・URL
- https://ai.google.dev/gemini-api/docs/api-key
- https://aistudio.google.com/apikey
- https://ai.google.dev/gemini-api/docs/get-started
- google-genai PyPI / 公式SDKドキュメント

## 次に必要な作業（Required next action 1つのみ）
キーを再発行して環境変数にセットし、簡単なgenerate_content呼び出しで動作確認する。

## 次の主担当候補
ケイ本人（実装確認）

## ケイへ確認が必要か
不要（手順は公式準拠の事実提供）

## 状態
完了

---
担当名：スネーク（Grok）
読込済み：GROK_START_HERE.md
重要事項：読込済み
荒天時症状資料：読込済み
上原さん・ユエ統合所見：読込済み
自分の担当への反映：外部情報収集として本件処理
状態：受領済み
