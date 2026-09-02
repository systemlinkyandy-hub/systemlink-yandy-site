# Router delivery: NARU overlay_v1 adoption gate

- Router: アーク
- Date: 2026-09-02 JST
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Source: `IACPROJECT/inbox/from_arc/2026-09-02_ARC_TO_KAKEZUKI_NARU_OVERLAY_V1_ADOPTION_GATE.md`
- Source commit: `bf412fceb47f75b26f131bdb90c381c55169847c`

## Recipient

- 欠月

## Delivery state

- REGISTERED: YES
- ROUTED: YES
- READ ACK: PENDING
- DECISION: PENDING

## Decision scope

欠月へ返した判断は以下のみ。

1. `overlay_v1` をNARU暫定visual/runtime routeとして採用するか
2. 技術試作のまま保留するか
3. Cubism Native `.moc3` 化を別ゲートとして維持するか

## Evidence state

- Sato smoke Handoff: primary GitHub artifact confirmed
- shared renderer `renderer.py` / `renderer.diff`: primary GitHub code evidence confirmed
- Kurose targeted verdict `SHARED_RENDERER_CHANGE_OK`: user-relayed secondary evidence at routing time
- Kurose source-authored review Markdown: not yet confirmed on remote

## Nonblocking follow-up

`LegacyFrameRenderer.get_mouth_level()` private state access (`_lock`, `_mouth_level`) is separated into:
`IACPROJECT/PROJECTS/NARU/2026-09-02_NARU_RENDERER_PRIVATE_STATE_TECH_DEBT.md`

This does not block the current decision gate.

## Owner burden rule

ケイへレビュー回収、ACK確認、進捗監視、コード確認を戻さない。
