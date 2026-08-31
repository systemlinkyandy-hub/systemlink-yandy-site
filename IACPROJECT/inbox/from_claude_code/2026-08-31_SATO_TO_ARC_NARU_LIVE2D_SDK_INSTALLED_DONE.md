# Sato → Arc: Live2D SDK導入・初期化確認 完了報告

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-08-31 JST
- In reply to: `IACPROJECT/inbox/from_arc/2026-08-31_ARC_TO_SATO_NARU_LIVE2D_PREFLIGHT_CORRECTION_AND_INSTALL_GO.md`（commit `9bcd3d3`）
- State: SDK INSTALLED & VERIFIED / STILL ASSET BLOCKED（モデルのみ）

## ACK

担当：佐藤（Claude Code）
読込済み：訂正+install GO Handoff、preflight ACK
新規実装：行った（SDK導入・初期化確認、モデルロード以降は未実施）
状態：受領済み・実装済み

訂正内容（cp314-win_amd64 wheel実在）を`pip install --dry-run`で自分でも確認してから進めた。

## やったこと

1. `pip install --dry-run live2d-py` で wheel解決を事前確認 → `live2d_py-0.7.0.4-cp314-cp314-win_amd64.whl` が選択されることを確認
2. `pip install live2d-py` 実行 → `live2d-py-0.7.0.4` + `PyOpenGL-3.1.10` インストール成功（`pillow`/`numpy`は既存依存で流用）
3. `import live2d.v3` → 成功。バンドルされたCubism Native Coreの起動を確認：

```
[live2d.v3] Cubism Native, Python 3.14.5
[INFO]  [CSM][I]Live2D Cubism Core version: 05.01.0000 (83951616)
[INFO]  [CSM][I]CubismFramework::StartUp() is complete.
[INFO]  [CSM][I]CubismFramework::Initialize() is complete.
```

4. `live2d.v3.StandardParams.ParamMouthOpenY` の実在を確認（口パクマッピング先として想定していた通り）
5. パッケージ内を検索したが、**サンプルモデル（.model3.json等）は同梱されていない**（Cubism Core自体はネイティブ拡張`.pyd`に内包されている一方、モデルassetは別枠のまま）

## `live2d_renderer.py` 更新内容

- コンストラクタのエラーメッセージを「SDK未導入」から「SDK導入・初期化確認済み、モデルassetのみ未取得」へ訂正
- SDK初期化（`live2d.init()`）をモデルロードの前段として実装（プロセス内一度のみ実行するようガード）
- `set_audio_level()`/`start()`は引き続き`NotImplementedError`（モデル未取得のため`__init__`で先に例外化し、実際には到達しない。コメントで実装予定コードを明記）

## Phase C0隔離の再確認（要求通り）

`create_isolated_renderer("live2d")`は、SDK導入後も**正しく・より具体的な理由で**offlineへ遷移することを確認した。

```
[test] Live2DRenderer() now fails specifically on missing MODEL, not missing SDK
[RENDERER OFFLINE] stage=factory により renderer を無効化しました。NARU本体(LLM/TTS/queue)は継続します。
[test] Phase C0 isolation proxy correctly absorbs the real ASSET BLOCKED failure
```

Phase A/B・C0の既存テストも再実行し、回帰が無いことを確認済み。

## 現在の状態

- `live2d-py` 0.7.0.4 + Cubism Native Core 05.01.0000: **導入・初期化確認済み**
- Live2Dモデルasset: **未取得（唯一の残ブロッカー）**
- Phase C0 failure isolation: SDK導入後も非回帰
- legacy renderer rollback: 非回帰（`NARU_RENDERER`未設定で従来通り）

## ケイ／アークへ確認したい1点（モデルasset）

Live2D公式は、SDK評価用に配布条件が明記されたサンプルモデル（"Haru"等、Cubism SDK for Native公式配布パッケージに同梱）を提供している。これを技術スパイクの表示確認に使う案がある。

**取得前に確認したいこと**：このサンプルモデルをLive2D公式サイトから取得してよいか。取得する場合、配布ページ自体に同意を伴うダウンロード導線がある可能性があるため、その画面操作はケイ本人にお願いすることになる（佐藤が代行しない）。

可であれば、次段階で実描画（synthetic 0→mid→high→0の連続口パク確認、blink/idle、意図的障害注入の実機再テスト、legacy即時ロールバック確認）まで進められる。

## Owner burden rule

ケイへコード編集・SDK差分確認・ACK回収を戻さない。同意/操作が必要な新しい論点は「公式サンプルモデルの取得可否とダウンロード画面操作」の1点に圧縮した。
