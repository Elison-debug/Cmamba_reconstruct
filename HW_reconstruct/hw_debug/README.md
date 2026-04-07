# HW Debug Flow

This folder is the bridge between:

- `refactor/bittrue/`
  - software-side exported model and golden results
- `HW_reconstruct/`
  - RTL and simulation

## Recommended directory layout

`cases/<case_name>/`

- `meta/`
  - `run.json`
  - `stages.json`
  - `artifacts.json`
- `float/`
  - `samples.npy`
  - `y_true.npy`
  - `y_float.npy`
  - `cache_meta.json`
- `stages/<stage_name>/`
  - `manifest.json`
  - stage-specific golden files to be added later
- `mem/`
  - optional packed `.mem` / `.hex` files for RTL loading
- `rtl_out/`
  - outputs dumped by simulator / cocotb
- `logs/`
  - compare logs and simulator logs
- `tb/`
  - generated or copied testbench-side helper files

## Stage order

Use this order for debug:

1. `sigmoid4_vec`
2. `ew_update_vec4`
3. `top_mac_plus_bias_fifo_sigmoid_ew_gate`
4. `reuse_mamba_block_top`

The reason is simple:

- `sigmoid4_vec` is easiest to make bit-exact
- `ew_update_vec4` captures the most important SSM fixed-point semantics
- block-level verification should only start after primitives are stable

## Export command

From repo root:

```bat
C:\Users\Elison\.conda\envs\python-transformers\python.exe -m refactor.bittrue.export_hw_debug ^
  --ckpt refactor/bittrue/reference.pt ^
  --feat_root ./data/features/parity_2100 ^
  --target test ^
  --preload ^
  --export_dir export_bittrue/case1 ^
  --out_dir HW_reconstruct/hw_debug/cases/test_case1
```

This prepares:

- software float cache
- exported model json/weights
- stage manifests
- primitive-level golden mem files for:
  - `sigmoid4_vec`
  - `ew_update_vec4`
- partial block-level golden files for:
  - `reuse_mamba_block_top`

Current `reuse_mamba_block_top` export is intentionally partial:

- it exports `h_t`, banked `in_proj/dt_proj` weights, and golden `u/z/u_act/dt/lam/ssm`
- it is suitable for checking `h -> in_proj -> u/z SRAM` and selected internal subpaths
- it is not yet a final `y` golden, because current RTL still keeps out-proj as a stub

## Cocotb flow

This folder includes a minimal cocotb scaffold in:

- `cocotb/Makefile`
- `cocotb/common.py`
- `cocotb/run_stage.py`
- `cocotb/test_sigmoid4_vec.py`
- `cocotb/test_ew_update_vec4.py`
- `cocotb/test_reuse_mamba_block_top.py`
- `cocotb/stubs/*.sv`

On Windows, prefer the Python runner instead of GNU make:

```bat
C:\Users\Elison\.conda\envs\python-transformers\python.exe HW_reconstruct\hw_debug\cocotb\run_stage.py ^
  --case_dir HW_reconstruct\hw_debug\cases\test_case1 ^
  --stage sigmoid4_vec ^
  --clean --verbose
```

Recommended first test:

```bat
cd HW_reconstruct\hw_debug\cocotb
set CASE_DIR=..\cases\test_case1
set STAGE=sigmoid4_vec
make MODULE=test_sigmoid4_vec TOPLEVEL=sigmoid4_vec RTL_TOP=..\..\sigmoid4_vec.sv
```

Second primitive test:

```bat
cd HW_reconstruct\hw_debug\cocotb
set CASE_DIR=..\cases\test_case1
set STAGE=ew_update_vec4
make MODULE=test_ew_update_vec4 TOPLEVEL=ew_update_vec4 RTL_TOP=..\..\ew_update_vec4.sv EXTRA_SOURCES=.\stubs\s_buffer.sv
```

Partial top test for the latest top:

