"""
naru_video_hybrid_engine.py
==============================
NARU "動画ハイブリッド"方式のレンダリングエンジン。

Arc Handoff `2026-09-08_ARC_TO_SATO_NARU_VIDEO_HYBRID_PRODUCTION_ONE_SHOT_IMPLEMENTATION.md`
の実装。黒瀬 final pre-production gate（C1〜C4 CLOSED）を経て、ケイの
owner視認承認（v4「もう完璧と思うよ」）を得た設計をそのまま実装する。

設計思想（診断の結論）:
  crop+featherベースのoverlay_v1では、口だけを局所的に動かし顎・頬・髪・
  陰影を静止させたままにしていたため「貼り絵に見える」問題が生じた
  （2026-09-08診断Handoff参照）。動画ハイブリッドでは、これらを
  再計算せず、元Imagine動画がすでに持っている自然な連動をそのまま使う。

構成:
  - STANDBY      = 採用動画のframe0（canonicalとほぼ一致、実測diff 7.11/255）
                   をベースに、既存の瞬き・毛揺れ（`naru_face_fx`共有）を適用
  - SPEAKING_ARC = 自然な発話区間（frame48-144、約4.0秒@24fps）をそのまま
                   forward再生。顎・頬・髪・陰影の再計算はしない
  - SPEAKING_PAUSE = 口が落ち着いた自然な続きの映像（frame145-168、約1.0秒）。
                   静止画への切替ではなく、実際の続きの映像を使う
  - 発話継続中はARC→PAUSE→ARCを繰り返す。反転再生(reverse)は行わない
    （旧ping-pong設計はケイのREJECTを受けて破棄済み、production復活禁止）

瞬き・毛揺れは、動画自体が実際の自然な動きを持っているため、SPEAKING中は
適用しない（STANDBY時のみ）。二重に動きを足すと不自然になるリスクがある
ための判断。post-change evidenceで違和感が出れば見直す。
"""

import time
import threading

import cv2
import numpy as np

import naru_face_fx

VIDEO_FRAME_DIR = "live2d_assets/naru_v1_extraction/imagine_frames_native"
BASE_DIR = "live2d_assets/naru_v1_extraction"


def _imread_unicode(path, flags=cv2.IMREAD_COLOR):
    data = np.fromfile(path, dtype=np.uint8)
    return cv2.imdecode(data, flags)


