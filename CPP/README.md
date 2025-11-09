# CMamba Q8.8 Inference (CPP)

This folder contains a fixed-point Q8.8 (signed int16 with 8 fractional bits) inference path designed to match an FPGA‑friendly implementation:

- Integer core for linear and depthwise ops: int16 × int16 → int32 accumulate, rounding right‑shift by 8, saturate to int16.
- Rounding: ties‑to‑even.
- Activations and weights quantized uniformly with scale = 1/256 (Q8.8).
- Nonlinearities (sigmoid / SiLU) via LUT in float domain, quantized at boundaries.
- RMSNorm computed in float, with quantize‑in/out to align with a fixed‑point pipeline.

## Build

```bash
mkdir -p build && cd build
cmake .. && cmake --build . --config Release
```

This produces `cmamba_demo` and a static library `cmamba_fixed88`.

## Export weights

Use the existing Python exporter to create `export.json` + `backbone.json` + `.npy` weights:

```powershell
python -m refactor.export.pack --help
# or via eval/train saving calib ckpt, then:
python - <<'PY'
import torch
from refactor.core.mamba_regressor import MambaRegressor
from refactor.export.pack import export_minimal
m = MambaRegressor(...)
ckpt = torch.load('ckpt_refactor/logo/calibrate_int8_best.pt', map_location='cpu')
m.load_state_dict(ckpt.get('state_dict', ckpt), strict=False)
export_minimal(m, out_dir='export_dir')
print('export:', 'export_dir/export.json')
PY
```

For best alignment with the hardware path here, run eval with `--quant_mode=fixed88` so activations/weights are calibrated to scale 1/256. The exporter itself writes float32 weights; the C++ engine quantizes them to Q8.8 internally using the same rounding and saturation as hardware.

## Run

```bash
# x.npy is (K, Din) float32 sample window (already normalized like Python eval)
./build/cmamba_demo export_dir/export.json x.npy Din
```

The program prints the predicted 2D coordinates as floats (dequantized from Q8.8).

## Read Features Directly

You can run the demo directly on your features folder (new npy/json layout) without creating x.npy manually:

```bash
./build/cmamba_demo export_dir/export.json ./data/features/logo_2100
```

The tool loads the first sequence under `json/`, reads its `npy/<base>.feats.npy`, takes the first K rows (K from export.json), and runs inference.

Alternatively, generate x.npy with the Python dataset (ensures identical preprocessing):

```bash
python CPP/tools/make_input_from_features.py --feat_root ./data/features/logo_2100 --export_json ./export_logo_2100/export.json --out_path ./export_logo_2100/x.npy
./build/cmamba_demo ./export_logo_2100/export.json ./export_logo_2100/x.npy 2100
```

## Notes

- Depthwise conv uses integer fixed‑point math; sigmoid/SiLU are LUT‑based to mimic hardware lookup.
- RMSNorm is applied in float with quantized interface to keep the core integer dataflow simple.
- The Q8.8 arithmetic helpers live in `src/quant_fixed88.hpp` and implement ties‑to‑even and saturating arithmetic.
