# Chain4 HW Debug Workflow

## 1) Export HW debug assets (block0~3 + chain4)

```powershell
conda run -n python-transformers python -m refactor.bittrue.export_hw_debug `
  --ckpt refactor/bittrue/reference.pt `
  --feat_root ./data/features/parity_2100 `
  --target test `
  --preload `
  --limit 8 `
  --export_dir export_bittrue/case1 `
  --out_dir HW_reconstruct/hw_debug/cases/test_case3_smoke
```

Generated key directories:

- `HW_reconstruct/hw_debug/cases/test_case3_smoke/stages/reuse_mamba_block_top_block0`
- `HW_reconstruct/hw_debug/cases/test_case3_smoke/stages/reuse_mamba_block_top_block1`
- `HW_reconstruct/hw_debug/cases/test_case3_smoke/stages/reuse_mamba_block_top_block2`
- `HW_reconstruct/hw_debug/cases/test_case3_smoke/stages/reuse_mamba_block_top_block3`
- `HW_reconstruct/hw_debug/cases/test_case3_smoke/stages/reuse_mamba_block_top_chain4/final_y_golden_q88.mem`

## 2) Run single-block debug stage (baseline)

```powershell
conda run -n python-transformers python HW_reconstruct/hw_debug/vivado/run_xsim_stage.py `
  --stage reuse_mamba_block_top_hw_debug `
  --case_dir HW_reconstruct/hw_debug/cases/test_case3_smoke `
  --run_name block_top_hw_debug_check `
  --clean
```

## 3) Run 4-block chain stage

```powershell
conda run -n python-transformers python HW_reconstruct/hw_debug/vivado/run_xsim_stage.py `
  --stage reuse_mamba_4block_chain_top `
  --case_dir HW_reconstruct/hw_debug/cases/test_case3_smoke `
  --run_name chain4_check `
  --clean
```

TB file:

- `HW_reconstruct/tb/tb_reuse_mamba_4block_chain_top.sv`

RTL top:

- `HW_reconstruct/rtl_reuse_shared/reuse_mamba_4block_chain_top.sv`

## 4) Current debug status

- chain4 TB can run to completion and produce final y stream.
- Remaining mismatch is currently in chained block inputs (already instrumented in TB at block3 launch).
- Check `xsim.log` for lines starting with:
  - `DEBUG b3-input mismatch`
  - `FIRST final-y mismatch`

