"""
live2d_renderer.py
===================
[PHASE C1] Live2D/Cubism 技術スパイク用アダプタ。

現時点の状態: ASSET BLOCKED
  - `live2d-py` パッケージは未インストール（pip install live2d-py で導入可能。
    パッケージ自体はMIT、ただしCubism Core/Frameworkは別途Live2D公式サイトから
    ライセンス同意の上取得する必要がある別物）。
  - Live2Dモデルasset（.model3.json一式）はこのプロジェクトに存在しない。
  - Handoff指示（ARC_TO_SATO_NARU_RENDERER_PHASE_C0_C1.md）に従い、
    ライセンス確認できていないモデルassetを佐藤の判断で取得・同梱することはしない。
    また `live2d-py` 自体のインストール（Cubism Coreの取得を伴う）も、
    今回は佐藤の判断だけでは実行していない（ライセンス同意が絡むため）。

ここでは以下のみ実装・検証する:
  1. Renderer interfaceとの接続点（このクラス自体の形）
  2. 音量→Cubismパラメータのマッピングロジック（SDK不要、純粋関数として検証可能）
  3. SDK/asset欠如時に明確な例外で失敗する構造
     （Phase C0のisolation proxyが正しく隔離できることを確認済み）

実際の描画・SDK接続は、ライセンス確認済みのモデルassetとlive2d-pyインストールの
判断がついてから次段階で実装する。
"""

import os


def audio_level_to_mouth_param(level: float) -> float:
    """
    0.0〜1.0程度のaudio levelを、Cubism標準パラメータ ParamMouthOpenY相当
    （0.0=閉, 1.0=全開）へ線形マッピングする。

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

    現状: コンストラクタの時点でASSET BLOCKEDとして明確な例外を出す。
    renderer.create_renderer("live2d") 経由で呼ばれた場合、
    RendererIsolationProxy がこの例外を捕捉し、NARU本体を巻き込まずに
    offlineへ遷移する（Phase C0で検証済みの経路）。
    """

    MODEL_PATH_ENV = "NARU_LIVE2D_MODEL_PATH"

    def __init__(self):
        try:
            import live2d.v3 as live2d  # noqa: F401  (live2d-py, Cubism 3/4系)
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
                f" ライセンス確認済みのモデルassetが用意されるまで、佐藤の判断で"
                f" モデルを取得・同梱することはしていない（ASSET BLOCKED: model asset未取得）。"
            )

        # ここから先（ウィンドウ/OpenGLコンテキスト初期化、モデルロード）は
        # SDK・asset両方が揃ってから実装する。今回のスパイクでは到達しない。
        self._model_path = model_path
        self._started = False

    def start(self):
        raise NotImplementedError("[live2d_renderer] ASSET BLOCKED: 描画実装は次段階")

    def stop(self):
        self._started = False

    def set_audio_level(self, level: float):
        raise NotImplementedError("[live2d_renderer] ASSET BLOCKED: 描画実装は次段階")

    def set_expression(self, name: str):
        pass  # 未実装（no-op許容、Renderer interfaceの規約通り）

    def set_motion(self, name: str):
        pass  # 未実装（no-op許容、Renderer interfaceの規約通り）
