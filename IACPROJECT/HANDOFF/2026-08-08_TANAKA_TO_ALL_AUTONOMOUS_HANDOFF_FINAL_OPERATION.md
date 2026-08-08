# HANDOFF：自主Handoff運用・アーク権限復帰後の最終運用共有

**日時**：2026-08-08 JST  
**送信元**：田中  
**宛先**：ALL MEMBERS  
**状態**：OPERATIONAL / SHARED  

---

## 1. 結論

自主Handoff実装完了後は、アークへ通常インフラ権限を戻し、以後ケイが毎回「次は誰へHandoffするか」を指定する運用を終了する。

`CURRENT_PENDING.md` の現行状態では、自主Handoffは **MODIFICATION COMPLETE / ARC AUTHORITY RESTORED** として扱う。

---

## 2. 自主Handoffの基本ルール

作業終了時、次に処理すべき内容がある場合は、各AIが自主的に次Handoff先を選ぶ。

選択順は次の通り。

1. タスク担当適合性を優先する。
2. 候補が複数いる場合、Handoff接続履歴・接続回数を補助指標として参照する。
3. 接続回数が多い相手へ機械的に送るのではなく、担当適合性を第一基準とする。
4. 固定リーダーや固定宛先を作らず、メッシュ状の協働を維持する。
5. ケイへ「次は誰に渡すか」を原則質問しない。

接続ログ：`IACPROJECT/ROUTER/HANDOFF_CONNECTION_LOG.md`  
実装仕様：`IACPROJECT/OPERATING_RULES/AUTONOMOUS_HANDOFF_TOOLING.md`

---

## 3. 作業終了時の必須出力

各AIは作業終了時に、最低限以下を出力する。

```text
作業状態：完了／中断（理由）
commit：xxxxxxxx（複数あれば列挙）
Handoff：実施／不要
Handoff先：正式呼称（基盤名）
理由：担当適合性＋接続履歴の根拠を1〜2行
Handoff：IACPROJECT/...（パス）
次に起床するスレッド：〇〇（不要なら「起床不要」）
```

ケイはこの終了ログを見て作業終了を判断し、必要な場合のみ次スレッドを起床する。

---

## 4. 正式呼称

- 二葉（Gemini）
- 黒瀬（Claude）
- スネーク（Grok）
- とーか（ChatGPT Codex）
- 佐藤（Claude Code）

その他メンバーは既存の正式呼称を維持する。

---

## 5. 二葉（Gemini）の配送例外

二葉はGitHub Pullを前提にしない。

二葉をHandoff先として選択すること自体は可能だが、GitHub登録だけで配送完了とは扱わず、アーク（または当時のインフラ担当）が単一Packetへ必要情報をまとめる工程を必須とする。

配送方式の差を理由に、二葉との接続強度を低く評価しない。

---

## 6. 医療・体調イベントの境界

重大な体調・症状イベントは単独AIで閉じない。

`IACPROJECT/OPERATING_RULES/MEDICAL_SYMPTOM_MULTI_AI_REVIEW_PROTOCOL.md` を正本とし、既存の観察事実・時系列・過去の同型反応・介入前後の変化を保持したまま、必要時に独立レビューへ回す。

---

## 7. ケイの役割

ケイはAI間の伝令、毎回のHandoff先指定、素材の再説明・再編集を担当しない。

ケイは各AIの終了ログを確認し、必要な場合に次スレッドを起床し、最終判断のみ保持する。

---

**追加作業**：なし。各AIは次回起床時から本運用を継続適用する。
