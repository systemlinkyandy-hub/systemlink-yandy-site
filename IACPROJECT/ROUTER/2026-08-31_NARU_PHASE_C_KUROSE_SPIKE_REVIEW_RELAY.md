# NARU Phase C — 黒瀬レビュー relay

- From: アーク（ケイ経由の黒瀬レビュー記録）
- Reviewer: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-08-31 JST
- Evidence level: SECONDARY CHAT RELAY / SOURCE-AUTHORED GITHUB ARTIFACT NOT YET CONFIRMED
- Reviewed implementation: `cedabc63fdd90362fa12e9256672379cccdb3fa6`

## Verdict

**APPROVE — 技術スパイクとして SPIKE PASS。**

黒瀬レビューで確認された要点：

- 承認範囲の明確化は妥当。技術スパイクと、正式採用・公開・商用利用のゲートを分離できている。
- Haruモデル本体はGitHubへコミットされていないことを黒瀬が確認。
- 実描画検証は実モデルの描画ループまで到達しており、`get_last_mouth_param()` により描画側が読んだ実値を検証している。
- `RendererIsolationProxy` は `app_live2d.py` からのinterface呼び出しを保護するが、Live2D renderer内部スレッドの例外は同proxy経路を通らない。この構造差は実在する。
- ただし黒瀬がPhase Cに課した条件「renderer failureでLLM/TTS/queueを巻き込まない」は、実モデル故障注入テストで満たされている。

## Conditions before formal adoption

正式採用前に次の2点を解消する：

1. renderer内部スレッドの生存／故障状態を、外部から見える `is_offline` 系状態へ統合する。
2. 意図的なrender-loop破壊時にプロセス終了で再現するsegfaultの根本原因を修正する。

これらは技術スパイクのAPPROVEを覆すblockerではないが、正式採用の前提条件とする。

## Minor closure item

過去の `Python 3.10 分離venv` 判断依頼は、cp314 wheel実在確認と現行3.14環境への実導入成功により前提消滅。正式にSUPERSEDED/CLOSEDとする。

## Boundary

本ファイルは黒瀬本人がGitHubへ書いた一次レビューではなく、ケイ経由で受領したレビュー内容をアークが運用証跡として記録したもの。一次レビューartifactが後から登録された場合は、本relayをそれで置き換えず相互参照する。
