@echo off
setlocal

if not defined VIVADO_BIN (
  set "VIVADO_BIN=E:\Xilinx\Vivado\2024.1\bin"
)

set "OPEN_TCL=vivado\open_final_hw_project.tcl"

if not exist "%VIVADO_BIN%\vivado.bat" (
  echo [error] Vivado not found: %VIVADO_BIN%\vivado.bat
  exit /b 1
)

if not exist "%OPEN_TCL%" (
  echo [error] Tcl not found: %OPEN_TCL%
  exit /b 1
)

echo [vivado] launching final_hw project bootstrap: %OPEN_TCL%
call "%VIVADO_BIN%\vivado.bat" -source "%OPEN_TCL%"

