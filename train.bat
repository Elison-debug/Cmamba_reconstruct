@echo off

set outdir=ckpt_refactor\logo_quant_head

python -m refactor.core.train ^
  --out_dir=%outdir% ^
  --Din=4200 --K=16 ^
  --proj_dim=64 --d_model=64 --n_layer=3 ^
  --patch_len=8 --stride=4 ^
  --batch_size=32 --epochs=6 --lr=1e-4 --lr_schedule=cosine ^
  --workers=4 --prefetch=4 --amp  --use_dwconv --preload 
  @REM --q_proj_head --quant_bits=16
goto :eof
