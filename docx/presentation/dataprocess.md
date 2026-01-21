# Data Processing Pipeline （CSI ? CIR Features）

```mermaid
flowchart LR
    A[Raw CSI （.mat）] --> B[IFFT over frequency <br/>? CIR]
    B --> C[Truncate taps <br/> Keep first K taps]
    C --> D[Per-antenna normalization
Scale by RMS]
    D --> E[Feature concat
Re（CIR） + Im（CIR）]
    E --> F[Power features
log1p（mean（\CIR\^2））]
    F --> G{Optional}
    G -->|--delta| H[Append first-order
 temporal difference]
    G -->|no delta| I[Keep base features]
    H --> J[Windowing
K=16, stride]
    I --> J
    J --> K[Train-only stats
mean/std]
    K --> L[Outputs
feats.npy / xy.npy / ts.npy
stats_train.npz]
```

- Notes for PPT
  - Keep boxes short, use 2-line labels.
  - Left-to-right layout is slide-friendly.
  - Replace ?K taps? with your actual `taps` value if needed.
