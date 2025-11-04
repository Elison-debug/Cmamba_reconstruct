#python ./dataprocess/preprocess_luvira.py   --radio_dir ./data/radio   --gt_dir    ./data/ground_truth/radio   --out_npz   ./data/data_transfered/prepared_data.npz  --seq_len 12 --taps 10 --fps 100 --train_split 0.8   --predict current
#python ./dataprocess/preprocess_luvira.py   --radio_dir ./data/radio   --gt_dir    ./data/ground_truth/radio   --out_npz   ./data/data_transfered/prepared_data.npz  --seq_len 12 --taps 10 --fps 100 --train_split 0.8   --predict current
  #transfer data to npz file
  python -m datasets.preprocess_luvira_lazy `
  --radio_dir=./data/radio `
  --gt_dir=./data/ground_truth/radio `
  --out_dir=./data/features   `
  --taps=10 --fps=100 `
  --pos_units=mm --dtype=float16 `
  --split=0.8



  #train & eval
  python -m models.train_regression_lazy `
  --features_root=./data/features `
  --seq_len=12 --input_dim=2000 `
  --proj_dim=64 --d_model=128 `
  --n_layer=4 --patch_len=6 `
  --stride=3 --batch_size=32 `
  --epochs=60 --lr=3e-4 `
  --wd=0.01 --out_dir=./ckpt `
  --amp --accum=4
  
  #train & eval
  python -m models.train_regression_lazy `
  --features_root=./data/features `
  --seq_len=12 --input_dim=2000 `
  --proj_dim=64 --d_model=128 `
  --n_layer=4 --patch_len=8 `
  --stride=4 --batch_size=32 `
  --epochs=60 --lr=3e-4 `
  --wd=0.05 --out_dir=./ckpt `
  --amp --accum=4
  
  
  #eval
  python -m models.eval_cdf_lazy `
  --features_root=.\data\features `
  --ckpt=.\ckpt\best.pt `
  --seq_len=12 --input_dim=2000 `
  --proj_dim=64 --d_model=128 --n_layer=4 `
  --patch_len=8 --stride=4 `
  --predict=next `
  --batch_size=64 --workers=4 `
  --out_dir=.\eval_out --save_csv

  #eval with live plotting and without specifying model structure
  python -m models.eval_cdf_lazy `
    --features_root=.\data\features `
    --ckpt=.\ckpt\best.pt `
    --out_dir=.\eval_out `
    --amp `
    --live_bins=120 --live_max_err=10 --live_every=1 `
    --save_csv

预处理(LOGO + embargo + windowing)：
python -m refactor.datasets.preprocess_logo --radio_dir=./data/radio/grid --gt_dir=./data/truth/grid --out_dir=./data/features/logo --split=logo --logo_holdout_gids="2,5" --embargo_sec=20 --fps=50 --win_len=64 --train_stride=32 --eval_stride=64 --taps=10 --phase_center --append_delta --dtype=float32

python -m refactor.datasets.preprocess_logo --phase_center --append_delta --dtype=float32

生成的 feature 根目录为 ./data/features/logo/train

训练：
python -m refactor.core.train  --Din=2100 --K=16 --proj_dim=64 --d_model=128 --n_layer=4 --patch_len=8 --stride=4 --batch_size=32 --epochs=20 --lr=3e-4 --lr_schedule=cosine --use_dwconv --out_dir=./ckpt_refactor/logo --preload

评估：

python -m refactor.core.eval --ckpt=ckpt_refactor/logo/best_epe_mean.pt --batch_size=256 --target=eval --out_dir=./test_out/eval --preload

测试/出图（逐文件子集）：
python -m refactor.core.test.test --feat_root=./data/features/logo --ckpt=best_epe_mean.pt --target=eval --out_dir=./test_out
   
  
  
