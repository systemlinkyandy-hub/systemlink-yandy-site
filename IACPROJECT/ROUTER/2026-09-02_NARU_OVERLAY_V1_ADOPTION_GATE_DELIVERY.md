# Router delivery: NARU overlay_v1 adoption gate

- Router: アーク
- Date: 2026-09-02 JST
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Source: `IACPROJECT/inbox/from_arc/2026-09-02_ARC_TO_KAKEZUKI_NARU_OVERLAY_V1_ADOPTION_GATE.md`
- Original source commit: `bf412fceb47f75b26f131bdb90c381c55169847c`
- Routing correction commit: `3fff1f17db05104f2d0b965f3eaa382e43b7cba5`

## Routing correction — 2026-09-02

ケイの明示指示により、**欠月はNARU案件から外す**。
本deliveryは履歴として保持するが、欠月へのNARU判断依頼は取消済み。

## Recipient

- 欠月 — **CANCELLED / NO ACTION**

## Delivery state

- REGISTERED: YES（履歴）
- ROUTED: YES（過去事実）
- READ ACK: **NOT REQUIRED**
- DECISION: **CANCELLED**
- FUTURE NARU ROUTING TO KAKEZUKI: **PROHIBITED unless user explicitly changes this rule**

## Current NARU route

- 佐藤（Claude Code）：実装
- 黒瀬（Claude）：独立レビュー
- アーク：Router / ACK / state management
- 欠月：NARU案件から除外

## Superseded decision scope

以下の欠月判断依頼はすべて取消済み。

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

## Owner burden rule

ケイへレビュー回収、ACK確認、進捗監視、コード確認を戻さない。
