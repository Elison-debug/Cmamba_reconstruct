@echo off
setlocal EnableExtensions EnableDelayedExpansion

set PYTHON_EXE=C:\Users\Elison\.conda\envs\python-transformers\python.exe
set CKPT=refactor/bittrue/reference.pt
set FEAT_ROOT=./data/features/parity_2100
set TARGET=test
set EXPORT_DIR=export_bittrue/case1
set OUT_DIR=eval_bittrue_out/recommended_full
set CPP_BIN=.\build\bittrue\main_full.exe

if not "%~1"=="" set OUT_DIR=%~1
if not "%~2"=="" set TARGET=%~2
if not "%~3"=="" set FEAT_ROOT=%~3

if not exist "%PYTHON_EXE%" (
  echo Python not found: %PYTHON_EXE%
  exit /b 1
)

if not exist "%CPP_BIN%" (
  echo C++ binary not found: %CPP_BIN%
  echo Run build_bittrue.bat first.
  exit /b 1
)

if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

set LOG_FILE=%OUT_DIR%\run.log
set SUMMARY_FILE=%OUT_DIR%\sweep_summary.csv

echo [bittrue] output dir: %OUT_DIR%
echo [bittrue] target: %TARGET%
echo [bittrue] feat_root: %FEAT_ROOT%
echo [bittrue] log: %LOG_FILE%
echo [bittrue] starting...

"%PYTHON_EXE%" -m refactor.bittrue.eval_bittrue ^
  --ckpt "%CKPT%" ^
  --feat_root "%FEAT_ROOT%" ^
  --target "%TARGET%" ^
  --export_dir "%EXPORT_DIR%" ^
  --out_dir "%OUT_DIR%" ^
  --cpp_bin "%CPP_BIN%" ^
  --sweep_case "fake|fake|" ^
  --sweep_case "all_int16|int16|ssm_state=int16,gate=int16" ^
  --sweep_case "all_int8|int8|ssm_state=int8,gate=int8" ^
  --sweep_case "patch_i8_on_i16|int16|patch_embedding=int8,ssm_state=int16,gate=int16" ^
  --sweep_case "inproj_i8_on_i16|int16|in_proj=int8,ssm_state=int16,gate=int16" ^
  --sweep_case "dtproj_i8_on_i16|int16|dt_proj=int8,ssm_state=int16,gate=int16" ^
  --sweep_case "ssmstate_i8_on_i16|int16|ssm_state=int8,gate=int16" ^
  --sweep_case "gate_i8_on_i16|int16|ssm_state=int16,gate=int8" ^
  --sweep_case "outproj_i8_on_i16|int16|out_proj=int8,ssm_state=int16,gate=int16" ^
  --sweep_case "head_fake_on_i16|int16|head=fake,ssm_state=int16,gate=int16" ^
  > "%LOG_FILE%" 2>&1

if errorlevel 1 (
  echo [bittrue] run failed. Check %LOG_FILE%
  exit /b 1
)

echo [bittrue] run completed.
if exist "%SUMMARY_FILE%" (
  echo [bittrue] summary: %SUMMARY_FILE%
) else (
  echo [bittrue] summary file not found. Check %LOG_FILE%
)

exit /b 0
