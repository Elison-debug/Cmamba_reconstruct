# CMamba → ZCU102 推理移植方案（仅推理实现）

本方案聚焦“推理侧硬件实现”，不涉及训练端改动。目标是在 Zynq UltraScale+ ZCU102 上实现 CMamba 模型的确定性、可复现、可综合的推理流水线，并与软件端实现位一致或误差有界的一致性对齐。

---

## 1) 范围与假设

- 仅推理，不训练/微调；仅使用离线导出的权重与量化参数。
- 模型结构以当前回归路径为准：`(B,K,Din) → Linear(Din→C) → (B,C,K) → CMamba → (B,C,1) → mean_t → Linear(C→2)`。
- 运行时关闭一切随机与训练态特性：`ChannelMixup=off`、`dropout=off`、`eval()` 模式。
- 输入长度固定：`seq_len=K=12`；预测长度 `forecast_len=1`；`patch_len=8`，`stride=4` ⇒ `num_patches=2`（大幅降低 SSM 扫描长度）。
- 采用 INT8 推理（建议）：激活 per‑tensor 非对称；权重 per‑channel 对称；累加 int32；层间采用逐层重定标。

---

## 2) 算法裁剪与等价变换（推理端）

- 位置编码：保留固定正弦编码（常量）；如误差可接受，可将其与 patch 线性层权重合并（离线：对每个 patch 位置的 bias 做平移）。
- 归一化：
  - 输入端使用数据集 train 均值/方差的固定仿射（预处理阶段已完成，推理端无需额外 LN）。
  - 块内 RMSNorm 可通过 QAT/折叠并入前后线性层的 scale/bias，以减少硬件代价；若保留，建议 LUT/PWL 近似（见 5.3）。
- ChannelMixup：推理禁用，无需实现。
- 时间聚合：`forecast_len=1` 时的末端时间维 `mean` 可省为取标量或恒等（与训练导出一致）。

---

## 3) 数据与布局契约（软件 ↔ 硬件）

- 张量布局：通道优先 `(B,C,K)`，内部 batch=1 流式处理；补齐与对齐按 16/32 字节边界。
- Patch 顺序：时间维从左到右滑窗；每个 patch 内先按通道 C 展开，再拼接 P（与现实现一致：reshape 为 `(B, num_patches, C·P)`）。
- 权重布局：矩阵按 row‑major 存放；逐通道尺度向量与输出通道对齐（axis=0）。
- 导出文件：JSON + npy/bin，包含每层类型、形状、权重、bias、量化参数、舍入/饱和策略与布局元数据（见 7）。

---

## 4) 量化与定点规范（推理）

- 舍入：全局“最近偶数（ties‑to‑even）”。
- 饱和：溢出即夹到 `[qmin, qmax]`（INT8：对称 −128/127 或非对称 0/255）。
- 精度路径：`int8 × int8 → int32` 累加；输出经一次重定标得到下一层激活量化域。
- 激活：per‑tensor 非对称（scale_a, zp_a）；权重：per‑channel 对称（scale_w[c]，zp=0）。
- 建议 PoT（2 的幂）约束在激活尺度上，便于硬件使用移位替乘法（若精度允许）。

参考 C++ 量化头（HLS 亦可用）：

```cpp
// reference_quant_int8.hpp（片段）
static inline int64_t round_ties_to_even(double v){
  double fl=floor(v),fr=v-fl; if(fr>0.5) return (int64_t)ceil(v); if(fr<0.5) return (int64_t)fl; int64_t lo=(int64_t)fl; return (lo&1)?lo+1:lo; }
template<typename T> static inline T sat(T x,T lo,T hi){return x<lo?lo:(x>hi?hi:x);} 
static inline int8_t q_per_tensor_asym(float x,double s,int64_t zp,int64_t qmin,int64_t qmax){int64_t qi=round_ties_to_even((double)x/s+zp);return (int8_t)sat<int64_t>(qi,qmin,qmax);} 
static inline int8_t q_per_channel_sym(float w,double s_c,int64_t qmin,int64_t qmax){int64_t qi=round_ties_to_even((double)w/s_c);return (int8_t)sat<int64_t>(qi,qmin,qmax);} 
```

