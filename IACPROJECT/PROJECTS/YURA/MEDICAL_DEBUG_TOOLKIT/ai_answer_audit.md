# AI Answer Audit

## Metadata
- audit_id:
- date_time:
- service:
- model_or_mode:
- conversation_or_source_ref:
- user_goal:

## Prompt intent
AIに何を聞いたか。全文保存が不要なら意図だけでも可。

## Answer summary
回答の要点。引用ではなく要約を基本とする。

## Claims extracted
| claim_id | claim | kind | source cited by AI | verification |
|---|---|---|---|---|
| | | observation / medical / mechanism / recommendation / other | | unverified |

## Verification
- 原典確認:
- 医療記録との一致:
- 本人連続データとの一致:
- 反証・矛盾:
- 未確認点:

## How this answer is used
- [ ] 仮説生成のみ
- [ ] 調査キーワード生成
- [ ] 原典探索
- [ ] 比較材料
- [ ] 医療者への質問材料
- [ ] 実装・UI設計材料
- [ ] その他:

## Decision
- accepted_as_fact: no
- status: unverified / partially_verified / verified / contradicted / not_applicable
- notes:

> AIの回答そのものを医療事実として採用しない。主張単位で検証する。
