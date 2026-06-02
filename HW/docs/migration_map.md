# Migration Map (`final_hw` -> `HW`)

This document records what was migrated and why, so refactor work can move
forward without repeatedly depending on `final_hw` paths.

## 1) Verification collateral

- Migrated TBs:
  - `tb_reuse_mamba_block_top_hw_debug.sv`
  - `tb_reuse_mamba_4block_chain_top.sv`
  - `tb_reuse_mamba_board_shell_stream.sv`
  - `tb_reuse_mamba_board_shell_stream_ps.sv`
  - `tb_reuse_mamba_board_shell_ps.sv`
- Added new smoke TB:
  - `tb_slm_mamba_block_top_smoke.sv`

## 2) Golden data and reference artifacts

- Migrated `cases/04` subtrees:
  - `stages/reuse_mamba_block_top_block0`
  - `stages/reuse_mamba_block_top_chain4`
  - `export_ir`, `float`, `logs`, `meta`

This keeps the proven block-level and chain-level golden I/O available for
the new architecture.

## 3) Board-shell and integration boundary

- Migrated shell-related RTL (kept as compatibility boundary):
  - `rtl/shell/reuse_mamba_board_shell_stream.v`
  - `rtl/shell/reuse_mamba_h_stream_loader.v`
  - `rtl/shell/reuse_mamba_4block_chain_top.sv`
  - `rtl/shell/reuse_mamba_chain4_core_adapter.sv`
  - `rtl/shell/reuse_mamba_core_adapter.sv`
  - `rtl/shell/reuse_mamba_axi_lite_regs.sv`
- Migrated full legacy RTL bundle:
  - `rtl/legacy_reuse_shared/*`

## 4) Vivado project assets

- Migrated:
  - `constraints/reuse_mamba_board_shell_stream.xdc`
  - `ip/*` (`*.xci` + LUT/data collateral)
  - utility scripts from `final_hw/vivado`
- Added new entry points:
  - `vivado/open_hw_project.tcl`
  - `vivado/run_xsim_hw.py`

## 5) Refactor policy

- `final_hw` is kept read-only as reference baseline.
- New development happens only under `HW/rtl/*` with `slm_` modules.
- Legacy TBs remain available for regression while `slm_` block internals
  are being rebuilt.


