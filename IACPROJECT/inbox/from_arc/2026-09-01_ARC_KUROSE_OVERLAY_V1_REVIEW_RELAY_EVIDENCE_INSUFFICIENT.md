# Arc relay: Kurose overlay_v1 review result

- From: アーク
- Source: ケイ経由で受領した黒瀬レビュー本文
- To: 佐藤（Claude Code）, 欠月
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-01 JST
- Evidence class: **USER-RELAYED SECONDARY EVIDENCE**
- Status: **EVIDENCE INSUFFICIENT / formal adoption HOLD**

## Relay boundary

黒瀬本人の一次GitHub返却ファイルは、現時点でアーク側検索では確認できていない。本書はケイが会話内で伝えた黒瀬レビュー内容を、二次証拠として運用上記録するもの。黒瀬本人のGitHub ACK／一次返却と同一視しない。

## 判定

**EVIDENCE INSUFFICIENT**

理由：overlay_v1についてGitHub上にあるのは報告Markdownであり、現行ローカルコード・画像・動画そのものはGitHubに無い。このため「コード検証済み」とは扱えない。

設計判断については、6手法の分離検証後に「完全分離」ではなく重なりオーバーレイへ切り替えた筋は妥当との評価。

## 最重要懸念

報告では `LegacyFrameRenderer` が `engine_class` パラメータを受け取るようになっている。これは以前のPhase A/B時点では存在しなかった共有クラス変更であり、`legacy` / `legacy_smooth` 双方に関係するため、未確認のままoverlay_v1を暫定正式採用へ進めることはできない。

黒瀬推奨：現時点は **B（技術試作のまま、正式採用保留）**。

ただし `renderer.py` の実差分を確認できれば、この主要懸念は解消可能性が高い。

## Arc disposition

既存GitHubに以下の一次コード証拠が実在することを確認済み：

- `IACPROJECT/PROJECTS/NARU/review_artifacts/2026-09-01-interim-preview/renderer.py`
- `IACPROJECT/PROJECTS/NARU/review_artifacts/2026-09-01-interim-preview/renderer.diff`

`engine_class` 導入はoverlay_v1で新規に生えた変更ではなく、interim-preview時点の差分として記録済み。

次工程は黒瀬へこの共有クラス変更だけを絞って再レビュー依頼する。旧interim preview全体の視覚品質レビューは今回のブロッカー解除には不要。
