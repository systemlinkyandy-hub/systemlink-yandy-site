# Arc → Sato: NARU overlay_v1 full `speak_with_lipsync()` smoke

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-03 JST
- Priority: High
- State: **READY TO EXECUTE**

## 0. Background

前工程 `overlay_v1` speaking-path smoke は黒瀬独立レビューで `SPEAKING_PATH_SMOKE_APPROVE`。

Router close:
`IACPROJECT/ROUTER/2026-09-03_NARU_OVERLAY_V1_SPEAKING_PATH_SMOKE_CLOSE.md`

次の最小ゲートとして黒瀬が指定したものだけを実施する。

## 1. Goal

`NARU_RENDERER=overlay_v1` 環境で、ElevenLabsの**新規音声生成を含む production `speak_with_lipsync()` 自体**を1回だけ通し、

`text → ElevenLabs TTS → output.mp3 → play_with_lipsync() → audio level → overlay_v1 mouth → playback complete`

が一気通貫で成立することを確認する。

## 2. Scope

実施するのは1回の短いローカルsmokeのみ。

必須:
- `NARU_RENDERER=overlay_v1`
- production `voice_analyzer.speak_with_lipsync()` を直接使用
- ElevenLabs新規生成 1 request
- TTSテキストは動作確認に必要な最短の自然文（目安20〜40日本語文字以内）
- `NaruOverlayEngine` 選択確認
- TTS request success / audio ready
- 実ffmpeg音量解析確認
- `set_volume()` 実呼び出し確認
- playback complete
- renderer offlineなし
- clean stop

## 3. Cost / retry boundary

今回は有料APIを含むため、無制限retryは禁止する。

- 新規ElevenLabs生成は原則 **1 requestのみ**
- smoke用テキストを短くし、消費文字数を最小化
- API key/auth/network等、rendererと無関係な理由で request が成立しなかった場合は、その事実を返して停止する
- 同一条件での反復再生成を自動で行わない
- 既存NARUには `NARU_TTS_SESSION_BUDGET` の安全上限があるが、このsmoke自体はさらに短文1回に限定する

## 4. Explicitly out of scope

以下は開かない:
- TikTok実配信
- TikTok ingest変更
- `.moc3` authoring
- renderer redesign
- `_mouth_level` tech debt修正
- LLM生成経路の追加テスト
- voice selection / voice tuning
- latency optimization
- productionコードの横断リファクタ

## 5. Evidence to return

Handoffには最低限以下を返す:

1. 実行した関数と条件
2. TTS入力文字数
3. ElevenLabs request回数
4. TTS成功/失敗
5. output audio生成確認
6. ffmpeg実解析のchunk数
7. `set_volume()` call数（可能なら `chunks + 1` 整合も確認）
8. non-silent call数 / max level（取得可能なら）
9. renderer offline有無
10. playback complete
11. clean stop
12. blocker有無
13. code change有無

## 6. Success criterion

以下を全て満たせば PASS候補:

- ElevenLabs新規生成が1回成功
- production `speak_with_lipsync()` がTrueで完了
- 実音声解析 → mouth更新が成立
- renderer offlineなし
- clean stop
- 新しいblocking regressionなし

## 7. Routing after result

結果はアークへ返す。
アークが受領・整合確認後、黒瀬へ最終独立レビューを回す。
ケイを伝令役にしない。

## Owner burden rule

ケイへコード探索、ログ採取、再説明、ACK追跡、レビュー配送を要求しない。