---

## 5) 层级映射与实现要点

### 5.1 Patch 线性嵌入（Linear: C·P → d_model）

- 计算：对每个 patch 向量 `x ∈ R^{C·P}`，输出 `y = W x + b`。
- 实现：INT8 GEMV/GEMM；并行度按 8/16/32 可配置；权重 per‑channel 对称；激活 per‑tensor 非对称；累加 int32；层末重定标到下一层激活域。
- 存储：权重常量放 BRAM/URAM，按输出通道分块；bias 放 BRAM。

### 5.2 深度可分卷积（Depthwise Conv1d, groups=d_inner, k=d_conv）

- 输入形状：`(B,l,d_inner)` 经重排为 `d_inner × l`；其中 `l=num_patches=2`，`k=4`（默认）。
- 实现：每通道独立的 1D 卷积，环形缓冲 + 逐通道 MAC；`padding=k-1` 后裁剪到长度 `l`（与软件保持一致）。
- 量化：同上，权重 per‑channel，对称；激活 per‑tensor，非对称。

### 5.3 非线性（SiLU、Softplus）与近似

- SiLU：`x·sigmoid(x)`，建议用 256/512 点 LUT 或分段线性（PWL）近似，域内限定 [-8,8]。
- Softplus：`log(1+exp(x))`，可用 `max(x,0)+log1p(exp(-|x|))` 的 LUT/PWL 近似；域裁剪避免溢出。
- 近似误差统一纳入“数字契约”，允许 < 1 LSB 或 < 1e-3 相对误差。

### 5.4 SSM Selective Scan（时序长度 l 极短）

- 变量：`A ∈ R^{d_in×n}`, `D ∈ R^{d_in}`, `delta ∈ R^{b×l×d_in}`, `B,C ∈ R^{b×l×n}`。
- 关键计算：

  1) `z = einsum(delta, A) → (b,l,d_in,n)`；`ΔA = exp(z)`；
  2) `ΔB·u = einsum(delta,B,u)`；
  3) 逐时刻扫描：`x_t = ΔA_t ⊙ x_{t-1} + (ΔB·u)_t`；`y_t = einsum(x_t, C_t) + D ⊙ u_t`。

- 硬件建议：
  - 由于 `l = num_patches = 2`，扫描环节仅 2 步，代价极小；
  - 将 `A_log`、`D` 常量化；`x_proj/dt_proj`、`x_proj` 产出的 `delta/B/C` 用 INT8 线性层生成，再经 Softplus/exp LUT 近似；
  - `exp` 的指数范围可由标定期统计裁剪（如 [-8,8]）。

### 5.5 残差与输出投影

- 残差：块内短残差 `y = out_proj(y) + x_in`；注意尺度对齐（若两支尺度不同，需在短支做一次重定标）。
- 输出头：`Linear(C→2)`，INT8 GEMV；最终输出以浮点或 Q16.16 形式返回。

---

## 6) 定标链与尺度管理（逐层）

设上一层激活量化为 `(s_a,zp_a)`，权重通道尺度为 `s_w[c]`：

- 累加：`acc = Σ_i (w_q[i] · (x_q[i] - zp_a))`，`acc ∈ int32`。
- 反量化到浮点（用于非线性/LUT 索引或导出）：`x_hat = acc · (s_a · s_w_eff)`；
- 或重定标回 INT8：`x_q' = sat(round_ties_to_even(acc · α) + zp_out)`，其中 `α = (s_a·s_w_eff)/s_out`。
- 残差分支需对齐到同一 `s_out` 后再相加。

建议在导出阶段离线求解每层的 `s_out`，并附带 PoT 限制选项，生成硬件友好的移位参数。

---

## 7) 导出格式（JSON + NPY/BIN）

示例 Schema 片段：

