# NARU renderer swap — review artifacts (2026-08-31)

黒瀬（Claude）独立レビュー用。`IACPROJECT/inbox/from_arc/2026-08-31_ARC_TO_SATO_NARU_RENDERER_SWAP_IMPLEMENTATION.md` への回答。

## ファイル

| ファイル | 内容 |
|---|---|
| `renderer.py` | 新規。Renderer interface + LegacyFrameRenderer(AvatarEngineアダプタ) + create_renderer() factory |
| `avatar_engine.py` | 現行修正版フルスナップショット（ヒステリシス化・瞬きジッター追加） |
| `avatar_engine.diff` | 前夜（2026-08-30 review artifacts提出時点）→ 今回の unified diff |
| `app_live2d.py` | 現行修正版フルスナップショット |
| `app_live2d.diff` | 前夜提出版 → 今回の unified diff（renderer factory経由の起動に変更、2箇所のみ） |
| `test_naru_renderer_swap.py` | 実行した検証テストそのもの（実課金API・TikTok接続なし） |

## 秘匿情報

`.env` / APIキーは含まない（grep確認済み）。

## Review focus への対応マップ

`IACPROJECT/PROJECTS/NARU/2026-08-31_NARU_RENDERER_SWAP_PLAN.md` の要求評価に対応:

- **Renderer boundary**: `renderer.py` の `Renderer` 抽象クラス（`start/stop/set_audio_level/set_expression/set_motion`）
- **legacy renderer即時ロールバック**: `avatar_engine.py` 自体は公開API（`start/stop/set_volume/set_speaking`）を変更していない。`renderer.py` は追加ファイルのみで、`app_live2d.py` の変更は2箇所（import 1行 + instantiation 1行）のみ。`NARU_RENDERER`環境変数は未設定時 `legacy` が既定
- **口パク改善**: `avatar_engine.py` の `set_volume()` をヒステリシス付き状態機械へ変更（`avatar_engine.diff` 参照）。実測: 同一の音量オシレーション列に対し旧単一閾値ロジックが30回状態遷移するところ、新ロジックは2回（`test_naru_renderer_swap.py` 実行結果参照）
- **瞬きの機械的さ軽減**: `BLINK_FRAME_DURATION` を固定値からランダム範囲(0.055〜0.085秒)へ変更。瞬きの間隔自体は元々ランダムだった（誤解の可能性を報告書に明記）
- **synthetic display test**: 実施済み、実課金API・TikTok接続なし。実際の「Noll Live」ウィンドウを起動し、synthetic audio levelで口パク遷移を確認後クローズ
- **Live2D/VRM比較**: 報告書（Handoffファイル本体）参照
