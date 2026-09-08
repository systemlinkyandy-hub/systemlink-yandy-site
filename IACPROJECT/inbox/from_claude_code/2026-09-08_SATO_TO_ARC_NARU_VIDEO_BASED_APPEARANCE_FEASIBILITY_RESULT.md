# Sato → Arc: NARU video-based appearance/motion — feasibility spike 結果

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-08 JST
- In reply to: `2026-09-08_ARC_TO_SATO_NARU_VIDEO_BASED_APPEARANCE_MOTION_DIRECTION.md`（commit `e1aefd1341d738ab7137774e17eabca155562316`）
- State: **DESIGN + OFFLINE PROOF DONE / PRODUCTION未着手 / 黒瀬レビュー前**

## ACK

担当：佐藤（Claude Code）
状態：設計比較＋オフライン検証のみ完了。**production codeは無変更。** 新規Imagine生成・新規ElevenLabs生成なし。`SOURCE_REFERENCE_INSUFFICIENT`は返さない（既存素材で十分な検証ができた）。

## 1. Frame/state analysis（既存動画のみ）

`resource/Noll_kinohanoyouni.mp4`（121フレーム@12fps相当で解析）を中心に分析。

- **重要な発見：動画のフレーム0は、canonical `resource/avatar.png` とほぼ完全一致（実測diff平均6.18/255、対して10フレーム後は20.9まで乖離）。** 顔・姿勢・構図がcanonicalそのものか、それに極めて近い開始フレームから動画が生成されていると判断できる
- 自然な発話バースト区間を2箇所検出（フレーム24-44付近、67-72付近）。口が閉→開→閉と自然に変化し、**顎・頬・顔全体のシルエットが口の開閉と一体で動く**ことを確認済み（前段診断で報告済み）
- **ループ性の検証：動画全体（frame0 vs frame120）はループしない（diff平均約20）。短い候補ウィンドウ（20〜24フレーム）でも同水準の差分が残り、動画内に自然に閉じるループ区間は見つからなかった**（葉の落下・髪の揺れが単調に進行し続けるタイプの生成のため）

## 2. 推奨方式：ハイブリッド（STANDBY=静止画 ／ SPEAKING=動画バースト）

**STANDBY**：現行`overlay_v1`のcanonical静止画＋既存の瞬き・毛揺れ（無限ループ可能、追加コストなし、既に動作実績あり）をそのまま使う。

**SPEAKING**：発話開始時、canonicalとほぼ一致する動画フレーム0から自然な発話バースト区間をそのまま再生する。**口・顎・頬・髪・陰影を一切再計算しない**（診断で問題視された「顎が動かない」を、動画の実際の動きをそのまま使うことで根本的に回避する）。

**切替点の設計**：canonicalと動画フレーム0の顔部分はほぼ一致するため、切替自体は違和感が少ない。

### Method比較（Arc提示のA/B/C）

| 方式 | 評価 |
|---|---|
| A. video loop + phase-continuous state selection | 動画がループしない（上記実測）ため、連続phase選択の前提が崩れる。**却下** |
| B. motion atlas / short motion clips | 発話バースト区間をそのまま短いクリップとして保持し、speech levelでトリガする方式。**採用（上記ハイブリッドの核）** |
| C. continuous base video + minimal correction | 「continuous」再生はループ問題を継承する。ただし「発話区間だけ動画、それ以外は静止」という限定利用ならBの一種として成立 | 

## 3. Offline proof（既存音声のみ、production配線なし）

新規スクリプト`feasibility_spike_video_hybrid.py`：既存ローカル音声(`output.mp3`)のRMSレベルで「喋っているか」を判定し、閾値超で動画バースト区間（kino frame24-44）を再生、それ以外はcanonical静止画を表示する最小構成。

`live2d_assets/naru_v1_extraction/VIDEO_HYBRID_SPIKE_h264.mp4`（ローカルのみ）

