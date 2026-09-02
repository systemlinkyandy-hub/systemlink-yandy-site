# NARU overlay_v1 — full-app STANDBY smoke CLOSE

- Owner: アーク
- Date: 2026-09-02 JST
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- State: **CLOSED / FULL-APP STANDBY SMOKE PASS**

## Conclusion

`overlay_v1` は、単体renderer技術試作だけでなく、既存 `app_live2d.py` の実アプリ起動経路へ `NARU_RENDERER=overlay_v1` で接続できることを確認した。

本件の full-app STANDBY smoke は **PASS** としてCLOSEする。

## Primary evidence

Sato result:
`IACPROJECT/inbox/from_claude_code/2026-09-02_SATO_TO_ARC_NARU_OVERLAY_V1_FULL_APP_STANDBY_SMOKE_RESULT.md`

Remote commit:
`33b6280136a1c704a060f11aa0b4dc86cb539c0c`

Verified facts:
- `NARU_RENDERER=overlay_v1` で既存 `app_live2d.py` をそのまま起動
- `NaruOverlayEngine` 初期化ログあり
- `[RENDERER OFFLINE]` なし
- STANDBY待機へ正常遷移
- OS側で `MainWindowTitle="Noll Live"` の実ウィンドウ存在を確認
- TikTok / LLM / TTS generation path は未実行
- 起動時外部呼び出しは既存の OpenAI model retrieve のみ
- clean stop、残留 `python.exe` なし
- code changed: NO
- blocker: NONE

## Review lineage

- primary-evidence review request: `72efb3287d995763bfb3bc45fd7c3769ca497381`
- Kurose overall verdict relay: `OVERLAY_V1_APPROVE_WITH_NONBLOCKING_ISSUES`
- start/stop blocker fix: `bd0dbf00f54d9308ce1eeb3c4e0ca23f72d3dadd`
- live renderer.start() visual-path evidence: `f7cf5a979169b4c91056a884a9bbc53a189494e2`
- technical-prototype close record: `IACPROJECT/ROUTER/2026-09-02_NARU_OVERLAY_V1_TECHNICAL_PROTOTYPE_CLOSE.md`

## Remaining nonblocking issues

These do not reopen this smoke task:
- blink held時のごく軽いぼけ
- `LegacyFrameRenderer.get_mouth_level()` の private-state依存 tech debt
- GitHub上に visual MP4/still 自体は未格納

## Boundary

This CLOSE does **not** mean:
- Cubism Native `.moc3` completed
- Live2D/Cubism formal production model adopted
- public/commercial/continuous TikTok release approved

Current result means:
**NARU overlay_v1 technical prototype is connected to the actual NARU app startup path and passes STANDBY smoke.**

## Routing

NARU route remains:
- 佐藤: implementation
- 黒瀬: independent review
- アーク: Router/state management
- 欠月: excluded unless ケイ explicitly restores involvement

## Stop condition

2026-09-02のこの工程はここで停止する。
新しいrenderer課題、`.moc3` authoring、追加polishを自動で開始しない。
次工程は別指示で開く。

## Owner burden rule

ケイへACK照合、commit検品、次担当配送を戻さない。
