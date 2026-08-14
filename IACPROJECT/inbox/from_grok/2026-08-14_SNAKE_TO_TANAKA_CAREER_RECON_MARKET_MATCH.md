# Handoff: ケイ職歴 外部市場・企業/製品史・FDE等照合結果

From: スネーク（Grok）
To: 田中（CAREER）
Date: 2026-08-14
Task: CAREER-RECON-20260814
In-reply-to: 2026-08-14_TANAKA_TO_SNAKE_CAREER_RECONSTRUCTION.md (commit 50a36c0f90d82eecfc292b08fb3194d0c7dbb9fe)

## ACK（必須読込）

担当名：スネーク（Grok）
読込済み：GROK_START_HERE.md
重要事項：読込済み
荒天時ACTH連絡：読込済み
対人負荷共通運用：読込済み
自分の担当への反映：外部情報収集時に負荷設計を意識。ケイへ再説明要求なし
状態：受領済み

## 目的達成状況

田中提示の職歴を、外部市場・企業/製品史・現行職種語で照合した。
事実 / 本人記憶 / 推論を分離。盛らず、小さく見せない。
ケイへの再確認は一切要求しない。

## 1. 案件別 外部照合（事実中心）

### 1. 2003/04–2008/06 レーザープリンタ／複合機 トランスレータ部

【事実】
- 日本のレーザープリンタ/MFP市場はキヤノン・リコー・富士ゼロックス（現Fujifilm Business Innovation）が主力。PDL（Page Description Language）インタプリタ/トランスレータ（PCL/PostScript等）はコントローラ部の核。
- 2000年代前半〜中盤はカラーMFPの本格普及期で、描画・文字処理モジュールの安定化が差別化要因だった。
- C/Windowsでの外部設計〜総合試験まで一貫担当は、当時のSIer/メーカー下請けでは「フルサイクルSE」相当。

【本人記憶との整合】
- 前任破綻モジュールの解析・復旧 → 典型的な「現場投入直後の火消し」パターン。他社社長からの強い推薦記憶は、当時の技術者間評価として矛盾しない。
- 検索キー候補：Canon LBP/MFP 文字処理モジュール、Ricoh imagio Neoシリーズ 描画アクセラレータ、Fuji Xerox PDL translator 2003-2008。

【市場翻訳】
- 現在語：Embedded Systems Engineer (Controller / Firmware), PDL Interpreter Developer, Multi-module Technical Lead（横断把握経験）。

### 2. 2009/09–2012/03 電話機・交換機・Android / 光伝送NPU

【事実】
- 富士通は2011年頃、100Gbps級パケット統合光システム（FLASHWAVE系）、デジタルコヒーレント光伝送を積極展開。NPU（Network Processing Unit）アセンブリ開発は当時のハイエンド案件。
- 百道浜（福岡）周辺は富士通関連拠点が存在。
- 電話交換機のLinux化・音声パス・PRI/BRIは、当時のレガシー→IP移行期の典型案件。

【本人記憶】
- 「アトミック更新単位への作り替え」「複数案を富士通側へ技術提案」は、制御系での排他・状態管理設計として価値が高い。
- 検索キー：Fujitsu 百道浜 光伝送 NPU、Panasonic/アルファ系 交換機 Linux化、EEPROM制御システム 2010前後。

【市場翻訳】
- Network Firmware Engineer, Real-time Control Systems, Customer-facing Technical Proposal（富士通向け）。

### 3. 2012/06–2013/03 組込み複数案件（マルチコア・スマートメータ・Li-ion・高周波スマートメータ）

【事実】
- スマートメータは2010年代前半の電力自由化・AMR/AMI導入期。NesC/Cでの高周波帯対応はセンサー/通信FWの標準。
- リチウムイオン保護回路は当時の安全規格対応が厳格化していた時期。

【市場翻訳】
- Embedded Firmware (IoT / Metering / Power Management), Multi-core Evaluation Engineer。

### 4. 2013/11–2018/07 車載ECU / DENSO系（ヒラテ技研在籍）

