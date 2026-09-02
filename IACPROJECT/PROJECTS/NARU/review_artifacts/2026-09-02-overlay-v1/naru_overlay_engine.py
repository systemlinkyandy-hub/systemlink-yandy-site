"""
naru_overlay_engine.py
=======================
NARU v1 "重なり許容オーバーレイ" 方式のレンダリングエンジン。

Arc Handoff `2026-09-01_ARC_TO_SATO_NARU_OVERLAY_ROUTE_V1_IMPLEMENTATION_GO.md`
（commit 28d1a3b）の実装。canonical解像度(896x1344)のv1実素材を使う。

構成:
  - BASE       = naru_v1_shoulder_composited.png（肩補完済みcanonical、無加工）
  - MOUTH      = 4状態（closed=canonical自体 / light / medium / wide）を
                 クロップ+フェザーで連続クロスフェード合成
  - EYE (瞬き) = 別素材ではなく、既存の目クロップを幾何学的に垂直圧縮する
                 一次近似（前段Handoffで「次段階で検証予定」としていたもの）
  - HAIR_FRONT = 前髪の房クラスタのみ、独立した半透明オーバーレイとして
                 別レイヤー合成する（プログラム支援の手動トレース、
                 既存輪郭の抽出のみ、新規描画なし）。微小な独立揺れを
                 クロップ限定で加え、重なり許容レイヤーであることを実証する。

原則（smooth_frame_rendererから踏襲）:
  - 常に同一の固定BASEから毎フレーム合成し直す（差分の蓄積をさせない）
  - 変形・再サンプリングは各クロップ領域内に限定する（全画面warpAffineはしない）
"""

import time
import threading

import cv2
import numpy as np

BASE_DIR = "live2d_assets/naru_v1_extraction"


def _imread_unicode(path, flags=cv2.IMREAD_COLOR):
    data = np.fromfile(path, dtype=np.uint8)
    return cv2.imdecode(data, flags)


