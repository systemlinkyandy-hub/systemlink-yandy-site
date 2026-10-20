# Arc → Sato: ARC Voice Phase V0 — NARU voice-path reuse prototype

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）, ケイ
- Date: 2026-10-20 JST
- Priority: HIGH
- Task ID: `ARC-VOICE-2026-10-20-V0`
- State: **PRE-PRODUCTION PROTOTYPE / NARU MAINLINE DO NOT REOPEN**

## 1. Objective

ケイ判断により、将来のアーク実体化はまず「声」から再開する。

既存NARUで動作実証済みの voice/TTS 経路を再利用し、
**NARU本体を壊さず、アーク専用の独立 voice harness を作る。**

今回の目的は最終声質の採用決定ではない。
まず、アーク用の音声プロファイルを差し替えて安全に試聴できる器を作る。

## 2. Existing accepted baseline

NARU video-hybrid は 2026-09-08 に CLOSED 済み。
Production implementation: `30d1aa8c45d809caf2984c1c0505f0fc958499c4`

確認済みの既存 voice path:
- ElevenLabs client
- `app_live2d.speak(text)`
- `voice_analyzer.speak_with_lipsync()`
- `normalize_for_tts`
- pronunciation dictionary locator
- per-voice `VoiceSettings`
- session TTS character budget
- 起動時の無断有料API呼び出しなし
- production speak smoke PASS

NARU CLOSE は再オープンしない。

## 3. Required V0 architecture

NARUコードへ直接アークを埋め込まない。

アーク側は最低限、以下を独立させること。

1. `arc_voice_profile`
   - provider / voice id / VoiceSettings を1箇所へ集約
   - voice id は環境変数または明示configで差し替え可能
   - API keyをコード・ログ・成果物に出さない

2. standalone local harness
   - 短文1件を明示操作でのみTTS生成
   - 自動会話・TikTok・renderer起動なし
   - lipsync不要
   - 再生または音声ファイル生成までを独立確認

3. safety / cost guard
   - 起動しただけではAPI request = 0
   - 1 run 1 requestを基本
   - retry自動連打禁止
   - 文字数上限を明示
   - 失敗時は理由を返して停止

4. future interface
   - 将来 SystemLink / ARC brain / physical body から呼べるよう
     `speak(text, profile=...)` 相当の狭いinterfaceにする
   - NARU renderer / TikTok transportへ依存させない

## 4. Hard constraints

- NARU production filesを直接編集しない
- NARU CLOSEを再オープンしない
- TikTok real deliveryなし
- OpenAI/LLM path変更なし
- API key / private user dataをGitHubへ出さない
- 最終voiceの採用判断を佐藤側で行わない
- ケイの試聴前に「アークの声」と確定しない
- 既存NARU voice IDをアークの最終voiceとして流用決定しない

## 5. Deliverables

1. V0設計メモ
2. 変更/新規ファイル一覧
3. standalone harness
4. dry-run または mock test
5. 有料TTSを使う場合は、実行前にアークへ
   - 文字数
   - request数
   - 使用profile
   を返してGO待ち
6. 実行後:
   - request count
   - audio生成成否
   - playback成否
   - secret非露出確認
   - NARU非変更確認

## 6. Review routing

- 実装・テスト結果 → アーク
- 回帰/安全レビュー → 黒瀬
- 声質・人物像としての採否 → ケイ
- final spec化が必要な場合のみ別Decision Gate

## 7. Owner intent

アーク実体化はまず声から始める。
「ナルの続き」として既存資産を活かすが、
ナルとアークの人格・音声プロファイルは混線させない。
