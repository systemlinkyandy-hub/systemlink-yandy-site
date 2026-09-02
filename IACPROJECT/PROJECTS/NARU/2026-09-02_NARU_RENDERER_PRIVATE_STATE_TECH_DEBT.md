# NARU Renderer private-state access tech debt

- Owner: アーク（追跡） / 佐藤（実装修正候補）
- Review: 黒瀬
- Date: 2026-09-02 JST
- Priority: NONBLOCKING
- Related Task: `NARU-RENDERER-SWAP-2026-08-31-01`

## Finding

`LegacyFrameRenderer.get_mouth_level()` が wrapped engine の private属性へ直接アクセスしている。

```python
with self._engine._lock:
    return self._engine._mouth_level
```

依存:
- `_lock`
- `_mouth_level`

## Why it matters

`LegacyFrameRenderer(engine_class=...)` により `AvatarEngine` 以外の差し替え可能クラスを受けられるようになったため、公開APIだけでなく上記private属性まで暗黙契約になる。

現時点では `AvatarEngine` / `SmoothFrameRenderer` 等の既存経路で成立しており、2026-09-02のshared renderer targeted reviewにおける非回帰判定を妨げるものではない。

## Classification

- current blocker: NO
- regression evidence: NONE CONFIRMED
- formal adoption blocker for overlay_v1: NO
- future maintainability debt: YES

## Suggested future fix

以下のどちらかへ寄せる。

1. engine側に公開 `get_mouth_level()` を定義し、adapterはその公開APIのみ利用する
2. debug/test専用観測をRenderer interface側へ明示し、private属性依存をadapter内部から除く

実装修正時は `legacy` / `legacy_smooth` / `overlay_v1` の非回帰テストを同時に行う。

## Routing rule

このtech debtのために現在のNARU overlay_v1採用判断ゲートを止めない。
他のhardening修正とまとめられる時に佐藤へ渡す。
ケイへ対応・確認を戻さない。
