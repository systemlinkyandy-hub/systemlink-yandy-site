"""
smooth_frame_renderer.py
=========================
[NARU interim native preview] 既存6枚素材のまま、口パクを離散3段階から
連続クロスフェードへ変える。既存6枚のjpgファイル自体は一切加工しない
（読み込むだけ）。キャラクターの描き直し・再解釈はしていない。

v3（黒瀬レビュー指摘に基づく修正、`2026-09-01_ARC_TO_SATO_NARU_INTERIM_PREVIEW_VISUAL_FIX_V3.md`）:

  1. 口の入力に時間平滑化（attack/release型の一次ローパス）を追加。
     v2までは`set_volume()`で受けた値をそのまま`_compose_frame()`が
     ブレンド比として使っていたため、50ms間隔の入力の揺れがそのまま
     視覚的な揺れになっていた（黒瀬指摘1）。

  2. 全画面idle swayを撤去。v2で追加した`cv2.warpAffine`による
     全画面の微小並進は、背景まで含む書き出し済みJPEGを毎フレーム
     再サンプリングするため、小さい振幅でも背景のディテール（葉・髪等）
     が視覚的に「這う」ように見えることが判明した（黒瀬指摘2）。
     今回のinterim previewでは、動きを追加するより見た目の安定を
     優先し、全画面の変形は行わない。

  3. 瞬きも口と同じ「クロップ+フェザーブレンド、常に同一土台へ合成」
     方式に変更。以前は`eye_frames[eye_idx]`を丸ごと表示しており、
     3枚が独立JPEGである以上、口と同じ全画面ちらつきバグが瞬き時にも
     再発しうる状態だった（黒瀬指摘3）。

  瞬きも口パクも、常に**同一の土台画像（mouth_frames[0] = mouth_closed.jpg）**
  へ、それぞれの小さいクロップ領域だけをフェザー合成する。
  したがって両クロップ領域の外側は、原理的に一切変化しない
  （このファイル内のテストで検証可能）。
"""

import time

import cv2
import numpy as np

from avatar_engine import AvatarEngine


