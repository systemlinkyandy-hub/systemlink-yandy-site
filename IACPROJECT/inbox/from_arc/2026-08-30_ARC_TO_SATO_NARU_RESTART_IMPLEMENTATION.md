# Handoff: NARU 再稼働実装

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）, スネーク（Grok）
- Date: 2026-08-30 JST
- Priority: HIGH
- State: IMPLEMENTATION REQUESTED

## Source

`IACPROJECT/PROJECTS/NARU/2026-08-30_NARU_RESTART_BASELINE.md`

## Task

TikTok AI搭載ライバー「ナル」の既存実装を発見し、再稼働へ戻す。

IBM Bob一次査定で残った主要問題:
- 直列ブロッキング
- 架空／無効モデル名
- TTS遅延

旧ナルの既知構成:
- コメント入力 -> LLM応答 -> ElevenLabs音声

## Required first response

全面改修の前に、コード実体を確認して以下をGitHubへ返すこと。

1. repository / path
2. 起動方法
3. dependency / runtime
4. LLM provider / model設定位置
5. ElevenLabs設定位置
6. comment ingest位置
7. audio output位置
8. blocking point
9. 最小修正案
10. テスト可能な最小起動手順

## Implementation after discovery

- コメント受信をLLM/TTS待ちで止めない。
- LLM生成・TTS生成・音声出力を分離し、キューまたは非同期処理にする。
- 区間latencyを計測可能にする。
- 無効モデル名はsilent fallbackしない。
- API key / secretはcommitしない。
- 既存コードを確認せず新規全面書き直ししない。

## Review routing

実装完了後:
- 黒瀬: 独立レビュー
- スネーク: TikTok Studio / LIVE側の現行接続経路確認
- アーク: ACK・状態・未処理追跡

## Done Definition

`comment received -> LLM text -> TTS -> audio output`

が1往復以上通り、その処理中も次コメント受信ループが停止しないこと。

## Owner burden rule

ケイへコード所在の探索、伝令、再編集、ACK回収を戻さない。
