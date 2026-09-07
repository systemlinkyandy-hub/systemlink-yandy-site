# Handoff — NARU owner visual confirmation run

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Project: SystemLink YandY / IACProject / NARU
- Date: 2026-09-07 JST
- State: TECHNICAL GATES CLOSED / OWNER VISUAL CONFIRMATION PENDING
- Priority: NEXT ACTION

## Current state

`overlay_v1` は Cubism Native `.moc3` ではなく、既存 Renderer 抽象化上で動く crop + feather ベースの technical prototype。

以下は既にCLOSE済み。

- renderer selection
- start()/stop()
- 約30fps描画ループ
- full NARU app STANDBY smoke
- speaking path smoke
- production `speak()` full smoke（ElevenLabs新規生成込み）
- multi-speak smoke
- mouth + blink concurrency smoke

直近の独立レビューは、技術的にはブロッキングなし。残件はケイ本人による見た目確認のみ。

## Required next action

既存ローカル音声のみでNARUを起動し、owner visual confirmation を可能にしてくれ。

新規ElevenLabs生成・追加課金は不要。

### Ownerが見る点

1. 口と瞬きが同時でも顔が崩れない
2. 発話後に口が閉じる
3. 瞬き・毛揺れが自然
4. 数回喋っても固着・累積破損がない

確認時間は30秒程度で十分。

## Execution constraints

- `NARU_RENDERER=overlay_v1` を維持
- 新しいRenderer設計を開かない
- `.moc3` authoringを開かない
- TikTok実配信を開かない
- LLM実接続拡張を開かない
- `_mouth_level` private-state tech debt修正をこの作業に混ぜない
- 不要なElevenLabs追加課金をしない
- 既存の発話・瞬き・毛揺れ挙動を壊さない

## Return evidence

実行後は以下だけ返してくれ。

- 起動方法 / 実行コマンド
- 使用した既存ローカル音声の識別情報
- 画面録画または確認可能なキャプチャ（可能なら）
- 口閉じ / 瞬き / 毛揺れ / 複数発話後の状態に関する実行側メモ
- renderer thread が clean stop したか
- 変更ファイルの有無
- commit（変更がある場合）

## Owner burden rule

ケイへ以下を戻さない。

- commit探索
- コード確認
- テストログ採取
- Handoff配送
- 次担当判断

アークがRouterとして引き取る。

## Gate rule

この実行は新しい技術合否ゲートではない。

owner visual confirmation が通れば、NARU単体の `overlay_v1` 現段階をCLOSEし、次段候補としてIACメンバー2D可視化（発話者切替 / 役割表示 / Handoff通知 / 状態表示 / 複数メンバー表示）へ進める。
