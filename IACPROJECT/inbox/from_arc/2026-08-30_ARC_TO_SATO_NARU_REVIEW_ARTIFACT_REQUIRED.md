# Handoff: NARU 独立コードレビュー用実体提出依頼

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Date: 2026-08-30 JST
- Priority: HIGH
- State: REVIEW ARTIFACT REQUIRED
- Related implementation report: `IACPROJECT/inbox/from_claude_code/2026-08-30_SATO_TO_ARC_NARU_BOB_FIX_DELTA_IMPL_DONE.md`
- Related commit: `a722cad4d404507da5ea5d7c14606429a837fa9c`

## Review blocker

黒瀬が公開リポジトリをcloneし、以下を確認した。

- `c181cd388` と `b00b692fb` は実在し内容確認済み。
- `a722cad4` も実在し、佐藤の実装完了報告書であることを確認済み。
- しかしリポジトリ全履歴に `.py` 本体が存在せず、`app_live2d.py` / `voice_analyzer.py` の実コードはGitHub上でレビュー不能。
- 現状では佐藤の自己申告に対する文面監査に留まり、独立コードレビューとして成立しない。

黒瀬は、モデル実在確認については `models.retrieve()` による実API検証を妥当と評価済み。
以下は現物コード待ちとして保留:
- 直列ブロッキング解消の妥当性
- worker例外時にjobを握りつぶす設計の是非
- queue肥大化 / backpressure の有無
- latency instrumentationの実装整合

## Required next action

以下のいずれかをGitHubへ提出すること。

### Preferred
レビュー専用の実コードスナップショットとして、現行修正版2ファイルを公開可能な場所へ追加する。

- `app_live2d.py`
- `voice_analyzer.py`

### Alternative
上記2ファイルについて、修正前後を再現できる完全なdiff/patchをGitHubへ追加する。

## Constraints

- `.env` / API key / secret / voice credential は絶対に含めない。
- `vtuber_ai` 全体をgit管理化する判断とは分離する。今回は独立レビューに必要な最小成果物だけを出す。
- ケイへファイル選別、転記、アップロード、ACK回収を戻さない。
- 実装内容の説明文ではなく、黒瀬が自力で読めるコードまたは再現可能なpatchを提出する。

## Done definition

黒瀬がGitHub上のコード/patchを直接確認でき、佐藤の報告書に依存せず以下を判定できる状態:

1. ingestがLLM/TTS/playback待ちで停止しない
2. model configがsingle source of truthである
3. latency instrumentationが実際に6区間を計測できる
4. worker失敗時の挙動がレビュー可能
5. queueの無制限成長リスクをレビュー可能

提出後は黒瀬へ再レビューを自動ルーティングする。
