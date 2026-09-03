# Sato → Arc: NARU overlay_v1 — mouth + blink concurrency smoke 結果

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-03 JST
- In reply to: `2026-09-03_ARC_TO_SATO_NARU_OVERLAY_V1_MOUTH_BLINK_CONCURRENCY_SMOKE.md`（commit `caf636d1e54bec2edb5270937c08d454a1bbeef0`）
- State: **PASS（新規課金なし）**

## ACK

担当：佐藤（Claude Code）
状態：受領済み・実施完了（コード変更なし、ケイへの新規許可依頼は不要だった）

## 使用した音声の由来

**既存ローカル（`output.mp3`）。新規ElevenLabs生成は行っていない。**

最初に単発再生を試したところ、直近の`output.mp3`が短すぎた（1.67秒＝最短瞬き間隔2.5秒未満のため、自然瞬きを1回も観測できず: blink_events=0）。これは前回のmulti-speak smokeで同じファイル名が上書きされ続けた結果。

新規課金の前に、指示通り「既存ローカル素材で条件を満たせるか」をまず試した：**同じ既存音声ファイルを4回連続再生**（新規生成なしで観測時間を延長、追加課金ゼロ）することで、十分な条件を満たせた。

## 新規ElevenLabs request数 / retry数

**0 / 0。** 新規生成は不要だった。

## 発話長・再生時間

1回1.67秒 × 4回連続 = 総経過約10.20秒（同一renderer・同一rendererインスタンスを起動したまま）。

## blink event count

**2回。** いずれも開始→完了まで正常に遷移した（`idle`以外の状態に入り、`idle`へ復帰）。

## blink発生時にmouth/audio-level更新が継続した証拠

50ms間隔でサンプリングした結果、2回の瞬きウィンドウそれぞれで`raw_audio_level`が単一値に固着せず変化し続けていた：

| 瞬き | サンプル数 | レベル範囲 |
|---|---|---|
| #1 | 8 | 0.000 〜 0.435 |
| #2 | 8 | 0.235 〜 0.448 |

固着（同一値のまま停止）していれば範囲がゼロ幅になるはずだが、両方とも明確に変化しており、瞬き中もmouth/audio-level経路が停止していないことを確認できた。

全体では345サンプル中203サンプルが非無音（>0.02）で、発話区間を通じて口パクが継続していたことも確認済み。

## renderer offline有無

**なし。** 全サンプルを通じて`is_offline=False`。

## clean stop

`renderer.stop()`後、描画スレッドが停止していることを確認（`thread alive=False`）。

## blocker

**NONE。**

## code change有無

**NO。** 新規テストスクリプト（既存ファイル無編集の監視用フックのみ）を2本追加しただけ（1本目は音声が短すぎたための予備確認、2本目が本結果）。

## Owner burden rule

ケイへコード探索・ログ採取・ACK追跡・再説明を戻していません。今回は新規課金が不要だったため、許可依頼も発生しませんでした。
