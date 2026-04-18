# Chain Relationship

## Overview

| Chain | Source of Truth Level | Main Producer | Main Output | What It Is Used For | Should Be Modified Carefully? |
|---|---|---|---|---|---|
| `CPP` | Highest reference | `refactor/bittrue/cpp/*`, `main_batch.exe`, `main_block0_y.exe` | `cpp_full_int16.npy`, `cpp_block0_y_cppbittrue.npy` | Reference numerical behavior for block-level comparison | Yes |
| `golden` | Stage reference derived from bittrue flow | `refactor/bittrue/export_hw_debug.py` | `stages/reuse_mamba_block_top/*.mem` | Stage-by-stage expected outputs for hardware comparison | Yes |
| `RTL` | Actual hardware implementation | Vivado/XSim via `HW_reconstruct/hw_debug/vivado/run_xsim_stage.py` | `rtl_out/reuse_mamba_block_top/*.mem` | Verifies hardware stage outputs against golden mem files | Yes |
| `hw_like` | Python approximation of hardware behavior | `refactor/bittrue/eval_hw_like_full.py` | `full_hw_like_eval.json`, internal per-stage traces | Helps debug where Python hardware model diverges from CPP | Yes, but only to match verified RTL/golden semantics |

## Current Validation Status

| Comparison | Current Status | Evidence |
|---|---|---|
| `RTL vs golden` | Matched | `logs/compare_reuse_mamba_block_top.json` |
| `CPP vs cppish` | Nearly matched | `logs/full_hw_like_eval.json` |
| `hw_like vs CPP` | Improved but not fully matched | `logs/full_hw_like_eval.json` |

## Practical Interpretation

- `CPP` is the numeric reference.
- `golden` is exported from the reference flow and used as stage-level expected data.
- `RTL` is the real hardware path. If `RTL vs golden` matches, hardware stage semantics are considered aligned.
- `hw_like` is not the golden source. It is only a Python-side hardware approximation used for debugging block-level error accumulation.

## Important Rule

When `RTL vs golden` already matches, but `hw_like vs CPP` is still bad, the first suspect is `hw_like`, not RTL and not the golden mem files.
