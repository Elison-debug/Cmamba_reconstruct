@echo off
set target=%1
set ckpt=%2
set backend=%3
set outdir=%4
set opt5=%5
set opt6=%6
set opt7=%7

if "%target%"=="" (
  echo Usage: ref_test.bat grid ^| random ^| parity ^| less [ckpt] [backend=python^|cpp] [out_dir] [quantize_all] [use_dwconv] [amp]
  goto :eof
)

if "%ckpt%"=="" (set ckpt=refactor_last.pt)
if "%backend%"=="" (set backend=python)
if "%outdir%"=="" (set outdir=test_out_%target%_%backend%)

set qa=
set dw=
set amp=
if "%opt5%"=="quantize_all" (set qa=--quantize_all)
if "%opt5%"=="use_dwconv" (set dw=--use_dwconv)
if "%opt5%"=="amp" (set amp=--amp)
if "%opt6%"=="quantize_all" (set qa=--quantize_all)
if "%opt6%"=="use_dwconv" (set dw=--use_dwconv)
if "%opt6%"=="amp" (set amp=--amp)
if "%opt7%"=="quantize_all" (set qa=--quantize_all)
if "%opt7%"=="use_dwconv" (set dw=--use_dwconv)
if "%opt7%"=="amp" (set amp=--amp)

set eval_root=./data/features/lessData/%target%

python -m refactor.core.test.test ^
  --eval_root=%eval_root% ^
  --ckpt=%ckpt% ^
  --out_dir=%outdir% ^
  --quant_backend=%backend% %qa% %dw% %amp% --save_csv

echo Test results saved to %outdir%
goto :eof

