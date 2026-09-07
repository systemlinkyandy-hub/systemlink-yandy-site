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

    # [mouth composite rework 2026-09-07] オーナー目視でREJECT
    # （`2026-09-07_ARC_TO_SATO_NARU_OWNER_REJECT_MOUTH_COMPOSITE_REWORK.md`、
    # commit 4bf5a0e）。前回のLAB色補正+タイトクロップ+sigmoid遷移では、
    # 発話時に鼻先・人中まで形が潰れる、口が二重に見える、という指摘が残った。
    #
    # 根本原因（グリッド目視で実測）:
    #   - canonicalの鼻孔ハイライトはy≈685、鼻の下端はy≈700-710、上唇はy≈725から。
    #     旧MOUTH_CROPの上端(y=665)は鼻孔より上まで含んでおり、light/medium/wide
    #     素材側のわずかな鼻周辺シェーディング差までクロスフェード対象に
    #     入ってしまっていた（これが「鼻が潰れる」の直接原因）。
    #   - 矩形crop全体を addWeighted で線形クロスフェードしていたため、形の異なる
    #     2つの口輪郭が同時に見える「二重像」区間が、矩形の全域で発生していた。
    #
    # 対策:
    #   1. MOUTH_REGIONの上端を鼻孔・人中より確実に下(y=715)へ固定する。
    #      これより上のcanonical画素は、どの発話状態でも一切変更しない
    #      （compose_frame()で物理的に触れない領域として保証する）。
    #   2. 矩形全体を均一に混ぜるのではなく、各状態ごとに「closedとの実差分」から
    #      口の形そのものに沿ったソフトアルファマスクを作る（`_build_mouth_alpha`）。
    #      口以外の周辺画素はアルファ0のため触れられない。二重像は口の実形状の
    #      重なり部分だけに縮小される。
    MOUTH_REGION = (715, 800, 445, 670)   # canonical座標。この矩形の外は絶対に変更しない
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

        # [mouth composite rework 2026-09-07] light/medium/wideは口の開閉差分を別途
        # 抽出した素材系列（closed=canonical本体とは別系列）で、MOUTH_REGION範囲内の
        # LAB輝度がcanonicalより暗く、周辺スキンとの混色域で色が浮いて見えていた。
        # closedを基準にLAB空間で色統計（平均・分散）を一致させ、あわせて軽い
        # アンシャープマスクでクロスフェード・フェザーにより甘くなった口線の
        # コントラストを復元する。初期化時に1回だけ計算してキャッシュする。
        light = self._match_and_sharpen(light, closed, self.MOUTH_REGION)
        medium = self._match_and_sharpen(medium, closed, self.MOUTH_REGION)
        wide = self._match_and_sharpen(wide, closed, self.MOUTH_REGION)
        self._mouth_states = [closed, light, medium, wide]

        # [mouth composite rework 2026-09-07] 各状態ごとに、closedとの実差分から
        # 口の形そのものに沿ったソフトアルファマスクを作る。MOUTH_REGIONの外、
        # および実差分が無い（=鼻・頬など無関係な）画素はアルファ0になるため、
        # 矩形全体を均一に混ぜていた旧方式と違い、鼻・人中には構造的に触れない。
        zero_alpha = np.zeros(
            (self.MOUTH_REGION[1] - self.MOUTH_REGION[0],
             self.MOUTH_REGION[3] - self.MOUTH_REGION[2]), dtype=np.float32
        )[:, :, None]
        self._mouth_alphas = [
            zero_alpha,
            self._build_mouth_alpha(light, closed, self.MOUTH_REGION),
            self._build_mouth_alpha(medium, closed, self.MOUTH_REGION),
            self._build_mouth_alpha(wide, closed, self.MOUTH_REGION),
        ]

        hair_front = cv2.imdecode(
            np.fromfile(BASE_DIR + "/HAIR_FRONT_overlay.png", dtype=np.uint8),
            cv2.IMREAD_UNCHANGED,
        )
        if hair_front is None or hair_front.shape[2] != 4:
            raise FileNotFoundError("HAIR_FRONT_overlay.png (BGRA) が読み込めません")
        self._hair_front = hair_front

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
    def _match_and_sharpen(src, ref, crop):
        """srcの[crop]領域の色統計(LAB平均・分散)をrefの同領域に合わせ、
        続けて軽いアンシャープマスクで線のコントラストを復元する。
        srcの他の領域には影響しない範囲の局所補正（画像全体には
        同じ線形変換を一括適用するが、統計はcrop領域だけで計算する）。"""
        y0, y1, x0, x1 = crop
        src_lab = cv2.cvtColor(src, cv2.COLOR_BGR2LAB).astype(np.float32)
        ref_lab = cv2.cvtColor(ref, cv2.COLOR_BGR2LAB).astype(np.float32)
        src_mean = src_lab[y0:y1, x0:x1].reshape(-1, 3).mean(axis=0)
        src_std = src_lab[y0:y1, x0:x1].reshape(-1, 3).std(axis=0)
        ref_mean = ref_lab[y0:y1, x0:x1].reshape(-1, 3).mean(axis=0)
        ref_std = ref_lab[y0:y1, x0:x1].reshape(-1, 3).std(axis=0)
        corrected_lab = (src_lab - src_mean) * (ref_std / np.maximum(src_std, 1e-3)) + ref_mean
        corrected_lab = np.clip(corrected_lab, 0, 255).astype(np.uint8)
        corrected = cv2.cvtColor(corrected_lab, cv2.COLOR_LAB2BGR)

        blurred = cv2.GaussianBlur(corrected, (0, 0), 1.0)
        sharpened = cv2.addWeighted(corrected, 1.8, blurred, -0.8, 0)
        return sharpened

    @staticmethod
    def _build_mouth_alpha(state_img, closed_img, region):
        """[mouth composite rework 2026-09-07] closedとの実差分から、口の形に沿った
        ソフトアルファマスクを作る。region矩形は「これより外は絶対に触らない」という
        ハード境界（鼻孔・人中より確実に下）。矩形内でも、実際に差がある画素
        （＝口そのもの）だけがアルファを持ち、頬・顎など無関係な画素はアルファ0のまま
        残る。均一な楕円フェザーで矩形全体を混ぜていた旧方式との違いはここ。"""
        y0, y1, x0, x1 = region
        diff = cv2.absdiff(state_img[y0:y1, x0:x1], closed_img[y0:y1, x0:x1])
        gray = cv2.cvtColor(diff, cv2.COLOR_BGR2GRAY).astype(np.float32)
        alpha = np.clip((gray - 6.0) / 30.0, 0.0, 1.0)
        alpha_u8 = (alpha * 255).astype(np.uint8)
        alpha_u8 = cv2.morphologyEx(alpha_u8, cv2.MORPH_OPEN, np.ones((3, 3), np.uint8))
        alpha_u8 = cv2.morphologyEx(alpha_u8, cv2.MORPH_CLOSE, np.ones((5, 5), np.uint8))
        alpha_soft = cv2.GaussianBlur(alpha_u8, (9, 9), 0).astype(np.float32) / 255.0
        return alpha_soft[:, :, None]

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
        """MOUTH_REGION内の(blended_pixels, combined_alpha)を返す。
        [mouth composite rework 2026-09-07] 旧方式は矩形全体を均一な楕円フェザーで
        混ぜていたため、鼻・頬など無関係な画素まで変化して見えた。新方式では、
        各状態固有の形状アルファ（`_build_mouth_alpha`、鼻より確実に下でのみ
        非ゼロ）をtで補間して使う。アルファがゼロの画素（鼻・頬など）は、
        どのtでも合成後にBASEの画素と完全に一致する（後段のcompose_frameで
        alpha乗算するため）。"""
        y0, y1, x0, x1 = self.MOUTH_REGION
        segment = min(int(level * 3), 2)
        t = min(max(level * 3 - segment, 0.0), 1.0)
        # [mouth polish 2026-09-07] 形の異なる口2状態を線形クロスフェードすると、
        # t≈0.5付近で両方の輪郭線が同時に薄く見える「二重像」区間が生じる。
        # t=0.5を中心にシグモイドで急峻化し、二重像区間を通過する時間を短くする。
        t = 1.0 / (1.0 + np.exp(-8.0 * (t - 0.5)))
        a = self._mouth_states[segment][y0:y1, x0:x1]
        b = self._mouth_states[segment + 1][y0:y1, x0:x1]
        blended = cv2.addWeighted(a, 1.0 - t, b, t, 0.0)
        alpha = self._mouth_alphas[segment] * (1.0 - t) + self._mouth_alphas[segment + 1] * t
        return blended, alpha

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
            blended_mouth, mouth_alpha = self._blend_mouth_crop(level)
            y0, y1, x0, x1 = self.MOUTH_REGION
            base_crop = frame[y0:y1, x0:x1].astype(np.float32)
            composited = blended_mouth.astype(np.float32) * mouth_alpha + base_crop * (1.0 - mouth_alpha)
            frame[y0:y1, x0:x1] = composited.astype(np.uint8)

        closeness = self._update_blink_state(now)
        self._squash_eye_crop(frame, closeness)

        self._composite_hair_front(frame, now - self._start_time)

        return frame
