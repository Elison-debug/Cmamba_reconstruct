# Debug Stages

## Purpose

This note records the main mismatch sources found so far, and the minimal fixes applied to the Python `hw_like` model.

## Stage Summary

| Stage | Symptom | Root Cause | Fix Applied | Result |
|---|---|---|---|---|
| `norm` | Small mismatch only | `hw_like` norm path was using a looser approximation than the stage-exported hardware-aligned path | Switched `eval_hw_like_full.py` to use `_rmsnorm_q88_hw` semantics | Improved consistency, but not the main error source |
| `inproj` | Small mismatch only | Minor trace-level differences only | No major structural fix required yet | Stayed low |
| `silu_gate` | Small mismatch only | Downstream effect was limited | No major structural fix required yet | Stayed low |
| `dtproj` | Very large mismatch (`~81` MAE in stage debug) | `u_act` was already quantized to `Q8.8`, but `hw_like` sent it through a path that quantized it again | Replaced `_conv1x1_q88_rne_clamp_tc(...)` with direct `_conv1x1_q88_rne_clamp(...)` on already-quantized tensors | Reduced `dtproj` MAE to `~0.036` |
| `dt_sigmoid` | Medium mismatch | Mostly propagated from wrong `dtproj` input scaling | Fixed indirectly by the `dtproj` correction | Reduced to `~0.0075` |
| `selective_scan` | Now the largest remaining mismatch | Python `hw_like` selective-scan semantics still do not fully match the verified stage flow | Not fixed yet | Still the next priority |
| `ewm_gating` | Moderate mismatch | Largely downstream of selective-scan mismatch | Not fixed yet | Still visible |
| `outproj` | Moderate mismatch | Mostly propagated from upstream scan/gating error | Not fixed directly yet | Still visible but much smaller than before |
| `block_output` | Large block-level error before fixes | Accumulated effect of wrong `dtproj` path and residual model mismatch | Fixed `dtproj` path and removed unnecessary block-boundary requant on `residual + y_blk` | Overall `hw_like_vs_cpp.mae` dropped from `~0.5322` to `~0.0675` |

## Change Log

### 1. Norm alignment in `hw_like`
- File: `refactor/bittrue/eval_hw_like_full.py`
- Change: replaced approximate norm handling with `_rmsnorm_q88_hw`-aligned behavior.
- Reason: match the already verified stage-export path.

### 2. Block residual boundary handling
- File: `refactor/bittrue/eval_hw_like_full.py`
- Change: removed extra requantization on `residual + y_blk` at block boundary.
- Reason: keep block-output semantics closer to the verified stage model.

### 3. `dtproj` input format fix
- File: `refactor/bittrue/eval_hw_like_full.py`
- Change: treated `u_act_q88_rows` as already-quantized `Q8.8` and used direct `_conv1x1_q88_rne_clamp(...)`.
- Reason: avoid double quantization of `u_act`.
- Effect: this was the main error fix.

### 4. Stage-oriented debug trace expansion
- Files:
  - `refactor/bittrue/eval_hw_like_full.py`
  - `refactor/bittrue/debug_dt_chain_mismatch.py`
- Change: expanded debug traces to report these stages:
  - `norm`
  - `inproj_u`
  - `inproj_z`
  - `silu_gate`
  - `dtproj`
  - `dt_sigmoid`
  - `selective_scan`
  - `ewm_gating`
  - `outproj`
  - `block_output`
- Reason: make the first failing stage obvious.

## Current State

- `RTL vs golden`: matched.
- `CPP vs cppish`: nearly matched.
- `hw_like vs CPP`: improved significantly, but still not fully aligned.
- Current first major remaining mismatch: `selective_scan`.

## Next Step

Align `selective_scan` in `refactor/bittrue/eval_hw_like_full.py` against the verified export/stage semantics before touching downstream `ewm_gating` and `outproj`.
