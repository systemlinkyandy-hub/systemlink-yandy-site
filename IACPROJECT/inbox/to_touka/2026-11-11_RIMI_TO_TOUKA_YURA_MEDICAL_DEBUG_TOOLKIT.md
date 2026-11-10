# HANDOFF

From: りみ（ENGINEER）
To: とーか（ChatGPT Codex）
Cc: アーク / 佐藤（Claude Code）
Task ID: IAC-YURA-MEDICAL-DEBUG-TOOLKIT-001
Date: 2026-11-11 JST
Priority: HIGH / TOOLING BASELINE

## Facts

- ケイは、医療費を自己負担しながら自分の連続データをデバッグし、AIの使い方・AI回答の捉え方を医療側へ説明する状況が続いている。
- Yuraは「体調記録アプリ」ではなく、人の状態・活動余力・ストレッサー・回復要因・時間変動を高解像度で残し、後から解析可能にする観測基盤として設計済み。
- Yura固定原則は Raw / Observation / Derived-Inference / Presentation の分離、実測と推定の分離、相関と因果の分離、再解析可能性の保持。
- RCW private側には佐藤実装の ImportedEvent / HealthEnvLogger importer / Cortisol HP importer / merge_event_streams() が既に存在する。新規importerを重複実装しない。
- りみが以下のportable baselineを作成済み。
  - `IACPROJECT/PROJECTS/YURA/MEDICAL_DEBUG_TOOLKIT/README.md`
  - `debug_event.schema.json`
  - `claim_ledger.csv`
  - `ai_answer_audit.md`
  - `medical_debug_packet.md`
  - `redaction_checklist.md`
  - `build_debug_packet.py`
  - `sample_events.jsonl`
  - `CLI_USAGE.md`

## Decisions

1. 医療デバッグ用の新しいrawデータ収集系は作らない。
2. HealthEnvLogger / Cortisol HP / RCW正規化層を再利用する。
3. 新規部分は「evidence/claim/audit/export layer」とする。
4. AI回答は結論ではなくclaim sourceとして扱い、検証状態を別フィールドで保持する。
5. 医療者向け出力は観測事実・介入・反応・仮説・反証・未解決を分離する。
6. 実データはGitへcommitしない。テストはsynthetic fixtureのみ。
7. とーかと佐藤が同一ファイルを並列編集しない。

## Changed files / Results

Baseline toolkit created under:
`IACPROJECT/PROJECTS/YURA/MEDICAL_DEBUG_TOOLKIT/`

現時点でCLIは外部ライブラリ不要。
debug event JSONL + claim ledger CSV から Markdown packet を生成できる。

## Required next action — とーか

まずコードを書き足す前に、以下だけレビューする。

1. `debug_event.schema.json` が Yura v0.1 Foundation Data Model の固定原則と衝突しないか。
2. `build_debug_packet.py` を将来Yuraへ取り込む場合の配置候補を提示。
3. AI Answer Audit をYura上の独立entityにするか、external source + claimとして表現可能かを判断材料として整理。
4. 既存SPEC-ANA-001との重複・衝突を列挙。
5. 実装開始条件を明記して、りみへ返す。

この段階ではYura本体へ大規模実装しない。

## Future next action — 佐藤

とーかのモデル整合レビュー後にのみ、
RCW ImportedEvent -> debug_event の薄いadapterを検討する。
既存importer本体は変更しない。

## Questions queue

ケイへの質問: なし。
仕様上判断が必要な点は、りみへ返却する。

## Handoff boundary

- 医学的採否・治療判断を行わない。
- AI回答を自動的に正しい情報へ昇格しない。
- ケイをAI間伝令に戻さない。
