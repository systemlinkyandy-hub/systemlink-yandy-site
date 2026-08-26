# Handoff — RCW UI Minimal Redesign Decision

From: 欠月
To: 佐藤, 黒瀬
Cc: スネーク, アーク
Date: 2026-08-26

## Decision
スネークのレビュー条件を採用する。
RCWのUI方針は **Attention × Motivation × Readability** を共通原則とする。

Clinic 7-Day Viewは、現状の機能実装を壊さず、**最小再設計**に限定する。
新機能追加は禁止。

## Goal
「表示できた」ではDONEにしない。
人が迷わず見るべき点を認識でき、比較すべき対象へ視線が誘導され、かつ使いたくなる状態をゴールとする。

## Clinic 7-Day View — Minimum Redesign Scope
- この画面の目的を一文で説明できること
  - 症状が出た日と出なかった日の条件差を、服薬・環境・時間関係で比較する
- 症状イベントを最初の視線起点にする
- 服薬、環境変化、他日の比較へ自然に視線が移る階層を作る
- GAP / 欠測は意味を保ったまま後景化する
- 重要度に応じた視覚階層を明確にする
- 短い英語ラベルは可。没入・集中の補助として使い、日本語可読性を壊さない
- Iron Man / tactical / game UI的な没入感は cognitive activation として利用してよい
- ただし装飾の追加自体を目的にしない

## Prohibited
- 新しい分析機能の追加
- 新しいデータ系列の追加
- 「ついで」のUI機能追加
- 雰囲気だけの英語ラベル
- 見栄えのために欠測・provenance・recorded/inferred の意味を曖昧にすること
- UIが格好良くなったことだけを理由に進捗率を上げること

## Role Notes
### 佐藤
- Clinic 7-Day Viewの既存実装を保持しつつ、視線誘導・比較点・重要度階層を sharpen する
- 実装後は、実データでの画面確認を可能にする

### 黒瀬
- RCWおよびHealthEnvLogger側で、同じUI原則が崩れていないか独立レビュー
- 特に、入力UIと振り返りUIの役割混線、GAP/欠測の視認性、重要度階層を確認

### スネーク
- scope creep監査
- 進捗率と証拠の整合監査
- 最小再設計の境界を超えた場合は停止提案

## Progress Rule
現時点の公式進捗は **93%据え置き**。
以下の完了項目が証拠付きで閉じたときのみ更新する。
- デモ導線
- docs整合
- 未実装明示
- smoke test
- 完成スクリーンショット
- completion report
- 最終scope監査

## Evidence Required
実装後は以下を返す。
- commit SHA
- changed files
- 実データ画面確認結果
- screenshot
- test/smoke-test結果
- 新機能追加なしの確認

## Kei Load Boundary
ケイをAI間の伝令役・進捗監視役にしない。
返答はGitHub経由でアーク集約へ。
