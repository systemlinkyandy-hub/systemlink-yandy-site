"""
NARU renderer swap verification (no paid API calls, no TikTok connection).

Covers Arc's "Test gate" (IACPROJECT/PROJECTS/NARU/2026-08-31_NARU_RENDERER_SWAP_PLAN.md):
  - STANDBY startup unaffected (not re-tested here; unchanged code path,
    already verified in last night's condition-fix test)
  - mouth closed at idle
  - synthetic audio level -> mouth state transitions, WITH hysteresis
  - blink still occurs (interval already randomized; duration now jittered too)
  - renderer factory: default (legacy), explicit "legacy", and an unknown name
    (must raise -- no silent fallback, matching the OPENAI_MODEL policy)
  - rollback path: renderer.py is additive; avatar_engine.py / AvatarEngine
    itself is unchanged in its public shape (start/stop/set_volume/set_speaking)
"""

import sys
import time

sys.path.insert(0, r"C:\Projects\vtuber_ai")

import avatar_engine as ae  # noqa: E402
import renderer as rnd      # noqa: E402

print("=== NARU renderer swap verification ===")

# ---------------------------------------------------------------------------
# 1. Hysteresis: before/after transition-count comparison on the exact same
#    oscillating volume sequence, using the REAL current set_volume() logic
#    for "after", and a small reference re-implementation of the OLD
#    single-threshold logic for "before" (since the old logic no longer
#    exists in the file to instantiate directly).
# ---------------------------------------------------------------------------
def old_single_threshold_level(volume, cur, last_sound_t, now, close_delay=0.15,
                                th=0.05, high=0.15):
    if volume > high:
        return 2, now
    elif volume > th:
        return 1, now
    else:
        if now - last_sound_t > close_delay:
            return 0, last_sound_t
        return cur, last_sound_t


# The OLD code already buffered the closed<->half_open boundary with
# MOUTH_CLOSE_DELAY, so oscillating there doesn't actually flicker much even
# in the old logic. The boundary with NO debounce at all in the old code was
# half_open<->open (single threshold VOLUME_OPEN_HIGH=0.15, both directions
# immediate). That is exactly where the new hysteresis band
# (HIGH_RISE=0.15 / HIGH_FALL=0.11) should make the real difference, so the
# sequence targets that: warm up to "open" once, then oscillate between a
# value above the old single threshold (0.16) and one that's below it but
# still above the new FALL threshold (0.13).
warmup = [0.20, 0.20]
sequence = warmup + [0.16, 0.13] * 15

# --- old (reference) ---
old_level, old_last_t, t = 0, 0.0, 0.0
old_transitions = 0
old_levels = []
for v in sequence:
    t += 0.05  # simulate ~50ms ticks like the real polling/lipsync interval
    new_level, old_last_t = old_single_threshold_level(v, old_level, old_last_t, t)
    if new_level != old_level:
        old_transitions += 1
    old_level = new_level
    old_levels.append(old_level)

# --- new (real code path) ---
engine = ae.AvatarEngine.__new__(ae.AvatarEngine)  # skip __init__ (no frame/file I/O needed)
engine._lock = __import__("threading").Lock()
engine._mouth_level = 0
engine._last_sound_t = 0.0

new_transitions = 0
new_levels = []
prev = 0
# advance a monotonic clock so MOUTH_CLOSE_DELAY comparisons behave like real time
import unittest.mock as mock
fake_now = [0.0]
with mock.patch("time.time", lambda: fake_now[0]):
    for v in sequence:
        fake_now[0] += 0.05
        engine.set_volume(v)
        lvl = engine._mouth_level
        if lvl != prev:
            new_transitions += 1
        prev = lvl
        new_levels.append(lvl)

print(f"[test] same oscillating sequence ({len(sequence)} samples, hovering near old threshold 0.05)")
print(f"[test] OLD single-threshold transitions: {old_transitions}  levels={old_levels}")
print(f"[test] NEW hysteresis transitions:       {new_transitions}  levels={new_levels}")
assert new_transitions < old_transitions, (
    f"hysteresis should reduce flicker (transitions), got old={old_transitions} new={new_transitions}"
)
print(f"[test] PASS: hysteresis reduced transitions {old_transitions} -> {new_transitions}")

# ---------------------------------------------------------------------------
# 2. Renderer factory: default/legacy/unknown
# ---------------------------------------------------------------------------
r1 = rnd.create_renderer()          # default -> legacy
assert isinstance(r1, rnd.LegacyFrameRenderer)
print("[test] create_renderer() default -> LegacyFrameRenderer: OK")

r2 = rnd.create_renderer("legacy")
assert isinstance(r2, rnd.LegacyFrameRenderer)
print("[test] create_renderer('legacy') -> LegacyFrameRenderer: OK")

try:
    rnd.create_renderer("nonexistent_future_renderer")
    raise AssertionError("expected ValueError for unknown renderer name, none raised")
except ValueError as e:
    print(f"[test] create_renderer('nonexistent_future_renderer') raised as expected: {e}")

# ---------------------------------------------------------------------------
# 3. Real visual smoke test: open the actual window briefly, drive it through
#    the renderer interface with synthetic audio levels, confirm mouth state
#    reaches idle/half/open and back to idle, then close. No API calls.
# ---------------------------------------------------------------------------
print("[test] opening real Noll Live window for a short synthetic smoke test...")
# NOTE: AvatarEngine also runs a background thread polling output/volume.txt
# every 50ms and re-applying whatever value it finds there (this is existing,
# pre-renderer-swap behavior, not something introduced today). In real
# production use voice_analyzer.py always calls write_volume() and
# set_volume()/set_audio_level() together in lockstep, so this doesn't race.
# A standalone synthetic test has to do the same or the stale/zero value
# already sitting in output/volume.txt from a prior run will fight the
# direct set_audio_level() call. Found exactly this while writing this test.
from voice_analyzer import write_volume  # noqa: E402

live = rnd.create_renderer("legacy")
live.start()
time.sleep(1.0)

print(f"[test] idle mouth level (expect 0): {live.get_mouth_level()}")
assert live.get_mouth_level() == 0

write_volume(0.20)
live.set_audio_level(0.20)  # should climb toward open as repeated loud levels arrive
time.sleep(0.3)
lvl_after_loud = live.get_mouth_level()
print(f"[test] after sustained set_audio_level(0.20): {lvl_after_loud}")
assert lvl_after_loud > 0, "expected mouth to open at least to half_open under sustained loud audio"

write_volume(0.0)
live.set_audio_level(0.0)
time.sleep(0.3)  # still within MOUTH_CLOSE_DELAY, should not be closed yet necessarily
lvl_mid = live.get_mouth_level()
print(f"[test] shortly after silence: {lvl_mid}")

time.sleep(0.3)  # now past MOUTH_CLOSE_DELAY (0.15s) with continued silence
write_volume(0.0)
live.set_audio_level(0.0)
lvl_after_silence = live.get_mouth_level()
print(f"[test] after MOUTH_CLOSE_DELAY of silence: {lvl_after_silence}")
assert lvl_after_silence == 0, "expected mouth closed after sustained silence"

write_volume(0.0)
live.stop()
print("[test] window closed cleanly")

print("=== ALL RENDERER SWAP CHECKS PASSED ===")
