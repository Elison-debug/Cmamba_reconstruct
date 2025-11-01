# CMamba for Wireless Positioning on LuViRA Dataset

This repo contains a PyTorch implementation of a **channel-sequence regression model** based on
[Simple-CMamba](https://github.com/Prismadic/simple-CMamba), adapted for **wireless localization** tasks
on the [LuViRA Dataset](https://github.com/ilaydayaman/LuViRA_Dataset).

Our goal is to explore **lightweight Mamba-style architectures** for radio-based positioning,
and compare them with CNN baselines (e.g. FCNN).

## 📂 Project Structure

```bash
.
├── datasets/ # Lazy sliding-window dataset loader  /
├── models/ # CMamba regressor, training & evaluation scripts/
├── data/ # Put LuViRA preprocessed .npz features here/
├── ckpt/ # Model checkpoints/
    ├── lessData/ 
    ├── grid/ 
    └── parity/
└── test/ # validation results (plots, csv, npz)/
```

## ⚙️ Setup

```bash
conda create -n mamba-pos python=3.10
conda activate mamba-pos
pip install -r requirements.txt
```

## Installation

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

```bash
python dataprocess/preprocess_luvira.py --input_root ./LuViRA --output_root ./data/features
```

Or in Windows(CMD/PowerShell):

```bash
./data.bat grid/random/parity/less
```

Each `-.npz` will contain:

- `-feats`: time-series feature tensor
- `-xy`: ground-truth positions

Use args grid/random to process grid*/random*.mat files with different strategy

## 🚀 Training

```bash
source ./train.bat 
```

## test quantization using cpp

```bash
python -m refactor.quant.build_and_use --prebuild
python -m refactor.quant.build_and_use --backend=cpp --test_linear
python -m refactor.quant.build_and_use --backend=cpp --test_linear
```

Usage Examples:
Precompile C++ extensions only

- python -m refactor.quant.build_and_use --prebuild

Test Python pseudo-quantification

- python -m refactor.quant.build_and_use --backend=python --test_linear

Test C++ quantification (compilation triggered on first run)

- python -m refactor.quant.build_and_use --backend=cpp --test_linear

## 📈 Validation

After training, run:

```bash
source ./test.bat 
```

- support per-grid result

This will produce:

- `-cdf.png`: error CDF plot
- `-err_hist.png`: histogram of position errors
- `-val_preds.npz`: predictions + ground truth + errors
- `-pred_vs_true.csv`: optional CSV for analysis

## 🙏 Acknowledgements

- Dataset  :  [LuViRA Dataset](https://github.com/ilaydayaman/LuViRA_Dataset)
- Base Code  : [Prismadic/simple-CMamba](https://github.com/Prismadic/simple-CMamba/tree/main))
- Inspired by the Mamba architecture (Selective State Spaces).
