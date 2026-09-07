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
| `demo_naru_overlay.py` | ローカルスモークテスト用スクリプト（オフライン一括MP4書き出し専用、`renderer.start()`は意図的に呼ばない。理由はファイル内コメント参照）。OpenAI/ElevenLabs/TikTokLiveをimportしていないことをコード内assertで自己検証する |
| `test_overlay_start_stop.py` | `renderer.start()`が実際に描画スレッドを起動し`compose_frame()`を周期的に呼び続けること、`stop()`で確実に停止することを検証するテスト |

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

## `start()`/`stop()`が空実装だった不具合の修正（2026-09-02、黒瀬レビュー指摘反映）

### 指摘内容

`NaruOverlayEngine.start()`/`stop()`が`pass`のみで、`compose_frame()`を周期的に呼んで画面へ出す描画駆動ループがどこにも存在しなかった。エラーは出ず`RendererIsolationProxy.is_offline`もFalseのままだが、実配信で`NARU_RENDERER=overlay_v1`にしても実際には何も表示されない状態だった。`demo_naru_overlay.py`が`renderer._engine`へ直接アクセスしてフレームを取得していたのは、この未実装を回避していた結果だった。

### 修正

`avatar_engine.AvatarEngine._run_cv2`と同じ構成（`WINDOW_TITLE`/`FPS`は`avatar_engine`からimportして共有し、OBS側のウィンドウキャプチャ設定を変えずに済むようにした）で、`start()`が実際にOpenCVウィンドウ描画スレッドを起動するよう実装した。`stop()`はスレッドを`join()`して確実に停止する。

`demo_naru_overlay.py`は元々`renderer._engine`を直接叩いてMP4へ一括書き出す設計だったため、`renderer.start()`（今回から実体を持つライブ表示スレッド）と併用すると同一エンジンへ二重に`compose_frame()`が走る競合状態になる。そのため`demo_naru_overlay.py`からは`renderer.start()`/`stop()`の呼び出しを外し、意図的にオフライン一括書き出し専用スクリプトとして位置づけを明記した（コード内コメント参照）。

### 検証

`test_overlay_start_stop.py`で、`renderer.start()`後に`compose_frame()`が実際に周期的（実測: 約1.8秒間で47回、目標30fpsに近い実測値）に呼ばれ続けること、`renderer.stop()`後はスレッドが確実に停止し呼び出しが増えないことを確認した。

## 口元3点の修正（2026-09-07、オーナー目視指摘反映）

ケイの目視確認で、発話時の口元について次3点の指摘があった：(A)色差、(B)座標ずれに見える、(C)線のシャープさ不足。詳細な原因分析・修正内容・acceptance criteria確認結果は以下のHandoffを参照：

`IACPROJECT/inbox/from_claude_code/2026-09-07_SATO_TO_ARC_NARU_OWNER_VISUAL_FIX_RESULT.md`

要点：
- `MOUTH_CROP`を実差分ベースの実測値へ縮小（180×250px → 135×214px）
- `_match_and_sharpen()`新設：light/medium/wideをclosed基準にLAB色空間で色統計を一致させ、軽いアンシャープマスクを適用（初期化時に1回のみ計算）
- `_blend_mouth_crop()`のクロスフェード係数をシグモイドで急峻化し、遷移中の二重像区間を短縮
- `test_mouth_blink_concurrency_smoke2.py`相当の回帰確認で、blink/hair/speaking pathへの影響なしを確認済み

## Mouth composite 根本rework（2026-09-07、オーナーREJECT反映）

上記の局所polish（色補正+タイトクロップ+sigmoid遷移）では、発話時に鼻先〜人中まで形が潰れる／口が二重に見える、というオーナー目視REJECTが出た。原因はクロップが矩形である限り解消できない構造的な問題と判明。詳細は以下のHandoffを参照：

`IACPROJECT/inbox/from_claude_code/2026-09-07_SATO_TO_ARC_NARU_OWNER_MOUTH_COMPOSITE_REWORK_RESULT.md`

要点：
- `MOUTH_CROP`（矩形）を廃止し、`MOUTH_REGION`という「これより外は絶対に変更しない」ハード境界に変更。上端をグリッド目視で実測した鼻孔(y≈685)・人中(y≈700-710)より確実に下(y=715)へ固定
- `_build_mouth_alpha()`新設：矩形全体を均一に混ぜるのではなく、各状態とclosedとの実差分から口の形そのものに沿ったソフトアルファマスクを生成。差が無い画素（鼻・頬等）はアルファ0のまま
- 検証：`MOUTH_REGION`より上（鼻を含む領域）の画素は、全ての発話レベル(0.0〜0.95)で**diff=0（数学的に完全不変）**であることを実測確認
- 既存のImagine元動画（`resource/Noll_kinohanoyouni.mp4`等、4/12時点の既存ローカル素材）を発見し、品質基準として参照（全体が動く生成動画のため直接の抽出元には使わず、今回は視覚的な基準として利用）
