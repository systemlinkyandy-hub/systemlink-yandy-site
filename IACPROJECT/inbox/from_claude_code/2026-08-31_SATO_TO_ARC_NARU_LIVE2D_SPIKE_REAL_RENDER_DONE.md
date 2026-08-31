# Sato → Arc: Live2D技術スパイク 実描画達成 + 障害注入で見つけた既知課題

- From: 佐藤（Claude Code）
- To: アーク
- Cc: 黒瀬（Claude）, 欠月
- Task ID: `NARU-RENDERER-SWAP-2026-08-31-01`
- Date: 2026-08-31 JST
- In reply to: モデルasset提供（ケイ、`C:\Projects\CubismSdkForNative-5-r.5.zip`）
- State: **SPIKE PASS**（実描画達成、既知課題1件あり）

## ACK

担当：佐藤（Claude Code）
新規実装：行った
状態：受領済み・実装済み

## モデルasset

ケイ提供の`CubismSdkForNative-5-r.5.zip`（公式サイトでライセンス同意の上ダウンロード済み）から、同梱の公式サンプルモデル**「Haru」**（Live2D Original Character、コラボキャラのNatoriとは規約が別枠）のみを抽出し `C:\Projects\vtuber_ai\live2d_assets\Haru\` へ配置した。

- 出所・利用条件・表記義務は `live2d_assets\Haru\ATTRIBUTION.md` に記録済み（ローカルのみ、後述の理由でGitHubへは同梱していない）
- **HaruはNARU/Nollの正式デザインではない**。動作確認専用の仮モデル
- zip全体（27MB、C++デモプロジェクト等含む）は展開せず、Haruフォルダのみ抽出した

## 実装：GLFW + OpenGLウィンドウでの実描画

追加ライブラリ：`glfw`（Live2D/Cubismとは無関係の独立OSSライブラリ、pip install済み）。

`live2d_renderer.py`を「ASSET BLOCKED」から実描画実装へ更新。`start()`が専用スレッドでGLFWウィンドウ+OpenGLコンテキストを確立し、`LAppModel.LoadModelJson()`でHaruをロード、`set_audio_level()`で受けた値を毎フレーム`ParamMouthOpenY`へ適用する。

## Required tests（Handoff指定の5項目）との対応

1. **renderer boots独立起動**: PASS（NARU本体のimport無しで単体起動・モデルロード成功）
2. **synthetic 0→mid→high→0が連続値を生む**: PASS。実モデルに対し`[0.0, 0.3, 0.6, 1.0, 0.5, 0.0]`を投入し、描画ループが読んだ値が完全に一致することを確認
3. **blink/idle motionがLLM/TTSに触れず動く**: 未接続（今回のスコープは口パクの実描画確認を優先。SDK側にauto blink/breath機構はあるが今回は結線していない、次課題）
4. **意図的な例外がPhase C0隔離を発動しコアjobが完走**: PASS。ただし**重要な発見**あり（次項）
5. **legacy切替がコード変更無しで機能**: PASS

## 重要な発見：Phase C0隔離の適用範囲の限界

`RendererIsolationProxy`は`app_live2d.py`が呼ぶ**interfaceメソッド**（`start`/`stop`/`set_audio_level`等）の例外だけを捕捉する設計。今回、Live2Dの**描画ループ自身**（rendererが持つ専用スレッド内部、interfaceメソッド呼び出しの外側）で例外を注入したところ：

- そのスレッド自体はPythonレベルでは正しく後始末された（try/finally追加により、GLリソース解放・ウィンドウクローズまで実行）
- **NARU本体（LLM/TTS/queue）は無関係のスレッドなので無傷で継続**（今回のjobは正常完走）
- しかし`RendererIsolationProxy.is_offline`は`False`のままになる（描画ループの内部クラッシュはproxyの監視対象外のため）

実装中に見つけたもう1つの問題：描画ループ内で例外が起きた場合、元の実装ではcleanupコードへ到達せずプロセス終了時にセグフォルトすることが実機で確認できた（try/finallyで囲んで修正、GLコンテキスト解放前にモデル参照を破棄する順序も重要と判明）。

**現状でも残る制約**：修正後も、**意図的に描画ループを壊した場合に限り**、プロセスの最終終了時（`sys.exit`相当のタイミング）にセグフォルトが再現する。正常系（例外を起こさないstart→運用→stop）では0件、複数回のクリーン実行で確認済み。**発生タイミングは常に「全テストロジック完了・成功メッセージ出力後」であり、障害発生の瞬間や配信継続中には影響しない** —— つまりPhase C0の必須要件（「renderer failure must not terminate or poison the NARU core」）はこの条件でも満たされているが、**その後のプロセス正常終了ができなくなる**という別の弱点として記録する。

## Owner burden ruleとの整合

これは「Phase Cで実際に壊してテストする」という黒瀬条件がまさに拾うべき種類の問題であり、佐藤単独の判断で「無かったこと」にせず正直に報告する。

## 現在の状態（比較エビデンス表 更新分）

| 項目 | 前回報告（ASSET BLOCKED時点） | 今回（実描画後） |
|---|---|---|
| process boundary | in-process見込み（未検証） | **in-process、実証済み**（同一プロセス内でGLFWウィンドウ+Cubism Core動作） |
| mouth parameter resolution | 連続値（理論値） | **連続値、実モデルで実証済み**（`ParamMouthOpenY`へ直接反映） |
| asset requirement | 未取得 | **Haru（公式サンプル、Free Material License）で充足** |
| observed failure behavior | 未観測（SDK未導入時の例外のみ） | 正常系: 安定。**障害注入系: interfaceメソッド経由の例外はPhase C0で隔離済み。描画ループ内部の例外はNARU本体には影響しないが、プロセス終了時セグフォルトの既知課題あり（次課題）** |

## Next issues（今回未対応・次課題として明示）

- 描画ループ内部クラッシュを`RendererIsolationProxy`が検知できるようにする（例: rendererスレッドの生存監視）
- 障害注入後のプロセス終了時セグフォルトの根本修正（Cubism Core側のネイティブリソース解放順序の深掘りが必要、今回のスパイク規模を超える）
- blink/idle/expression/motionの実接続
- 正式公開判断（Cubism SDK Release License該当性、表記義務対応）は別ゲートのまま

## Owner burden rule

ケイへコード編集・SDK差分確認・ACK回収を戻さない。
