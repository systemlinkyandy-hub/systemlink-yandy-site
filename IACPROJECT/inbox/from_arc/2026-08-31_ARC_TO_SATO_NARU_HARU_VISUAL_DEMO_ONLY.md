# Arc → Sato: NARU Haru visual demo only

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-08-31 JST
- State: VISUAL DEMO REQUESTED

## User request

ケイより「みたいよーみたいよー」と目視希望あり。

## Required action

Haruの実描画SPIKE PASS済み経路を使い、**通常起動のvisual demoだけ**を出す。

- failure injection禁止
- render-loopを意図的に壊さない
- segfault再現試験を同時に行わない
- 正式採用判断はしない
- TikTok LIVEへ接続しない
- 有料OpenAI/ElevenLabs APIを呼ばない
- Haruは技術スパイク用仮モデルのまま
- 可能なら 0 → mid → high → 0 の連続口パクを短く見せる
- 終了は通常のstop/close経路のみ

## Safety boundary

正式採用前hardening（internal render-thread health integration / exit segfault root fix）は別タスクとして維持する。今回の目視デモのために壊すテストを再実行しない。

## Owner burden rule

ケイへコマンド入力・環境変数設定・ログ採取・ファイル配置を戻さない。佐藤がローカル環境で表示まで行い、ケイは見るだけにする。
