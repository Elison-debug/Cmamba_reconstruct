# 训练 / Test / Eval 全流程说明（基于 lessData 配置）

本文梳理当前仓库从数据到训练、评估（单文件与多文件）的完整流程，并给出关键张量形状与公式说明。示例命令以 Windows PowerShell/CMD 为准，斜杠续行使用 `^`。

示例训练命令（用户指定）：

```bat
python -m models.training.train_regression_lazy ^
    --features_root=./data/features/lessData ^
    --seq_len=12 --input_dim=2100 ^
    --proj_dim=64 --d_model=128 ^
    --n_layer=4 --patch_len=8 ^
    --stride=4 --batch_size=32 ^
    --epochs=20 --lr=3e-4 --sigma=0.1 ^
    --wd=0.01 --out_dir=./ckpt/lessData ^
    --amp --accum=4
```

---

## 数据准备（lessData）

- 执行命令（已在 `data.bat` 中提供）：

```bat
./data.bat less
```

- 主要脚本：`datasets/preprocess_parity_lessDataset.py`
  - 读取无线电 `.mat` 与地面真值 `.csv`，自动嗅探分隔符与编码；
  - 选择 3D 复数张量并按时间轴对齐为 `(T, F, A)`；
  - 沿频率轴 IFFT 取前 `L=taps` 个 CIR taps，默认 `L=10`；
  - 每天线幅度归一：
    - 令 `D = IFFT(Y, axis=f)[:, :L, :]`，`p = sqrt(mean(|D|^2, axis=(t,f)))`（形状 `(1,1,A)`）；
    - 归一后 `D_n = D / (p + 1e-8)`；
  - 特征拼接：
    - 实虚展开：`feat_cir = concat(Re(D_n), Im(D_n))` → `(T, 2·L·A)`；
    - 功率通道：`power = log(1 + mean(|D|^2, axis=f))` → `(T, A)`；
    - 最终特征：`feats = [feat_cir, power]` → `(T, Din)`，其中 `Din = 2·L·A + A`。

- 在本示例中：`input_dim = 2100`，且 `L=10`，故可解出天线数 `A`：

$$A = \frac{\text{Din}}{2L+1} = \frac{2100}{21} = 100.$$

- 数据划分（奇偶 grid）：
  - 单数 grid → 生成 train/eval（以 5 帧为 block：前 `n_per_block` 帧分配 train，后 `m_per_block` 分配 eval，默认 4/1）；
  - 双数 grid → 全部放入 test；
  - 仅用 train 部分做特征统计，保存 `stats_train.npz`（避免信息泄漏）。

- 归一化统计：对所有 train 帧按列计算

$$\mu = \frac{1}{N}\sum_{i=1}^{N} x_i, \quad \sigma = \sqrt{\max\big(\mathbb{E}[x^2]-\mu^2,\,0\big)};$$

并做地板保护 `\sigma \leftarrow \max(\sigma, \text{std\_floor})`（默认 `1e-3`）。

---

## 训练输入管线（FramesLazyDataset）

- 数据根：`--features_root=./data/features/lessData`，训练脚本自动映射为：
  - `train_root = ./data/features/lessData/train`
  - `val_root   = ./data/features/lessData/eval`

- 数据集：`datasets/frames_lazy.py`
  - 惰性滑窗索引，不展开重叠窗口，构造 `(file_idx, start, target_t)` 索引；
  - 预测模式 `predict=current`（默认）：

$$\text{样本 } i:\; X_i = [x_{t-K},\ldots,x_{t-1}]\in\mathbb{R}^{K\times Din},\; y_i = y_t\in\mathbb{R}^{2},\; t=K,\ldots,T-1.$$

  - 归一化：加载 `stats_train.npz` 的 `(\mu,\sigma)` 并对 `X_i` 做逐列 `z = (x-\mu)/\sigma`；
  - 返回：`xb: (B, K, Din)`、`yb: (B, 1, 2)`（训练时再 `squeeze` 为 `(B,2)`）。

- DataLoader：
  - `batch_size=32`、`num_workers=4`、`prefetch_factor` 2/4（train/val）；
  - Windows 下 `persistent_workers=True` 已在安全判断后启用；
  - worker 随机种子与主进程一致性已处理。

---

## 模型结构（MambaRegressor → CMamba）

- `models/training/mamba_regressor.py`
  - 输入投影：`Linear(Din→C)`，其中 `C=proj_dim=64`；
  - 归一：`LayerNorm(C)`；
  - 维度变换：`(B,K,C) → (B,C,K)`；
  - 主干：`CMamba(args)`（通道优先、时间序列选择性状态空间）；
  - 聚合：`(B,C,T_out)` 平均时间维（通常 `T_out=1`）；
  - 回归头：`Linear(C→2)` 输出 `(x,y)`。

- 关键 patch 展开与嵌入（在 `CMamba` 内）：
  - `K=seq_len=12`，`P=patch_len=8`，`S=stride=4`；
  - patch 数：`num_patches = \left\lfloor\frac{K-P}{S}\right\rfloor + 1 = 2`；
  - 展开：

$$X\in\mathbb{R}^{B\times C\times K} \xrightarrow{\text{unfold}} \mathbb{R}^{B\times C\times \text{num\_patches}\times P}
\xrightarrow{\text{reshape}} \mathbb{R}^{B\times \text{num\_patches}\times (C\cdot P)}$$

  - 线性嵌入：`Linear(C·P → d_model)`，`d_model=128`；
  - 位置编码（正弦，可选）：`pe[k, 2i]=sin(pos/10000^{2i/d})`、`pe[k, 2i+1]=cos(...)`；
  - C‑Mamba 块：包含 `RMSNorm → in_proj → depthwise Conv1d(groups=d_inner) → SiLU → SSM selective_scan → gating → out_proj`，并有短残差；
  - 输出层：`Linear(d_model·num_patches → C·forecast_len)`，`forecast_len=1`。

