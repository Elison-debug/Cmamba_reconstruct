# Export Tool (fixed88)

Quick helper to export a trained/checkpointed model into `export.json` + `backbone.json` + `.npy` files for the C++ Q8.8 inference.

- Default checkpoint: `./ckpt_refactor/logo_2100/calibrate_best.pt`
- Default export dir: `./export_logo_2100`

Usage (PowerShell/CMD):

- `CPP\tools\export_fixed88.bat`
- Or: `python CPP\tools\export_fixed88.py --ckpt .\ckpt_refactor\logo_2100\calibrate_best.pt --out_dir .\export_logo_2100`

Optional overrides:

- `--Din`, `--K`, `--proj_dim`, `--d_model`, `--n_layer`, `--patch_len`, `--stride` (used only if checkpoint lacks arch fields)

The exported folder can be fed to the C++ demo:

- `CPP\build\Release\cmamba_demo.exe .\export_logo_2100\export.json .\export_logo_2100\x.npy 2100`

