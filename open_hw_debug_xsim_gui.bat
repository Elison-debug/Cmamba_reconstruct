@echo off
setlocal

if not defined VIVADO_BIN (
  set "VIVADO_BIN=E:\Xilinx\Vivado\2024.1\bin"
)

set "RUN_DIR=HW_reconstruct\hw_debug\vivado_runs\reuse_mamba_block_top_hw_debug"
set "SNAPSHOT=tb_reuse_mamba_block_top_hw_debug"
set "WDB=%RUN_DIR%\tb_reuse_mamba_block_top_hw_debug.wdb"

if not exist "%VIVADO_BIN%\xsim.bat" (
  echo [error] xsim not found: %VIVADO_BIN%\xsim.bat
  exit /b 1
)

if not exist "%RUN_DIR%\xsim.dir\%SNAPSHOT%" (
  echo [error] Snapshot not found: %RUN_DIR%\xsim.dir\%SNAPSHOT%
  exit /b 1
)

pushd "%RUN_DIR%"
echo [xsim] opening GUI in %CD%
if exist "%WDB%" (
  call "%VIVADO_BIN%\xsim.bat" %SNAPSHOT% -gui -view "%WDB%"
) else (
  call "%VIVADO_BIN%\xsim.bat" %SNAPSHOT% -gui
)
popd

