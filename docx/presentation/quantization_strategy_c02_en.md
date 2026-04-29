# final_hw c02 Quantization Strategy

This document records the quantization semantics currently used by `final_hw/cases/c02`, and how the corresponding scaling and rounding are implemented in RTL.

## Current Results

Source:

```text
final_hw/cases/c02/logs/full_hw_like_eval.json
```

Current evaluation summary:

```text
samples              = 64
scan_mode            = scaled_state
block_source         = case_chain4
hw_like_vs_cpp mae   = 0.016766730695962906
hw_like_vs_cpp max   = 0.05162525177001953
hw_like_vs_float mae = 0.01628795638680458
```

## Layer-by-Layer Quantization Table

| stage | format | scale | rounding | notes |
|---|---|---|---|---|
| block input `h` | Q8.8 signed int16 | static fixed scale `1/256` | during float export: `round(float * 256)`; Python uses nearest integer | block input is written to `h_wr_data_s16_q8p8.mem`. |
| RMSNorm gamma | Q8.8 signed int16 | static fixed scale `1/256` | during float export: `round(gamma * 256)` | gamma comes from `norm_gamma_s16_q8p8.mem`. |
| RMSNorm output | Q8.8 signed int16 | static fixed output scale `1/256` | `requant_round_sat_engine`, currently configured as round-to-nearest-even, with int16 saturation | c02 uses `exact_recip30` hardware-like RMSNorm. The output is written into the in-proj input SRAM. |
| in_proj U/Z | Q8.8 signed int16 | input scale `1/256`, weight scale `1/256`, output scale `1/256` | after MAC, shift right by 8 from Q16.16 back to Q8.8, use round-to-nearest-even, then saturate | generates `u_golden_q88.mem` and `z_golden_q88.mem`; weights come from `inproj_wbuf_bank*.mem`. |
| in_proj post scale | Q1.15 packed scale | static identity scale `0x8000 = 1.0` | the scale multiplication path exists; current identity scale does not change the value | `inproj_scale_q15.mem` is currently all `8000`, so no extra per-channel rescale is enabled. |
| SiLU / gate | sigmoid is Q0.16, data is Q8.8, output is Q8.8 | sigmoid scale `1/65536`, data/output scale `1/256` | sigmoid LUT outputs integers; after multiplication, shift right by 16 back to Q8.8, then requantize according to the EW multiply module rules | uses sigmoid LUT; generates `u_act_golden_q88.mem` and `z_silu_golden_q88.mem`. |
| dt_proj | Q8.8 signed int16 | input scale `1/256`, weight scale `1/256`, output scale `1/256` | after MAC, shift right by 8 from Q16.16 back to Q8.8, use round-to-nearest-even, then saturate | weights come from `dt_wbuf_bank*.mem`, bias comes from `bias_ROM.mem`, output is `dt_golden_q88.mem`. |
| dt_proj post scale | Q1.15 packed scale | static identity scale `0x8000 = 1.0` | the scale multiplication path exists; current identity scale does not change the value | `dt_scale_q15.mem` is currently all `8000`. |
| dt sigmoid / lambda | Q0.16 unsigned | static fixed scale `1/65536` | LUT outputs discrete Q0.16 values | `dt_q88` is fed into the sigmoid LUT, producing `lam_golden_q016.mem`. |
| selective scan lambda | Q1.15 internal | static conversion from Q0.16: `lam_q15 = lam_q016 >> 1` | right shift by 1, equivalent to truncating the least significant bit | in scaled-state scan mode, EW update uses Q1.15 lambda. |
| selective scan state write | scaled signed int16 | per-state-channel static scale, precomputed during Python export and written into `state_u_to_state_q16.mem` | after `u_act Q8.8 * state_u_to_state_q16`, shift right by 16, round-to-nearest-even, then saturate to int16 | the state SRAM stores scaled int16 rather than raw Q8.8. |
| selective scan state update | scaled signed int16 | the state keeps the corresponding per-state-channel static scale | `lam_q15 * s_prev + (1-lam_q15) * u_scaled`, then shift right by 15, round-to-nearest-even, then saturate | the core update semantics are `s_new = lam * s_prev + (1-lam) * u`. |
| selective scan output | Q8.8 signed int16 | per-state-channel static scale, precomputed during Python export and written into `state_to_q88_q16.mem` | `scaled_state * state_to_q88_q16`, then shift right by 16, round-to-nearest-even, then saturate to Q8.8 int16 | outputs `ssm_golden_q88.mem` for the downstream gate path. |
| ewm gating | Q8.8 signed int16 | both input and output scales are `1/256` | Q8.8 * Q8.8 produces Q16.16, then shift right by 8 back to Q8.8 and requantize according to the EW multiply rules | computes `gate_y = z_silu * ssm`, output is `gate_y_golden_q88.mem`. |
| out_proj | Q8.8 signed int16 | input scale `1/256`, weight scale `1/256`, output scale `1/256` | after MAC, shift right by 8 from Q16.16 back to Q8.8, use round-to-nearest-even, then saturate | weights come from `outproj_wbuf_bank*.mem`, output is `y_golden_q88.mem`. |
| out_proj post scale | Q1.15 packed scale | static identity scale `0x8000 = 1.0` | the scale multiplication path exists; current identity scale does not change the value | `outproj_scale_q15.mem` is currently all `8000`. |
| residual / block output | Q8.8 signed int16 | static fixed scale `1/256` | int16 addition followed by clamp/saturation to Q8.8 int16 | `x_next_golden_q88.mem = clamp(h_wr_data + y_golden)`, used as the next block input. |

