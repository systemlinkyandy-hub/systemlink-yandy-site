"""
live2d_renderer.py
===================
[PHASE C1] Live2D/Cubism 技術スパイク用アダプタ。

現時点の状態: 実描画まで到達（技術スパイク段階）
  - ケイの同意（Live2D使用許諾を踏まえた非公開技術スパイクとしての導入）を受け、
    `live2d-py` 0.7.0.4（cp314-win_amd64）+ `glfw`（OpenGLウィンドウ用、Live2Dとは
    無関係の独立OSSライブラリ）をこのvenvへ導入済み。内包されるCubism Native Core
    version 05.01.0000 の初期化を確認済み。
  - モデルassetは、ケイが公式サイトでライセンス同意の上ダウンロードした
    `CubismSdkForNative-5-r.5.zip` に同梱の公式サンプルモデルのうち、
    "Haru"（Live2D Original Character、コラボキャラのNatoriとは規約が別）を
    `live2d_assets/Haru/` へ配置して使用する。出所・ライセンス条件は
    `live2d_assets/Haru/ATTRIBUTION.md` 参照。第三者由来の素性不明なモデルは
    一切使用していない。
  - **HaruはNARU/Nollの正式キャラクターデザインではない。** Renderer interfaceが
    実際にLive2Dを駆動できることを確認するための、技術スパイク専用の仮モデル。

実装済み:
  1. Renderer interfaceとの接続点（start/stop/set_audio_level/set_expression/set_motion）
  2. 音量→Cubismパラメータのマッピング（`audio_level_to_mouth_param`、連続値）
  3. GLFW + OpenGLウィンドウでの実モデル描画ループ（専用スレッド、legacy rendererと
     同様のstart/stopライフサイクル）
  4. モデルasset欠如時に明確な例外で失敗する構造（Phase C0のisolation proxyが
     正しく隔離できることを確認済み）

未実装（次段階）:
  - 瞬き・idle motionの自動化（SDK側にauto blink/breath機構あり、今回は
    連続口パクの確認を優先し未接続）
  - set_expression/set_motionの実装（Haruにはexpressions/motionsが同梱されているが
    今回のスパイクでは接続していない、no-opのまま）
"""

import os
import threading
import time


def audio_level_to_mouth_param(level: float) -> float:
    """
    0.0〜1.0程度のaudio levelを、Cubism標準パラメータ ParamMouthOpenY
    （0.0=閉, 1.0=全開。live2d.v3.StandardParams.ParamMouthOpenYとして実在確認済み）
    へ線形マッピングする。

    legacy rendererは口の形が3段階（closed/half_open/open）の離散値しか
    表現できないが、Live2Dは連続パラメータを受け取れるため、そのまま
    クランプするだけで滑らかな口パクにできる（合成先での分岐処理が不要）。
    """
    if level < 0.0:
        return 0.0
    if level > 1.0:
        return 1.0
    return level


