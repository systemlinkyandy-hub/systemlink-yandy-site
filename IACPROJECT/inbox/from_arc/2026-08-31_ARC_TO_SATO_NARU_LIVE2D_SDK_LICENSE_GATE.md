# Handoff: NARU Phase C1 — Live2D SDK / Core 導入ゲート

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）, 欠月
- Date: 2026-08-31 JST
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- State: PUSH CURRENT WORK / SDK INSTALL HOLD UNTIL HUMAN LICENSE CONSENT

## Decision

1. ローカルcommit `d503281` は push してよい。
   - Phase C0 isolation proxy / failure-injection tests
   - Phase C1 adapter / mapping spike / reports
   - `live2d-py`, Cubism Core, model assets は未導入
   - third-party licensed binaries/assets を含めない現状の成果物は実装証跡としてGitHubへ登録する。

2. `live2d-py` / Cubism Core の実インストールは自動で進めない。
   - Live2D公式SDK/Coreのダウンロード・起動は使用許諾への同意を伴う。
   - この法的同意はAI側で代行しない。ケイ本人が内容確認・同意するまで HOLD。

3. 同意後も本番環境へ直入れしない。
   - Phase C1 technical spikeとして隔離環境で実施する。
   - 現行legacy rendererのrollback pathを維持する。
   - 黒瀬条件どおり renderer failure を故意に発生させ、LLM/TTS/queueが生存することを再確認する。

## Preflight before install

佐藤はインストール前に、実行のみで以下を返すこと。

- 現行Python version / architecture
- `live2d-py`候補versionと配布元
- Windows対応wheel有無
- Cubism Core取得元はLive2D公式のみ
- 導入予定assetの出所・ライセンス（勝手に第三者モデルを取得しない）
- rollback手順

## Licensing note

Live2D公式情報では、Cubism SDKは試用・開発段階で検証可能だが、SDKダウンロード時に Proprietary Software / Open Software License Agreement への同意が必要。公開段階のライセンス区分はコンテンツ形態により別途確認が必要で、AI/chatbot interfaceやExpandable Applicationに関する案内もある。

したがって、Phase C1の技術検証許可と、将来の公開・配信形態に対する出版許諾判断は分離する。

## Owner burden rule

ケイへ実装・インストール作業・差分編集・ACK回収を戻さない。必要な人間判断は「Live2D使用許諾を確認して技術検証のための導入に同意するか」の一点に圧縮する。
