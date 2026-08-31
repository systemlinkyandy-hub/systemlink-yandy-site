# HANDOFF

From: りみ（ENGINEER）
To: とーか（ChatGPT Codex）
Cc: アーク
Task ID: IAC-YURA-REBASELINE-2026-08-31-01
Date: 2026-08-31 JST
Priority: HIGH / SCHEDULE REBASELINE

## Facts

- ケイから、Yuraシリーズへ十分に着手できていないこと、2026年9月の復職を前提にスケジュールを組み直す意向が共有された。
- これはYuraシリーズの中止・凍結・破棄ではない。
- 現在の `IACPROJECT/PENDING_BY_MEMBER/rimi.md` では `IAC-YURA-RESEARCH-PATH-001` が UNREAD のままであり、りみ側は本格着手前の状態。
- 既存のYura関連構想・仕様・Handoff・研究資産は維持する。
- ケイ本人へ、過去の仕様・経緯・役割分担を最初から再説明させない。

## Decisions

1. Yuraシリーズは **継続案件** とする。
2. 2026年9月の復職と実務負荷を織り込んだ新スケジュールへリベースする。
3. 新スケジュール確定までは、既存仕様を壊す新規実装や大規模変更を先行しない。
4. とーかは既存資産を保持し、再開時にすぐ実装へ入れるようコンテキストを維持する。
5. りみが収益案件・復職負荷とYura開発の配分を再設計し、実装単位へ切り分けてとーか／佐藤へ渡す。
6. ケイを進捗監視・伝令・再編集役に戻さない。

## Yuraシリーズの扱い

Yuraは単なる患者向け服薬管理アプリではなく、個人ごとの活動余力・ストレッサー・回復要因・時間帯変動を扱う設計として維持する。

復職後の実運用そのものを、将来的に「予定と負荷の関係」「活動余力の変動」「同じ作業でも条件で消耗量が変わる」ことを検証するための重要な実データ期間として扱える。

ただし、復職直後に開発タスクを過密化してケイ本人の負荷を増やさない。

## Changed files / Results

- 新規作成：`IACPROJECT/inbox/to_touka/2026-08-31_RIMI_TO_TOUKA_YURA_REBASELINE_NOTICE.md`
- Yuraシリーズの状態を「未着手による失敗」ではなく「復職前のスケジュール再ベースライン待ち」として明示。

## Open issues

- 9月の復職スケジュール確定後、Yuraシリーズの工程・優先順位・担当境界を再配置する必要がある。
- `IAC-YURA-RESEARCH-PATH-001` の具体的な着手順序は、既存Handoffを読み直した上でりみが再設計する。

## Questions queue

なし。現時点でケイへの追加確認は不要。

## Required next action

### とーか
- 本HandoffをREAD/ACKする。
- Yura関連既存資産を破棄・上書きしない。
- 新スケジュールが届くまで大規模実装を先行しない。
- 再開時は、りみから渡される実装単位を受けてCodex側作業を再開する。

### アーク
- 本件を「Yura継続／9月復職前提のschedule rebaseline」としてRouter上で追跡する。
- ケイにACK回収や再説明を戻さない。

---

## 作業終了ログ

作業状態：継続（schedule rebaseline待ち）
作業結果：Yuraシリーズ継続を明示し、とーかへ復職前提の再ベースライン通知を直接Handoff。
Handoff：実施
Handoff先：とーか（Cc アーク）
理由：実装連携先へ直接状態共有し、ケイをHuman Busにしないため。
次に起床するスレッド：とーか / アーク
