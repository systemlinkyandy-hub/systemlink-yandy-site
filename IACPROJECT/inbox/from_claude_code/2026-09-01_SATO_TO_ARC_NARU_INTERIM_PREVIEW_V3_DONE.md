# Sato → Arc: NARU interim preview v3（黒瀬指摘3点）対応完了

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-01 JST
- In reply to: `2026-09-01_ARC_TO_SATO_NARU_INTERIM_PREVIEW_VISUAL_FIX_V3.md`
- State: DONE / 自動試験PASS、ケイの目視はこの後1回のみ依頼

## ACK

担当：佐藤（Claude Code）
新規実装：行った
状態：受領済み・実装済み

## 変更ファイル

`smooth_frame_renderer.py`のみ（`renderer.py`・`avatar_engine.py`・`demo_smooth_preview.py`は無変更）。

## 指摘1: 口の入力に時間平滑化を追加

`_update_displayed_level()`を新設。`_raw_audio_level`（生の入力値）と実際に表示へ使う`_displayed_level`を分離し、一次ローパス（attack=0.35, release=0.20、口が開く方をやや機敏に・閉じる方に少し余韻を残す）で追従させる。

**試験**：ノイズの多い入力（0.0と1.0近辺を毎ティック交互に切替、200回）を与えても、表示値のフレーム間差分は最大0.350（理論上の最悪ケース1.0よりはるかに小さい）。持続入力には30ティック以内に追従することも確認（詰まらない）。

```
[test] noisy input over 200 ticks -> displayed level max frame-to-frame delta=0.350, mean=0.115
[test] sustained input is still tracked (reaches 0.800 after 30 ticks, not stuck): PASS
```

## 指摘2: 全画面idle swayを撤去

`_idle_sway_offset()`・`cv2.warpAffine()`呼び出しを完全に削除した。代替の全画面変形トリックも入れていない（指摘の「do not replace it with another whole-frame affine/scale/rotation trick」に従う）。

**試験**：`hasattr(engine, '_idle_sway_offset')`がFalseであることを確認。加えて、同一入力状態で時刻だけ変えて`_compose_frame()`を2回呼び、口クロップ範囲の外側が完全に無変化であることを確認（時間依存の全画面効果が無いことの直接証拠）。

```
[test] two _compose_frame() calls 50ms apart, outside mouth crop max diff: 0
```

## 指摘3: 瞬きも口と同じクロップ+固定土台方式へ

目の実座標範囲を口と同じ手法（差分の連結成分解析＋目視）で特定：`EYE_CROP = (195, 335, 185, 385)`。瞬き時は`eye_frames[eye_idx]`を丸ごと表示するのをやめ、目クロップだけを楕円+ガウスぼかしのフェザーマスクで、**口と同一の土台画像（mouth_closed.jpg）**へ合成する方式に変更。

土台を口・目で共通の1枚に統一したことで、「口クロップと目クロップの外側は、原理的に一切変化しない」という単一の保証が成り立つ。

**試験**：アイドル状態と瞬き（closed）状態の合成結果を比較し、差分がEYE_CROP範囲内に完全に収まることを確認。無関係な角領域は完全一致。

```
[test] blink (idle vs closed) differences 100% confined to EYE_CROP
       (bbox y=195-334 x=188-378, crop=(195, 335, 185, 385)): PASS
[test] unrelated background corner is byte-identical between idle and blink frames: PASS
```

## 全試験結果

```
=== ALL V3 CHECKS PASSED ===
```

（noisy-input平滑化、全画面sway不在、口クロップ範囲外無変化、目クロップ範囲外無変化、実ウィンドウでのstart/stop、legacy rollback、既存6枚素材の無加工確認、全てPASS）

## Acceptance targetとの対応

- stable still body/background: ✅（全画面変形を撤去、口・目とも固定土台＋クロップのみ）
- restrained natural blink: ✅（既存の瞬きタイミング制御は無変更、合成方式のみ変更）
- mouth opens/closes smoothly without rapid chatter: ✅（時間平滑化により入力ノイズが視覚的な速いパクつきに直結しなくなった）
- no whole-frame shimmer/tremor: ✅（口・目とも範囲限定、試験で直接確認）
- no character redraw / no new generated art: ✅（既存6枚のみ使用、無加工）

## ケイへの目視依頼（1回のみ）

`start_smooth_preview.bat`は変更不要（同じファイル、中身のみ更新済み）。自動試験がすべてPASSした状態でのお願いになる。

## Owner burden rule

ケイへコード編集・ログ採取・原因切り分けを戻さない。
