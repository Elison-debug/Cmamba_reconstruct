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
- `pack.py`
  - canonical export implementation for bit-true deployment packages
- `run_export.py`
  - export entry that reads the reference checkpoint and writes the deployment package
- `eval_bittrue.py`
  - evaluation entry for Python vs C++ reference inference
- `cpp/`
  - C++ reference inference path migrated from the old `refactor/runtime_cpp/`

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
- Use `refactor.bittrue.run_export`
- Use `refactor.bittrue.eval_bittrue`

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

Unless explicitly overridden, `run_export.py` and `eval_bittrue.py`
use this checkpoint by default.

## Build

Use the repo-root build script to compile the C++ reference binaries:

- `build_bittrue.bat`

Generated executables are placed under:

- `build/bittrue/main_full.exe`

## Active Entry Points

- Export: `python -m refactor.bittrue.run_export --out export_bittrue/case1`
- Export: `./export.bat export_bittrue\case1`
- Build: `./build_bittrue.bat`
- Eval: `python -m refactor.bittrue.eval_bittrue --export_dir export_bittrue/case1 --out_dir eval_bittrue_out/case1 --feat_root ./data/features/parity_2100 --cpp_bin .\build\bittrue\main_full.exe`
