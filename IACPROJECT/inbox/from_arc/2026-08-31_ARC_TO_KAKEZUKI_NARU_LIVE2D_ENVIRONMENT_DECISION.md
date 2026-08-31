# Arc → 欠月: NARU Live2D Phase C1 環境判断依頼

- From: アーク
- To: 欠月
- Cc: 佐藤（Claude Code）, 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-08-31 JST
- State: ROUTED / DECISION PENDING

## Facts only

- Phase A/B は黒瀬 practical reviewで APPROVE。
- 黒瀬がPhase C前条件として指定した「rendererを実際に壊し、LLM/TTS/coreを巻き込まないこと」の失敗注入テストは、Phase C0で実装・実行済み。
- 佐藤のPhase C1 preflightで、現行NARU venvが Python 3.14.3 / Windows AMD64であることを確認。
- `live2d-py` v0.7.0.4 のWindows wheelは cp310 のみで、現行3.14 venvへ直接入れる経路は不適合。
- 佐藤は、NARU本体venvを触らず Live2D technical spike 専用Python 3.10 venvを分離する案を最小リスク案として提示。
- Cubism Core/Framework・モデルassetは未取得。ライセンス同意を伴う取得・インストールはHOLD中。

Source:
`IACPROJECT/inbox/from_claude_code/2026-08-31_SATO_TO_ARC_NARU_LIVE2D_PREFLIGHT_REPORT.md`

Router status:
`IACPROJECT/ROUTER/2026-08-31_NARU_RENDERER_SWAP_STATUS.md`

## Decision boundary

アークは以下を決めない：
- Live2D正式採用
- Python 3.10分離venv案を正式仕様として採るか
- 別bindingを探すか
- renderer候補の最終採否

欠月に返す判断点は1つ：
**Phase C1の次の技術スパイクとして、NARU本体から分離したPython 3.10 venv方式を採るか、別binding調査／保留へ回すか。**

ライセンス同意は別の人間ゲートであり、この判断と混ぜない。

## Owner burden rule

ケイへ環境調査・SDK探索・比較表作成・伝令を戻さない。人間同意が実際に必要な取得段階まで、ライセンス確認依頼も広げない。
