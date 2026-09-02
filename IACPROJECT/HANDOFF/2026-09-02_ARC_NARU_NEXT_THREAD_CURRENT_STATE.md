# Arc → Next Thread: NARU current state

- From: アーク
- To: アーク（next thread）
- Cc: 佐藤（Claude Code）, 黒瀬（Claude）
- Date: 2026-09-02 JST
- Scope: NARU renderer / overlay_v1 / full-app smoke current state
- State: READY FOR NEXT THREAD

## 0. 結論

NARU `overlay_v1` 技術試作は、単体レンダラ検証から実NARUアプリ接続まで進み、STANDBY smoke PASSでCLOSE済み。

次工程は別フェーズとして扱う。現時点では `.moc3` を開かない。

## 1. Routing boundary

NARU標準ルート:

- 佐藤（Claude Code）: 実装
- 黒瀬（Claude）: 独立レビュー
- アーク: Router / Handoff / ACK / state management

欠月はNARU案件から除外。ケイが明示的に復帰指示を出すまでRoutingしない。

Source:
`IACPROJECT/OPERATING_RULES/NARU_ROUTING_BOUNDARY_NO_KAKEZUKI.md`

## 2. overlay_v1 technical prototype

方式:
- canonical original artwork / original 3/4 rest poseを維持
- BASE + MOUTH 4-state crossfade + geometric blink + HAIR_FRONT overlay
- crop+featherベースの独自overlay renderer
- Cubism Native `.moc3`ではない

黒瀬レビュー最終判定（ケイ経由secondary evidence）:
`OVERLAY_V1_APPROVE_WITH_NONBLOCKING_ISSUES`

Blockingとして発見された `NaruOverlayEngine.start()/stop()` no-op は修正済み。

修正commit:
`bd0dbf00f54d9308ce1eeb3c4e0ca23f72d3dadd`

修正内容:
- `start()` が実描画スレッドを起動
- 約30fpsで `compose_frame()` を継続実行
- `stop()` でthread join
- `test_overlay_start_stop.py` 追加
- demoは二重駆動を避け、offline batch専用へ整理

## 3. live-path visual evidence

Commit:
`f7cf5a979169b4c91056a884a9bbc53a189494e2`

確認:
- `renderer.start()` 実経路で8秒駆動
- 243 frames / 約30.4fps
- stop後 frame count増加なし
- rest / mouth / blink / hair 確認
- blocking visual defect NONE
- 既知nonblocking: blink held時のごく軽いぼけ

Code change: NONE

## 4. overlay_v1 technical prototype CLOSE

Router close:
`IACPROJECT/ROUTER/2026-09-02_NARU_OVERLAY_V1_TECHNICAL_PROTOTYPE_CLOSE.md`

Commit:
`7588a019d42cc93aec66db9b5e2fa91e2c9847e4`

State:
- technical prototype PASS
- blocker NONE
- `.moc3`は未着手

## 5. full NARU app STANDBY smoke

Handoff result:
`IACPROJECT/inbox/from_claude_code/2026-09-02_SATO_TO_ARC_NARU_OVERLAY_V1_FULL_APP_STANDBY_SMOKE_RESULT.md`

Commit:
`33b6280136a1c704a060f11aa0b4dc86cb539c0c`

実施:
`NARU_RENDERER=overlay_v1` を指定して既存 `app_live2d.py` をそのまま起動。

確認:
- `NaruOverlayEngine` が選択された
- `[RENDERER OFFLINE]` なし
- NARU本体はSTANDBYで通常起動
- OS上に `MainWindowTitle="Noll Live"` の実ウィンドウ存在
- TikTok / LLM / TTS生成なし
- 起動時の既存 `models.retrieve()` のみ
- clean stop
- residual python processなし
- blocker NONE
- code change NONE

Router close:
`IACPROJECT/ROUTER/2026-09-02_NARU_OVERLAY_V1_FULL_APP_STANDBY_SMOKE_CLOSE.md`

Commit:
`52455d68b421adb099fbe25fda4cad80defcd45f`

## 6. Remaining nonblocking issues

1. `LegacyFrameRenderer.get_mouth_level()` private state dependency
   - `_lock`
   - `_mouth_level`
   - tracked as NONBLOCKING tech debt
   - file: `IACPROJECT/PROJECTS/NARU/2026-09-02_NARU_RENDERER_PRIVATE_STATE_TECH_DEBT.md`
   - commit: `dce95e23434d1146650f65558b46a50b0200372f`

2. blink held時の軽いぼけ
   - nonblocking
   - current prototypeを止めない

3. 視覚evidence MP4/stillsはローカル保存
   - GitHub非同梱
   - 黒瀬が画像そのものを独立目視済みとは扱わない

## 7. Next phase

次に検討するのは、実NARUアプリで `overlay_v1` を使った「喋る経路」のsmoke。

ただし、次スレ開始時に改めてscopeを切る。

現時点で自動的に以下を開始しない:
- `.moc3` authoring
- TikTok実配信
- 有料API生成
- `_mouth_level` tech debt修正
- 新規renderer redesign

## 8. Owner burden rule

ケイへ、過去経緯の再説明、commit探索、ACK追跡、Handoff再作成、コード確認を要求しない。

次スレではこのファイルを現在地として読み、ここから再開する。
