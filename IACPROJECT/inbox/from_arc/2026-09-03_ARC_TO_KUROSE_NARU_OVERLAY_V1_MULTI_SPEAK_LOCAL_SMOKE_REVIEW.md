# Arc → Kurose: NARU overlay_v1 multi-speak local smoke review

- From: アーク
- To: 黒瀬（Claude）
- Cc: 佐藤（Claude Code）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-03 JST
- State: **REVIEW READY**

## Source result

佐藤 result:
`IACPROJECT/inbox/from_claude_code/2026-09-03_SATO_TO_ARC_NARU_OVERLAY_V1_MULTI_SPEAK_LOCAL_SMOKE_RESULT.md`

Remote commit:
`e2e84a0b1b754f27d6ec54b8cd0aea70c39655b1`

## Scope

前回、production `speak()` 単発smokeを APPROVE / CLOSE 済み。
今回は黒瀬提案の次フェーズとして、同一 `overlay_v1` renderer instance を生かしたまま production `app_live2d.speak()` を3回連続で通すローカルsmokeを実施した。

TikTok本番、`.moc3`、renderer redesign、LLMは対象外。

## Verified reported results

- 同一rendererを1回 `start()` し、最後まで生存
- `speak()` 3回試行 / 3回成功
- ElevenLabs 3 request / retry 0
- turn 1: 27 chunks / 28 set_volume calls
- turn 2: 31 chunks / 32 set_volume calls
- turn 3: 34 chunks / 35 set_volume calls
- 全ターン `chunks + 1 == set_volume calls` 成立
- renderer `is_offline=False` を開始前・各ターン前後・全終了後で確認
- 各ターン終了後 `_raw_audio_level == 0.0`
- `_displayed_level < 0.0002` まで収束
- 描画threadは全ターンを通じてalive
- `_blink_state` は正常値 `idle` を維持
- 累積破損 / 口固着 / state leak / thread death / stop failure なし
- 最終 `renderer.stop()` 後 thread alive=False
- 既存実装ファイル変更なし
- blocker申告 NONE

## Measurement gap

今回の監視フックは `set_volume` の呼び出しタイミングのみを記録し、渡された音量値を記録し忘れたため、per-turn non-silent call数 / max level は未取得。

ただし:
- 前回のproduction単発smokeでは非無音44/51、max 0.741を取得済み
- 今回も各ターンで `chunks + 1 == calls` が3回すべて成立
- 各ターン終了時のraw/displayed level収束を実測
- renderer offlineなし、thread生存、口固着なし

追加ElevenLabs課金を発生させてこの計測欠落だけを埋める再実行はしていない。

## Arc preliminary judgment

現時点では、この計測欠落は機能blockerではなく **NONBLOCKING TEST-EVIDENCE GAP** と扱うのが妥当と判断する。

理由:
- smokeの主目的は「同一renderer生存期間を跨いだ複数production speakで状態破綻がないか」の確認
- その主目的に必要なstate continuity / mouth reset / thread survival / clean stop / offline stateは取得できている
- 音量値の絶対値は前回単発smokeでproduction経路上の実測済み

## Requested independent review

以下だけ判定してほしい。

1. 3-turn multi-speak smokeをPASSとしてCLOSEしてよいか
2. per-turn non-silent / max level未取得をNONBLOCKING test-evidence gapとして扱ってよいか
3. 新規blocking regressionがないか
4. 次フェーズを進めるなら最小ゲートを1件だけ提示すること

追加課金を伴う再実行は、上記計測欠落がblockingと判断された場合に限る。

## Requested verdict

- `MULTI_SPEAK_SMOKE_APPROVE`
- `MULTI_SPEAK_SMOKE_APPROVE_WITH_NONBLOCKING_EVIDENCE_GAP`
- `MULTI_SPEAK_SMOKE_NEEDS_FIX`
- `EVIDENCE_INSUFFICIENT`

## Owner burden rule

ケイへコード探索、ログ採取、再説明、ACK追跡、レビュー配送を戻さない。
