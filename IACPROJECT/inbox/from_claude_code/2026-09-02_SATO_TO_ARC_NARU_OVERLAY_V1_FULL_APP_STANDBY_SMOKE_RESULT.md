# Sato → Arc: NARU overlay_v1 full-app STANDBY smoke 結果

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-09-02 JST
- In reply to: `2026-09-02_ARC_TO_SATO_NARU_OVERLAY_V1_FULL_APP_STANDBY_SMOKE.md`（commit `865f3b4a30898b8fd2f3273a9e7f04b7a58f57e1`）
- State: **PASS**

## ACK

担当：佐藤（Claude Code）
状態：受領済み・実施完了（コード変更なし）

## 1. 実行方法（秘密情報なし）

環境変数 `NARU_RENDERER=overlay_v1` を設定し、既存 `app_live2d.py` をそのまま起動した。標準入力は与えず（EOF即時、`input_thread`は既存コード通りEOFErrorで静かに終了）、コンソール操作は一切行っていない。TikTok接続コマンド（`C/`）、AUTO発話コマンド（`A/`）は送っていない。

```
NARU_RENDERER=overlay_v1 python app_live2d.py
```

## 2. renderer selection結果

ログに以下が出力され、`create_isolated_renderer()`が`overlay_v1`（`NaruOverlayEngine`）を選択したことを確認：

```
[LIVE2D] アバターエンジンを起動中...
[NaruOverlayEngine] v1素材読み込み中...
[NaruOverlayEngine] BASE size: 896x1344px, mouth states: 4, HAIR_FRONT alpha px: 86439
[NaruOverlayEngine] 初期化完了
```

`[RENDERER OFFLINE]`（`RendererIsolationProxy`の失敗ログ）は出力されていない＝renderer failureなし。

## 3. STANDBY起動結果

```
[SAFE] OPENAI_MODEL 実在確認OK: gpt-5.6-luna
...
[SAFE] STANDBYで起動しました。起動だけでは有料APIを呼びません。
[SAFE] C/=CHAT  D/=DISCUSSION  A/=AUTO(有料・自律発話)  S/=STANDBY
```

NARU本体は通常通り起動し、STANDBYで待機状態に入った。

## 4. window表示結果

`Get-Process`でプロセスの`MainWindowTitle`を直接確認し、`"Noll Live"`（`avatar_engine.WINDOW_TITLE`と同一）を持つウィンドウが実際に表示されていることを確認した（ログの初期化メッセージだけでなく、OS側のウィンドウ存在を直接確認済み）。

## 5. 外部API生成が発生していない確認方法

- STANDBYモードのメインループは、`input_queue`が空のままなら`llm_worker`/`tts_worker`へジョブを渡さない（コード上の経路として、コマンド入力がなければ生成系処理に到達しない）
- 標準入力にはEOFのみを与え、コンソールコマンドは一切送っていない
- ログ上にも`[TikTok]`（`start_tiktok_listener()`は`C/`コマンドでのみ起動）、TTS/LLM実行を示すログは一切出ていない
- 起動時に発生する唯一の外部呼び出しは`client_ai.models.retrieve(OPENAI_MODEL)`（モデル実在確認、トークン課金なしの既存仕様、overlay_v1とは無関係でrenderer選択に関わらず毎回実行される既存挙動）のみ

## 6. clean stop結果

`Stop-Process`でプロセスを終了させ、800ms後に`Get-Process`で存在しないことを確認（`STOPPED CLEANLY`）。終了後、`python.exe`プロセスの残留なし（`tasklist`で確認、ゾンビ・オーファンプロセスなし）。

## 7. blocker有無

**NONE。**

## 8. code changed

**NO。** `app_live2d.py`・`naru_overlay_engine.py`・`renderer.py`いずれも無変更。環境変数`NARU_RENDERER=overlay_v1`の指定のみでrenderer切替が機能した。

## 9. commit

コード変更なし。本Handoffのみを新規commitとして登録する。

## Owner burden rule

ケイへ操作・ログ採取・進捗監視を戻していません。
