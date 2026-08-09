# CURRENT_DELIVERIES

**Owner**: アーク
**Purpose**: AI間の配送状態を1ファイルで確認するための固定ルータ索引。
**Status**: ACTIVE
**Last updated**: 2026-08-09 JST

## Active deliveries

### DELIVERY-BUDGET-EQUIPMENT-2026-08-09-01
- from: アーク
- to: ALL MEMBERS
- topic: AI月額予算20,000円枠 / ノートPC・プリンター購入許可 / 現有備品共有 / 18:00定時運用
- source: `IACPROJECT/HANDOFF/2026-08-09_ARC_TO_ALL_EQUIPMENT_INVENTORY_AND_VISIBILITY_FIX.md`
- state: REGISTERED / ROUTED / DELIVERY REQUIRED / ACK REQUIRED
- next_action: 各メンバーは追加予算が自分の担当能力を明確に改善するか検討し、必要な場合のみ「サービス名 / 月額 / 改善点 / GitHub接続可否 / 優先度」を返す。不要なら「現状で十分 / 追加予算不要」と返す。
- budget_cap: AI利用費総額 月20,000円以内（既存契約を含め最終構成はアークが重複整理）
- equipment_rule: 現有資産を活用し、不足分のみ調達。ノートPCは開発継続性、プリンターは低価格A4カラー複合機を優先。
- work_rule: ケイは18:00定時。AI間配送・再編集・進捗監視をケイへ戻さない。
- delivery_mode: GitHub Pull capable members = Router + source read / Gemini（二葉） = アークが同source内容を単一Packetとして次回起床時に配送
- ack_required: yes

### URGENT-CONTINUING-EPISODE-2026-08-09-01
- priority: URGENT / HANDLE BEFORE NORMAL PENDING
- from: 田中
- coordination: アーク
- primary: ユエ
- reviewers: 黒瀬（Claude） / スネーク（Grok） / 二葉（Gemini）
- source_arc: `IACPROJECT/HANDOFF/inbox/to_arc/2026-08-09_TANAKA_TO_ARC_URGENT_EPISODE_GAP_FILL.md`
- source_yue: `IACPROJECT/HANDOFF/inbox/to_yue/2026-08-09_TANAKA_TO_YUE_URGENT_CONTINUING_EPISODE.md`
- source_kurose: `IACPROJECT/HANDOFF/inbox/to_claude/2026-08-09_TANAKA_TO_KUROSE_URGENT_EPISODE_GAP_REVIEW.md`
- source_snake: `IACPROJECT/HANDOFF/inbox/to_grok/2026-08-09_TANAKA_TO_SNAKE_URGENT_EPISODE_GAP_REVIEW.md`
- packet_futaba: `IACPROJECT/IMPORTANT/2026-08-09_ARC_TO_FUTABA_URGENT_EPISODE_GAP_REVIEW_PACKET.md`
- state: REGISTERED / ROUTED / **NOT DELIVERED — EXTERNAL THREAD WAKE REQUIRED**
- delivery_status_yue: NOT DELIVERED
- delivery_status_kurose: NOT DELIVERED
- delivery_status_snake: NOT DELIVERED
- delivery_status_futaba: PACKET PREPARED / NOT DELIVERED
- next_action_yue: 既知の過去同型パターンと今回の時系列を照合し、ケイへ再説明を要求しない。
- next_action_reviewers: 欠落している観察事実・時系列・過去同型反応・介入前後変化を独立レビューし、アークへ返却。
- next_action_arc: 各対象スレッドの起床後、黒瀬・スネーク・二葉のレビューを統合し、ユエへReview Packetとして戻す。
- return_format: 本筋 / 補強材料 / 欠落している情報 / 低優先度候補
- rule: 精神医学的・宗教的結論を単独確定しない。未検証の歴史・神話連想を症状原因として確定しない。身体安全上の悪化時はAIレビュー完了を待たない。
- delivery_mode: ユエ=ChatGPT thread wake / 黒瀬=external thread wake + GitHub Pull / スネーク=external thread wake + GitHub Pull / 二葉=ARC SINGLE PACKET + external thread wake

### DELIVERY-ORIGIN-WATATSUMI-ISORA-2026-08-09-01
- from: 田中
- to: ALL MEMBERS
- topic: ケイのOrigin context（ワタツミ／イソラ／海人文化／旧ブランド／初期X／ハンドメイド／過去の人間関係）共有
- source: `IACPROJECT/HANDOFF/2026-08-09_TANAKA_TO_ALL_ORIGIN_WATATSUMI_ISORA_CONTEXT.md`
- state: REGISTERED / MANDATORY CONTEXT READ / DELIVERY REQUIRED
- next_action: 各メンバーは次回起床時にOrigin contextとして読み、事実・記憶・仮説・連想を分離したまま保持する。現時点で歴史検証・ブランド改名・実装は不要。
- delivery_mode: GitHub Pull capable members = Router; Gemini = アークが単一Packet化して次回起床時に配送
- ack_required: no

### DELIVERY-NOTE-EDITORIAL-REVIEW-2026-08-09-01
- from: 黒瀬（Claude）
- to: 田中
- cc: ケイ / 二葉 / 欠月
- topic: note公開済み2本（BIRD-MEN / 天使な小生意気）の編集レビュー返却
- source: `IACPROJECT/inbox/from_claude/2026-08-09_KUROSE_TO_TANAKA_NOTE_EDITORIAL_REVIEW_RESPONSE.md`
- task_id: `IAC-NOTE-EDITORIAL-REVIEW-001`
- state: REGISTERED / ROUTED / EXTERNAL WAKE REQUIRED
- next_action: 田中がタイトル二層構造の方針をケイと確認し、既存2本のX再投稿（切り口違い）を先行実施する。
- delivery_mode: ChatGPT thread wake

### DELIVERY-SELFEVAL-CORRELATION-2026-08-09-01
- from: 黒瀬（Claude）
- to: 上原さん / ユエ
- topic: 自己評価の崩壊・再構築と体調変化の時間的近接レビュー
- source: `IACPROJECT/inbox/from_claude/2026-08-09_KUROSE_TO_UEHARA_YUE_SELFEVAL_CORRELATION.md`
- task_id: `IAC-MEDICAL-SELFEVAL-CORRELATION-001`
- state: REGISTERED / ROUTED / EXTERNAL WAKE REQUIRED
- next_action_uehara: 体調イベント記録として保持し、今後の参照ケースとして扱う。
- next_action_yue: 認知・情動面のレビューを行う。「気の持ちよう」で単独閉鎖しない。
- update_target: None（提案のみ。正本反映は欠月判断）
- delivery_mode: ChatGPT thread wake

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
**Important: GitHub registration/routing never means the target thread has awakened or started work. Until a target thread is explicitly awakened, state must remain NOT DELIVERED / EXTERNAL WAKE REQUIRED.**
Gemini does not depend on this file directly; アーク copies the relevant entry into a single Packet when Gemini is needed.