```json
{
  "version": 2,
  "layout": {"tensor": "BCK", "patch_order": "time_sweep:C_then_P", "row_major": true},
  "quant": {"round": "ties_to_even", "saturate": true,
    "act": {"scheme": "per_tensor_asym", "bits": 8},
    "weight": {"scheme": "per_channel_sym", "bits": 8, "axis": 0}
  },
  "layers": [
    {"type":"linear","name":"patch_embed","in":512,"out":128,
     "W":"patch_W.npy","B":"patch_B.npy","w_scale":"patch_WS.npy",
     "act_in":{"scale":0.03125,"zp":3},"act_out":{"scale":0.05,"zp":0}},
    {"type":"dwconv1d","name":"mb1_conv","channels":256,"k":4,
     "W":"mb1_K.npy","w_scale":"mb1_KS.npy","padding":3},
    {"type":"mamba_ssm","name":"mb1_ssm","d_in":256,"n":16,
     "A_log":"Alog.npy","D":"D.npy","x_proj":"xproj_W.npy","dt_proj":"dtproj_W.npy"},
    {"type":"linear","name":"head","in":64,"out":2,
     "W":"head_W.npy","B":"head_B.npy","w_scale":"head_WS.npy",
     "act_in":{"scale":0.03125,"zp":0}}
  ]
}
```

---

## 8) HLS/RTL 顶层接口与并行策略

- 顶层接口（建议）：
  - 数据：AXI‑Stream 输入 `(C,K)`，按 `K` 为主序流入；AXI‑Stream 输出 `(2)`；
  - 控制：AXI‑Lite（加载/选择参数集）；
  - 权重：AXI‑MM（PS 侧 DDR → PL BRAM/URAM）一次加载，多次复用。
- 并行策略：
  - Linear/DWConv：输出通道方向并行度 `Poc=8/16`；输入方向做向量化 `Vin=8/16`，复用 DSP；
  - SSM：n（状态维）较小（默认 16），可全并行或按 8 并行；`l=2` 时时间展开可直接循环展开；
  - LUT：SiLU/Softplus/exp 各 256/512 点，BRAM 存储，单周期查表。

---

## 9) 联调流程（仅推理）

1) 离线导出：冻结权重与量化参数，生成 JSON+NPY；
2) C++ 参考：用 `reference_quant_int8.hpp` 实现整网前向，生成中间向量 dump（各层输入/输出）；
3) RTL/HLS 仿真：以相同输入，按层比对（INT8/INT32/反量化 float），误差容忍 < 1 LSB；
4) ZCU102 上板：PS 加载参数至 PL，DMA 输入 10~100 组样本，采集输出，与 C++ 参考逐样本对齐；
5) 性能评估：测吞吐/时延/功耗，按需要调整并行度与时钟。

---

## 10) 参数建议（ZCU102）

- `proj_dim`=64、`d_model`=96、`n_layer`=2、`d_state`=8、`patch_len/stride`=8/4；
- 并行：`Poc=16`、`Vin=16`；`clk`=200–250 MHz（视时序）；
- 资源预估（示例）：DSP < 500，BRAM < 300；具体以 Vivado 报告为准。

---

## 11) 风险与应对

- SSM 近似误差：优先在 `l=2` 的前提下用更细 LUT/PWL；必要时该子模块保留浮点核或 Q16.16 的更高精度路径。
- 残差分支尺度对齐：导出端确保提供匹配的 `s_out`；硬件端统一在加法前做重定标与饱和。
- 位置编码折叠：若折叠入 patch 线性层，需对每个 patch index 维护独立 bias 偏置（常量）。

---

## 12) 最小落地清单（仅推理）

- 定版“数字契约”（本文件第 3/4 节）；
- 编写权重/尺度导出脚本（JSON+NPY）；
- 实现 C++ 参考推理（bit‑exact）；
- HLS/RTL 实现 Linear、DWConv、SiLU/Softplus LUT、SSM 扫描（l=2）；
- 写 AXI‑Stream 顶层包装与 PS 侧 Demo；
- 逐层矢量对齐 + 上板实测。

