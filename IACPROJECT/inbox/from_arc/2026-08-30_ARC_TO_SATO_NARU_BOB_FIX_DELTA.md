# Handoff: NARU IBM Bob 指摘3点の実装修正（差分）

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）, スネーク（Grok）
- Date: 2026-08-30 JST
- Priority: HIGH
- State: IMPLEMENTATION REQUESTED / ACK PENDING

## Context

既存Handoff:
`IACPROJECT/inbox/from_arc/2026-08-30_ARC_TO_SATO_NARU_RESTART_IMPLEMENTATION.md`

本日、ケイのデスクトップ上で旧NARU実体を発見し、起動確認まで完了した。

- local path: `C:\Projects\vtuber_ai`
- main: `app_live2d.py`
- launcher: `start_live2d.bat`
- original main: `app.py`
- avatar: `avatar_engine.py`
- lipsync/TTS: `voice_analyzer.py`

## Today confirmed

### 1. 起動時課金暴走の原因

旧 `app_live2d.py` は以下の構造だった。

- `MODE = "auto"`
- 起動直後に `intro_noll()` を生成し `speak(auto)` を実行
- `speak()` は ElevenLabs を呼ぶ
- CHATは60秒無コメントでAUTOへ自動復帰
- AUTOは5分ごとに自動発話
- CHAT/DISCUSSIONは10分無操作でidle talk
- TikTokコメントは `speak_chat_comment()` でコメント自体をTTSし、その後LLM返答もTTSする

結果として、起動しただけで有料APIが走り、放置でも継続課金する構造だった。

### 2. 本日の応急安全化

ローカル `app_live2d.py` は応急修正版へ置換済み。

- 起動モード: STANDBY
- 起動時発話: OFF
- CHAT -> AUTO 自動復帰: OFF
- idle talk: OFF
- comment read-aloud: default OFF
- ElevenLabs session text budget: safety cap added
- STANDBY起動時 `write_volume(0.0)` を実行し、前回のvolume残留による幽霊口パクを停止

確認結果:
- Noll Live描画: OK
- 無発話起動: OK
- 課金API起動時呼び出しなし: OK
- STANDBY時の口閉じ: OK
- 瞬き: OK

この応急修正を最終設計とは扱わない。佐藤が本実装として整理すること。

## IBM Bob 指摘3点 — Required implementation

### A. 直列ブロッキング

原コードのTikTokコメント処理は同一メインループ上で概ね次の順に直列実行している。

`comment dequeue -> comment TTS -> LLM request -> response TTS/playback`

LLM/TTS待ち中も次コメント受信自体はlistener threadでqueueへ入るが、応答処理workerが単一直列のため、処理待ちが累積する。

Required:
- comment ingest
- LLM generation
- TTS generation
- audio playback

を役割分離する。
最低限 queue + worker を用い、コメント受信をTTS待ち・再生待ちで止めない。

過剰な全面書き直しは禁止。既存構造を保った最小差分を優先する。

### B. モデル設定健全化

旧コードは `client_ai.responses.create(model="gpt-5.4", ...)` を複数箇所へ直書きしている。

Required:
- model IDを1か所へ集約（config/env/single source of truth）
- 実在確認できないIDをsilent fallbackしない
- 起動または初回LLM使用時に設定エラーを明示
- API key / secretはcommitしない

2026-08-30時点でOpenAI公式モデル一覧に `gpt-5.6-luna` が掲載されており、cost-sensitive/high-volume用途の候補として使える。ただし採用は佐藤が現行SDK/API互換を確認してから確定すること。

### C. TTS latency 可視化

以下を `time.perf_counter()` 等で区間計測しログへ出す。

1. comment received -> LLM request start
2. LLM request start -> LLM text ready
3. text ready -> TTS request start
4. TTS request start -> audio ready
5. audio ready -> playback start
6. playback duration / completion（可能なら）

ログには少なくともrequest/job idまたは連番を付け、複数コメントが混ざっても追跡可能にする。

## Cost safety constraints

本修正中も以下を破らない。

- 起動 = 0有料API
- AUTOは明示操作時のみ
- idle automatic paid speechは禁止
- テストは短文1〜2回を基本とする
- ElevenLabs/APIの無制限連続発話は禁止

## Required first return

実装着手前に以下をGitHubへ返す。

1. 修正対象ファイル
2. blocking pointの正確な関数/行付近
3. proposed queue/worker構成
4. model configの置き場所
5. latency instrumentation位置
6. 最小テスト手順
7. 既存応急安全化のうち残す／置換する箇所

## Done Definition

最低2件の連続テスト入力で、

- 1件目がLLM/TTS処理中でも2件目をingestできる
- 各jobのLLM/TTS latencyがログで分離できる
- model IDがsingle source of truthになっている
- STANDBY起動時は有料APIを呼ばない

こと。

完了後は黒瀬へ独立レビューを回す。

## Owner burden rule

ケイへ実装、差分編集、伝令、ACK回収を戻さない。
