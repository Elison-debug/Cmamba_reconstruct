@echo off
set target=%1
if "%target%"=="" (
  echo Usage: ref_data.bat grid ^| random ^| parity ^| less
  goto :eof
)

if "%target%"=="logo" goto run_logo
if "%target%"=="logo_delta" goto run_logo_delta

echo Unknown target: %target%
goto :eof

:run_logo
python -m refactor.datasets.preprocess_logo ^
  --out_dir=./data/features/logo_2100 ^
  --taps=10 --fps=100 ^
  --phase_center
goto :eof

:run_logo_delta
python -m refactor.datasets.preprocess_logo ^
  --out_dir=./data/features/logo_4200 ^
  --taps=10 --fps=100 ^
  --phase_center --append_delta 
goto :eof