class Live2DRenderer:
    """
    Renderer interface実装（renderer.Rendererとの循環import回避のため、
    継承はせずduck typingで同じメソッド集合を持たせる）。

    モデルasset未取得の場合はコンストラクタの時点でASSET BLOCKEDとして
    明確な例外を出す。renderer.create_renderer("live2d") 経由で呼ばれた場合、
    RendererIsolationProxy がこの例外を捕捉し、NARU本体を巻き込まずに
    offlineへ遷移する（Phase C0で検証済みの経路）。
    """

    MODEL_PATH_ENV = "NARU_LIVE2D_MODEL_PATH"
    WINDOW_TITLE = "NARU Live2D Spike"
    FPS = 30
    _sdk_initialized = False  # live2d.init()はプロセス内で一度だけ呼べばよい

    def __init__(self):
        try:
            import live2d.v3 as live2d  # live2d-py, Cubism 3/4系
        except ImportError as e:
            raise RuntimeError(
                "[live2d_renderer] live2d-py がインストールされていません。"
                " `pip install live2d-py` で導入できるが、Cubism Core/Framework"
                " 自体は別途Live2D公式サイトでライセンスへ同意の上取得する必要がある"
                "（ASSET BLOCKED: SDK未導入）。"
            ) from e

        try:
            import glfw
        except ImportError as e:
            raise RuntimeError(
                "[live2d_renderer] glfw がインストールされていません（`pip install glfw`）。"
                " Live2D/Cubismとは無関係の独立OSSライブラリ。"
            ) from e

        model_path = os.getenv(self.MODEL_PATH_ENV)
        if not model_path or not os.path.exists(model_path):
            raise RuntimeError(
                f"[live2d_renderer] Live2Dモデルassetが見つかりません"
                f"（環境変数 {self.MODEL_PATH_ENV} に .model3.json のパスを設定してください）。"
                f" SDK自体（live2d-py / Cubism Core）は導入・初期化確認済みだが、"
                f" ライセンス確認済みのモデルassetが用意されるまで、佐藤の判断で"
                f" モデルを取得・同梱することはしていない（ASSET BLOCKED: model asset未取得）。"
            )

        if not Live2DRenderer._sdk_initialized:
            live2d.init()
            Live2DRenderer._sdk_initialized = True

        self._live2d = live2d
        self._glfw = glfw
        self._model_path = model_path
        self._model = None
        self._window = None
        self._running = False
        self._thread = None

        self._lock = threading.Lock()
        self._audio_level = 0.0

        # デバッグ/テスト用: 実際にDrawループが読んだ最後の口パラメータ値を記録する
        # （テストからGLの外側で確認するため）。
        self._last_applied_mouth_param = None

    def start(self):
        if self._running:
            return
        self._running = True
        self._thread = threading.Thread(target=self._run, daemon=True)
        self._thread.start()
        # ウィンドウ/モデルロードが終わるまで軽く待つ（legacy rendererと同様の待ち方）。
        time.sleep(1.0)

    def stop(self):
        self._running = False
        if self._thread:
            self._thread.join(timeout=3.0)

    def set_audio_level(self, level: float):
        with self._lock:
            self._audio_level = audio_level_to_mouth_param(level)

    def set_expression(self, name: str):
        pass  # 未接続（no-op許容、Renderer interfaceの規約通り。次段階で実装）

    def set_motion(self, name: str):
        pass  # 未接続（no-op許容、Renderer interfaceの規約通り。次段階で実装）

    # ── デバッグ/テスト用 ──
    def get_last_mouth_param(self):
        with self._lock:
            return self._last_applied_mouth_param

    # ── 内部: 描画スレッド ──
    def _run(self):
        live2d = self._live2d
        glfw = self._glfw

        if not glfw.init():
            print("[live2d_renderer] glfw.init() に失敗しました。")
            self._running = False
            return

        glfw.window_hint(glfw.VISIBLE, glfw.TRUE)
        window = glfw.create_window(600, 900, self.WINDOW_TITLE, None, None)
        if not window:
            print("[live2d_renderer] glfwウィンドウの作成に失敗しました。")
            glfw.terminate()
            self._running = False
            return

        glfw.make_context_current(window)
        self._window = window

        try:
            live2d.glInit()
            model = live2d.LAppModel()
            model.LoadModelJson(self._model_path)
            self._model = model
        except Exception as e:
            print(f"[live2d_renderer] モデルロードに失敗しました: {e}")
            glfw.destroy_window(window)
            glfw.terminate()
            self._running = False
            raise

        interval = 1.0 / self.FPS
        mouth_param = live2d.StandardParams.ParamMouthOpenY

        # [PHASE C0] ループ本体を try/except で包む。ここを素通しにすると、
        # 描画ループ内で例外が起きた際にループの外側（下のcleanup）へ制御が
        # 落ちずクリーンアップが走らないまま関数を抜け、プロセス終了時に
        # セグフォルトすることを実機で確認した（GLコンテキスト解放前に
        # ネイティブリソースが解放されないまま終了するため）。
        # NARU本体(LLM/TTS/queue)はこのスレッドと無関係なので落ちないが、
        # このrendererスレッド自身の後始末は自前で保証する必要がある。
        try:
            while self._running and not glfw.window_should_close(window):
                t_start = time.time()
                glfw.poll_events()

                with self._lock:
                    level = self._audio_level
                self._last_applied_mouth_param = level

                live2d.clearBuffer()
                model.SetParameterValue(mouth_param, level)
                model.Update()
                model.Draw()
                glfw.swap_buffers(window)

                elapsed = time.time() - t_start
                sleep_t = interval - elapsed
                if sleep_t > 0:
                    time.sleep(sleep_t)
        except Exception as e:
            print(f"[live2d_renderer] 描画ループ内で例外、rendererスレッドを終了します: {e}")
        finally:
            self._running = False
            # モデル参照を破棄してからGLコンテキストを解放する。この順序を守らないと
            # プロセス終了時にネイティブ側のGPUリソース解放がGLコンテキスト消滅後に
            # 走ってセグフォルトする（実機で確認済み）。
            self._model = None
            model = None
            try:
                live2d.glRelease()
            except Exception as e:
                print(f"[live2d_renderer] glRelease()で例外（続行）: {e}")
            glfw.destroy_window(window)
            glfw.terminate()
            print("[live2d_renderer] ウィンドウを閉じました")
