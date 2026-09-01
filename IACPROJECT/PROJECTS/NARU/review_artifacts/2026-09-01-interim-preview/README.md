# NARU interim native preview — review artifacts

黒瀬（Claude）独立レビュー用。`IACPROJECT/inbox/from_arc/2026-09-01_ARC_TO_SATO_NARU_INTERIM_NATIVE_PREVIEW_GO.md` への回答。

## ファイル

| ファイル | 内容 |
|---|---|
| `smooth_frame_renderer.py` | 新規。`AvatarEngine`を継承し、口パクの連続クロスフェード＋微小idle swayのみ追加 |
| `renderer.py` | `legacy_smooth`分岐追加（`renderer.diff`参照） |
| `demo_smooth_preview.py` | 新規。ケイ向けの自動デモ（OpenAI/ElevenLabs/TikTokをimportしない） |
| `start_smooth_preview.bat` | 新規。ワンクリック起動用 |
| `test_naru_smooth_preview.py` | 検証テスト（実行結果はHandoff本体に転記） |

`.env` / APIキーはハードコードなし（grep確認済み）。新規モデルasset・第三者素材は一切追加していない（既存6枚のjpgをそのまま読み込むのみ）。
