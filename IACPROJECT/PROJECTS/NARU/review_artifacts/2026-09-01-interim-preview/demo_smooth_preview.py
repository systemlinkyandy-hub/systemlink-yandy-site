"""
demo_smooth_preview.py
========================
[NARU interim native preview] ケイの目視確認専用デモ。

このスクリプトは意図的に app_live2d.py を経由しない。
openai / elevenlabs / TikTokLive のいずれもimportしないため、
「有料API呼び出し0・TikTok接続なし」を構造的に保証する
（挙動として気をつける、ではなくコード上そもそも到達できない）。

やること:
  1. legacy_smooth renderer（既存6枚素材、口パク連続化＋微小sway）を起動
  2. 自動でゆっくり「アイドル → 短い発話っぽい動き → アイドル」を繰り返す
     （実音声・実LLMは一切使わない。合成の音量値を送るだけ）
  3. ウィンドウを閉じる、またはCtrl+Cで終了

操作は不要（起動するだけで動きが見られる）。
"""

import math
import sys
import time

sys.path.insert(0, r"C:\Projects\vtuber_ai")

from renderer import create_renderer  # noqa: E402


def synthetic_talk_wave(t: float) -> float:
    """
    実音声の代わりに使う、なだらかな合成波形。0.0〜0.75程度に収め、
    ナルの落ち着いたキャラクター性に合わせて振り切らせない。
    """
    return max(0.0, 0.55 + 0.35 * math.sin(t * 3.3) * math.sin(t * 0.7))


def main():
    print("=== NARU interim native preview (legacy_smooth) ===")
    print("[SAFE] このデモはOpenAI/ElevenLabs/TikTokのいずれにも接続しません。")

    renderer = create_renderer("legacy_smooth")
    renderer.start()
    print("[demo] ウィンドウ「Noll Live」が開きます。閉じるとデモも終了します。")

    IDLE_SEC = 4.0
    TALK_SEC = 6.0

    try:
        while True:
            print("[demo] アイドル（瞬き・微小なsway）...")
            t0 = time.time()
            while time.time() - t0 < IDLE_SEC:
                renderer.set_audio_level(0.0)
                time.sleep(0.05)

            print("[demo] 発話っぽい動き（合成波形、実音声なし）...")
            t0 = time.time()
            while time.time() - t0 < TALK_SEC:
                level = synthetic_talk_wave(time.time() - t0)
                renderer.set_audio_level(level)
                time.sleep(0.05)

            renderer.set_audio_level(0.0)
    except KeyboardInterrupt:
        pass
    finally:
        renderer.stop()
        print("[demo] 終了しました。")


if __name__ == "__main__":
    main()
