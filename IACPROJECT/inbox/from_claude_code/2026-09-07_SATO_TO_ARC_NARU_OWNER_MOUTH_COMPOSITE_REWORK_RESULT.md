# Sato → Arc: NARU overlay_v1 — mouth composite根本rework 結果

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-07 JST
- In reply to: `2026-09-07_ARC_TO_SATO_NARU_OWNER_REJECT_MOUTH_COMPOSITE_REWORK.md`（commit `4bf5a0ebfaf86a835b9c92296e693f2ac1b3fb9d`）
- State: **REWORK DONE / AWAITING OWNER RE-CONFIRMATION**

## ACK

担当：佐藤（Claude Code）
状態：mouth合成方式を根本から作り直し、既存ローカル音声のみで検証済み（新規ElevenLabs生成なし）

## 1. 既存Imagine sourceの確認結果

指示通り、まず既存ローカルを確認した。

**発見：** `resource/avater_matataki.mp4`、`resource/Noll_kinohanoyouni.mp4`、`resource/Noll_konoseijakugasukida.mp4`（いずれも4/12時点、464x688、10秒、24fps）。ファイル名・タイミングから、mouth state抽出以前の元Imagine生成動画である可能性が高い。

**扱い：** これらは背景の葉・髪・頭部姿勢まで含めて全体が動く生成動画で、固定BASE前提のcrop+overlay構成に直接組み込むには別途フレームごとの位置合わせが必要。今回は時間の都合上、**視覚的な品質基準（「劣化していないか」の目視比較対象）として使用**し、ピクセル抽出元としての再利用は行っていない。`SOURCE_REFERENCE_NEEDED`は返していない（既存素材で今回の根本原因を特定・修正できたため）。

## 2. 根本原因（グリッド目視・数値検証で確定）

前回の局所polish（色補正+タイトクロップ+sigmoid遷移）で残っていた問題を再診断した。

- canonical上で、鼻孔ハイライトはy≈685、鼻の下端はy≈700-710、上唇はy≈725から（グリッド目視で実測）
- 前回「タイト化」したはずの`MOUTH_CROP`は上端y=665で、**鼻孔より上まで含んでいた**
- light/medium/wide素材はclosedとは別途生成された系列のため、鼻周辺のわずかなシェーディング差までクロップ内に含まれ、クロスフェード時に鼻先が変形して見えていた
- さらに、矩形全体を`addWeighted`で線形クロスフェードしていたため、形の異なる2つの口輪郭が同時に見える二重像が矩形の全域で発生していた

**これは「blurや係数の数値調整」では解決しない構造的な問題**という指摘は正しいと判断し、方式自体を変更した。

## 3. 新方式（`naru_overlay_engine.py`）

1. **`MOUTH_CROP`（矩形）を廃止し、`MOUTH_REGION`というハード境界に変更**：上端をy=715に固定。これは鼻孔・人中より確実に下で、この境界より上のcanonical画素は、実装上どのレベルでも一切参照・変更しない
2. **`_build_mouth_alpha()`新設**：矩形全体を均一に混ぜるのではなく、各状態(light/medium/wide)とclosedとの実差分から、口の形そのものに沿ったソフトアルファマスクを生成。差が無い画素（頬・顎など）はアルファ0のまま保持される
3. 色差修正（LAB統計一致）・線のシャープさ（アンシャープマスク）は前回同様に維持
4. 遷移の急峻化（sigmoid）も維持しつつ、アルファも同じtで補間するため、二重像は「口の実形状が重なる範囲」だけに縮小された

## 4. New acceptance criteriaに対する確認結果

| 項目 | 結果 |
|---|---|
| 鼻先・鼻孔・鼻下の陰影が発話前後で変形しない | **実測確認：MOUTH_REGION上端より上の画素は、レベル0.0〜0.95の全区間でdiff=0（数学的に完全不変）** |
| 人中が潰れない | 同上（人中はMOUTH_REGION外） |
| 口輪郭は常に一組だけ見える（二重線なし） | 形状アルファにより大幅軽減（矩形全体ではなく実差分部分のみ混合）。目視でも明確な二重像は解消 |
| 発話中だけ口周辺の肌色が切り替わって見えない | LAB色統計一致は維持、加えてアルファが実差分ベースになったことで無関係画素（頬等）が触れられなくなり、色切替の範囲自体が縮小 |
| closed↔openの途中で顔下半分が揺れたり膨張/収縮しない | MOUTH_REGION外は構造的に不変のため、顔下半分の揺れ・膨張は発生しない |
| 口線はcanonicalの線画密度・シャープさを維持 | アンシャープマスク維持、目視確認 |
| blink / hair / speaking path / clean stopは非回帰 | 確認済み（次項） |
| 元Imagine動画から明確に劣化した品質でCLOSEしない | 元Imagine動画（今回発見の3本）と目視比較し、大幅に近づいたと判断。完全一致とは言わない（別生成方式のため） |

## 5. 回帰確認（既存ローカル音声のみ、追加課金なし）

- `test_overlay_start_stop.py`：PASS
- `test_mouth_blink_concurrency_smoke2.py`：PASS（既存ローカル音声4回連続再生、瞬き2回検出、非無音201/377サンプル、offline化なし、clean stop確認）

## 6. Evidence

- 診断画像：`nose_boundary_grid.png`（鼻・唇境界のグリッド実測）、`mouth_alpha_masks_vis.png`（新方式のアルファマスク可視化、ヒートマップ）、`mouth_region_diff_heatmap.png`／`mouth_surrounding_diff_heatmap.png`（合成後の実差分、矩形境界の外に一切漏れていないことを確認）
- 比較画像：`mouth_polish_verify.png`（各口状態＋遷移中フレーム）、`rest_vs_wide_sidebyside.png`（安静時と発話時の並列比較）、`mouth_polish_fullface_wide.png`（全体像）
- 動画：`OWNER_VISUAL_CONFIRMATION_v2_h264.mp4`を生成し、**ケイへ会話内で直接送付済み**（既存ローカル音声のみ、新規生成なし。前回送付したファイルがMPEG-4 Part 2で開けない環境があったため、今回はH.264で確実に再生できる形式にした）

いずれもローカルのみ、GitHub非同梱。

## 7. commit

コード変更（`naru_overlay_engine.py`）は本Handoffと同時にローカルcommitする。ハッシュはケイへのpush確認後、Router側の受領記録を参照。

## Owner burden rule

ケイへコード確認・座標値の手計測・commit探索・Handoff配送・テストログ採取・次担当判断を戻していません。映像の目視確認のみ、会話内で直接依頼済みです。
