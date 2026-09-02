# NARU overlay_v1 — review artifacts

黒瀬（Claude）独立レビュー用の一次コード証拠。

対応Handoff:
- `IACPROJECT/inbox/from_claude_code/2026-09-01_SATO_TO_ARC_NARU_OVERLAY_ROUTE_V1_SMOKETEST_RESULT.md`
- `IACPROJECT/inbox/from_arc/2026-09-02_ARC_TO_SATO_NARU_OVERLAY_V1_EVIDENCE_AND_BLINK_POLISH.md`（commit `792a1336bc87ac2b9791e86ba8952a82f24b42e0`）

## 境界

これは **Cubism Native `.moc3` 完成モデルではない**。既存 `renderer.py` のRenderer抽象化に乗る、crop+feather合成ベースの技術試作（v1実装候補）。詳細な位置づけは対応Handoff・および`IACPROJECT/inbox/from_arc/2026-09-01_ARC_TO_KUROSE_NARU_OVERLAY_V1_INDEPENDENT_REVIEW_REQUEST.md`を参照。

## ファイル

| ファイル | 内容 |
|---|---|
| `naru_overlay_engine.py` | 新規。`NaruOverlayEngine`。FACE基底 + MOUTH4状態クロスフェード + 幾何学的blink近似 + HAIR_FRONT独立オーバーレイを合成する |
| `renderer.py` | `overlay_v1` / `naru_overlay` 分岐を追加した現行版全文（`renderer.diff`参照） |
| `renderer.diff` | 直前の一次証拠（`2026-09-01-interim-preview/renderer.py`）との差分。**追加は`create_renderer()`内の新規分岐1箇所のみ**で、既存`legacy`/`legacy_smooth`/`live2d`の分岐・デフォルト動作・`LegacyFrameRenderer`本体は無変更であることが確認できる |
| `demo_naru_overlay.py` | ローカルスモークテスト用スクリプト。`renderer.py`経由で`NaruOverlayEngine`を駆動し、MP4+静止画をローカル出力する。OpenAI/ElevenLabs/TikTokLiveをimportしていないことをコード内assertで自己検証する |

## blink polish（今回の変更点）

`naru_overlay_engine.py`内、`_squash_eye_crop()` と `_build_eye_mask()` に、前回smoketest報告時点から以下の修正を加えた：

1. **モアレ状のにじみの原因特定**：目クロップ全体を覆う単一の大きな楕円マスクだと、髪が密集する周辺領域までフェザー帯に含んでしまい、「圧縮後の画像」と「原画」（どちらも斜め方向の細い毛束線画を持つ）を部分アルファで重ねた際に干渉縞（モアレ）が出ていたと判明
   - 検証のためアンシャープマスクで線を強調してみたところ悪化したため、単純なぼけではなく干渉縞であると特定できた（試行錯誤の記録として残す）
2. **修正**：目クロップ全体を覆う1つの大楕円ではなく、**片目ずつの小さい楕円2つ**（`EYE_LOCAL_CENTERS`、目視でグリッド確認して座標決定）へマスクを変更。毛束が密集する領域をフェザー帯の外に置くことで、干渉縞の発生条件そのものを減らした
3. 縮小前に軽いガウスぼかし（σ=1.4）を`src`へかけてから`INTER_AREA`縮小することで、縮小そのものに起因する高周波エイリアシングも別途抑制

## 非回帰確認（ローカル、目視）

`demo_naru_overlay.py`実行後、以下を目視確認済み（レビュー時の参考であり、コード自体が一次証拠）：

- rest（安静時）: 変化なし
- blink closing序盤: 目立った変化なし、自然に閉じ始める
- blink held（ほぼ閉じ切った状態）: 二重像・縞・境界ポップなし。目周辺のみ柔らかいぼけがあるが、閉じかけた目として妥当な範囲
- mouth open最大時: 既存の口クロスフェードに影響なし
- HAIR_FRONT揺れ最大時: 既存の房オーバーレイに影響なし（今回の変更は目マスクのみ）

`.env` / APIキーはハードコードなし（grep確認済み）。ローカル絶対パス（`C:\...`）も含まれていない（相対パスのみ使用）。
