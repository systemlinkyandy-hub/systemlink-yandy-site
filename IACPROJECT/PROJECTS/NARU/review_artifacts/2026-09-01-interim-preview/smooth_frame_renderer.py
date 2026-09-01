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

[v2 修正: 全画面ブレンド → 口のみクロップ+フェザーブレンドへ]
  v1は「口以外のピクセルは全フレームで完全一致する」という
  avatar_engine.py内のコメントを前提に、フレーム全体をcv2.addWeighted()
  していた。しかし実測したところ、6枚は個別JPEGとして書き出されているため
  口以外の領域（背景の葉・服の柄など）にも無視できない差分があることが
  判明した（例: mouth_closed.jpg と mouth_open.jpg の背景領域だけでも
  平均差分が約9〜20あり、フレーム全体をブレンドすると口と無関係な部分まで
  毎フレーム揺らめいて見えた。実際にケイが見て「痙攣のよう」と表現した
  不具合の原因）。

  v2では口の実座標範囲（差分の連結成分解析＋目視で特定）だけを切り出して
  ブレンドし、楕円形+ガウスぼかしのフェザーマスクで境界を馴染ませた上で、
  **常に同じ1枚（mouth_closed.jpg）を土台**として貼り戻す。土台が常に同一
  ファイルの画素であるため、口のクロップ領域の外側は原理的に一切変化しない
  （「差分が小さいはず」という期待値ではなく、構造的にゼロを保証する）。

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

    # 口の実座標範囲（y0, y1, x0, x1）。差分の連結成分解析＋目視で特定した、
    # 3状態すべての口の形を収める最小限の矩形。
    MOUTH_CROP = (300, 420, 200, 370)

    def __init__(self):
        super().__init__()
        self._raw_audio_level = 0.0
        self._start_time = time.time()
        self._mouth_mask = self._build_mouth_mask()

    def _build_mouth_mask(self) -> np.ndarray:
        """
        口クロップ領域用のフェザーマスク（楕円+ガウスぼかし、0.0〜1.0）。
        境界を滑らかにし、貼り戻した跡が矩形として見えないようにする。
        """
        y0, y1, x0, x1 = self.MOUTH_CROP
        h, w = y1 - y0, x1 - x0
        mask = np.zeros((h, w), dtype=np.float32)
        center = (w // 2, h // 2)
        axes = (int(w * 0.42), int(h * 0.42))
        cv2.ellipse(mask, center, axes, 0, 0, 360, 1.0, -1)
        mask = cv2.GaussianBlur(mask, (25, 25), 0)
        return mask[:, :, None]  # チャンネル方向へブロードキャストできる形にする

    def set_volume(self, volume: float):
        # 離散ヒステリシス状態(self._mouth_level)は瞬き優先判定等、親クラスの
        # 他ロジックが参照する可能性があるため引き続き更新する。
        # 連続値は口パクのクロスフェードにのみ使う。
        with self._lock:
            self._raw_audio_level = max(0.0, min(1.0, volume))
        super().set_volume(volume)

    def _blend_mouth_crop(self, level: float) -> np.ndarray:
        """
        0.0〜1.0の連続値を [closed -> half_open -> open] の2区間クロスフェードへ
        変換する。口クロップ領域だけを対象にする（既存3枚以外の新しい画素は
        生成しない、重み付き合成のみ）。
        """
        y0, y1, x0, x1 = self.MOUTH_CROP
        if level <= 0.5:
            t = level / 0.5
            a = self._mouth_frames[0][y0:y1, x0:x1]
            b = self._mouth_frames[1][y0:y1, x0:x1]
        else:
            t = (level - 0.5) / 0.5
            a = self._mouth_frames[1][y0:y1, x0:x1]
            b = self._mouth_frames[2][y0:y1, x0:x1]
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
            frame = self._eye_frames[eye_idx].copy()
        else:
            with self._lock:
                level = self._raw_audio_level

            # 土台は常に同一ファイル(mouth_closed.jpg)の画素にする。
            # これにより口クロップ領域の外側は原理的に一切変化しない。
            frame = self._mouth_frames[0].copy()

            if level > self.SILENT_LEVEL_THRESHOLD:
                y0, y1, x0, x1 = self.MOUTH_CROP
                blended_crop = self._blend_mouth_crop(level).astype(np.float32)
                base_crop = frame[y0:y1, x0:x1].astype(np.float32)
                mask = self._mouth_mask
                composited = blended_crop * mask + base_crop * (1.0 - mask)
                frame[y0:y1, x0:x1] = composited.astype(np.uint8)

        dx, dy = self._idle_sway_offset(time.time())
        m = np.float32([[1, 0, dx], [0, 1, dy]])
        frame = cv2.warpAffine(
            frame, m, (frame.shape[1], frame.shape[0]), borderMode=cv2.BORDER_REPLICATE
        )
        return frame
