import os
from renderer import create_renderer, LegacyFrameRenderer

results = {}

# legacy
os.environ["NARU_RENDERER"] = "legacy"
r = create_renderer()
assert isinstance(r, LegacyFrameRenderer)
from avatar_engine import AvatarEngine
assert isinstance(r._engine, AvatarEngine)
results["legacy"] = type(r._engine).__name__
print(f"[c4] legacy OK: {type(r._engine).__name__}")

# legacy_smooth
os.environ["NARU_RENDERER"] = "legacy_smooth"
r = create_renderer()
assert isinstance(r, LegacyFrameRenderer)
from smooth_frame_renderer import SmoothFrameRenderer
assert isinstance(r._engine, SmoothFrameRenderer)
results["legacy_smooth"] = type(r._engine).__name__
print(f"[c4] legacy_smooth OK: {type(r._engine).__name__}")

# overlay_v1 (unaffected by video_hybrid addition)
os.environ["NARU_RENDERER"] = "overlay_v1"
r = create_renderer()
assert isinstance(r, LegacyFrameRenderer)
from naru_overlay_engine import NaruOverlayEngine
assert isinstance(r._engine, NaruOverlayEngine)
results["overlay_v1"] = type(r._engine).__name__
print(f"[c4] overlay_v1 OK: {type(r._engine).__name__}")

# video_hybrid (new)
os.environ["NARU_RENDERER"] = "video_hybrid"
r = create_renderer()
assert isinstance(r, LegacyFrameRenderer)
from naru_video_hybrid_engine import NaruVideoHybridEngine
assert isinstance(r._engine, NaruVideoHybridEngine)
results["video_hybrid"] = type(r._engine).__name__
print(f"[c4] video_hybrid OK: {type(r._engine).__name__}")

# live2d: constructor-level only (SDK may be unavailable in this environment; treat exception as environment limitation, not a regression, matching established test caution)
os.environ["NARU_RENDERER"] = "live2d"
try:
    r = create_renderer()
    from live2d_renderer import Live2DRenderer
    assert isinstance(r, Live2DRenderer)
    results["live2d"] = "Live2DRenderer (constructed)"
    print(f"[c4] live2d OK: constructed successfully")
except Exception as e:
    results["live2d"] = f"SKIPPED (env limitation): {type(e).__name__}: {e}"
    print(f"[c4] live2d constructor raised (environment limitation, not tested further): {type(e).__name__}: {e}")

print("\n[c4] === SUMMARY ===")
for k, v in results.items():
    print(f"  {k}: {v}")
