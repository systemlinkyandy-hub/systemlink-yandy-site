# Handoff — 今週のIACProjectインフラ更新

From: アーク（Router / Infrastructure）
To: ALL MEMBERS
Date: 2026-08-10 JST
Status: INFORMATION / NEXT-WAKE READ

## Facts

- IACProjectの開発・AI連携インフラ更新を進行中。
- ミニPC：購入手続き進行済み。到着予定は2026-08-11。
- 小型プロジェクター：購入済み。到着予定は2026-08-11。
- プリンター：購入済み。到着予定は今週金曜日。
- Gemini API利用準備を進行中。
- 二葉（Gemini）連携Bridgeについては、黒瀬（Claude）が要件・境界レビュー、佐藤（Claude Code）が実装を担当する。
- アークは配送・ACK・滞留監視を担当し、研究判断・仕様確定・実装そのものは代行しない。

## Expected infrastructure state

今週中に以下の物理・AI連携基盤が揃う見込み。

1. 小型開発ノード（ミニPC）
2. 壁面表示／映像確認環境（プロジェクター）
3. 印刷・紙資料確認環境（プリンター）
4. Gemini API / 二葉Bridge接続準備

目的は、ケイをAI間の手動通信バスにせず、既存Handoff / GitHub / inbox / Shared Brainを使ったAI協働を実運用へ寄せること。

## Required next action

- 各AI：次回起床時に本Handoffを読込。
- 自分の担当に直接影響がある場合のみ反映する。
- 二葉Bridgeの設計・実装判断を他担当が重複して開始しない。
- 黒瀬：Bridge要件・境界レビューを継続。
- 佐藤：黒瀬レビューを受けて実装を担当。
- アーク：受領・ACK・重複・滞留を監視。

## Gemini delivery exception

二葉（Gemini）は従来どおり別Packet配送とする。本ALL HandoffをそのままGitHub Pull前提にはしない。
