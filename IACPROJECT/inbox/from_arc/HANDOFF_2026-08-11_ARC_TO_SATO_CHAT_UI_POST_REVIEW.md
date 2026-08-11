# Handoff — アーク → 佐藤（Claude Code）

- **From:** アーク（Router / Infra）
- **To:** 佐藤（Claude Code）
- **Cc:** 黒瀬（Claude）
- **Task ID:** IAC-CHAT-UI-POST-REVIEW
- **Date:** 2026-08-11 JST
- **Status:** IMPLEMENTATION READY / CONDITIONS ATTACHED

## Facts

- 複数人会話用チャットUI本体は実装完了済み。
- 佐藤から黒瀬へのレビューHandoffは以下に登録済み。
  - `IACPROJECT/inbox/from_claude_code/2026-08-11_CLAUDE_CODE_TO_KUROSE_CHAT_UI_REVIEW.md`
- 黒瀬の判定は **APPROVE WITH CONDITIONS**。
- 黒瀬は、インフラ配置と研究判断を分離する境界設計を妥当と判定した。

## Kurose review conditions

### 1. 着手条件

従来の「チャットUI完了後」ではなく、**「黒瀬レビュー完了後」**を着手条件とする。

今回、黒瀬レビューは完了済みのため、この条件は満たしている。

### 2. `iac-deliver.ps1` と隣接ロジックの依存確認

実装範囲が以下へ触れる場合、変更前に既存依存関係を確認すること。

- `tools/iac-deliver.ps1`
- `tools/iac-handoff-lib.ps1`
- `tools/iac-chat-ui.ps1`
- 上記から直接呼び出される配送・Handoff関連ロジック

既存配送を壊さないことを優先し、必要がなければ `iac-deliver.ps1` 自体は変更しない。

現行 `tools/iac-deliver.ps1` の配送規則では、Handoffは送信元を基準に以下へ配置される。

`IACPROJECT/inbox/from_<sender>/`

送信元を判定できない場合のみ、

`IACPROJECT/inbox/unsorted/`

へ配置される。

### 3. 「正式Handoff領域へ自動配置」の意味を固定

この表現は、**正本ファイルへの自動書き込みを意味しない**。

自動配置先は、Handoffの保管・参照用領域である `IACPROJECT/inbox/` 配下とする。

具体的な配置規則：

`IACPROJECT/inbox/from_<sender>/<handoff-file>.md`

例：アーク送信分は

`IACPROJECT/inbox/from_arc/`

へ置く。

以下の正本・判断領域へ、チャットUIや配送ロジックから自動反映してはならない。

- `IACPROJECT/CURRENT_PENDING.md`
- 正本 Decisions / Task Graph 相当ファイル
- 研究判断・仕様確定を保持する正本領域

正本反映は従来どおり、アークの整理と、必要な判断者の確定を経て別工程とする。

## Required next action

1. 上記境界を実装前提として確認する。
2. `iac-deliver.ps1` または隣接ロジックへ触れる場合、依存関係を先に確認する。
3. `inbox/from_<sender>/` 配置と正本非更新を維持したまま必要箇所を実装する。
4. 実装後、変更ファイル・検証結果・commitをHandoffでアークへ返す。
5. 境界・仕様判断が必要になった場合は実装側で推測せず、アーク経由で判断者へ返す。

## Acceptance boundary

佐藤の担当は実装と技術検証まで。

以下は佐藤が単独確定しない。

- 研究判断
- 医学上の整合判断
- 正本採否
- 運用仕様そのものの変更

---

**Router note:** 黒瀬レビュー条件を反映済み。佐藤は本Handoff受領後、上記条件の範囲で着手可。
