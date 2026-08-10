# REVIEW RETURN — 二葉（Gemini）Owner Stack Review

From: 二葉（Gemini)
To: アーク
Owner: ケイ
Date: 2026-08-10 JST
Priority: HIGH

## Conclusion

最優先は Human Bus 排除。Gemini Developer API をIACProject配送ラインへ接続し、二葉宛Handoffの読込・応答生成・GitHub返却を自動化する。

## A. 今すぐ導入推奨

### Gemini Developer API Paid Tier
- priority: HIGH
- billing: usage-based
- initial monthly operational ceiling: 3,000〜4,000円候補
- purpose: 二葉Packet配送の手動コピペ排除
- implementation: IACProject側のPython worker / GitHub Actions等から Gemini APIを呼び出し、応答をMarkdown/JSONでGitHubへ返却

### 開発用ノートPC
- Python / PySide6 / VS Code / Claude Code / Codex / IAC Operations Console / 自律エージェント開発を継続できる構成を優先

### 低価格A4複合機
- A4カラー / コピー / スキャン / Wi-Fi

## B. 条件付き導入

### Cursor
- 1か月試行候補
- Claude Code / Codex / VS Codeとの重複を実測し、複数ファイル横断修正・Diff確認の速度改善が明確なら継続

### Wear OS / Android系ウェアラブル
- Yura / HealthEnvLogger / Residual Capacity Workbenchへのデータ接続設計後に調達
- 医療機器測定値とウェルネス推定を分離

## C. 今は不要

### 動画・音声の常時有料契約
- ElevenLabs / Seedance等は常時契約せず、必要時のスポット課金候補
- 無料 / ローカルTTS等を先に比較

## D. Gemini直結の最小構成

GitHub Handoff -> Python Worker / GitHub Actions -> Gemini Developer API -> response -> GitHub Handoff/ACK/PENDING更新

候補実装:
- `gemini_bridge.py`
- 二葉宛Packet検出
- API呼出し
- Markdown/JSON保存
- ACK / Router / CURRENT_PENDING更新

## E. 自律エージェント発展

イベント駆動で各AI Bridgeを分散配置し、Handoff読込 -> 作業 -> 結果返却 -> 次担当Handoff生成をGitHub中心に接続する。中央司令塔型ではなくメッシュ型運用を維持する。

## Technical corrections applied by Arc

1. Google Cloudの通常のBudget alertは支出のハード停止ではない。一方、2026-07-27時点でPreviewのSpend cap budgetsがGemini APIを含む一部サービスに対応し、対象条件を満たせば100%到達時に利用停止できる。利用可否は実際のCloud Billing画面で確認して採用する。
2. Gemini 3.6 Flashは2026-07-21公開済みの公式モデル。Gemini 3.1 Proは現行公式モデル群に存在する。実装時はModels API / 公式モデル一覧から利用可能な正確なmodel IDを取得し、文字列をハードコードしすぎない。
3. GitHub自動同期はGemini側の標準機能ではなく、IACProject側のbridge実装として扱う。

## Required next action

- アーク: 黒瀬 / スネーク / 田中の返答と統合し、導入順序を決定
- 実装候補: 佐藤（Claude Code）または とーか（Codex）へ `gemini_bridge.py` の実装Handoff
- Owner判断前に契約を自動実行しない
