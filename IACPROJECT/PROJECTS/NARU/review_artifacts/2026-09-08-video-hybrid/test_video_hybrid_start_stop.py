import os
os.environ.setdefault("NARU_RENDERER", "video_hybrid")
import time
from renderer import create_isolated_renderer

renderer = create_isolated_renderer()
engine = renderer._real._engine
print(f"[test] engine: {type(engine).__name__}, is_offline={renderer.is_offline}")

renderer.start()
time.sleep(0.3)
print(f"[test] start後: thread alive={engine._thread.is_alive()}, is_offline={renderer.is_offline}")

call_count = 0
orig = type(engine).compose_frame
def counted(self):
    global call_count
    call_count += 1
    return orig(self)
type(engine).compose_frame = counted

time.sleep(1.5)
print(f"[test] 1.5秒間でcompose_frame呼び出し回数: {call_count}")
assert call_count > 20

renderer.stop()
time.sleep(0.3)
print(f"[test] stop後: thread alive={engine._thread.is_alive() if engine._thread else None}")
assert not engine._thread.is_alive()
print("[test] PASS")
