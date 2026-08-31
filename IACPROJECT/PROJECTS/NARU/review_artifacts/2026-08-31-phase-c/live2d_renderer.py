"""
live2d_renderer.py
===================
[PHASE C1] Live2D/Cubism 技術スパイク用アダプタ。

現時点の状態: SDK導入済み / ASSET BLOCKED（モデルのみ）
  - ケイの同意（Live2D使用許諾を踏まえた非公開技術スパイクとしての導入）を受け、
    `live2d-py` 0.7.0.4（cp314-win_amd64）をこのvenvへ導入済み。
    パッケージ自体はMIT、内包されるCubism Native Core version 05.01.0000 の
    初期化まで確認済み（`live2d.v3.init()` 成功、StandardParams取得成功）。
  - Live2Dモデルasset（.model3.json一式）はこのプロジェクトに存在しない。
    Handoff指示に従い、ライセンス確認できていないモデルassetを佐藤の判断で
    取得・同梱することはしていない（ASSET BLOCKED: モデルのみ）。
    Live2D公式配布のサンプルモデル（Haru等、SDK評価用に配布条件が明記されたもの）を
    使う案はあるが、取得前にこのHandoffで出所と利用条件を報告し判断を仰ぐ。

ここでは以下を実装・検証する:
  1. Renderer interfaceとの接続点（このクラス自体の形）
  2. 音量→Cubismパラメータのマッピングロジック（`ParamMouthOpenY`、SDK不要の純粋関数）
  3. SDK自体の初期化（`live2d.init()`、Cubism Core起動）— モデル不要な範囲で実機確認済み
  4. モデルasset欠如時に明確な例外で失敗する構造
     （Phase C0のisolation proxyが正しく隔離できることを確認済み）

モデルロード・実描画・OpenGLウィンドウ確立は、ライセンス確認済みのモデルasset入手後に
次段階で実装する。
"""

import os


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

    現状: SDK自体は導入・初期化確認済み。モデルasset未取得のため、
    コンストラクタの時点でASSET BLOCKEDとして明確な例外を出す。
    renderer.create_renderer("live2d") 経由で呼ばれた場合、
    RendererIsolationProxy がこの例外を捕捉し、NARU本体を巻き込まずに
    offlineへ遷移する（Phase C0で検証済みの経路）。
    """

    MODEL_PATH_ENV = "NARU_LIVE2D_MODEL_PATH"
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

        model_path = os.getenv(self.MODEL_PATH_ENV)
        if not model_path or not os.path.exists(model_path):
            raise RuntimeError(
                f"[live2d_renderer] Live2Dモデルassetが見つかりません"
                f"（環境変数 {self.MODEL_PATH_ENV} に .model3.json のパスを設定してください）。"
                f" SDK自体（live2d-py / Cubism Core）は導入・初期化確認済みだが、"
                f" ライセンス確認済みのモデルassetが用意されるまで、佐藤の判断で"
                f" モデルを取得・同梱することはしていない（ASSET BLOCKED: model asset未取得）。"
            )

        # SDK初期化（モデルロード前に一度だけ必要）。
        if not Live2DRenderer._sdk_initialized:
            live2d.init()
            Live2DRenderer._sdk_initialized = True

        self._live2d = live2d
        self._model_path = model_path
        self._model = None  # live2d.v3.LAppModel()、実際のモデルロードは次段階
        self._started = False

    def start(self):
        # モデルasset入手後: self._live2d.glInit() → LAppModel().LoadModelJson(...)
        # → OpenGLウィンドウ確立、という流れになる想定。今回のスパイクでは
        # モデルasset未取得のため__init__で既に例外化しており、ここへは到達しない。
        raise NotImplementedError("[live2d_renderer] ASSET BLOCKED: 描画実装は次段階")

    def stop(self):
        self._started = False

    def set_audio_level(self, level: float):
        # モデルasset入手後: self._model.SetParameterValue(
        #     self._live2d.StandardParams.ParamMouthOpenY,
        #     audio_level_to_mouth_param(level)
        # ) という形になる想定（`StandardParams.ParamMouthOpenY`は実在確認済み）。
        raise NotImplementedError("[live2d_renderer] ASSET BLOCKED: 描画実装は次段階")

    def set_expression(self, name: str):
        pass  # 未実装（no-op許容、Renderer interfaceの規約通り）

    def set_motion(self, name: str):
        pass  # 未実装（no-op許容、Renderer interfaceの規約通り）
