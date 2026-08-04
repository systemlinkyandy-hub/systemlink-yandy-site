# HANDOFF: Residual Capacity Workbench 58秒広報動画 最終素材引渡し

送信元：アーク
次工程管理主：綴
日付：2026-08-04
状態：READY_FOR_TSUZURI

---

## 1. 目的

58秒広報動画について、公開済みマニュアル・RCW公開ページ・ケイが撮影したHealthEnvLogger実画面を用い、Sceneごとの素材当て込み、クロップ、図解統合、字幕・ナレーション反映へ進む。

ケイは綴スレッドを「こんにちは」で起動するだけとし、素材の再説明・再編集・AI間伝令を行わない。

---

## 2. 素材正本

### 残コルチゾールHP

公開PDF：
https://systemlinkyandy-hub.github.io/systemlink-yandy-site/manuals/cortisol_hp_manual_v0_3.pdf

使用候補：
- p2 メイン画面
- p3 活動余力の推移
- p4 メモ欄／しんどさスライダー
- p5 タスクカード一覧

固定表現：
- 血中コルチゾール濃度の推定グラフとして扱わない
- 「活動余力の推移」または「個人尺度としての活動余力推移」とする

### HealthEnvLogger

公開PDF：
https://systemlinkyandy-hub.github.io/systemlink-yandy-site/manuals/HealthEnvLogger_manual_v2.pdf

PDF使用候補：
- 記録画面
- 連続記録
- タグ・メモ追加
- ログ一覧
- 設定画面

ケイ撮影の追加実画面は、File Libraryから以下のファイル名で回収すること。

#### 優先使用
- `8583.jpg`：Health Analysis Dashboard
- `8579.jpg`：Log List（症状・メモ・気温・湿度・気圧・PM2.5・画面輝度）
- `8581.jpg`：ログ詳細 上部（イベント・メモ・天気）
- `8584.jpg`：ログ詳細 下部（大気質・照度センサー）
- `8582.jpg`：Correlation Analysis／比較
- `8577.jpg`：Correlation Analysis／散布
- `8578.jpg`：Correlation Analysis／気圧変化
- `8586.jpg`：Correlation Analysis／カレンダー

#### 重複・原則不使用
- `8588.jpg`：8579とほぼ同内容、端末編集UIあり
- `8585.jpg`：8581と重複
- `8587.jpg`：8581と重複
- `8580.jpg`：8577と重複

HealthEnvLoggerについては、以下が実画面で確認済み。
- 症状／好転と環境値が同一ログ内で時刻対応して表示される
- 気温、湿度、気圧、PM2.5、照度、画面輝度等が表示される
- 不調時と好転時の環境比較がある
- 散布、気圧変化、カレンダー表示がある

公開処理：
- 氏名・メール・個人IDは見当たらない
- 実ログの日時・体温・血圧・脈拍・リブレ値・自由記述が含まれるため、必要範囲だけクロップする
- 動画上で読ませる必要がない個人値は、ぼかしまたは画角外へ除外する
- 端末ステータスバーは可能ならクロップする
- 黒塗りは使わず、チャコール矩形・ぼかし・画角調整を優先する

### Residual Capacity Workbench

公開ページ：
https://systemlinkyandy-hub.github.io/systemlink-yandy-site/residual-capacity-workbench.html

既存公開画像：
- `assets/screenshots/01_main_dashboard.png`
- `assets/screenshots/02_episode_log.png`
- `assets/screenshots/03_similar_episodes.png`
- `assets/screenshots/04_imaging_analysis.png`
- `assets/screenshots/05_body_map.png`
- `assets/screenshots/06_asymmetry_analysis.png`
- `assets/screenshots/07_cervical_approx_model.png`

優先使用：
- Unified Timeline
- Episode Log
- Similar Episodes
- 3D Body Map

注意：
- Similar Episodesは実装済み試作画面として使用可
- AI診断・医学的類似判定に見せない
- `DEMO DATA`、`NOT FOR DIAGNOSTIC USE`、`AI NOT CONNECTED`等の注意表示は残す
- 未実装機能を動作済みに見せない

---

## 3. Scene別の素材割当

### Scene 1｜0:00–0:05
綴制作のテキスト／ノード図。
実画面不要。

### Scene 2｜0:05–0:12
残コルチゾールHP公開PDFから切り出す。
- メイン画面
- 服薬時刻
- タスクカード
- 活動余力の推移

### Scene 3｜0:12–0:19
HealthEnvLogger実画面を使用。
第一候補：
- `8579.jpg`
- `8581.jpg`
- `8584.jpg`

短時間で環境項目と身体反応の同時記録が分かる構成にする。

### Scene 4｜0:19–0:27
ログ統合図を綴が制作。
左：残コルチゾールHP
右：HealthEnvLogger
中央：Residual Capacity Workbench

### Scene 5｜0:27–0:35
RCW公開画像を使用。
- 01_main_dashboard
- 03_similar_episodes
- 05_body_map
必要に応じて02_episode_log。

### Scene 6｜0:35–0:42
プロジェクト全体構成図を綴が制作。
入力→統合→比較→活動余力／働き方・環境設計への応用。

### Scene 7｜0:42–0:49
AI開発体制図を綴が制作。
- ケイ｜Owner / Research Direction
- 欠月｜研究・仕様・最終統合
- アーク｜AI連携インフラ・Handoff整理
- Claude Code｜実装
- Claude｜独立レビュー
- Gemini｜構造化・比喩・別視点
- Grok｜外部情報・動画試作
- 綴｜映像・ブランディング

### Scene 8｜0:49–0:55
失敗前／改善後の運用図を綴が制作。
- 重複報告
- 役割混線
- ケイの伝令化
- 入口一本化
- 1書き手原則
- 独立レビュー
- Handoff管理

### Scene 9｜0:55–0:58
最終タイトルカード。

表示：
- RESIDUAL CAPACITY WORKBENCH
- Observe. Compare. Design for Human Capacity.
- PUBLIC MANUAL AVAILABLE
- Visual Prototype / AI Not Connected
- systemlinkyandy-hub.github.io/systemlink-yandy-site/residual-capacity-workbench.html
- SystemLink YandY / IACProject

---

## 4. 次工程の作業

綴は以下を進める。

1. File Libraryから指定HealthEnvLogger画像を回収
2. 公開PDF・RCW公開ページから必要画面を切り出し
3. 重複素材を除外
4. Sceneごとの素材当て込み
5. クロップ・ぼかし・画角調整
6. 図解6点の制作
7. 字幕・ナレーション反映
8. 58秒タイムラインへの仮編集

途中でケイへ素材単位の確認を返さない。

---

## 5. 完了条件

綴は次を一括で返す。

- 58秒仮編集または全Sceneの完成タイムライン
- 使用素材一覧
- クロップ／ぼかし済み箇所
- 図解6点
- 字幕全文
- ナレーション全文
- 未解決事項
- 公開前にケイが確認すべき項目

ケイへの確認は公開前の1回だけとする。

---

## 6. ACK

綴は起動後、GitHub raw URLから本Handoffを読み、以下だけ返す。

```text
担当：綴
読込済み：2026-08-04_rcw_video_final_material_handoff_to_tsuzuri.md
管理対象：58秒広報動画の素材当て込み・図解・仮編集
ケイへの途中確認：行わない
状態：受領済み
```
