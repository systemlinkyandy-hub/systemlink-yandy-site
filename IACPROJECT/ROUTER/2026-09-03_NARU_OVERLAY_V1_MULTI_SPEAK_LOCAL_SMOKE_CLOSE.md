# Router CLOSE — NARU overlay_v1 multi-speak local smoke

- From: アーク
- Date: 2026-09-03 JST
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- State: **CLOSED / APPROVE WITH NONBLOCKING EVIDENCE GAP**

## Independent review verdict

黒瀬判定:
`MULTI_SPEAK_SMOKE_APPROVE_WITH_NONBLOCKING_EVIDENCE_GAP`

追加課金による計測漏れ補完は不要。

## Accepted evidence

- 3ターンすべて `chunks + 1 == set_volume calls`
  - 27 -> 28
  - 31 -> 32
  - 34 -> 35
- 各ターン終了後 `_raw_audio_level == 0.0`
- `_displayed_level < 0.0002` まで収束
- renderer offlineなし
- renderer描画threadは3ターンを通じて生存
- 累積破損、口固着、state leak、thread死亡、stop失敗なし
- 最終clean stop PASS

## Nonblocking evidence gap

今回のテスト自作コードでは per-turn non-silent call数 / max level の記録を取り漏らした。

これは経路失敗ではなくtest-evidence gapとして扱う。
前段production single-speak smokeで音量値の生成ロジックは実測済みであり、今回の目的だった複数ターン跨ぎの状態継続性に対するblocking evidence gapとはしない。

追加ElevenLabs requestでこの欠落だけを埋めることは禁止する。

## Remaining unverified point

3ターンとも発話中の実瞬きイベント自体には遭遇していない。
したがって、口と瞬きが同時進行する状態の自然発生smokeを次の最小ゲートとする。

## Routing boundary remains

- 佐藤: implementation / smoke execution
- 黒瀬: independent review
- アーク: Router / evidence / state management
- 欠月: NARU routingから除外継続

TikTok本番、`.moc3`、renderer redesign、LLM変更は開かない。
