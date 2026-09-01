# Arc → Kurose: NARU shared renderer targeted review

- From: アーク
- To: 黒瀬（Claude）
- Cc: 欠月, 佐藤（Claude Code）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-01 JST
- Purpose: overlay_v1 review blocker resolution
- Scope: **TARGETED ONLY**

## Background

黒瀬のoverlay_v1レビュー（ケイ経由二次証拠）では、`LegacyFrameRenderer(engine_class=...)` が共有クラス変更である点を未確認の主要懸念として `EVIDENCE INSUFFICIENT` 判定となった。

調査したところ、この変更はoverlay_v1で新規導入されたものではなく、既存のinterim-preview時点でGitHubへ実コードとdiffが保存されている。

## Review artifacts

1. `IACPROJECT/PROJECTS/NARU/review_artifacts/2026-09-01-interim-preview/renderer.diff`
2. `IACPROJECT/PROJECTS/NARU/review_artifacts/2026-09-01-interim-preview/renderer.py`
3. 比較元として必要なら：`IACPROJECT/PROJECTS/NARU/review_artifacts/2026-08-31-phase-c/renderer.py`

## Exact question

`LegacyFrameRenderer.__init__` の

- 旧：引数なしで `AvatarEngine()` を直接生成
- 新：`engine_class=None`、未指定なら従来通り `AvatarEngine` を選択して生成

という変更が、既存 `legacy` 経路の非回帰を保っているかを確認してほしい。

特に：

- `create_renderer("legacy") -> LegacyFrameRenderer()` が従来通り `AvatarEngine` を生成するか
- `engine_class` 注入によって既存 `legacy` の start/stop/set_volume/set_speaking/get_mouth_level 契約が変わっていないか
- `legacy_smooth` の追加が未選択時の既定経路へ影響しないか

## Out of scope

今回は旧 `interim native preview` 全体の視覚品質レビューを求めない。
`smooth_frame_renderer.py` の口パク品質やidle swayの採否も、このターンでは不要。

目的はoverlay_v1の現行レビューを止めている**共有renderer変更の一点確認**だけ。

## Requested verdict

- `SHARED_RENDERER_CHANGE_OK`
- `SHARED_RENDERER_CHANGE_NEEDS_FIX`
- `EVIDENCE STILL INSUFFICIENT`

必要なら最小修正だけ提示してほしい。

黒瀬の一次返却後、アークがoverlay_v1レビュー状態へ反映する。正式採用判断は欠月へ返す。
