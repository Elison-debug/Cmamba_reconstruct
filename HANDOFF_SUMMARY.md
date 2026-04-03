# Handoff Summary

## Project Goal

This repository currently has two main tracks:

1. Software / quantization track
- Build a usable bit-true reference for slim-Mamba inference.
- Measure quantization accuracy loss.
- Identify sensitive layers and mixed-precision candidates.
- Use the C++ route as the main end-to-end accuracy reference.

2. Hardware / RTL track
- Bring up the FPGA-oriented RTL in `HW_reconstruct`.
- Align each hardware stage against a software-generated golden reference.
- Eventually run on ZCU102 and compare hardware behavior against the software bit-true route.

The most important current unresolved issue is:
- The `dt` path in RTL is being rewritten to match the C++ / software semantics.

---

## Important Directories

### Main software / bittrue path
- [refactor/bittrue](./refactor/bittrue)
- [refactor/bittrue/cpp](./refactor/bittrue/cpp)

Key files:
- [refactor/bittrue/config.py](./refactor/bittrue/config.py)
- [refactor/bittrue/pack.py](./refactor/bittrue/pack.py)
- [refactor/bittrue/run_export.py](./refactor/bittrue/run_export.py)
- [refactor/bittrue/eval_bittrue.py](./refactor/bittrue/eval_bittrue.py)
- [refactor/bittrue/reference.pt](./refactor/bittrue/reference.pt)
- [refactor/bittrue/export_hw_debug.py](./refactor/bittrue/export_hw_debug.py)
- [refactor/bittrue/promote_dt_hw_golden.py](./refactor/bittrue/promote_dt_hw_golden.py)
- [refactor/bittrue/compare_hw_dump.py](./refactor/bittrue/compare_hw_dump.py)

### Main hardware / RTL path
- [HW_reconstruct](./HW_reconstruct)

Key subdirectories:
- [HW_reconstruct/rtl_reuse_shared](./HW_reconstruct/rtl_reuse_shared)
- [HW_reconstruct/tb](./HW_reconstruct/tb)
- [HW_reconstruct/hw_debug](./HW_reconstruct/hw_debug)
- [HW_reconstruct/project_mamba_all1](./HW_reconstruct/project_mamba_all1)

### Built C++ binaries
- [build/bittrue](./build/bittrue)

---

## Main Scripts

### Existing project scripts
- [train.bat](./train.bat)
- [eval.bat](./eval.bat)
- [export.bat](./export.bat)
- [build_bittrue.bat](./build_bittrue.bat)

### Bittrue evaluation
- [run_bittrue_recommended_full.bat](./run_bittrue_recommended_full.bat)
- [run_bittrue_test_focus.bat](./run_bittrue_test_focus.bat)

### Vivado / GUI
- [open_vivado_project.bat](./open_vivado_project.bat)
- [open_hw_debug_xsim_gui.bat](./open_hw_debug_xsim_gui.bat)

---

## Current Software Flow

### 1. Export a bittrue package

```bat
export.bat export_bittrue\case1
```

Default checkpoint:
- [refactor/bittrue/reference.pt](./refactor/bittrue/reference.pt)

### 2. Build the C++ tools

```bat
build_bittrue.bat all
```

### 3. Run bittrue evaluation

Quick focused run:

```bat
run_bittrue_test_focus.bat
```

Full recommended run:

```bat
run_bittrue_recommended_full.bat
```

Notes:
- `eval_bittrue.py` now supports fixed cache files:
  - `float/samples.npy`
  - `float/y_true.npy`
  - `float/y_float.npy`
- Cases reuse the same `samples.npy`
- `compare.csv` is optional
- Case-level parallelism is supported
- `--preload` is enabled in the helper scripts

---

## Current Hardware Flow

### 1. Export an hw_debug case

```bat
python -m refactor.bittrue.export_hw_debug --ckpt refactor/bittrue/reference.pt --feat_root ./data/features/parity_2100 --target test --preload --limit 8 --export_dir export_bittrue/case1 --out_dir HW_reconstruct/hw_debug/cases/test_case3_smoke
```

### 2. Run Vivado xsim for a stage

Example:

```bat
python HW_reconstruct/hw_debug/vivado/run_xsim_stage.py --stage reuse_mamba_block_top_hw_debug --case_dir HW_reconstruct/hw_debug/cases/test_case3_smoke --clean
```

### 3. Open GUI for waveform debug

```bat
open_hw_debug_xsim_gui.bat
```

Open the full Vivado project:

```bat
open_vivado_project.bat
```

---

## What Has Been Completed

### Repository structure cleanup
The active bittrue route has been consolidated under:
- [refactor/bittrue](./refactor/bittrue)

Older routes under:
- `refactor/export`
- `refactor/runtime_cpp`
- old `int16` experiments

have been largely deprecated or removed from the active workflow.

