@echo off
set target=%1
if "%target%"=="" (
  echo Usage: ref_data.bat grid ^| random ^| parity ^| less
  goto :eof
)

if "%target%"=="grid" goto run_grid
if "%target%"=="random" goto run_random
if "%target%"=="parity" goto run_parity
if "%target%"=="less" goto run_logo

echo Unknown target: %target%
goto :eof

:run_grid
python -m refactor.datasets.preprocess_luvira_lazy ^
  --radio_dir=./data/radio/grid ^
  --gt_dir=./data/truth/grid ^
  --out_dir=./data/features/grid   ^
  --taps=10 --fps=100 ^
  --pos_units=mm --dtype=float16 ^
  --split=0.8 --eval_ratio=1
goto :eof

:run_random
python -m refactor.datasets.preprocess_luvira_lazy ^
  --radio_dir=./data/radio/random ^
  --gt_dir=./data/truth/random ^
  --out_dir=./data/features/random   ^
  --taps=10 --fps=100 ^
  --pos_units=mm --dtype=float16 ^
  --split=0.2 --eval_ratio=0.5
goto :eof

:run_parity
python -m refactor.datasets.preprocess_parity_split ^
  --radio_dir=./data/radio/grid ^
  --gt_dir=./data/truth/grid ^
  --out_dir=./data/features/parity   ^
  --taps=10 --fps=100 ^
  --pos_units=mm --dtype=float16 ^
  --odd_even=odd
goto :eof

:run_logo
python -m refactor.datasets.preprocess_logo ^
  --out_dir=./data/features/logo ^
  --taps=10 --fps=100 ^
  --phase_center --append_delta 
goto :eof
