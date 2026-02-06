# Data Processing Pipeline （CSI ? CIR Features）

```mermaid
flowchart TD
    A[Raw CSI] --> C[IFFT over frequency CIR <br/> Truncate taps <br/> Keep first K taps]
    C --> E[Per-antenna normalization
Scale by RMS <br/> &Feature concat <br/> Re（CIR） + Im（CIR）]
    E --> F[Power features]
    F --> G{Optional}
    G -->|with delta| H[Append first-order
 temporal difference]
    G -->|no delta| I[Keep base features]
    H --> J[Windowing
K=16, stride]
    I --> J
    J --> L[Output
feats]
```

- Notes for PPT
  - Keep boxes short, use 2-line labels.
  - Left-to-right layout is slide-friendly.
  - Replace ?K taps? with your actual `taps` value if needed.
