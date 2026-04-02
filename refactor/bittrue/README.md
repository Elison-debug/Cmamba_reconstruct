# Bit-True Inference Reference

This folder is the deployment-side reference chain for FPGA implementation.

It is intentionally separated from the training and QAT flow under `refactor/core` and `refactor/quant`.

## Purpose

- Export trained models into a deployment-oriented package.
- Run bit-true reference inference in software before FPGA integration.
- Provide a stable numerical reference for:
  - integer quantization rules
  - LUT behavior
  - rounding and saturation
  - layer-by-layer comparison against FPGA outputs

## Scope

This folder is for inference only.

- Training stays in `refactor/core/train.py`.
- Evaluation of the float/fake-quant model stays in `refactor/core/eval.py`.
- The C++ files under `refactor/bittrue/cpp/` are the preferred starting point for FPGA-aligned reference execution.

## Layout

- `config.py`
  - shared bit-true quantization configuration
- `pack.py` / `cli.py`
  - canonical export implementation for bit-true deployment packages
- `schema.json`
  - export package schema kept together with the canonical bit-true export path
- `cpp/`
  - C++ reference inference path migrated from the old `refactor/runtime_cpp/`
- future scripts
  - export runner
  - bit-true evaluation
  - layer-wise compare utilities

## Current Baseline

- weights: `int8`, per-channel symmetric
- activations: `int8`, per-tensor asymmetric
- bias: `int32`
- accumulator: `int32`
- requant: ties-to-even + clamp
- sigmoid / SiLU: LUT-based reference implementation
- RMSNorm: float reference

This baseline is chosen to match the current exported runtime path and can be tightened later if the FPGA design moves to a stricter integer-only formulation.

## Canonical Ownership

The canonical deployment export path now lives here.

- Use `refactor.bittrue.pack`
- Use `refactor.bittrue.cli`
- Use `refactor.bittrue.run_export`

## Default Reference Checkpoint

The default checkpoint for the bit-true flow is:

- `refactor/bittrue/reference.pt`

Its current metadata is:

- `Din=2100`
- `K=2`
- `proj_dim=64`
- `d_model=128`
- `n_layer=4`
- `patch_len=2`
- `stride=2`
- `feat_root=./data/features/parity_2100`

Unless explicitly overridden, `run_export.py`, `cli.py`, and `eval_bittrue.py`
use this checkpoint by default.

## Build

Use the repo-root build script to compile the C++ reference binaries:

- `build_bittrue.bat`
- `build_bittrue.bat full`
- `build_bittrue.bat compare`
- `build_bittrue.bat demo`

Generated executables are placed under:

- `build/bittrue/main_full.exe`
- `build/bittrue/main_compare.exe`
- `build/bittrue/main_demo.exe`

The older `refactor/export/` directory is retained only as a deprecated compatibility layer.
