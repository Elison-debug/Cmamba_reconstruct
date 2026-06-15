# Integration Inventory

This document records the reference assets that the current Slim-Mamba
implementation consumes during simulation and comparison.

## Golden Data

The golden vectors live under `final_hw/cases/c01` and remain the source of
truth for regression comparison.

The current testbenches read:

- block-level input/output vectors for the single-block smoke tests
- four-block chain outputs for the chain comparison tests

## Board Shell Assets

The board-facing assets remain under the same shell contract:

- `constraints/reuse_mamba_board_shell_stream.xdc`
- local IP under `HW/ip`
- Vivado project scripts under `HW/vivado`

The shell is treated as fixed integration infrastructure. The compute core
changes underneath it.

## Regression Collateral

The following testbenches are used by the current run scripts:

- `tb_slim_mamba_block_smoke.sv`
- `tb_slim_mamba_block_hw_debug.sv`
- `tb_slim_mamba_chain4.sv`
- `tb_slim_mamba_chain4_top.sv`
- `tb_reuse_mamba_4block_chain_top.sv`

The legacy testbenches remain available for baseline comparison and do not
participate in the new shell naming.

## Implementation Notes

- The chain top accepts one block descriptor per block.
- Stage directories keep the per-block weight images grouped with the golden
  artifacts that generated them.
- The shell scripts are written so the new implementation can be run both in
  batch mode and in GUI mode without changing the core RTL.
