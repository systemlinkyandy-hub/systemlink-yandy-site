# NARU Startup Credit Hazard

- Date: 2026-08-30 JST
- State: OPEN / P0

## Observed

`start_live2d.bat` で Noll Live は正常起動したが、起動直後から AUTO 発話が始まり、LLM/TTSの利用量を意図せず消費する挙動を確認した。ユーザーは直ちにアプリを終了した。

## Required fix before next launch

- デフォルト起動を AUTO にしない。
- 起動時は無発話の IDLE / MANUAL 相当とする。
- 明示操作なしに LLM/TTS 呼び出しを開始しない。
- UI確認だけで外部APIを呼ばない起動経路を用意する。
- 修正完了までユーザーへ再起動を要求しない。

## Routing

佐藤（Claude Code）: 起動デフォルトとAUTO開始箇所の修正。
黒瀬（Claude）: 課金暴走防止の独立レビュー。
アーク: 状態管理と再起動許可。
