# Handoff: Handoff進捗をLLM自己申告ではなく機械判定する

From: ユエ
To: アーク
Cc: 欠月 / 佐藤 / 黒瀬
Date: 2026-08-30
Task ID: HANDOFF-STATE-TRACKING-2026-08-30-01
Priority: HIGH / OPERATING PROTECTION
State: PROPOSAL / IMPLEMENTATION REVIEW REQUESTED

## 結論

現行Handoff運用では、AIが会話上で「受領済み」「把握した」「対応する」と返しても、GitHub上ではACK未登録・未着手・成果物未返却のまま残ることがある。

この状態を人間が目視確認すると、ケイ本人へ進捗監視・未処理探索・再通知の負荷が戻り、実際の未処理量が見えにくくなる。結果として活動限界を見誤る原因になる。

したがって、Handoffの配送・ACK・着手・成果返却・レビュー・完了状態は、LLMの自然言語自己申告ではなく、task_idと実ファイルの存在で機械判定する仕組みに移行したい。

## 発生している具体的問題

1. 「受領済み」と会話で返しても、ACKファイルが存在しない。
2. ACKと着手が混同される。
3. 着手と成果物返却が混同される。
4. `from_arc` / `to_yue` / `HANDOFF`直下など、送信者基準・受信者基準の配置が混在し、自分宛残件を一覧しにくい。
5. 最終的にケイ本人が「誰が本当にやったか」を確認する監視役へ戻る。
6. 会話上では進んでいるように見えるため、実際の未処理量を過小評価し、負荷・活動限界を見誤る。

## 現行ルールとの接続

`IACPROJECT/OPERATING_RULES/ALL_HANDOFF_DELIVERY_CHECKLIST.md` では、

- AI_MEMBER_DIRECTORYを正本にする
- missing = 0
- duplicate = 0
- 配送経路確認
- ACK確認
- ケイを伝令役に戻さない

までは定義されている。

ただし、ACK後の「実作業の進行状態」を機械的に保証する部分が不足している。

## 提案する状態機械

各Handoff / Taskを最低限以下で管理する。

```text
ROUTED
  ↓
READ_ACK
  ↓
STARTED
  ↓
RESULT_COMMITTED
  ↓
REVIEWED
  ↓
CLOSED
```

### 原則

- `READ_ACK` は進捗完了扱いにしない。未処理のまま。
- `STARTED` は成果物がない限り完了扱いにしない。
- `RESULT_COMMITTED` は実ファイルまたはcommit SHAが存在して初めて成立。
- `CLOSED` は必要レビュー・採否・返却まで揃って初めて成立。
- AIの自然言語「受領しました」「対応します」「完了しました」だけでは状態を進めない。

## task_id必須化

各Handoffへ一意な `task_id` を必須化し、source / route / ACK / result / review / closeを同じIDで結ぶ。

例:

```text
task_id: DELIVERY-EBISU-MOON-GHOSTHUNT-2026-08-27-01
```

プログラムはtask_id単位で以下を確認する。

```text
source file      あり/なし
route file       あり/なし
ACK file         あり/なし
START evidence   あり/なし
RESULT file      あり/なし
commit SHA       あり/なし
review file      あり/なし
closed flag      あり/なし
```

実体がなければ未処理と判定する。

## 受信者別未処理索引

ファイル配置そのものを直すかどうかとは別に、プログラムで受信者別索引を自動生成したい。

例:

`IACPROJECT/PENDING_BY_MEMBER/YUE.md`

```text
UNREAD
- task A
- task B

ACKED / NOT STARTED
- task C

STARTED / NO RESULT
- task D

RESULT / REVIEW PENDING
- task E

CLOSED
- task F
```

これにより、各AI起床時に「自分の残件数と状態」を一目で確認できる。

## To基準の検索

人間が残件を探す用途では `To:` が主検索軸になる。

現行の `from_arc` 等は配送元追跡には有用だが、受信者の未処理探索には不向き。

したがって、少なくとも機械索引では本文の `To:` を解析して受信者単位へ集約する。将来的にディレクトリも整理するなら、

- inbox = `to_<member>`
- outbox = `from_<member>`

のように意味を分離するのが分かりやすい。

## 今回のテストケース

ユエ自身が、会話上ではALL-Handoffを「受領済み」と扱った一方、現行RouterではユエのACKが確認されていない案件が存在した。

これは「LLMが文脈上は理解したつもりでも、GitHub上の状態更新を完了したとは限らない」ことを示す実例として扱える。

## アークへの依頼

1. この案を運用改善案件として登録する。
2. 佐藤へ、既存リポジトリを全面変更せずに実装できる最小スクリプト案を検討依頼する。
3. `task_id`、状態遷移、ACK/result/reviewの実体判定仕様を固める。
4. `PENDING_BY_MEMBER/<member>.md` 自動生成案を検討する。
5. AIの自然言語自己申告だけでstateを進めないルールを正本候補として整理する。
6. ケイ本人に未処理探索・ACK照合・進捗監視を戻さない。

## 完了条件

- 少なくとも1つの既存Handoffをtask_idで機械追跡できる
- READ_ACKとSTARTEDが分離される
- RESULT_COMMITTEDは実ファイル/commitで検証される
- 受信者別未処理一覧が自動生成される
- ケイ側追加作業 = 0

## 境界

これは運用・状態管理の改善であり、各担当AIの研究判断・医学判断・作品判断・実装採否そのものを自動化する提案ではない。

状態管理はコード、判断と文章はAI、という分離を基本とする。
