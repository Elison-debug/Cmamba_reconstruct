# CMamba for Wireless Positioning on LuViRA Dataset

This repo contains PyTorch implementations of **Mamba-family models** based on the [LuViRA Dataset](https://github.com/ilaydayaman/LuViRA_Dataset).

Our goal is to explore **lightweight Mamba-style architectures** for radio-based positioning and compare them with CNN baselines (e.g., FCNN), with an emphasis on hardware-friendly inference.

This document summarizes the current training, evaluation, dataset layout, and quantization pipeline, with tips and examples.

## Highlights (Software)
- Models: `vanilla mamba v1`, `channel mamba`, and `slim mamba`.
- Best test accuracy is achieved with very short context windows (K=1/2) on LuViRA.
- `slim mamba` achieves comparable accuracy to `channel mamba` with much smaller model size and faster training (see the report for full numbers).

## 📁 Project Directory Structure

```txt
Cmamba_reconstruct/
├── data/                     # LuViRA raw + processed features
│  ├── radio/                 # raw CSI/CIR per grid
│  ├── truth/                 # ground-truth labels per grid
│  └── features/              # processed features (npy/json/stats)
├── refactor/                 # main Python codebase
│  ├── core/                  # training/eval/model
│  ├── datasets/              # preprocessing scripts
│  ├── export/                # export helpers
│  ├── quant/                 # quantization (python + cpp extension)
│  ├── runtime_cpp/           # C++ runtime experiments
│  └── vectors/               # feature/vector utilities
├── tools/                    # analysis utilities (quant, model size, etc.)
├── report/                   # LaTeX report + figures
├── docx/                     # ablation notes and tables
├── HW_reconstruct/           # FPGA design and notes
├── CPP/                      # legacy C++ experiments
├── ckpt_refactor/            # main checkpoints
├── ckpt_refactor_ablation_K/ # ablation checkpoints
├── ckpt_origin/              # baseline checkpoints
├── eval_out*/                # evaluation outputs
├── test_out*/                # test outputs
├── train.bat / eval.bat      # run scripts
└── README.md
```

## ⚙️ Setup

```powershell
    conda create -n mamba python=3.10
    conda init python-transformers
    conda activate python-transformers
    pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cu129
```

After install torch you can try:

```powershell
    #testing transformers
    python -c "from transformers import pipeline; print(pipeline('sentiment-analysis')('we love you'))"
```

To use this model, you need to have the following libraries installed:

- `torch`
- `einops`
- `numpy`
- `pandas`
- `scikit-learn`
- `matplotlib`
- `wandb`

You can install them using pip:

```bash
    pip install torch einops numpy pandas scikit-learn matplotlib wandb 
```

📊 Data Preparation

Download the [LuViRA Dataset](https://github.com/ilaydayaman/LuViRA_Dataset)

Convert raw .mat/.csv into .npz feature files using the provided preprocessing scripts:

## Data Layout

- Feature root: `feat_root/`
  - `npy/`: per-sequence arrays
    - `base.feats.npy` (T, Din) float16/float32
    - `base.xy.npy` (T, 2) float32
    - `base.ts.npy` (T,) float64 (optional)
  - `json/`: one `base.json` per sequence with metadata and split indices
    - keys: `role` (train/eval/test), `indices_*` window end indices, `win_len`, `stride`, etc.
  - Optional global stats (train-only): `stats_train.npz` with `feat_mean`, `feat_std`, `std_floor`

Use `refactor/datasets/preprocess_logo.py` to convert raw `.mat` + `.csv` into this layout with LOGO split, temporal embargo, and windowing.

## Dataset Loader

- `FramesLazyDataset` builds windows lazily from the npy/json layout.
- Role filtering: `target=train|eval|test|auto` uses the corresponding indices from JSON.
- Normalization: if `stats_train.npz` is found, features are normalized via (x - mean) / max(std, std_floor).

## Model

- `MambaRegressor` (slim mamba):
  - Input: (B, K, Din)
  - 1x1 Conv projection (or quantized linear) to `proj_dim` channels per timestep.
  - Backbone: `CMambaSlim` (conv-patch-embedded, selective-scan block, optional DWConv, optional PE, residual blocks, RMSNorm, and either flat or pooled head).
  - Head: 1x1 Conv (or quantized linear) to 2D (x,y).

Key knobs: `K`, `Din`, `proj_dim`, `d_model`, `n_layer`, `patch_len`, `stride`, `pe_off`, `pe_scale`, `gate_off`, `agg_pool`, `use_dwconv`.

## Model Size (torch.save)
To compare with works that report model size as a serialized PyTorch file (e.g., `torch.save(model.cpu(), path)`), use:

```powershell
python tools/measure_model_size.py --ckpt ckpt_refactor/logo/best_epe_mean.pt
```

To write the full model to disk and report size:

```powershell
python tools/measure_model_size.py --ckpt ckpt_refactor/logo/best_epe_mean.pt --out model_full.pt --save_full
```

## Training

Entry: `python -m refactor.core.train [args]`

- Data: only pass `--feat_root=...` of the new layout. The script loads `train` and `eval` splits from JSON.
- Sampler: `GridPureBatchSampler` ensures grid-pure batches (batches from a single file/grid).
- AMP: `--amp` enables autocast + GradScaler if CUDA is available.
- Scheduler: cosine or constant (`--lr_schedule`), stepped per-batch.
- Din inference: the script now infers `Din` from the dataset and overrides `cfg.Din` if mismatched.
- Logging: CSV at `out_dir/train_log.csv`; per-epoch console summary is a single stable f-string line.
- Checkpoints: `last.pt` per epoch, best by `--best_metric` (default `epe_mean`), and a convenience `refactor_last.pt` at repo root for quick eval.

Example:

```powershell
python -m refactor.core.train \
  --feat_root=./data/features/logo \
  --Din=4200 --K=16 \
  --proj_dim=64 --d_model=64 --n_layer=3 \
  --patch_len=8 --stride=4 \
  --batch_size=32 --epochs=20 --lr=1e-4 --lr_schedule=cosine \
  --workers=4 --prefetch=4 --amp --use_dwconv --preload 
```

## Evaluation

Entry: `python -m refactor.core.eval [args]`

- Dims: resolved from `--ckpt` (preferred) to avoid size mismatches.
- Data: `--feat_root=...` with the new layout; `--target=train|eval|test|auto` chooses indices from JSON.
- Outputs: metrics printed; saved `val_preds.npz` (y_true, y_pred, err, percentiles), CDFs, histogram, and `pred_vs_true.svg`.

Example (float):

```powershell
python -m refactor.core.eval \
  --feat_root=./data/features/logo \
  --ckpt=ckpt_refactor/logo/best_epe_mean.pt \
  --target=eval --out_dir=./eval_out --preload
```

- support per-grid result

This will produce:

- `-cdf.png`             : error CDF plot
- `-err_hist.png`        : histogram of position errors
- `-val_preds.npz`       : predictions + ground truth + errors
- `-k_error_heatmap.svg` : heatmap for each grid predicted result
- `-pred_vs_true.svg`    : predicted location(point) VS true location (line)
- `-pred_vs_true.csv`    : optional CSV for analysis

## Quantization (Eval)

Two interchangeable backends for `QConv1x1INT` (quantized 1x1 conv):

- `--quant_backend=python`: LSQ fake-quant in Python (no build needed).
- `--quant_backend=cpp`: C++ extension via `torch.utils.cpp_extension` (JIT builds on first use).

Where quant is applied:

- `--quantize_all` applies to proj/head and backbone 1x1 projections.
- Fine-grained: `--q_proj_head`, `--q_block_linear`, `--q_backbone_linear`.

Examples:

```powershell
# Prebuild/test C++ extension (optional)
python -m refactor.quant.build_and_use --prebuild
python -m refactor.quant.build_and_use --backend=cpp --test_linear
```

```powershell
# Eval with C++ quant (all 1x1 projections quantized)
python -m refactor.core.eval \
  --feat_root=./data/features/logo \
  --ckpt=ckpt_refactor/logo/best_epe_mean.pt \
  --quant_backend=cpp --quantize_all \
  --target=eval --out_dir=./eval_out_cpp --preload
```

## Quantization Analysis (CSV)

- Script: `tools/analyze_quant.py` compares baseline vs quantized results from CSVs and summarizes accuracy loss per grid.
- Expected layout under a root (default `test_out`):
  - `logo_eval_ori/Grid*/pred_vs_true.csv`
  - `logo_eval_quant16/Grid*/pred_vs_true.csv`
  - `logo_test_ori/Grid*/pred_vs_true.csv`
  - `logo_test_quant16/Grid*/pred_vs_true.csv`
- Pairing rules (in order):
  - Prefer `logo_eval_ori` ↔ `logo_eval_quant16`, `logo_test_ori` ↔ `logo_test_quant16`.
  - Fallback: `logo_eval_best_epe_mean.pt` ↔ `logo_eval_calibrate_best.pt`, and similarly for `logo_test_*`.
  - Last resort: keyword heuristic by split (`eval`/`test`) and `quant16|calibrate|int|qat|quant`.

Usage

- Basic run: `python tools/analyze_quant.py --root test_out --rel-threshold 0.05`
- Options:
  - `--root`: root directory containing the paired run folders (default `test_out`).
  - `--rel-threshold`: maximum allowed relative increase of `mean_err_m` to declare success (default `0.05` for 5%).

Outputs

- Console summary per split and grid with relative change in `mean_err_m` and pass/fail.
- CSV summary at `test_out/quant_analysis_summary.csv` with columns:
  - `split`, `grid`, `success`, sample counts, and metrics per grid.
  - Metrics include: `mean_err_m`, `median_err_m`, `p95_err_m`, `mae_x`, `mae_y`, `rmse_x`, `rmse_y`, plus deltas and relative deltas.

Notes

- Success is defined as: no NaN/Inf detected, sample counts match, and relative `mean_err_m` increase ≤ threshold.
- If you change folder names, keep the `*_ori` for baseline and `*_quant16` for quantized, or rely on the fallback pairing.

## Preprocessing Notes (LOGO)

- `preprocess_logo.py` supports leave-one-grid-out split and temporal embargo.
- By default, it currently applies embargo and uses `eval_stride` across roles for uniform density. If you prefer denser training, re-enable the role-specific stride (commented branch in the script).

## Batch Files

- `train.bat`: starts a default training run (adjust to your `feat_root`).
- `eval.bat` : starts a default eval run (adjust to your `feat_root`)..
- `test.bat` : runs eval and per-file tests for selected targets.

## Pitfalls & Tips

- Make sure `feat_root` points to the new npy/json layout; legacy npz is not supported by `FramesLazyDataset`.
- If you modify preprocessing, keep `Din` consistent; training now auto-infers and overrides.
- When using `--quant_backend=cpp` on Windows, ensure your compiler toolchain is set up for PyTorch C++ extensions.

## 🙏 Acknowledgements

- Dataset  :  [LuViRA Dataset](https://github.com/ilaydayaman/LuViRA_Dataset)
- Inspired by the Mamba architecture (Selective State Spaces).
