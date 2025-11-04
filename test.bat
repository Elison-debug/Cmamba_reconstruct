@echo off
set target=%1

if "%target%"=="" (
  echo Usage: ref_data.bat train ^| eval ^| test
  goto :eof
)
if "%target%"=="train_all" goto run_train_all
if "%target%"=="train" goto run_train
if "%target%"=="eval" goto run_eval
if "%target%"=="test" goto run_test

echo Unknown target: %target%
goto :eof

:run_train
python -m refactor.core.eval ^
  --ckpt ckpt_refactor\logo\best_epe_mean.pt ^
  --target=train --out_dir ./test_out/train ^
  --preload 

python -m refactor.core.test.test ^
  --ckpt ckpt_refactor\logo\best_epe_mean.pt ^
  --target=train --out_dir=test_out/train ^
  --preload 

:run_train_all
python -m refactor.core.eval ^
  --ckpt ckpt_refactor\logo\best_epe_mean.pt ^
  --target=train --out_dir ./test_out/train ^
  --preload 

goto :eof

:run_test
python -m refactor.core.eval ^
  --ckpt ckpt_refactor\logo\best_epe_mean.pt ^
  --target=test --out_dir=test_out/test ^
  --preload 

python -m refactor.core.test.test ^
  --ckpt ckpt_refactor\logo\best_epe_mean.pt ^
  --target=test --out_dir=test_out/test ^
  --preload 

goto :eof

:run_eval
python -m refactor.core.eval ^
  --ckpt ckpt_refactor\logo\best_epe_mean.pt ^
  --target=eval --out_dir ./test_out/eval --preload 

python -m refactor.core.test.test ^
  --ckpt ckpt_refactor\logo\best_epe_mean.pt ^
  --target=eval --out_dir=test_out/eval --preload 
goto :eof