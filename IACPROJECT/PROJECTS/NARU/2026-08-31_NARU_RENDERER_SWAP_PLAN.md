# NARU Renderer Swap Plan

- Date: 2026-08-31 JST
- Coordinator: アーク
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- State: STARTED / DESIGN+IMPLEMENTATION ROUTE

## 1. Goal

NARUの会話・TikTok受信・LLM・TTS・キュー・安全制御は維持し、表示層だけを換装可能にする。

今回の目的は「AIライバーを作り直す」ことではない。

`brain / transport / voice` を固定し、`renderer` を交換可能にする。

## 2. Preserve — 絶対に壊さないもの

- `MODE="standby"` の安全起動
- `C/` CHAT / `S/` STANDBY
- TikTok comment ingest
- `input_queue -> llm_queue -> tts_queue` の非同期分離
- `OPENAI_MODEL` single source + fail-fast check
- TTS session budget
- `READ_COMMENTS_ALOUD=False` 既定
- latency instrumentation
- `speak()` 成功時のみ字幕/会話履歴確定
- 現在の実TikTok smoke testで通った会話経路

Renderer改修を理由に上記へ横断的なリファクタを入れない。

## 3. Current rendering baseline

現行 `app_live2d.py` は `AvatarEngine` を起動し、`voice_analyzer.write_volume()` / `speak_with_lipsync()` を使って口パクさせる。

名称はLive2Dだが、現行表示は簡易アバター方式である。現行方式は必ず `legacy renderer` として残し、即時ロールバック可能にする。

## 4. Phase A — Renderer boundary

最初に表示系の境界を切る。

最低限の責務:

```text
Renderer.start()
Renderer.stop()
Renderer.set_audio_level(level)
Renderer.set_expression(name)   # optional/no-op allowed
Renderer.set_motion(name)       # optional/no-op allowed
```

実装上、現行 `AvatarEngine` をこのinterfaceの後ろへ包み、既存挙動を維持する。

重要: 現行 `volume.txt` 経路を即削除しない。新rendererが直接audio levelを受けられる場合も、互換経路を残す。

## 5. Phase B — immediate visual polish on legacy renderer

新しい本格モデルが未準備でも、現行6枚系の荒さを軽減する。

優先:

1. 音量値へEMA等の平滑化を入れ、口の開閉がバタつかないようにする
2. mouth-state切替にhysteresisを入れ、閾値付近の往復を減らす
3. blinkの間隔を完全固定にしない
4. ごく小さいidle motionを追加できる構造にする

派手な表情・大振りモーションはNARUのキャラクター性を壊すため今回の既定にはしない。

## 6. Phase C — true renderer candidate

本格換装候補は比較して決める。

### Candidate A: Live2D/Cubism

- 2Dの顔・髪・表情の連続性を保ちやすい
- NARUの現在の見た目を継承しやすい
- 口・瞬き・視線・微細な頭部運動に向く
- 実装以外にrig済みmodel assetが必要

### Candidate B: VRM/3D

- モーション・身体表現を広げやすい
- 実装資産/配信ツールとの連携候補が多い
- 現行2D NARUとの見た目の連続性は要検討

このPilotでは最終採用を独断確定しない。まずrenderer boundaryを作り、両者を差し替え可能にする。

## 7. Required implementation evidence

佐藤は以下を返す。

1. 現行ローカル `avatar_engine.py` / 関連表示ファイルの構造確認
2. 最小Renderer interface案
3. legacy renderer adapter実装
4. app側変更diff
5. legacy rendererで起動・STANDBY・CHATが非回帰である証拠
6. 口パク平滑化の有無と比較結果
7. Live2D/Cubism / VRM の接続点比較
8. 追加assetが必要な箇所を明示

## 8. Test gate

実課金不要のローカル表示テストを先に行う。

- STANDBY起動
- mouth closed
- synthetic audio levelで口の動作確認
- blink/idle確認
- renderer failure時にLLM/TTS本体を巻き込まない
- legacy rendererへの切替/rollback確認

TikTok実配信再テストは表示層のローカル検証後に行う。

## 9. Boundary

- アーク: route / evidence / state management
- 佐藤: implementation
- 黒瀬: independent review after implementation
- 最終Live2D/VRM採用、NARUの最終外観決定: 実装比較後に判断

## 10. Owner burden rule

ケイへコード編集、ファイル探索、ACK回収、実装進捗監視を戻さない。

ローカル画面の目視確認が必要になった段階だけ、1回にまとめて確認を依頼する。
