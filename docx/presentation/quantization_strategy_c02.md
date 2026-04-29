# final_hw c02 量化策略说明

本文记录 `final_hw/cases/c02` 当前使用的量化语义，以及这些 scaling / rounding 在 RTL 中如何实现。

## 当前结果

来源：

```text
final_hw/cases/c02/logs/full_hw_like_eval.json
```

当前评估摘要：

```text
samples              = 64
scan_mode            = scaled_state
block_source         = case_chain4
hw_like_vs_cpp mae   = 0.016766730695962906
hw_like_vs_cpp max   = 0.05162525177001953
hw_like_vs_float mae = 0.01628795638680458
```

## 分层量化表

| stage | format | scale | rounding | notes |
|---|---|---|---|---|
| block input `h` | Q8.8 signed int16 | static fixed scale `1/256` | float export 时 `round(float * 256)`，Python 使用 nearest 整数 | block 输入写入 `h_wr_data_s16_q8p8.mem`。 |
| RMSNorm gamma | Q8.8 signed int16 | static fixed scale `1/256` | float export 时 `round(gamma * 256)` | gamma 来自 `norm_gamma_s16_q8p8.mem`。 |
| RMSNorm output | Q8.8 signed int16 | static fixed output scale `1/256` | `requant_round_sat_engine`，当前配置为 round-to-nearest-even，输出饱和到 int16 | c02 记录为 `exact_recip30` hardware-like RMSNorm。输出写给 in_proj 输入 SRAM。 |
| in_proj U/Z | Q8.8 signed int16 | input scale `1/256`，weight scale `1/256`，output scale `1/256` | MAC 后从 Q16.16 右移 8 位回 Q8.8，使用 round-to-nearest-even，再 saturate | 生成 `u_golden_q88.mem`、`z_golden_q88.mem`；权重来自 `inproj_wbuf_bank*.mem`。 |
| in_proj post scale | Q1.15 packed scale | static identity scale `0x8000 = 1.0` | scale 乘法路径存在；当前 identity 不改变数值 | `inproj_scale_q15.mem` 当前全是 `8000`，所以没有启用额外 per-channel rescale。 |
| SiLU / gate | sigmoid 为 Q0.16，数据为 Q8.8，输出 Q8.8 | sigmoid scale `1/65536`，data/output scale `1/256` | sigmoid 查表输出整数；乘法后右移 16 位回 Q8.8，按 EW multiply 模块规则 requant | 使用 sigmoid LUT；生成 `u_act_golden_q88.mem`、`z_silu_golden_q88.mem`。 |
| dt_proj | Q8.8 signed int16 | input scale `1/256`，weight scale `1/256`，output scale `1/256` | MAC 后从 Q16.16 右移 8 位回 Q8.8，使用 round-to-nearest-even，再 saturate | 权重来自 `dt_wbuf_bank*.mem`，bias 来自 `bias_ROM.mem`，输出 `dt_golden_q88.mem`。 |
| dt_proj post scale | Q1.15 packed scale | static identity scale `0x8000 = 1.0` | scale 乘法路径存在；当前 identity 不改变数值 | `dt_scale_q15.mem` 当前全是 `8000`。 |
| dt sigmoid / lambda | Q0.16 unsigned | static fixed scale `1/65536` | LUT 输出离散 Q0.16 值 | `dt_q88` 进 sigmoid LUT，输出 `lam_golden_q016.mem`。 |
| selective scan lambda | Q1.15 internal | static conversion from Q0.16: `lam_q15 = lam_q016 >> 1` | 右移 1 位，等价于截断低位 | scaled-state scan 模式下 EW update 使用 Q1.15 lambda。 |
| selective scan state write | scaled signed int16 | per state channel static scale，由 Python export 预先计算并写入 `state_u_to_state_q16.mem` | `u_act Q8.8 * state_u_to_state_q16` 后右移 16 位，round-to-nearest-even，再 saturate 到 int16 | state SRAM 存 scaled int16，不再直接存 Q8.8。 |
| selective scan state update | scaled signed int16 | state 本身沿用对应 state channel 的 static scale | `lam_q15 * s_prev + (1-lam_q15) * u_scaled` 后右移 15 位，round-to-nearest-even，再 saturate | 核心更新语义是 `s_new = lam * s_prev + (1-lam) * u`。 |
| selective scan output | Q8.8 signed int16 | per state channel static scale，由 Python export 预先计算并写入 `state_to_q88_q16.mem` | `scaled_state * state_to_q88_q16` 后右移 16 位，round-to-nearest-even，再 saturate 到 Q8.8 int16 | 输出 `ssm_golden_q88.mem`，供后级 gate 使用。 |
| ewm gating | Q8.8 signed int16 | input/output scale 都是 `1/256` | Q8.8 * Q8.8 得到 Q16.16，右移 8 位回 Q8.8，按 EW multiply 模块规则 requant | 计算 `gate_y = z_silu * ssm`，输出 `gate_y_golden_q88.mem`。 |
| out_proj | Q8.8 signed int16 | input scale `1/256`，weight scale `1/256`，output scale `1/256` | MAC 后从 Q16.16 右移 8 位回 Q8.8，使用 round-to-nearest-even，再 saturate | 权重来自 `outproj_wbuf_bank*.mem`，输出 `y_golden_q88.mem`。 |
| out_proj post scale | Q1.15 packed scale | static identity scale `0x8000 = 1.0` | scale 乘法路径存在；当前 identity 不改变数值 | `outproj_scale_q15.mem` 当前全是 `8000`。 |
| residual / block output | Q8.8 signed int16 | static fixed scale `1/256` | int16 加法后 clamp/saturate 到 Q8.8 int16 | `x_next_golden_q88.mem = clamp(h_wr_data + y_golden)`，作为下一 block 输入。 |

