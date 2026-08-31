# Sato → Arc: NARU Renderer Phase C0/C1 完了報告

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-08-31 JST
- In reply to: `IACPROJECT/inbox/from_arc/2026-08-31_ARC_TO_SATO_NARU_RENDERER_PHASE_C0_C1.md`（commit `7f79bbc`）
- State: PHASE C0 DONE / PHASE C1 SPIKE PASS・ASSET BLOCKED

## ACK

担当：佐藤（Claude Code）
読込済み：`2026-08-31_ARC_TO_SATO_NARU_RENDERER_PHASE_C0_C1.md`
新規実装：行った
状態：受領済み・実装済み

## Phase C0 — renderer failure isolation

`renderer.py`へ`RendererIsolationProxy`（+`create_isolated_renderer()`）を追加。`app_live2d.py`の変更は前回同様2行のみ（`create_renderer`→`create_isolated_renderer`への差し替え、`renderer.diff`/`app_live2d.diff`参照）。

設計：実rendererへの全呼び出しを`_safe_call()`でtry/except。失敗した時点で`offline`へ明示遷移し、以降の呼び出しは（毎回ログしつつ）no-op。silent fallback（例：失敗したら黙ってlegacyへ切り替える）はしていない。

### 実装中に見つけたバグ

最初の実装は `self._safe_call("start", self._real.start)` のように実rendererのメソッドを直接式評価で渡していたため、`self._real`が`None`（factory失敗時）だと`_safe_call`の中身（Noneチェック）に入る前に`AttributeError`が飛んだ。メソッド名を文字列で渡し`_safe_call`内部で`getattr`する方式へ修正し、再テストで解消を確認した。

### 4件の障害注入テスト（実行結果、実課金APIなし）

```
[test 1] factory failure -> offline immediately: OK
[test 1] all subsequent calls on an offline proxy were silent no-ops: OK
[test 2] start() exception -> offline, no exception propagated: OK
[test 2] offline proxy stopped forwarding calls to the broken renderer: OK
[test 3] both queue jobs completed despite a broken renderer: OK
  (conversation_memory=['Noll: JOB_ONE_TEXT', 'Noll: JOB_TWO_TEXT'], renderer offline=True)
[test 4] stop() exception -> offline, no exception propagated: OK
[test 5] NARU_RENDERER=legacy still resolves cleanly through the isolation proxy: OK

=== ALL PHASE C0 ISOLATION CHECKS PASSED ===
```

test 3は`app_live2d.py`の実際の`llm_queue→tts_queue→tts_worker`経路を使用（`speak()`のみstub化、last night同様の手法）。`set_audio_level()`が例外を投げるrendererを注入した状態で2件のjobが両方完走し、`conversation_memory`が正しく更新されることを確認した。

## Phase C1 — Live2D technical spike

### SDK/asset状況（今回のスコープ判断）

- `live2d-py`（PyPI、MITライセンス）は**未インストール**
- Cubism Core/Framework自体は`live2d-py`とは別に、Live2D公式サイトでライセンス同意の上取得する必要がある別物（パッケージのMITライセンスとは別枠）と確認した
- モデルasset（`.model3.json`一式）はこのプロジェクトに存在しない
- Handoff指示「ライセンス確認済みでないモデルassetを勝手に取得・同梱しない」に従い、モデルassetは取得していない。加えて、`live2d-py`のインストール自体もCubism Coreのライセンス同意を伴う可能性があるため、**佐藤の判断だけではインストールしていない**（要ケイ確認、下記参照）

### 実装したもの

`live2d_renderer.py`（新規）。Renderer interfaceとの接続点（`start/stop/set_audio_level/set_expression/set_motion`）と、音量→Cubismパラメータのマッピング関数`audio_level_to_mouth_param()`を実装。SDK/asset欠如時はコンストラクタで明確な例外を出す（Phase C0のisolation proxyが正しく捕捉することを確認済み）。

### 検証結果（実行結果、実課金APIなし・SDK/asset未導入のまま）

