# Handoff: UI可読性・注意誘導・モチベーション原則のロガー側共有

From: 欠月
To: 黒瀬
Cc: アーク / スネーク / 佐藤
Date: 2026-08-26 JST
State: SHARED PRINCIPLE / LOGGER-SIDE REVIEW REQUEST
Related Handoff: `IACPROJECT/HANDOFF/2026-08-26_KAKEZUKI_TO_SNAKE_SATO_UI_ATTENTION_MOTIVATION_PRINCIPLE.md`
Related commit: `93c0960f8babe9d36ce2a202a82fd1bfe4750d80`

## Purpose
RCW側で共有したUI原則を、HealthEnvLogger / ロガー側にも共通認識として渡す。

## Kei observation / design principle
ケイ本人の設計観察として、以下を保持する。

- 可読性は単に文字が読めることではない。
- 可読性とは、注意を引き、最初に見る場所を示し、次に見る対象へ誘導し、比較すべき点と重要度を視覚階層で伝えること。
- 「何を見ればいいか分からない画面」は、情報量や見栄えにかかわらず解析UIとして弱い。
- 一方、格好よさ・没入感・英語の短いmicrocopy・ゲーム/HUD的な緊張感は装飾ではなく、本人にとって『見たい・触りたい・続けたい』を立ち上げ、解析に使える注意・集中・粘りを増やす側へ働く。
- 例として Iron Man のHUDやゲームUI、Metal Gear Solid的なUI体験を挙げている。
- スネークという呼称自体も、ケイが格好いいと感じた『METAL GEAR SOLID』由来。
- 現在の電子カルテUIについて、ケイは「情報はあるが、注意誘導が弱く、集中して見ないと読めない」と評価している。これは本人評価として扱い、一般化は別途検証する。

## Logger-side implications
HealthEnvLogger側でも、以下を原則とする。

1. ログ入力画面と解析・振り返り画面の役割を混同しない。
2. 入力時は、迷わず・速く・負荷なく記録できることを優先する。
3. 振り返り時は、重要イベント、変化点、欠測、異常候補、前後関係の『見る順序』をUI側で作る。
4. すべてを同じ強さで表示しない。重要度・確度・時間関係で視覚階層を作る。
5. 格好よさは削らない。ただし、データの真実性や証拠境界を歪める演出はしない。
6. 英語microcopyやHUD的表現は、注意誘導・没入に寄与する範囲で使えるが、意味不明な装飾にしない。
7. GAP / missing data / provenance / recorded vs inferred 等の重要なデータ品質情報は、後景化しても消さない。

## Boundary
- 「格好いいほど解析能力が上がる」を一般的医学・認知科学上の確定事実とはしない。
- ケイ本人については、格好よさ・没入感・構造的整合感が活動継続・集中の回復要因候補として反復観察されている、という本人観察として保持する。
- UI演出によって異常や因果を誇張しない。
- ロガーのRaw data / provenance / timestamp / missingness semanticsは変更しない。

## Request to Kurose
ロガー担当として、今後のHealthEnvLogger UI / 表示 / 振り返り機能のレビューで、

- 『何を入力させたいのか』
- 『何を最初に見せたいのか』
- 『次にどこへ視線を誘導するのか』
- 『格好よさが解析継続の資源として機能しているか』
- 『演出がデータ解釈を歪めていないか』

を独立レビュー観点に追加してほしい。

Questions queue: 0

Required next action:
黒瀬は本原則をHealthEnvLogger側のレビュー基準へ反映。回答やACKはケイへ貼らずGitHubへ個別登録し、アークが回収する。