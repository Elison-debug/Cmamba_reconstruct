# Case 04 Full HW-like Evaluation: One-slide Summary

Source:

```text
final_hw/cases/04/logs/full_hw_like_eval.json
```

## Setup

| Item | Value |
|---|---:|
| Samples | 34,505 |
| Scan mode | `scaled_state` |
| Block source | `case_chain4` |
| Input mode | `stream_parallel_nocache` |

## Key Metrics

| Comparison | MAE | Max Abs | Meaning |
|---|---:|---:|---|
| `hw_like_vs_cpp` | 0.02027 | 0.13866 | hardware-like fixed-point error against C++ reference |
| `hw_like_vs_float` | 0.02081 | 0.15173 | final hardware-like deviation from float model |
| `cppish_vs_cpp` | 0.000032 | 0.00404 | Python `cpp_like` closely matches real C++ reference |

## Task-level Accuracy

| Metric vs `y_true` | Value |
|---|---:|
| Mean error | 0.14103 |
| Median error | 0.10339 |
| P80 error | 0.20949 |
| P90 error | 0.29808 |
| Max error | 1.35270 |

## Slide Takeaways

- `cpp_like` is validated: its MAE against real C++ is only `3.2e-5`.
- HW-like output remains close to both C++ reference and float output: around `0.02` MAE.
- With `scaled_state`, the full 34,505-sample evaluation reaches mean task error `0.141` and P90 error `0.298`.
- Remaining gap mainly reflects hardware-friendly fixed-point mapping, not a mismatch between Python `cpp_like` and C++.

## One-line Message

```text
Case 04 scaled-state HW-like inference closely tracks the C++ reference over the full dataset, with ~0.02 MAE hardware-mapping error and 0.141 mean task error.
```

