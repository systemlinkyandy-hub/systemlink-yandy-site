# AUTONOMOUS_HANDOFF_TOOLING — 自主Handoffルーティング実装仕様

**日時**：2026-08-08 JST
**実装者**：Claude Code（モデル：Claude Fable 5）
**正本設計**：`IACPROJECT/HANDOFF/2026-08-08_ARC_TO_SNAKE_AUTONOMOUS_HANDOFF_ROUTING_FULL_HANDOFF.md`（commit `8e01b21`）
**状態**：実装済み / ケイの確認待ち（アーク権限復帰はケイの明示宣言まで行わない）

---

## 1. 何が追加されたか

| 正本§9の要求 | 実装 |
|---|---|
| 1. Handoff履歴の集計 | `IACPROJECT/ROUTER/HANDOFF_CONNECTION_LOG.md`（既存48件をファイル名からバックフィル済み） |
| 2. AI間接続回数の参照 | `iac-handoff-log tally`（from→to回数を降順表示、正式呼称で表示） |
| 3. 担当領域との適合判定 | `AI_MEMBER_DIRECTORY.md` の早見表を第一基準とする（下記選択手順） |
| 4. 自主的な次Handoff先選択 | Claude Code恒久指示（リポジトリ直下 `CLAUDE.md`）に選択手順を組込み |
| 5. 終了時のHandoff自主実行 | 同上（作業終了時プロトコル） |
| 6. コミット番号の併記 | `iac-deliver` がファイル単位のcommit hashを接続ログに自動記録 |
| 7. Handoff先・理由・パスの終了ログ | 終了ログ定型（§4）を恒久指示化 |
| 8. 次にケイが起床すべきスレッドの明示 | 終了ログ定型に含む |
| 9. 二葉（Gemini）の配送方式別枠 | 選択手順に別枠規定（§3） |
| 10. 固定リーダーなしのメッシュ維持 | 選択手順は「タスク適合性→接続強度」の順で、固定の既定宛先を持たない |

## 2. 接続ログ仕様

- ファイル：`IACPROJECT/ROUTER/HANDOFF_CONNECTION_LOG.md`（markdown表、1行=1Handoff）
- 列：`date / from / to / task / handoff_path / commit`
- 書き込み経路：
  - `iac-deliver` 実行時に自動追記（FROM判定できた配送のみ。unsorted行きは記録しない）
  - 手動配置した場合は `iac-handoff-log add -From x -To y -HandoffPath ... -Commit ...`
- 重複防止：同じ `handoff_path` は二重記録されない（push失敗→再実行でも安全）
- 集計：`iac-handoff-log tally`
- バックフィル：`iac-handoff-log backfill`（既存ファイル名から補完。再実行しても重複しない）

### 記録の限界（了解事項）

- ファイル名からの推定であり、**複数宛Handoffは先頭の宛先1名のみ**記録される（数え漏れ許容。回数は補助指標であり、止まらないことを優先）
- `kakezuki` / `ketsugetsu` / `ketsuzuki` / `kaduki` / `ketsuki` は同一人物（欠月）の表記ゆれとして **`kakezuki`（かけづき）** に統合する（2026-08-08 ケイ確認済み）
- `snake→grok`、`kurose→claude`、`futaba→gemini`、`ark→arc` も同様に統合済み

## 3. 自主Handoff先の選択手順（全AI共通・Claude Codeは恒久指示化済み)

1. 作業終了時、次に処理すべき内容があるか判断する
2. ある場合、`AI_MEMBER_DIRECTORY.md` §7 の早見表で担当適合するメンバーを候補にする
3. 候補が複数なら `iac-handoff-log tally` の接続回数を**補助的な重み**として使う（回数が多い相手へ機械的に送ることはしない）
4. **二葉（Gemini）別枠**：二葉を選ぶこと自体は可能だが、GitHub登録だけでは配送完了と扱わない。二葉宛はアーク（または当時のインフラ担当）が単一Packetへまとめる工程が必要である旨を終了ログに明記する。配送方式の差を理由に二葉との接続強度を低く評価しない
5. Handoffファイルを作成し、`staging\` へ置いて `iac-deliver` で配送する（接続ログは自動記録される）
6. ケイへ終了ログ（§4）を返す

## 4. 作業終了ログの定型（正本§4準拠）

```text
作業状態：完了／中断（理由）
commit：xxxxxxxx（複数あれば列挙）
Handoff：実施／不要
Handoff先：正式呼称（基盤名）
理由：担当適合性＋接続履歴の根拠を1〜2行
Handoff：IACPROJECT/...（パス）
次に起床するスレッド：〇〇（不要なら「起床不要」）
```

正式呼称：黒瀬（Claude）／二葉（Gemini）／スネーク（Grok）／佐藤（Claude Code、2026-08-08 ケイ承認）。ChatGPT Codexは呼称未確定のため「ChatGPT Codex」または「Codex」とし、仮名を付けない。

## 5. 確定していないこと（本実装では触れていない）

- 接続強度の閾値・重み付けアルゴリズムの正式採用（正本§11によりスネーク・Claude Fableとも独断確定しない）
- アーク権限の復帰（ケイの明示宣言まで現状維持）
- ChatGPT Codexの呼称
- `CURRENT_PENDING.md` の per-member 状態更新（一時代理スネークの担当のまま）

---

**Copyright: ケイ**
