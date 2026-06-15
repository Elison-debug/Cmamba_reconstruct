# Slim-Mamba Hardware

This directory contains the standalone Slim-Mamba hardware implementation.
The board shell and PS-side loading contract are preserved, while the RTL
inside this tree is organized as a block-oriented compute pipeline:

- a block controller that sequences the local stages
- a shared linear stage abstraction for in-projection, dt projection, and
  out-projection
- a block configuration descriptor that collects per-stage settings in one
  place
- a chain wrapper that instantiates four independently configured blocks
- an explicit recurrent stage for state update, gating, and p capture

The code in this tree is intended to be read as the implementation itself.
Golden vectors and stage artifacts under `final_hw/` are used only as
reference data for verification.

## Directory Layout

- `rtl/common`
  Small reusable datapath primitives.
- `rtl/linear`
  Generic GEMV job, dispatcher, scheduler, and shared engine prototypes.
- `rtl/state`
  State update, gating, and runtime scaling prototypes.
- `rtl/block`
  Prototype block controller and block top used for synthesis experiments.
- `rtl/shell`
  The current Slim-Mamba implementation and its block/chain descriptors.
- `tb`
  Smoke and debug testbenches for the current implementation and regression
  collateral.
- `vivado`
  Simulation, regression, synthesis, and project-entry scripts.
- `docs`
  Architecture notes and integration inventory.
- `cases`
  Golden inputs and stage outputs used by the testbenches.
- `ip`, `constraints`
  Local IP collateral and shell constraints.

## Core Entry Points

- `rtl/shell/slim_mamba_block.sv`
  Single block implementation.
- `rtl/shell/slim_mamba_chain4.sv`
  Four-block chain using per-block configuration descriptors.
- `rtl/shell/slim_mamba_chain4_top.sv`
  Project-facing top that exposes the chain through the board-shell contract.
- `vivado/run_xsim_hw.py`
  Batch and GUI simulation entry point.
- `vivado/run_xsim_hw_gui.py`
  One-command GUI launcher for the main block debug stage.

## Quick Commands

Run the block smoke test:

```powershell
python HW\vivado\run_xsim_hw.py --stage slim_block_smoke --run_name slim_block_smoke_run1
```

Run the 4-block chain comparison:

```powershell
python HW\vivado\run_xsim_hw.py --stage slim_chain4_debug --run_name slim_chain4_debug_run1
```

Start the GUI on the block debug stage:

```powershell
python HW\vivado\run_xsim_hw_gui.py
```

Run the focused regression gate:

```powershell
python HW\vivado\run_regression_hw.py --case_dir final_hw\cases\c01 --run_tag nightly
```

Run a synthesis sweep on the prototype RTL set:

```powershell
python HW\vivado\run_synth_sweep.py --source_set mm --periods 10 8 6
```

## Notes

- The current implementation keeps per-block behavior in a single descriptor
  so a chain can mix settings without changing the top-level port contract.
- Regression still uses `final_hw` as the golden source.
- The design goal is reproducibility first, then resource and timing tuning.
