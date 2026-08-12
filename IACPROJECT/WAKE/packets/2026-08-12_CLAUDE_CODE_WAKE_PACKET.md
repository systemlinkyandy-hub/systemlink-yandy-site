# WAKE PACKET — 佐藤（Claude Code）

**Generated**: 2026-08-12 12:37 JST by iac-console（機械生成。推論・優先順位付けなし）
**Latest commit**: `fd9d779277fa1dba7fcc64a9fbda544ca3e12de7`
**対象範囲**: 過去 7 日の 佐藤（Claude Code） 宛Handoff（to_フォルダ / To欄の一致のみ）

---

## 共通起床文

# IACProject 共通起床文

**Date**: 2026-08-09 JST
**Status**: REGISTERED COMMON WAKEUP MESSAGE
**Scope**: 二葉（Gemini）を除く全メンバー

---

IACProject起床。運用アップデートです。 まず `IACPROJECT/CURRENT_PENDING.md` を確認してください。 最新コミット：`fd9d779277fa1dba7fcc64a9fbda544ca3e12de7`

あわせて、以下の最新運用を確認してください。

- 自主Handoff運用
- 作業終了時の `commit / Handoff先 / 理由 / Handoffパス / 次に起こすスレッド` 出力
- ケイへ「次は誰に渡すか」を原則聞かない
- 二葉（Gemini）は配送方式だけ別枠
- 正式呼称：二葉（Gemini）／黒瀬（Claude）／スネーク（Grok）／とーか（ChatGPT Codex）／佐藤（Claude Code）
- 重大な体調イベントは単独AIで閉じない

自分宛 `pending > 0` がある場合だけRouterと対象Handoffを読み、処理してください。 `pending = 0` なら追加探索は不要です。

読了後、必要な作業があればそのまま処理し、終了時は自主Handoff形式で返してください。

---

## 二葉（Gemini）例外

二葉だけはGitHub Pull前提にしない。
この共通文は使用せず、アークが必要情報をまとめた単一Packet方式で配送する。

---

## 対象Handoff（14件）

### IACPROJECT/inbox/from_arc/HANDOFF_2026-08-11_ARC_TO_SATO_CHAT_UI_POST_REVIEW.md

- Date: ** 2026-08-11 JST / From: ** アーク（Router / Infra） / Task ID: ** IAC-CHAT-UI-POST-REVIEW
- Required next action（転記）:
  > 1. 上記境界を実装前提として確認する。
  > 2. `iac-deliver.ps1` または隣接ロジックへ触れる場合、依存関係を先に確認する。
  > 3. `inbox/from_<sender>/` 配置と正本非更新を維持したまま必要箇所を実装する。
  > 4. 実装後、変更ファイル・検証結果・commitをHandoffでアークへ返す。
  > 5. 境界・仕様判断が必要になった場合は実装側で推測せず、アーク経由で判断者へ返す。

### IACPROJECT/inbox/from_arc/HANDOFF_2026-08-11_KUROSE_SATO_AUTO_CANONICALIZE_HANDOFFS.md

- Date: 2026-08-11 JST / From: アーク / Task ID: -
- Required next action（転記）:
  > （記載なし）
- 警告: Task ID がありません / Required next action がありません

### IACPROJECT/inbox/from_arc/HANDOFF_2026-08-10_PROCUREMENT_CURSOR_VIDEO.md

- Date: 2026-08-10 / From: アーク（Router / AI連携インフラ） / Task ID: -
- Required next action（転記）:
  > - 欠月／黒瀬：Cursor導入時の役割境界・重複を確認。
  > - とーか／佐藤：実装フロー上、Cursor追加が高速化になる箇所と重複する箇所を整理。
  > - スネーク：必要なら外部製品・価格・運用比較を担当。
  > - 綴：6秒刻み制作を減らせる動画制作フローをOwnerと再検討。
  > - 二葉：必要になった段階で構造化・表現整理。配送は既存ルールに従う。
  > - アーク：受領・ACK・未処理を監視し、届いていない担当を残さない。
- 警告: Task ID がありません

### IACPROJECT/inbox/from_arc/HANDOFF_2026-08-10_PROCUREMENT_CURSOR_VIDEO_ALL_EXCEPT_FUTABA.md

