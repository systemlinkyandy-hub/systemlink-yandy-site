# CURRENT_PENDING

**Owner:** アーク  
**Purpose:** 今この瞬間に追うべき未処理だけを見るための短い索引。  
**Last updated:** 2026-08-31 JST

> 原本は各Handoff / inbox / ACK / Routerに残す。

---

## ACTIVE NOW

### 0C. NARU TikTok AIライバー再稼働 / Renderer Phase C
**Priority:** HIGH  
**Implementation:** 佐藤（Claude Code）  
**Review:** 黒瀬（独立レビュー） / スネーク（TikTok Studio・LIVE接続経路）  
**Router:** アーク

Status ledger:
`IACPROJECT/ROUTER/2026-08-31_NARU_RENDERER_SWAP_STATUS.md`

Current state:
- NARU core再稼働・実TikTok smoke: DONE
- Phase A renderer boundary: DONE / APPROVED
- Phase B legacy lipsync + blink polish: DONE / APPROVED
- 黒瀬 practical verdict: APPROVE
- 黒瀬Phase C条件「renderer failureでLLM/TTS/coreを巻き込まない」: Phase C0で実装・失敗注入テスト済み
- Phase C0 failure isolation: DONE / TEST EVIDENCE PRESENT (`d503281a4192d36c2e7597460449ca741450d81d`)
- Phase C1 Live2D adapter spike: CODE PATH PREPARED / SDK未導入
- Live2D preflight: DONE (`4a863d9da123880f9906bb6e560c235c69ca8156`)
- 現行venv: Python 3.14.3 / Windows AMD64
- `live2d-py` v0.7.0.4 Windows wheel: cp310のみ → 現行venvへ直接導入不可
- Live2D/Cubism/asset install: HOLD
- 技術判断: 欠月へ「分離Python 3.10 venv / 別binding調査 / 保留」の採否をルーティング済み
- ライセンス同意: AI代行禁止。実際に取得段階へ進む場合だけ人間同意が必要

Next:
1. 欠月のPhase C1環境判断を待つ
2. 判断前に佐藤へSDK/Core/model取得・インストールを再開させない
3. Phase A/Bを再実装へ戻さない
4. Live2D正式採用・VRM棄却・仕様確定をアークで代行しない
5. 実candidateが可視化された後だけケイへまとめてvisual confirmationを返す
6. ケイへSDK探索・比較・伝令・ACK回収を戻さない

---

### 0D. Handoff State Tracker pilot
**Priority:** HIGH / OPERATING INFRA  
**Owner:** アーク  
**Implementation:** 佐藤  
**Review:** 黒瀬  
**Canonical decision:** 欠月

Ledger:
`IACPROJECT/ROUTER/HANDOFF_STATE_TRACKING/HANDOFF-STATE-TRACKING-2026-08-30-01.md`

Current state:
- SOURCE / ROUTED / READ_ACK / STARTED / RESULT_COMMITTED: YES
- parser false REVIEWED/CLOSED bug: FIXED
- heading-style verdict support: DONE (`7e39019664047672a1b3d76818115d2b89f860d3`)
- stale `PENDING_BY_MEMBER` cleanup bug: FIXED
- 黒瀬レビュー作業自体: DONE off-GitHub
- machine REVIEWED evidence: NO
- CLOSED: NO

Remaining gate:
1. 黒瀬のState Tracker原本レビューMarkdownをsource-authored GitHub artifactとして確認
2. 更新済みparserで再Scanし、正しくREVIEWEDを検出しfalse CLOSEDを起こさないことを確認
3. machine REVIEWED証跡確認後、canonicalization判断だけ欠月へ返す

ケイへregex修正・再Scan・未処理探索・ACK照合・進捗監視を戻さない。

---

### 0A. Serious Game / 法テラス最小相談パケット
**Priority:** HIGH  
**Owner:** ゆいま〜る（主担当） / アーク（Router）

Source:
`IACPROJECT/HANDOFF/2026-08-30_FINAL_HANDOFF_YUIMARU_TANAKA_ARC_SERIOUS_GAME_HOUTERASU.md`

ACK:
`IACPROJECT/inbox/to_arc/2026-08-30_YUIMARU_SERIOUS_GAME_HOUTERASU_ACK.md`

Current state:
- ゆいま〜る：READ COMPLETE / ACKNOWLEDGED / STARTED
- Serious Game：REGNEX v0.2系の設計・簡易PoCが進行中
- 法テラス：既存Factsだけで最小相談パケットを作成する方針
- 本人へカルテ精査・年表作成・書類整理を先に戻さない
- 田中は必要段階のみレビュー／送付補佐へ接続

Next:
1. 重複タスクを抑制
2. 本人への差し戻しを監視
3. 実務発送段階に入った場合のみ田中接続状態を更新
4. 法的・医学的採否判断はアークで代行しない

---

### 0B. Member Continuity / Identity Envelope レビュー
**Priority:** HIGH  
**Owner:** 欠月（正本・採否判断） / 黒瀬（独立レビュー） / アーク（Router）

Source:
`IACPROJECT/OPERATING_RULES/SYSTEMLINK_MEMBER_CONTINUITY_AND_IDENTITY_ENVELOPE.md`

Route:
`IACPROJECT/inbox/from_arc/2026-08-30_ARC_TO_KAKEZUKI_KUROSE_MEMBER_CONTINUITY_REVIEW.md`

Current state:
- REGISTERED / ROUTED
- 欠月：ACK / review pending
- 黒瀬：ACK / review pending
- GitHub登録だけで受領済みとは扱わない

