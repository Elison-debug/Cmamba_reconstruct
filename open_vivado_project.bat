@echo off
setlocal

if not defined VIVADO_BIN (
  set "VIVADO_BIN=E:\Xilinx\Vivado\2024.1\bin"
)

set "XPR=HW\project_slim_mamba_c01_hw\project_slim_mamba_c01_hw.xpr"
set "OPEN_TCL=HW\vivado\open_hw_project.tcl"

if not exist "%VIVADO_BIN%\vivado.bat" (
  echo [error] Vivado not found: %VIVADO_BIN%\vivado.bat
  exit /b 1
)

if exist "%XPR%" (
  echo [vivado] opening project: %XPR%
  call "%VIVADO_BIN%\vivado.bat" "%XPR%"
  exit /b %ERRORLEVEL%
)

if not exist "%OPEN_TCL%" (
  echo [error] Project not found: %XPR%
  echo [error] Tcl bootstrap not found: %OPEN_TCL%
  exit /b 1
)

echo [vivado] project not found, bootstrapping via: %OPEN_TCL%
call "%VIVADO_BIN%\vivado.bat" -mode gui -source "%OPEN_TCL%"

