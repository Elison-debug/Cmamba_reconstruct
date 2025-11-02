import torch
from .mamba_regressor import MambaRegressor


def main():
    B, K, Din = 2, 12, 2100
    x = torch.randn(B, K, Din)
    model = MambaRegressor(Din=Din, K=K)
    y = model(x)
    print({"in": tuple(x.shape), "out": tuple(y.shape)})


if __name__ == "__main__":
    main()