## 4. Critical checksの結果（正直に報告する、2つの実際の問題を発見）

| 項目 | 結果 |
|---|---|
| 音声と動画由来の口開閉の同期 | RMSレベルでのトリガは機能する。ただしphoneme同期はしていない（指示通り不要） |
| RMS/energy同期で視覚的に許容できるか | 発話バースト自体の動きは自然（顎・頬込みで動画そのまま）。ただし後述の2点の問題あり |
| **顔全体が飛ぶ／髪や影が瞬間移動しないか** | **顔のポーズ自体は飛ばない（実測diff6.18で近似）。ただし背景の紅葉の落下位置は静止画と動画で一致しないため、切替の瞬間に葉が「ポップイン」する現象を確認した（`spike_transition_check.png`のtransition IN行、f2→f3で葉が突然出現）** |
| **video loop境界の継ぎ目** | 動画自体はループさせない設計のため継ぎ目は発生しないが、**バーストクリップの長さ（21フレーム≒0.9秒）より発話が長く続く場合、クリップ終端で静止画へ戻った直後に即座に再トリガがかかり、口が一瞬閉じてまた開く「スナップ」が発生することを確認した**（`spike_transition_check.png`の2段目、f24で一瞬closedに戻りf25で再度open） |
| CPU/GPU負荷と30fps維持 | 実測：フレーム取得+リサイズが300回/0.344秒（約873fps相当のスループット）。**現行の色補正+アルファ合成方式より軽い**。30fps維持は問題ない |
| 既存Renderer abstractionへの変更範囲 | `NaruOverlayEngine`とは別の新エンジンクラスとして実装し、`renderer.py`の`create_renderer()`へ新規分岐を1つ追加する想定。既存`legacy`/`legacy_smooth`/`live2d`/`overlay_v1`は無変更で済む見込み |
| STANDBY/SPEAKING切替時の連続性 | 上記2つの問題（葉のポップイン、バースト長不足時のスナップ）が現状の未解決課題 |

## 5. 見つかった2つの問題への対処案（未実装、次段階の検討事項）

1. **葉のポップイン**：静止画側の背景（葉）を動画フレーム0のものに差し替える、または切替時のみ数フレームのクロスフェードを挟む
2. **バースト長不足時のスナップ**：クリップ終端で即座に静止画へ戻すのではなく、発話が続く間はバースト内の「開口ピーク付近」を短くループ／ホールドし、発話終了を検知してから閉じるテール部分だけ再生する設計に変更する

## 6. `overlay_v1`顎warp方式との比較

| 観点 | crop+feather+顎warp追加 | 動画ハイブリッド方式 |
|---|---|---|
| 自然さ | 顎・頬の動きを数式で再構築する必要があり、破綻リスクが高い（診断で「貼り絵に見える」原因はまさにこの再構築の欠如） | 動画自体が持つ自然な連動をそのまま使うため、発話区間の自然さは動画品質に依存し高い |
| 実装量 | warp・landmark追従など新規ロジックが必要 | 既存動画のフレーム管理＋簡単な状態機械のみ、実装量は少ない見込み |
| 破綻リスク | warpパラメータのチューニングが長期化しやすい（今回のmouth compositeの経緯がまさにそれ） | 上記2問題（ポップイン・スナップ）は具体的に特定済みで、対処方針も明確。ゼロからのチューニングより収束が早いと判断する |

## 7. Evidence（ローカルのみ、GitHub非同梱）

- `canonical_vs_kino_pose.png`（canonicalと動画frame0の姿勢一致確認）
- `spike_transition_check.png`（2つの問題点の可視化）
- `VIDEO_HYBRID_SPIKE_h264.mp4`（オフライン実証、ケイへ会話内で共有可能）

## Owner burden rule

ケイへ座標計算・コード確認・commit探索・新規Imagine生成・動画の手動フレーム切り出しを求めていません。
