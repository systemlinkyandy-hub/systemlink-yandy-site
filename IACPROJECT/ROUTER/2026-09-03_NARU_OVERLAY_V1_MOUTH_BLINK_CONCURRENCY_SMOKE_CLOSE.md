# Arc Router Close: NARU overlay_v1 — mouth + blink concurrency smoke

- From: アーク
- Date: 2026-09-03 JST
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- State: **CLOSED / APPROVED WITH NONBLOCKING NOTE**

## Verdict source

黒瀬（Claude）判定:
`MOUTH_BLINK_CONCURRENCY_SMOKE_APPROVE_WITH_NONBLOCKING_NOTE`

Exact rerun: **NOT REQUIRED**

## Reviewed result

佐藤 result commit:
`6a10633e7c3e8741c60270a6d731a71a408e3edb`

Handoff:
`IACPROJECT/inbox/from_claude_code/2026-09-03_SATO_TO_ARC_NARU_OVERLAY_V1_MOUTH_BLINK_CONCURRENCY_SMOKE_RESULT.md`

Verified outcome:
- 新規ElevenLabs request: 0
- existing local `output.mp3` used
- same renderer instance kept alive for ~10.2s
- natural blink events: 2
- blink #1 raw audio level window: 0.000–0.435
- blink #2 raw audio level window: 0.235–0.448
- total samples: 345
- non-silent samples (>0.02): 203
- renderer offline: none
- clean stop: PASS
- production code change: NONE
- blocker: NONE

## Review conclusion

実施手順は、事前指定の「長めの一文を1回」ではなく、既存短音声を4回連続再生して観測時間を延長する方式だった。

この差分は事実としてNONBLOCKING NOTEに残す。

ただし、blink #2では約400msの瞬き窓全体でraw audio levelが0.235以上を維持しつつ0.235–0.448の範囲で変化している。

前工程で各turn終端に`_raw_audio_level=0.0`へ戻ることが確認済みであるため、blink #2は再生間の無音境界ではなく、実音声再生中に自然瞬きが発生し、その間もmouth/audio-level経路が継続した直接証拠として扱える。

blink #1は0.000を含むため参考証拠とし、単独では判定根拠にしない。

目的である「mouthとblinkの同時稼働時にrendererが破綻しないこと」は達成済み。

## Cost decision

Exact rerunのための追加ElevenLabs課金は不要。

## Scope remains closed

This close does not open:
- TikTok production live
- `.moc3` authoring
- renderer redesign
- LLM changes
- unrelated NARU feature expansion

## Routing state

黒瀬から次フェーズ提案なし。

したがって本smokeをCLOSEし、追加NARU作業は新しい明示scopeが出るまで自動開始しない。

## Owner burden rule

ケイへ再説明・追加計測・追加課金・ACK追跡を戻さない。
