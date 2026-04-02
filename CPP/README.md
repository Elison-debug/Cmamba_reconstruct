# Legacy Q8.8 Runtime

This folder is a legacy fixed-point runtime that is no longer the active deployment reference.

The active export and inference chain now lives under:

- `refactor/bittrue/`
- `refactor/bittrue/cpp/`
- `build_bittrue.bat`

For the current flow, use:

- `python -m refactor.bittrue.run_export --out export_bittrue/case1`
- `build_bittrue.bat`
- `python -m refactor.bittrue.eval_bittrue --export_dir export_bittrue/case1 --out_dir eval_bittrue_out/case1 --feat_root ./data/features/parity_2100`

This legacy folder is kept only for archival reference and should not be extended.
