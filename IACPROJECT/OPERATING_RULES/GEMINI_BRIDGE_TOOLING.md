# GEMINI_BRIDGE_TOOLING — Handoff⇄Gemini API連携 実装仕様

**日時**：2026-08-10 JST
**実装者**：佐藤（Claude Code）
**正本レビュー**：`staging/delivered/2026-08-10_KUROSE_TO_SATO_GEMINI_BRIDGE_REVIEW.md`（黒瀬 APPROVE WITH CONDITIONS）
**状態**：実装済み・selftest全件成功（29/29）／ 実API接続は未検証（ケイのGEMINI_API_KEY設定待ち）

---

## 1. 目的

これまで二葉（Gemini）はGitHub Pullを前提にせず、`HUMAN_BUS_BYPASS_PROTOCOL.md`の「Gemini exception」に従い、アークが単一Packetへまとめてケイが1回渡す運用だった（`04_GEMINI_PROTOTYPE_HANDOFF.md`が定める原型保存原則はこの運用の上に成立している）。

Gemini Bridgeは、この受け渡しのうち機械的な部分（Handoff検出・API呼び出し・応答の生保存・状態更新）だけを自動化する。仕様確定・正本反映・矛盾解決はこれまで通り人/該当AIが行う。

## 2. 自動化境界（レビューで確定。実装で越えない）

| 自動でよい | 止める（Owner/研究判断） |
|---|---|
| Handoff検出 | 正本ファイル（`02_DECISIONS`等）への直接書き込み |
| API呼び出し | 二葉の応答内容の要約・整形・「分かりやすく直す」判断 |
| 応答の生保存（Markdownのまま） | コスト上限到達時の継続可否 |
| ACK/PENDINGフラグ更新（機械的処理のみ） | 既存正本との矛盾の解決（検出して止めるのはBridge、解決は人/該当AI） |
| 規定回数までのリトライ | |

## 3. 監視対象・処理フロー

```
IACPROJECT/inbox/from_arc/    ─┐
IACPROJECT/inbox/from_kei/    ─┼─→ iac-gemini-bridge run
IACPROJECT/inbox/from_gemini/ ─┘
```

`from_kei/`は2026-08-11追加（`$Script:GeminiWatchDirs`、`tools/iac-gemini-bridge.ps1`）。チャット
UI（`IAC-CHAT-UI-001`）からの送信元がケイ固定のため`inbox/from_kei/`に配送されるが、当初Bridgeの
監視対象に含まれておらず、チャットUIから二葉へ送っても自動でAPIが呼ばれない不具合があった
（ケイ・黒瀬・アーク経由のHandoffで指摘、修正依頼）。`from_arc/`と同じ処理ロジックを`from_kei/`にも
適用する形で解消。§3.1の宛先フィルタ（`Test-HandoffAddressedTo -Token gemini`）が冪等性チェックより
先に効くため、`from_kei/`配下の二葉宛以外のHandoff（黒瀬宛・アーク宛等）は自動的にスキップされ、
誤ってGemini APIへ送られることはない（selftest §14で検証済み）。

### 3.1 `from_arc/`・`from_kei/`（二葉宛Handoffの送信）

1. `Get-HandoffDocument`（`iac-console.ps1`のパーサを再利用）でHandoffを解析
2. 宛先が二葉（`Test-HandoffAddressedTo -Token gemini`）でなければ対象外
3. 冪等性チェック：状態ファイルで既に終端状態なら再処理しない
4. 往復上限チェック：同一スレッド（Task ID優先、なければファイル名から推定）で `to_gemini` 方向の試行が3回を超えたら`HELD_ROUNDTRIP_LIMIT`
5. コスト上限チェック：当月`est_cost_yen`が2,000円に達していたら`HELD_COST_CAP`
6. Gemini API呼び出し（最大3回、バックオフ2/4/8秒）。失敗し尽くしたら`FAILED_RETRY_EXHAUSTED`
7. 応答に宛先ヘッダ（`To:`/`宛先:`）が無い、または解決不能なら`HELD_NO_TO_HEADER`（staging保存、inboxへは置かない。宛先の推測はしない）
8. 応答に断定語（決定/確定/採用/finalize/decide/adopt等、機械的検出）を含むなら`HELD_DECISION_LANGUAGE`（staging保存。誤検知は許容、見逃しより安全側）
9. 上記いずれにも該当しなければ `IACPROJECT/inbox/from_gemini/` へ生Markdownのまま保存し`SENT`

### 3.2 `from_gemini/`（既存・手動投入分の検証登録）

APIは呼ばない。宛先ヘッダの有無・断定語の有無だけを検証し、状態ファイルへ`ACK`または`HELD_*`として登録する（3.1の7・8と同じ基準）。

