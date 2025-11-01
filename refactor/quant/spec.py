ROUNDING = "ties_to_even"
SATURATE = True

# Activation: per-tensor asymmetric INT8
ACT_BITS = 8
ACT_QMIN = 0
ACT_QMAX = (1 << ACT_BITS) - 1

# Weights: per-channel symmetric INT8
W_BITS = 8
W_QMIN = -(1 << (W_BITS - 1))
W_QMAX = (1 << (W_BITS - 1)) - 1

CH_AXIS = 0  # out_channels axis

