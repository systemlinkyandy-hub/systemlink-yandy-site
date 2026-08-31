# Arc → Sato: NARU Phase C 正式採用前条件

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-08-31 JST
- State: SPIKE APPROVED / FORMAL ADOPTION CONDITIONS ROUTED

## Basis

黒瀬レビュー relay:
`IACPROJECT/ROUTER/2026-08-31_NARU_PHASE_C_KUROSE_SPIKE_REVIEW_RELAY.md`

Reviewed implementation:
`cedabc63fdd90362fa12e9256672379cccdb3fa6`

## Verdict

Phase C技術スパイクは **APPROVE / SPIKE PASS**。
ここから先はスパイクのやり直しではなく、正式採用前のhardeningとして扱う。

## Required next implementation

### 1. Internal render-thread health integration

現状 `RendererIsolationProxy` が観測できるのはinterface呼び出し失敗であり、Live2D renderer内部スレッド例外はproxy経路外。

次段階では、renderer内部スレッドの状態を外から確認できる形へ統合すること。
最低限：
- render thread alive/dead
- last internal error
- offline/degraded state
- `is_offline` または等価の単一観測点から判定可能

LLM/TTS/queueへ例外を伝播させない原則は維持する。

### 2. Exit segfault root fix

意図的なrender-loop failure時のみ再現する、プロセス終了時segfaultを根本修正すること。

- 単に握りつぶさない
- native GL/Cubism resourceの破棄順序を確認する
- failure injection後も正常終了できることをテストする
- legacy rollbackを壊さない

## Non-goals

今回は以下を勝手に進めない：
- Live2D正式採用の最終決定
- 公開TikTok LIVE運用開始
- 商用利用判断
- HaruをNARU正式外観として採用
- NARU core conversation/TikTok/TTS/queue設計の変更

## Required evidence

完了時に以下を返す：
- changed files
- failure injection test結果
- render-thread異常時の外部観測結果
- segfault再現条件と修正後結果
- legacy rollback確認
- 0 paid API callで可能な試験は0 paidのまま実施

## Owner burden rule

ケイへコード編集・ログ採取・差分比較・再レビュー回収を戻さない。目視確認が必要になった場合だけ最後に一回へ集約する。
