"""
小脚本：使用 torch.utils.cpp_extension 预编译/加载量化 C++ 扩展，并在 Python 中一键切换与测试量化后端。

用法示例：
  1) 仅预编译 C++ 扩展：
     python -m refactor.quant.build_and_use --prebuild

  2) 测试 Python 伪量化后端：
     python -m refactor.quant.build_and_use --backend=python --test_linear

  3) 测试 C++ 量化后端（若未编译，会自动触发 JIT 编译）：
     python -m refactor.quant.build_and_use --backend=cpp --test_linear

说明：
  - 仅量化 1x1 卷积 QConv1x1INT 会使用选择的后端（cpp/python），其余网络计算仍在 PyTorch 中。
  - 脚本只做最小验证（前向与梯度），方便快速确认环境可用。
"""

from __future__ import annotations
import argparse
import sys
import traceback

import torch


def prebuild_cpp() -> bool:
    try:
        from .cpp_backend import get_cpp_quant
        m = get_cpp_quant()
        # 简单探测函数是否存在
        getattr(m, "quant_per_tensor_asym")
        getattr(m, "dequant_per_tensor_asym")
        getattr(m, "quant_per_channel_sym")
        print({"prebuild": True, "module": str(m)})
        return True
    except Exception:
        print({"prebuild": False, "error": traceback.format_exc()})
        return False


def test_qlinear(backend: str = "python") -> bool:
    try:
        from .qat_layers import QConv1x1INT, set_default_backend
        set_default_backend(backend)
        in_f, out_f, B, K = 16, 8, 4, 12
        x = torch.randn(B, in_f, K, dtype=torch.float32, requires_grad=True)
        lin = QConv1x1INT(in_f, out_f, backend=backend)
        y = lin(x)
        loss = y.pow(2).mean()
        loss.backward()
        print({
            "backend": backend,
            "x": list(x.shape),
            "y": list(y.shape),
            "loss": float(loss.detach().cpu().item()),
            "has_grad": (x.grad is not None),
        })
        return True
    except Exception:
        print({"test_linear": False, "backend": backend, "error": traceback.format_exc()})
        return False


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--backend", type=str, choices=["cpp", "python"], default="cpp")
    p.add_argument("--prebuild", action="store_true", help="仅预编译/加载 C++ 扩展")
    p.add_argument("--test_linear", action="store_true", help="运行一个最小的 QConv1x1INT 前向+反向测试")
    args = p.parse_args()

    ok = True
    if args.prebuild:
        ok = prebuild_cpp() and ok
    if args.test_linear:
        ok = test_qlinear(args.backend) and ok
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
