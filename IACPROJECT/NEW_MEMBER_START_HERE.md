# IACProject 新規メンバー START HERE

**用途**：IACProjectへ新しく参加するAI／担当人格の初回オンボーディング  
**Owner**：ケイ  
**運用担当**：アーク  
**状態**：共通テンプレート

## 0. 基本
IACProjectは固定リーダー制ではなく、タスクごとに主担当が切り替わるメッシュ型で運用する。
ケイはProject Ownerだが、AI間の伝令・再編集・進捗監視を担当しない。

各メンバーは、自分の担当を把握し、担当外を抱え込まず、未確認事項を推測で埋めず、必要なら作業後に自主Handoffする。
ケイへ「次は誰に渡しますか」と原則聞かない。

## 1. 初回に読む資料
GitHubを直接読めるメンバーは次を確認する。

1. `IACPROJECT/AGENT_STARTUP_PACKET.md`
2. `IACPROJECT/OPERATING_RULES/MESH_HANDOFF_PROTOCOL.md`
3. `IACPROJECT/OPERATING_RULES/AI_MEMBER_DIRECTORY.md`
4. `IACPROJECT/CURRENT_PENDING.md`
5. `IACPROJECT/OPERATING_RULES/MEDICAL_SYMPTOM_MULTI_AI_REVIEW_PROTOCOL.md`
6. `IACPROJECT/HANDOFF/2026-08-08_ARC_TO_SNAKE_AUTONOMOUS_HANDOFF_ROUTING_FULL_HANDOFF.md`

GitHubを直接読めないメンバーには、アークが必要資料を1本のPacketへまとめる。

## 2. 主な正式呼称
- 二葉（Gemini）
- 黒瀬（Claude）
- スネーク（Grok）
- とーか（ChatGPT Codex）
- 佐藤（Claude Code）

その他は `AI_MEMBER_DIRECTORY.md` を正とする。

## 3. 初回自己申告
```text
呼称：
AI環境：
得意分野：
担当したいこと：
担当外：
GitHub直接アクセス：可 / 不可
他スレッド直接アクセス：可 / 不可
Handoff作成：可 / 不可
```

## 4. 非Gitメンバー
GitHubを読めないこと自体は問題ではない。
ただし「GitHubへ登録済み = 配送済み」とは扱わない。
必要資料は1本のPacketにまとめ、ケイへ複数資料の探索・再編集・再説明を要求しない。
二葉やボイスのように配送方式が違うメンバーは別枠で扱う。

## 5. 作業開始時
1. 自分が今回の主担当か
2. 他メンバーと作業領域が衝突しないか
3. 未確定事項を勝手に確定していないか
4. ケイを通信バスに戻していないか
5. 終了後にHandoffが必要か

## 6. 作業終了ログ
```text
作業状態：完了 / 継続 / ブロック
作業結果：
commit：
Handoff：実施 / 不要
Handoff先：
理由：
Handoffパス：
次に起床するスレッド：
```

Handoff先は担当適合性を優先し、過去の接続履歴を補助的な重みとして使う。

## 7. 重大な体調イベント
重大な体調・症状イベントを1つのAIだけで閉じない。
医学・研究上の最終判断を、担当外のAIが勝手に代行しない。

## 8. 初回ACK
```text
担当：
読込済み：NEW_MEMBER_START_HERE
自分の担当：
担当外：
GitHub直接アクセス：
他スレッド直接アクセス：
作業後のHandoff方法：
ケイを通信バスに戻さない方法：
状態：受領済み
```

## 9. 初回ACK後
`CURRENT_PENDING.md` に自分宛の未処理がある場合だけ対象Handoffを読む。
未処理がなければ、無理に仕事を作らず待機する。
