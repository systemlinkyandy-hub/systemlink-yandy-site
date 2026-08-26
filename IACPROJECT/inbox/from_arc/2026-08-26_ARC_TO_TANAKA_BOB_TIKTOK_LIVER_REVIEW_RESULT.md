# Handoff: BobによるTikTokライバー一次査定結果

From: アーク
To: 田中
Cc: 欠月
Date: 2026-08-26
Task ID: TANAKA-ARC-BOB-TIKTOK-LIVER-REVIEW-20260826

## Status
COMPLETED / FIRST PASS ONLY / IMPLEMENTATION NOT STARTED

## Facts
- 対象：ローカル `C:\Projects\vtuber_ai`
- IBM Bob v2.0.0で既存コードを一次査定した。
- 初回はファイル変更禁止で実施した。
- `.env` / `.venv` 等の秘密情報候補は解析対象から除外する指示を出した。
- Bobは日本語で査定結果を返した。
- ケイ本人への「何がいまいちだったか」の思い出し作業は要求していない。
- 査定後、ケイはIBM Bob利用結果のスクリーンショットを添えてSNS投稿を完了した。

## Bob primary findings
1. コメント着信 → OpenAI API → ElevenLabs TTS → ffmpeg解析 → 音声再生が直列ブロッキングになっており、ライブ配信のリアルタイム性を大きく損なう構造。
2. AI呼び出しのモデル指定についてBobから問題指摘あり。ただしモデル名の有効性は外部・API環境依存のため、アーク側では未検証事項として分離する。
3. `os.startfile` による音声再生開始と口パクタイマー開始が同期せず、口パクが先行する構造。
4. その他、`app.py` の `while True` 配置、Thread二重start、MODEと実際のプロンプト選択の不整合等をコード上の問題候補として提示。

## Arc evaluation
- コード読解：PASS
- 原因候補への掘り下げ：PASS
- 日本語運用：PASS
- 変更禁止遵守：PASS
- 事実／推測分離：概ねPASS。ただしモデル存在判定は要外部検証。
- 2投目：今回は不要と判断。

## Decision
本試作は「失敗作」ではなく、再評価・改修候補として扱う。
特に直列同期型の処理系は、当時の「いまいち」という体感を説明する強い原因候補。

Current asset status:
`vtuber_ai: RE-EVALUATION CANDIDATE / BOB FIRST REVIEW PASS / IMPLEMENTATION NOT STARTED`

## External communication
IBM関係者からのフォローをきっかけにBobを再評価した経緯があり、ケイは査定画面のスクリーンショットとともにSNS投稿を完了。公開投稿では秘密情報そのものは掲載しない方針。

## Required next action
田中側では、必要に応じて外部発信・反応の観察対象として扱う。
技術改修を行う場合は別タスクとして起票し、アークが適切な実装担当へ配送する。
ケイを伝令役・再説明役には戻さない。
