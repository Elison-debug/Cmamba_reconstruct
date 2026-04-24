# HW Debug Workflow (Bittrue -> Export -> XSIM)

## 0. Environment
```powershell
conda activate python-transformers
cd E:\course\smamba
```

## 1. Build C++ Bittrue Binaries
```powershell
build_bittrue.bat
```

Expected executables:
- `build/bittrue/main_batch.exe`
- `build/bittrue/main_full.exe`
- `build/bittrue/main_block0_y.exe`

## 2. Export HW Debug Package (includes IP init files)
```powershell
python -m refactor.bittrue.export_hw_debug `
  --out_dir final_hw/cases/04 `
  --export_dir export_bittrue/final_hw/cases/04 `
  --target test `
  --feat_root data/features/parity_2100 `
  --workers 20 `
  --chain4_stream_frames 200 `
  --float_cache_dir final_hw/cases/02 `
  --preload
```

Generated roots:
- `HW_reconstruct/hw_debug/cases/test_case3_smoke/stages/*`
- `HW_reconstruct/hw_debug/cases/test_case3_smoke/ip_init/block0/*` (Vivado IP `.mem/.coe`)
- `HW_reconstruct/hw_debug/cases/test_case3_smoke/logs/*`

## 3. Run Stage-Level XSIM
### 3.1 Block top hw debug
```powershell
python HW_reconstruct/hw_debug/vivado/run_xsim_stage.py `
  --stage reuse_mamba_block_top_hw_debug `
  --case_dir HW_reconstruct/hw_debug/cases/test_case3_smoke `
  --run_name reuse_mamba_block_top_hw_debug `
  --clean
```

### 3.2 SSM core hw debug
```powershell
python HW_reconstruct/hw_debug/vivado/run_xsim_stage.py `
  --stage reuse_ssm_core_hw_debug `
  --case_dir HW_reconstruct/hw_debug/cases/test_case3_smoke `
  --run_name reuse_ssm_core_hw_debug `
  --clean
```

## 4. End-to-End Error Estimate (Parallel)
```powershell
python -m refactor.bittrue.eval_hw_like_full `
  --export_json export_bittrue/case1/export.json `
  --case_dir HW_reconstruct/hw_debug/cases/test_case3_smoke `
  --cpp_batch_bin build/bittrue/main_batch.exe `
  --din 2100 `
  --scan_mode scaled_state `
  --limit 512 `
  --workers 12 `
  --progress_every 64
```

Result JSON:
- `HW_reconstruct/hw_debug/cases/test_case3_smoke/logs/full_hw_like_eval.json`

## Module Inputs / Golden Files
### `sigmoid4_vec`
- Inputs: `in_q88.mem`
- Golden: `out_q016.mem`

### `ew_update_vec4`
- Inputs: `lam_q016.mem`, `u_q88.mem`, `s_prev_q88.mem`, `s_addr.mem`
- Golden: `s_new_q88.mem`, `state_write_addr.mem`, `state_write_data.mem`

### `reuse_ssm_dt_scheduler`
- Inputs: `u_act_in_q88.mem`, `dt_wbuf_bank*.mem`, `dt_scale_q15.mem`
- Golden: `dt_golden_q88.mem`, `xt_golden_q88.mem`

### `reuse_ssm_core`
- Inputs: `mac_in_q88.mem` (pre-bias dt MAC), `xt_in_q88.mem`, `g_in_q88.mem`, `state_u_to_state_q16.mem`, `state_to_q88_q16.mem`
- Golden: `lam_golden_q016.mem`, `ssm_golden_q88.mem`, `gate_y_golden_q88.mem`

### `reuse_mamba_block_top` (current block0 chain)
- Inputs:
`h_wr_addr.mem`, `h_wr_data_s16_q8p8.mem`, `norm_gamma_s16_q8p8.mem`,
`inproj_wbuf_bank*.mem`, `inproj_scale_q15.mem`,
`dt_wbuf_bank*.mem`, `dt_scale_q15.mem`,
`outproj_wbuf_bank*.mem`, `outproj_scale_q15.mem`,
`state_u_to_state_q16.mem`, `state_to_q88_q16.mem`
- Golden:
`u_golden_q88.mem`, `z_golden_q88.mem`, `u_act_golden_q88.mem`, `z_silu_golden_q88.mem`,
`dt_golden_q88.mem` (pre-bias MAC output), `lam_golden_q016.mem`,
`ssm_golden_q88.mem`, `gate_y_golden_q88.mem`, `y_golden_q88.mem`

