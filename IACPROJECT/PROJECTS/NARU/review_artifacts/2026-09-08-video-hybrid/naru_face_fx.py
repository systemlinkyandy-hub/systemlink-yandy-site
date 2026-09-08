"""
naru_face_fx.py
==================
NARUレンダラー間で共有する瞬き・毛揺れの合成ヘルパー。

[production 2026-09-08] `NaruVideoHybridEngine`追加にあたり、`NaruOverlayEngine`
にだけ実装されていた瞬き（EYE_CROPの幾何学的圧縮）・毛揺れ（HAIR_FRONTの
独立オーバーレイ）ロジックを、両エンジンから使える形へ切り出した
（Arc Handoff: 「瞬き・毛揺れロジックの二重管理を避ける。ただし、そのために
renderer abstraction全体を再設計してはならない。必要最小限の共有ヘルパー
抽出に留める」に対応）。

`NaruOverlayEngine`側もこのモジュールを使うようリファクタ済み
（ロジック自体の変更はなし、関数として切り出しただけ）。
"""

import cv2
import numpy as np


def build_eye_mask(crop, local_centers, blur_kernel=21):
    """目クロップ内での、片目ずつの中心＋半径からソフトマスクを作る。
    local_centers: [(cx, cy, rx, ry), ...]（クロップ内ローカル座標）
    """
    y0, y1, x0, x1 = crop
    h, w = y1 - y0, x1 - x0
    mask = np.zeros((h, w), dtype=np.float32)
    for cx, cy, rx, ry in local_centers:
        cv2.ellipse(mask, (cx, cy), (rx, ry), 0, 0, 360, 1.0, -1)
    mask = cv2.GaussianBlur(mask, (blur_kernel, blur_kernel), 0)
    return mask[:, :, None]


def squash_eye_crop(base_frame, eye_crop, eye_mask, closeness):
    """crop全体を縦方向に圧縮した版を、eye_maskでフェザー合成する（瞬き近似）。
    経緯・不採用案は`naru_overlay_engine.py`のdocstringを参照。
    """
    if closeness <= 0.001:
        return
    y0, y1, x0, x1 = eye_crop
    h, w = y1 - y0, x1 - x0
    src = base_frame[y0:y1, x0:x1]
    scale_y = max(0.10, 1.0 - closeness * 0.85)
    small_h = max(1, int(h * scale_y))
    prefiltered = cv2.GaussianBlur(src, (0, 0), 1.4)
    squashed_small = cv2.resize(prefiltered, (w, small_h), interpolation=cv2.INTER_AREA)
    squashed = cv2.resize(squashed_small, (w, h), interpolation=cv2.INTER_LINEAR)
    alpha = eye_mask * closeness
    composited = squashed.astype(np.float32) * alpha + src.astype(np.float32) * (1.0 - alpha)
    base_frame[y0:y1, x0:x1] = composited.astype(np.uint8)


def composite_hair_front(frame, hair_front_bgra, offset, t, amplitude_px, period_sec):
    """HAIR_FRONTオーバーレイ（BGRA）を、微小な独立揺れを加えてframeへ合成する。"""
    y0, x0 = offset
    h, w = hair_front_bgra.shape[:2]
    sway = amplitude_px * np.sin(2 * np.pi * t / period_sec)
    M = np.float32([[1, 0, sway], [0, 1, sway * 0.3]])
    shifted = cv2.warpAffine(
        hair_front_bgra, M, (w, h),
        flags=cv2.INTER_LINEAR, borderMode=cv2.BORDER_REPLICATE
    )
    color = shifted[:, :, :3].astype(np.float32)
    alpha = (shifted[:, :, 3:4].astype(np.float32)) / 255.0
    region = frame[y0:y0 + h, x0:x0 + w].astype(np.float32)
    frame[y0:y0 + h, x0:x0 + w] = (region * (1 - alpha) + color * alpha).astype(np.uint8)
