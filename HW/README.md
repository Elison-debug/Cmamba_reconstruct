# HW Refactor

This directory hosts the clean-slate hardware refactor for the Slim-Mamba
accelerator. The legacy implementation in `final_hw/` remains the functional
reference and the source of proven golden vectors, but the new RTL in `HW/`
is intentionally reorganized around a publication-oriented architecture:

- modular block-level orchestration
- a reusable tiled GEMV engine
- a descriptor-driven dispatch layer
- an explicitly staged recurrent datapath
- quantization-sensitive state scaling isolated as its own stage

The external assumptions remain unchanged:

- the board shell architecture is preserved
- PS-side data loading remains unchanged
- the 4-block chain remains the system-level integration target

What changes here is the internal block architecture and naming. The goal is
to make the implementation align with a journal paper narrative rather than
with compatibility to the earlier incremental RTL.

## Directory layout

- `rtl/common`
  Low-level compute primitives and small reusable buffers.
- `rtl/linear`
  Shared GEMV engine, scheduler, and dispatcher.
- `rtl/state`
  Slim-Mamba-specific recurrent stages.
- `rtl/block`
  Block controller and block top.
- `docs`
  Architecture notes, design decisions, and refactor plan.
- `tb`
  New smoke TB plus migrated legacy TBs for regression.
- `vivado`
  New project/open scripts and simulation/synthesis entry points.
- `cases/04`
  Migrated golden vectors and stage artifacts from `final_hw`.
- `ip`, `constraints`
  Migrated local IP xci files and board-shell constraints.

## Naming

New modules use the `slm_` prefix (`modular mamba`) instead of `reuse_`.
This avoids carrying over legacy naming assumptions into the new design.

## Current status

This refactor starts from an architecture skeleton and selectively ports only
those low-level primitives that are still suitable in the new hierarchy.
The legacy code should be used as:

- arithmetic/functionality reference
- golden-vector source
- timing/area comparison baseline

## Quick commands

Run new block smoke test:

```powershell
python HW\vivado\run_xsim_hw.py --stage slm_block_smoke --run_name slm_block_smoke_run2
```

Run new 4-block chain control smoke test:

```powershell
python HW\vivado\run_xsim_hw.py --stage slm_chain4_smoke --run_name slm_chain4_smoke_run1
```

Run focused regression (gating on `slm_smoke` + `legacy_chain4_debug`):

```powershell
python HW\vivado\run_regression_hw.py --case_dir final_hw\cases\c01 --run_tag nightly
```

Run synthesis sweep for Slim-Mamba modules:

```powershell
python HW\vivado\run_synth_sweep.py --source_set mm --periods 10 8 6
```

Optional: include non-gating legacy block debug path in regression output:

```powershell
python HW\vivado\run_regression_hw.py --case_dir final_hw\cases\c01 --run_tag debug --include_legacy_block_debug
```

