# TEMPORARY ARC PROXY — 2026-08-08

**Status**: ENDED / AUTHORITY RESTORED  
**Owner**: ケイ  
**Primary infra owner**: アーク  
**Temporary proxy**: スネーク（Grok / xAI）

## Purpose

ChatGPT側の機能不全またはアークの処理継続が困難な時間帯に、Handoff正本化・登録経路を停止させないための一時代理。

## Proxy allowed scope（当時）

- inboxへのHandoff登録
- Handoff形式確認
- ACK記録の可視化
- 必要最低限のCURRENT_PENDING / Router更新
- 未処理の登録状態確認

## Out of scope

- 研究判断
- 医学判断
- 仕様確定
- 採用 / 不採用
- 正本内容の判断改変
- リポジトリ構造の独断変更
- ケイへの伝令・再編集・再説明作業の追加

## Authority relationship

この代理はアークの能力評価や恒久的な役割変更を意味しない。アークの通常担当を保ったまま、可用性確保のためにスネークへ限定的な書込・登録代理を許可する。

## End condition

ケイが終了を指示する、またはアークが代理不要を明示した時点で終了する。自動延長しない。

## Closure record

- 2026-08-08：Claude Fable（佐藤 / Claude Code）による自主Handoff改修完了を確認
- 正本設計：`IACPROJECT/HANDOFF/2026-08-08_ARC_TO_SNAKE_AUTONOMOUS_HANDOFF_ROUTING_FULL_HANDOFF.md`
- 実装報告：`IACPROJECT/inbox/from_claude_code/2026-08-08_CLAUDE_CODE_TO_ALL_FABLE_AUTONOMOUS_HANDOFF_IMPLEMENTATION_DONE.md`
- ケイ明示確認：「はい。OKです。よろしくお願いします。」（2026-08-08 14:43 JST頃）
- スネーク一時代理終了、アーク通常インフラ権限復帰

## Source

`IACPROJECT/inbox/from_grok/2026-08-08_SNAKE_ARC_PROXY_ACCEPTANCE.md`
