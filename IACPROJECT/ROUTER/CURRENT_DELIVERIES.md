# CURRENT_DELIVERIES

**Owner**: アーク
**Purpose**: AI間の配送状態を1ファイルで確認するための固定ルータ索引。
**Status**: ACTIVE
**Last updated**: 2026-08-08 JST

## Active deliveries

### DELIVERY-MANGA-STRUCTURE-2026-08-08-01
- from: 双葉（Gemini）
- to: 黒瀬（Claude）
- topic: 作品解読シリーズ第2弾「天小 / いせおじ / クレイモア」記事化
- source: `IACPROJECT/HANDOFF/2026-08-08_FUTABA_TO_KUROSE_MANGA_STRUCTURE_SERIES_02_REQUEST.md`
- state: REGISTERED / ROUTED / EXTERNAL WAKE REQUIRED
- next_action: 黒瀬は3作品の解読軸を保持し、あらすじ化せず、工学・制御論と深層心理学が交差する長文記事として構成する。
- delivery_mode: GitHub Pull
- note: 元Handoff本文は会話内保持。GitHub安全制約によりsourceは運用要約。

### DELIVERY-MEDICAL-PROTOCOL-2026-08-07-01
- from: 上原さん / アーク
- to: ALL MEMBERS
- topic: 重大な医療・体調イベントを単独AIで閉じない運用
- source: `IACPROJECT/OPERATING_RULES/MEDICAL_SYMPTOM_MULTI_AI_REVIEW_PROTOCOL.md`
- distribution_packet: `IACPROJECT/IMPORTANT/2026-08-07_IACPROJECT_MEDICAL_MULTI_AI_MANDATORY_WAKEUP_PACKET.md`
- source_handoff: `IACPROJECT/HANDOFF/inbox/to_arc/2026-08-07_uehara_to_arc_external_ai_medical_review_priority.md`
- state: REGISTERED / MANDATORY READ / DELIVERY REQUIRED
- next_action: 各メンバーは次回起床時に正本または配布Packetを読み、自分の担当境界へ反映する。医療判断を勝手に拡張しない。
- delivery_mode: GitHub Pull capable members = Router; Gemini = single Packet on next wake
- ack_required: yes

## Temporary infrastructure delegation

### TEMP-ARC-PROXY-2026-08-08
- primary_owner: アーク
- temporary_proxy: スネーク（Grok / xAI）
- source: `IACPROJECT/inbox/from_grok/2026-08-08_SNAKE_ARC_PROXY_ACCEPTANCE.md`
- rule: `IACPROJECT/OPERATING_RULES/TEMP_ARC_PROXY_2026-08-08.md`
- state: **ENDED / AUTHORITY RESTORED**
- closure: ケイ確認（2026-08-08）により終了。佐藤（Claude Code）による自主Handoff実装完了後。
- scope: Handoff登録 / 形式確認 / ACK可視化 / 最低限のRouter・CURRENT_PENDING更新
- exclusions: 研究判断 / 医学判断 / 仕様確定 / 採否 / 正本内容改変 / 構造独断変更

## Closed deliveries

### DELIVERY-AUTONOMOUS-HANDOFF-2026-08-08-01
- from: アーク
- to: ALL MEMBERS
- topic: 自主Handoffルーティング導入前通知 → 実装完了
- source: `IACPROJECT/HANDOFF/2026-08-08_ARC_TO_ALL_AUTONOMOUS_HANDOFF_ROUTING_PREP.md`
- design: `IACPROJECT/HANDOFF/2026-08-08_ARC_TO_SNAKE_AUTONOMOUS_HANDOFF_ROUTING_FULL_HANDOFF.md`
- implementation: `IACPROJECT/inbox/from_claude_code/2026-08-08_CLAUDE_CODE_TO_ALL_FABLE_AUTONOMOUS_HANDOFF_IMPLEMENTATION_DONE.md`
- state: COMPLETED / CLOSED
- result: 佐藤実装完了・ケイ確認・アーク権限復帰

### DELIVERY-IAC-INFRA-BUS-001
- from: Claude Code
- to: アーク
- topic: `iac-deliver` 自動配送コマンド実装完了（ケイの手作業中継の排除）
- source: 外部Handoff（Task ID: IAC-INFRA-BUS-001。リポジトリ外・ケイより直接指示）
- state: COMPLETED / CLOSED
- result: `IACPROJECT/inbox/from_claude_code/2026-08-08_CLAUDE_CODE_TO_ARC_IAC_INFRA_BUS_001_DONE.md`
- artifact: `tools/iac-deliver.ps1`, `tools/iac-deliver.cmd`, `tools/README_GMAIL_TO_STAGING.md`
- note: 処理2（Router/CURRENT_PENDING自動更新）は縮小フォールバック規定により未実装。本エントリはアークによる手動登録の代理としてClaude Codeがケイの指示で追記した。

### DELIVERY-BIRDMEN-2026-08-07-02
- from: Gemini
- to: Claude
- topic: BIRDMEN fact/interpretation separation final review
- source: `IACPROJECT/inbox/from_gemini/2026-08-07_GEMINI_BIRDMEN_FACT_PACKET.md`
- state: COMPLETED / CLOSED
- result: `IACPROJECT/inbox/from_claude/2026-08-07_CLAUDE_TO_ARC_GEMINI_BIRDMEN_FINAL_REVIEW.md`

### DELIVERY-BIRDMEN-2026-08-07-01
- from: Claude / Gemini review loop
- to: Gemini
- topic: BIRDMEN fact/interpretation separation minimal Fact Packet
- source: `IACPROJECT/inbox/from_claude/2026-08-07_CLAUDE_TO_ARC_GEMINI_BIRDMEN_REVIEW_ROUND3.md`
- state: COMPLETED
- result: `IACPROJECT/inbox/from_gemini/2026-08-07_GEMINI_BIRDMEN_FACT_PACKET.md`

## Reading rule

GitHub Pull-capable AIs read only entries addressed to themselves or ALL MEMBERS, then fetch the exact `source`, `distribution_packet`, and listed `context` paths as applicable.
Gemini does not depend on this file directly; アーク copies the relevant entry into a single Packet when Gemini is needed.
