import os
import sys
from pathlib import Path

import torch


def main():
    # Ensure we are running from project root or package importable
    here = Path(__file__).resolve().parent
    pkg_root = here.parent.parent
    if str(pkg_root) not in sys.path:
        sys.path.insert(0, str(pkg_root))

    print({"torch_version": torch.__version__, "cuda": torch.cuda.is_available()})

    # 1) Build/load C++ extension
    from .cpp_backend import get_cpp_quant, QConv1x1INT
    m = get_cpp_quant()
    print({
        "loaded": True,
        "symbols": [
            hasattr(m, "quant_per_tensor_asym"),
            hasattr(m, "dequant_per_tensor_asym"),
            hasattr(m, "quant_per_channel_sym"),
            hasattr(m, "quant_per_tensor_asym16"),
            hasattr(m, "dequant_per_tensor_asym16"),
            hasattr(m, "quant_per_channel_sym16"),
        ],
    })

    # 2) Exercise raw functions
    x = torch.randn(2, 3, 5, dtype=torch.float32)
    w = torch.randn(4, 3, 1, dtype=torch.float32)
    a_scale = 0.05
    a_zp = 0
    qmin8, qmax8 = -(1 << 7), (1 << 7) - 1
    qmin16, qmax16 = -(1 << 15), (1 << 15) - 1
    # INT8 per-tensor
    xq8 = m.quant_per_tensor_asym(x, float(a_scale), int(a_zp), int(qmin8), int(qmax8))
    x8 = m.dequant_per_tensor_asym(xq8, float(a_scale), int(a_zp))
    # INT16 per-tensor
    xq16 = m.quant_per_tensor_asym16(x, float(a_scale), int(a_zp), int(qmin16), int(qmax16))
    x16 = m.dequant_per_tensor_asym16(xq16, float(a_scale), int(a_zp))
    # per-channel weights
    w_scale8 = torch.ones(w.shape[0], dtype=torch.float32)
    wq8 = m.quant_per_channel_sym(w, w_scale8, 0, int(qmin8), int(qmax8))
    w_scale16 = torch.ones(w.shape[0], dtype=torch.float32)
    wq16 = m.quant_per_channel_sym16(w, w_scale16, 0, int(qmin16), int(qmax16))
    print({
        "raw_ok": True,
        "xq8_dtype": str(xq8.dtype), "x8_shape": tuple(x8.shape),
        "xq16_dtype": str(xq16.dtype), "x16_shape": tuple(x16.shape),
        "wq8_dtype": str(wq8.dtype), "wq16_dtype": str(wq16.dtype),
    })

    # 3) Forward pass through QConv1x1INT for 8/16 bits
    B, C, K = 2, 8, 16
    x_in = torch.randn(B, C, K)
    for bits in (8, 16):
        qconv = QConv1x1INT(in_f=C, out_f=6, bias=True, a_bits=bits, w_bits=bits, ch_axis=0)
        # set per-channel activation scales and per-channel weight scales to non-zero
        if hasattr(qconv, "a_scale"):
            with torch.no_grad():
                if qconv.a_scale.dim() == 1 and qconv.a_scale.numel() == C:
                    qconv.a_scale.fill_(0.05)
                else:
                    qconv.a_scale.fill_(0.05)
        if hasattr(qconv, "w_scale"):
            with torch.no_grad():
                qconv.w_scale.fill_(0.05)
        y = qconv(x_in)
        assert y.shape == (B, 6, K if bits in (8, 16) else K), f"unexpected shape: {y.shape}"
        print({"qconv_bits": bits, "out_shape": tuple(y.shape), "nan": bool(torch.isnan(y).any().item())})

    print({"status": "ok"})


if __name__ == "__main__":
    main()

