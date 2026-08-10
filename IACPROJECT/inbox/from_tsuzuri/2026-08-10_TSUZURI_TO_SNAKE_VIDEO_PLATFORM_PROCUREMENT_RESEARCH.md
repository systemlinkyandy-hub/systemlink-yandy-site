# HANDOFF

From: 綴
To: スネーク（Grok）
CC: ケイ、アーク、田中、欠月
Date: 2026-08-10
Task ID: TSUZURI-VIDEO-PLATFORM-PROCUREMENT-001

## Context
ケイ側では、動画制作の手作業・生成回数・サービス間移動を減らしつつ、30〜60秒級の完成度の高い広報／創作動画を作れる制作基盤を検討している。

綴の暫定第一候補は **Runway Proを1か月契約し、制作母艦として使う** こと。
理由：Runway上でGen-4.5、Seedance 2.0、Kling 3.0等の複数モデル、Edit Studio/Aleph 2.0、TTS、アップスケール等を一つの契約・画面にまとめられるため。個別サービスを複数契約するより、ケイの操作負荷を減らせる可能性が高い。

## Research request
以下を2026-08-10時点の最新情報で比較し、事実と推奨を分離して返してほしい。

1. Runway Pro（必要ならStandard/Maxも）
2. Seedance 2.0 直接利用（即夢AI / 豆包 / Volcengine等を含む）
3. Kling AI 直接利用
4. もし上記よりSystemLink YandY用途に明確に優れる候補があれば1件まで追加

## Compare items
- 日本からの契約・利用可否
- 月額 / クレジット / 追加課金
- 生成可能な最大尺
- 画像・動画・音声リファレンス数と使い勝手
- 音声同時生成の有無
- キャラクター一貫性
- video-to-video / edit / extend / keyframe等、作り直しを減らす機能
- 商用利用条件
- ウォーターマーク
- 縦9:16 / 横16:9 / 1080p / 4K対応
- 日本語UI / 日本語プロンプトの実用性
- 30〜60秒動画を作る際の実質的な生成回数
- ケイの操作回数を最小にできるか

## Preliminary facts already found by Tsuzuri
- Runway公式価格ではStandard $15/月、Pro $35/月（年払い時は実質$12/$28）、Pro 2250 credits/月。
- Runway公式価格ページにGen-4.5、Seedance 2.0、Kling 3.0等が掲載されている。
- Runway Edit Studio / Aleph 2.0 は既存動画の編集をプロンプトで行い、最大30秒の単一／複数ショット系列を扱える。
- Seedance 2.0公式は、テキスト・画像・音声・動画入力、最大9画像/3動画/3音声参照、15秒の高品質マルチショット音動画出力を案内している。

## Decision question
**「明日1つだけ契約するならどれか」** を最終行に明記してほしい。

## Guardrail
契約判断はケイ／欠月。スネークは外部調査と比較に限定する。

Copyright: ケイ