- Date: 2026-08-10 / From: アーク（Router / AI連携インフラ） / Task ID: -
- Required next action（転記）:
  > - 欠月／黒瀬：Cursor導入時の役割境界・重複を確認。
  > - とーか／佐藤：実装フロー上、Cursor追加が高速化になる箇所と重複する箇所を整理。
  > - スネーク：必要に応じて外部製品・価格・運用比較。
  > - 綴：6秒刻み制作を減らせる動画制作フローをOwnerと再検討。
  > - 田中：広報・動画運用面から、制作負荷と公開効率を確認。
  > - りみ：開発/UI側で今回の環境変更が影響する場合のみ反映。
  > - 上原／ユエ／まさる姐さん／纏めの君／ゆいま〜る：全体運用・Owner負荷軽減の共有事項として保持。必要な担当事項が生じた場合のみ返却。
  > - アーク：受領・ACK・未処理を監視し、「来ていない」メンバーを残さない。
- 警告: Task ID がありません

### IACPROJECT/HANDOFF/inbox/to_claude_code/2026-08-10_KAKEZUKI_HYPOTHESIS_VERIFICATION_UI_V1_TIMEBOX_EXTENDED.md

- Date: 2026-08-10 JST / From: 欠月 / Task ID: -
- Required next action（転記）:
  > （記載なし）
- 警告: Task ID がありません / Required next action がありません

### IACPROJECT/HANDOFF/inbox/to_claude_code/2026-08-10_KAKEZUKI_HYPOTHESIS_VERIFICATION_UI_V1.md

- Date: 2026-08-10 JST / From: 欠月 / Task ID: -
- Required next action（転記）:
  > （記載なし）
- 警告: Task ID がありません / Required next action がありません

### IACPROJECT/HANDOFF/inbox/to_claude_code/2026-08-10_KAKEZUKI_7DAY_CLINIC_VIEW_PRIORITY.md

- Date: 2026-08-10 JST / From: 欠月 / Task ID: -
- Required next action（転記）:
  > （記載なし）
- 警告: Task ID がありません / Required next action がありません

### IACPROJECT/HANDOFF/inbox/to_claude_code/2026-08-07_KAKEZUKI_CORRECT_CURRENT_TASK_REAL_DATA_IMPORT.md

- Date: 2026-08-07 11:17 JST / From: 欠月 / Task ID: -
- Required next action（転記）:
  > （記載なし）
- 警告: Task ID がありません / Required next action がありません

### IACPROJECT/inbox/from_grok/2026-08-07_prompt_graph_engineering_paper_check.md

- Date: 2026-08-07 10:40 JST / From: スネーク（Grok） / Task ID: -
- Required next action（転記）:
  > 欠月またはClaudeが、IACProjectのエージェント設計・Residual Capacity Workbenchや自動ライバー関連の実装方針にこの定義をどう当てはめるか検討する場合、本Handoffを起点にせよ。
- Questions queue（転記）:
  - なし。
- 警告: Task ID がありません

### IACPROJECT/HANDOFF/inbox/to_claude_code/2026-08-07_kakezuki_real_data_import_start.md

- Date: 2026-08-07 / From: 欠月 / Task ID: -
- Required next action（転記）:
  > （記載なし）
- 警告: Task ID がありません / Required next action がありません

### IACPROJECT/inbox/from_chatgpt/2026-08-06_weather_ACTH_handoff.md

- Date: 2026-08-06 / From: ChatGPT / Task ID: -
- Required next action（転記）:
  > （記載なし）
- 警告: Task ID がありません / Required next action がありません

### IACPROJECT/HANDOFF/2026-08-06_UEHARA_PROCEDURE_CORRECTION_AND_DAY_CLOSE.md

- Date: 2026-08-06 19:57 JST / From: 上原さん / Task ID: -
- Required next action（転記）:
  > （記載なし）
- 警告: Task ID がありません / Required next action がありません

### IACPROJECT/HANDOFF/2026-08-06_KAKEZUKI_TO_CLAUDE_CODE_SIMILAR_EPISODES_SCOPE.md

- Date: 2026-08-06 / From: 欠月 / Task ID: -
- Required next action（転記）:
  > （記載なし）
- 警告: Task ID がありません / Required next action がありません

### IACPROJECT/inbox/from_tsuzuri/2026-08-05_RCW_MANUAL_AND_PROMO_VIDEO_PUBLISHED.md

- Date: 2026-08-05 19:25 JST / From: 綴 / Task ID: -
- Required next action（転記）:
  > （記載なし）
- 警告: Task ID がありません / Required next action がありません

