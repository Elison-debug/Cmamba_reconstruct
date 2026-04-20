# Scaled-State SSM Scan RTL Change Log

## Goal

Reduce the fixed Q8.8 SSM scan error by matching the Python `scaled_state` hw-like model:

```text
lam_q15      = lam_q016 >> 1
u_state      = round(u_q88 * u_to_state_q16 / 2^16)
s_new_state  = round((lam_q15*s_prev_state + (32768-lam_q15)*u_state) / 2^15)
ssm_q88      = round(s_new_state * state_to_q88_q16 / 2^16)
```

The state SRAM still stores 4x16-bit lanes, but in scaled-state mode those lanes are signed state-domain int16 values rather than Q8.8 values. The stream emitted to the gate path is requantized back to Q8.8.

## Python Validation

`refactor/bittrue/eval_hw_like_full.py` now supports:

```text
--scan_mode fixed_q88
--scan_mode scaled_state
```

The 100-sample result for `scaled_state` was:

```text
hw_like_vs_cpp MAE = 0.003594893729314208
hw_like_vs_cpp max = 0.014057636260986328
```

The earlier fixed Q8.8 scan result was about:

```text
hw_like_vs_cpp MAE = 0.047479283064603806
```

Sample0 `selective_scan` MAE dropped from about `0.126738` to `0.004616`.

## RTL Changes

### `ew_update_vec4.sv`

Added `USE_SCALED_STATE`, `SCALE_W`, and `SCALE_FRAC_BITS` parameters.

When `USE_SCALED_STATE=0`, the previous fixed Q8.8 path is preserved.

When `USE_SCALED_STATE=1`:

- `lam_vec` is converted from Q0.16 to Q1.15 with `lam_vec >> 1`.
- `u_vec` is requantized from Q8.8 into signed scaled-state int16 using `u_to_state_scale_vec`.
- The EW update computes both products, sums them, and then applies one Q1.15 rounding step.
- The state SRAM write data is `s_new_state`.
- The module output stream is `s_new_state` requantized to Q8.8 using `state_to_q88_scale_vec`.

### `reuse_ssm_core.sv`

Added scaled-state scan parameters and two packed scale memories:

```text
STATE_U_TO_STATE_SCALE_INIT_FILE
STATE_TO_Q88_SCALE_INIT_FILE
```

Each scale memory stores four 32-bit Q16.16 lane scales per row.

### `reuse_mamba_block_top.sv`

Added top-level parameters and passed them into `reuse_ssm_core`:

```text
USE_SCALED_STATE_SCAN
STATE_U_TO_STATE_SCALE_INIT_FILE
STATE_TO_Q88_SCALE_INIT_FILE
```

### Testbenches

`tb_reuse_mamba_block_top_hw_debug.sv` and `tb_reuse_ssm_core_hw_debug.sv` enable scaled-state scan and point to:

```text
state_u_to_state_q16.mem
state_to_q88_q16.mem
```

## Export Changes

`refactor/bittrue/export_hw_debug.py` now writes:

```text
state_u_to_state_q16.mem
state_to_q88_q16.mem
```

for both:

```text
stages/reuse_mamba_block_top
stages/reuse_ssm_core
```

The generated `ssm_golden_q88.mem`, `gate_y_golden_q88.mem`, and downstream `y_golden_q88.mem` now follow the scaled-state scan semantics.

The stage golden also preserves the existing hardware state SRAM addressing behavior: row `t` reads `s_addr=t` and writes the new state to `s_addr+1`, with the same one-entry last-write bypass model used by the fixed Q8.8 exporter. This matches the RTL's existing `s_addr_w = s_addr_r + 1` state flow.

## Verification Order

1. Re-export the hw debug case.
2. Run `reuse_ssm_core_hw_debug`.
3. Run `reuse_mamba_block_top_hw_debug`.
4. Compare `U/Z`, `UACT`, `DT`, `LAM`, `SSM`, `gate_y`, `P`, and `Y` logs.

Do not change IP read latency, replace FIFO IPs, or add synthesis-only `ifdef` behavior for this path.
