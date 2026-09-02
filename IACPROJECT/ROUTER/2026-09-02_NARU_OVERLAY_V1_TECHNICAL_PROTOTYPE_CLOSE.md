# NARU overlay_v1 technical prototype — close record

- Router: アーク
- Date: 2026-09-02 JST
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- State: `TECHNICAL PROTOTYPE APPROVED / NONBLOCKING ISSUES REMAIN`

## Conclusion

`overlay_v1` は **Cubism Native `.moc3` 完成モデルではない**。
canonical NARU画像を基礎に、mouth / blink / HAIR_FRONT を crop+feather 系で独立駆動する技術試作である。

この技術試作については、blocking issue を解消し、次工程へ進めてよい状態とする。

## Evidence

- primary review artifact package:
  - `IACPROJECT/PROJECTS/NARU/review_artifacts/2026-09-02-overlay-v1/`
  - commit `c98b149674e866fdcede2b02b661fa8afd1727bc`
- start()/stop() render-loop fix:
  - commit `bd0dbf00f54d9308ce1eeb3c4e0ca23f72d3dadd`
- live `renderer.start()` visual-path evidence:
  - `IACPROJECT/inbox/from_claude_code/2026-09-02_SATO_TO_ARC_NARU_OVERLAY_V1_LIVE_PATH_VISUAL_EVIDENCE.md`
  - commit `f7cf5a979169b4c91056a884a9bbc53a189494e2`

## Review state

ケイ経由secondary evidenceとして、黒瀬の総合判定:
`OVERLAY_V1_APPROVE_WITH_NONBLOCKING_ISSUES`

黒瀬source-authored最終Markdownは、このclose record作成時点ではremote未確認。
よって verdict文字列自体はsecondary evidenceとして保持する。

一方、blockingだった描画駆動ループ欠如の修正コードはGitHub一次証拠で確認済み。

## Nonblocking issues

1. blink held時のごく軽いぼけ
2. `LegacyFrameRenderer.get_mouth_level()` の wrapped engine private state (`_lock`, `_mouth_level`) 依存
3. visual evidenceのMP4/still自体はローカルのみで、黒瀬が画像を独立目視したとは扱わない

上記はいずれも技術試作の次工程を止めない。

## Next

次工程は `.moc3` authoring ではなく、既存 `app_live2d.py` の `create_isolated_renderer()` / `NARU_RENDERER` 選択経路を使い、`NARU_RENDERER=overlay_v1` で実アプリ STANDBY smoke を行う。

- コード変更を目的にしない
- TikTok接続を行わない
- 有料API生成を行わない
- startup / renderer selection / window display / clean stop のみ確認
- 問題が出た場合のみ最小修正へ戻す

## Routing boundary

NARU標準ルートは:
佐藤（実装/検証） → 黒瀬（独立レビュー） → アーク（Router）

欠月へはRoutingしない。
ケイへコード確認・進捗監視・再説明を戻さない。
