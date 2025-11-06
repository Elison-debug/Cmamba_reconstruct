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
    xq8 = m.quant_per_tensor_asym(x, float(a_scale), int(a_zp), int(qmin8), int(qmax8))  # type: ignore
    x8 = m.dequant_per_tensor_asym(xq8, float(a_scale), int(a_zp))# type: ignore
    # INT16 per-tensor
    xq16 = m.quant_per_tensor_asym16(x, float(a_scale), int(a_zp), int(qmin16), int(qmax16))# type: ignore
    x16 = m.dequant_per_tensor_asym16(xq16, float(a_scale), int(a_zp))# type: ignore
    w_scale8 = torch.ones(w.shape[0], dtype=torch.float32)
    wq8 = m.quant_per_channel_sym(w, w_scale8, 0, int(qmin8), int(qmax8))# type: ignore
    w_scale16 = torch.ones(w.shape[0], dtype=torch.float32)
    wq16 = m.quant_per_channel_sym16(w, w_scale16, 0, int(qmin16), int(qmax16))# type: ignore
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

    # 4) Python LSQ vs C++ numerical consistency on a single 1x1 layer
    print({"compare_py_cpp": True})
    from .qat_layers import QConv1x1INT as QPy
    torch.manual_seed(0)
    B, C, K, O = 2, 8, 32, 5
    x = torch.randn(B, C, K)
    for bits in (8, 16):
        py = QPy(in_f=C, out_f=O, bias=True, a_bits=bits, w_bits=bits, backend="python")
        cpp = QConv1x1INT(in_f=C, out_f=O, bias=True, a_bits=bits, w_bits=bits, ch_axis=0)
        # sync weights/bias
        with torch.no_grad():
            w = torch.randn_like(py.conv.weight)
            b = torch.randn_like(py.conv.bias)  # type: ignore
            py.conv.weight.copy_(w); py.conv.bias.copy_(b) # type: ignore
            cpp.conv.weight.copy_(w); cpp.conv.bias.copy_(b) # type: ignore
            # scales
            if hasattr(py, "qa") and hasattr(py.qa, "scale"):
                if py.qa.scale.dim() == 1 and py.qa.scale.numel() == C:
                    py.qa.scale.copy_(torch.full((C,), 0.05, dtype=py.qa.scale.dtype))
            if hasattr(py, "qw") and hasattr(py.qw, "scale"):
                if py.qw.scale.dim() == 1 and py.qw.scale.numel() == O:
                    py.qw.scale.copy_(torch.full((O,), 0.05, dtype=py.qw.scale.dtype))
            if hasattr(cpp, "a_scale"):
                if cpp.a_scale.dim() == 1 and cpp.a_scale.numel() == C:
                    cpp.a_scale.copy_(torch.full((C,), 0.05, dtype=cpp.a_scale.dtype))
            if hasattr(cpp, "w_scale"):
                if cpp.w_scale.dim() == 1 and cpp.w_scale.numel() == O:
                    cpp.w_scale.copy_(torch.full((O,), 0.05, dtype=cpp.w_scale.dtype))
        y_py = py(x)
        y_cpp = cpp(x)
        mse = torch.mean((y_py - y_cpp) ** 2).item()
        maxae = torch.max(torch.abs(y_py - y_cpp)).item()
        print({"bits": bits, "mse": mse, "max_abs": maxae, "py_nan": bool(torch.isnan(y_py).any().item()), "cpp_nan": bool(torch.isnan(y_cpp).any().item())})

    print({"status": "ok"})


if __name__ == "__main__":
    main()
