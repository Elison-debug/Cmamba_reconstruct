@echo off
set target=%1
if "%target%"=="" (
  echo Usage: ref_data.bat grid ^| random ^| parity ^| less
  goto :eof
)


if "%target%"=="logo" goto run_logo
if "%target%"=="logo2000" goto run_logo2000
if "%target%"=="parity" goto run_parity
if "%target%"=="parityori" goto run_parityori
if "%target%"=="paritydelta" goto run_paritydelta
if "%target%"=="paritypower" goto run_paritypower
if "%target%"=="logo_delta" goto run_logo_delta

echo Unknown target: %target%
goto :eof

:run_logo
python -m refactor.datasets.preprocess_logo ^
  --out_dir=./data/features/logo_2100 ^
  --taps=10 --fps=100 ^
  --phase_center
goto :eof

:run_logo2000
python -m refactor.datasets.preprocess_logo ^
  --out_dir=./data/features/logo_2000 ^
  --taps=10 --fps=100 ^
  --phase_center --ori
goto :eof

:run_parity
python -m refactor.datasets.preprocess_logo ^
  --out_dir=./data/features/parity_2100 ^
  --logo_holdout_gids=109,125^
  --logo_test_gids=102,104,106,108,110,112,114,116,118,122,124,126,128,130,132,134,136,138,140,142,144,146,148,150,152,154,156,158,160,162,164,166,168,170,172,174,176 ^
  --taps=10 --fps=100 ^
  --phase_center --ori --power
goto :eof

:run_parityori
python -m refactor.datasets.preprocess_logo ^
  --out_dir=./data/features/parity_ori ^
  --logo_holdout_gids=109,125^
  --logo_test_gids=102,104,106,108,110,112,114,116,118,122,124,126,128,130,132,134,136,138,140,142,144,146,148,150,152,154,156,158,160,162,164,166,168,170,172,174,176 ^
  --taps=10 --fps=100 ^
  --phase_center  --ori
goto :eof

:run_paritydelta
python -m refactor.datasets.preprocess_logo ^
  --out_dir=./data/features/parity_delta ^
  --logo_holdout_gids=109,125^
  --logo_test_gids=102,104,106,108,110,112,114,116,118,122,124,126,128,130,132,134,136,138,140,142,144,146,148,150,152,154,156,158,160,162,164,166,168,170,172,174,176 ^
  --taps=10 --fps=100 ^
  --phase_center  --delta
goto :eof

:run_paritypower
python -m refactor.datasets.preprocess_logo ^
  --out_dir=./data/features/parity_power ^
  --logo_holdout_gids=109,125^
  --logo_test_gids=102,104,106,108,110,112,114,116,118,122,124,126,128,130,132,134,136,138,140,142,144,146,148,150,152,154,156,158,160,162,164,166,168,170,172,174,176 ^
  --taps=10 --fps=100 ^
  --phase_center  --power
goto :eof



:run_logo_delta
python -m refactor.datasets.preprocess_logo ^
  --out_dir=./data/features/logo_4200 ^
  --taps=10 --fps=100 ^
  --phase_center  --ori --power --delta
goto :eof
