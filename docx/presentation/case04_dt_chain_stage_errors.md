# Case 04 DT Chain Stage Error Summary

This document compares the two scan modes for case 04, sample 0:

- `fixed_q88`: `final_hw/cases/04/logs/dt_chain_debug_sample0.json`
- `scaled_state`: `final_hw/cases/04/logs/dt_chain_debug_sample0_scaled_state.json`

The comparison is cpp-like float/int semantics versus hw-like chain4 q8.8 semantics. `scaled_state` changes the state update scale inside `selective_scan`; stages before `selective_scan` should therefore remain nearly identical unless later block inputs have already diverged.

## Key Result

`scaled_state` materially reduces the dominant error source: `selective_scan`.

| Stage | Fixed Avg MAE | Scaled Avg MAE | MAE Delta | Improvement |
|---|---:|---:|---:|---:|
| selective_scan | 0.121098 | 0.090323 | -0.030776 | 25.41% |
| ewm_gating | 0.034753 | 0.028978 | -0.005775 | 16.62% |
| outproj | 0.044009 | 0.036918 | -0.007091 | 16.11% |
| block_output | 0.053300 | 0.050464 | -0.002836 | 5.32% |

This proves the scale path is important: the first large reduction appears exactly at `selective_scan`, and part of that reduction propagates through `ewm_gating`, `outproj`, and final block output.

## Selective Scan

| Block | Fixed MAE | Scaled MAE | MAE Delta | Fixed Max | Scaled Max | Max Delta |
|---|---:|---:|---:|---:|---:|---:|
| block0 | 0.127090 | 0.085484 | -0.041606 | 1.836078 | 0.852945 | -0.983133 |
| block1 | 0.097121 | 0.087604 | -0.009517 | 0.834004 | 0.934178 | +0.100174 |
| block2 | 0.127349 | 0.096943 | -0.030406 | 0.822855 | 0.805772 | -0.017083 |
| block3 | 0.132833 | 0.091259 | -0.041574 | 0.919629 | 1.316820 | +0.397191 |

`scaled_state` improves `selective_scan` MAE in all four blocks. The largest MAE reductions are block0 and block3, both about `0.0416`.

## Gating And Projection

The scan result feeds `ewm_gating`, then `outproj`. Those stages also improve on average.

### EWM Gating

| Block | Fixed MAE | Scaled MAE | MAE Delta | Fixed Max | Scaled Max | Max Delta |
|---|---:|---:|---:|---:|---:|---:|
| block0 | 0.033001 | 0.029827 | -0.003174 | 0.466367 | 0.467679 | +0.001311 |
| block1 | 0.026524 | 0.024379 | -0.002145 | 0.608140 | 0.587620 | -0.020521 |
| block2 | 0.042982 | 0.035648 | -0.007334 | 0.725638 | 0.455017 | -0.270621 |
| block3 | 0.036506 | 0.026059 | -0.010447 | 0.604976 | 0.555675 | -0.049301 |

### Out Projection

| Block | Fixed MAE | Scaled MAE | MAE Delta | Fixed Max | Scaled Max | Max Delta |
|---|---:|---:|---:|---:|---:|---:|
| block0 | 0.032225 | 0.031243 | -0.000981 | 0.100456 | 0.104575 | +0.004118 |
| block1 | 0.031305 | 0.029109 | -0.002197 | 0.089612 | 0.112271 | +0.022659 |
| block2 | 0.045758 | 0.046820 | +0.001062 | 0.179544 | 0.145903 | -0.033641 |
| block3 | 0.066747 | 0.040499 | -0.026248 | 0.191562 | 0.151651 | -0.039911 |

## Block Output

| Block | Fixed MAE | Scaled MAE | MAE Delta | Fixed Max | Scaled Max | Max Delta |
|---|---:|---:|---:|---:|---:|---:|
| block0 | 0.032426 | 0.031332 | -0.001094 | 0.099216 | 0.106085 | +0.006869 |
| block1 | 0.041138 | 0.043511 | +0.002372 | 0.134051 | 0.155190 | +0.021140 |
| block2 | 0.059177 | 0.063802 | +0.004625 | 0.218708 | 0.261147 | +0.042439 |
| block3 | 0.080459 | 0.063209 | -0.017249 | 0.240635 | 0.212255 | -0.028381 |

The final block output improvement is smaller than the scan improvement because residual addition and later projection mix the error with other quantization effects. Still, by block3 the output MAE drops from `0.080459` to `0.063209`.

## Full Per-Stage MAE

### Block 0

