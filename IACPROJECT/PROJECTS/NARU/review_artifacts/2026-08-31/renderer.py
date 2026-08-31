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

    def __init__(self):
        from avatar_engine import AvatarEngine
        self._engine = AvatarEngine()

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
    """
    name = (name or os.getenv("NARU_RENDERER", "legacy")).strip().lower()

    if name == "legacy":
        return LegacyFrameRenderer()

    # 将来のLive2D/VRM renderer追加時はここへ分岐を足す。
    # 未知の名前を指定された場合はsilent fallbackせず明示的に落とす
    # （NARUのモデル設定健全化と同じ方針: 実在確認できないIDを黙って
    #   legacyへ差し替えたりしない）。
    raise ValueError(
        f"[renderer] 未知のNARU_RENDERER指定です: {name!r}. "
        f"現時点で利用可能なrendererは 'legacy' のみです。"
    )
