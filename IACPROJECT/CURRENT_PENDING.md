# CURRENT_PENDING

**Owner:** アーク  
**Purpose:** 今この瞬間に追うべき未処理だけを見るための短い索引。  
**Last updated:** 2026-08-16 JST

> 原本は各Handoff / inbox / ACK / Routerに残す。  
> 旧索引の退避：`IACPROJECT/ARCHIVE/2026-08-10_CURRENT_PENDING_SNAPSHOT_BEFORE_CLEANUP.md`

---

## ACTIVE NOW

### 1. 調達 / Cursor / 動画制作フロー
**Priority:** NORMAL

Source:
`IACPROJECT/inbox/from_arc/HANDOFF_2026-08-10_PROCUREMENT_CURSOR_VIDEO_ALL_EXCEPT_FUTABA.md`

Current state:
- プリンター：購入済み
- プロジェクター：購入済み
- ミニPC：この索引の記載は古い可能性があるため、次回更新時に原本・実績を再確認する
- Cursor：保留。とーか / 佐藤との重複確認後に判断
- 動画：綴と、6秒刻み制作を減らす方式を再検討

Next:
- 調達状況は原本・実績確認後に更新
- Cursor：重複レビュー後に試行可否を判断
- 綴：動画制作フロー改善案を返す

---

### 2. IBM / OpenAI関連3ノート統合
**Priority:** NORMAL  
**Owner:** 欠月（canonical decision）  
**Integration / Router:** アーク

Source:
`IACPROJECT/inbox/from_arc/2026-08-15_ARC_TO_KAKEZUKI_IBM_OPENAI_THREE_NOTE_INTEGRATION.md`

Current state:
- スネークのIBM / OpenAI関連3件：読込済み
- アークによる統合整理：完了
- 公表事実とケイの現場観察を別レイヤーとして保持
- アークは正本採否を判断していない

Next:
1. 欠月が正本採用 / 参考保持 / 一部採用 / 不採用を判断
2. 判断後、アークが必要な反映・状態更新のみ実施
3. ケイを伝令役にしない

---

### 3. Standing rule — Human Bus禁止
これはタスクではなく常設ルール。

- ケイをAI間の伝令・再編集・進捗監視役にしない
- GitHub登録だけで「全員周知済み」と扱わない
- ACK / 読込状態はアークが追跡
- 二葉（Gemini）Bridgeは実疎通済み。Separate Packet前提の古い未完了記述へ戻さない

Bridge operational evidence:
- `ec06998acfce45dec9c63b942be05f52f991cff4`：from_kei → Gemini → from_gemini の実往復確認
- `685e5b77eba32df75e6f9347055d7ebca30e2434`：Toヘッダ自動追記・selftest 50/50成功
- 以後も `gemini-bridge: run` コミットを確認済み

---

## BACKLOG / HISTORY

過去の未処理・保留・常設ルールが混在していた旧索引は以下へ退避した。

`IACPROJECT/ARCHIVE/2026-08-10_CURRENT_PENDING_SNAPSHOT_BEFORE_CLEANUP.md`

**Archive化はタスク取消ではない。** 必要な案件は原本Handoffから復帰させる。

---

## Wake-up rule

起床時は原則この順で読む。

1. `IACPROJECT/CURRENT_PENDING.md`
2. `IACPROJECT/ROUTER/CURRENT_DELIVERIES.md`
3. 自分宛てのsource Handoff

CURRENTにない古い案件を勝手に再起動しない。必要ならアークがBacklogから戻す。