| Stage | Fixed MAE | Scaled MAE | Delta |
|---|---:|---:|---:|
| norm | 0.004498 | 0.004498 | +0.000000 |
| inproj_u | 0.010917 | 0.010917 | +0.000000 |
| inproj_z | 0.011069 | 0.011069 | +0.000000 |
| silu_u | 0.006183 | 0.006183 | +0.000000 |
| silu_gate | 0.005931 | 0.005931 | +0.000000 |
| dtproj | 0.010139 | 0.010139 | +0.000000 |
| dt_sigmoid | 0.002118 | 0.002118 | +0.000000 |
| selective_scan | 0.127090 | 0.085484 | -0.041606 |
| ewm_gating | 0.033001 | 0.029827 | -0.003174 |
| outproj | 0.032225 | 0.031243 | -0.000981 |
| block_output | 0.032426 | 0.031332 | -0.001094 |

### Block 1

| Stage | Fixed MAE | Scaled MAE | Delta |
|---|---:|---:|---:|
| norm | 0.032719 | 0.032267 | -0.000451 |
| inproj_u | 0.024226 | 0.021053 | -0.003172 |
| inproj_z | 0.022330 | 0.021995 | -0.000335 |
| silu_u | 0.010924 | 0.009988 | -0.000937 |
| silu_gate | 0.011154 | 0.011177 | +0.000023 |
| dtproj | 0.012954 | 0.011544 | -0.001410 |
| dt_sigmoid | 0.003022 | 0.002675 | -0.000347 |
| selective_scan | 0.097121 | 0.087604 | -0.009517 |
| ewm_gating | 0.026524 | 0.024379 | -0.002145 |
| outproj | 0.031305 | 0.029109 | -0.002197 |
| block_output | 0.041138 | 0.043511 | +0.002372 |

### Block 2

| Stage | Fixed MAE | Scaled MAE | Delta |
|---|---:|---:|---:|
| norm | 0.040036 | 0.042263 | +0.002227 |
| inproj_u | 0.026211 | 0.030660 | +0.004450 |
| inproj_z | 0.026770 | 0.028639 | +0.001868 |
| silu_u | 0.013965 | 0.015458 | +0.001492 |
| silu_gate | 0.013673 | 0.014308 | +0.000635 |
| dtproj | 0.015275 | 0.020845 | +0.005569 |
| dt_sigmoid | 0.003206 | 0.004356 | +0.001149 |
| selective_scan | 0.127349 | 0.096943 | -0.030406 |
| ewm_gating | 0.042982 | 0.035648 | -0.007334 |
| outproj | 0.045758 | 0.046820 | +0.001062 |
| block_output | 0.059177 | 0.063802 | +0.004625 |

### Block 3

| Stage | Fixed MAE | Scaled MAE | Delta |
|---|---:|---:|---:|
| norm | 0.048674 | 0.049124 | +0.000450 |
| inproj_u | 0.035350 | 0.036145 | +0.000795 |
| inproj_z | 0.033259 | 0.033932 | +0.000673 |
| silu_u | 0.017179 | 0.017593 | +0.000414 |
| silu_gate | 0.015927 | 0.016280 | +0.000353 |
| dtproj | 0.020325 | 0.025587 | +0.005262 |
| dt_sigmoid | 0.004467 | 0.005688 | +0.001221 |
| selective_scan | 0.132833 | 0.091259 | -0.041574 |
| ewm_gating | 0.036506 | 0.026059 | -0.010447 |
| outproj | 0.066747 | 0.040499 | -0.026248 |
| block_output | 0.080459 | 0.063209 | -0.017249 |

## Conclusion

Scale is not a cosmetic implementation detail. In this case, enabling `scaled_state` changes the selective scan state representation and reduces the dominant scan MAE from `0.121098` to `0.090323` on average. The improvement then carries into gating and projection, especially in block3 where final block output MAE drops by `0.017249`.

The max error is not uniformly better for every block, so scale does not eliminate all outliers. But the consistent all-block MAE reduction at `selective_scan` proves that the fixed q8.8 state scale is too coarse for this case.

## Reproduction

Default `fixed_q88` run:

```powershell
python -m refactor.bittrue.debug_dt_chain_mismatch --export_json final_hw/cases/04/export_ir/export.json --case_dir final_hw/cases/04 --sample_idx 0
```

Explicit `scaled_state` run:

```powershell
python -m refactor.bittrue.debug_dt_chain_mismatch --export_json final_hw/cases/04/export_ir/export.json --case_dir final_hw/cases/04 --sample_idx 0 --scan_mode scaled_state
```

