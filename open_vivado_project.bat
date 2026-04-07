@echo off
setlocal

if not defined VIVADO_BIN (
  set "VIVADO_BIN=E:\Xilinx\Vivado\2024.1\bin"
)

set "XPR=HW_reconstruct\project_mamba_all1\project_mamba_all1.xpr"

if not exist "%VIVADO_BIN%\vivado.bat" (
  echo [error] Vivado not found: %VIVADO_BIN%\vivado.bat
  exit /b 1
)

if not exist "%XPR%" (
  echo [error] Project not found: %XPR%
  exit /b 1
)

echo [vivado] opening project: %XPR%
call "%VIVADO_BIN%\vivado.bat" "%XPR%"

