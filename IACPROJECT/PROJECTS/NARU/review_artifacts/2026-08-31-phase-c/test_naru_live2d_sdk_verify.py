"""
NARU Phase C1 -- live2d-py / Cubism Core SDK verification (post-install).
No model asset used or required. No paid API calls.
"""

import sys
sys.path.insert(0, r"C:\Projects\vtuber_ai")

import live2d.v3 as live2d  # noqa: E402
import live2d_renderer as l2d  # noqa: E402
import renderer as rnd  # noqa: E402

print("=== NARU Live2D SDK verification (post-install) ===")

# 1. SDK-level init (no model needed)
assert hasattr(live2d.StandardParams, "ParamMouthOpenY"), "expected ParamMouthOpenY in StandardParams"
live2d.init()
print("[test] live2d.init() succeeded (Cubism Native Core initialized)")
print(f"[test] StandardParams.ParamMouthOpenY exists: {live2d.StandardParams.ParamMouthOpenY!r}")

# 2. mapping function unaffected by real SDK presence (still a pure function)
seq = [0.0, 0.5, 1.0]
mapped = [l2d.audio_level_to_mouth_param(v) for v in seq]
assert mapped == seq
print(f"[test] audio_level_to_mouth_param still pure/continuous: {seq} -> {mapped}")

# 3. Live2DRenderer construction: SDK now imports fine, but still ASSET BLOCKED
#    on the missing model path -- confirms the isolation gate now fails on the
#    *correct*, more specific reason (model asset, not missing SDK).
try:
    l2d.Live2DRenderer()
    raise AssertionError("expected RuntimeError: no model asset configured")
except RuntimeError as e:
    msg = str(e)
    assert "model asset" in msg or "モデルasset" in msg, f"expected model-asset-specific message, got: {msg}"
    assert "live2d-py" not in msg.split("SDK")[0] or "未導入" not in msg, "should not claim SDK missing anymore"
    print(f"[test] Live2DRenderer() now fails specifically on missing MODEL, not missing SDK: {msg}")

# 4. Phase C0 isolation still correctly absorbs this (now real, not synthetic) failure
proxy = rnd.create_isolated_renderer("live2d")
assert proxy.is_offline
assert "model asset" in proxy.offline_reason or "モデルasset" in proxy.offline_reason
print(f"[test] Phase C0 isolation proxy correctly absorbs the real ASSET BLOCKED failure: "
      f"{proxy.offline_reason}")

print("\n=== SDK VERIFIED: init OK, ParamMouthOpenY OK, still ASSET BLOCKED on model only ===")
