@echo off
setlocal

REM Defaults
set FEAT=.^\data^\features^\logo_2100
set EXP=.^\export_logo_2100^\export.json
set OUT=.^\export_logo_2100^\x.npy

python "%~dp0make_input_from_features.py" --feat_root "%FEAT%" --export_json "%EXP%" --out_path "%OUT%" %*

endlocal
