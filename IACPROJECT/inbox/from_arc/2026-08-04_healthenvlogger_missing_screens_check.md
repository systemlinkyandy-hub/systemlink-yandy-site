# HANDOFF: HealthEnvLogger 広報動画用不足画面の限定確認

送信元：アーク
次工程管理主：Claude Code
日付：2026-08-04
状態：READY_FOR_CLAUDE_CODE

---

## 1. 目的

Residual Capacity Workbench広報動画で使用するHealthEnvLogger素材について、公開マニュアル内で不足している2項目の実装有無と取得可否だけを確認する。

新規実装、UI変更、機能追加、マニュアル改定は行わない。

---

## 2. 確認対象

C:\IAC_Project 側のHealthEnvLogger現行実装を確認し、以下の2項目が存在するか調査する。

1. 症状と環境データが同時刻で並ぶ画面
2. 分析画面

補助確認として、気圧・温度・照度等の環境値がまとまって見える画面があるかも確認する。

---

## 3. 既存素材

公開マニュアル `HealthEnvLogger_manual_v2.pdf` では以下を確認済み。

- HEL-01 記録画面
- HEL-02 生理モード等
- HEL-03 連続記録
- HEL-04 タグ・メモ追加
- HEL-05 ログ確認画面
- HEL-06 設定画面

上記PDF画像はケイが目視確認済みで、使用可能。

---

## 4. 実施内容

各確認対象について、以下を返す。

- 実装有無
- 画面名
- 起動経路
- 取得可否
- 匿名化またはクロップ要否
- 取得できる場合の保存先
- 取得できない場合の理由

取得可能な場合のみ、個人情報を含まない状態でスクリーンショットを保存する。

ファイル名：

- `HEL_symptom_environment_timeline_01.png`
- `HEL_analysis_01.png`
- `HEL_environment_values_01.png`

---

## 5. 禁止

- 新規機能の実装
- デモ画面の捏造
- 実装済みに見せるための仮UI作成
- 個人ログの公開
- ケイへの素材単位の確認
- RCWや残コルチゾールHPの追加作業

---

## 6. 完了条件

以下を一括返却する。

1. 2項目の実装有無
2. 取得した素材一覧
3. 未取得理由
4. 綴が既存マニュアル素材だけでScene 3を構成可能か
5. 追加の仕様判断が必要か

返却先：`IACPROJECT/inbox/from_claude_code/`

---

## 7. ACK

```text
担当：Claude Code
読込済み：2026-08-04_healthenvlogger_missing_screens_check.md
確認対象：HealthEnvLogger不足画面2項目
新規実装：行わない
ケイへの個別確認：行わない
状態：受領済み
```
