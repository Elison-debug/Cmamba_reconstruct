@echo off
set target=%1
set backend=%2
set outdir=%3
set resume=%4
set best=%5
set opt6=%6
set opt7=%7

if "%target%"=="" (
  echo Usage: ref_train.bat grid ^| random ^| parity ^| less [backend=python^|cpp] [out_dir] [resume_ckpt] [best_metric=epe_mean^|eval_loss]
  goto :eof
)

if "%backend%"=="" (set backend=python)
if "%best%"=="" (set best=epe_mean)
if "%outdir%"=="" (set outdir=ckpt_refactor\%target%_%backend%)

set qa=
set dw=
if "%opt6%"=="quantize_all" (set qa=--quantize_all)
if "%opt6%"=="use_dwconv" (set dw=--use_dwconv)
if "%opt7%"=="quantize_all" (set qa=--quantize_all)
if "%opt7%"=="use_dwconv" (set dw=--use_dwconv)

set extra=
if not "%resume%"=="" (set extra=%extra% --resume=%resume%)
if not "%best%"==""   (set extra=%extra% --best_metric=%best%)

if "%target%"=="grid" goto run_grid
if "%target%"=="random" goto run_random
if "%target%"=="parity" goto run_parity
if "%target%"=="less" goto run_less

echo Unknown target: %target%
goto :eof

:run_grid
python -m refactor.core.train ^
  --train_root=./data/features/grid/train ^
  --eval_root=./data/features/grid/eval ^
  --Din=2100 --K=12 ^
  --proj_dim=64 --d_model=128 --n_layer=4 ^
  --patch_len=8 --stride=4 ^
  --batch_size=32 --epochs=20 --lr=3e-4 --lr_schedule=cosine ^
  --quant_backend=%backend% --out_dir=%outdir% %qa% %dw% %extra%
goto :eof

:run_random
python -m refactor.core.train ^
  --train_root=./data/features/random/train ^
  --eval_root=./data/features/random/eval ^
  --Din=2100 --K=12 ^
  --proj_dim=64 --d_model=128 --n_layer=4 ^
  --patch_len=8 --stride=4 ^
  --batch_size=32 --epochs=20 --lr=3e-4 --lr_schedule=cosine ^
  --quant_backend=%backend% --out_dir=%outdir% %qa% %dw% %extra%
goto :eof

:run_parity
echo Running parity grid...
python -m refactor.core.train ^
  --train_root=./data/features/parity/train ^
  --eval_root=./data/features/parity/eval ^
  --Din=2100 --K=12 ^
  --proj_dim=64 --d_model=128 --n_layer=4 ^
  --patch_len=8 --stride=4 ^
  --batch_size=32 --epochs=20 --lr=3e-4 --lr_schedule=cosine ^
  --quant_backend=%backend% --out_dir=%outdir% %qa% %dw% %extra%
goto :eof

:run_less
echo Running parity with lessData...
python -m refactor.core.train ^
  --train_root=./data/features/lessData/train ^
  --eval_root=./data/features/lessData/eval ^
  --Din=2100 --K=16 ^
  --proj_dim=64 --d_model=128 --n_layer=4 ^
  --patch_len=8 --stride=4 ^
  --batch_size=64 --epochs=20 --lr=1.5e-4 --lr_schedule=cosine ^
  --workers=8 --prefetch=8 --mmap_off --amp ^
  --quant_backend=%backend% --out_dir=%outdir% %qa% %dw% %extra%
goto :eof