## Scaling 和 rounding 在硬件里怎么实现

### 1. 固定 Q8.8 scaling

大部分 activation 和 weight 都使用 Q8.8：

```text
real_value = int_value / 256
int_value  = round(real_value * 256)
```

在 RTL 中，Q8.8 乘 Q8.8 后会得到 Q16.16：

```text
(a / 256) * (b / 256) = (a * b) / 65536
```

如果后级仍然需要 Q8.8，就要把 Q16.16 变回 Q8.8：

```text
q88_out = round((a * b) / 256)
```

硬件实现通常是：

```text
乘法得到宽位宽 accumulator
根据 rounding 规则处理低位
算术右移 8 位
饱和到 int16
```

对应的通用 RTL 模块是：

```text
final_hw/rtl_reuse_shared/requant_round_sat_engine.sv
```

### 2. Q1.15 scale mem scaling

in_proj、dt_proj、out_proj 都保留了 post scale 乘法路径，scale 格式是 Q1.15：

```text
scale_real = scale_q15 / 32768
```

当前 c02 的三个 scale mem 都是：

```text
0x8000 = 32768 = 1.0
```

所以这一路目前是静态 identity scale，不改变数值：

```text
inproj_scale_q15.mem  = 8000...
dt_scale_q15.mem      = 8000...
outproj_scale_q15.mem = 8000...
```

硬件上如果未来启用非 1.0 scale，操作就是：

```text
acc_or_q88 * scale_q15
round shift by 15
saturate
```

### 3. sigmoid Q0.16 scaling

sigmoid 输出使用 Q0.16：

```text
sigmoid_real = sigmoid_q016 / 65536
```

硬件不是动态计算 sigmoid，而是查 LUT：

```text
Q8.8 input -> clamp/address -> LUT -> Q0.16 output
```

因此 sigmoid 的 rounding 主要发生在 LUT 生成阶段；RTL 运行时主要是地址映射和查表。

### 4. scaled-state scan scaling

这是当前 c02 最重要的变化。

旧策略是：

```text
state SRAM 直接存 Q8.8
所有 state channel 共用固定 scale = 1/256
```

当前策略是：

```text
state SRAM 存 scaled int16
每个 state channel 有自己的 scale
scan 输出时再转回 Q8.8
```

相关 mem：

```text
state_u_to_state_q16.mem
state_to_q88_q16.mem
```

注意：当前 RTL 不会在运行时先读完整个 SRAM、统计最大值、再动态计算 scale。

scale 的计算发生在 Python export 阶段：

```text
Python 读取/生成该 case 的参考数据范围
为每个 state channel 计算 scale
写出 state_u_to_state_q16.mem 和 state_to_q88_q16.mem
RTL 仿真/硬件运行时只读取这些 scale mem
```

也就是说，当前是：

```text
per-channel static scale from export
```

不是：

```text
runtime dynamic scale computed inside RTL
```

硬件中的 scaled-state 操作分三步：

```text
1. u_act Q8.8 -> scaled int16
   u_scaled = round((u_q88 * state_u_to_state_q16) >> 16)

2. scaled-state EW update
   lam_q15 = lam_q016 >> 1
   s_new = round((lam_q15 * s_prev + (32768 - lam_q15) * u_scaled) >> 15)

3. scaled int16 -> Q8.8 output
   ssm_q88 = round((s_new * state_to_q88_q16) >> 16)
```

这三步都在 `ew_update_vec4.sv` 和 `requant_round_sat_engine.sv` 相关路径里实现。

### 5. rounding 规则

当前主要使用 round-to-nearest-even，也就是 tie-to-even。

直观理解：

```text
不是简单截断
也不是永远 0.5 向上
而是离哪个整数近就取哪个
刚好在中间时，取偶数那个整数
```

这么做的原因是减少长期累积偏差。简单截断会系统性偏小；普通四舍五入在大量数据上也可能有轻微偏置。tie-to-even 更适合多层 MAC / recurrent scan 这种会累计误差的路径。

### 6. saturation / clamp

多数 Q8.8 输出最后都饱和到 signed int16：

```text
min = -32768
max =  32767
```

这对应真实值范围大约是：

```text
[-128.0, 127.996]
```

如果中间结果超过范围，RTL 不让它继续溢出成错误符号，而是 clamp 到 int16 边界。

## 当前结论

c02 当前各线性层仍然主要是固定 Q8.8 量化，in_proj / dt_proj / out_proj 的 post scale mem 虽然存在，但当前值是 identity `0x8000`。

真正改变误差结构的是 selective scan：

```text
fixed Q8.8 state -> per-state-channel scaled int16 state
```

这让 scan 本身的误差明显下降。当前 sample0 中：

```text
selective_scan mae ~= 0.00360
inproj_u       mae ~= 0.01056
inproj_z       mae ~= 0.01073
dtproj         mae ~= 0.01014
```

因此当前主要剩余误差不再是 scan state，而是 Q8.8 projection 量化和 4-block 链式累积。
