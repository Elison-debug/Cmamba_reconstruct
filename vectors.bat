@echo off
set target=%1
set layer=%2
set export_dir=%3
set ckpt=%4
set backend=%5
set tidx=%6

if "%target%"=="" (
  echo Usage: ref_vectors.bat grid ^| random ^| parity ^| less  layer  export_dir  [ckpt] [backend=python^|cpp] [t_index]
  goto :eof
)
if "%layer%"=="" (echo Missing layer name: proj ^| head & goto :eof)
if "%export_dir%"=="" (echo Missing export_dir & goto :eof)
if "%ckpt%"=="" (set ckpt=refactor_last.pt)
if "%backend%"=="" (set backend=python)
if "%tidx%"=="" (set tidx=0)

set eval_root=./data/features/%target%/eval

python -m vectors.gen_vectors ^
  --layer=%layer% ^
  --export_dir=%export_dir% ^
  --ckpt=%ckpt% ^
  --eval_root=%eval_root% ^
  --Din=2100 --K=12 ^
  --quant_backend=%backend% ^
  --t_index=%tidx%

echo Vectors generated under %export_dir%\vectors for %layer%
goto :eof

