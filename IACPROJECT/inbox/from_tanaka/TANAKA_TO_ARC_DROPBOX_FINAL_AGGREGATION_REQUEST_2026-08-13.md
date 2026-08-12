# Handoff: Dropbox評価4者集約・最終採否依頼

From: 田中
To: アーク
Cc: スネーク / 二葉 / 黒瀬 / ケイ
Date: 2026-08-13 JST
State: 集約依頼

## Facts

田中から依頼したDropbox Basic導入可否レビューについて、4者分の評価が揃ったため、アークへ最終集約を依頼する。

### 黒瀬
判定：条件付き導入
- GitHub=正本、Dropbox=補助という責務分離は妥当
- APIキー・トークン・秘密鍵はDropbox禁止
- 双方向同期は当面組まない
- 重要原資料はDropbox一本化しない
- 共有リンク権限ミスに注意

既存返答：
`IACPROJECT/inbox/from_claude/2026-08-13_KUROSE_TO_ARC_DROPBOX_EVALUATION.md`

### スネーク
判定：条件付き導入だが優先度低・代替推奨
- Dropbox Basic 2GBは動画・画像・スキャンPDF用途には小さすぎる
- Google Drive 15GB / OneDrive 5GBの方が現実的
- Dropboxは一時受け渡し用途なら可
- シークレット禁止、原資料一本化禁止

既存返答：
`IACPROJECT/inbox/from_grok/SNAKE_TO_ARC_KUROSE_FUTABA_DROPBOX_BASIC_EVAL_2026-08-13.md`

### 二葉
判定：条件付き導入（作業用一次パッシングゾーン限定）
- 実体ファイルとKnowledge Layer側メタ情報の分離は自然
- Dropbox 2GBは原資料アーカイブには不足
- Obsidian / GitHubにはMarkdown・メタ情報・OCR抽出テキスト・URI参照のみを保持
- Dropboxは処理中原資料・端末間一時受け渡し用途に限定
- 長期原資料保管はGoogle Drive 15GBを第一推奨
- `1 Note = 1 Reference` を提案
- APIキー・トークンだけでなく、未整理の個人特定情報もDropboxへ無造作に置かない

### アーク既存評価
判定：条件付き導入
- GitHub = 正本 / 履歴 / Handoff / Code
- Dropbox = binary/raw auxiliary storage
- Obsidian = Knowledge Layer
- バックアップ本体、秘密情報置き場、GitHub代替にはしない

既存返答：
`IACPROJECT/inbox/from_arc/ARC_TO_TANAKA_SNAKE_FUTABA_KUROSE_DROPBOX_EVALUATION_2026-08-13.md`

## 田中側の暫定判断

ケイはDropbox導入を一旦保留する意向。
4者とも「使うなら補助・一時レイヤー」としては許容しているが、無料2GBの容量面から積極導入理由は弱い。

現時点の自然な構成案：
- GitHub = 正本・履歴
- Obsidian = Knowledge Layer
- Google Drive等 = 長期原資料・大容量バイナリ保管候補
- Dropbox = 必要時のみ一時パッシングゾーン

## Required next action

アークは4者評価を正式に集約し、
1. Dropboxの最終採否
2. 採用する場合の限定用途
3. Google Drive / OneDriveを次に比較する必要性
4. SharedBrain原資料の最終ストレージ方針
を短く確定して返却すること。

ケイへ追加説明・再確認を要求しないこと。
