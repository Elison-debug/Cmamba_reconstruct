@echo off
setlocal

@REM $env:PYTHONHOME = "C:\Users\Elison\.conda\envs\python-transformers"

set target=%1
if "%target%"=="" (
  echo Usage: ./train logo ^| logo_delta
  goto :eof
)

set args=
:collect
if "%2"=="" goto proceed
set args=%args% %~2
shift
goto collect

:proceed
if "%target%"=="logo" ( 
  set dataform=logo_2100
  set Din=2100
  goto run
)

if "%target%"=="logo2000" ( 
  set dataform=logo_2000 
  set Din=2000
  goto run
)

if "%target%"=="parity" ( 
  set dataform=parity_2100 
  set Din=2100
  goto run
)

if "%target%"=="parity2000" ( 
  set dataform=parity_2000 
  set Din=2000
  goto run
)

if "%target%"=="logo_delta" ( 
  set dataform=logo_4200 
  set Din=4200
  goto run
)

echo Unknown target: %target%
goto :eof

:run
echo running training for %dataform%
python -m refactor.core.train ^
  --feat_root=./data/features/%dataform% ^
  --out_dir=ckpt_refactor\%dataform% ^
  --Din=%Din% --K=16 ^
  --proj_dim=64 --d_model=128 --n_layer=4 ^
  --patch_len=8 --stride=4 ^
  --batch_size=32 --epochs=20 --lr=3e-4 --lr_schedule=cosine ^
  --workers=4 --prefetch=4 --amp --pe_off  --preload %args%
goto :eof

echo analysing training for %dataform%
python -m scalene -m refactor.core.train ^
  --feat_root=./data/features/%dataform% ^
  --out_dir=ckpt_refactor\%dataform% ^
  --Din=2100 --K=16 ^
  --proj_dim=64 --d_model=64 --n_layer=3 ^
  --patch_len=8 --stride=4 ^
  --batch_size=32 --epochs=2 --lr=1e-4 --lr_schedule=cosine ^
  --workers=0 --prefetch=4 --amp --use_dwconv --preload %args%