# Handoff: Residual Capacity Workbench 広報動画 素材正本整理

送信元：アーク
次工程管理主：Claude
日付：2026-08-04
状態：READY_FOR_CLAUDE

---

## 1. 目的

58秒広報動画で使用する実画面素材について、公開済みマニュアルと公開ページを素材正本として整理し、Sceneごとの素材対応表を作成する。

ケイへ素材単位の確認を返さず、確認は公開前の1回に集約する。

---

## 2. 方針決定

残コルチゾールHPとHealthEnvLoggerは、新規にアプリを起動して全画面を撮り直す方式を主経路にしない。

ClaudeがGitから差分更新し、公開・保全している以下のマニュアルを素材正本とする。

- 残コルチゾールHP
  - `manuals/cortisol_hp_manual_v0_3.pdf`
  - 公開URL：`https://systemlinkyandy-hub.github.io/systemlink-yandy-site/manuals/cortisol_hp_manual_v0_3.pdf`

- HealthEnvLogger
  - `manuals/HealthEnvLogger_manual_v2.pdf`
  - 公開URL：`https://systemlinkyandy-hub.github.io/systemlink-yandy-site/manuals/HealthEnvLogger_manual_v2.pdf`

- Residual Capacity Workbench
  - `residual-capacity-workbench.html`
  - 公開URL：`https://systemlinkyandy-hub.github.io/systemlink-yandy-site/residual-capacity-workbench.html`
  - 既存公開画像：`assets/screenshots/`

---

## 3. 現在確認済みのRCW素材

公開ページ内で以下を確認済み。

- `assets/screenshots/01_main_dashboard.png`
- `assets/screenshots/02_episode_log.png`
- `assets/screenshots/03_similar_episodes.png`
- `assets/screenshots/04_imaging_analysis.png`
- `assets/screenshots/05_body_map.png`
- `assets/screenshots/06_asymmetry_analysis.png`
- `assets/screenshots/07_cervical_approx_model.png`

Similar Episodesは実装済み試作画面として使用可能。ただしAI診断・医学的類似判定に見せない。

---

## 4. Claudeの担当

公開済みマニュアル2点について、動画素材対応表を作成する。

各候補図について以下を整理する。

- 素材ID
- マニュアル名
- ページ番号
- 図または画面名
- 動画内の使用候補Scene
- Git内に元画像がある場合のパス
- PDFからの切り出しでよいか
- クロップ要否
- 公開上の注意
- 最新版として使用可能か
- 不足している画面

### 残コルチゾールHP 回収候補

- 全体画面
- 服薬時刻
- 活動・消費記録
- 症状＋時系列
- 活動余力の推移

固定表現：

- 「コルチゾール濃度の推定グラフ」とは扱わない
- 「活動余力の推移」または「個人尺度としての活動余力推移」とする

### HealthEnvLogger 回収候補

- 全体画面
- 記録画面
- 気圧・温度・照度等
- 症状と環境の同時刻表示
- ログ一覧
- ログ詳細
- 分析画面

---

## 5. Claude Codeの扱い

Claude Codeは次工程の管理主ではない。

既に取得したRCW素材がある場合は保持する。

- RCW画像4点
- RCW操作動画1点

残コルチゾールHPとHealthEnvLoggerについては、公開マニュアルで素材が足りるか確認するまで、新規環境構築・全画面撮影を進めない。

追加取得が必要と確定した場合のみ、Claudeまたはアークから限定依頼する。

---

## 6. 完了条件

Claudeは以下を一括でHandoff返却する。

1. 残コルチゾールHPの動画素材対応表
2. HealthEnvLoggerの動画素材対応表
3. PDF切り出しで足りる素材
4. Git上の元画像を使うべき素材
5. 不足素材
6. Claude Codeへ追加取得を依頼すべき項目
7. ケイの追加操作が必要か
8. 事実／未確認の区分

素材単位でケイへ確認しない。

---

## 7. 次工程

Claude返却後：

Claude → アーク → 綴

アークが以下を行う。

- RCW素材との統合
- 重複除去
- Scene別素材割当
- クロップ対象固定
- 綴向け制作素材Handoff作成

---

## 8. ACK

Claudeは読込後、以下だけ返す。

```text
担当：Claude
読込済み：2026-08-04_rcw_video_material_source_handoff.md
管理対象：公開マニュアル2点の動画素材対応表
返却先：IACPROJECT/inbox/from_claude/
ケイへの個別確認：行わない
状態：受領済み
```
