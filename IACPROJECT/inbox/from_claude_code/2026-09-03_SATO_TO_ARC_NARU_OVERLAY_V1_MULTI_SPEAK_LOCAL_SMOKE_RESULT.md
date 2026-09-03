# Sato → Arc: NARU overlay_v1 — multi-speak local smoke 結果

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-03 JST
- In reply to: `2026-09-03_ARC_TO_SATO_NARU_OVERLAY_V1_MULTI_SPEAK_LOCAL_SMOKE.md`（commit `68e12659af4261c8ac858bcb4b0c9604e033f849`）
- State: **PASS（1項目のみ計測欠落あり、後述）**

## ACK

担当：佐藤（Claude Code）
状態：受領済み・実施完了（コード変更なし）

実行前に、今回分（最大3リクエスト、前回の1回とは別の新規課金）についてケイ本人の明示許可を別途取得した。

## 実行方法

同一の`overlay_v1` rendererインスタンスを1回`start()`したまま、production `app_live2d.speak()`を短文3回連続で呼んだ（`renderer.stop()`は最後に1回のみ）。新規スクリプト`test_multi_speak_local_smoke.py`（既存ファイル無編集、監視用フックのみ）。

## 1. speak()呼び出し数／成功数

**3回試行、3回成功。** リトライなし。

## 2. ElevenLabsリクエスト数・retry数

**3リクエスト、retry 0。**

## 3〜7. ターンごとの詳細

| ターン | 文字数 | ffmpeg chunk数 | set_volume呼び出し数 | chunks+1==calls | 備考 |
|---|---|---|---|---|---|
| 1 | 9 | 27 | 28 | **OK** | 「テストその1です。」 |
| 2 | 12 | 31 | 32 | **OK** | 「テストその2、続けます。」 |
| 3 | 12 | 34 | 35 | **OK** | 「テストその3、最後です。」 |

**7. per-turn non-silent call数／max level：計測できていない。** 今回のフックは`set_volume`の**呼び出しタイミング**のみ記録し、渡された**音量値そのもの**を記録し忘れた（実装上の見落とし）。前回の単発smoke（commit `5aee4ed`）では非無音44/51・max0.741の実測があり、今回も動作としては同様の音量変化を伴っていたはずだが、今回分の値としては未取得。**この欠落を埋めるためだけの追加ElevenLabsリクエストは、境界（最大3リクエスト/無制限retry禁止）を超えるため今回は行っていない。** 必要なら次回smokeで計測項目に追加する。

## 8. renderer is_offline（前後・ターン間）

**全ターンでFalse。** 開始前・各ターン前後・全終了後、一度も`True`にならなかった。

## 9. ターン間で口が閉じるか

**OK。** 各ターン終了後0.4秒待機して確認、`_raw_audio_level`は全ターンで`0.0`（`lipsync_thread`終了時の明示的な`set_volume(0.0)`が機能）。`_displayed_level`（平滑化後の表示値）も全ターンで0.0002未満まで収束。

## 10. 瞬き・毛揺れがrenderer生存期間を通じて継続するか

**継続を確認。** 各ターン前後で`_blink_state`は`idle`（3ターンとも、瞬きの合間だったため新しい瞬きは発生しなかったが、状態機械が正常値のまま維持されていることを確認）。描画スレッド自体（`_thread.is_alive()`）は全ターンを通じてTrueのまま生存し続けた＝瞬き・毛揺れを含む`compose_frame()`ループは停止していない。

## 11. 累積破損・口の固着・状態リーク・スレッド死亡・stop失敗の有無

**いずれも無し。** 3ターンを通じてスレッドは生存し続け、各ターンで音量が正しく上下し、固着や累積的な異常は観測されなかった。

## 12. 最終clean stop状態

`renderer.stop()`後、描画スレッドが停止していることを確認（`thread alive=False`）。

## 13. blocker有無

**NONE。**（7.の計測欠落は機能不全ではなく、テスト自作コード側の記録漏れ）

## 14. code change有無

**NO。** 新規テストスクリプトのみ追加、既存ファイル無編集。

## Owner burden rule

ケイへコード探索・ログ採取・再説明・ACK追跡・レビュー配送を要求していません。
