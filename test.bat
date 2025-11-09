@echo off
setlocal
set target=%1
set data=%2
set quant=%3

if "%target%"=="" (
echo Usage: ./test.bat logo^|logo_delta test^|eval^|train ori^|quant ^[extra args...^]
  goto :eof
) else if "%data%"=="" (
  echo Usage: ./test.bat logo^|logo_delta test^|eval^|train ^[extra args...^]
  goto :eof
)

:proceed
if "%quant%"=="" (
  set model=best_epe_mean.pt
  echo Using original model for testing
) else if "%quant%"=="ori" (
  set model=best_epe_mean.pt
  echo Using original model for testing
) else if "%quant%"=="quant16" (
  set model=calibrate_best.pt
  echo Using calibrated model for testing
) else if "%quant%"=="quant8" (
  set model=calibrate_int8_best.pt
  echo Using calibrated model for testing
) else (
  echo Unknown model type: %model%
  goto :eof
)



if "%target%"=="logo" ( 
  set dataform=logo_2100
  goto run
)
if "%target%"=="logo_delta" ( 
  set dataform=logo_4200
  goto run
)

echo Unknown target: %target%
goto :eof

:run
echo running eval for %dataform% with model %model%
python -m refactor.core.eval ^
  --feat_root=./data/features/%dataform% ^
  --ckpt=./ckpt_refactor/%dataform%/%model% ^
  --dont_save_calib_ckpt ^
  --target=%data% --out_dir=./test_out/%target%_%data%_%quant%^
  --preload

if "%data%"=="train_all" (
  goto :eof
)

python -m refactor.core.test.test ^
--feat_root=./data/features/%dataform% ^
  --ckpt ckpt_refactor\%dataform%\%model%  ^
  --target=%data% --out_dir=test_out/%target%_%data%_%quant% ^
  --preload 
goto :eof