### C++ bittrue route
The following are working:
- `main_full`
- `main_batch`
- `eval_bittrue.py`
- fake/int16/int8/mixed-precision sweeps

This route is still the main end-to-end quantization-loss reference.

### Layer sensitivity conclusions
Observed sensitive layers:
- `patch_embedding`
- `in_proj`
- `out_proj`

Observed relatively tolerant layers:
- `dt_proj`
- `gate`
- `ssm_state`

Current practical mixed-precision candidate:
- keep `patch/in_proj/out_proj/head` at higher precision
- reduce `dt_proj/gate/ssm_state`

### Vivado + real project IP integration
The xsim flow now uses the actual project IP wrappers from:
- `project_mamba_all1.gen/sources_1/ip/*/sim/*.v`

It no longer depends on custom blackbox FIFO/BRAM stubs for the main hw_debug route.

### RTL bring-up status achieved before the new dt rewrite
The following hardware chain had already been debugged and aligned against `export_hw_debug.py` golden:
- `in_proj -> u/z SRAM`
- `z -> SiLU`
- `reuse_ssm_core` through `gate_y`
- `p_capture / u_p_sram`
- `out_proj`
- top local `y`

Important files previously fixed during this process:
- [HW_reconstruct/rtl_reuse_shared/reuse_reduction_accumulator.sv](./HW_reconstruct/rtl_reuse_shared/reuse_reduction_accumulator.sv)
- [HW_reconstruct/rtl_reuse_shared/reuse_in_proj_scheduler.sv](./HW_reconstruct/rtl_reuse_shared/reuse_in_proj_scheduler.sv)
- [HW_reconstruct/rtl_reuse_shared/bias_add_regslice_ip.sv](./HW_reconstruct/rtl_reuse_shared/bias_add_regslice_ip.sv)
- [HW_reconstruct/rtl_reuse_shared/ew_update_vec4.sv](./HW_reconstruct/rtl_reuse_shared/ew_update_vec4.sv)
- [HW_reconstruct/rtl_reuse_shared/reuse_outproj_multi_bank_wbuf_dp.sv](./HW_reconstruct/rtl_reuse_shared/reuse_outproj_multi_bank_wbuf_dp.sv)
- [HW_reconstruct/rtl_reuse_shared/reuse_mamba_block_top.sv](./HW_reconstruct/rtl_reuse_shared/reuse_mamba_block_top.sv)
- [HW_reconstruct/tb/tb_reuse_mamba_block_top_hw_debug.sv](./HW_reconstruct/tb/tb_reuse_mamba_block_top_hw_debug.sv)

---

## Two Current Reference Paths

There are now two distinct reference paths:

### 1. Main C++ bittrue route
Files:
- [refactor/bittrue/cpp/ref_infer.cpp](./refactor/bittrue/cpp/ref_infer.cpp)
- [refactor/bittrue/eval_bittrue.py](./refactor/bittrue/eval_bittrue.py)

Purpose:
- End-to-end quantization-loss evaluation
- Main software-side accuracy reference

This still matches float closely.

### 2. `export_hw_debug.py` route
File:
- [refactor/bittrue/export_hw_debug.py](./refactor/bittrue/export_hw_debug.py)

Purpose:
- Generate stage-level golden files for RTL / xsim debugging
- Hardware bring-up reference

This is not currently the same thing as the end-to-end C++ route.

---

## Important Quantitative Result Before the New dt Rewrite

When comparing local block-level `y`:

- `float` vs `cpp`
  - MAE about `0.00099`

- `float` vs `hardware/export_hw_debug`
  - MAE about `0.0687`

- `cpp` vs `hardware/export_hw_debug`
  - MAE about `0.0685`

Interpretation:
- `float` and `cpp` are still very close
- `RTL` and `export_hw_debug` matched each other
- But `RTL/export_hw_debug` still differed significantly from `cpp/float`
- The main reason was identified as the `dt` semantic mismatch

Reference logs:
- [HW_reconstruct/hw_debug/cases/test_case3_smoke/logs/final_compare_float_export_hw.json](./HW_reconstruct/hw_debug/cases/test_case3_smoke/logs/final_compare_float_export_hw.json)
- [HW_reconstruct/hw_debug/cases/test_case3_smoke/logs/final_compare_cpp_export_hw.json](./HW_reconstruct/hw_debug/cases/test_case3_smoke/logs/final_compare_cpp_export_hw.json)

---

## Current Main Task In Progress

The repository is now in the middle of a major rewrite of the `dt` path so that hardware semantics match the C++ / software semantics.

### Reason
The old RTL `dt` path was internally self-consistent, but not equivalent to the main software/cpp definition of:
- `u_act -> dt_proj -> sigmoid -> lam`

### Current rewrite direction
Do not preserve backward compatibility.

The new target is:
- rewrite `reuse_ssm_dt_scheduler.sv`
- rewrite `export_hw_debug.py` dt weight export
- make dt hardware directly implement the cpp-aligned `W*x`

