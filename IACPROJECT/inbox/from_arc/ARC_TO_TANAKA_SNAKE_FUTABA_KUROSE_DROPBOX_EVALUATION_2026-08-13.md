# Handoff: Dropbox Basic 導入可否 — アーク評価

From: アーク
To: 田中 / スネーク / 二葉 / 黒瀬
Date: 2026-08-13 JST
State: 評価返答

## 判定

**条件付き導入**

Dropbox Basic は、IACProject の基幹ストレージやバックアップ本体にはしない。
ただし、**大きめバイナリ・原資料・端末間受け渡しの補助レイヤー**として、用途を限定して導入する価値はある。

## 主理由

1. GitHub / Dropbox / Obsidian の役割分離は自然
   - GitHub = 正本 / 履歴 / Handoff / コード
   - Dropbox = Git管理に向かない実体ファイルの補助置き場
   - Obsidian = Knowledge Layer / メタ情報 / 関係構造
   この三層は混線させなければ運用しやすい。

2. Dropbox Basic の無料枠は小さい
   - 2026-08-13時点の公式情報では Basic は **2 GB**、リンク可能端末は **最大3台**。
   - 動画素材・高解像度画像・スキャンPDFを恒常保管するには不足しやすい。
   - よって「大きいバイナリの主保管庫」ではなく、選別された原資料・受け渡し・一時保管向けとする。

3. 同期とバックアップを混同しない
   - 同期フォルダでの削除・上書きは事故時に他端末へ伝播し得る。
   - SharedBrain原資料は Dropbox だけを唯一の保存先にしない。
   - 原本または別媒体を保持し、Dropbox は補助コピーとする。

## 必須ルール

### 1. シークレット禁止

Dropbox に以下を置かない。

- APIキー
- トークン
- 秘密鍵
- `.env`
- 認証情報
- その他シークレット

既存境界をそのまま採用する。

### 2. GitHub正本との二重化禁止

以下は Dropbox を正本にしない。

- コード
- Handoff
- Decisions
- CURRENT_STATE
- TASK_GRAPH
- 設計仕様の正本Markdown

正本は GitHub。

### 3. Obsidian Vault 全体の常時同期には使わない

Obsidian の Knowledge Layer 本体と Dropbox 実体ファイルを安易に同一フォルダへ混在させない。

推奨：
- Obsidian = Markdown / メタデータ / リンク
- Dropbox = PDF / 画像 / 動画 / スキャン原本
- Obsidian 側から Dropbox 上の原資料を参照する構造

### 4. SharedBrain原資料

父の設計書・技術メモのスキャン原本は、Dropboxだけを唯一の保存先にしない。

最低でも、
- ローカル原本または外部媒体
- Dropbox補助コピー
- GitHub側に原資料一覧・メタ情報

を分離する。

### 5. 命名

Dropbox側は最低限、以下のように用途を分ける。

- `/SharedBrain/raw/`
- `/RCW/assets/`
- `/Media/source/`
- `/Transfer/temp/`

`/Transfer/temp/` は恒久保存先にしない。

## 将来の自動化

将来自動化する場合も、Dropboxを直接「正本生成先」にしない。

候補フロー：

Dropbox Raw
→ ハッシュ / メタ情報抽出
→ GitHubへ manifest / index を記録
→ Obsidianから Knowledge Layer として参照

実ファイルとメタデータを分離する。

## 他サービス比較

2026-08-13時点の公式無料枠：
- Dropbox Basic: 2 GB / 最大3端末
- OneDrive 無料: 5 GB
- Googleアカウント: 最大15 GB（Drive / Gmail / Photos 共有）

容量だけで見れば Dropbox Basic は不利。

したがって、**Dropbox固有の同期・共有UIを使いたい明確な理由がなければ、容量面では Google Drive / OneDrive の方が有利**。

ただし既存運用への混入を避ける意味では、Dropboxを「IACProject専用の補助箱」として独立させる利点はある。

## アーク結論

Dropbox Basic は **条件付き導入**。

採用するなら位置づけは以下に固定する。

**GitHub = 正本**
**Dropbox = binary/raw auxiliary storage**
**Obsidian = Knowledge Layer**

Dropboxをバックアップ本体・秘密情報置き場・GitHub代替にはしない。

最終採否は、スネーク / 二葉 / 黒瀬の返答と合わせて集約する。
