"""
NARU interim native preview verification (v2: cropped+feathered mouth blend).
No paid API calls, no TikTok connection.

v1 regression this specifically guards against: whole-frame alpha blending
of the 3 mouth images caused visible flicker/"twitching" across the ENTIRE
frame (background, hair, clothing), because the source JPEGs are NOT
actually pixel-identical outside the mouth as originally assumed (verified:
mean abs diff ~9-20 even in clearly-unrelated regions). Kei saw this live
and described it as "looks like it's convulsing". v2 confines all blending
to a small, feathered mouth-only crop, always composited onto the same
fixed base image, so nothing outside that crop can ever change.
"""

import sys
import time

sys.path.insert(0, r"C:\Projects\vtuber_ai")

from renderer import create_renderer  # noqa: E402
import numpy as np  # noqa: E402

print("=== NARU interim native preview verification (v2) ===")

sr = create_renderer("legacy_smooth")
engine = sr._engine

# --- 1. mouth crop blending continuity ---
y0, y1, x0, x1 = engine.MOUTH_CROP
levels = [0.0, 0.1, 0.25, 0.5, 0.75, 1.0]
for lv in levels:
    crop = engine._blend_mouth_crop(lv)
    assert crop.shape == (y1 - y0, x1 - x0, 3), f"unexpected crop shape at level={lv}: {crop.shape}"
print(f"[test] _blend_mouth_crop produced correctly-shaped crops for {len(levels)} levels: PASS")

crop_low = engine._blend_mouth_crop(0.1)
crop_high = engine._blend_mouth_crop(0.9)
diff = np.abs(crop_low.astype(int) - crop_high.astype(int)).sum()
assert diff > 0, "different levels should produce visibly different mouth crops"
print(f"[test] mouth crop differs between low/high levels (sum abs diff={diff}): PASS")

# --- 2. THE KEY REGRESSION TEST: compositing must not change anything
#     outside MOUTH_CROP, regardless of audio level. Sway is neutralized so
#     this isolates the mouth-blend logic specifically. ---
engine._idle_sway_offset = lambda now: (0.0, 0.0)
engine._raw_audio_level = 0.0
frame_silent = engine._compose_frame(-1, 0)
engine._raw_audio_level = 1.0
frame_loud = engine._compose_frame(-1, 0)

diff_map = np.abs(frame_silent.astype(int) - frame_loud.astype(int)).max(axis=2)
changed = diff_map > 2
ys, xs = np.where(changed)
assert ys.min() >= y0 and ys.max() < y1 and xs.min() >= x0 and xs.max() < x1, (
    f"mouth-level change leaked outside MOUTH_CROP! changed bbox=({ys.min()},{ys.max()},{xs.min()},{xs.max()}) "
    f"MOUTH_CROP={engine.MOUTH_CROP}"
)
print(f"[test] level=0.0 vs level=1.0 differences are 100% confined to MOUTH_CROP "
      f"(changed bbox y={ys.min()}-{ys.max()} x={xs.min()}-{xs.max()}, crop={engine.MOUTH_CROP}): PASS")

# a clearly-unrelated corner (top-left, hair/background) must be byte-identical
corner_diff = diff_map[0:100, 0:100].max()
assert corner_diff == 0, f"unrelated corner region changed (max diff {corner_diff}) -- this is the v1 bug"
print("[test] unrelated background corner is byte-identical between silent and loud frames "
      "(this is exactly the v1 whole-frame-flicker bug, now fixed): PASS")

# --- 3. idle sway is small and periodic ---
del engine._idle_sway_offset  # restore the real bound method
offsets = [engine._idle_sway_offset(t) for t in [0, 1, 2, 3, 4, 5]]
max_abs = max(max(abs(dx), abs(dy)) for dx, dy in offsets)
print(f"[test] idle sway offsets over one period: {offsets}")
assert max_abs <= engine.IDLE_SWAY_AMPLITUDE_PX + 0.01, "sway must stay within the configured small amplitude"
print(f"[test] idle sway stays within {engine.IDLE_SWAY_AMPLITUDE_PX}px amplitude: PASS")

# --- 4. real window smoke test (short) ---
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

# --- 5. legacy rollback still produces plain AvatarEngine, unaffected ---
legacy = create_renderer("legacy")
from avatar_engine import AvatarEngine  # noqa: E402
assert type(legacy._engine) is AvatarEngine, "legacy must still resolve to the plain AvatarEngine class"
print("[test] NARU_RENDERER=legacy (or default) still resolves to plain AvatarEngine: PASS")

# --- 6. original asset files unmodified ---
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
    assert actual == expected_hash, f"{fname} changed! expected {expected_hash}, got {actual}"
print("[test] all 6 original avatar_frames files byte-identical to before this test run: PASS")

print("\n=== ALL INTERIM PREVIEW CHECKS PASSED (v2) ===")
