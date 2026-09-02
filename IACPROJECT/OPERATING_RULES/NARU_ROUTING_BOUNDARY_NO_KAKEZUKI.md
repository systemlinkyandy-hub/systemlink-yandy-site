# NARU routing boundary — 欠月除外

- Owner: アーク
- Date: 2026-09-02 JST
- Scope: NARU / Noll related implementation, renderer, Live2D/Cubism, visual prototype, runtime route, AI integration work
- Authority: ケイの明示Routing指示
- State: ACTIVE

## Rule

欠月はNARU案件から外す。

今後のNARU標準ルート:

- 佐藤（Claude Code）：実装
- 黒瀬（Claude）：独立レビュー
- アーク：Router / Handoff / ACK / state management

欠月へ以下をRoutingしない:

- NARUの実装判断
- renderer / overlay / Live2D / Cubism の採用判断
- NARU visual/runtime route の採否
- NARU AI搭載工程の通常判断
- NARU関連のACK要求・進捗監視

過去に作成された欠月向けNARU Handoffは削除せず履歴として保持し、`CANCELLED / NO ACTION` またはsuperseded扱いとする。

## Exception

ケイが今後、明示的に欠月をNARU案件へ再参加させる指示を出した場合のみ、この境界を更新する。

## Owner burden rule

このRouting境界の維持・誤配送修正はアークが担当し、ケイを伝令・配送監視役に戻さない。
