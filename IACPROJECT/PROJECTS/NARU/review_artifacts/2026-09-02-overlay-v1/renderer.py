"""
renderer.py
===========
NARU 表示層の境界（Renderer interface）。

目的:
  会話・TikTok受信・LLM・TTS・キュー・安全制御（app_live2d.py / voice_analyzer.py）
  は一切変更せず、アバター表示だけをいつでも差し替えられるようにする。

  現行の6枚フレーム切り替え方式（avatar_engine.AvatarEngine）は "legacy renderer"
  として LegacyFrameRenderer に包み、動作は変更しない（app_live2d.py / voice_analyzer.py
  からは今まで通り avatar_engine.set_volume(...) / .start() / .stop() が呼べる）。

  将来 Live2D/Cubism や VRM 等の新renderer を追加する場合は、Renderer を継承した
  クラスを作り、create_renderer() の分岐へ追加するだけでよい。app側の変更は不要。

ロールバック:
  何か問題が起きた場合、環境変数 NARU_RENDERER=legacy（既定値）のままにしておけば
  従来のAvatarEngine実装がそのまま使われる。renderer.py自体を経由しない直接の
  `from avatar_engine import AvatarEngine` も引き続き可能（avatar_engine.py は無変更）。
"""

import os


class Renderer:
    """
    Renderer interface。最低限の責務のみ定義する。

    実装クラスは以下を満たすこと:
      - set_expression() / set_motion() は対応していなければ no-op でよい
        （現行の6枚フレーム切り替え方式には表情・モーションの概念が無いため）
      - start()/stop() 以外のメソッドは、start() 前後どちらで呼ばれても例外を出さない
    """

    def start(self):
        raise NotImplementedError

    def stop(self):
        raise NotImplementedError

    def set_audio_level(self, level: float):
        """0.0〜1.0程度の音量レベルを渡す。口パク等の音声同期に使う。"""
        raise NotImplementedError

    def set_expression(self, name: str):
        """表情名を渡す。対応していないrendererは無視してよい（既定: no-op）。"""
        pass

    def set_motion(self, name: str):
        """モーション名を渡す。対応していないrendererは無視してよい（既定: no-op）。"""
        pass


class LegacyFrameRenderer(Renderer):
    """
    現行の6枚フレーム切り替え方式（avatar_engine.AvatarEngine）を Renderer interface
    へ包むアダプタ。AvatarEngine自体の実装・挙動は変更しない。

    後方互換のため set_volume() もそのまま公開する
    （voice_analyzer.py が avatar_engine.set_volume(...) を直接呼んでいるため、
    呼び出し側を一切変更せずに済む）。
    """

    def __init__(self, engine_class=None):
        # engine_class: 省略時は従来通りAvatarEngine。SmoothFrameRenderer等、
        # AvatarEngineと同じ公開API（start/stop/set_volume/set_speaking/
        # _mouth_level/_lock）を持つサブクラスであれば差し替えられる。
        if engine_class is None:
            from avatar_engine import AvatarEngine
            engine_class = AvatarEngine
        self._engine = engine_class()

    def start(self):
        self._engine.start()

    def stop(self):
        self._engine.stop()

    def set_audio_level(self, level: float):
        self._engine.set_volume(level)

    # ── 後方互換 API（voice_analyzer.py が直接呼ぶ） ──
    def set_volume(self, volume: float):
        self._engine.set_volume(volume)

    def set_speaking(self, is_speaking: bool):
        self._engine.set_speaking(is_speaking)

    def set_expression(self, name: str):
        pass  # legacy rendererは表情非対応（no-op）

    def set_motion(self, name: str):
        pass  # legacy rendererはモーション非対応（no-op）

    # ── デバッグ/テスト用（表示テストで内部状態を検証するために公開） ──
    def get_mouth_level(self) -> int:
        """現在の口パク状態を返す（0=closed, 1=half_open, 2=open）。テスト専用。"""
        with self._engine._lock:
            return self._engine._mouth_level


