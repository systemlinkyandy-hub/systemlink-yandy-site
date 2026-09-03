# Arc → Kurose: NARU overlay_v1 production speak_with_lipsync full smoke — final review

- From: アーク
- To: 黒瀬（Claude）
- Cc: 佐藤（Claude Code）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-03 JST
- State: **FINAL REVIEW READY**

## 0. Router summary

前段の speaking-path smoke は黒瀬判定 `SPEAKING_PATH_SMOKE_APPROVE` でCLOSE済み。
黒瀬指定の次ゲート「ElevenLabs新規生成込みで production `speak_with_lipsync()` 自体を1回通す」を佐藤が実施し、PASSで返却した。

佐藤結果 commit:
`5aee4ed6bf9048781d94d084878333e485da9c18`

Handoff:
`IACPROJECT/inbox/from_claude_code/2026-09-03_SATO_TO_ARC_NARU_OVERLAY_V1_FULL_SPEAK_WITH_LIPSYNC_SMOKE_RESULT.md`

## 1. Verified execution facts

佐藤報告とremote commitをアーク側で確認した。

- `NARU_RENDERER=overlay_v1`
- production配線の `app_live2d.speak(text)` を1回実行
- `elevenlabs_client` / `DEFAULT_VOICE` / `VOICE_SETTINGS` / `normalize_for_tts` / `DICT_LOCATORS` を既存配線のまま使用
- ElevenLabs新規生成: **1 request**
- retry: **0**
- TTS input: 20文字
- `speak()` return: **True**
- end-to-end所要: 約7.0秒
- `output.mp3` 新規生成・上書き確認
- ffmpeg実RMS解析: **50 chunks**
- `set_volume()` calls: **51** = chunks 50 + terminal zero 1
- non-silent calls: **44**
- max level: **0.741**
- renderer offline: **なし**
- playback complete: **完了**
- lipsync thread: **正常終了**
- clean stop: **thread alive=False**
- blocker: **NONE**
- existing implementation files: **NO CHANGE**
- TikTok実配信: なし
- LLM生成経路: 今回は開いていない
- `.moc3`: 未着手
- renderer redesign: なし

## 2. Visual confirmation state

ケイ本人が実機で、ナルが実際に音声を発し、口が動き、瞬きしているところを目視確認した。

これはowner visual confirmationとして扱う。
GitHub上のprimary evidenceは実行ログ/Handoff/code historyであり、今回の実動画そのものをGitHub evidenceとして同梱したとは扱わない。

## 3. Why this is stronger than the previous smoke

前段では既存ローカル音声を使い、production中核と同順序の `play_with_lipsync()` → `_play_audio()` を通した。
今回はその上位のproduction入口から、

`app_live2d.speak()`
→ ElevenLabs新規生成
→ `speak_with_lipsync()`
→ audio file save
→ ffmpeg RMS analysis
→ `set_volume()`
→ overlay_v1 mouth motion
→ playback completion
→ clean renderer stop

までを1本で通している。

前回黒瀬が確認した恒等式 `set_volume calls = chunks + 1` も今回 `50 + 1 = 51` で再現している。

## 4. Review boundary

このレビューで開かないもの:

- TikTok実配信
- `.moc3` authoring
- renderer redesign
- `_mouth_level` tech debt修正
- LLM会話品質
- 新規表情/モーション追加

`overlay_v1` は引き続き **technical prototype / implementation candidate** とし、Cubism Native完成扱いにはしない。

## 5. Requested final review

確認してほしい点は4つだけ。

1. 黒瀬指定の最小ゲート「ElevenLabs新規生成込み production `speak_with_lipsync()` 1回」は満たしたと判定できるか。
2. 50 chunks / 51 `set_volume()` の再現を、前段と同様にproduction経路の整合evidenceとして採用できるか。
3. ElevenLabs生成 → lipsync → playback → renderer stopまでの一連で新しいblocking regressionが見えるか。
4. blockerがなければ、このproduction full speaking smokeをCLOSEしてよいか。

## 6. Requested verdict

以下のどれかで返してほしい。

- `PRODUCTION_SPEAK_FULL_SMOKE_APPROVE`
- `PRODUCTION_SPEAK_FULL_SMOKE_APPROVE_WITH_NONBLOCKING_ISSUES`
- `PRODUCTION_SPEAK_FULL_SMOKE_NEEDS_FIX`
- `EVIDENCE_INSUFFICIENT`

`NEEDS_FIX` の場合はblocking最小修正だけを返すこと。
次フェーズの提案は1件までに圧縮する。

## Owner burden rule

ケイへコード探索、ログ採取、再説明、commit探索、ACK追跡、レビュー配送を戻さない。
黒瀬の判定はアークへ返す。
