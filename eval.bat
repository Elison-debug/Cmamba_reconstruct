@echo off
setlocal
@REM if "%~1"=="" (
@REM   echo Usage: ref_eval.bat [python-args...]
@REM   echo   For example:
@REM   echo     ref_eval.bat --eval_root=.^\data^\features^\lessData^\test --Din=2100 --K=12 --ckpt=best_epe_mean.pt --quant_backend=python --pe_scale=1.0
@REM   goto :eof
@REM )

python -m refactor.core.eval --feat_root=./data/features/lessData/test --target=auto --ckpt ckpt_refactor\less_python\best_epe_mean.pt --out_dir ./test_out/test
 %*
goto :eof