class NaruOverlayEngine:
    """AvatarEngineと同じ公開契約(start/stop/set_volume/set_speaking/_lock/_mouth_level)を満たす。
    継承はしない（AvatarEngine.__init__が旧avatar_frames/*.jpgを前提にしているため）。
    """

    MOUTH_CROP = (640, 820, 440, 690)   # canonical座標、口4状態を包む矩形（やや広め、フェザー用）
    EYE_CROP = (390, 670, 370, 770)     # canonical座標、両目を含む範囲（IMAGE_EDIT_PACKET_READY記載値）
    HAIR_FRONT_OFFSET = (296, 340)      # HAIR_FRONT_overlay.png の貼り付け原点 (y0, x0)

    VOLUME_THRESHOLD_RISE = 0.05
    VOLUME_THRESHOLD_FALL = 0.03
    VOLUME_OPEN_HIGH_RISE = 0.15
    VOLUME_OPEN_HIGH_FALL = 0.11
    MOUTH_CLOSE_DELAY = 0.15
    MOUTH_ATTACK = 0.35
    MOUTH_RELEASE = 0.20
    SILENT_LEVEL_THRESHOLD = 0.02

    BLINK_INTERVAL_MIN = 2.5
    BLINK_INTERVAL_MAX = 6.0
    BLINK_CLOSE_DURATION = 0.09
    BLINK_HOLD_DURATION = 0.03
    BLINK_OPEN_DURATION = 0.09

    HAIR_SWAY_AMPLITUDE_PX = 2.0
    HAIR_SWAY_PERIOD_SEC = 4.2

    def __init__(self):
        self._running = False
        self._thread = None
        self._lock = threading.Lock()

        self._raw_audio_level = 0.0
        self._displayed_level = 0.0
        self._mouth_level = 0
        self._last_sound_t = 0.0
        self._start_time = time.time()

        self._next_blink_t = time.time() + np.random.uniform(
            self.BLINK_INTERVAL_MIN, self.BLINK_INTERVAL_MAX
        )
        self._blink_state = "idle"
        self._blink_phase_t = 0.0

        print("[NaruOverlayEngine] v1素材読み込み中...")
        self._base = _imread_unicode(BASE_DIR + "/naru_v1_shoulder_composited.png")
        if self._base is None:
            raise FileNotFoundError("naru_v1_shoulder_composited.png が読み込めません")

        closed = _imread_unicode("resource/avatar.png")
        light = _imread_unicode(BASE_DIR + "/naru_v1_mouth_light_open.png")
        medium = _imread_unicode(BASE_DIR + "/naru_v1_mouth_medium_open.png")
        wide = _imread_unicode(BASE_DIR + "/naru_v1_mouth_wide_open.png")
        for name, im in [("closed", closed), ("light", light), ("medium", medium), ("wide", wide)]:
            if im is None:
                raise FileNotFoundError("mouth state '" + name + "' が読み込めません")
        self._mouth_states = [closed, light, medium, wide]

        hair_front = cv2.imdecode(
            np.fromfile(BASE_DIR + "/HAIR_FRONT_overlay.png", dtype=np.uint8),
            cv2.IMREAD_UNCHANGED,
        )
        if hair_front is None or hair_front.shape[2] != 4:
            raise FileNotFoundError("HAIR_FRONT_overlay.png (BGRA) が読み込めません")
        self._hair_front = hair_front

        self._mouth_mask = self._build_feather_mask(self.MOUTH_CROP)
        self._eye_mask = self._build_eye_mask(self.EYE_CROP)

        h, w = self._base.shape[:2]
        print("[NaruOverlayEngine] BASE size: " + str(w) + "x" + str(h) + "px, mouth states: "
              + str(len(self._mouth_states)) + ", HAIR_FRONT alpha px: "
              + str((hair_front[:, :, 3] > 0).sum()))
        print("[NaruOverlayEngine] 初期化完了")

    # [blink polish] 目クロップ内での、片目ずつの中心＋半径（クロップ内ローカル座標、px）。
    # グリッド重ね描画で目視特定（`eye_crop_grid.png`）。手前側の目はやや大きく、
    # 奥側（髪に隠れがちな方）はやや小さい半径にしてある。
    EYE_LOCAL_CENTERS = [
        (100, 140, 55, 42),   # 手前側の目: cx, cy, rx, ry
        (280, 178, 55, 45),   # 奥側の目
    ]

    @classmethod
    def _build_eye_mask(cls, crop):
        """目クロップ全体を覆う単一の大きな楕円だと、髪が密集する周辺領域まで
        フェザー帯に含んでしまい、圧縮画像と原画（どちらも斜め方向の細い毛束
        線画を持つ）を部分アルファで重ねた際にモアレ状のにじみが出ると判明した
        （実測で確認、修正済み）。目そのものの周りだけに絞った小さい楕円2つへ
        変更し、毛束が密集する領域をできるだけフェザー帯の外に置く。"""
        y0, y1, x0, x1 = crop
        h, w = y1 - y0, x1 - x0
        mask = np.zeros((h, w), dtype=np.float32)
        for cx, cy, rx, ry in cls.EYE_LOCAL_CENTERS:
            cv2.ellipse(mask, (cx, cy), (rx, ry), 0, 0, 360, 1.0, -1)
        mask = cv2.GaussianBlur(mask, (21, 21), 0)
        return mask[:, :, None]

    @staticmethod
    def _build_feather_mask(crop):
        y0, y1, x0, x1 = crop
        h, w = y1 - y0, x1 - x0
        mask = np.zeros((h, w), dtype=np.float32)
        center = (w // 2, h // 2)
        axes = (int(w * 0.46), int(h * 0.46))
        cv2.ellipse(mask, center, axes, 0, 0, 360, 1.0, -1)
        mask = cv2.GaussianBlur(mask, (35, 35), 0)
        return mask[:, :, None]

    # -- 公開API（LegacyFrameRenderer / RendererIsolationProxy 契約） --

    def start(self):
        """[FIX: 黒瀬レビュー指摘] 以前はここが空（`pass`）で、
        `compose_frame()`を定期的に呼んで画面へ出す描画駆動ループが
        どこにも存在しなかった。エラーは出ず`is_offline`もFalseのまま
        だが、実際には何も表示されないという不具合だった
        （`avatar_engine.AvatarEngine._run_cv2`と同じ構成で実装する）。"""
        if self._running:
            return
        self._running = True
        self._thread = threading.Thread(target=self._run_cv2, daemon=True)
        self._thread.start()

    def stop(self):
        self._running = False
        if self._thread:
            self._thread.join(timeout=2.0)

    def _run_cv2(self):
        """OpenCVウィンドウで`compose_frame()`を30fpsで描画するループ。
        `avatar_engine.AvatarEngine._run_cv2`と同じ構成（同じWINDOW_TITLEを
        使うため、OBS側のウィンドウキャプチャ設定を変えずにrenderer切替できる）。"""
        from avatar_engine import WINDOW_TITLE, FPS

        cv2.namedWindow(WINDOW_TITLE, cv2.WINDOW_AUTOSIZE)
        interval = 1.0 / FPS

        while self._running:
            t_start = time.time()

            frame = self.compose_frame()
            cv2.imshow(WINDOW_TITLE, frame)

            key = cv2.waitKey(1) & 0xFF
            if key == 27:  # ESC
                self._running = False
                break

            try:
                if cv2.getWindowProperty(WINDOW_TITLE, cv2.WND_PROP_VISIBLE) < 1:
                    self._running = False
                    break
            except Exception:
                pass

            elapsed = time.time() - t_start
            sleep_t = interval - elapsed
            if sleep_t > 0:
                time.sleep(sleep_t)

        cv2.destroyAllWindows()
        print("[NaruOverlayEngine] ウィンドウを閉じました")

    def set_volume(self, volume: float):
        with self._lock:
            self._raw_audio_level = max(0.0, min(1.0, volume))
            if volume > self.SILENT_LEVEL_THRESHOLD:
                self._last_sound_t = time.time()

    def set_speaking(self, is_speaking: bool):
        with self._lock:
            if is_speaking:
                self._raw_audio_level = max(self._raw_audio_level, 0.2)
                self._last_sound_t = time.time()
            else:
                self._raw_audio_level = 0.0

    # -- フレーム合成 --

    def _update_displayed_level(self):
        with self._lock:
            target = self._raw_audio_level
        rate = self.MOUTH_ATTACK if target > self._displayed_level else self.MOUTH_RELEASE
        self._displayed_level += (target - self._displayed_level) * rate
        return self._displayed_level

    def _blend_mouth_crop(self, level):
        y0, y1, x0, x1 = self.MOUTH_CROP
        segment = min(int(level * 3), 2)
        t = min(max(level * 3 - segment, 0.0), 1.0)
        a = self._mouth_states[segment][y0:y1, x0:x1]
        b = self._mouth_states[segment + 1][y0:y1, x0:x1]
        return cv2.addWeighted(a, 1.0 - t, b, t, 0.0)

    def _update_blink_state(self, now):
        if self._blink_state == "idle":
            if now >= self._next_blink_t:
                self._blink_state = "closing"
                self._blink_phase_t = now
            else:
                return 0.0
        if self._blink_state == "closing":
            t = (now - self._blink_phase_t) / self.BLINK_CLOSE_DURATION
            if t >= 1.0:
                self._blink_state = "held"
                self._blink_phase_t = now
                return 1.0
            return t
        if self._blink_state == "held":
            if now - self._blink_phase_t >= self.BLINK_HOLD_DURATION:
                self._blink_state = "opening"
                self._blink_phase_t = now
            return 1.0
        if self._blink_state == "opening":
            t = (now - self._blink_phase_t) / self.BLINK_OPEN_DURATION
            if t >= 1.0:
                self._blink_state = "idle"
                self._next_blink_t = now + np.random.uniform(
                    self.BLINK_INTERVAL_MIN, self.BLINK_INTERVAL_MAX
                )
                return 0.0
            return 1.0 - t
        return 0.0

    def _squash_eye_crop(self, base_frame, closeness):
        """目クロップ全体を縦方向に圧縮した版を作り、`_eye_mask`（片目ずつの
        小さい楕円フェザー、`_build_eye_mask`参照）でクロップ全体へ合成する。

        試行錯誤の経緯（3方式とも実測して不採用理由を確認済み）:
          1. 圧縮画像を元クロップの中央帯だけへ差し戻す方式
             → 差し戻し境界で「目が二重に見える」継ぎ目が発生（不採用）
          2. warpAffine一発での大幅縮小
             → 縮小率が大きい箇所でエイリアシング（縞模様）が発生（不採用）
          3. クロップ全体を覆う単一の大きな楕円マスクで(2)の縮小結果を合成
             → 髪が密集する周辺領域までフェザー帯に含み、圧縮画像と原画
               （どちらも斜め方向の細い毛束線画を持つ）を部分アルファで
               重ねた際にモアレ状のにじみが発生（不採用。アンシャープマスクで
               検証したところ悪化したため、単純なぼけでなく干渉縞と特定）
        現在の実装: 縮小前に軽いガウスぼかしでエイリアシングの種を減らし
        (2)を回避、マスクは片目ずつの小さい楕円に絞って毛束密集領域を
        フェザー帯の外へ出すことで(3)を回避している。
        """
        if closeness <= 0.001:
            return
        y0, y1, x0, x1 = self.EYE_CROP
        h, w = y1 - y0, x1 - x0
        src = base_frame[y0:y1, x0:x1]
        scale_y = max(0.10, 1.0 - closeness * 0.85)
        small_h = max(1, int(h * scale_y))
        # [blink polish] 当初は src をそのままINTER_AREAで縮小していたが、まつ毛・
        # 前髪の細い線画が持つ高周波成分が、縮小時にわずかなモアレ（格子状の
        # にじみ）を生んでいたと判明した（アンシャープマスクで強調すると悪化する
        # ことで裏付けられた＝アンシャープは逆効果だった）。縮小前に軽くガウス
        # ぼかしをかけて高周波成分を落としてから縮小することで、モアレの原因を
        # 元から減らす（一般的なダウンサンプリング前ローパスフィルタと同じ考え方）。
        prefiltered = cv2.GaussianBlur(src, (0, 0), 1.4)
        squashed_small = cv2.resize(prefiltered, (w, small_h), interpolation=cv2.INTER_AREA)
        squashed = cv2.resize(squashed_small, (w, h), interpolation=cv2.INTER_LINEAR)
        alpha = self._eye_mask * closeness
        composited = squashed.astype(np.float32) * alpha + src.astype(np.float32) * (1.0 - alpha)
        base_frame[y0:y1, x0:x1] = composited.astype(np.uint8)

    def _composite_hair_front(self, frame, t):
        y0, x0 = self.HAIR_FRONT_OFFSET
        h, w = self._hair_front.shape[:2]
        sway = self.HAIR_SWAY_AMPLITUDE_PX * np.sin(2 * np.pi * t / self.HAIR_SWAY_PERIOD_SEC)
        M = np.float32([[1, 0, sway], [0, 1, sway * 0.3]])
        shifted = cv2.warpAffine(
            self._hair_front, M, (w, h),
            flags=cv2.INTER_LINEAR, borderMode=cv2.BORDER_REPLICATE
        )
        color = shifted[:, :, :3].astype(np.float32)
        alpha = (shifted[:, :, 3:4].astype(np.float32)) / 255.0
        region = frame[y0:y0 + h, x0:x0 + w].astype(np.float32)
        frame[y0:y0 + h, x0:x0 + w] = (region * (1 - alpha) + color * alpha).astype(np.uint8)

    def compose_frame(self):
        """現在の状態から1フレーム合成して返す（呼び出し側がループ/描画/保存を担う）。"""
        now = time.time()
        frame = self._base.copy()

        level = self._update_displayed_level()
        if level > self.SILENT_LEVEL_THRESHOLD:
            blended_mouth = self._blend_mouth_crop(level)
            y0, y1, x0, x1 = self.MOUTH_CROP
            base_crop = frame[y0:y1, x0:x1].astype(np.float32)
            composited = blended_mouth.astype(np.float32) * self._mouth_mask + base_crop * (1.0 - self._mouth_mask)
            frame[y0:y1, x0:x1] = composited.astype(np.uint8)

        closeness = self._update_blink_state(now)
        self._squash_eye_crop(frame, closeness)

        self._composite_hair_front(frame, now - self._start_time)

        return frame
