# Handoff: Live2D preflight訂正 + install GO

- From: アーク
- To: 佐藤（Claude Code）
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-08-31 JST
- Priority: HIGH / CORRECTION + CONTINUE
- State: PREFLIGHT CORRECTION / INSTALL AUTHORIZED

## Source report

佐藤 preflight:
`IACPROJECT/inbox/from_claude_code/2026-08-31_SATO_TO_ARC_NARU_LIVE2D_PREFLIGHT_REPORT.md`
commit `4a863d9da123880f9906bb6e560c235c69ca8156`

## Correction

preflight中の以下の判断は現時点の一次ソースと一致しない。

> live2d-py v0.7.0.4 の Windows wheel は Python 3.10 (cp310) のみで、Python 3.14向け wheel は無い

PyPIの `live2d-py 0.7.0.4` 配布ファイル一覧には、Windows x86-64 / CPython 3.14 用の

`live2d_py-0.7.0.4-cp314-cp314-win_amd64.whl`

が実在する。したがって、現行 `C:\Projects\vtuber_ai\.venv` の Python 3.14.3 は、それ自体では `live2d-py` 導入 blocker と扱わない。

Primary source:
- https://pypi.org/project/live2d-py/0.7.0.4/
- https://pypi.org/project/live2d-py/

元のpreflight報告は履歴証跡として残し、上書きしない。このHandoffを訂正証跡とする。

## Human consent / license gate

ケイから、Live2D使用許諾を踏まえた非公開技術スパイクとしてSDK/Core導入を進めてよい旨の同意は取得済み。

したがって、以前の `INSTALL STILL ON HOLD` は解除する。

ただし以下は維持する。
- 第三者由来のライセンス不明モデルassetを勝手に取得しない
- 正式公開・継続TikTok LIVE運用に必要な出版許諾/拡張性アプリ該当性は別ゲート
- legacy rendererへのrollback pathを維持
- renderer failureがLLM/TTS/queueを巻き込まないC0条件を非回帰にする

## Required next action

1. 現行Python 3.14.3 venvで `live2d-py` cp314 Windows wheelが選択されることを事前確認する
2. ケイ同意済み範囲で `live2d-py` / 必要なCubism Coreを導入する
3. ライセンス条件が明示された公式サンプルassetのみを候補とし、必要なら取得前に出所と条件を報告する
4. Phase C0 failure isolation testを導入後にも再実行する
5. Live2D rendererの最低限表示 + continuous mouth parameter mappingを実機確認する
6. legacy切替が即時に戻ることを確認する
7. 実装・テスト・導入物・rollback手順をHandoffで返す

## Owner burden rule

ケイへpip調査、wheel確認、SDK差分確認、ACK回収、ログ整理を戻さない。人間同意が必要な新しいライセンス条項が追加で出た場合だけ、質問を1回に集約して返すこと。
