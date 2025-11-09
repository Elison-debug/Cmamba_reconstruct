@echo off
setlocal

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
  goto run
)
if "%target%"=="logo_delta" ( 
  set dataform=logo_4200 
  goto run
)

echo Unknown target: %target%
goto :eof

:run
echo running training for %dataform%
python -m refactor.core.train ^
  --feat_root=./data/features/%dataform% ^
  --out_dir=ckpt_refactor\%dataform% ^
  --Din=2100 --K=16 ^
  --proj_dim=64 --d_model=64 --n_layer=3 ^
  --patch_len=8 --stride=4 ^
  --batch_size=32 --epochs=20 --lr=1e-4 --lr_schedule=cosine ^
  --workers=4 --prefetch=4 --amp --use_dwconv --preload %args%
goto :eof
