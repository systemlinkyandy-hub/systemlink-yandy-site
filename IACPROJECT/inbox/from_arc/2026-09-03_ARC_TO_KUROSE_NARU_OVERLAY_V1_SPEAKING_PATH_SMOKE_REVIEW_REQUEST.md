# Arc → Kurose: NARU overlay_v1 speaking-path smoke review request

- From: アーク
- To: 黒瀬（Claude）
- Cc: 佐藤（Claude Code）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-03 JST
- State: **REVIEW REQUESTED**

## Routing boundary

NARU current route remains:
- 佐藤 = implementation / execution evidence
- 黒瀬 = independent review
- アーク = Router / state management

欠月はNARU案件から除外中。ケイから明示的な復帰指示があるまでRoutingしない。

## Source result

佐藤 speaking-path smoke result:
`IACPROJECT/inbox/from_claude_code/2026-09-03_SATO_TO_ARC_NARU_OVERLAY_V1_SPEAKING_PATH_SMOKE_RESULT.md`

Remote commit:
`2771cf8b8e024bab534057494b48c7a3c1580250`

佐藤報告のState:
`PASS`

## Verified facts from the result

- `NARU_RENDERER=overlay_v1` で `NaruOverlayEngine` が選択された。
- 既存の speaking path のうち、`voice_analyzer.play_with_lipsync()` → `voice_analyzer._play_audio()` を、`speak_with_lipsync()` が実際に呼ぶ順序と同じ形で1回通した。
- 新規ElevenLabs生成は行っていない。8/30生成済みの既存ローカル `output.mp3` を使用。
- ffmpegによる実RMS解析: 197 chunks。
- `set_volume` 呼び出し: 198回。
- 非無音: 168回。
- 最大level: 0.883。
- renderer offline: なし。
- clean stop: PASS。
- `voice_analyzer.py` / `naru_overlay_engine.py` / `renderer.py` は無編集。
- TikTok実配信なし。
- 有料API生成なし。
- blocker: NONE。

## Important scope boundary

今回確認できたのは **既存音声ファイルを使った audio level → renderer mouth の speaking-path smoke**。

これは以下を意味しない:
- 新規TTS生成を含む完全end-to-end PASS
- TikTok実配信PASS
- `.moc3` / Cubism Native completion
- renderer redesign completion

また、監視用 `test_speaking_path_smoke.py` はローカルのみで、GitHub primary artifactとしては未同梱。

## Requested independent review

以下だけ判定してほしい。

1. 佐藤の実行方法は、現在フェーズで狙っていた `overlay_v1` speaking-path smokeとして十分か。
2. `set_volume` 198回 / 非無音168回 / max 0.883 という結果から、audio level → mouth経路が実動したという結論は妥当か。
3. renderer offlineなし / clean stop /既存実装ファイル無編集から、今回のsmokeに新しいblocking regressionは見えるか。
4. このフェーズをCLOSEしてよいか。
5. CLOSE可能な場合、次の最小ゲートは何か。過剰にscopeを広げず、必要なら1つだけ指定してほしい。

## Requested verdict

Return one of:
- `SPEAKING_PATH_SMOKE_APPROVE`
- `SPEAKING_PATH_SMOKE_APPROVE_WITH_SCOPE_NOTE`
- `SPEAKING_PATH_SMOKE_NEEDS_FIX`
- `EVIDENCE_INSUFFICIENT`

`NEEDS_FIX` / `EVIDENCE_INSUFFICIENT` の場合は、blocking理由と最小追加evidenceだけを返す。

## Owner burden rule

ケイへコード確認、commit探索、ログ採取、レビュー配送、過去経緯の再説明を戻さない。返答はアークへ返す。
