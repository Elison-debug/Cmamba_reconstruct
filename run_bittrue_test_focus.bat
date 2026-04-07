@echo off
setlocal EnableExtensions EnableDelayedExpansion

set PYTHON_EXE=C:\Users\Elison\.conda\envs\python-transformers\python.exe
set CKPT=refactor/bittrue/reference.pt
set FEAT_ROOT=./data/features/parity_2100
set TARGET=test
set EXPORT_DIR=export_bittrue/case1
set OUT_DIR=eval_bittrue_out/test_focus_2
set CPP_BIN=.\build\bittrue\main_full.exe
set CPP_BATCH_BIN=.\build\bittrue\main_batch.exe

if not "%~1"=="" set OUT_DIR=%~1
if not "%~2"=="" set FEAT_ROOT=%~2

if not exist "%PYTHON_EXE%" (
  echo Python not found: %PYTHON_EXE%
  exit /b 1
)

if not exist "%CPP_BIN%" (
  echo C++ binary not found: %CPP_BIN%
  echo Run build_bittrue.bat all first.
  exit /b 1
)

if not exist "%CPP_BATCH_BIN%" (
  echo C++ batch binary not found: %CPP_BATCH_BIN%
  echo Run build_bittrue.bat all first.
  exit /b 1
)

if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

echo [bittrue-test] output dir: %OUT_DIR%
echo [bittrue-test] target: %TARGET%
echo [bittrue-test] feat_root: %FEAT_ROOT%
echo [bittrue-test] batch binary: %CPP_BATCH_BIN%
echo [bittrue-test] starting...

"%PYTHON_EXE%" -m refactor.bittrue.eval_bittrue ^
  --ckpt "%CKPT%" ^
  --feat_root "%FEAT_ROOT%" ^
  --target "%TARGET%" ^
  --preload ^
  --case_parallel 2 ^
  --export_dir "%EXPORT_DIR%" ^
  --out_dir "%OUT_DIR%" ^
  --cpp_bin "%CPP_BIN%" ^
  --cpp_batch_bin "%CPP_BATCH_BIN%" ^
  --sweep_case "fake|fake|" ^
  --sweep_case "all_int16|int16|ssm_state=int16,gate=int16" ^
  --sweep_case "mixed_candidate|int16|dt_proj=int8,ssm_state=int8,gate=int8" ^
  --sweep_case "patch_i8_on_i16|int16|patch_embedding=int8,ssm_state=int16,gate=int16" ^
  --sweep_case "inproj_i8_on_i16|int16|in_proj=int8,ssm_state=int16,gate=int16" ^
  --sweep_case "outproj_i8_on_i16|int16|out_proj=int8,ssm_state=int16,gate=int16"

if errorlevel 1 (
  echo [bittrue-test] run failed.
  exit /b 1
)

echo [bittrue-test] run completed.
if exist "%OUT_DIR%\sweep_summary.csv" (
  echo [bittrue-test] summary: %OUT_DIR%\sweep_summary.csv
)

exit /b 0