## 4. 状態ファイル（ACK/PENDING、one writer原則）

- パス：`IACPROJECT/ROUTER/GEMINI_BRIDGE_STATE.md`
- 書き込み者：`iac-gemini-bridge`のみ。他ツール・手動編集は禁止
- **`IACPROJECT/CURRENT_PENDING.md`（アーク管理）とは別系統**。混同しないこと。CURRENT_PENDING.mdのper-member状態はCLAUDE.mdの禁止事項によりBridgeも佐藤も独断更新しない
- 列：`handoff_id | thread_key | direction | status | attempts | round_trip | last_updated | note`
- status値：`PENDING / SENT / ACK / HELD_NO_TO_HEADER / HELD_DECISION_LANGUAGE / HELD_ROUNDTRIP_LIMIT / HELD_COST_CAP / FAILED_NO_API_KEY / FAILED_RETRY_EXHAUSTED`

## 5. コスト上限

- パス：`IACPROJECT/ROUTER/GEMINI_BRIDGE_COST_LOG.md`
- 月次上限：**2,000円**（2026-08-10 ケイ確定）
- 1回あたり推定コスト：3円（暫定値。実コスト確認後にOwnerが見直す。このスクリプトが独断確定しない）
- 上限到達で自動停止。続行可否はケイ判断

## 6. 往復ループ防止

- 同一スレッド（`thread_key` = Handoff の Task ID。無ければファイル名から推定）で`to_gemini`方向の送信試行が3回を超えたら停止し、Owner確認へ

## 7. 認証・秘密情報

- APIキーは環境変数 `GEMINI_API_KEY` のみ。リポジトリ・ログへのハードコード/混入は禁止
- ログ・エラーメッセージは`Protect-GeminiBridgeSecret`でAPIキー文字列をredactしてから出力する
- モデル名は環境変数 `GEMINI_BRIDGE_MODEL` で上書き可能（既定: `gemini-2.0-flash`）

## 8. 二重起動防止

- ロックファイル：`IACPROJECT/ROUTER/.gemini_bridge.lock`（gitignore対象にすること推奨）
- 有効期限15分。期限切れロックは停止プロセスの残骸とみなし奪取する

## 9. ファイル構成

| ファイル | 役割 |
|---|---|
| `tools/iac-gemini-bridge-lib.ps1` | 状態/コストログ/ロック/宛先検証/断定語検出/リトライ付きAPI呼び出しの共有関数 |
| `tools/iac-gemini-bridge.ps1` | メイン実行（`run` / `status`）。`iac-handoff-lib.ps1`・`iac-console.ps1`のパーサを再利用 |
| `tools/iac-gemini-bridge.cmd` | cmdラッパー |
| `tools/iac-gemini-bridge-selftest.ps1` | 人工fixture・一時ディレクトリ・モックAPIのみを使うロジック自己テスト（実API・実リポジトリ・gitに触れない） |
| `tools/tests/fixtures/gemini_bridge/` | selftest用の人工Handoff fixture（実案件を含まない） |
| `.github/workflows/gemini-bridge.yml` | トリガーをローカル手動実行からGitHub Actionsへ移す場合のworkflow（§13） |

## 10. 使い方

```
iac-gemini-bridge run              inbox/from_arc・from_kei・from_gemini をスキャンして処理
iac-gemini-bridge run -WhatIf      送信対象を表示するだけ（API呼び出し・書き込みなし）
iac-gemini-bridge run -NoGit       処理は行うがgit commitはしない
iac-gemini-bridge run -Push        commit後にgit pushまで行う（§13のActions実行専用。ローカルでは使わない）
iac-gemini-bridge status           状態・コストログの要約（読み取り専用）
```

前提：`$env:GEMINI_API_KEY` を設定しておくこと。未設定の場合は`FAILED_NO_API_KEY`として記録され、実APIへは到達しない。

## 13. GitHub Actions化（トリガーのクラウド移行、2026-08-11 黒瀬要件→佐藤実装）

**目的**：スマホから`inbox/from_arc/`等へGitHub Pushするだけで、Surface/PCの起動なしにBridgeを自動実行する。

**トリガー**：`.github/workflows/gemini-bridge.yml`。`push`イベント、対象パスは`IACPROJECT/inbox/from_arc/**`・`IACPROJECT/inbox/from_kei/**`・`IACPROJECT/inbox/from_gemini/**`のみ（§3の監視対象と一致。`from_kei/**`は2026-08-11追加。他の`from_*`はBridge内部で対象外になるため監視しない）。

