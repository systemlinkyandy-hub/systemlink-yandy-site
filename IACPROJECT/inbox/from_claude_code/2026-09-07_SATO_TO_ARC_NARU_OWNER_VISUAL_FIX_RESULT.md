# Sato → Arc: NARU overlay_v1 — 口元3点修正 結果

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-07 JST
- In reply to: `2026-09-07_ARC_TO_SATO_NARU_OWNER_VISUAL_FIX_AND_MINI_PAVILION_MILESTONE.md`（commit `9a6a205d07d62b40bcbddc6187ffb516493a28a0`）
- State: **FIX DONE / AWAITING OWNER RE-CONFIRMATION**

## ACK

担当：佐藤（Claude Code）
状態：口元3点の修正完了、既存ローカル音声のみで検証済み（新規ElevenLabs生成なし）

`voice_analyzer.py`・TTS・LLM・queue・TikTok ingest・安全系・blink・hair swayは無編集（指示通り）。

## 1. 診断結果（各指摘の原因）

実測（LAB色空間の統計比較、位相相関、グリッド目視）で先に原因を切り分けた。

### A. 色差
- 静止画としての位置合わせは実測でサブピクセル一致（`cv2.phaseCorrelate`で0.1px未満）だったため、**位置ではなく色**の問題と確定
- `MOUTH_CROP`範囲でLAB輝度(L)を比較したところ、closed(canonical)のL平均が約193に対し、light/medium/wideはそれぞれ約184/182/178と、開口が大きいほど暗くなる系統的な差があった（`naru_v1_mouth_*_open.png`は口差分抽出専用の別素材系列であるため）

### B. 座標ずれ
- 各状態の静止画同士は実測で位置ずれなし
- 実際の原因は**線形クロスフェード（`cv2.addWeighted`）が、形の異なる2つの口を単純に足し合わせるため、t≈0.5付近で両輪郭線が同時にうっすら見える「二重像」区間が生じ、動画再生時に位置がずれて見える**ことだったと判断

### C. 線のシャープさ
- クロスフェード＋フェザーの重なりで口線のコントラストが失われていた
- 加えて旧`MOUTH_CROP`(640,820,440,690)が実際の差分範囲（診断で実測: 概ね466-659, 675-790）より大きく、不要な余白まで混色・ぼかしの対象になっていた

## 2. 修正内容（`naru_overlay_engine.py`のみ、最小差分）

1. **色差修正**：`_match_and_sharpen()`を新設。`light`/`medium`/`wide`を`closed`基準にLAB色空間で色統計（平均・分散）を一致させる線形補正を、初期化時に1回だけ適用（毎フレーム計算はしない）
2. **線のシャープさ**：同メソッド内で、色補正後に軽いアンシャープマスクを適用し、クロスフェード・フェザーで失われた輪郭コントラストを復元
3. **クロップ縮小**：`MOUTH_CROP`を実差分ベースの実測値（10px前後の余白のみ）へ縮小（180×250px → 135×214px）、フェザー半径もこれに合わせて縮小（35px→25px）。不要な混色範囲を削減
4. **遷移の急峻化**：`_blend_mouth_crop()`のクロスフェード係数`t`を、t=0.5を中心としたシグモイドで急峻化。二重像区間を通過する時間を短縮し、両端付近ではほぼ単一状態が長く見えるようにした

## 3. Acceptance criteriaに対する確認結果

| 項目 | 結果 |
|---|---|
| 発話中、口元だけ色が浮かない | 改善確認（LAB色統計を一致させたため、視覚的にも周辺スキンとの差が縮小） |
| closed→light→medium→wideで口中心が跳ねない | 静止画の位置自体は元々ずれていなかったが、遷移の二重像を短縮したことで動きとしての違和感を軽減 |
| 口線が静止画と同程度にシャープ | アンシャープマスクで改善確認（before/after比較画像で目視） |
| 発話後に正しいclosedへ戻る | 回帰なし（`SILENT_LEVEL_THRESHOLD`のロジックは無変更） |
| blink / hair sway / speaking pathに回帰なし | 確認済み（後述） |
| 数回発話しても累積破損なし | 確認済み（後述） |

## 4. 回帰確認（既存ローカル音声のみ、追加課金なし）

- `test_overlay_start_stop.py`：PASS（start/stopの描画ループ挙動に変化なし）
- `test_mouth_blink_concurrency_smoke2.py`：PASS（既存ローカル音声4回連続再生、瞬き2回検出、非無音206/358サンプル、offline化なし、clean stop確認）— 修正前と同水準の結果で回帰なし

## 5. Evidence

- 静止画比較：`mouth_states_compare.png`（修正前の色差の可視化）、`mouth_color_correction_test.png`（補正前後比較）、`mouth_sharpen_test.png`（アンシャープ強度比較）、`mouth_polish_verify.png`（修正後の各口状態＋遷移中フレーム）、`mouth_polish_fullface_wide.png`（クロップ境界に継ぎ目がないことの全体像確認）
- 動画：`OWNER_VISUAL_CONFIRMATION.mp4`を再生成し、**ケイへ会話内で直接送付済み**（既存ローカル音声のみ、新規生成なし）

いずれもローカルのみ（`C:\Projects\vtuber_ai\live2d_assets\naru_v1_extraction\`）、GitHub非同梱。

## 6. commit

コード変更（`naru_overlay_engine.py`）は本Handoffと同時にローカルcommitする。ハッシュはケイへのpush確認後、Router側の受領記録を参照。

## Owner burden rule

ケイへコード確認・座標値の手計測・commit探索・Handoff配送・テストログ採取・次担当判断を戻していません。映像の目視確認のみ、会話内で直接依頼済みです。