class NaruVideoHybridEngine:
    """AvatarEngine/NaruOverlayEngineと同じ公開契約
    (start/stop/set_volume/set_speaking/_lock/_mouth_level)を満たす。
    """

    # [C1 gate] 顔領域diffゲート（矩形、canonical座標）。将来canonical更新時は
    # この領域・この測定方法で再計測し、閾値超過なら方式再判定へ戻す。
    FACE_REGION_BBOX = (390, 800, 370, 770)  # y0,y1,x0,x1
    FACE_DIFF_THRESHOLD = 8.0

    # [C3 v4 metadata] オーナー視認承認済み（"もう完璧と思うよ"）。
    # 反転再生(reverse_playback)は絶対に復活させない。
    SOURCE_FPS = 24
    PLAYBACK_FPS = 24
    STANDBY_FRAME = 1
    SPEECH_ARC_RANGE = (48, 144)   # inclusive
    PAUSE_RANGE = (145, 168)       # inclusive
    REVERSE_PLAYBACK = False

    EYE_CROP = (390, 670, 370, 770)
    HAIR_FRONT_OFFSET = (296, 340)
    EYE_LOCAL_CENTERS = [
        (100, 140, 55, 42),
        (280, 178, 55, 45),
    ]
    HAIR_SWAY_AMPLITUDE_PX = 2.0
    HAIR_SWAY_PERIOD_SEC = 4.2

    VOLUME_THRESHOLD_RISE = 0.05
    SILENT_LEVEL_THRESHOLD = 0.02

    BLINK_INTERVAL_MIN = 2.5
    BLINK_INTERVAL_MAX = 6.0
    BLINK_CLOSE_DURATION = 0.09
    BLINK_HOLD_DURATION = 0.03
    BLINK_OPEN_DURATION = 0.09

    def __init__(self):
        self._running = False
        self._thread = None
        self._lock = threading.Lock()

        self._raw_audio_level = 0.0
        self._mouth_level = 0
        self._start_time = time.time()

        self._next_blink_t = time.time() + np.random.uniform(
            self.BLINK_INTERVAL_MIN, self.BLINK_INTERVAL_MAX
        )
        self._blink_state = "idle"
        self._blink_phase_t = 0.0

        print("[NaruVideoHybridEngine] 動画素材読み込み中...")

        def load_frame(i):
            f = _imread_unicode(f"{VIDEO_FRAME_DIR}/kino_{i:03d}.png")
            if f is None:
                raise FileNotFoundError(f"video frame {i} が読み込めません")
            return f

        standby_raw = load_frame(self.STANDBY_FRAME)
        H, W = standby_raw.shape[0], standby_raw.shape[1]
        # canonical解像度(896x1344)へ合わせる。既存のEYE_CROP/HAIR_FRONT_OFFSET
        # 等はcanonical座標系のため、動画フレーム側をそちらへ合わせて統一する。
        self._canon_w, self._canon_h = 896, 1344

        def to_canon(img):
            return cv2.resize(img, (self._canon_w, self._canon_h), interpolation=cv2.INTER_LANCZOS4)

        self._standby_frame = to_canon(standby_raw)

        arc_start, arc_end = self.SPEECH_ARC_RANGE
        pause_start, pause_end = self.PAUSE_RANGE
        self._arc_frames = [to_canon(load_frame(i)) for i in range(arc_start, arc_end + 1)]
        self._pause_frames = [to_canon(load_frame(i)) for i in range(pause_start, pause_end + 1)]

        hair_front = cv2.imdecode(
            np.fromfile(f"{BASE_DIR}/HAIR_FRONT_overlay.png", dtype=np.uint8),
            cv2.IMREAD_UNCHANGED,
        )
        if hair_front is None or hair_front.shape[2] != 4:
            raise FileNotFoundError("HAIR_FRONT_overlay.png (BGRA) が読み込めません")
        self._hair_front = hair_front

        self._eye_mask = naru_face_fx.build_eye_mask(self.EYE_CROP, self.EYE_LOCAL_CENTERS, blur_kernel=21)

        print(f"[NaruVideoHybridEngine] STANDBY {self._canon_w}x{self._canon_h}px, "
              f"ARC frames={len(self._arc_frames)}, PAUSE frames={len(self._pause_frames)}")
        print("[NaruVideoHybridEngine] 初期化完了")

        # -- state machine --
        self._speak_state = "STANDBY"
        self._state_entered_t = time.time()

    # -- [C1 gate] 顔領域diff測定（再現可能な検証手順） --
    @classmethod
    def measure_face_diff(cls, canonical_img, candidate_frame0_img):
        """canonicalと候補frame0の顔領域(FACE_REGION_BBOX)平均BGR絶対差分を返す。
        戻り値 <= FACE_DIFF_THRESHOLD なら継続可、超過なら方式再判定。"""
        y0, y1, x0, x1 = cls.FACE_REGION_BBOX
        a = cv2.resize(canonical_img, (896, 1344))[y0:y1, x0:x1]
        b = cv2.resize(candidate_frame0_img, (896, 1344))[y0:y1, x0:x1]
        diff = cv2.absdiff(a, b)
        return float(diff.mean())

    # -- 公開API（LegacyFrameRenderer / RendererIsolationProxy 契約） --

    def start(self):
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
        from avatar_engine import WINDOW_TITLE, FPS

        cv2.namedWindow(WINDOW_TITLE, cv2.WINDOW_AUTOSIZE)
        interval = 1.0 / FPS

        while self._running:
            t_start = time.time()
            frame = self.compose_frame()
            cv2.imshow(WINDOW_TITLE, frame)

            key = cv2.waitKey(1) & 0xFF
            if key == 27:
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
        print("[NaruVideoHybridEngine] ウィンドウを閉じました")

    def set_volume(self, volume: float):
        with self._lock:
            self._raw_audio_level = max(0.0, min(1.0, volume))

    def set_speaking(self, is_speaking: bool):
        with self._lock:
            self._raw_audio_level = 0.3 if is_speaking else 0.0

    # -- 瞬き（STANDBYのみ適用） --

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

    # -- 状態遷移＋フレーム合成 --

    def compose_frame(self):
        now = time.time()
        with self._lock:
            level = self._raw_audio_level
        speaking = level > self.VOLUME_THRESHOLD_RISE

        if self._speak_state == "STANDBY":
            if speaking:
                self._speak_state = "SPEAKING_ARC"
                self._state_entered_t = now
            else:
                frame = self._standby_frame.copy()
                closeness = self._update_blink_state(now)
                naru_face_fx.squash_eye_crop(frame, self.EYE_CROP, self._eye_mask, closeness)
                naru_face_fx.composite_hair_front(
                    frame, self._hair_front, self.HAIR_FRONT_OFFSET,
                    now - self._start_time, self.HAIR_SWAY_AMPLITUDE_PX, self.HAIR_SWAY_PERIOD_SEC,
                )
                return frame

        if self._speak_state == "SPEAKING_ARC":
            elapsed = now - self._state_entered_t
            idx = int(elapsed * self.PLAYBACK_FPS)
            if idx >= len(self._arc_frames):
                self._speak_state = "SPEAKING_PAUSE"
                self._state_entered_t = now
                idx = 0
            else:
                return self._arc_frames[idx].copy()

        if self._speak_state == "SPEAKING_PAUSE":
            elapsed = now - self._state_entered_t
            idx = int(elapsed * self.PLAYBACK_FPS)
            if idx >= len(self._pause_frames):
                # pause完了時点でのみ継続/終了を判定する（承認済みstate machine通り）
                if speaking:
                    self._speak_state = "SPEAKING_ARC"
                    self._state_entered_t = now
                    return self._arc_frames[0].copy()
                else:
                    self._speak_state = "STANDBY"
                    self._state_entered_t = now
                    return self._standby_frame.copy()
            return self._pause_frames[idx].copy()

        # フォールバック（理論上到達しない）
        return self._standby_frame.copy()
