# Arc → Sato: NARU overlay_v1 mouth + blink concurrency smoke

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Date: 2026-09-03 JST
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- State: READY

## Background

黒瀬のmulti-speak review verdict:
`MULTI_SPEAK_SMOKE_APPROVE_WITH_NONBLOCKING_EVIDENCE_GAP`

前段multi-speak smokeはCLOSE済み。
計測漏れ（per-turn non-silent/max level）のための追加課金は不要。

残る未確認点は1つだけ。

**発話中に自然瞬きが実際に発生し、mouth動作とblink動作が同時進行しても破綻しないこと。**

## Scope

同一 `overlay_v1` rendererを起動し、十分な長さの発話区間を1回通し、発話中に自然瞬きイベントが少なくとも1回発生するところまで観測する。

確認項目:

1. 発話中に口パクが継続している
2. 同じ発話中にblink stateが実際にidle以外へ遷移し、瞬きが1回以上完了する
3. blink中もmouth state/audio-level pathが停止・固着・破損しない
4. blink終了後もmouth/blink/compose loopが正常継続する
5. renderer offlineにならない
6. 最終clean stop
7. 既存実装ファイルへの変更有無を明示

## Cost boundary

このゲートの目的はrenderer内のmouth + blink concurrency確認であり、ElevenLabs新規生成そのものではない。

まず**追加課金なしで実行可能な既存ローカル音声・既存生成物で条件を満たせるか確認**すること。

既存ローカル素材では十分な発話長を確保できず、ElevenLabs新規生成が必要な場合は、**実行前にケイ本人の明示許可を得ること。許可前に有料requestを発行しない。**

許可された場合も短文〜中程度の1文、1 request、retryなしを上限とする。

## Do not open

- TikTok実配信
- `.moc3`
- renderer redesign
- LLM経路変更
- `_mouth_level` tech debt修正
- per-turn non-silent/max level gapだけを埋める再計測

## Return to Arc

Handoffに以下を含めること。

- 使用した音声の由来（既存ローカル / 新規生成）
- 新規ElevenLabs request数 / retry数（0なら0）
- 発話長または再生時間
- blink event count
- blink発生時にmouth/audio-level更新が継続した証拠
- renderer offline有無
- clean stop
- blocker
- code change有無

ケイへコード探索、ログ採取、ACK追跡、再説明を戻さない。
