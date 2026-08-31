"""
NARU Phase C0 — renderer failure isolation verification.
No paid API calls, no TikTok connection.

Covers the 4 required failure injections
(IACPROJECT/inbox/from_arc/2026-08-31_ARC_TO_SATO_NARU_RENDERER_PHASE_C0_C1.md):
  1. renderer factory failure
  2. renderer.start() exception
  3. renderer.set_audio_level()/set_volume() exception while core workers are alive
  4. renderer stop/cleanup exception
"""

import sys
import threading

sys.path.insert(0, r"C:\Projects\vtuber_ai")

import renderer as rnd  # noqa: E402

print("=== NARU Phase C0 isolation verification ===")


class BrokenRenderer(rnd.Renderer):
    """Test double: every method explodes. Used to inject failures deterministically."""

    def __init__(self, fail_on=()):
        self.fail_on = set(fail_on)
        self.calls = []

    def _maybe_raise(self, name):
        self.calls.append(name)
        if name in self.fail_on:
            raise RuntimeError(f"deliberately broken: {name}()")

    def start(self):
        self._maybe_raise("start")

    def stop(self):
        self._maybe_raise("stop")

    def set_audio_level(self, level):
        self._maybe_raise("set_audio_level")

    def set_expression(self, name):
        self._maybe_raise("set_expression")

    def set_motion(self, name):
        self._maybe_raise("set_motion")


# ---------------------------------------------------------------------------
# 1. renderer factory failure
# ---------------------------------------------------------------------------
proxy1 = rnd.create_isolated_renderer("this_renderer_does_not_exist")
assert proxy1.is_offline, "factory failure should leave the proxy offline"
print(f"[test 1] factory failure -> offline immediately: OK (reason={proxy1.offline_reason})")

# subsequent calls must be silent no-ops, never raise
proxy1.start()
proxy1.set_audio_level(0.5)
proxy1.set_volume(0.5)
proxy1.stop()
print("[test 1] all subsequent calls on an offline proxy were silent no-ops: OK")

# ---------------------------------------------------------------------------
# 2. renderer.start() exception
# ---------------------------------------------------------------------------
broken_start = BrokenRenderer(fail_on={"start"})
proxy2 = rnd.RendererIsolationProxy(renderer_instance=broken_start)
assert not proxy2.is_offline, "should still be online before start() is called"
proxy2.start()  # must not raise
assert proxy2.is_offline, "start() exception should mark the proxy offline"
print(f"[test 2] start() exception -> offline, no exception propagated: OK (reason={proxy2.offline_reason})")

# once offline, further calls must not reach the broken renderer again
calls_before = list(broken_start.calls)
proxy2.set_audio_level(0.3)
assert broken_start.calls == calls_before, "offline proxy must not forward calls to the broken renderer"
print("[test 2] offline proxy stopped forwarding calls to the broken renderer: OK")

# ---------------------------------------------------------------------------
# 3. set_audio_level()/set_volume() exception WHILE core workers are alive
#    (reuses the app_live2d queue/worker pipeline with speak() stubbed, same
#    no-paid-API technique as the Kurose condition-fix verification)
# ---------------------------------------------------------------------------
import app_live2d as app  # noqa: E402

broken_audio = BrokenRenderer(fail_on={"set_audio_level"})
app.avatar_engine = rnd.RendererIsolationProxy(renderer_instance=broken_audio)
assert not app.avatar_engine.is_offline

calls = []

def fake_speak(text, voice_id=app.DEFAULT_VOICE, voice_settings=None, job_id=None):
    calls.append(job_id)
    # Exercise exactly the calls the real speak()/speak_with_lipsync() path makes
    # against avatar_engine -- this is the actual injection point for test 3.
    app.avatar_engine.set_volume(0.5)
    app.avatar_engine.set_volume(0.0)
    return True

app.speak = fake_speak

assert app.conversation_memory == []
threading.Thread(target=app.tts_worker, daemon=True).start()

app.tts_queue.put({"id": 1, "response_text": "JOB_ONE_TEXT"})
app.tts_queue.put({"id": 2, "response_text": "JOB_TWO_TEXT"})
app.tts_queue.join()

assert "Noll: JOB_ONE_TEXT" in app.conversation_memory
assert "Noll: JOB_TWO_TEXT" in app.conversation_memory
assert app.avatar_engine.is_offline, "renderer should have gone offline after set_audio_level() raised"
print(f"[test 3] both queue jobs completed despite a broken renderer: OK "
      f"(conversation_memory={app.conversation_memory}, renderer offline={app.avatar_engine.is_offline})")

# ---------------------------------------------------------------------------
# 4. renderer stop/cleanup exception
# ---------------------------------------------------------------------------
broken_stop = BrokenRenderer(fail_on={"stop"})
proxy4 = rnd.RendererIsolationProxy(renderer_instance=broken_stop)
proxy4.start()  # succeeds (not in fail_on)
assert not proxy4.is_offline
proxy4.stop()  # must not raise
assert proxy4.is_offline
print(f"[test 4] stop() exception -> offline, no exception propagated: OK (reason={proxy4.offline_reason})")

# ---------------------------------------------------------------------------
# 5. legacy still selectable for immediate rollback (sanity, no failure injected)
# ---------------------------------------------------------------------------
proxy5 = rnd.create_isolated_renderer("legacy")
assert not proxy5.is_offline
assert isinstance(proxy5._real, rnd.LegacyFrameRenderer)
print("[test 5] NARU_RENDERER=legacy still resolves cleanly through the isolation proxy: OK")

print("\n=== ALL PHASE C0 ISOLATION CHECKS PASSED ===")
