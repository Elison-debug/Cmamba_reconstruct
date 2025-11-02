@echo off
set target=%1

if "%target%"=="" (
  echo Usage: ref_data.bat train ^| eval ^| test
  goto :eof
)

if "%target%"=="train" goto run_train
if "%target%"=="eval" goto run_eval
if "%target%"=="test" goto run_test

echo Unknown target: %target%
goto :eof

:run_train
python -m refactor.core.eval ^
  --eval_root=./data/features/lessData/train ^
  --ckpt ckpt_refactor\less_python\best_epe_mean.pt ^
  --target=train --out_dir ./test_out/train

python -m refactor.core.test.test ^
  --eval_root=./data/features/lessData/train ^
  --ckpt ckpt_refactor\less_python\best_epe_mean.pt ^
  --target=train --out_dir=test_out/train

goto :eof

:run_test
python -m refactor.core.eval ^
  --eval_root=./data/features/lessData/test ^
  --ckpt ckpt_refactor\less_python\best_epe_mean.pt ^
  --out_dir=test_out/testing

python -m refactor.core.test.test ^
  --eval_root=./data/features/lessData/test ^
  --ckpt ckpt_refactor\less_python\best_epe_mean.pt ^
  --out_dir=eval_out_testing --out_dir=test_out/testing

goto :eof

:run_eval
python -m refactor.core.eval ^
  --eval_root=./data/features/lessData/eval ^
  --ckpt ckpt_refactor\less_python\best_epe_mean.pt ^
  --target=eval --out_dir ./test_out/eval

python -m refactor.core.test.test ^
  --eval_root=./data/features/lessData/eval ^
  --ckpt ckpt_refactor\less_python\best_epe_mean.pt ^
  --target=eval --out_dir=test_out/eval
goto :eof