@echo off
setlocal
set target=%1
set data=%2

if "%target%"=="" (
echo Usage: ./eval.bat logo^|logo_delta test^|eval^|train ^[extra args...^]
  goto :eof
) else if "%data%"=="" (
  echo Usage: ./eval.bat logo^|logo_delta test^|eval^|train ^[extra args...^]
  goto :eof
)

set args=
:collect
if "%3"=="" goto proceed
set args=%args% %~3
shift
goto collect

:proceed
if "%target%"=="logo" ( 
  set feat_root=logo_2100
  set ckpt=logo_2100
  goto run
)

if "%target%"=="parity" ( 
  set feat_root=parity_2100
  set ckpt=parity_2100
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
  set feat_root=parity_3200
  set ckpt=parity_4200
  goto run
)

if "%target%"=="logo_delta" ( 
  set ckpt=logo_4200
  goto run
)

echo Unknown target: %target%
goto :eof

@REM :run
@REM echo running eval and calibrate for %ckpt%
@REM python -m refactor.core.eval ^
@REM   --feat_root=./data/features/%ckpt% ^
@REM   --ckpt=./ckpt_refactor/%ckpt%/best_epe_mean.pt  ^
@REM   --save_calib_ckpt=./ckpt_refactor/%ckpt%/calibrate_cpp_best.pt ^
@REM   --target=%data% --out_dir=./eval_out/%target%_%data%_cpp ^
@REM   --preload --quant_bits=16 %args%
@REM goto :eof

@REM :run
@REM echo running eval and calibrate for %ckpt%
@REM python -m refactor.core.eval ^
@REM   --feat_root=./data/features/%feat_root% ^
@REM   --ckpt=./ckpt_refactor/%ckpt%/best_epe_mean.pt  ^
@REM   --save_calib_ckpt=./ckpt_refactor/%ckpt%/calibrate_cpp_best.pt ^
@REM   --target=%data% --out_dir=./eval_out_abolation/%ckpt%_%data% ^
@REM   --preload --quant_bits=16 %args%
@REM goto :eof

@REM original eval without calibration for mambaOri
:run
echo running eval and calibrate for %ckpt%
python -m refactor.core.eval ^
  --feat_root=./data/features/%feat_root% ^
  --ckpt=./ckpt_origin/%ckpt%/best_epe_mean.pt  ^
  --save_calib_ckpt=./ckpt_origin/%ckpt%/calibrate_cpp_best.pt ^
  --target=%data% --out_dir=./eval_out_mambaOri_abolation/%ckpt%_%data% ^
  --preload --quant_bits=16 %args%
goto :eof

@REM Ablation eval for K in slim mamba
@REM :run
@REM echo running eval and calibrate for %ckpt%
@REM python -m refactor.core.eval ^
@REM   --feat_root=./data/features/%feat_root% ^
@REM   --ckpt=./ckpt_refactor_ablation_K/%ckpt%/best_epe_mean.pt  ^
@REM   --save_calib_ckpt=./ckpt_refactor_ablation_K/%ckpt%/calibrate_cpp_best.pt ^
@REM   --target=%data% --out_dir=./eval_out_abolation_K/%ckpt%_%data% ^
@REM   --preload --quant_bits=16 %args%
@REM goto :eof