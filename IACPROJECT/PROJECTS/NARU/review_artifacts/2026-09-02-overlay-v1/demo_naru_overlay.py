"""
demo_naru_overlay.py
=====================
NARU overlay-route v1 のローカルスモークテスト。TikTok接続なし、
OpenAI/ElevenLabs等の有料API呼び出しなし（合成音量波形のみ使用）。

renderer.py の Renderer抽象化（create_renderer("overlay_v1")）経由で
NaruOverlayEngineへ接続し、口パク・瞬き・HAIR_FRONT独立揺れを
一定時間シミュレートして、ローカルMP4 + 代表フレームPNGを書き出す。
"""

import math
import sys

import cv2
import numpy as np

from renderer import create_renderer


def synthetic_talk_wave(t: float) -> float:
    envelope = 0.5 + 0.5 * math.sin(t * 0.45)
    syllable = 0.5 + 0.5 * math.sin(t * 1.1)
    return max(0.0, envelope * syllable * 0.9)


def main():
    renderer = create_renderer("overlay_v1")
    engine = renderer._engine  # smoke test: 内部engineへ直接アクセスしフレームを取得する

    assert "naru_overlay" not in {"openai", "elevenlabs", "tiktok"}
    for banned in ("openai", "elevenlabs", "TikTokLive"):
        assert banned not in sys.modules, f"禁止モジュール {banned} がロードされています"

    renderer.start()

    fps = 30
    duration_sec = 10.0
    n_frames = int(fps * duration_sec)

    h, w = engine._base.shape[:2]
    out_path = "live2d_assets/naru_v1_extraction/overlay_v1_smoketest.mp4"
    fourcc = cv2.VideoWriter_fourcc(*"mp4v")
    writer = cv2.VideoWriter(out_path, fourcc, fps, (w, h))

    still_targets = {
        "rest": 0.3,
        "mouth_open": None,   # 探索して決める（level最大時）
        "blink_mid": None,    # 探索して決める（closeness最大時）
        "hair_sway_extreme": None,
    }
    saved_stills = {}
    best_level = -1.0
    best_level_t = 0.0

    # スモークテストの再現性のため、最初の瞬きを確実にt=1.0sで起こす
    engine._next_blink_t = engine._start_time + 1.0

    for i in range(n_frames):
        t = i / fps
        vol = synthetic_talk_wave(t)
        renderer.set_audio_level(vol)

        frame = engine.compose_frame()
        writer.write(frame)

        if abs(t - still_targets["rest"]) < (1.0 / fps):
            saved_stills["rest"] = frame.copy()

        lvl = engine._displayed_level
        if lvl > best_level:
            best_level = lvl
            best_level_t = t
            saved_stills["mouth_open"] = frame.copy()

        if engine._blink_state in ("held",):
            saved_stills.setdefault("blink_mid", frame.copy())
        if engine._blink_state == "closing":
            saved_stills.setdefault("blink_halfway", frame.copy())

        sway_phase = (t % engine.HAIR_SWAY_PERIOD_SEC) / engine.HAIR_SWAY_PERIOD_SEC
        if abs(sway_phase - 0.25) < (1.0 / fps) / engine.HAIR_SWAY_PERIOD_SEC * 2:
            saved_stills.setdefault("hair_sway_extreme", frame.copy())

    writer.release()
    renderer.stop()

    print(f"saved video: {out_path} ({n_frames} frames, {duration_sec}s @ {fps}fps)")
    print(f"best mouth level observed: {best_level:.3f} at t={best_level_t:.2f}s")

    for name, frame in saved_stills.items():
        if frame is None:
            continue
        path = f"live2d_assets/naru_v1_extraction/overlay_v1_still_{name}.png"
        cv2.imwrite(path, frame)
        print(f"saved still: {path}")

    print("done")


if __name__ == "__main__":
    main()
