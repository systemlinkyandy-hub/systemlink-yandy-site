"""
test_overlay_start_stop.py
============================
黒瀬レビュー指摘（NaruOverlayEngine.start()が空実装で描画ループが存在しない）
への修正検証。renderer.start()経由で実際にOpenCVウィンドウが立ち上がり、
compose_frame()が周期的に呼ばれ続けることを確認する。TikTok/有料API不使用。
"""

import time
import sys

from renderer import create_renderer
import naru_overlay_engine


def main():
    call_count = {"n": 0}
    original = naru_overlay_engine.NaruOverlayEngine.compose_frame

    def counting_compose_frame(self):
        call_count["n"] += 1
        return original(self)

    naru_overlay_engine.NaruOverlayEngine.compose_frame = counting_compose_frame

    for banned in ("openai", "elevenlabs", "TikTokLive"):
        assert banned not in sys.modules, f"禁止モジュール {banned} がロードされています"

    renderer = create_renderer("overlay_v1")
    engine = renderer._engine

    print(f"[test] start前: thread={engine._thread}, running={engine._running}")
    renderer.start()
    time.sleep(0.3)  # スレッド起動待ち
    print(f"[test] start後: thread alive={engine._thread.is_alive() if engine._thread else None}, running={engine._running}")

    time.sleep(1.5)  # 30fps想定で約45フレーム分待つ

    n_calls_during_run = call_count["n"]
    print(f"[test] 約1.8秒間でcompose_frame()が呼ばれた回数: {n_calls_during_run}")
    assert n_calls_during_run > 20, (
        f"描画ループが実際に動いていない可能性: 呼び出し回数={n_calls_during_run}"
    )

    renderer.stop()
    time.sleep(0.3)
    print(f"[test] stop後: thread alive={engine._thread.is_alive() if engine._thread else None}, running={engine._running}")
    assert engine._running is False
    assert not engine._thread.is_alive()

    n_calls_after_stop = call_count["n"]
    time.sleep(0.5)
    n_calls_settled = call_count["n"]
    print(f"[test] stop直後={n_calls_after_stop}, 0.5秒後={n_calls_settled}（stop後は増加しないはず）")
    assert n_calls_settled == n_calls_after_stop, "stop()後もフレーム生成が続いている"

    print("[test] PASS: start()は実際に描画スレッドを起動し、stop()で確実に停止する")


if __name__ == "__main__":
    main()
