# Handoff: NARU Renderer Swap Implementation

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Date: 2026-08-31 JST
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Priority: HIGH / NEXT DEVELOPMENT
- State: IMPLEMENTATION REQUESTED

## Source

`IACPROJECT/PROJECTS/NARU/2026-08-31_NARU_RENDERER_SWAP_PLAN.md`
commit `a5f3e6f18cf90828492eb17cd1f7dc1fed5f6111`

## Context

2026-08-30の実TikTok smoke testで、NARUのTikTok受信→LLM→TTS→配信の主経路は実運用相当で動作した。

次工程は会話系を作り直すことではなく、現行の簡易アバター表示を安全に換装可能にすること。

## Required action

1. `C:\Projects\vtuber_ai` の現行 `avatar_engine.py` と表示関連コードを確認する。
2. 現行 `AvatarEngine` を壊さず包める最小 `Renderer` 境界を設計・実装する。
3. app側はrenderer factory/adapter経由で起動するよう最小差分にする。
4. 現行方式を `legacy renderer` として残し、即時rollback可能にする。
5. legacy rendererの口パクについて、audio level平滑化+hysteresis等の低リスク改善を実装または比較検証する。
6. synthetic audio levelで、実OpenAI/ElevenLabs/TikTokを使わない表示テストを作る。
7. Live2D/Cubism と VRM/3D を次renderer候補として、コード接続点・必要asset・導入コストを簡潔に比較する。

## Hard constraints

以下は変更禁止または非回帰必須。

- STANDBY安全起動
- CHAT/STANDBY操作
- TikTok ingest
- input/LLM/TTS queue separation
- model fail-fast
- TTS budget
- READ_COMMENTS_ALOUD default OFF
- latency instrumentation
- speak success後のみsubtitle/history commit

表示改修のついでに会話/TTS/queueを横断リファクタしない。

## Evidence required

返却Handoffには以下を含める。

- changed local files
- code/diff review artifact on GitHub（API key/.env除外）
- legacy renderer rollback path
- synthetic display test result
- before/after mouth behavior所見
- Live2D/Cubism vs VRM接続比較
- unresolved asset requirements
- ケイが実際に目視する必要がある確認事項を最後に1回へ圧縮

## Next route

実装返却後、アークが証拠確認し、黒瀬へ独立レビューを回す。

## Owner burden rule

ケイへコード編集・探索・差分作成・伝令・ACK回収を戻さない。
