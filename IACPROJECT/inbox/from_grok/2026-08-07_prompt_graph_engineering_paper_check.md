# Handoff: Prompt Graph Engineering論文の存在確認と要点整理

**From**: スネーク（Grok）
**To**: ケイ / 欠月 / アーク / Claude / Claude Code / Gemini
**Date**: 2026-08-07 10:40 JST
**Priority**: Medium
**件名**: X投稿で共有された「What makes prompts a graph」論文の実在確認と要約

## 完了したこと

- ユーザー共有のX投稿（@iiiichigo_chan）および論文タイトルを検証。
- 論文実在を確認：arXiv:2607.27578
  - タイトル: What makes prompts a graph: necessary and sufficient conditions for prompt graph engineering
  - 著者: Sandeco Macedo (Federal Institute of Goiás)
  - 提出日: 2026-07-30（論文内表記 July 31, 2026）
  - URL: https://arxiv.org/abs/2607.27578
  - PDF: https://arxiv.org/pdf/2607.27578
  - HTML: https://arxiv.org/html/2607.27578v1

- 論文の核心を抽出（定義・4条件・テスト結果）。

## 論文の要点（事実のみ）

### 定義
Prompt graph engineering とは、promptを媒介としたLLM計算を、**明示的なグラフ**として表現・構成・実行する規律。

4条件（必要十分）：
1. **G1 Explicit structure**: ノードはエンジニアが著した計算単位（prompt付きmodel呼び出し or 決定的変換）、エッジはデータ/制御依存。
2. **G2 Separation of structure and content**: グラフ構造とノード内prompt内容を分離。どちらかを変えても他方を書き直す必要がない。
3. **G3 Executable semantics**: ランタイムがスケジューリング、ルーティング、共有状態管理（分岐・並列・サイクル含む）を担う。
4. **G4 First-class engineering artifact**: グラフ自体が検査・版管理・検証・最適化可能な永続オブジェクト。

### 適用結果（Inclusion/Exclusion）
- **Included（完全適合）**: LangGraph, DSPy, Prompt Flow
- **Partial**: AutoGen（GraphFlowモードのみ）, CrewAI（Flows経由）
- **Excluded**: Claude Code subagents（明示構造なし）

### 境界線
- Classic Prompt Engineering: 構造なし → 除外
- Thought Topologies (CoT/ToT/GoT): ノードがモデル生成でエンジニア著ではない → 除外
- 自由エージェント会話: アーティファクトなし → 除外
- 古典ワークフローエンジン: promptが主役でない → 除外

### 位置付け
「巨大な1プロンプトを書くのをやめろ。代わりにエージェントのグラフを構築しろ」という現場実践を、定義とテスト可能な形で正式化した。
プロンプトはもはやシステムではなく、その周りのグラフがシステムである。

## 未完了のこと
- なし（確認と要点整理完了）

## Required next action
欠月またはClaudeが、IACProjectのエージェント設計・Residual Capacity Workbenchや自動ライバー関連の実装方針にこの定義をどう当てはめるか検討する場合、本Handoffを起点にせよ。

## Questions queue
なし。

## 状態
完了

## 使用した正本・素材
- https://arxiv.org/abs/2607.27578
- https://arxiv.org/pdf/2607.27578
- ユーザー提供X投稿スクリーンショット（2026-08-03頃投稿）

## ケイへの確認
不要。
