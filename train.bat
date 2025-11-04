@echo off

set outdir=ckpt_refactor\logo

python -m refactor.core.train ^
  --Din=4200 --K=16 ^
  --proj_dim=64 --d_model=64 --n_layer=3 ^
  --patch_len=8 --stride=4 ^
  --batch_size=32 --epochs=20 --lr=1e-4 --lr_schedule=cosine ^
  --workers=4 --prefetch=4 --amp  --use_dwconv --preload
goto :eof
