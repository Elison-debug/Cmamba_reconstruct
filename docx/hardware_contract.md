Hardware quantization and I/O contract

- Tensor layout: inputs `(B,C,K)`, patch unfold over time, patch content order is channel-major then patch index.
- Rounding: ties-to-even; Saturation: enabled; Accumulation: int32.
- Activations: per-tensor asymmetric INT8; Weights: per-channel symmetric INT8 along out_channels.
- Normalization: prefer folding into adjacent linear layers at export; avoid runtime norms on hardware.
- Determinism: disable AMP/TF32 and stochastic data aug during export/calibration.