**状態・コストログの永続化**：既存設計のまま変更なし。`GEMINI_BRIDGE_STATE.md`・`GEMINI_BRIDGE_COST_LOG.md`は元々`IACPROJECT/ROUTER/`配下のリポジトリ管理ファイル（.gitignore対象外）で、Bridge自身がcommitする。Actions環境が使い捨てでも、commit後に`git push`まで行えばリポジトリ側に状態が残る。この`push`だけをローカル運用と切り分けるため`-Push`スイッチを追加した（§10）。ローカルではケイ/佐藤が内容を確認してから手動push、Actionsでは`-Push`で自動push、という分岐。

**push失敗時の扱い**：`-Push`時、push失敗→`pull --rebase`→再pushを1回だけ試み、それでも失敗したらジョブを失敗させる（`throw`）。ローカルcommitがActions環境の消滅とともに失われることを明示するため。

**無限ループの検討**：`from_gemini/`への応答保存commitをActionsがpushしても、GITHUB_TOKENによるpushはデフォルトで新たなworkflow runをトリガーしないため、自己再帰は起きない。

**認証・秘密情報**：`GEMINI_API_KEY`はGitHub Secrets（リポジトリ Settings → Secrets and variables → Actions）に登録する。Windows環境変数の値はActions環境からは参照できないため、Secretsへの登録がケイ側で別途必要（§7の「APIキーは環境変数のみ」という制約はActions内でも`env:`経由で維持している）。

**リポジトリ権限**：workflow内で`git push`するため、リポジトリ設定 Settings → Actions → General → Workflow permissions を「Read and write permissions」にする必要がある（既定は読み取りのみで、その場合push権限エラーになる）。

**実疎通テスト結果（2026-08-11、ケイのSecrets登録・Workflow permissions変更後に実施）**：

1. **1回目のテストで不具合発見**：`run 31436080377`はAPI呼び出し・HELD判定まで正常動作（応答に宛先ヘッダが
   ないためテストHandoff通り`HELD_NO_TO_HEADER`として保留）したが、`git commit`は成功したのに`git push`が
   実行された形跡がなく、リポジトリに全く反映されなかった。
2. **原因**：`iac-console.ps1`が同名の`[switch]$Push`paramを持っており、`iac-gemini-bridge.ps1`が
   `iac-console.ps1`をdot-sourceする際に呼び出し元の`$Push`がデフォルト（`$false`）で上書きされていた
   （§13冒頭で追加した`-Push`スイッチ自体が、既存の`$Command`衝突バグ―§本文中に既出―と全く同型の
   バグを新たに持ち込んでいた）。デバッグ用に`git status`をworkflow内に一時追加して`Your branch is
   ahead of 'origin/main' by 1 commit` / `nothing to commit`というログで確定した。
3. **修正**：dot-source前に`$Script:BridgePush = [bool]$Push`へ退避し、`Publish-GeminiBridgeFile`内の
   参照もそちらに変更（`tools/iac-gemini-bridge.ps1`）。selftest 33/33成功、既存ロジックへの影響なし。
4. **再検証**：修正後`run 31440029489`で、テストHandoff3件すべてが正しく検出・処理され、`GEMINI_BRIDGE_
   STATE.md`・`GEMINI_BRIDGE_COST_LOG.md`の更新がActionsから自動commit・pushされることを確認
   （commit `1ee78b4`）。コスト計上：3回×3円=9円（月次上限2000円のうち、cap_status: OK）。

これによりActions化は実疎通確認まで完了した。テスト用に投入した3件のHandoff
（`IACPROJECT/inbox/from_arc/2026-08-11_ARC_TO_GEMINI_BRIDGE_ACTIONS_{LIVE_TEST,DEBUG_TEST,FIX_VERIFY}.md`）
はTask IDに`TEST`と明記済み・実害なし（断定語なし、宛先ヘッダなしで保留のみ）。

## 11. selftest結果

2026-08-10時点：29項目全て成功。検証済み内容：正常送信、冪等性、宛先ヘッダ欠落時の保留、断定語検出時の保留、リトライ上限、APIキー未設定時の即時失敗、往復上限、コスト上限、二葉宛でないHandoffの除外、`from_gemini`既存ファイルの検証登録。

実行：`powershell -NoProfile -ExecutionPolicy Bypass -File tools\iac-gemini-bridge-selftest.ps1`

## 12. 確定していないこと（本実装では触れていない）

- 実Gemini APIとの疎通確認（`GEMINI_API_KEY`未設定のため未実施。ケイのキー設定後に`iac-gemini-bridge run -WhatIf`→実行の順で確認すること）
- 1回あたり推定コスト（3円）の実測による見直し
- 既存の手動Packet運用（アーク単一Packet方式）を廃止する条件・判定者（Questions queue未解決）
- `IACPROJECT/inbox/from_gemini/`へ保存された応答が、さらに別AIへの新規Handoffとして自動的に転送されるかどうか（現状は生保存・登録のみで、後続配送は行わない）

---

**Copyright: ケイ**