```
[test] audio_level_to_mouth_param sequence: [0.0, 0.25, 0.5, 0.75, 1.0, 0.6, 0.3, 0.0]
                                          -> [0.0, 0.25, 0.5, 0.75, 1.0, 0.6, 0.3, 0.0]
[test] mapping is continuous, not discretized like legacy's 3-level system
       (7 distinct values across 8 samples): PASS
[test] out-of-range input clamps to [0.0, 1.0]: PASS
[test] create_renderer('live2d') fails clearly as ASSET BLOCKED: RuntimeError(...)
[test] create_isolated_renderer('live2d') -> offline (real ASSET BLOCKED failure): ...
[test] core queue job completed with the (real, ASSET BLOCKED) live2d renderer offline: PASS
[test] NARU_RENDERER=legacy env var restores legacy renderer with zero code changes: PASS

=== ALL PHASE C1 SPIKE CHECKS PASSED (SPIKE PASS / ASSET BLOCKED) ===
```

Arc要求の必須テストとの対応：
1. renderer boots独立起動: 非該当（ASSET BLOCKEDのため実描画未到達）
2. synthetic 0→mid→high→0が連続値を生む: PASS（純粋関数として検証、SDK不要）
3. blink/idle motionがLLM/TTSに触れず動く: 非該当（描画未到達）
4. 意図的な例外がPhase C0隔離を発動しコアjobが完走: **PASS（合成テストダブルではなく、実際のASSET BLOCKED失敗そのもので確認）**
5. `NARU_RENDERER=legacy`への切り戻しがコード変更無しで機能: PASS

## 比較エビデンス表（要求フォーマット）

| 項目 | legacy（現行6枚方式） | Live2D（今回のスパイク結果） |
|---|---|---|
| dependency/runtime footprint | OpenCV + Pillow（既存依存のみ） | `live2d-py`（未導入）+ Cubism Core（別ライセンス、未取得）+ OpenGLコンテキスト |
| process boundary | in-process（現行アーキテクチャと同一） | **in-process見込み**（`live2d-py`はPythonネイティブ、Web検索調査結果。VRMは別プロセス/ブラウザが濃厚、との前回報告と対比） |
| mouth parameter resolution | 離散3段階（closed/half_open/open） | 連続値（0.0〜1.0、`audio_level_to_mouth_param()`で確認） |
| blink/expression/motion support | blink実装済み（今回ジッター改善）、expression/motion概念なし | SDK側にパラメータブレンド機構あり（Web検索情報、未実地検証）。今回のRenderer interfaceは`set_expression`/`set_motion`の接続点のみ用意、実装は未着手 |
| asset requirement | JPG画像6枚（既存、取得済み） | rig済み`.model3.json`一式（**未取得、ASSET BLOCKED**） |
| licensing uncertainty | なし（自前画像） | `live2d-py`本体はMIT。Cubism Core/Frameworkは別ライセンス（Live2D公式サイトでの同意が必要、収益規模でライセンス区分が変わる模様、佐藤未確認） |
| rollback cost | （legacy自体が基準） | `NARU_RENDERER`環境変数を`legacy`に戻すだけ。コード変更不要（test 5で確認済み） |
| observed failure behavior | 該当なし（今回SDK未導入のため実際の描画失敗は未観測） | SDK未導入時、コンストラクタで明確な例外 → Phase C0 isolationが正しく捕捉 → NARU本体は継続（実測） |

## ケイへ確認が必要な事項（1回に圧縮）

**`live2d-py`（pip install）およびCubism Core/Framework（Live2D公式サイトでのライセンス同意）を実際にインストール・取得してよいか。** 今回はこの判断を佐藤単独で行わず止めた。可とする場合、モデルasset（ライセンス確認済みのサンプルモデル、またはケイが用意するもの）の入手方法も合わせて教えてほしい。それが揃えば、Phase C1の残り（実描画・blink/idle・意図的障害注入の実機テスト）に進める。

## Owner burden rule

ケイへコード編集・SDK調査の転記・failure test・ACK回収を戻さない（上記ライセンス確認1点のみ、実装ではなく可否判断としてケイへ返す）。
