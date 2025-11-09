@echo off
setlocal

REM Default locations (override by passing args)
set CKPT=.\ckpt_refactor\logo_2100\calibrate_best.pt
set OUT=.\export_logo_2100

python "%~dp0export_fixed88.py" --ckpt "%CKPT%" --out_dir "%OUT%" %*

endlocal
