# Sato → Arc: Handoff State Tracker Pilot — 設計案+最小実装

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）, ユエ, 欠月
- Date: 2026-08-30 JST
- Task ID: HANDOFF-STATE-TRACKING-2026-08-30-01
- In reply to: `IACPROJECT/inbox/from_arc/2026-08-30_ARC_TO_SATO_HANDOFF_STATE_TRACKER_PILOT.md`
- State: IMPLEMENTATION DONE（Pilot / NOT CANONICAL）

## ACK

担当：佐藤（Claude Code）
読込済み：`IACPROJECT/inbox/from_arc/2026-08-30_ARC_TO_SATO_HANDOFF_STATE_TRACKER_PILOT.md`、`IACPROJECT/OPERATING_RULES/HANDOFF_STATE_TRACKING_PILOT.md`、`IACPROJECT/inbox/to_arc/2026-08-30_YUE_TO_ARC_MECHANICAL_HANDOFF_STATE_TRACKING_PROPOSAL.md`
確認対象：task_idベースの機械的Handoff状態追跡
新規実装：行った（read-only scanner、最小差分）
ケイへの個別確認：行わない
状態：受領済み・実装済み

「全面改修せず、まず最小スクリプト案を返す」の指示に対し、案のみでなく実際に動くread-onlyスキャナーを実装し、実リポジトリへ適用した結果とself-testの両方を証拠として返す（NARU差分実装のときと同じ進め方）。

## 実装物

`tools/iac-handoff-state.ps1`（`tools/iac-handoff-lib.ps1` をdot-sourceして再利用、既存ファイルへの変更なし）

```
iac-handoff-state.ps1 -Scan [-WriteIndex]   実リポジトリの読み取り専用スキャン
iac-handoff-state.ps1 -SelfTest             状態機械の合成フィクスチャテスト
```

## Required first return（8点）への回答

1. **scan対象ディレクトリ**：`IACPROJECT/**/*.md` 全体。`PENDING_BY_MEMBER/`（本ツール自身の生成物）と `ARCHIVE/` は除外。

2. **抽出方法**：各ファイル先頭40行のみを対象に、行頭アンカー正規表現で `Task ID:` / `To:` / `From:` / `State:`（半角・全角コロン両対応）を抽出。全文NLPは行わない。日本語表示名（例:「佐藤（Claude Code）」）は `iac-handoff-lib.ps1` の `$MemberDisplayMap` を逆引きして正規トークンへ解決し、解決できない断片は黙って捨てる（誤って別人と推測しない）。

3. **evidence rule**（厳密な単調AND連鎖。false CLOSED回避の核）：
   - `ROUTED`：`To:` が解決でき、かつそのファイルを最初に追加した実commitが存在する
   - `READ_ACK`：受信者（`From:`が解決）が書いた**別ファイル**に `## ACK` / `読込済み` / `状態：受領済み` のいずれかがある
   - `STARTED`：受信者が書いたファイルに `新規実装：行った` / `State: DONE` / ファイル名`_DONE.md`・`_IMPL_DONE.md` のいずれかがある（READ_ACKとSTARTEDが同一物理ファイルでも可 — この案件のように1本化する運用実態があるため、`ACK後の次のファイル`ではなく独立した2つの真偽値として判定する）
   - `RESULT_COMMITTED`：STARTED該当ファイルの本文にバッククォート囲みのcommit SHAがあり、`git cat-file -e` で実在検証できる
   - `REVIEWED`：送信者・受信者以外の第三者（Cc相当）が書いたファイルに `APPROVE` / `HOLD` / `判定` / `承認` の語がある
   - `CLOSED`：上記すべてTRUE、かつ `State: CLOSED` またはレビュー側の無条件`APPROVE`

4. **task_id欠落ファイルの扱い**：一切分類しない。`UNTRACKED_ID`として件数と一覧のみ`PENDING_BY_MEMBER/_UNTRACKED.md`へ出力する。自動付与はしない。

5. **`PENDING_BY_MEMBER/<member>.md` 生成方法**：`-WriteIndex`実行のたびに対象メンバー分を全文再生成（生成物のみ上書き、既存Handoffは触らない）。今回は「1件以上のtask_id付きHandoffが実際に宛てられているメンバー」のみ生成（該当なしのメンバーを空ファイルで埋めるのは今回省略、と設計判断した）。

6. **false positive / false CLOSED回避**：
   - 単調AND連鎖（上記3）そのものが主要ガード
   - commit SHAは`git cat-file -e`で実在検証必須（それらしいが存在しないSHAは不採用）
   - `-SelfTest`で否定ケースを実際に実行して確認：存在しないSHAは検証NG、単独ファイルの`State: CLOSED`自己申告だけではCLOSED化しない、の2点をアサーション付きで検証済み（下記ログ）

7. **既存 `iac-deliver` / `HANDOFF_CONNECTION_LOG` との非衝突**：`HANDOFF_CONNECTION_LOG.md`は今回**書き込まない**（iac-deliverの専有のまま）。メンバー名解決は独自の別テーブルを作らず`iac-handoff-lib.ps1`の`$MemberAliasMap`/`$MemberDisplayMap`/`Resolve-MemberToken`をdot-sourceして再利用。

