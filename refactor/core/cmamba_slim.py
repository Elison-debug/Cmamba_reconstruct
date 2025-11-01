import math
import os
import torch
import torch.nn as nn
import os

class ModelArgs:
    def __init__(
        self,
        d_model: int = 128,
        n_layer: int = 4,
        seq_len: int = 96,
        d_state: int = 16,
        expand: int = 2,
        dt_rank: str | int = "auto",
        d_conv: int = 4,
        pad_multiple: int = 1,
        conv_bias: bool = True,
        bias: bool = False,
        num_channels: int = 64,
        patch_len: int = 16,
        stride: int = 4,
        forecast_len: int = 96,
        reduction_ratio: int = 8,
        verbose: bool = False,
    ) -> None:
        self.d_model = d_model
        self.n_layer = n_layer
        self.seq_len = seq_len
        self.d_state = d_state
        self.v = verbose
        self.expand = expand
        self.dt_rank = dt_rank
        self.d_conv = d_conv
        self.pad_multiple = pad_multiple
        self.conv_bias = conv_bias
        self.bias = bias
        self.num_channels = num_channels
        self.patch_len = patch_len
        self.stride = stride
        self.forecast_len = forecast_len
        self.reduction_ratio = reduction_ratio

        self.num_patches = (self.seq_len - self.patch_len) // self.stride + 1
        self.d_inner = int(self.expand * self.d_model)

        if self.dt_rank == "auto":
            self.dt_rank = math.ceil(self.d_model / 16)
        if self.forecast_len % self.pad_multiple != 0:
            self.forecast_len += (
                self.pad_multiple - self.forecast_len % self.pad_multiple
            )


class RMSNorm(nn.Module):
    def __init__(self, d_model: int, eps: float = 1e-5):
        super().__init__()
        self.eps = eps
        self.weight = nn.Parameter(torch.ones(d_model))

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        var = x.pow(2).mean(dim=-1, keepdim=True)
        x = x * torch.rsqrt(var + self.eps)
        return x * self.weight


class SelectiveScanIC(nn.Module):
    """
    Input-conditioned SSM (Mamba-style approximation):
    lam_t = sigmoid(dt_proj(u_t)) in (0,1)
    s_t = lam_t ⊙ s_{t-1} + (1 - lam_t) ⊙ u_t
    y_t = s_t
    dt_proj is quantizable Linear.
    """

    def __init__(self, dim: int, LinearImpl=nn.Linear):
        super().__init__()
        self.dt_proj = LinearImpl(dim, dim, bias=True)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # x: [B,K,D]
        B, K, D = x.shape
        s = torch.zeros(B, D, device=x.device, dtype=x.dtype)
        ys = []
        for t in range(K):
            u = x[:, t, :]
            lam = torch.sigmoid(self.dt_proj(u))  # (B,D)
            s = lam * s + (1.0 - lam) * u
            ys.append(s)
        return torch.stack(ys, dim=1)


