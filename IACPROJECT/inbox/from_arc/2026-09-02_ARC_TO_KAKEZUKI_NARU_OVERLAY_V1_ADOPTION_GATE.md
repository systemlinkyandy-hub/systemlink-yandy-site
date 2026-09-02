# Arc → 欠月: NARU overlay_v1 採用判断ゲート

> **2026-09-02 ROUTING CORRECTION — CANCELLED / NO ACTION**  
> ケイの明示指示により、**欠月はNARU案件から外す**。本Handoffは履歴保持のみとし、欠月への判断依頼・ACK追跡・採否待ちはすべて取消す。今後のNARU進行は **佐藤（実装）／黒瀬（独立レビュー）／アーク（Router）** で扱う。欠月へNARUの仕様確定・採用判断を再Routingしない。

- From: アーク
- To: 欠月
- Cc: 黒瀬（Claude）, 佐藤（Claude Code）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-02 JST
- State: **CANCELLED / NO ACTION — SUPERSEDED BY USER ROUTING DECISION**

## 結論

NARU `overlay_v1` について、主要な共有Renderer回帰懸念は解消済みとして、正式な採否判断を欠月へ返す。

ただし、この判断対象は **Cubism Native `.moc3` 完成モデルではない**。
`overlay_v1` は canonical NARU画像を保持したまま、前髪・口・瞬きを独立オーバーレイとして動かす技術試作／暫定runtime経路である。

## 一次確認済み事実

### 1. 佐藤実装・ローカルsmoke
Source:
`IACPROJECT/inbox/from_claude_code/2026-09-01_SATO_TO_ARC_NARU_OVERLAY_ROUTE_V1_SMOKETEST_RESULT.md`
Commit: `92565f6aba9a0bdeeabfa1b693f3430d0245205e`

報告内容:
- canonical base保持
- HAIR_FRONT overlay
- mouth 4-state continuous blend
- blink approximation
- `renderer.py` factory接続
- 10秒 / 300frame / 30fps ローカルsmoke完了
- 既存 `legacy` / `legacy_smooth` / `live2d` の既定経路は変更しない設計

### 2. 共有Rendererコード証拠
一次コード:
- `IACPROJECT/PROJECTS/NARU/review_artifacts/2026-09-01-interim-preview/renderer.py`
- `IACPROJECT/PROJECTS/NARU/review_artifacts/2026-09-01-interim-preview/renderer.diff`

確認事項:
- `LegacyFrameRenderer.__init__()` は `engine_class=None` を追加したのみ
- `engine_class is None` の場合は従来どおり `AvatarEngine`
- `create_renderer("legacy")` は従来どおり `LegacyFrameRenderer()`
- `legacy_smooth` は別分岐
- start / stop / set_volume / set_speaking / get_mouth_level の本体ロジックは当該差分で変更なし

## 黒瀬レビュー状態

### 先行overlay_v1レビュー
ケイ経由secondary evidence:
`EVIDENCE INSUFFICIENT`

理由:
- 当時、overlay_v1のローカル実装コード・画像・動画がGitHub一次証拠として存在せず、コード検証済みとは言えなかった
- 最大懸念は共有 `LegacyFrameRenderer(engine_class=...)` 変更の非回帰

### targeted shared renderer review
ケイ経由secondary evidence（2026-09-02）:
`SHARED_RENDERER_CHANGE_OK`

黒瀬報告要点:
- phase-c版とinterim-preview版の `renderer.py` を独自再diff
- 提供diffと一致
- shared class変更は `__init__` のdependency injection追加のみ
- `legacy` は `engine_class=None` → `AvatarEngine` で非回帰
- `legacy_smooth` 分岐はlegacy到達条件に影響なし
- overlay_v1の主要懸念は直接的に解消

注意:
- 黒瀬自身がcommitした一次レビューMarkdownは、Arcのremote検索では本Handoff作成時点で未確認
- よって verdict文字列はsecondary evidenceとして記録し、一次コード証拠はArcが独立確認した

## 非blocking技術負債

`LegacyFrameRenderer.get_mouth_level()` が以下のengine private属性へ直接依存している:
- `_lock`
- `_mouth_level`

これは今回のshared renderer非回帰判定を妨げない。
ただし `engine_class` 差し替え候補が増えるほど暗黙契約になるため、別tech-debtとして追跡する。

## 旧・欠月へ返す判断（取消済み）

以下は**現在はNO ACTION**。欠月へ判断を求めない。

1. `overlay_v1` を **NARU暫定visual/runtime route** として採用するか
2. それとも **技術試作のまま保留** とするか
3. 採用する場合も、Cubism Native `.moc3` 化は別工程・別ゲートとするか

## 現行Routing

- 佐藤：NARU実装
- 黒瀬：独立レビュー
- アーク：Router / ACK / 状態整理
- 欠月：**NARU案件から除外。NO ACTION**

## Owner burden rule

ケイへコード差分確認、レビュー回収、再説明、素材探索、進捗監視を戻さない。
