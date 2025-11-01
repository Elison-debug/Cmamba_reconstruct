@echo off
set target=%1
set ckpt=%2
set backend=%3
if "%target%"=="" (
  echo Usage: ref_eval.bat grid ^| random ^| parity ^| less [ckpt_path] [backend=python^|cpp]
  goto :eof
)

if "%ckpt%"=="" (set ckpt=refactor_last.pt)
if "%backend%"=="" (set backend=python)

if "%target%"=="grid" goto run_grid
if "%target%"=="random" goto run_random
if "%target%"=="parity" goto run_parity
if "%target%"=="less" goto run_less

echo Unknown target: %target%
goto :eof

:run_grid
python -m refactor.core.eval ^
  --eval_root=./data/features/grid/test  ^
  --Din=2100 --K=12 --ckpt=%ckpt% ^
  --quant_backend=%backend%
goto :eof

:run_random
python -m refactor.core.eval ^
  --eval_root=./data/features/random/test  ^
  --Din=2100 --K=12 --ckpt=%ckpt% ^
  --quant_backend=%backend%
goto :eof

:run_parity
python -m refactor.core.eval ^
  --eval_root=./data/features/parity/test  ^
  --Din=2100 --K=12 --ckpt=%ckpt% ^
  --quant_backend=%backend%
goto :eof

:run_less
python -m refactor.core.eval ^
  --eval_root=./data/features/lessData/test ^
  --Din=2100 --K=12 --ckpt=%ckpt% ^
  --quant_backend=%backend%
goto :eof