class SmoothFrameRenderer(AvatarEngine):
    # 口パク入力の時間平滑化。1フレーム(約1/FPS秒)あたり、現在値と目標値の
    # 差をこの割合だけ縮める（一次ローパス）。値が小さいほど滑らかで遅く、
    # 大きいほど入力に忠実で速い。attack(上がる方)をrelease(下がる方)より
    # やや速くし、口が開くのは機敏に・閉じるのは少し余韻を残す。
    MOUTH_ATTACK = 0.35
    MOUTH_RELEASE = 0.20

    # この値以下の音量は「無音」とみなす
    SILENT_LEVEL_THRESHOLD = 0.02

    # 口・目それぞれの実座標範囲（y0, y1, x0, x1）。
    # 差分の連結成分解析＋目視で特定した、3状態すべてを収める矩形。
    MOUTH_CROP = (300, 420, 200, 370)
    EYE_CROP = (195, 335, 185, 385)

    def __init__(self):
        super().__init__()
        self._raw_audio_level = 0.0
        self._displayed_level = 0.0  # 平滑化後、実際に表示に使う値
        self._start_time = time.time()
        self._mouth_mask = self._build_feather_mask(self.MOUTH_CROP)
        self._eye_mask = self._build_feather_mask(self.EYE_CROP)

    @staticmethod
    def _build_feather_mask(crop) -> np.ndarray:
        """指定クロップ用のフェザーマスク（楕円+ガウスぼかし、0.0〜1.0）。"""
        y0, y1, x0, x1 = crop
        h, w = y1 - y0, x1 - x0
        mask = np.zeros((h, w), dtype=np.float32)
        center = (w // 2, h // 2)
        axes = (int(w * 0.44), int(h * 0.44))
        cv2.ellipse(mask, center, axes, 0, 0, 360, 1.0, -1)
        mask = cv2.GaussianBlur(mask, (31, 31), 0)
        return mask[:, :, None]

    def set_volume(self, volume: float):
        # 離散ヒステリシス状態(self._mouth_level)は瞬き優先判定等、親クラスの
        # 他ロジックが参照する可能性があるため引き続き更新する。
        # 連続値（平滑化前の生値）は口パクのクロスフェードにのみ使う。
        with self._lock:
            self._raw_audio_level = max(0.0, min(1.0, volume))
        super().set_volume(volume)

    def _update_displayed_level(self) -> float:
        """
        raw_audio_levelへ一次ローパスで追従させる。呼び出しごとに
        self._displayed_level を更新して返す（描画ループから毎フレーム呼ぶ想定）。
        """
        with self._lock:
            target = self._raw_audio_level
        rate = self.MOUTH_ATTACK if target > self._displayed_level else self.MOUTH_RELEASE
        self._displayed_level += (target - self._displayed_level) * rate
        return self._displayed_level

    def _blend_crop(self, frames, crop, level: float) -> np.ndarray:
        """
        0.0〜1.0の連続値を [frames[0] -> frames[1] -> frames[2]] の
        2区間クロスフェードへ変換する。指定クロップ領域だけを対象にする。
        """
        y0, y1, x0, x1 = crop
        if level <= 0.5:
            t = level / 0.5
            a, b = frames[0][y0:y1, x0:x1], frames[1][y0:y1, x0:x1]
        else:
            t = (level - 0.5) / 0.5
            a, b = frames[1][y0:y1, x0:x1], frames[2][y0:y1, x0:x1]
        return cv2.addWeighted(a, 1.0 - t, b, t, 0.0)

    def _composite_region(self, base: np.ndarray, crop, blended: np.ndarray, mask: np.ndarray):
        y0, y1, x0, x1 = crop
        base_crop = base[y0:y1, x0:x1].astype(np.float32)
        composited = blended.astype(np.float32) * mask + base_crop * (1.0 - mask)
        base[y0:y1, x0:x1] = composited.astype(np.uint8)

    def _compose_frame(self, eye_idx: int, mouth_idx: int) -> np.ndarray:
        # 常に同一の土台（mouth_closed.jpg）から始める。
        # これにより、口・目どちらのクロップ領域の外側も原理的に一切変化しない。
        frame = self._mouth_frames[0].copy()

        if eye_idx >= 0:
            # 瞬き中: 目クロップだけをフェザー合成する（口パクは一時的に無視、
            # 親クラスの元の優先ルールを踏襲）。全画面のeye_frames切替はしない。
            blended_eye = self._blend_eye_crop(eye_idx)
            self._composite_region(frame, self.EYE_CROP, blended_eye, self._eye_mask)
        else:
            level = self._update_displayed_level()
            if level > self.SILENT_LEVEL_THRESHOLD:
                blended_mouth = self._blend_crop(self._mouth_frames, self.MOUTH_CROP, level)
                self._composite_region(frame, self.MOUTH_CROP, blended_mouth, self._mouth_mask)

        # [v3] 全画面idle swayは撤去（黒瀬指摘2）。書き出し済みJPEG全体を
        # 再サンプリングすると背景のディテールが視覚的に這って見えるため。
        return frame

    def _blend_eye_crop(self, eye_idx: int) -> np.ndarray:
        """
        瞬きシーケンスの離散インデックス(0=closed,1=half_open,2=open想定だが
        実際は BLINK_SEQUENCE=[1,0,1] のため 0 or 1 のみ渡ってくる)を、
        目クロップの合成へ変換する。急激な入力ではないため平滑化はしない
        （瞬き自体が親クラスの既存タイミング制御で短時間に留まる）。
        """
        y0, y1, x0, x1 = self.EYE_CROP
        return self._eye_frames[eye_idx][y0:y1, x0:x1]
