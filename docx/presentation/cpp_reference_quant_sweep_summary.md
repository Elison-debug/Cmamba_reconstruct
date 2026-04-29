# C++ Reference Quantization Sweep Summary

这张 sweep 表用于评估不同 C++ reference 量化配置对最终任务误差的影响。它回答的问题是：

```text
在还没有进入 RTL/hw_like 之前，仅从 C++ 部署量化 reference 看，
哪些模块可以降精度，哪些模块对 int8 敏感？
```

## 指标含义

| 指标 | 含义 |
|---|---|
| `mean_err` | `y_cpp` 相对 `y_true` 的平均任务误差，越小越好。 |
| `median_err` | 中位数任务误差，反映典型样本表现。 |
| `p80_err` / `p90_err` | 80% / 90% 样本以内的误差上界，反映大多数样本质量。 |
| `float_vs_cpp_mae` | C++ reference 输出和 float model 输出的平均绝对差，衡量量化偏差。 |
| `float_vs_cpp_max_abs` | C++ reference 和 float model 的最大单元素差，反映最坏 outlier。 |

## 结果摘要

| label | mode | overrides | mean_err | p90_err | float_vs_cpp_mae | 结论 |
|---|---|---|---:|---:|---:|---|
| `fake` | `fake` | 空 | 0.13695 | 0.29646 | 0.00010 | 几乎等同 float，是参考上限。 |
| `all_int16` | `int16` | `ssm_state=int16,gate=int16` | 0.13520 | 0.29327 | 0.00705 | 全 int16 基本保持 float 精度。 |
| `mixed_candidate` | `int16` | `dt_proj=int8,ssm_state=int8,gate=int8` | 0.13519 | 0.29318 | 0.00702 | `dt_proj/ssm_state/gate` 降到 int8 损失很小，是较好的混合量化候选。 |
| `patch_i8_on_i16` | `int16` | `patch_embedding=int8,ssm_state=int16,gate=int16` | 0.82425 | 1.37696 | 0.47089 | `patch_embedding` 对 int8 极敏感，不适合直接降到 int8。 |
| `inproj_i8_on_i16` | `int16` | `in_proj=int8,ssm_state=int16,gate=int16` | 0.76520 | 1.28336 | 0.48383 | `in_proj` 对 int8 极敏感，不适合直接降到 int8。 |
| `outproj_i8_on_i16` | `int16` | `out_proj=int8,ssm_state=int16,gate=int16` | 0.24352 | 0.49104 | 0.10987 | `out_proj` 降 int8 有明显损失，但比 `patch_embedding/in_proj` 轻。 |

## 主要结论

1. `all_int16` 和 `fake` 的任务误差非常接近，说明 **int16 作为 C++ 部署 reference 是安全的**。
2. `mixed_candidate` 几乎不劣于 `all_int16`，说明 **`dt_proj`、`ssm_state`、`gate` 是可以优先尝试 int8 的模块**。
3. `patch_embedding=int8` 和 `in_proj=int8` 后误差大幅上升，说明 **输入侧 projection 对 int8 非常敏感**。
4. `out_proj=int8` 也会带来明显损失，但严重程度低于 `patch_embedding` 和 `in_proj`。

## 汇报用一句话

```text
C++ reference sweep 表明，整体 int16 基本不损失模型精度；
dt_proj / ssm_state / gate 可以作为 int8 混合量化候选；
但 patch_embedding 和 in_proj 对 int8 非常敏感，是当前不适合直接降精度的关键模块。
```