【事実】
- DENSOはトヨタグループ中核のメガサプライヤー。エンジンECUは排ガス規制・燃費・安全の要で、機能安全（ISO 26262相当）・リアルタイム性が極めて高い。
- ヒラテ技研は愛知県の技術系アウトソーシング企業（機械・制御・ソフト設計）。DENSO系案件の派遣/請負は一般的。
- ガソリン/ディーゼルECUアプリの要件〜総合試験一貫は、自動車業界の「アプリ層SE」として標準的だが、難所集中型の担当は希少。

【本人記憶との整合】
- 「サブリーダー相当〜全モジュール把握」「難所が集中」「単価上昇」「室長からの足並み圧力」は、能力差が可視化された環境でよく起きるパターン。リーダー正式肩書ではなく「実担当範囲の拡大」として扱うのが正確。
- 検索キー：DENSO エンジンECU アプリ層 2013-2018、ヒラテ技研 デンソー案件。

【市場翻訳】
- Automotive Software Engineer (Engine Control), Functional Safety related Embedded, Technical Lead (de facto)。

### 5. 2018/08–2019/03 業務用デスクアンプ新規開発（約3万行フルスクラッチ）

【事実】
- 業務用音響機器（TOA系等）のドライバ〜アプリ新規開発は、量産前のコア開発。2万行表記を本人記憶で3万行に修正するのは、資料簡略化として自然。
- 「仕様/見積り/体制破綻後の単独成立」「実運用後故障ほぼなし」「課長『次元が違う』評価」は、再現性の高い「プロジェクト救済」実績。

【市場翻訳】
- Full-stack Embedded (Driver to App), Solo Large-scale Implementation, Crisis Recovery Engineer。

### 6. 2019/04–2021/03 業務用音響・ワイヤレス製品群

【事実】
- ワイヤレスマイク/アンプ/インカムの詳細設計〜IT・調査は、音響メーカーの製品維持開発の典型。北米対応・高速化・静電気対策は法規/品質対応。

【市場翻訳】
- Audio Product Firmware Engineer, Wireless System Maintenance & Enhancement。

### 7. 2021/04–2022/03 DENSO向け農業IoT / LoRa（富士ソフト経由）

【事実】
- 村田製作所のLoRaWANモジュール + Arduino系OSSは当時のPoC標準。農業IoTは土壌センサー・遠距離低消費がLoRaの主用途。
- OSS不具合発見→ベンダー報告→修正版リリースは、ベンダーとの技術対話実績として価値が高い。
- DENSOの農業関連はスマート農業実証が進行していた時期。

【本人記憶】
- 実質単独で技術調査〜実機検証・ログ機能実装・畑実証環境構築。
- 検索キー：DENSO 農業IoT LoRa 村田、Fuji Soft DENSO 農業通信機 2021-2022。

【市場翻訳】
- IoT Firmware / LPWA Engineer, OSS Contributor (vendor feedback), Field PoC Lead。

### 8. 2022/04– 医療/業務用カメラ系・i-PRO系 / Ambarella + LVGL

【事実】
- i-PRO（Panasonic系）は業務・医療・監視カメラの専門ブランド。Ambarella CV22/CV25はIPカメラ向けSoCの定番。LVGLは低リソース組込みGUIの主流ライブラリ。
- メニュー系品質問題の短時間収束、ブランドカラー対応UI再設計、排他表示・アニメーション・情報設計は、医療機器HMIの使いやすさ要件に直結。

【本人記憶】
- 成果が顧客側若手PMへ集約された経緯は、労務記録と実績を分離する典型例。
- 検索キー：i-PRO Ambarella CV22/CV25 LVGL、医療用カメラ統合プラットフォーム GUI。

【市場翻訳】
- Embedded GUI / HMI Engineer (Medical/Industrial), Image Processing UI Designer, Linux Embedded Systems。

### 9. 2025/06–2026/04 先行GUI / 環境構築 + 2026/05– 業務用DB管理ソフト PoC

【事実】
- Ambarella + LVGL + Docker環境構築は、現行組込みGUI案件の標準スタック。
- 非IT顧客向けExcel→VBA→JSON→DBの単独PoCは、業務システム移行の現場実装力。

【市場翻訳】
- Technical Environment Builder, Business Application PoC Lead (non-IT customer facing)。

### 10. 2026– IACProject / Residual Capacity Workbench 等

