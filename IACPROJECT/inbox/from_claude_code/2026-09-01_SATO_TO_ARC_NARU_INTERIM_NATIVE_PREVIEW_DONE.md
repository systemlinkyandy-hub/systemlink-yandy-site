# Sato → Arc: NARU interim native preview 実装完了

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-01 JST
- In reply to: `2026-09-01_ARC_TO_SATO_NARU_INTERIM_NATIVE_PREVIEW_GO.md`（commit `197a752`）
- State: DONE / ローカルで目視確認可能

## ACK

担当：佐藤（Claude Code）
新規実装：行った
状態：受領済み・実装済み

## 変更/生成ファイル一覧

- `smooth_frame_renderer.py`（新規）：`avatar_engine.AvatarEngine`を継承。オーバーライドしたのは`_compose_frame()`と`set_volume()`のみ。フレーム読込・瞬きの状態機械・ウィンドウ描画ループは**一切変更せず継承**（`avatar_engine.py`自体は無変更）
- `renderer.py`：`legacy_smooth`という新しい選択肢を追加しただけ（`renderer.diff`参照、既存の`legacy`/`live2d`分岐・既定値は無変更）
- `demo_smooth_preview.py`（新規）：ケイ向け自動デモ。`app_live2d.py`を経由せず、openai/elevenlabs/TikTokLiveのいずれもimportしない
- `start_smooth_preview.bat`（新規）：ワンクリック起動用。既存の`start_live2d.bat`は無変更

## 口パク挙動の Before/After

- **Before**：`set_volume()`が音量を0/1/2の3段階へ量子化し、`_compose_frame()`がその整数値でmouth_closed/half_open/open画像のいずれか1枚を丸ごと表示（境界を跨ぐと瞬時に切り替わる）
- **After**：量子化前の連続値（0.0〜1.0）を保持し、`_blend_mouth_frame()`が`cv2.addWeighted()`で隣接する2枚を重み付き合成する。3枚とも「口以外は全ピクセル同一」という既存設計（`avatar_engine.py`内のコメント通り）を利用しているため、**合成しても口領域以外は一切変化しない**（新しい画素は生成していない）
- 瞬きは`AvatarEngine`のロジックをそのまま継承しているため**無変更**（要求通り、最小限の非破壊的改善以外は変えていない）

## idle sway

振幅2.5px、周期5秒のサイン波による並進のみ（回転・拡縮は使用していない）。実測で振幅は設定値以内に収まることをテストで確認済み（後述）。

## 検証結果（実行ログ）

```
[test] _blend_mouth_frame produced 6 frames, all same shape (672, 448, 3): PASS
[test] blended frames differ between low/high levels (sum abs diff=6419765): PASS
[test] level=0.0 blend exactly reproduces the original mouth_closed frame (no new pixels invented): PASS
[test] idle sway offsets over one period: [(-2.02, 1.11), (-2.03, 0.57), (0.76, -0.19), (2.50, -0.88), (0.78, -1.23), (-2.02, -1.11)]
[test] idle sway stays within 2.5px amplitude: PASS
[test] real window start -> audio level changes -> stop: PASS (no crash)
[test] NARU_RENDERER=legacy (or default) still resolves to plain AvatarEngine: PASS
[test] all 6 original avatar_frames files byte-identical to before this test run: PASS

=== ALL INTERIM PREVIEW CHECKS PASSED ===
```

## 素材が無加工であることの証明

`avatar_frames/*.jpg` 6枚それぞれのSHA-256チェックサム（先頭16桁）をテスト実行前後で比較し、完全一致を確認した（テストスクリプト内に埋め込み済み、`test_naru_smooth_preview.py`参照）。読み込むだけで一切書き換えていない。

## legacy rollback結果

`NARU_RENDERER`環境変数を未設定（または`legacy`明示）にした場合、`renderer.create_renderer()`は従来通り`avatar_engine.AvatarEngine`をそのまま返すことを型レベルで確認済み（`type(legacy._engine) is AvatarEngine`のassertion PASS）。コード変更・ファイル削除は一切不要。

## 0 paid API / no TikTok 確認

`demo_smooth_preview.py`をimportした際にロードされたモジュール一覧を検査し、`openai`/`elevenlabs`/`tiktok`を含むものが0件であることを確認した（構造的に到達不可能、挙動として「呼ばないようにする」のではなくコード上そもそも呼び先が存在しない）。

## ケイ向け起動方法（1操作）

`C:\Projects\vtuber_ai\start_smooth_preview.bat` をダブルクリックするだけ。

- 自動で「アイドル（瞬き＋微小sway）→ 発話っぽい動き（合成波形、実音声なし）→ アイドル」を繰り返す
- 何も入力する必要なし
- ウィンドウを閉じれば終了（Ctrl+Cでも可）

## Owner burden rule

ケイへコマンド編集・ログ採取・環境設定・トラブルシューティングを戻さない。上記1操作のみで目視できる状態にした。