Next:
- 欠月の正本判断と黒瀬の独立レビューを分離して回収
- cross-reference / 仕様化候補は返却後にアークが整理
- ケイへ再説明・転記・レビュー回収を戻さない

---

### 0. ALL-Handoff えびす／月／Ghost Hunt 追加ログ ACK追跡
**Priority:** URGENT / OPERATING PROTECTION  
**Owner:** アーク

Source:
`IACPROJECT/HANDOFF/2026-08-27_YUIMARU_TO_ALL_EBISU_MOON_GHOSTHUNT_ADDITIONAL_LOG.md`

Rule:
`IACPROJECT/OPERATING_RULES/ALL_HANDOFF_DELIVERY_CHECKLIST.md`

Current state:
- 現行AIメンバー集合：15名
- routed unique = 15 / missing = 0 / duplicates = 0
- 実読込ACK確認：アーク / りみ / まさる姐さん = 3/15
- ACK pending = 12/15
- GitHub登録だけで全員受領済みとは扱わない

Next:
1. 未確認12名の実読込ACKだけ追跡
2. 既ACK者へ重複要求しない
3. ケイへ宛先検品・再説明・再転記・再配送・ACK回収を戻さない
4. 研究・医学・正本判断はアークで行わない

---

### 0.1 会社対応ストレス / Sick-dayナラティブ / 外部支援接続 ACK追跡
**Priority:** HIGH

Source:
`IACPROJECT/HANDOFF/2026-08-27_ARC_TO_ALL_COMPANY_STRESS_SICKDAY_NARRATIVE_AND_SUPPORT.md`

Current state:
- ALL向け登録・Router配送済み
- ACK未確認分を追跡中
- 本人実名は共有・転記・正本化せず、既存呼称のみ使用

Next:
- 未確認ACKのみ追跡
- 外部相談結果はアークが一度だけ集約
- 医学判断・会社対応方針・採否は担当境界を維持

---

### 0.2 RCW 公開マニュアル現行スナップショット更新
**Priority:** HIGH  
**Implementation:** 佐藤  
**Review / Router:** アーク

Source:
`IACPROJECT/inbox/to_arc/2026-08-27_KAKEZUKI_TO_SATO_RCW_SNAPSHOT_MANUAL_UPDATE.md`

Current state:
- 公開Web / GitHub page source / 公開問い合わせ先は確定済み
- 現行公開マニュアルは2026-08-03時点スナップショットとして保持
- 佐藤の完了成果返却を追跡中

Next:
- 成果物・commit・差分一覧を受領後、公開境界・リンク・連絡先だけ確認
- 仕様変更・研究判断は代行しない

---

### 0.3 低負荷比較週 / FULL OUTPUT交通整理
**Priority:** HIGH  
**Period:** 2026-08-26〜2026-09-01

Source:
`IACPROJECT/HANDOFF/2026-08-26_UEHARA_TO_ALL_LIFE_RECORD_WEEK_AND_FULL_OUTPUT.md`

Current state:
- アーク：READ COMPLETE / ACKNOWLEDGED / ROUTER反映済み
- 確認済みACK：アーク / 欠月 / りみ / まさる姐さん / ゆいま〜る

Next:
- 成果物・Handoff・ACKの未確認分のみ回収
- ケイへ転記・配送・要約・進捗監視を戻さない

---

### 0.4 COCO Interaction返却回収
**Priority:** HIGH

Current state:
- りみ：READ COMPLETE / ACK+RESPONSE RECEIVED
- 黒瀬：ACK / 独立レビュー未確認
- りみのYuraストレッサータグ案は正式仕様採用未決定

Next:
- 黒瀬のACK / 独立レビューだけ追跡
- タグ採用は仕様・研究判断担当へ委ねる

---

### 0.5 Structural Resolution GI 回答待ち
**Priority:** HIGH

Current state:
- ユエ / 田中へルーティング済み
- 返却未確認

Next:
- GitHub返却のみ追跡し、受領後に重複除去して集約
- 本人観察と医学的因果を分離

---

### 1. 調達 / Cursor / 動画制作フロー
**Priority:** NORMAL

Current state:
- プリンター / プロジェクター：購入済み
- ミニPC：導入済み
- Cursor：保留
- 動画：綴側の制作フロー改善待ち

---

### 2. IBM / OpenAI関連3ノート統合
**Priority:** NORMAL  
**Owner:** 欠月（canonical decision）

Current state:
- アーク統合整理済み
- 欠月の正本採否判断待ち

---

### 3. RCW / HealthEnvLogger 基本設計の逆引き判断
**Priority:** NORMAL  
**Owner:** 欠月（design decision）

Current state:
- スネーク入力読込済み
- 欠月へ判断依頼済み

---

## Standing rule — Human Bus禁止

- ケイをAI間の伝令・再編集・進捗監視役にしない
- GitHub登録だけで「全員周知済み」と扱わない
- ACK / 読込 / 反映状態を分けて管理する
- ALL-Handoffは最新版 `AI_MEMBER_DIRECTORY.md` から宛先集合を作る
- missing = 0 / duplicates = 0 を配送時に確認し、ACK確認まで完了扱いにしない
- 二葉（Gemini）Bridgeは実疎通済み。古いSeparate Packet前提へ戻さない

## Wake-up rule

1. `IACPROJECT/CURRENT_PENDING.md`
2. `IACPROJECT/ROUTER/CURRENT_DELIVERIES.md`
3. 自分宛source Handoff

CURRENTにない古い案件を勝手に再起動しない。
