"""
NARU interim native preview verification.
No paid API calls, no TikTok connection.
"""

import sys
import time

sys.path.insert(0, r"C:\Projects\vtuber_ai")

from renderer import create_renderer  # noqa: E402

print("=== NARU interim native preview verification ===")

# --- 1. mouth blending continuity (pure logic check via internal method) ---
sr = create_renderer("legacy_smooth")
engine = sr._engine
levels = [0.0, 0.1, 0.25, 0.5, 0.75, 1.0]
shapes = []
for lv in levels:
    frame = engine._blend_mouth_frame(lv)
    shapes.append(frame.shape)
assert all(s == shapes[0] for s in shapes), "blended frames should keep the original resolution"
print(f"[test] _blend_mouth_frame produced {len(levels)} frames, all same shape {shapes[0]}: PASS")

# confirm blending actually differs between adjacent levels (not a no-op)
import numpy as np  # noqa: E402
f_low = engine._blend_mouth_frame(0.1)
f_high = engine._blend_mouth_frame(0.9)
diff = np.abs(f_low.astype(int) - f_high.astype(int)).sum()
assert diff > 0, "different levels should produce visibly different blended frames"
print(f"[test] blended frames differ between low/high levels (sum abs diff={diff}): PASS")

# confirm endpoints match the original discrete frames closely (t=0/1 blend = pure source)
f0 = engine._blend_mouth_frame(0.0)
diff0 = np.abs(f0.astype(int) - engine._mouth_frames[0].astype(int)).sum()
assert diff0 == 0, "level=0.0 should reproduce mouth_closed.jpg exactly"
print("[test] level=0.0 blend exactly reproduces the original mouth_closed frame (no new pixels invented): PASS")

# --- 2. idle sway is small and periodic ---
offsets = [engine._idle_sway_offset(t) for t in [0, 1, 2, 3, 4, 5]]
max_abs = max(max(abs(dx), abs(dy)) for dx, dy in offsets)
print(f"[test] idle sway offsets over one period: {offsets}")
assert max_abs <= engine.IDLE_SWAY_AMPLITUDE_PX + 0.01, "sway must stay within the configured small amplitude"
print(f"[test] idle sway stays within {engine.IDLE_SWAY_AMPLITUDE_PX}px amplitude: PASS")

# --- 3. real window smoke test (short) ---
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

# --- 4. legacy rollback still produces plain AvatarEngine, unaffected ---
legacy = create_renderer("legacy")
from avatar_engine import AvatarEngine  # noqa: E402
assert type(legacy._engine) is AvatarEngine, "legacy must still resolve to the plain AvatarEngine class"
print("[test] NARU_RENDERER=legacy (or default) still resolves to plain AvatarEngine: PASS")

# --- 5. original asset files unmodified ---
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

print("\n=== ALL INTERIM PREVIEW CHECKS PASSED ===")
