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
  set dataform=logo_2100
  goto run
)
if "%target%"=="logo_delta" ( 
  set dataform=logo_4200
  goto run
)

echo Unknown target: %target%
goto :eof

@REM :run
@REM echo running eval and calibrate for %dataform%
@REM python -m refactor.core.eval ^
@REM   --feat_root=./data/features/%dataform% ^
@REM   --ckpt=./ckpt_refactor/%dataform%/best_epe_mean.pt  ^
@REM   --save_calib_ckpt=./ckpt_refactor/%dataform%/calibrate_cpp_best.pt ^
@REM   --target=%data% --out_dir=./eval_out/%target%_%data%_cpp ^
@REM   --preload --quant_bits=16 %args%
@REM goto :eof

:run
echo running eval and calibrate for %dataform%
python -m refactor.core.eval ^
  --feat_root=./data/features/%dataform% ^
  --ckpt=./ckpt_refactor/%dataform%/best_epe_mean.pt  ^
  --save_calib_ckpt=./ckpt_refactor/%dataform%/calibrate_cpp_best.pt ^
  --target=%data% --out_dir=./eval_out/%target%_%data%_cpp ^
  --preload --quant_bits=16 %args%
goto :eof