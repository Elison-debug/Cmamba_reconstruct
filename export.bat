@echo off
set out=%1
set ckpt=%2
if "%out%"=="" (
  echo Usage: ref_export.bat export_out_dir [ckpt]
  goto :eof
)
if "%ckpt%"=="" (set ckpt=refactor_last.pt)

python -m refactor.export.cli ^
  --out=%out% ^
  --ckpt=%ckpt% ^
  --Din=2100 --K=12 --proj_dim=64 --d_model=96 --n_layer=3 --patch_len=8 --stride=4

echo Export written to %out%
goto :eof

