# Bit-True C++ Reference

This directory contains the active C++ reference runtime for deployment-side bit-true inference.

It is the preferred location for:

- exported-model integer reference execution
- layer-wise software vs FPGA comparison
- validation of quantization, LUT behavior, rounding, and saturation rules

Current key files:

- `reference_quant_int8.hpp`
  - low-level quantization helpers used by the reference path
- `ref_infer.hpp` / `ref_infer.cpp`
  - exported-model loading and forward execution
- `main_full.cpp`
  - end-to-end forward entry
- `io_utils.hpp`
  - simple NPY / file IO helpers

`main_full.exe` accepts:

- `--mode fake|int8|int16`
- `--overrides role=mode,...`
- `--verbose`

This is intended for sensitivity studies such as:

- all layers in `fake`
- all linear layers in `int16`
- `int16` by default with selected roles such as `dt_proj`, `ssm_state`, `gate`, or `out_proj` forced to `fake` or `int8`
