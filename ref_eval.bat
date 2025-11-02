@echo off
setlocal
if "%~1"=="" (
  echo Usage: ref_eval.bat [python-args...]
  echo   For example:
  echo     ref_eval.bat --eval_root=.^\data^\features^\lessData^\test --Din=2100 --K=12 --ckpt=best_epe_mean.pt --quant_backend=python --pe_scale=1.0
  goto :eof
)

python -m refactor.core.eval --eval_root=./data/features/lessData/test --target=auto --ckpt ckpt_refactor\less_python\best_epe_mean.pt --out_dir ./test_out
 %*
goto :eof
