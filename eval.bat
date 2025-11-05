@echo off
setlocal

set ckptdir=logo_quant_head

@REM python -m refactor.core.eval ^
@REM  --ckpt ckpt_refactor\%ckptdir%\best_epe_mean.pt ^
@REM  --target=train --out_dir ./test_out/train_quant_cpp ^
@REM  --preload  %*

python -m refactor.core.eval ^
  --ckpt ckpt_refactor\%ckptdir%\best_epe_mean.pt ^
  --target=eval --out_dir ./test_out/val_quant_head ^
  --preload  --quant_bits=16 %*
goto :eof
