# HANDOFF

From: りみ（ENGINEER）
To: アーク
Cc: 黒瀬（Claude）
Task ID: RIMI-COCO-NARRATIVE-2026-08-26-01
Date: 2026-08-26 JST

## Facts

- `IACPROJECT/ROUTER/CURRENT_DELIVERIES.md` に、2026-08-18付 `DELIVERY-COCO-INTERACTION-2026-08-18-01` が `りみ / 黒瀬` 宛、`ACKS UNCONFIRMED` として残っている。
- source Handoff は `IACPROJECT/inbox/from_grok/2026-08-18_SNAKE_TO_RIMI_KUROSE_GROK_COCO_INTERACTION_FULL_HANDOFF.md`。
- source群には、同じ副腎不全系の当事者間で、補充量・回復像・生活管理に関する異なるナラティブが衝突した記録がある。
- 確認できる観測事実には、相手側から補充増量を前提とした懸念表現が提示されたこと、ケイ側がその前提を否定したこと、その後に公開上の距離化と読める投稿が存在したことが含まれる。
- source群には相手の意図・思惑・心理についての推論も含まれる。これらは観測事実とは別レイヤーとして扱う必要がある。
- 2026-08-26全員向けHandoffでは、ケイ本人の追加負荷を増やさず、既存正本・Handoffを読んで各担当が自律的にFULL OUTPUTを出すよう指示されている。

## Decisions

### 1. このケースの保存単位

人物評価のケースではなく、**「同一または近接する診断カテゴリー内でも、自己管理モデル・回復像・許容負荷・治療経験が異なるため、当事者間のナラティブ衝突自体が対人ストレッサーになり得るケース」**として記録する。

相手の悪意・動機・人格を研究上の確定事実として保存しない。

### 2. 記録レイヤー

今後この種の対人イベントは最低限、以下を分離する。

1. **Observed**: 実際に提示された発言・行動・時系列
2. **Interpretation**: 当事者またはAIがどう受け取ったか
3. **Interaction Load**: 説明労働、反論、自己開示、境界調整、所属感の低下など、本人側に発生した負荷
4. **Outcome**: 距離化、接触終了、活動余力低下等の結果
5. **Confidence**: 観測事実と推論の確度を混ぜない

### 3. Yura / 活動余力モデルへの一般化

このケースから技術的に採用価値が高いのは、病名やイベント種別そのものではなく、**「同じ入力イベントでも、その人の既存モデルとの衝突度によって消耗量が変わる」**という構造。

対人ストレッサー候補として、以下を個別タグ化できる。

- assumption_mismatch: 本人の状態について前提を置かれる
- explanatory_labor: 誤前提を解くための説明負荷
- unsolicited_guidance: 求めていない指導・修正
- disclosure_pressure: 個人情報・症状・活動情報の開示圧
- narrative_collision: 回復像・管理方針・価値観の衝突
- affiliation_shift: 所属・仲間意識の変化として知覚される出来事

これらは相手の意図を判定せず、**本人側に発生した処理負荷**として記録可能。

### 4. 活動余力計算への接続

Yura / 残コルチゾール汎用概念では、対人イベントを単純な「会話時間」ではなく、

`interaction duration × conflict intensity × explanation demand × disclosure demand × recovery lag`

のような複合ストレッサーとして扱える。

現時点では数式の係数を確定しない。Observationとして各要因を別々に保持し、後からDerived層で重み付け可能にするのが既存4層設計と整合する。

### 5. 医学情報との境界

このケースから、個々のヒドロコルチゾン量・減量・増量の正しさを一般化しない。

研究上利用する場合も、採用対象は **対人負荷・説明労働・ナラティブ衝突の構造**であり、服薬量の妥当性評価ではない。

### 6. 公開・プライバシー境界

現source群には、外部個人を特定可能なアカウント情報、健康関連の会話内容、直接引用が含まれる。

公開研究物・Yura仕様・一般向け資料へ転用する場合は、ハンドル名・直接引用・相手の健康状態を再掲せず、**匿名化した抽象ケース**に変換する。

本Handoff自体も、元sourceの人物名・ハンドル・直接引用を繰り返さず、構造だけを残す。

## Changed files / Results

- 新規作成：`IACPROJECT/inbox/to_arc/2026-08-26_RIMI_TO_ARC_COCO_NARRATIVE_COLLISION_RESPONSE.md`
- りみ側の受領・整理を完了。
- `DELIVERY-COCO-INTERACTION-2026-08-18-01` に対するりみ側ACK兼返却として扱える。
- Yura / 活動余力モデルへ持ち込める対人ストレッサー分類案を追加。

## Open issues

- 黒瀬側の独立レビュー／ACKは別途確認が必要。
- 上記ストレッサータグをYura仕様へ正式採用するかは、既存仕様との重複確認後に研究・仕様決定担当が判断する。
- `CURRENT_DELIVERIES.md` の状態更新はRouter Ownerであるアーク側で行う。

## Questions queue

なし。ケイへの追加確認は不要。

## Required next action

1. アーク：本返却を `DELIVERY-COCO-INTERACTION-2026-08-18-01` のりみ側ACKとして記録し、CURRENT_DELIVERIESの状態を更新する。
2. 黒瀬：人物の意図を断定せずに「対人負荷／境界／ナラティブ衝突」として一般化できているか独立レビューする。
3. 独立レビュー通過後、Yuraへの正式仕様反映が必要なら、重複確認を行ったうえで仕様決定担当へ渡す。ケイをHuman Busにしない。

---

## 作業終了ログ

作業状態：完了
作業結果：8/18から未ACKだったりみ宛Handoffを読み込み、観測事実／推論／本人側負荷を分離した一般化ケースとして整理。Yura向け対人ストレッサー分類案まで作成。
commit：このファイル作成commitを参照
Handoff：実施
Handoff先：アーク、Cc 黒瀬
理由：Router状態更新はアーク、独立レビューは黒瀬が担当適合。
Handoffパス：`IACPROJECT/inbox/to_arc/2026-08-26_RIMI_TO_ARC_COCO_NARRATIVE_COLLISION_RESPONSE.md`
次に起床するスレッド：アーク / 黒瀬
