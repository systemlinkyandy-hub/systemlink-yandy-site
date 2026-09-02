# Arc → Sato: NARU overlay_v1 full-app STANDBY smoke

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-02 JST
- State: READY

## Purpose

`overlay_v1` 単体rendererの技術試作確認は完了した。
次は、既存NARU実アプリのrenderer選択経路に接続した状態で、安全に起動・停止できることだけ確認する。

## Scope

`NARU_RENDERER=overlay_v1` を明示し、既存 `app_live2d.py` を **STANDBY** で起動する。

確認項目:
1. `create_isolated_renderer()` 経由で `overlay_v1` が選択される
2. NARU本体が通常起動する
3. overlay window が表示される
4. startup時に勝手な発話・TikTok接続・有料API生成が発生しない
5. renderer failure / app core failure がない
6. clean stopできる
7. legacy既定値を変更しない

## Hard constraints

- TikTok LIVEへ接続しない
- OpenAI生成を実行しない
- ElevenLabs生成を実行しない
- `.env` 内容をGitHubへ出さない
- API keyを出さない
- `.moc3` authoringを開始しない
- NARU core conversation / queue / TTS / TikTok ingest logicを変更しない
- コード変更は原則禁止。問題が見つかった場合は、まず症状・原因候補・最小修正案だけ返す
- `NARU_RENDERER` の既定値 `legacy` を変更しない

## Evidence requested

Handoffで以下を返す:
- 実行方法（秘密情報なし）
- renderer selection結果
- STANDBY起動結果
- window表示結果
- 外部API生成が発生していない確認方法
- clean stop結果
- blocker有無
- code changed: YES/NO
- commit

## Decision rule

- PASS: `overlay_v1` を「NARU実アプリ接続済み technical prototype」として次へ進める
- FAIL: コードを広く触らず、最小原因切り分けだけアークへ返す

## Boundary

これはLive TikTok smokeではない。
これはCubism Native `.moc3` 採用判断でもない。

欠月へRoutingしない。
ケイへ操作・ログ採取・進捗監視を戻さない。
