@echo off
set out=%1
set ckpt=%2
if "%out%"=="" (
  echo Usage: ref_export.bat export_out_dir [ckpt]
  goto :eof
)
if "%ckpt%"=="" (set ckpt=refactor/bittrue/reference.pt)

python -m refactor.bittrue.run_export ^
  --out=%out% ^
  --ckpt=%ckpt%

echo Export written to %out%
goto :eof
