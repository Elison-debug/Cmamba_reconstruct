# CPP vs RTL Selective Scan Gap

## Purpose

This note records the current evidence around the selective-scan mismatch between the C++ reference path and the RTL/hardware path.

The goal is to prevent premature RTL changes before the project agrees on which numeric semantics are the actual sign-off target.

## Current Status

### What is already aligned

- `RTL vs golden mem`: aligned
- Case: `test_case3_norm_smoke`
- Evidence:
  - `logs/compare_reuse_mamba_block_top.json` -> `match = true`

This means the current RTL implementation matches the exported hardware-stage golden files for:
- `norm`
- `inproj`
- `silu_gate`
- `dtproj`
- `dt_sigmoid`
- `selective_scan`
- `ewm_gating`
- `outproj`

### What is still not aligned

- `hw_like Python vs CPP`: not fully aligned
- Evidence:
  - `logs/full_hw_like_eval.json`
  - `logs/dt_chain_debug_sample0.json`

After fixing the `dtproj` input-format bug in `hw_like`, the first major remaining mismatch is now:
- `selective_scan`

## Key Finding

The remaining selective-scan mismatch is no longer best explained as a Python implementation bug.

Instead, the evidence indicates that:
- the current `CPP` selective-scan semantics
- and the current RTL/export selective-scan semantics

are not the same algorithmic/quantized implementation.

## Why This Matters

If the mismatch is caused by a real semantic gap, then reducing `hw_like_vs_cpp` further by editing Python alone would risk making the Python model less representative of actual hardware.

Likewise, directly changing RTL to match CPP would be a design decision, not a bug fix.

## Concrete Semantic Differences

## 1. `lam` quantization format

### CPP
File: `refactor/bittrue/cpp/ref_infer.cpp`

- `lam` is quantized with `frac_bits = 15`
- effectively treated as `Q0.15`
- uses ties-to-even rounding

### RTL / export
File: `refactor/bittrue/export_hw_debug.py`

- `lam` is first represented as `Q0.16`
- hardware update uses `lam_q016 >> 8`
- this becomes an unsigned `Q8.8` factor
- this is truncation, not ties-to-even rounding

### Consequence
The same sigmoid output is not converted to the same fixed-point value.

## 2. State update arithmetic

### CPP
- one combined multiply-accumulate expression
- final right shift with rounding
- final saturation/clamp

### RTL / export
- two separate `Q8.8 * Q8.8` products
- hardware-style intermediate quantization
- final addition uses wrap behavior

### Consequence
Even if inputs were identical, state evolution can diverge over time.

## 3. State storage model

### CPP
- linear per-channel state vector
- no SRAM addressing behavior
- no bypass/read-after-write timing semantics

### RTL / export
- explicit SRAM-like state model
- read address: `s_addr = t % state_depth`
- write address: `s_addr + 1`
- bypass through `last_wr_valid / last_wr_addr / last_wr_data`

### Consequence
The recurrence path is structurally different.

## 4. `u` quantization inside selective scan

### CPP
- dynamic per-channel `state_scale`
- quantize/dequantize around that scale

### RTL / export
- input is already fixed `Q8.8`
- no dynamic per-channel state scale in the state-update operator

### Consequence
The state input representation is fundamentally different.

## 5. Gating path

### CPP
- uses dynamic `gate_scale`
- quantize/dequantize around that scale

### RTL / export
- direct fixed-point `Q8.8 x Q8.8 -> Q8.8`
- no extra dynamic scale path

### Consequence
Downstream gated output differs even if scan state is close.

## What Has Been Proven So Far

## Proven true

1. RTL matches exported stage golden files.
2. `dtproj` mismatch in `hw_like` was a Python-side modeling bug and was fixed.
3. After the `dtproj` fix, `selective_scan` became the dominant remaining gap.
4. `hw_like selective_scan` is already closer to golden/hardware than `CPP selective_scan` is.

## Not yet proven

1. That RTL is numerically wrong.
2. That CPP is the only valid sign-off golden for selective scan.
3. That RTL should be changed before project-level sign-off criteria are agreed.

## Decision Risk

Changing RTL now would mean changing:
- `lam` format handling
- state-update arithmetic
- SRAM/state timing semantics
- gating numeric semantics
- exported golden files
- regression expectations across existing hardware-debug cases

This is not a small quantization tweak. It is a design-level behavior change.

## Recommendation

Do **not** immediately change RTL to match CPP selective-scan semantics.

Instead:

1. Treat the current mismatch as a semantic gap, not yet as an RTL bug.
2. Keep `test_case3_norm_smoke` as the standard case for `RTL vs golden` validation.
3. Document the selective-scan semantic gap clearly.
4. Ask for a project-level decision:
   - Is `CPP` the only sign-off golden?
   - Or is the current hardware/export path an accepted hardware-specific numeric realization?

## If the team decides `CPP` is the final sign-off golden

Then the next work should be a controlled redesign plan, not an ad-hoc RTL patch.

That redesign must cover:
- `lam` numeric format
- state update operator
- state memory behavior
- gating quantization
- updated stage golden export path
- full regression reruns

## If the team decides hardware semantics are acceptable

Then:
- keep the RTL as-is
- keep exported stage golden as-is
- align Python `hw_like` only to hardware behavior
- accept that `CPP` and hardware selective-scan are intentionally different

## Current Practical Conclusion

At this point:
- `RTL vs golden` should be trusted
- `CPP vs RTL selective_scan` should be treated as an unresolved semantic discrepancy
- the project should make a sign-off decision before RTL changes are made