```bat
cd HW_reconstruct\hw_debug\cocotb
set CASE_DIR=..\cases\test_case1
set STAGE=reuse_mamba_block_top
make MODULE=test_reuse_mamba_block_top TOPLEVEL=reuse_mamba_block_top RTL_TOP=..\..\rtl_reuse_shared\reuse_mamba_block_top.sv EXTRA_SOURCES="..\..\rtl_reuse_shared\reuse_ssm_core.sv ..\..\rtl_reuse_shared\reuse_in_proj_scheduler.sv ..\..\rtl_reuse_shared\reuse_ssm_dt_scheduler.sv ..\..\rtl_reuse_shared\reuse_mac_fabric_manager.sv ..\..\rtl_reuse_shared\reuse_shared_mac_fabric.sv ..\..\rtl_reuse_shared\reuse_pipeline_4array_with_reduction.sv ..\..\rtl_reuse_shared\reuse_pipeline_4array_top.sv ..\..\rtl_reuse_shared\reuse_array4x4.sv ..\..\rtl_reuse_shared\reuse_reduction_accumulator.sv ..\..\rtl_reuse_shared\reuse_inproj_weight_sram.sv ..\..\rtl_reuse_shared\reuse_ht_sram.sv ..\..\rtl_reuse_shared\reuse_ht_sram_sp.sv ..\..\rtl_reuse_shared\reuse_vec_out_sram.sv ..\..\rtl_reuse_shared\reuse_vec_out_sram_ip.sv ..\..\rtl_reuse_shared\reuse_out_proj_scheduler.sv ..\..\rtl_reuse_shared\reuse_pt_capture.sv ..\..\rtl_reuse_shared\reuse_z_stream_reader.sv ..\..\rtl_reuse_shared\reuse_silu_vec4.sv ..\..\rtl_reuse_shared\reuse_top_mac_plus_bias_fifo_sigmoid_ew_gate.sv ..\..\rtl_reuse_shared\pulse_to_stream_adapter.sv ..\..\rtl_reuse_shared\bias_add_regslice_ip.sv ..\..\rtl_reuse_shared\vec_fifo_axis_ip.sv ..\..\rtl_reuse_shared\sigmoid4_vec.sv ..\..\rtl_reuse_shared\axis_vec_join2.sv ..\..\rtl_reuse_shared\ew_update_vec4.sv ..\..\rtl_reuse_shared\ewm_gate_sbuf_vec4.sv ..\..\rtl_reuse_shared\ewm_vec4.sv ..\..\rtl_reuse_shared\ewa_vec4.sv ..\..\rtl_reuse_shared\pe_unit_pipe.sv ..\..\rtl_reuse_shared\slim_multi_bank_wbuf_dp.sv ..\..\rtl_reuse_shared\xt_input_buf.sv .\stubs\bias_ROM.sv .\stubs\s_buffer.sv .\stubs\slim_WBUF_bank_dp.sv .\stubs\u_xt_rom.sv"
```

This top test is intentionally partial:

- it checks `h_t -> in_proj -> u/z SRAM`
- it does not claim final `y` is golden
- current RTL still has out-proj stub, so full end-to-end compare is not valid yet

## Full workflow

1. Generate a debug case with `export_hw_debug.py`.
2. Populate stage golden files:
   - `in_q88.mem`
   - `out_q016.mem`
   - etc.
3. Run `sigmoid4_vec` cocotb.
4. Run `ew_update_vec4` cocotb.
5. Run partial `reuse_mamba_block_top` cocotb for in-proj/u-z SRAM alignment.
6. Fix first mismatch before moving upward.
7. Only after primitive and partial top alignment, add full SSM/top compare.

## ZCU102 bring-up recommendation

Use two phases:

1. Simulation / RTL debug
   - `.mem` files
   - cocotb or SV TB
   - direct bit-exact compare
2. On-board bring-up
   - control via AXI-Lite
   - sample / weight payload from PS DDR
   - DMA or AXI master move into PL-local SRAM/BRAM

For on-board use:

- keep sigmoid LUT in on-chip ROM
- keep small constants in BRAM
- load large weights from DDR into SRAM banks at runtime

Do not hardcode the full model weights into synthesized SRAM init for the final path.

## XSIM hw_debug TB

For the latest top, prefer the dedicated xsim testbench that reads a generated case directly:

```bat
C:\Users\Elison\.conda\envs\python-transformers\python.exe HW_reconstruct\hw_debug\vivado\run_xsim_stage.py ^
  --stage reuse_mamba_block_top_hw_debug ^
  --case_dir HW_reconstruct\hw_debug\cases\test_case1 ^
  --clean
```

This TB reads exported files from `stages/reuse_mamba_block_top/` and performs a partial compare on the in-proj `u/z` SRAM contents.
