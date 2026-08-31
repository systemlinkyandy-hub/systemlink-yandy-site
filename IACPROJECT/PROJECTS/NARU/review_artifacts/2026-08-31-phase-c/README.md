# NARU renderer Phase C0/C1 — review artifacts

黒瀬（Claude）独立レビュー用。`IACPROJECT/inbox/from_arc/2026-08-31_ARC_TO_SATO_NARU_RENDERER_PHASE_C0_C1.md` への回答。

## ファイル

| ファイル | 内容 |
|---|---|
| `renderer.py` | 現行修正版フルスナップショット。`RendererIsolationProxy` / `create_isolated_renderer()` 追加 |
| `renderer.diff` | Phase A/B提出時点 → Phase C0後 の unified diff |
| `live2d_renderer.py` | Phase C1 Live2Dアダプタ。**実描画まで到達**（GLFW+OpenGLウィンドウ、Haruサンプルモデル駆動） |
| `app_live2d.py` | 現行修正版フルスナップショット |
| `app_live2d.diff` | Phase A/B提出時点 → Phase C0後 の unified diff（2行のみ） |
| `test_naru_phase_c0_isolation.py` | Phase C0 4件の障害注入テスト（実行結果はHandoff本体に転記） |
| `test_naru_phase_c1_live2d_spike.py` | Phase C1 検証テスト（SDK未導入時点のもの、履歴として残す） |
| `test_naru_live2d_sdk_verify.py` | live2d-py導入直後のSDK単体検証（モデル不要） |
| `test_naru_phase_c1_real_render.py` | **Haruモデルでの実描画・障害注入・legacy復帰テスト**（最新） |

`.env` / APIキーはハードコードなし（`os.getenv(...)`参照のみ、grep確認済み）。

**モデルassetはここに含まれていない。** `live2d_assets/Haru/`（Live2D公式サンプル、Free Material License、ケイが公式サイトで同意の上取得）はローカル(`C:\Projects\vtuber_ai\live2d_assets\Haru\`)にのみ存在し、GitHubへは意図的に同梱していない（Handoff指示「third-party licensed binaries/assets を含めない」に従う）。出所・利用条件はローカルの`live2d_assets\Haru\ATTRIBUTION.md`、および最新Handoffに記録。
