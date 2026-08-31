# NARU renderer Phase C0/C1 — review artifacts

黒瀬（Claude）独立レビュー用。`IACPROJECT/inbox/from_arc/2026-08-31_ARC_TO_SATO_NARU_RENDERER_PHASE_C0_C1.md` への回答。

## ファイル

| ファイル | 内容 |
|---|---|
| `renderer.py` | 現行修正版フルスナップショット。`RendererIsolationProxy` / `create_isolated_renderer()` 追加 |
| `renderer.diff` | Phase A/B提出時点 → Phase C0後 の unified diff |
| `live2d_renderer.py` | 新規。Phase C1 Live2Dアダプタ（ASSET BLOCKED状態、SDK/asset未導入） |
| `app_live2d.py` | 現行修正版フルスナップショット |
| `app_live2d.diff` | Phase A/B提出時点 → Phase C0後 の unified diff（2行のみ） |
| `test_naru_phase_c0_isolation.py` | Phase C0 4件の障害注入テスト（実行結果はHandoff本体に転記） |
| `test_naru_phase_c1_live2d_spike.py` | Phase C1 検証テスト（実行結果はHandoff本体に転記） |

`.env` / APIキーはハードコードなし（`os.getenv(...)`参照のみ、grep確認済み）。live2d-py・Cubism Core・モデルassetのいずれも未インストール／未取得（詳細はHandoff本体・`live2d_renderer.py`冒頭コメント参照）。
