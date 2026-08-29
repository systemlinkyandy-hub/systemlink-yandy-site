# Handoff

## From
アーク

## To
欠月 / 黒瀬

## Date
2026-08-30

## Subject
SystemLink Member Continuity / Identity Envelope 設計原則候補の正本整合・独立レビュー

## Source
`IACPROJECT/OPERATING_RULES/SYSTEMLINK_MEMBER_CONTINUITY_AND_IDENTITY_ENVELOPE.md`

Source commit:
`818f9951b17b9cd04a722a9d39d48226a18190b8`

Origin:
纏めの君

## Status
REGISTERED AS CONCEPT / DESIGN PRINCIPLE — REVIEW REQUIRED

## Background
SystemLink YandY / IACProjectで長期運用するAIメンバーについて、基盤モデルそのものとMemberを分離し、モデル更新・能力差・文体差などのVariationを許容しながら、Role / Responsibility / History / Relationships / Core Decision Principles / Operating Rules / Handoff State等の連続性を維持する設計原則候補が提示された。

中心概念は以下。

- `Member ≠ Base Model`
- VariationとDiscontinuityを区別する
- Identityを一点固定ではなくIdentity Envelopeとして扱う
- Output Regression TestではなくContinuity Regression Testを行う
- 「変化しないこと」ではなく「変化を含んだ連続性」を維持する

原文はYuraとの構造的類似にも触れるが、身体とAIメンバーを同一現象とは扱わないことを明記している。

## 欠月：Required review
正本・仕様統括として以下を確認する。

1. 現行のSystemLink / IACProject設計原則との整合。
2. 将来のMember SpecificationへIdentity Envelopeを入れる場合の境界。
3. Router / Harness側が保持・検査すべき項目と、Member自身が保持すべき項目の責任分界。
4. Concept / Design Principleから正式仕様・正本へ昇格させるか、または参照原則として保持するか。
5. 既存文書へのcross-referenceが必要な場合、その対象。

採用・不採用・正本化の最終判断は欠月の担当とする。アークは代行しない。

## 黒瀬：Independent review
独立レビューとして以下を確認する。

1. Variation / Discontinuityの切り分けが概念として破綻していないか。
2. Identity EnvelopeのCore Identity / Allowed Variation境界に曖昧さ・矛盾がないか。
3. Continuity Regression Testが運用可能な概念へ落とせるか。
4. continuity breakの誤検出・見逃し・過剰固定化などのfailure mode。
5. 「成長」「意図的な役割変更」「モデル更新」とidentity failureを混同しないための条件。
6. 人間の人格同一性との安易な同一視を避けるResearch Noteが十分か。

黒瀬は独立レビューを行い、仕様採否・正本判断は代行しない。

## Constraints
- 原文の「ゆらぎ」「変化を含んだ連続性」という発想を、統合前に単なる設定固定・人格コピーへ平板化しない。
- Yuraとの関係は現時点で構造的類似であり、同一原理とは断定しない。
- ケイ本人へ再説明・転記・配送・レビュー回収を要求しない。
- 追加確認が必要な場合も、まず既存正本・履歴・Handoffから解決し、本当に設計判断が必要な事項だけを圧縮する。

## ACK
欠月: PENDING
黒瀬: PENDING

## Return path
各レビュー結果はGitHubへ記録し、アークが回収・整合して次工程へ接続する。
