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
) else if "%quant%"=="_ori" (
  set model=best_epe_mean.pt
  echo Using original model for testing
) else if "%quant%"=="_quant16" (
  set model=calibrate_best.pt
  echo Using calibrated model for testing
) else if "%quant%"=="_quant8" (
  set model=calibrate_int8_best.pt
  echo Using calibrated model for testing
) else (
  echo Unknown model type: %model%
  goto :eof
)


if "%target%"=="logo" ( 
  set feat_root=logo_2100
  set ckpt=logo_2100
  goto run
)

if "%target%"=="parity" ( 
  set feat_root=parity_2100
  set ckpt=parity_2100_K2_pl2
  goto run
)

if "%target%"=="parity_PE" ( 
  set feat_root=parity_2100
  set ckpt=parity_2100_PE
  goto run
)

if "%target%"=="parity_DWconv" ( 
  set feat_root=parity_2100
  set ckpt=parity_2100_DWconv
  goto run
)

if "%target%"=="parity_PE_DWconv" ( 
  set feat_root=parity_2100
  set ckpt=parity_2100_PE_DWconv
  goto run
)

if "%target%"=="parity_ori" ( 
  set feat_root=parity_ori
  set ckpt=parity_ori
  goto run
)

if "%target%"=="parity_delta" ( 
  set feat_root=parity_delta
  set ckpt=parity_delta
  goto run
)

if "%target%"=="parity_power" ( 
  set feat_root=parity_power
  set ckpt=parity_power
  goto run
)


if "%target%"=="parity_ori_power_delta" ( 
  set feat_root=parity_4200
  set ckpt=parity_4200
  goto run
)

if "%target%"=="logo_delta" ( 
  set ckpt=logo_4200
  goto run
)

echo Unknown target: %target%
goto :eof


@REM --ckpt=./ckpt_refactor/%ckpt%/%model% ^


:run
echo running eval for %ckpt% with model %model%

python -m refactor.core.test.test ^
--feat_root=./data/features/%feat_root% ^
  --ckpt ckpt_refactor_ablation_K\%ckpt%\%model%  ^
  --target=%data% --out_dir=test_out_ablation_K/%target%_%data%%quant% ^
  --preload 

goto :eof


@REM :run
@REM echo running eval for %ckpt% with model %model%
@REM python -m refactor.core.eval ^
@REM   --feat_root=./data/features/%feat_root% ^
@REM   --ckpt=././ckpt_refactor_ablation_K/%ckpt%/%model% ^
@REM   --dont_save_calib_ckpt ^
@REM   --target=%data% --out_dir=./test_out_mambaOri/%target%_%data%%quant%^
@REM   --preload

@REM if "%data%"=="train_all" (
@REM   goto :eof
@REM )

@REM python -m refactor.core.test.test ^
@REM --feat_root=./data/features/%feat_root% ^
@REM   --ckpt ckpt_origin\%ckpt%\%model%  ^
@REM   --target=%data% --out_dir=test_out_mambaOri/%target%_%data%%quant% ^
@REM   --preload 

@REM goto :eof

python -m refactor.core.test.test ^
--feat_root=./data/features/%feat_root% ^
  --ckpt ckpt_refactor\%ckpt%\%model%  ^
  --target=%data% --out_dir=test_out/%target%_%data%%quant% ^
  --preload 
goto :eof