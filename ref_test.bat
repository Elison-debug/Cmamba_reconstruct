@echo off
setlocal
if "%~1"=="" (
  echo Usage: ref_test.bat [python-args...]
  echo   For example:
  echo     ref_test.bat --eval_root=.^\data^\features^\lessData^\test --ckpt=best_epe_mean.pt --out_dir=test_out_less_python --quant_backend=python --target=auto --save_csv
  goto :eof
)

python -m refactor.core.test.test %*

goto :eof
