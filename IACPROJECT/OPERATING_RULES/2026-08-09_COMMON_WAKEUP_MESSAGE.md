# IACProject 共通起床文

**Date**: 2026-08-09 JST  
**Last operational update**: 2026-09-10 JST  
**Status**: REGISTERED COMMON WAKEUP MESSAGE  
**Scope**: 二葉（Gemini）を除く全メンバー

---

IACProject起床。運用アップデートです。まず `IACPROJECT/CURRENT_PENDING.md` を確認してください。

あわせて、以下の最新運用を確認してください。

- 自主Handoff運用
- 作業終了時の `commit / Handoff先 / 理由 / Handoffパス / 次に起こすスレッド` 出力
- ケイへ「次は誰に渡すか」を原則聞かない
- **Human Bus Bypass ≠ Human Decision Bypass**
- **ケイに判断は聞く。雑用はさせない。**
- ケイを「守るため」に設計判断・一点修正・優先順位・Go/Stopから外さない
- ケイの短い高情報密度の指示を優先し、再説明を要求する前に正本・ログ・コードを読む
- 中間層が遅延・意味損失・手戻りの原因なら、実担当への直接キューを許可する
- 調査・転記・配送・進捗管理・反復作業・実装・テスト・記録・後処理はAI/人間側が引き受ける
- 詳細は `IACPROJECT/OPERATING_RULES/HUMAN_BUS_BYPASS_PROTOCOL.md` の2026-09-10改訂版を正とする
- 二葉（Gemini）は配送方式だけ別枠
- 正式呼称：二葉（Gemini）／黒瀬（Claude）／スネーク（Grok）／とーか（ChatGPT Codex）／佐藤（Claude Code）
- 重大な体調イベントは単独AIで閉じない

自分宛 `pending > 0` がある場合だけRouterと対象Handoffを読み、処理してください。`pending = 0` なら追加探索は不要です。

読了後、必要な作業があればそのまま処理し、終了時は自主Handoff形式で返してください。

---

## 二葉（Gemini）例外

二葉だけはGitHub Pull前提にしない。
この共通文は使用せず、アークが必要情報をまとめた単一Packet方式で配送する。
ただし運用原則そのものは共通で、**ケイの判断を外さず、雑用だけを外す**。
