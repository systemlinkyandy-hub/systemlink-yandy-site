# Arc → 佐藤: NARU overlay_v1 live-path visual evidence only

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-02 JST
- State: GO / EVIDENCE ONLY

## Context

黒瀬のケイ経由secondary reviewでは、`start()` / `stop()` 描画駆動ループ修正は FIX VERIFIED。
総合判定は `OVERLAY_V1_APPROVE_WITH_NONBLOCKING_ISSUES`。

Router登録:
`IACPROJECT/ROUTER/2026-09-02_NARU_OVERLAY_V1_KUROSE_REVIEW_RESULT.md`

## Required action

**コード変更を目的にしない。**
現行 `overlay_v1` の実 `renderer.start()` 経路が、目視可能な状態でどう見えるかを確認できる最小visual evidenceを作る。

最低限確認対象:
- rest
- mouth motion
- blink closing / held / opening
- HAIR_FRONT sway
- start → live render loop → stop の実経路

## Evidence form

ローカルでよい。

- 5〜10秒程度の短い画面録画、または同等の最小visual evidence
- 必要なら代表still
- 実行したrenderer routeと手順を短いHandoffへ記録

GitHubへbinaryを無理に登録しない。
ケイへファイル探索・変換作業を戻さない。

## Hard constraints

- `.moc3` authoringを開始しない
- NARU core conversation / TikTok ingest / LLM / TTS / queueを変更しない
- mouth / blink / hair logicを追加変更しない（visual evidenceで新しいblocking defectが見つかった場合のみ報告して止める）
- `_mouth_level` tech debtは今回修正しない
- legacy / legacy_smooth / live2d routeを変更しない
- canonical artworkを変更しない

## Return

Handoffに以下だけ返す:
1. evidence生成結果
2. 実 `renderer.start()` 経路で表示できたか
3. rest / mouth / blink / hairの目視所見
4. blocking visual defectの有無
5. evidence local path
6. commit（Handoffのみで可）

blocking visual defectが無ければ、次の判断はアークが引き取る。

## Routing boundary

NARU標準ルートは 佐藤 → 黒瀬 → アーク。
欠月へRoutingしない。
