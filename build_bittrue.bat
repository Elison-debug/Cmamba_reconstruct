@echo off
setlocal

set TARGET=%1
if "%TARGET%"=="" set TARGET=full

set VSVCVARS=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat
if not exist "%VSVCVARS%" (
  echo vcvars64.bat not found: "%VSVCVARS%"
  exit /b 1
)

if not exist build\bittrue mkdir build\bittrue

call "%VSVCVARS%" >nul
if errorlevel 1 (
  echo Failed to initialize Visual Studio build environment.
  exit /b 1
)

set COMMON_FLAGS=/nologo /std:c++17 /EHsc /O2 /I refactor\bittrue\cpp
set COMMON_SRC=refactor\bittrue\cpp\ref_infer.cpp

if /I "%TARGET%"=="full" goto build_full

echo Unknown target: %TARGET%
echo Usage: build_bittrue.bat [full]
exit /b 1

:build_full
echo [build] main_full.exe
cl %COMMON_FLAGS% %COMMON_SRC% refactor\bittrue\cpp\main_full.cpp /Febuild\bittrue\main_full.exe
if errorlevel 1 exit /b 1
echo [build] done: build\bittrue
exit /b 0