- 选择性状态空间（简化表达）：

给定 `A\in\mathbb{R}^{d\times n}`、`B_t,C_t\in\mathbb{R}^{n}`、步长相关 `\Delta_t\in\mathbb{R}^{d}`，离散化后每时刻的状态递推为：

$$\begin{aligned}
\Delta A_t &= \exp(\Delta_t A),\\
\Delta B_t u_t &= f(\Delta_t,B_t,u_t),\\
x_t &= \Delta A_t \odot x_{t-1} + \Delta B_t u_t,\\
y_t &= C_t^\top x_t + D\odot u_t,
\end{aligned}$$

其中 `\odot` 为逐通道乘，代码实现按批量与通道维进行 `einsum` 展开与逐时序扫描。

---

## 损失函数与训练细节

- 欧氏距离：

$$\mathrm{EPE}_i = \left\lVert \hat{y}_i - y_i \right\rVert_2.$$

- Huber（SmoothL1）在距离上的应用：

$$\mathcal{L}_i = \mathrm{SmoothL1}(\mathrm{EPE}_i; \beta),\quad \beta=1.0.$$

- 尾部加权（可选，默认开启）：

$$w_i = 1 + \alpha\,\sigma\!\left(\frac{\mathrm{EPE}_i - \tau}{\gamma}\right),\quad \alpha=3.0,\; \tau=0.5,\; \gamma=0.2,$$

总体 batch 损失：

$$\mathcal{L} = \frac{1}{B}\sum_{i=1}^{B} w_i\,\mathcal{L}_i.$$

- AMP：`--amp` 开启自动混合精度（若 GPU 可用）；
- 梯度累积：`--accum=4`，每 4 个小步执行一次 `optimizer.step()`；
- 梯度裁剪：`clip_grad_norm_(..., 5.0)`；
- 优化器：AdamW（1D 参数与 bias 不做权重衰减）；
- 学习率计划：Const‑then‑Cosine（前 6% 常数，后余弦下降）；
- EMA：若安装 `torch_ema` 则启用 `decay=0.999`（保存 best 时可切换平均权重）。

- Checkpoint：
  - 每 epoch 评估并保存两份最优：按 `val_loss` 的 `bestN.pt` 与按 `val_epe` 的 `bestN_epe.pt`；
  - 同时保存 `checkpoint.pt`（包含 epoch、global_step、model/optimizer/scaler/scheduler/EMA/RNG 状态）；
  - 文本日志位于 `out_dir/log/train_log*.txt`。

---

## 评估（聚合与逐文件）

两种评估方式，共同点：都会用 ckpt 中记录的训练超参覆盖本地默认；并强制使用 train 统计做归一化（避免信息泄漏）。

1) 聚合评估（单整体 CDF/直方图）

```bat
python -m models.eval.eval_cdf_lazy ^
  --ckpt=ckpt/lessData/result/best1_epe.pt ^
  --predict=current --sigma=0.1 ^
  --out_dir=eval_out_testing_001 --save_csv ^
  --amp --eval_root=./data/features/lessData/test
```

- 构造整个 eval/test 文件列表为一个 DataLoader，汇总 `y_true/y_pred` 后统一计算：`mean/median/P80/P90`；
- 产出 `cdf.png` / `cdf_zoom.png` / `err_hist.png` 与 `val_preds.npz`、`pred_vs_true.csv`（可选）。

2) 逐文件评估（每个 `.npz` 单独输出一套图与结果）

```bat
python -m models.eval.eval_multi ^
  --ckpt=ckpt/lessData/result/best1_epe.pt ^
  --predict=current --sigma=0.1 ^
  --out_dir=eval_out_testing_001 --save_csv ^
  --amp --eval_root=./data/features/lessData/test
```

- 为 eval_root/test 下每个 `.npz` 创建子目录，分别保存 CDF/直方图与 `val_preds.npz`、`pred_vs_true.csv`；
- 顶层 `eval_out.txt` 汇总排名与统计（由脚本写入）。

---

## Test 脚本入口（批处理）

- `test.bat` 中与 lessData 对应的入口为 `:run5`：

```bat
python -m models.eval.eval_multi ^
  --ckpt=ckpt/lessData/result/best%args%_epe.pt ^
  --predict=current --sigma=0.1 ^
  --out_dir=eval_out_testing_%args% --save_csv ^
  --amp --eval_root=./data/features/lessData/test
```

其中 `%args%` 为你传入的后缀编号（如 `001` 对应 `best001_epe.pt`）。

---

## 关键注意事项

- 归一化：始终使用 train 的 `stats_train.npz`（由预处理脚本在 `out_dir/` 下生成）；
- `sigma` 仅在训练态的 `ChannelMixup` 中起效，评估时模型在 `eval()` 模式下不会混入通道噪声；
- 若做量化/位一致对齐，建议评估时关闭 AMP/TF32，并固定随机种子；
- `input_dim` 必须与预处理生成的 `Din` 一致（lessData 下通常为 2100，取决于 `taps` 与天线数）。

---

如需，我可以基于该说明再输出一份“从零到可复现实验”的命令清单（含数据生成、训练、选择最佳 ckpt、逐文件评估与表格汇总）。

