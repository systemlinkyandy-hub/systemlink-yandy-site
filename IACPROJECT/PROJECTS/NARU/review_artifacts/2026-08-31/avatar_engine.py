"""
avatar_engine.py  ―  フレーム切り替え方式 Live2D エンジン
================================================================
【設計方針】
  ユーザー提供の 6 枚フル画像をそのままフレームとして使用する。
  パーツ合成・座標計算は一切行わず、画像を丸ごと切り替えることで
  位置ズレ・色ズレ・境界線の問題をゼロにする。

【使用フレーム】 (avatar_frames/ フォルダ内)
  目アニメーション（瞬き）:
    eye_closed.jpg → eye_half_open.jpg → eye_closed.jpg
    (eye_open.jpg は通常状態と位置が異なるため瞬きには使用しない)

  口アニメーション（口パク）:
    mouth_closed.jpg → mouth_half_open.jpg → mouth_open.jpg
    → mouth_half_open.jpg → mouth_closed.jpg

【合成ルール】
  ベース = mouth_closed.jpg（通常時・目が開いた状態）
  瞬き中 = eye_xxx.jpg をフル画像で表示（口の状態は維持）
  口パク中 = mouth_xxx.jpg をフル画像で表示（目の状態は維持）

  ※ 全フレームが同じ構図・同じ解像度（448×672px）のため
     ピクセル単位で完全に一致する。座標計算不要。

【スレッド構成】
  メインスレッド : OpenCV ウィンドウ描画（30fps）
  サブスレッド   : volume.txt 監視 → 口パク状態更新
"""

import os
import time
import math
import random
import threading
from pathlib import Path

import cv2
import numpy as np
from PIL import Image

# ─────────────────────────────────────────────
#  パス定義
# ─────────────────────────────────────────────
BASE_DIR    = Path(__file__).parent
FRAMES_DIR  = BASE_DIR / "avatar_frames"
VOLUME_FILE = BASE_DIR / "output" / "volume.txt"

# ─────────────────────────────────────────────
#  表示設定
# ─────────────────────────────────────────────
DISPLAY_SCALE = 1.0    # 1.0 = 448×672px そのまま（重い場合は 0.8 に）
FPS           = 30     # フレームレート
WINDOW_TITLE  = "Noll Live"  # OBS でこのタイトルをキャプチャする

# ─────────────────────────────────────────────
#  口パク設定
# ─────────────────────────────────────────────
# [RENDERER SWAP Phase B] ヒステリシス追加。
# 立ち上がり(RISE)と立ち下がり(FALL)を別値にすることで、閾値付近で音量が
# 微妙に上下しただけの往復（バタつき）を抑える。FALL側は必ずRISE側より低い値にする。
# 旧単一閾値(VOLUME_THRESHOLD=0.05 / VOLUME_OPEN_HIGH=0.15)はコメントとして残す。
VOLUME_THRESHOLD_RISE   = 0.05   # closed→half_open（この音量を超えたら口を開く）
VOLUME_THRESHOLD_FALL   = 0.03   # half_open→closed（この音量以下に下がったら閉じる候補）
VOLUME_OPEN_HIGH_RISE   = 0.15   # half_open→open（この音量を超えたら全開）
VOLUME_OPEN_HIGH_FALL   = 0.11   # open→half_open（この音量以下に下がったら半開へ戻る）
MOUTH_CLOSE_DELAY       = 0.15   # 音が止まってからこの秒数後に口を閉じる

# ─────────────────────────────────────────────
#  瞬き設定
# ─────────────────────────────────────────────
BLINK_INTERVAL_MIN   = 2.5   # 瞬きの最小間隔（秒）
BLINK_INTERVAL_MAX   = 6.0   # 瞬きの最大間隔（秒）
# [RENDERER SWAP Phase B] 各フェーズの表示時間に軽いランダム幅を持たせ、
# 毎回寸分違わず同じ速さで瞬きする機械的な印象を減らす（間隔自体は元々ランダム）。
BLINK_FRAME_DURATION_MIN = 0.055  # 各フェーズの表示時間・下限（秒）
BLINK_FRAME_DURATION_MAX = 0.085  # 各フェーズの表示時間・上限（秒）
# 瞬きシーケンス: half_open(1) → closed(0) → half_open(1)
# 通常状態(open=2)から: open → half → closed → half → open
# eye_open.jpg は通常状態（mouth_closed.jpg）と画像位置が異なるため使用しない
BLINK_SEQUENCE = [1, 0, 1]