def create_renderer(name: str = None) -> Renderer:
    """
    Renderer factory。

    name省略時は環境変数 NARU_RENDERER を見る（未設定なら "legacy"）。
    既定は必ず legacy（安全側）。

    このfactory自体は失敗時にそのまま例外を送出する（テスト・プログラム的な
    利用のため明示的に落とす）。本番起動から使うのは create_isolated_renderer()
    の方（下記）で、そちらがfactory失敗も含めて隔離する。
    """
    name = (name or os.getenv("NARU_RENDERER", "legacy")).strip().lower()

    if name == "legacy":
        return LegacyFrameRenderer()

    if name in ("legacy_smooth", "smooth"):
        # [NARU interim native preview] 既存6枚素材のまま、口パクの連続化＋
        # ごく小さいidle swayを加えた版。legacyとは完全に別インスタンスなので
        # 選ばなければ何も変わらない（zero irreversible conversion）。
        from smooth_frame_renderer import SmoothFrameRenderer
        return LegacyFrameRenderer(engine_class=SmoothFrameRenderer)

    if name == "live2d":
        from live2d_renderer import Live2DRenderer
        return Live2DRenderer()

    if name in ("overlay_v1", "naru_overlay"):
        # [NARU-RENDERER-SWAP overlay route] 「重なり許容オーバーレイ」方式のv1実装候補。
        # Arc GO: 2026-09-01_ARC_TO_SATO_NARU_OVERLAY_ROUTE_V1_IMPLEMENTATION_GO.md
        # （commit 28d1a3b）。canonical解像度のNARU実素材（FACE + MOUTH4状態 +
        # 幾何学的blink + HAIR_FRONT独立オーバーレイ）を使う。live2dのような
        # ネイティブCubism SDK/.moc3経路ではなく、legacy_smoothと同じ
        # crop+feather合成アーキテクチャの上に構築している（.moc3はCubism Editor
        # という専用GUIでの手作業authoringが必要で、現状のツールでは生成できない）。
        from naru_overlay_engine import NaruOverlayEngine
        return LegacyFrameRenderer(engine_class=NaruOverlayEngine)

    # 将来の追加renderer向け。未知の名前はsilent fallbackせず明示的に落とす
    # （NARUのモデル設定健全化と同じ方針: 実在確認できないIDを黙って
    #   legacyへ差し替えたりしない）。
    raise ValueError(
        f"[renderer] 未知のNARU_RENDERER指定です: {name!r}. "
        f"現時点で利用可能なrendererは 'legacy' / 'legacy_smooth' / 'live2d' / 'overlay_v1' です。"
    )


class RendererIsolationProxy(Renderer):
    """
    [PHASE C0] Renderer失敗がNARU本体（LLM/TTS/queue）を巻き込まないための隔離層。

    実rendererへの全呼び出しをtry/exceptで包む。失敗した時点でoffline状態へ
    明示的に遷移し、以降の呼び出しはno-op（ただし毎回ログには残す）。
    - silent fallback（例: 失敗したら黙ってlegacyへ切り替える）はしない
    - 失敗は必ずログに残す（"failure is logged clearly"）
    - offline化してもNARU本体側（呼び出し元）へは例外を伝播させない
      （呼び出し元は今まで通り avatar_engine.set_volume(...) 等をそのまま呼べる）

    app_live2d.py からはこのクラスを経由して起動する
    （create_isolated_renderer() を使う）。
    """

    def __init__(self, name: str = None, renderer_instance: Renderer = None):
        self._real = None
        self._offline = False
        self._offline_reason = None
        self._offline_stage = None

        if renderer_instance is not None:
            # テスト用: factoryを経由せず既存のrendererインスタンスを直接包む
            self._real = renderer_instance
            return

        try:
            self._real = create_renderer(name)
        except Exception as e:
            self._mark_offline("factory", e)

    def _mark_offline(self, stage: str, exc: Exception):
        self._offline = True
        self._offline_stage = stage
        self._offline_reason = f"{type(exc).__name__}: {exc}"
        print(
            f"[RENDERER OFFLINE] stage={stage} により renderer を無効化しました。"
            f" NARU本体(LLM/TTS/queue)は継続します。詳細: {self._offline_reason}"
        )

    def _safe_call(self, stage: str, method_name: str, *args, **kwargs):
        # method_nameは文字列で受け取り、ここでgetattrする。
        # 呼び出し側で self._real.<method> のように直接属性アクセスすると、
        # self._real が None のケースで _safe_call の中身に入る前に
        # AttributeError が飛んでしまう（実際にこの実装で踏んだ）。
        if self._offline or self._real is None:
            return None
        try:
            fn = getattr(self._real, method_name, None)
            if fn is None:
                return None  # rendererがそのメソッドを実装していない（no-op許容）
            return fn(*args, **kwargs)
        except Exception as e:
            self._mark_offline(stage, e)
            return None

    @property
    def is_offline(self) -> bool:
        return self._offline

    @property
    def offline_reason(self):
        return self._offline_reason

    def start(self):
        self._safe_call("start", "start")

    def stop(self):
        self._safe_call("stop", "stop")

    def set_audio_level(self, level: float):
        self._safe_call("set_audio_level", "set_audio_level", level)

    # ── 後方互換 API。実rendererの set_volume ではなく、必ずこのproxy自身の
    #    set_audio_level を経由させる（将来のrendererがset_volumeを持たなくても
    #    proxy側で吸収できるようにするため）。 ──
    def set_volume(self, volume: float):
        self.set_audio_level(volume)

    def set_speaking(self, is_speaking: bool):
        self._safe_call("set_speaking", "set_speaking", is_speaking)

    def set_expression(self, name: str):
        self._safe_call("set_expression", "set_expression", name)

    def set_motion(self, name: str):
        self._safe_call("set_motion", "set_motion", name)


def create_isolated_renderer(name: str = None) -> RendererIsolationProxy:
    """
    [PHASE C0] 本番起動用のエントリポイント。
    factory失敗も含めてRendererIsolationProxyで包み、NARU本体を巻き込まない。
    """
    return RendererIsolationProxy(name=name)