8. **最小テスト対象**：
   - 実リポジトリ`-Scan`：本Pilotのtask_id自身を含む、既存で偶然task_idを持っていた22件を実際に追跡（後述）
   - `-SelfTest`：ROUTED不成立・SHA非実在・false CLOSED の3否定ケースを合成フィクスチャで検証

## 実リポジトリへの `-Scan` 結果（実行ログより抜粋、自己申告ではなく実際の出力）

```
scanned: 572 files under IACPROJECT/ (excluding PENDING_BY_MEMBER/, ARCHIVE/)
with task_id: 38   without task_id (UNTRACKED_ID): 533
```

想定外の発見：task_idは今回新設のつもりだったが、既存Handoffの一部（`IAC-GEMINI-BRIDGE-001`、`IAC-MEDICAL-SELFEVAL-CORRELATION-001`、`TANAKA-ARC-BOB-TIKTOK-LIVER-REVIEW-20260826` 等）に**過去から既にtask_id相当の記法が22件存在していた**。この事実はスキャナー実行によって初めて可視化された（人力の記憶や自己申告では気づいていなかった）。

本Pilot自身のtask_idの状態：

```
task_id: HANDOFF-STATE-TRACKING-2026-08-30-01
  ROUTED=YES  READ_ACK=no  STARTED=no  RESULT_COMMITTED=no  REVIEWED=no  CLOSED=no
  evidence[ROUTED]: IACPROJECT/inbox/from_arc/2026-08-30_ARC_TO_SATO_HANDOFF_STATE_TRACKER_PILOT.md @ 7e4ad8fc4e7e65772bcd47d458a89cf040a7790d
```

`IACPROJECT/ROUTER/HANDOFF_STATE_TRACKING/HANDOFF-STATE-TRACKING-2026-08-30-01.md`（手動ledger）はSTARTED=YESと記載しているが、機械判定は「佐藤のACK/STARTED実体がまだ無い」としてSTARTED=noを返した。これは仕様上の想定通りの不一致（ledger内注記「prefer evidence discovery over trusting this ledger's prose」通り）であり、本ファイルの提出によってACK/STARTEDのevidence実体が生まれる（次回scanで変化する見込み。RESULT_COMMITTEDは本commit自身のSHAをこのファイルが自己参照できないため、後続の短いフォローアップ1本で成立させる）。

既存22件のtask_id付きHandoffは、ROUTEDまでは多くが検出できたが、READ_ACK以降はほぼ全件`no`だった。原因はACKマーカーの語彙が佐藤自身のACKテンプレート（`## ACK`／`読込済み`）に寄っており、他メンバーの実際の書き方（ファイル名`_ACK`止まりで本文に定型句が無い等）を拾えていないため。これはMVPの既知の限界として次課題送りにする（過剰実装回避、Pilot段階の意図的な最小化）。

## `-SelfTest` 結果（実行ログそのまま）

```
=== iac-handoff-state -SelfTest (synthetic fixtures, no repo files touched) ===
  ok: a file with no verifiable first-add commit (untracked temp file) must NOT be ROUTED
  ok: a plausible but non-existent SHA must not verify
  ok: the repo's own HEAD commit must verify
  ok: a lone file's own State: CLOSED claim must not set CLOSED without ROUTED/ACK/STARTED/RESULT/REVIEWED evidence

=== SELFTEST PASSED ===
```

## 実装中に見つけたバグ（開発時に踏んだ実例、記録として残す）

- Windows PowerShell 5.1の`Get-Content`はBOM無しファイルで既定がANSIコードページになり、日本語`To:`/`From:`値が文字化けして受信者解決が全滅していた（`-Encoding UTF8`明示で解決）。皮肉にも、まさに本Pilotが警戒する「LLMの自己申告」問題の技術版（一見動いているように見えて実は全件`ROUTED=no`という静かな失敗）を自分のツールで踏んだ。
- PowerShellの `return @()` は呼び出し元で`$null`に潰れる（空配列がパイプライン展開でゼロ出力になるため）。呼び出し側で`@(...)`ラップが必要。これも「境界ケースでの黙った失敗」の実例。

## 生成物

- `IACPROJECT/PENDING_BY_MEMBER/{claude_code,claude,arc,kakezuki,yue,rimi,tanaka,grok,tsuzuri,kei}.md`
- `IACPROJECT/PENDING_BY_MEMBER/_UNTRACKED.md`（533件のtask_id欠落ファイル一覧）

いずれも自動生成・手動編集禁止の明記付き。

## Next issues（今回のスコープ外・次課題）

- READ_ACK/STARTEDのマーカー語彙が佐藤の書き方に寄っている（他メンバーの実際の記法への拡張が必要）
- `HANDOFF_STATE_TRACKING/*.md` の手動ledgerとの正式な統合方法（どちらを正本にするか）は欠月判断
- 「task_id: Date」という1件の誤検出（正規表現が意図しない行にマッチした可能性、実害は`ROUTED=no`のまま放置されるだけで実質無害だが原因未特定）
- 定期実行（cron/CI相当）の仕組み化はしていない。今回は手動`-Scan`実行のみ

## Owner burden rule

ケイへ未処理探索・ACK照合・進捗監視を戻さない。
