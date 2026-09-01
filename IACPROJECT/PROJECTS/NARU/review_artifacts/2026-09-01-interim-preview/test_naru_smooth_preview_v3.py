"""
NARU interim native preview v3 verification.
No paid API calls, no TikTok connection.

Covers the 3 findings from
IACPROJECT/inbox/from_arc/2026-09-01_ARC_TO_SATO_NARU_INTERIM_PREVIEW_VISUAL_FIX_V3.md:
  1. temporal smoothing on mouth input (bounded frame-to-frame delta under noisy input)
  2. whole-frame idle sway removed entirely
  3. blink path uses the same crop+fixed-base strategy as mouth (no whole-frame eye swap)
"""

import random
import sys
import time

sys.path.insert(0, r"C:\Projects\vtuber_ai")

from renderer import create_renderer  # noqa: E402
import numpy as np  # noqa: E402

print("=== NARU interim native preview v3 verification ===")

sr = create_renderer("legacy_smooth")
engine = sr._engine

# ---------------------------------------------------------------------------
# 1. Temporal smoothing: noisy input must not translate 1:1 into the
#    displayed level. Bound the frame-to-frame delta.
# ---------------------------------------------------------------------------
random.seed(42)
engine._displayed_level = 0.0
deltas = []
prev = 0.0
for _ in range(200):
    noisy_target = random.choice([0.0, 0.9, 0.1, 0.8, 0.0, 1.0])  # deliberately jumpy
    with engine._lock:
        engine._raw_audio_level = noisy_target
    level = engine._update_displayed_level()
    deltas.append(abs(level - prev))
    prev = level

max_delta = max(deltas)
mean_delta = sum(deltas) / len(deltas)
print(f"[test] noisy input over 200 ticks -> displayed level max frame-to-frame delta={max_delta:.3f}, "
      f"mean={mean_delta:.3f}")
assert max_delta < 0.5, (
    f"a single tick should never jump more than half the full range even under worst-case noisy "
    f"input (0.0<->1.0 every tick); got {max_delta:.3f} -- smoothing is not effective"
)
print("[test] temporal smoothing bounds frame-to-frame jitter even under adversarial noisy input: PASS")

# sanity: smoothing must still reach the target eventually for a sustained input (not stuck)
engine._displayed_level = 0.0
with engine._lock:
    engine._raw_audio_level = 0.8
for _ in range(30):
    level = engine._update_displayed_level()
assert level > 0.7, f"sustained input should be tracked within ~30 ticks, got {level:.3f}"
print(f"[test] sustained input is still tracked (reaches {level:.3f} after 30 ticks, not stuck): PASS")

# ---------------------------------------------------------------------------
# 2. No whole-frame idle sway: _compose_frame output must be identical
#    regardless of time.time(), given the same level/blink state.
# ---------------------------------------------------------------------------
assert not hasattr(engine, "_idle_sway_offset"), "idle sway method should be removed entirely in v3"
engine._displayed_level = 0.3
with engine._lock:
    engine._raw_audio_level = 0.3
frame_a = engine._compose_frame(-1, 0)
time.sleep(0.05)
frame_b = engine._compose_frame(-1, 0)
# displayed level advances slightly toward the (same) target between calls, so allow the
# mouth region to differ a little, but nothing outside it may differ AT ALL, and there must
# be no time-dependent whole-frame warp artifact.
diff = np.abs(frame_a.astype(int) - frame_b.astype(int)).max(axis=2)
y0, y1, x0, x1 = engine.MOUTH_CROP
outside = diff.copy()
outside[y0:y1, x0:x1] = 0
print(f"[test] two _compose_frame() calls 50ms apart, outside mouth crop max diff: {outside.max()}")
assert outside.max() == 0, "no whole-frame time-dependent effect (sway) should exist outside the mouth crop"
print("[test] whole-frame idle sway confirmed removed (zero time-dependent change outside mouth crop): PASS")

# ---------------------------------------------------------------------------
# 3. Blink path: eye crop compositing must not alter pixels outside EYE_CROP,
#    and must not alter pixels outside MOUTH_CROP either (both stem from the
#    same fixed base frame).
# ---------------------------------------------------------------------------
ey0, ey1, ex0, ex1 = engine.EYE_CROP
my0, my1, mx0, mx1 = engine.MOUTH_CROP

# reset mouth-level state left over from the smoothing test above, so this
# section isolates the blink/eye compositing effect specifically
with engine._lock:
    engine._raw_audio_level = 0.0
engine._displayed_level = 0.0
for _ in range(50):  # let the release curve settle fully back to 0
    engine._update_displayed_level()

frame_open = engine._compose_frame(-1, 0)   # idle, no blink
frame_blink = engine._compose_frame(0, 0)   # blink phase 0 = eye_closed

diff2 = np.abs(frame_open.astype(int) - frame_blink.astype(int)).max(axis=2)
ys, xs = np.where(diff2 > 2)
assert ys.min() >= ey0 and ys.max() < ey1 and xs.min() >= ex0 and xs.max() < ex1, (
    f"blink-induced change leaked outside EYE_CROP! bbox=({ys.min()},{ys.max()},{xs.min()},{xs.max()}) "
    f"EYE_CROP={engine.EYE_CROP}"
)
print(f"[test] blink (idle vs closed) differences 100% confined to EYE_CROP "
      f"(bbox y={ys.min()}-{ys.max()} x={xs.min()}-{xs.max()}, crop={engine.EYE_CROP}): PASS")

# outside-mouth/eye corner must be byte-identical between idle and blink frames
corner_diff = diff2[0:80, 0:80].max()
assert corner_diff == 0, f"unrelated corner changed during blink (max diff {corner_diff})"
print("[test] unrelated background corner is byte-identical between idle and blink frames: PASS")

# ---------------------------------------------------------------------------
# 4. Real window smoke test (short)
# ---------------------------------------------------------------------------
sr.start()
time.sleep(1.0)
sr.set_audio_level(0.3)
time.sleep(0.3)
sr.set_audio_level(0.8)
time.sleep(0.3)
sr.set_audio_level(0.0)
time.sleep(0.3)
sr.stop()
print("[test] real window start -> audio level changes -> stop: PASS (no crash)")

# ---------------------------------------------------------------------------
# 5. legacy rollback + original assets unmodified (carried over from v2)
# ---------------------------------------------------------------------------
legacy = create_renderer("legacy")
from avatar_engine import AvatarEngine  # noqa: E402
assert type(legacy._engine) is AvatarEngine
print("[test] NARU_RENDERER=legacy still resolves to plain AvatarEngine: PASS")

import hashlib, os  # noqa: E402
expected = {
    "eye_closed.jpg": "3b7e44b1a8db28bc",
    "eye_half_open.jpg": "580b1f489cc2f3f8",
    "eye_open.jpg": "e68b09a461f778a1",
    "mouth_closed.jpg": "b76d6e9c926d683c",
    "mouth_half_open.jpg": "2bc21dd1a9c12e66",
    "mouth_open.jpg": "2b034311dff2fcb6",
}
for fname, expected_hash in expected.items():
    p = os.path.join("avatar_frames", fname)
    actual = hashlib.sha256(open(p, "rb").read()).hexdigest()[:16]
    assert actual == expected_hash, f"{fname} changed!"
print("[test] all 6 original avatar_frames files byte-identical: PASS")

print("\n=== ALL V3 CHECKS PASSED ===")
