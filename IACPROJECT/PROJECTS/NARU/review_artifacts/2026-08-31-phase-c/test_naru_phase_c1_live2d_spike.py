"""
NARU Phase C1 — Live2D technical spike verification.
No paid API calls. No model asset installed/downloaded (ASSET BLOCKED, by design).

Covers the required tests from
IACPROJECT/inbox/from_arc/2026-08-31_ARC_TO_SATO_NARU_RENDERER_PHASE_C0_C1.md
that are reachable without SDK/asset:
  1. renderer boots independently from NARU core -- N/A here (ASSET BLOCKED,
     see test 2/3 for what IS verifiable: clean, isolated failure instead)
  2. synthetic 0->mid->high->0 audio values produce continuous/meaningful
     mouth parameter change (pure mapping-function test, no SDK needed)
  4. deliberate renderer exception invokes Phase C0 isolation and core
     synthetic job still completes
  5. switching back to NARU_RENDERER=legacy restores current renderer
     without code rollback
"""

import os
import sys

sys.path.insert(0, r"C:\Projects\vtuber_ai")

import renderer as rnd  # noqa: E402
import live2d_renderer as l2d  # noqa: E402

print("=== NARU Phase C1 Live2D spike verification ===")

# ---------------------------------------------------------------------------
# Test 2 (of Arc's required list): synthetic 0->mid->high->0 audio produces
# continuous/meaningful mouth parameter change. Pure function, no SDK/asset
# needed -- this is exactly the connection-point logic that stays valid
# regardless of whether the SDK is actually installed today.
# ---------------------------------------------------------------------------
sequence = [0.0, 0.25, 0.5, 0.75, 1.0, 0.6, 0.3, 0.0]
mapped = [l2d.audio_level_to_mouth_param(v) for v in sequence]
print(f"[test] audio_level_to_mouth_param sequence: {sequence} -> {mapped}")

assert mapped == sequence, "in-range values should map 1:1 (linear, no discretization)"
distinct_values = len(set(mapped))
assert distinct_values >= 6, (
    f"expected mostly-continuous output (>=6 distinct values across 8 samples), got {distinct_values}"
)
print(f"[test] mapping is continuous, not discretized like legacy's 3-level system "
      f"({distinct_values} distinct values across {len(sequence)} samples): PASS")

# clamping behavior for out-of-range input
assert l2d.audio_level_to_mouth_param(-0.5) == 0.0
assert l2d.audio_level_to_mouth_param(1.5) == 1.0
print("[test] out-of-range input clamps to [0.0, 1.0]: PASS")

# ---------------------------------------------------------------------------
# SDK/asset-missing failure mode: create_renderer("live2d") should raise
# clearly (no live2d-py installed, no model asset present -- both by design,
# see live2d_renderer.py docstring).
# ---------------------------------------------------------------------------
try:
    rnd.create_renderer("live2d")
    raise AssertionError("expected a clear failure since live2d-py/model asset are not present")
except RuntimeError as e:
    print(f"[test] create_renderer('live2d') fails clearly as ASSET BLOCKED: {e}")

# ---------------------------------------------------------------------------
# Test 4 (of Arc's required list): deliberate renderer exception invokes
# Phase C0 isolation and a synthetic core job still completes.
# (Reuses the exact isolation mechanism verified in the Phase C0 test --
# here the "deliberate exception" is the real ASSET BLOCKED failure, not a
# synthetic test double, which is a stronger proof than Phase C0's own test.)
# ---------------------------------------------------------------------------
import threading  # noqa: E402
import app_live2d as app  # noqa: E402

app.avatar_engine = rnd.create_isolated_renderer("live2d")
assert app.avatar_engine.is_offline, "live2d renderer with no SDK/asset should be offline immediately"
print(f"[test] create_isolated_renderer('live2d') -> offline (real ASSET BLOCKED failure): "
      f"{app.avatar_engine.offline_reason}")

calls = []

def fake_speak(text, voice_id=app.DEFAULT_VOICE, voice_settings=None, job_id=None):
    calls.append(job_id)
    app.avatar_engine.set_volume(0.5)  # must be a silent no-op, renderer is offline
    return True

app.speak = fake_speak
assert app.conversation_memory == []
threading.Thread(target=app.tts_worker, daemon=True).start()
app.tts_queue.put({"id": 1, "response_text": "LIVE2D_SPIKE_JOB"})
app.tts_queue.join()
assert "Noll: LIVE2D_SPIKE_JOB" in app.conversation_memory
print("[test] core queue job completed with the (real, ASSET BLOCKED) live2d renderer offline: PASS")

# ---------------------------------------------------------------------------
# Test 5 (of Arc's required list): switching back to NARU_RENDERER=legacy
# restores current renderer without code rollback.
# ---------------------------------------------------------------------------
os.environ["NARU_RENDERER"] = "legacy"
proxy_back = rnd.create_isolated_renderer()  # no explicit name -> reads env var
assert not proxy_back.is_offline
assert isinstance(proxy_back._real, rnd.LegacyFrameRenderer)
print("[test] NARU_RENDERER=legacy env var restores legacy renderer with zero code changes: PASS")
del os.environ["NARU_RENDERER"]

print("\n=== ALL PHASE C1 SPIKE CHECKS PASSED (SPIKE PASS / ASSET BLOCKED) ===")