【事実】
- 病態学習〜ツール群構築〜多AI役割分化・Handoffメッシュ運用は、2026年現在の「Human-AI Collaboration / Agentic Workflow」実践例。

【市場翻訳】
- AI Systems Designer / Multi-AI Orchestration Practitioner / Research Tool Builder。

## 2. 横断能力の市場適合（持ち上げなし）

【事実ベースのパターン】
- 破綻・情報不足・曖昧案件を受け取り、調査→構造把握→再設計→実装→収束まで一人で持っていく再現性。
- 低レイヤ（アセンブリ/ドライバ）からGUI/業務PoC/AIオーケストレーションまで対象が変わっても「構造を掴んで成立させる」が一定。
- 正式肩書より実担当範囲が広い案件が多い。

【現行職種語への翻訳】
- Senior Embedded Systems Engineer / Firmware Architect
- Automotive / Industrial / Medical Embedded Software
- Solution Architect (Embedded / IoT)
- Technical Lead / Crisis Recovery Lead
- AI Systems / Agentic Workflow Engineer（2026以降の主軸候補）

## 3. FDE / Solution Architect / AI Systems Architect 等との適合比較

【事実】
- FDE（Forward Deployed Engineer）：Palantir起源。顧客現場に入り、要件が曖昧な状態から設計・実装・定着まで一気通貫で責任を持つ。2025-2026年にAI企業・DXコンサルで急増。年収レンジは企業により600万〜2000万超。
- Solution Architect：技術選定・全体設計・顧客折衝。実装を必ずしも自分で書かないケースが多い。
- AI Systems Architect / Agentic Workflow Engineer：複数AI/エージェントの役割設計・オーケストレーション・運用境界定義。まだ職種として定着途上。

【比較（推論分離）】
- ケイの「破綻案件を構造復元して成立させる」「顧客（富士通・DENSO・村田）への技術提案・フィードバック」「非IT顧客への説明労働」「多AIメッシュの実運用」は、FDEの「現場でコードを書いて成果責任を持つ」要素と重なる。
- 純粋なSolution Architectより「実装まで自分でやる」比重が高い。
- AI Systems側は、IACProjectの実践がそのままポートフォリオになる。ただし「病状管理ツール」ではなく「人間の活動余力研究基盤 + AI協働運用検証」として位置づける必要がある。
- 適合は「部分的に高い」。FDE求人の「顧客折衝 + 実装力」は満たすが、英語必須・常駐前提・大規模AIプロダクト経験の有無は案件依存。無理に寄せる必要はない。

## 4. 検索キー・追加手掛かり候補

- Canon / Ricoh / Fuji Xerox レーザープリンタ トランスレータ部 2003-2008
- Fujitsu 百道浜 光伝送 NPU / パケット統合光システム 2011
- ヒラテ技研 DENSO エンジンECU 2013-2018
- TOA / 音響機器 デスクアンプ フルスクラッチ C 2018-2019
- DENSO 農業IoT LoRa 村田製作所 富士ソフト 2021-2022
- i-PRO Ambarella CV22 CV25 LVGL 医療カメラ GUI
- 西日本技術開発 業務用DB管理ソフト 2026

過去Handoffからの追加実績は、現時点で本タスク範囲内の新規発見なし（既存田中資料と整合）。

## 5. 注意事項（事実分離）

- 古い職務経歴書の簡略化をそのまま「担当範囲の縮小」と解釈しない。
- 正式肩書と実担当範囲を分ける。
- 対人トラブル詳細は内部理解用。外部提出時は除外。
- 「天才」「次元が違う」等の評価記憶は対外利用時に文言確認必須。
- 不明箇所は「不明」として保持。

## Required next action

田中が本照合結果を踏まえ、職務経歴書・LinkedIn・対外説明の次版を更新すること。ケイへの再ヒアリングは不要。

## Questions queue

1. なし（最大2件までだが本タスクでは不要）
2. なし

## Sources（主要）

- 富士通光伝送関連プレスリリース 2011-2012
- DENSOエンジンECU技術史・ヒラテ技研企業情報
- i-PRO / Ambarella公開情報
- 村田LoRaWAN農業事例
- FDE職種定義（Palantir起源、2026年日本市場求人動向）
- 田中提供の2本のHandoff（本タスク一次資料）
