# Quantization Integration and Calibration Guide

This document describes how to use, evaluate, and calibrate the refactored quantization paths, and how to compare INT16 fixed-point (8.8) vs dynamic scaling for inference decisions. It also documents the new CLI switches after splitting `q_proj_head` into `q_proj` and `q_head`.

## Goals

- Make quantization toggles explicit and testable per stage (proj/head/backbone).
- Provide robust calibration (max-abs or percentile) to avoid saturated or overly coarse quantization steps.
- Offer a simple way to compare INT16 fixed-point 8.8 vs dynamic scale quantization at eval time.
- Keep train/eval/test scripts usable and backward compatible with older checkpoints.

## New/Updated Flags

- `--q_proj` (bool): Quantize the input projection 1x1 layer.
- `--q_head` (bool): Quantize the output head 1x1 layer.
- `--q_block_linear` (bool): Quantize pointwise 1x1 layers inside backbone blocks.
- `--quantize_all` (bool): Convenience toggle to enable all above.
- `--quant_backend {python,cpp}`: Choose LSQ fake-quant (python) or C++ extension backend.
- `--quant_bits {8,16}`: Bit-width for activations and weights.
- `--quant_mode {dynamic,fixed88}`: Select dynamic scale (default) or INT16 8.8 fixed-point style.
- `--calib_method {maxabs,p99}`: Eval-time calibration; use max-abs or 99th percentile.

Notes:

- Backward compatibility: older checkpoints that store `q_proj_head` will map to `q_proj=True` and `q_head=True` when loading. New checkpoints store `q_proj` and `q_head` separately.

## Recommended Calibration

- Activations: per-tensor symmetric
  - `scale = amax / qmax` (max-abs)
  - or `scale = percentile(|x|, 99%) / qmax` (p99)
- Weights: per-channel symmetric
  - `w_scale[c] = max_abs(W[c, ...]) / qmax`
- Track and log `sat_ratio` (fraction of values with `|x/scale| > qmax`) for diagnostics.

Why not mean(|x|)? Mean-based estimates can cause large steps or saturation in heavy-tailed distributions, which produces grid-like predictions and degraded accuracy. Max-abs or percentile is more robust.

## INT16 (8.8) vs Dynamic Scale

- `quant_mode=dynamic`: standard dynamic scaling (recommended for accuracy). For INT16, `qmax=32767`.
- `quant_mode=fixed88`: fixed fractional bits for INT16. We set `scale = 1/256` for both activations and weights to emulate Q8.8 format. This helps estimate accuracy under strict hardware constraints but can saturate if your ranges exceed ~128.
- When `fixed88` is used, `quant_bits` is forced to 16.

## Usage Examples

- Baseline (as in checkpoint):
  - `python -m refactor.core.eval --feat_root data/features/logo --ckpt refactor_last.pt`
- C++ INT16 dynamic scale with max-abs calibration (50 batches):
  - `python -m refactor.core.eval --feat_root data/features/logo --ckpt refactor_last.pt \
     --quant_backend cpp --quant_bits 16 --quant_mode dynamic --calib_method maxabs \
     --quant_calib_batches 50 --out_dir eval_out_cpp16`
- C++ INT16 fixed 8.8 (no dynamic scaling), compare accuracy:
  - `python -m refactor.core.eval --feat_root data/features/logo --ckpt refactor_last.pt \
     --quant_backend cpp --quant_mode fixed88 --quant_calib_batches 0 --out_dir eval_out_cpp16_fixed88`
- Isolate proj vs head effects (quantize only head):
  - `python -m refactor.core.eval --feat_root data/features/logo --ckpt refactor_last.pt \
     --q_head --quant_backend cpp --quant_bits 8 --quant_calib_batches 50`

## Implementation Notes

- C++ backend now safely unboxes `scale` and `zp` when passed from Python (fixes potential type errors).
- Activations use symmetric ranges; use `zp=0` for clearer, hardware-friendly behavior.
- Eval-time calibration updates `a_scale`/`w_scale` for both python and cpp backends, and can be saved into a new checkpoint for repeatable results.

## Troubleshooting

- Grid-like outputs / large spacing:
  - Check `sat_ratio` logs. If high, increase scale (max-abs/percentile naturally helps). If extremely low, steps may be too coarse.
  - Try disabling head quantization first (`--q_proj` only) to identify the main contributor.
  - Prefer dynamic scale over fixed 8.8 for accuracy; use 8.8 only to assess worst-case hardware.

