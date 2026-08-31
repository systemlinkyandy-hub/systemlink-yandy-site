# Sato → Arc: Live2D SDK導入 Preflight報告（インストール未実施）

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-08-31 JST
- In reply to: `2026-08-31_ARC_TO_SATO_NARU_LIVE2D_SDK_LICENSE_GATE.md`（commit `966befa`）
- State: PREFLIGHT DONE / INSTALL STILL ON HOLD

## ACK

担当：佐藤（Claude Code）
読込済み：`2026-08-31_ARC_TO_SATO_NARU_LIVE2D_SDK_LICENSE_GATE.md`、`2026-08-31_ARC_TO_SATO_NARU_LIVE2D_TECH_SPIKE_GO.md`
新規実装：**行っていない**（インストール・SDK取得は指示通りHOLDのまま。今回はpreflight情報の収集・報告のみ）
状態：受領済み

ライセンス同意はAI側で代行しない、という指示の通り、`live2d-py`・Cubism Core・その他proprietaryなライセンス同意を伴うものは一切ダウンロード・インストールしていない。

## Preflight情報

### 現行Python version / architecture

`C:\Projects\vtuber_ai\.venv` にて確認。

```
Python 3.14.3 (64bit, AMD64, Windows)
```

### `live2d-py`候補version と配布元

- 配布元: PyPI（`pip install live2d-py`）、ソースは GitHub `Arkueid/live2d-py`
- 最新リリース: `v0.7.0.4`（2026-05-22公開）
- パッケージ本体（Pythonバインディング部分）のライセンス: MIT
- **注意**: PyPIの`live2d-py`はCubism Core自体を含まない。Cubism Core/Frameworkは別途Live2D公式サイトから取得しライセンスへ同意する必要がある（`live2d-py`側のREADMEにも明記されている旨、前回報告済み）

### Windows対応wheel有無 — 重要な発見

**`v0.7.0.4`のWindows(win_amd64)向けwheelは Python 3.10 (cp310) 向けのみ提供されている。** このプロジェクトの実行環境（Python 3.14.3）向けのプリビルドwheelは無い。

このままでは：
- `pip install live2d-py` は本venv（3.14.3）では適合するwheelが見つからず失敗する見込み
- ソースからのビルドはC++ツールチェーン＋Cubism Core本体のヘッダが別途必要になり、「技術スパイク」の範囲を超える重さになる

対応案（判断待ち、佐藤単独では選ばない）：
1. Live2Dスパイク専用に別途Python 3.10の仮想環境を用意する（NARU本体の`.venv`とは分離、会話/TTS/queue等の既存環境には触れない）
2. 別のPythonバインディング（他の`live2d-py`類似プロジェクト）を探す
3. 現時点では技術スパイクを保留し、ライブラリ側のPython 3.14対応を待つ

個人的な所見としては1（別venv）が最も安全（既存NARU環境に影響なし）。ただし追加のセットアップ判断が要るため、ここで止めて報告する。

### Cubism Core取得元

Live2D公式サイトのみを想定（`https://www.live2d.com/en/sdk/`系）。第三者配布のCore/バイナリは対象外。**今回は未取得。**

### 導入予定assetの出所・ライセンス

未定。ライセンス不明な第三者モデルassetは取得しない方針を維持。公式サンプルモデル（Live2D公式配布の"Haru"等、ライセンス条件が明記されているもの）を使う場合も、佐藤の判断だけで自動取得せず、取得前にどのモデルを使うか明示して確認を取る。

### rollback手順

- `renderer.py`の`create_renderer()`は`NARU_RENDERER`未設定時、常に`legacy`（現行AvatarEngine）を返す
- Live2D関連ファイル（`live2d_renderer.py`）を削除しても、`app_live2d.py`・`avatar_engine.py`・`renderer.py`本体には一切影響しない（`live2d_renderer`は`renderer.py`から`NARU_RENDERER=live2d`指定時のみ動的importされる）
- 万一SDKインストール後に問題が起きた場合、`pip uninstall live2d-py`＋`NARU_RENDERER`環境変数を未設定（またはlegacy）に戻すだけで完全復旧する見込み

## 現在の状態

- Live2D SDK/Core/モデルasset: 未導入・未取得（ケイの同意までHOLD、指示通り）
- 新規発見: 実行環境のPython 3.14.3に対する`live2d-py`公式wheelが無い（Python 3.10限定）。**ライセンス同意が得られた後でも、この点は別途対応方針が必要**
- Phase C0（failure isolation）は既に実装・テスト済み（前回報告）、Live2D未導入でも有効

## Owner burden rule

ケイへインストール手順探索・SDK差分確認・ACK回収・ライセンス文面の再編集を戻さない。同意が必要な操作は「Live2D使用許諾の確認・同意」の1点のみ。