### Files currently being actively reworked
- [HW_reconstruct/rtl_reuse_shared/reuse_ssm_dt_scheduler.sv](./HW_reconstruct/rtl_reuse_shared/reuse_ssm_dt_scheduler.sv)
- [refactor/bittrue/export_hw_debug.py](./refactor/bittrue/export_hw_debug.py)
- [HW_reconstruct/tb/tb_reuse_ssm_dt_scheduler_hw_debug.sv](./HW_reconstruct/tb/tb_reuse_ssm_dt_scheduler_hw_debug.sv)
- [HW_reconstruct/rtl_reuse_shared/reuse_mamba_block_top.sv](./HW_reconstruct/rtl_reuse_shared/reuse_mamba_block_top.sv)

---

## Current Status Of The New dt Rewrite

### What has already changed
In the rewrite attempt:

1. `export_hw_debug.py`
- `dt` weights are no longer exported with the old `%6` bank layout
- new cpp-aligned layout is used:
  - `bank = array index 0..3`
  - `addr = row_tile * groups + group`
  - banks 4/5 zero-filled for compatibility

2. `reuse_ssm_dt_scheduler.sv`
- the old scheduler logic is being replaced
- old `phase_reg / addr_bank_cnt / modulo-bank` control is no longer the goal
- new scheduler is intended to be a dedicated cpp-aligned `dt_proj` scheduler

3. `tb_reuse_ssm_dt_scheduler_hw_debug.sv`
- standalone dt TB now verifies the new scheduler against:
  - `u_act_in_q88.mem`
  - `dt_golden_q88.mem`
  - `xt_golden_q88.mem`
  - new `dt_wbuf_bank*.mem`

### What is already verified
- The new exported `dt` weight layout itself is correct.
- Python re-computation from the exported banks reproduces the `dt_golden_q88.mem` exactly.
- The new standalone dt xsim simulation now:
  - compiles
  - runs through all tokens
  - no longer deadlocks

### What is not solved yet
The new standalone dt scheduler still mismatches the golden numerically.

Current problem:
- the standalone `reuse_ssm_dt_scheduler` still has A/B/valid pipeline alignment issues relative to the shared 4-array MAC fabric

In other words:
- export layout is correct
- desired math is correct
- current remaining bug is in RTL timing / staging

Latest xsim log:
- [HW_reconstruct/hw_debug/vivado_runs/reuse_ssm_dt_scheduler_hw_debug/xsim.log](./HW_reconstruct/hw_debug/vivado_runs/reuse_ssm_dt_scheduler_hw_debug/xsim.log)

---

## What The Next Conversation Should Continue Doing

Priority 1:
- Continue debugging the new cpp-aligned standalone `dt` scheduler until:
  - standalone `reuse_ssm_dt_scheduler` matches `dt_golden_q88.mem`
  - `xt` stream matches

Priority 2:
- Reconnect the corrected new `dt` scheduler into:
  - `reuse_ssm_core`
  - `reuse_mamba_block_top`

Priority 3:
- Re-run top xsim and re-check:
  - `dt`
  - `lam`
  - `ssm`
  - `gate`
  - `y`

Priority 4:
- Re-run the three-way comparison:
  - `cpp`
  - `export_hw_debug`
  - `RTL`

The final desired state is:
- hardware behavior matches cpp semantics
- top final `y` matches between:
  - C++ main route
  - `export_hw_debug`
  - RTL/xsim

---

## Important Current Interpretation

### Does `export_hw_debug.py` replace the C++ route?
No.

- `export_hw_debug.py` is now the RTL stage-golden export route.
- The C++ route remains the main end-to-end quantization-loss evaluation route.

### Can `export_hw_debug.py` be used to prove hardware matches cpp?
Only after:
- the dt semantic split is removed
- or a dedicated stage-dump bridge is added between cpp and hw_debug

### Is `promote_dt_hw_golden.py` permanent?
Probably not.

It is a debug/bring-up bridge:
- useful while upstream/downstream RTL stages are being isolated
- likely removable once the final dt semantics are unified

---

## Recommended Immediate Focus In The New Chat

Start directly from:
- [HW_reconstruct/rtl_reuse_shared/reuse_ssm_dt_scheduler.sv](./HW_reconstruct/rtl_reuse_shared/reuse_ssm_dt_scheduler.sv)
- [HW_reconstruct/tb/tb_reuse_ssm_dt_scheduler_hw_debug.sv](./HW_reconstruct/tb/tb_reuse_ssm_dt_scheduler_hw_debug.sv)
- [refactor/bittrue/export_hw_debug.py](./refactor/bittrue/export_hw_debug.py)

Do not revert to the old dt flow.

The current direction is correct:
- keep the new cpp-aligned dt export layout
- keep the new dedicated dt scheduler approach
- finish the standalone dt alignment first
- then reconnect downstream modules

