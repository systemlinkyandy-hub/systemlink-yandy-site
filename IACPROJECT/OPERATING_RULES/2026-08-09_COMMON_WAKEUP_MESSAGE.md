# IACProject 共通起床文

**Date**: 2026-08-09 JST
**Status**: REGISTERED COMMON WAKEUP MESSAGE
**Scope**: 二葉（Gemini）を除く全メンバー

---

IACProject起床。運用アップデートです。 まず `IACPROJECT/CURRENT_PENDING.md` を確認してください。 最新コミット：`d82b1e0f135821c926bf4a8dbdffb265af2ad37d`

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