class SlimMambaBlock(nn.Module):
    """
    Minimal SSM-only block (hardware-friendly, Mamba-like):
    RMSNorm -> in_proj(D->2*inner) -> split(u,z)
           -> [optional DWConv1d on u] -> SiLU(u) -> SelectiveScanIC(u)
           -> gate g = SiLU(z)
           -> y = out_proj( ssm(u) ⊙ g ) -> +res
    No channel fusion/gating path, per your request.
    """

    def __init__(self, args: ModelArgs) -> None:
        super().__init__()
        self.args = args
        D = args.d_model
        inner = args.d_inner

        # env toggles
        quant_all = bool(int(os.environ.get("QUANTIZE_ALL", "0")))
        use_q_block = bool(int(os.environ.get("Q_BLOCK_LINEAR", "0"))) or quant_all
        use_dw = bool(int(os.environ.get("USE_DWCONV", "0")))

        # ensure odd kernel if used
        k = max(1, int(args.d_conv))
        if k % 2 == 0:
            k += 1

        self.norm = RMSNorm(D)
        try:
            from ..quant.qat_layers import QLinearINT8 as _QLinear
        except Exception:
            _QLinear = None
        LinearImpl = (_QLinear if (use_q_block and _QLinear is not None) else nn.Linear)

        self.in_proj = LinearImpl(D, 2 * inner, bias=args.bias)
        if use_dw:
            pad = k // 2
            self.dw_conv = nn.Conv1d(inner, inner, kernel_size=k, padding=pad, groups=inner, bias=args.conv_bias)
        else:
            self.dw_conv = None
        self.act = nn.SiLU()
        # dt_proj inside SSM is also quantizable
        self.ssm = SelectiveScanIC(inner, LinearImpl=LinearImpl)
        self.out_proj = LinearImpl(inner, D, bias=args.bias)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # x: [B,K,D]
        h = self.norm(x)
        uv = self.in_proj(h)  # [B,K,2*inner]
        inner = self.args.d_inner
        u, z = uv[..., :inner], uv[..., inner:]
        if self.dw_conv is not None:
            u = u.permute(0, 2, 1)
            u = self.dw_conv(u)
            u = u.permute(0, 2, 1)
        u = self.act(u)
        s = self.ssm(u)
        g = self.act(z)
        y = self.out_proj(s * g)
        return x + y


class CMambaSlim(nn.Module):
    def __init__(self, args: ModelArgs):
        super().__init__()
        self.args = args
        # Optional quantized linears for backbone via env Q_BACKBONE_LINEAR
        quant_all = bool(int(os.environ.get("QUANTIZE_ALL", "0")))
        use_q = bool(int(os.environ.get("Q_BACKBONE_LINEAR", "0"))) or quant_all
        try:
            from ..quant.qat_layers import QLinearINT8 as _QLinear
        except Exception:
            _QLinear = None

        LinearImpl = (_QLinear if (use_q and _QLinear is not None) else nn.Linear)

        self.patch_embedding = LinearImpl(
            args.patch_len * args.num_channels, args.d_model
        )
        self.blocks = nn.ModuleList([SlimMambaBlock(args) for _ in range(args.n_layer)])
        self.norm_f = RMSNorm(args.d_model)
        self.output_layer = LinearImpl(
            args.d_model * args.num_patches, args.num_channels * args.forecast_len
        )

    @staticmethod
    def _build_sincos(n: int, d: int, device=None, dtype=None) -> torch.Tensor:
        if device is None:
            device = torch.device("cpu")
        if dtype is None:
            dtype = torch.float32
        pos = torch.arange(n, device=device, dtype=dtype).unsqueeze(1)
        sin_cols = (d + 1) // 2
        cos_cols = d // 2
        denom = (d / 2.0)
        sin_i = torch.arange(sin_cols, device=device, dtype=dtype)
        cos_i = torch.arange(cos_cols, device=device, dtype=dtype)
        sin_div = torch.exp(-math.log(10000.0) * sin_i / denom).unsqueeze(0)
        cos_div = torch.exp(-math.log(10000.0) * cos_i / denom).unsqueeze(0)
        sin_part = torch.sin(pos * sin_div)
        cos_part = torch.cos(pos * cos_div)
        pe = torch.zeros(n, d, device=device, dtype=dtype)
        pe[:, 0::2] = sin_part
        if cos_cols > 0:
            pe[:, 1::2] = cos_part
        return pe

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # x: [B, C, K]
        B, C, L = x.shape
        P, S = self.args.patch_len, self.args.stride
        x = (
            x.unfold(2, P, S)
            .contiguous()
            .permute(0, 2, 1, 3)
            .reshape(B, -1, C * P)
        )
        x = self.patch_embedding(x)
        pe = self._build_sincos(
            n=x.size(1), d=self.args.d_model, device=x.device, dtype=x.dtype
        )
        x = x + pe.unsqueeze(0)
        for blk in self.blocks:
            x = x + blk(x)
        x = self.norm_f(x)
        x = x.reshape(B, -1)
        y = self.output_layer(x).reshape(
            B, self.args.num_channels, self.args.forecast_len
        )
        return y
