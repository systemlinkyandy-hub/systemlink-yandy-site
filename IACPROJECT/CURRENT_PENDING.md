# CURRENT_PENDING

**Owner:** アーク  
**Purpose:** 今この瞬間に追うべき未処理だけを見るための短い索引。  
**Last updated:** 2026-08-10 JST

> 原本は各Handoff / inbox / ACK / Routerに残す。  
> 旧索引の退避：`IACPROJECT/ARCHIVE/2026-08-10_CURRENT_PENDING_SNAPSHOT_BEFORE_CLEANUP.md`

---

## ACTIVE NOW

### 1. 二葉（Gemini）Bridge
**Priority:** HIGH  
**Owner:** ケイ  
**Requirement final review:** 黒瀬（Claude）  
**Implementation:** 佐藤（Claude Code）  
**Backup / independent review:** とーか（ChatGPT Codex）  
**Router / ACK:** アーク

Source:
`IACPROJECT/inbox/from_arc/HANDOFF_2026-08-10_KUROSE_GEMINI_BRIDGE_REVIEW.md`

Current state:
- Gemini Developer API Paid Tier：契約済み（初回2,000円）
- 二葉はBridge完成・検証まではSeparate Packet運用を維持
- ケイを手動Packet配送へ戻さない

Next:
1. 黒瀬が APPROVE / CONDITIONS / REJECT と最小要件を返す
2. 承認後、佐藤へ実装Handoff
3. 佐藤がBridge実装・検証
4. アークがACK / 配送状態のみ管理

---

### 2. 調達 / Cursor / 動画制作フロー
**Priority:** NORMAL

Source:
`IACPROJECT/inbox/from_arc/HANDOFF_2026-08-10_PROCUREMENT_CURSOR_VIDEO_ALL_EXCEPT_FUTABA.md`

Current state:
- プリンター：購入済み
- プロジェクター：購入済み
- ミニPC：カート投入済み、カード利用条件変更の承認待ち
- Cursor：保留。とーか / 佐藤との重複確認後に判断
- 動画：綴と、6秒刻み制作を減らす方式を再検討

Next:
- PC：カード側承認後、Owner判断で購入
- Cursor：重複レビュー後に試行可否を判断
- 綴：動画制作フロー改善案を返す

---

### 3. Standing rule — Human Bus禁止
これはタスクではなく常設ルール。

- ケイをAI間の伝令・再編集・進捗監視役にしない
- GitHub登録だけで「全員周知済み」と扱わない
- ACK / 読込状態はアークが追跡
- 二葉はBridge完成まではSeparate Packet

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
