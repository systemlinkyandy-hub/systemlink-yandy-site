import os
os.environ.setdefault("NARU_RENDERER", "video_hybrid")
import time
from renderer import create_isolated_renderer
import voice_analyzer
import app_live2d

renderer = create_isolated_renderer()
engine = renderer._real._engine
renderer.start()
time.sleep(0.3)
print(f"[test] start後 is_offline={renderer.is_offline}")

app_live2d.avatar_engine = renderer

audio_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "output.mp3")
print(f"[test] 既存ローカル音声使用（新規生成なし）: {audio_path}")

states_seen = []
def poll():
    states_seen.append(engine._speak_state)

sync_thread = voice_analyzer.play_with_lipsync(audio_path, renderer)
t0 = time.time()
while sync_thread and sync_thread.is_alive() and time.time() - t0 < 10:
    poll()
    time.sleep(0.05)
poll()

print(f"[test] 観測した状態遷移（重複除去）: {list(dict.fromkeys(states_seen))}")
print(f"[test] 再生完了後 is_offline={renderer.is_offline}")

renderer.stop()
time.sleep(0.3)
print(f"[test] stop後 thread alive={engine._thread.is_alive() if engine._thread else None}")
assert not engine._thread.is_alive()
print("[test] PASS")
