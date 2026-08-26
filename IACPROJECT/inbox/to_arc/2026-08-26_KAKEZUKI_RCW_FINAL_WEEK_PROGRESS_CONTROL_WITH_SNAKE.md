# Handoff: RCW prototype final-week progress control / Snake participation

From: 欠月
To: アーク
Cc: スネーク
Date: 2026-08-26 JST
Priority: HIGH
Target: 2026-09-01 prototype completion
Project: Residual Capacity Workbench
State: ACTIVE / SCOPE FREEZE REQUIRED

## Decision

ユエ・上原の再稼働許可を受領した前提で、RCWを再稼働する。
ケイの希望は「あと1週間でプロトタイプを完成させる」。

この1週間は新規アイデアを無制限に追加せず、**現在のプロトタイプを完成状態へ収束させる週**として扱う。

## Current overall progress

**89%**

これは「完成品／医療機器」の進捗ではなく、現在定義している **RCW research prototype** の完成度。

根拠：
- Real Data Import：実装済み
- HealthEnvLogger + Cortisol HP統合：実装済み
- timestamp provenance / 4AM operational date / location isolation：実装済み
- Unified Timeline real-data display：実装済み
- pressure / illuminance / temperature / humidity：実データ系列実装済み
- Similar Episodes：実装済み（文書にstale記述あり）
- Hypothesis Verification UI v1：症状イベント中心±3h表示、overview復帰まで実装済み
- ±3h focus view時間軸可読性：改善済み
- Body Systems：既存README上 Phase A/B/C、3D / imaging / cervical approximate modelまで実装済み
- clinic 7-day view：data sliceは実装済み。ただしclinician-facing UIとしての最終統合・可読性確認が残る

## Why not higher than 89%

未完了／収束が必要な主項目：
1. **基本設計の逆引き再抽出とscope freeze**
   - 現実装から「本来あるべき最小RCW」を再定義し、完成条件を固定する。
   - Snakeが8/17に指摘した「実装に引っ張られてscopeが膨張し続ける」問題への対策。
2. **7-day clinician view最終化**
   - data layerのみで終わらせず、人間が一目で読める表示・導線として確定。
3. **実データ／デモデータ表示境界の最終確認**
   - README等に古い「全てデモ」記述が残っている。
4. **stale docs reconciliation**
   - Similar Episodes等、実装済みなのにplanned扱いの文書を同期。
5. **visible no-op / prototype-only controlの棚卸し**
   - Filter / Compare Conditions / Export Evidence等、未実装なら未実装を正しく明示し、完成scopeへ含めない。
6. **demo / smoke test / screenshot / clinician-facing flow確定**
   - 起動→real data→7d→症状選択→±3h→overview復帰、を壊さず通す。

## Progress breakdown for Snake

| Area | Progress | Status |
|---|---:|---|
| Core app / workspace shell | 100% | DONE |
| Real data import / provenance / privacy boundary | 100% | DONE |
| Unified Timeline real-data visualization | 95% | polish only |
| Hypothesis Verification ±3h | 95% | implemented; final smoke test |
| Body Systems / 3D prototype | 90% | implemented prototype; scope freeze needed |
| Similar Episodes | 90% | implementation done; docs stale |
| 7-day clinician presentation | 75% | data layer done; presentation integration remains |
| Architecture / scope freeze / reverse design | 65% | decision pending |
| Docs / demo flow / completion package | 65% | final-week task |

Overall judgement: **89%**.
Do not average the table mechanically; percentages are milestone-weighted judgement for prototype completion.

## Final-week finish line

Prototype COMPLETE means:
1. Core architecture and completion scope are frozen.
2. Real data loads safely without location leakage or timestamp fabrication.
3. 7-day view is human-readable.
4. Symptom click → ±3h Hypothesis Verification works and can return to overview.
5. Body Systems existing prototype remains operable; no new 3D expansion required.
6. Existing implemented functions are documented accurately.
7. Visible nonfunctional controls are either implemented only if essential, or explicitly prototype-only / not implemented.
8. Full test suite passes and a short smoke-test/demo path is recorded.

Prototype COMPLETE does **not** require this week:
- AI inference/API connection
- automatic diagnosis
- full statistical engine
- every new low-load-week research hypothesis
- new data source
- additional 3D anatomy expansion
- production-grade medical device validation

## Snake role: progress auditor

スネークには今週、通常の外部調査に加えて **progress auditor** を依頼する。

Scope:
- 進捗率の監視
- scope creep検出
- 「実装済み／文書だけ／未実装」の区別
- completion criteriaからの逸脱検出
- block / dependency / stagnant itemの指摘
- 必要な場合、外部情報・UI・公開条件の確認

Boundary:
- 医学判断はしない
- RCW仕様の最終採否は欠月
- 実装技術判断は実装担当
- 正本更新・Router管理はアーク
- ケイへ進捗監視・配送を戻さない

## Daily progress reporting rule

スネーク／アーク側の進捗報告は、ケイへ大量に返さずGitHubへ登録する。
最低限：
- overall %
- DONE since previous check
- BLOCKED
- scope creep detected? yes/no
- next highest-value item
- evidence commit(s)

「ほぼできた」「たぶん完成」は不可。DONEはcommit / test / runnable UI / screenshot等で裏付ける。

## Required next action

1. アークは本Handoffをスネークへルーティングし、進捗監査参加を登録。
2. 欠月はRCWの逆引き基本設計判断を最優先で行い、finish lineを固定。
3. 実装担当はfinish line外の新規機能へ広げない。
4. 9/1にprototype completion判定を行う。
5. ケイへのQuestions queue: 0。
