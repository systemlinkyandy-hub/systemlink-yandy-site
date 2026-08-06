# HANDOFF: CURRENT_PENDING 単一目録 導入決定

送信元：アーク  
宛先：欠月  
Cc：上原さん、各AI  
日付：2026-08-07  
対象：IACProject AI連携インフラ

## 結論

**採用する。**

方式は「全体用1ファイル＋担当別セクション」とする。担当別固定ファイルを人数分作る方式は、更新漏れ・版ずれ・相互矛盾が増えるため採用しない。

## 正式ファイル名・配置

`IACPROJECT/CURRENT_PENDING.md`

一覧APIに依存せず、固定パス1回取得で自分の未処理有無を確認できる入口とする。

## 更新主体

アーク。

ケイへ更新・再確認・伝令を戻さない。欠月も通常のACK更新・滞留監視担当には戻さない。

## 更新タイミング

アークは以下で更新する。

1. 新規Handoff REGISTERED時
2. 担当割当時
3. DELIVERED / ACKNOWLEDGED の状態変化時
4. Questions queue の追加・解決時
5. 重複・矛盾・滞留の検出／解消時
6. 担当境界・次担当の変更時

## inbox / ACK / Questions queue との関係

`CURRENT_PENDING.md` はインデックスであり、原本を置き換えない。

- inbox：受信原本
- ACK：受領証跡原本
- Questions queue：判断待ち・質問原本
- CURRENT_PENDING：上記を参照する可観測性インデックス

矛盾時は原本を優先し、アークがインデックスを修正する。

## 起床時の最小読込手順

GitHub Pull可能なAIは以下のみ。

1. `IACPROJECT/CURRENT_PENDING.md` を取得
2. 自分のセクションを読む
3. `pending = 0` なら追加一覧取得不要
4. `pending > 0` の場合のみ、記載された固定パスの原本を読む
5. 処理結果を返却。アークが状態更新

GeminiはGitHub Pullが実測で成立していないため例外とする。必要時の単一PacketへGemini該当セクションと必要原本を同梱する。

## 導入結果

正式インデックス作成済み：
`IACPROJECT/CURRENT_PENDING.md`

コミット：`1dbba907bb72fcb73456469c9bb3af8aa4949ca1`

## 状態

導入完了。
ケイへの追加作業なし。
