"""
smooth_frame_renderer.py
=========================
[NARU interim native preview] 既存6枚素材のまま、口パクを離散3段階から
連続クロスフェードへ、ごく小さいidle sway（呼吸のような微小な揺れ）を追加する。

方針:
  - `avatar_engine.AvatarEngine` を継承する。フレーム読込・瞬きの状態機械・
    ウィンドウ描画ループ（`_run_cv2`）は一切変更せずそのまま使う。
  - オーバーライドするのは `_compose_frame()`（口パク合成方法）と
    `set_volume()`（量子化前の連続値も保持する）だけ。
  - **完全に可逆**: このクラスを使わなければ（`NARU_RENDERER=legacy`のまま）
    従来のAvatarEngineの挙動と1バイトも変わらない。既存の6枚のjpgファイル自体
    も一切加工しない（読み込むだけ）。
  - キャラクターの描き直し・再解釈はしていない。同じ6枚の画素をブレンド・
    平行移動するだけで、新しい絵は一切生成していない。

口パクの連続化:
  既存の mouth_closed / mouth_half_open / mouth_open は「同じ構図・同じ解像度で
  口の部分だけが違う」設計（avatar_engine.py内のコメント通り、全フレームが
  ピクセル単位で一致する）。したがって、2枚をそのまま `cv2.addWeighted` で
  合成すると、口の領域だけが自然に混ざる（他の領域は元々同一画素なので
  合成しても変化しない）。

idle sway:
  数px程度のごく小さい並進のみ（回転・拡大縮小は誇張されやすいため使わない）。
  ナルの落ち着いたキャラクター性を壊さない範囲に留める。
"""

import math
import time

import cv2
import numpy as np

from avatar_engine import AvatarEngine


class SmoothFrameRenderer(AvatarEngine):
    # ごく小さい揺れ（px）。誇張しない。
    IDLE_SWAY_AMPLITUDE_PX = 2.5
    IDLE_SWAY_PERIOD_SEC = 5.0  # 呼吸のようなゆっくりした周期

    # この値以下の音量は「無音」とみなし、mouth_closed相当の合成コストを省く
    SILENT_LEVEL_THRESHOLD = 0.02

    def __init__(self):
        super().__init__()
        self._raw_audio_level = 0.0
        self._start_time = time.time()

    def set_volume(self, volume: float):
        # 離散ヒステリシス状態(self._mouth_level)は瞬き優先判定等、親クラスの
        # 他ロジックが参照する可能性があるため引き続き更新する。
        # 連続値は口パクのクロスフェードにのみ使う。
        with self._lock:
            self._raw_audio_level = max(0.0, min(1.0, volume))
        super().set_volume(volume)

    def _blend_mouth_frame(self, level: float) -> np.ndarray:
        """
        0.0〜1.0の連続値を [closed -> half_open -> open] の2区間クロスフェードへ
        変換する。既存3枚以外の新しい画素は生成しない（重み付き合成のみ）。
        """
        if level <= 0.5:
            t = level / 0.5
            a, b = self._mouth_frames[0], self._mouth_frames[1]
        else:
            t = (level - 0.5) / 0.5
            a, b = self._mouth_frames[1], self._mouth_frames[2]
        return cv2.addWeighted(a, 1.0 - t, b, t, 0.0)

    def _idle_sway_offset(self, now: float):
        phase = (now - self._start_time) / self.IDLE_SWAY_PERIOD_SEC * 2 * math.pi
        dx = self.IDLE_SWAY_AMPLITUDE_PX * math.sin(phase)
        dy = (self.IDLE_SWAY_AMPLITUDE_PX * 0.5) * math.sin(phase * 0.5)
        return dx, dy

    def _compose_frame(self, eye_idx: int, mouth_idx: int) -> np.ndarray:
        # 瞬き中は親クラスと同じ優先ルール（口パクは一時的に無視）を維持する。
        # 瞬きの品質・タイミングは今回変更しない（要求通り）。
        if eye_idx >= 0:
            frame = self._eye_frames[eye_idx]
        else:
            with self._lock:
                level = self._raw_audio_level
            if level > self.SILENT_LEVEL_THRESHOLD:
                frame = self._blend_mouth_frame(level)
            else:
                # 無音時はeye_open.jpgを使う（親クラスの元の挙動と同じ。
                # mouth_closed.jpgより位置が正確、という既存コメントに準拠）。
                frame = self._eye_frames[2]

        dx, dy = self._idle_sway_offset(time.time())
        m = np.float32([[1, 0, dx], [0, 1, dy]])
        frame = cv2.warpAffine(
            frame, m, (frame.shape[1], frame.shape[0]), borderMode=cv2.BORDER_REPLICATE
        )
        return frame
