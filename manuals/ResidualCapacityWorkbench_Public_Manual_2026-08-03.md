# Residual Capacity Workbench — 公開マニュアル（2026-08-03時点）

## 概要

Residual Capacity Workbench（RCW）は、症状・服薬・活動、気圧・照度・温度・心拍などの環境／生体系列、身体部位ごとの所見を、時系列・部位別に並べて比較するデスクトップ向けの視覚・操作感プロトタイプです。

個人観測データの整理・比較・仮説検討のための**研究用ワークベンチ**として位置づけています。現時点ではAI連携を実装しておらず、外部AI API・ローカルLLM等には接続しません。

本アプリは医療機器、診断支援ソフトウェア、治療支援ソフトウェアではありません。因果関係や医学的原因の推定、診断、治療判断は行いません。

## 入力データ

### Unified Timeline

現時点では、症状・服薬・活動・メモと、気圧・照度・温度・心拍の組み込みデモデータを表示します。ユーザーによる実データ入力、CSVインポートは未実装です。

### Body Systems

以下をローカルSQLiteへ保存できます。

- 身体部位ごとの観測記録
- 姿勢、可動域
- 介入記録と前後比較時間窓
- 症状の出現順序
- レビュアーメモ
- DICOMフォルダ・画像ファイルへの参照
- 頸椎近似モデルの手動調整値

## 主要機能

- **Unified Timeline** — 症状・服薬・活動・メモと環境／生体系列を共通時間軸上へ並置
- **3D Body Map** — 簡易人体モデル上で部位を選び、観測を確認・追加
- **Left / Right Asymmetry** — 保存済み観測から左右の記録分布を集計
- **Symptom Propagation** — 記録された症状の出現順序を整理
- **Intervention Comparison** — 介入前後の観測を指定時間窓で比較
- **Similar Episodes** — 症状種別、部位、平均強度差、時間帯、服薬タイミング差を用いて保存済みエピソードを単純比較
- **Imaging References** — DICOM・画像ファイルを読み取り専用で参照表示
- **Cervical Approx Model** — AP／側面レントゲンを参照し、標準的な頸椎ブロックモデルを手動調整
- **Posture / Range of Motion** — 姿勢・可動域の記録
- **Reviewer Notes** — レビュアー所見メモの保存

## 現在できること

- Unified Timelineでデモデータを俯瞰する
- Body Systemsで観測記録、姿勢、可動域、介入、症状順序、メモを保存する
- 保存済み記録から左右差、症状伝播候補、介入前後比較、類似エピソードを計算する
- DICOMフォルダ・画像ファイルを参照登録し、メタデータと画像を読み取り専用で表示する
- PRIVATE FULL DATAとANONYMIZED VIEWを切り替える。匿名化は表示上のマスクであり、保存データ自体は変更しない
- レントゲン画像を参照し、頸椎近似モデルを手動調整する

## 現在できないこと／未実装点

- Unified Timelineへの実データ入力、CSVインポート
- Filter、Compare Conditions、Lag Scan、Detect Episodes、Run Analysis、Export Evidenceの実処理
- AI、外部API、ローカルLLMとの接続
- 画像から所見・診断を推定する画像診断支援
- Reviewer Workflow全体の自動化
- 外部共有、レポート出力、AI API送信
- Unified TimelineとBody Systemsの完全な双方向同期
- Counterexampleの自動連携
- 頸椎モデルのAI自動再構成、形状最適化、投影オーバーレイ
- 本格的な統計解析

## データとプライバシー

RCWは利用者自身のPCで動作し、Body SystemsのデータはローカルSQLiteへ保存します。外部サーバー、クラウド、AI APIへの自動送信は行いません。

Imaging Referencesは元のDICOM・画像データを移動、編集、削除せず、参照情報を登録します。ANONYMIZED VIEWは画面上の識別情報をマスクする表示モードであり、元データの匿名化処理ではありません。

公開用スクリーンショット7点は、架空データおよび公開用匿名化表示であることを確認済みです。現在、画像ファイルのサイト配置はGitHub接続上のバイナリアップロード制約により別工程として残っています。

## 開発状況

2026-08-03時点で、Unified TimelineとBody Systemsの主要画面・機能を実装したAIなしプロトタイプです。自動テストは268件成功を確認しています。

## Webサイト

https://systemlinkyandy-hub.github.io/systemlink-yandy-site/

RCW公開ページ:

https://systemlinkyandy-hub.github.io/systemlink-yandy-site/residual-capacity-workbench.html

## GitHub

https://github.com/systemlinkyandy-hub/systemlink-yandy-site

今回の公開対象は説明ページと公開マニュアルです。アプリ本体、ローカルDB、内部設計資料は公開対象に含めません。

## 連絡先

systemlink.yandy@gmail.com

研究連携、技術協力、公開資料に関する連絡先です。診断、治療、服薬量に関する個別の医療相談には対応していません。