def pil_to_cv2(pil_img: Image.Image) -> np.ndarray:
    """PIL Image → OpenCV BGR numpy array に変換"""
    rgb = np.array(pil_img.convert("RGB"))
    return cv2.cvtColor(rgb, cv2.COLOR_RGB2BGR)


def load_frame(filename: str, scale: float) -> np.ndarray:
    """
    avatar_frames/ から画像を読み込んで OpenCV BGR 形式で返す。
    scale に応じてリサイズする。
    """
    path = FRAMES_DIR / filename
    if not path.exists():
        raise FileNotFoundError(f"フレーム画像が見つかりません: {path}")
    img = Image.open(path).convert("RGB")
    if scale != 1.0:
        w = int(img.width * scale)
        h = int(img.height * scale)
        img = img.resize((w, h), Image.LANCZOS)
    return pil_to_cv2(img)


class AvatarEngine:
    """
    フレーム切り替え方式の Live2D エンジン。
    OpenCV ウィンドウに 30fps でアバターを描画する。
    """

    def __init__(self):
        self._running = False
        self._thread  = None

        # ── 口パク状態（スレッドセーフ） ──
        self._lock         = threading.Lock()
        self._mouth_level  = 0      # 0=closed, 1=half_open, 2=open
        self._last_sound_t = 0.0    # 最後に音量を検知した時刻

        # ── 瞬き状態 ──
        self._blink_seq_idx  = len(BLINK_SEQUENCE)  # シーケンス終了位置 = 待機中
        self._blink_phase_t  = 0.0
        # [RENDERER SWAP Phase B] 瞬き1回ごとのフェーズ表示時間（毎回ランダムに選び直す）
        self._blink_frame_duration = BLINK_FRAME_DURATION_MIN
        self._next_blink_t   = time.time() + random.uniform(
            BLINK_INTERVAL_MIN, BLINK_INTERVAL_MAX
        )

        # ── フレーム画像の読み込み ──
        sc = DISPLAY_SCALE
        print(f"[AvatarEngine] フレーム読み込み中... (scale={sc})")

        # 目フレーム: [0]=closed, [1]=half_open, [2]=open
        self._eye_frames = [
            load_frame("eye_closed.jpg",    sc),
            load_frame("eye_half_open.jpg", sc),
            load_frame("eye_open.jpg",      sc),
        ]

        # 口フレーム: [0]=closed, [1]=half_open, [2]=open
        self._mouth_frames = [
            load_frame("mouth_closed.jpg",    sc),
            load_frame("mouth_half_open.jpg", sc),
            load_frame("mouth_open.jpg",      sc),
        ]

        # フレームサイズ確認
        h, w = self._eye_frames[0].shape[:2]
        print(f"[AvatarEngine] フレームサイズ: {w}x{h}px")
        print(f"[AvatarEngine] 初期化完了")
        print(f'  OBS ウィンドウキャプチャ: "{WINDOW_TITLE}"')

        # ── 音量監視スレッド起動 ──
        self._vol_thread = threading.Thread(
            target=self._volume_monitor_loop, daemon=True
        )
        self._vol_thread.start()

    # ─────────────────────────────────────────
    #  公開 API
    # ─────────────────────────────────────────

    def start(self):
        """OpenCV ウィンドウを起動してアニメーションを開始する"""
        if self._running:
            return
        self._running = True
        self._thread = threading.Thread(target=self._run_cv2, daemon=True)
        self._thread.start()

    def stop(self):
        """エンジンを停止する"""
        self._running = False
        if self._thread:
            self._thread.join(timeout=2.0)

    def set_volume(self, volume: float):
        """
        外部から音量を直接設定する（voice_analyzer から呼ばれる）。
        volume: 0.0〜1.0

        [RENDERER SWAP Phase B] ヒステリシス付き状態機械に変更。
        現在の口パクレベル(self._mouth_level)を起点に、上昇と下降で別の閾値を使う。
        単一閾値だった旧実装は、音量が閾値付近で微小に上下するだけでも
        closed⇔half_open（またはhalf_open⇔open）を毎フレーム往復し、
        口パクがバタついて見える原因になっていた。
        """
        with self._lock:
            cur = self._mouth_level
            now = time.time()

            if cur == 0:  # closed
                if volume > VOLUME_THRESHOLD_RISE:
                    cur = 1  # half_open
                    self._last_sound_t = now

            elif cur == 1:  # half_open
                if volume > VOLUME_OPEN_HIGH_RISE:
                    cur = 2  # open
                    self._last_sound_t = now
                elif volume > VOLUME_THRESHOLD_FALL:
                    # ヒステリシス帯域内: half_openを維持
                    self._last_sound_t = now
                else:
                    # 無音とみなせる音量まで下がった場合のみ、
                    # 遅延後にclosedへ（従来通りのclose delayを維持）
                    if now - self._last_sound_t > MOUTH_CLOSE_DELAY:
                        cur = 0  # closed

            else:  # cur == 2, open
                if volume > VOLUME_OPEN_HIGH_FALL:
                    # ヒステリシス帯域内: openを維持
                    self._last_sound_t = now
                else:
                    # openの閾値を割ったのでhalf_openへ降格（closedへは直接落とさない）
                    cur = 1
                    self._last_sound_t = now

            self._mouth_level = cur

    def set_speaking(self, is_speaking: bool):
        """
        外部から口パク状態を直接制御する（voice_analyzer から呼ばれる）。
        """
        with self._lock:
            if is_speaking:
                self._mouth_level  = 1  # half_open（デフォルト）
                self._last_sound_t = time.time()
            else:
                if time.time() - self._last_sound_t > MOUTH_CLOSE_DELAY:
                    self._mouth_level = 0

    # ─────────────────────────────────────────
    #  内部メソッド
    # ─────────────────────────────────────────

    def _volume_monitor_loop(self):
        """
        output/volume.txt を 50ms ごとに監視して口パク状態を更新するループ。
        """
        while True:
            try:
                vol = self._read_volume_file()
                if vol is not None:
                    self.set_volume(vol)
            except Exception:
                pass
            time.sleep(0.05)

    def _read_volume_file(self):
        """output/volume.txt から音量値（float）を読み込む"""
        try:
            if VOLUME_FILE.exists():
                content = VOLUME_FILE.read_text().strip()
                if content:
                    return float(content)
        except Exception:
            pass
        return None

    def _get_eye_frame_index(self, now: float) -> int:
        """
        瞬きシーケンスの現在位置に対応する目フレームインデックスを返す。
        待機中（シーケンス終了）は 2（open）を返す。

        シーケンス: BLINK_SEQUENCE = [1, 0, 1]
          0=closed, 1=half_open, 2=open
        """
        # 待機中: 次の瞬きタイミングを確認
        if self._blink_seq_idx >= len(BLINK_SEQUENCE):
            if now >= self._next_blink_t:
                # 瞬き開始
                self._blink_seq_idx = 0
                self._blink_phase_t = now
                # [RENDERER SWAP Phase B] 毎回速さを少し変える（機械的な印象を減らす）
                self._blink_frame_duration = random.uniform(
                    BLINK_FRAME_DURATION_MIN, BLINK_FRAME_DURATION_MAX
                )
            else:
                return -1  # 瞬きなし（通常状態 = mouth_closed を使う）

        # シーケンス実行中: 経過時間でフェーズを進める
        elapsed = now - self._blink_phase_t
        if elapsed >= self._blink_frame_duration:
            self._blink_seq_idx += 1
            self._blink_phase_t  = now

            if self._blink_seq_idx >= len(BLINK_SEQUENCE):
                # シーケンス完了 → 次の瞬きをスケジュール
                self._next_blink_t = now + random.uniform(
                    BLINK_INTERVAL_MIN, BLINK_INTERVAL_MAX
                )
                return -1  # シーケンス完了（通常状態に戻る）

        # 現在のシーケンス位置のフレームインデックスを返す
        idx = min(self._blink_seq_idx, len(BLINK_SEQUENCE) - 1)
        return BLINK_SEQUENCE[idx]

    def _get_mouth_frame_index(self) -> int:
        """現在の口パク状態に対応するフレームインデックスを返す"""
        with self._lock:
            return self._mouth_level

    def _compose_frame(self, eye_idx: int, mouth_idx: int) -> np.ndarray:
        """
        表示フレームを決定して返す。

        引数:
          eye_idx  : -1=瞬きなし, 0=closed, 1=half_open
          mouth_idx:  0=closed,   1=half_open, 2=open

        優先ルール:
          1. 瞬き中（eye_idx >= 0）→ eye_frames[eye_idx] を返す
             （瞬きは短時間なので口パクは一時的に無視）
          2. 口パク中（mouth_idx > 0）→ mouth_frames[mouth_idx] を返す
          3. 通常状態 → eye_frames[2]（eye_open.jpg）を返す

        ※ 通常状態は eye_open.jpg を使う。
           mouth_closed.jpg は口パク専用（位置が異なるため通常状態には使わない）。
        """
        # 瞬き中 → eye フレームを優先
        if eye_idx >= 0:
            return self._eye_frames[eye_idx]

        # 口パク中（瞬きなし）
        if mouth_idx > 0:
            return self._mouth_frames[mouth_idx]

        # 通常状態 → eye_open.jpg（mouth_closed.jpg より位置が正確）
        return self._eye_frames[2]

    def _run_cv2(self):
        """
        OpenCV メインループ（専用スレッドで実行）。
        30fps でフレームを描画する。
        """
        cv2.namedWindow(WINDOW_TITLE, cv2.WINDOW_AUTOSIZE)

        interval = 1.0 / FPS

        while self._running:
            t_start = time.time()

            # ── 状態取得 ──
            now       = time.time()
            eye_idx   = self._get_eye_frame_index(now)
            mouth_idx = self._get_mouth_frame_index()

            # ── フレーム合成 ──
            frame = self._compose_frame(eye_idx, mouth_idx)

            # ── 描画 ──
            cv2.imshow(WINDOW_TITLE, frame)

            # ── キー入力チェック（ESC で終了） ──
            key = cv2.waitKey(1) & 0xFF
            if key == 27:  # ESC
                self._running = False
                break

            # ── ウィンドウが閉じられたか確認 ──
            try:
                if cv2.getWindowProperty(WINDOW_TITLE, cv2.WND_PROP_VISIBLE) < 1:
                    self._running = False
                    break
            except Exception:
                pass

            # ── フレームレート制御 ──
            elapsed = time.time() - t_start
            sleep_t = interval - elapsed
            if sleep_t > 0:
                time.sleep(sleep_t)

        cv2.destroyAllWindows()
        print("[AvatarEngine] ウィンドウを閉じました")


# ─────────────────────────────────────────────
#  単体テスト用エントリポイント
# ─────────────────────────────────────────────
if __name__ == "__main__":
    print("=== AvatarEngine 単体テスト ===")
    print("ESC キーまたはウィンドウ × で終了")

    engine = AvatarEngine()
    engine.start()

    # 口パクテスト
    os.makedirs(str(BASE_DIR / "output"), exist_ok=True)
    test_seq = [
        (0.0,  "アイドル（口閉じ・瞬き待ち）"),
        (3.0,  "口パク: half_open"),
        (0.08, "口パク: half_open（小声）"),
        (0.20, "口パク: open（大声）"),
        (0.08, "口パク: half_open"),
        (0.0,  "口閉じ"),
    ]
    try:
        for vol, label in test_seq:
            print(f"  テスト: {label} (vol={vol})")
            (BASE_DIR / "output" / "volume.txt").write_text(str(vol))
            time.sleep(2.5)
    except KeyboardInterrupt:
        pass
    finally:
        engine.stop()
        print("テスト終了")