## How Scaling and Rounding Are Implemented in Hardware

### 1. Fixed Q8.8 Scaling

Most activations and weights use Q8.8:

```text
real_value = int_value / 256
int_value  = round(real_value * 256)
```

In RTL, multiplying Q8.8 by Q8.8 produces Q16.16:

```text
(a / 256) * (b / 256) = (a * b) / 65536
```

If the downstream stage still expects Q8.8, Q16.16 must be converted back to Q8.8:

```text
q88_out = round((a * b) / 256)
```

The hardware implementation is typically:

```text
obtain a wide accumulator from multiplication
process the low bits according to the rounding rule
arithmetic right shift by 8
saturate to int16
```

The generic RTL module for this is:

```text
final_hw/rtl_reuse_shared/requant_round_sat_engine.sv
```

### 2. Q1.15 Scale-Memory Scaling

`in_proj`, `dt_proj`, and `out_proj` all keep a post-scale multiplication path, with the scale stored in Q1.15:

```text
scale_real = scale_q15 / 32768
```

For c02, the three scale memories are all:

```text
0x8000 = 32768 = 1.0
```

So this path is currently a static identity scale and does not change the value:

```text
inproj_scale_q15.mem  = 8000...
dt_scale_q15.mem      = 8000...
outproj_scale_q15.mem = 8000...
```

If a non-1.0 scale is enabled later in hardware, the operation becomes:

```text
acc_or_q88 * scale_q15
round shift by 15
saturate
```

### 3. Sigmoid Q0.16 Scaling

The sigmoid output uses Q0.16:

```text
sigmoid_real = sigmoid_q016 / 65536
```

Hardware does not compute sigmoid dynamically. It uses a LUT instead:

```text
Q8.8 input -> clamp/address -> LUT -> Q0.16 output
```

As a result, rounding for sigmoid mainly happens when the LUT is generated. At RTL runtime, the main operations are address mapping and lookup.

### 4. Scaled-State Scan Scaling

This is the most important change in the current c02 setup.

The old strategy was:

```text
state SRAM stores Q8.8 directly
all state channels share the same fixed scale = 1/256
```

The current strategy is:

```text
state SRAM stores scaled int16
each state channel has its own scale
the scan output is converted back to Q8.8
```

Relevant memory files:

```text
state_u_to_state_q16.mem
state_to_q88_q16.mem
```

Note: the current RTL does not read back the full SRAM at runtime, collect maxima, and compute scale dynamically.

Scale computation happens during the Python export stage:

```text
Python reads or generates the reference data range for the case
computes scale for each state channel
writes state_u_to_state_q16.mem and state_to_q88_q16.mem
RTL simulation / hardware runtime only reads these scale memories
```

So the current scheme is:

```text
per-channel static scale from export
```

not:

```text
runtime dynamic scale computed inside RTL
```

The scaled-state operation in hardware has three steps:

```text
1. u_act Q8.8 -> scaled int16
   u_scaled = round((u_q88 * state_u_to_state_q16) >> 16)

2. scaled-state EW update
   lam_q15 = lam_q016 >> 1
   s_new = round((lam_q15 * s_prev + (32768 - lam_q15) * u_scaled) >> 15)

3. scaled int16 -> Q8.8 output
   ssm_q88 = round((s_new * state_to_q88_q16) >> 16)
```

These three steps are implemented along the paths involving `ew_update_vec4.sv` and `requant_round_sat_engine.sv`.

### 5. Rounding Rule

The current setup mainly uses round-to-nearest-even, i.e. tie-to-even.

Intuitively:

```text
not simple truncation
not always rounding 0.5 upward
round to the nearest integer
if exactly halfway, choose the even integer
```

The reason is to reduce long-term accumulated bias. Simple truncation tends to bias values downward systematically. Standard round-half-up can also introduce slight bias over large data volumes. Tie-to-even is better suited for paths with accumulated error, such as multi-layer MAC pipelines and recurrent scan updates.

### 6. Saturation / Clamp

Most Q8.8 outputs are finally saturated to signed int16:

```text
min = -32768
max =  32767
```

This corresponds to a real-value range of approximately:

```text
[-128.0, 127.996]
```

If an intermediate result exceeds this range, RTL does not allow it to overflow into an incorrect sign. It is clamped to the int16 boundary instead.

## Current Conclusion

For c02, each linear layer is still mainly quantized using fixed Q8.8. Although post-scale memories exist for `in_proj`, `dt_proj`, and `out_proj`, their current values are the identity `0x8000`.

The component that truly changes the error structure is the selective scan:

```text
fixed Q8.8 state -> per-state-channel scaled int16 state
```

This significantly reduces the scan-related error. For the current `sample0`:

```text
selective_scan mae ~= 0.00360
inproj_u       mae ~= 0.01056
inproj_z       mae ~= 0.01073
dtproj         mae ~= 0.01014
```

Therefore, the main remaining error is no longer the scan-state representation itself, but the Q8.8 projection quantization and the accumulated error across the 4-block chain.
