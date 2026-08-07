# MEDICAL_SYMPTOM_MULTI_AI_REVIEW_PROTOCOL

**Status**: CANONICAL / MANDATORY READ
**Owner**: ケイ
**Operational maintainer**: アーク
**Source Handoff**: `IACPROJECT/HANDOFF/inbox/to_arc/2026-08-07_uehara_to_arc_external_ai_medical_review_priority.md`
**Source commit**: `e84251811d65f8a09250e8e7e781b3ef7749581d`
**Date**: 2026-08-07 JST

## Purpose

重大度の高い医療・体調イベントの解析を単独AIだけで閉じず、既存の連続データ・時系列・過去の同型反応・介入前後の変化を保持したまま、必要時に独立レビューへ回すための運用規約。

この文書は医療判断そのものを確定するものではない。解析経路・役割境界・レビュー形式を定める。

## Mandatory analysis order

身体症状の一次整理は、次の順序を崩さない。

1. 観察事実
2. 時系列
3. 過去の同型反応
4. 介入前後の変化
5. 高優先度仮説

一般論や未実測項目の確認待ちだけを理由に、既存の連続データや介入前後の変化を本筋から外さない。

## Multi-AI review rule

重大度が高い医療・体調イベントでは、単独AIの回答だけを正本化しない。

必要時、外部AIレビューでは以下だけを確認する。

- 本筋を壊さない矛盾検出
- 見落とし確認
- 代替解釈の優先順位付け

低優先度の可能性を大量に列挙して本筋をぼかすレビューは禁止する。

レビュー結果は必ず次の3区分で返す。

- 本筋
- 補強材料
- 低優先度候補

## Role boundaries

- 上原さん：身体データ、時系列、介入前後の変化を整理する。
- ユエ：認知・情動・過覚醒側との関連を整理する。
- 外部AI：本筋を維持したまま矛盾・見落とし・優先順位をレビューする。
- アーク：Review Packet、配送経路、ACK、滞留管理を担当する。
- ケイ：AI間の伝令、再説明、素材再整理を担当しない。最終判断のみ保持する。

## Review Packet rule

外部AIレビューが必要な場合、アークが既存ログから1本のReview Packetを作る。ケイに経緯の再説明・再送・再編集を求めない。

GitHub Pull可能なAIにはRouter経由でsource/contextを固定する。GeminiなどPull不能なAIにはアークが単一Packetへ必要情報を同梱する。

## Safety boundary

この規約は、緊急時の受診・救急判断をAIレビュー完了まで待つことを意味しない。緊急性の高い状態では現実の医療対応を優先する。

## Distribution state

Canonical registration alone does not mean all members have read it. `CURRENT_DELIVERIES.md` と ACK で REGISTERED / DELIVERED / ACKNOWLEDGED を追跡する。
