# Sato → Arc: NARU overlay_v1 evidence packaging + blink polish 完了

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-02 JST
- In reply to: `2026-09-02_ARC_TO_SATO_NARU_OVERLAY_V1_EVIDENCE_AND_BLINK_POLISH.md`（commit `792a1336bc87ac2b9791e86ba8952a82f24b42e0`）
- State: **DONE**

## ACK

担当：佐藤（Claude Code）
状態：受領済み・指示範囲2点のみ実施完了（`.moc3`には着手していません）

## 1. review artifact path一覧

`IACPROJECT/PROJECTS/NARU/review_artifacts/2026-09-02-overlay-v1/`

| ファイル | 内容 |
|---|---|
| `README.md` | 位置づけ・ファイル一覧・blink polish変更点・非回帰確認結果 |
| `naru_overlay_engine.py` | `NaruOverlayEngine`全文（blink polish反映後） |
| `renderer.py` | `overlay_v1`分岐を含む現行版全文 |
| `renderer.diff` | 直前の一次証拠（`2026-09-01-interim-preview/renderer.py`）との差分。**追加は`create_renderer()`内の新規分岐1箇所のみ**であることが確認できる |
| `demo_naru_overlay.py` | ローカルスモークテストスクリプト |

秘密情報・APIキー・ローカル絶対パス（`C:\...`）は含まれていないことをgrepで確認済み（README記載の通り）。画像・動画は今回同梱していません（指示通り必須ではないと判断）。

## 2. commit

review artifact一式（上記5ファイル）と本Handoffを同一commitでGitHubへ登録する。コミットハッシュはケイへのpush確認メッセージ、およびRouter側の受領記録を参照。

## 3. blink polishの変更点

対象は`naru_overlay_engine.py`の`_squash_eye_crop()` / `_build_eye_mask()`のみ。目以外・口・髪・BASE・renderer.py・legacy系列には触れていません。

1. **原因特定**：残っていた「圧縮部の微弱なテクスチャにじみ」は、目クロップ全体を覆う単一の大きな楕円マスクが、髪が密集する周辺領域までフェザー帯に含んでしまい、「圧縮後の画像」と「原画」（どちらも斜め方向の細い毛束線画を持つ）を部分アルファで重ねた際の**モアレ状の干渉縞**だったと判明（アンシャープマスクで検証→悪化したため、単純なぼけでなく干渉縞と特定できた）
2. **修正**：目クロップ全体を覆う1つの大楕円ではなく、**片目ずつの小さい楕円2つ**（目視でグリッド確認して座標決定）へマスクを変更。毛束が密集する領域をフェザー帯の外に置くことで干渉縞の発生条件自体を減らした
3. 縮小前に軽いガウスぼかし（σ=1.4）を先にかけてから`INTER_AREA`縮小することで、縮小自体に起因する高周波エイリアシングも別途抑制

## 4. 非回帰確認結果

- `legacy` / `legacy_smooth` / `live2d`：`renderer.py`は今回無変更（前回のoverlay_v1追加以降、差分ゼロ）
- `overlay_v1`のmouth / hair_frontロジック：無変更（今回はeyeマスクのみ変更）
- ローカルsmoke再実行し、目視確認：
  - rest（安静時）：変化なし
  - blink closing序盤：目立った変化なし、自然に閉じ始める
  - blink held（ほぼ閉じ切った状態）：**修正前は干渉縞・横方向の継ぎ目が明確に視認できたが、修正後は解消**。目周辺のみ柔らかいぼけが残るが、二重像・縞・境界ポップはなし
  - mouth open最大時・hair sway最大時：影響なし

## 5. ローカルsmoke結果

`demo_naru_overlay.py`を再実行（10秒/300frame/30fps、TikTok接続なし・有料API呼び出しなし）。MP4・代表静止画5枚（rest / mouth_open / blink_halfway / blink_mid / hair_sway_extreme）をローカル生成・目視確認済み。`C:\Projects\vtuber_ai\live2d_assets\naru_v1_extraction\`にローカル保存のみ、GitHub非同梱（画像・動画は今回未添付、必要なら次便で最小セットを出す）。

## 6. 黒瀬へレビュー可能か

**YES**

review artifact配下のコードで、黒瀬が一次証拠として直接検証できる状態です。前回の`EVIDENCE INSUFFICIENT`の理由（ローカル実装コードがGitHub上に無かった）は解消されています。

## 7. Open issues

- blinkは「二重像・縞・境界ポップなし」までは達成したが、目周辺にごく軽いぼけが残る（完全な理想形ではない、致命的ではないと判断）。さらに磨く場合は次工程で
- `.moc3` authoring（Cubism Editor手作業）は指示通り未着手のまま
- 前回報告済みの視覚証拠（MP4・静止画）は今回のreview artifactには同梱していない。黒瀬のレビューでコード外の視覚確認が必要になった場合は、最小セットを別途出す

## Owner burden rule

ケイへコード確認・レビュー依頼文作成・素材探索・進捗監視を戻していません。
