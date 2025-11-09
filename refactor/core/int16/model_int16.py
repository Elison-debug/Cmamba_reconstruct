from __future__ import annotations
import torch
import torch.nn as nn

from ..mamba_regressor import MambaRegressor
from ...quant.int16.backend import (
    Int16Conv1x1Q88,
    Int16Conv1dKxQ88,
    Int16SiLULUT,
    Int16SigmoidLUT,
)


class MambaRegressorINT16(nn.Module):
    """
    Wrap MambaRegressor and replace 1x1 pointwise layers (proj/head) with integer-only Q8.8 kernels
    to emulate hardware behavior. Backbone remains float in this initial version.
    """
    def __init__(self, base: MambaRegressor,
                 q_proj: bool = True,
                 q_head: bool = True,
                 q_patch_embed: bool = True,
                 q_output_flat: bool = True,
                 use_lut_act: bool = True,
                 use_lut_sigmoid: bool = True):
        super().__init__()
        self.base = base
        B = base.backbone
        in_ch = base.Din
        out_ch = B.args.num_channels

        # Optional LUTs
        self.act_lut = Int16SiLULUT() if use_lut_act else None
        self.sig_lut = Int16SigmoidLUT() if use_lut_sigmoid else None

        # Replace proj/head optionally
        self.use_proj_int = bool(q_proj)
        if self.use_proj_int:
            self.proj_int = Int16Conv1x1Q88(in_ch, out_ch, bias=True)
            with torch.no_grad():
                self.proj_int.load_float_weight(base.proj.conv.weight, base.proj.conv.bias)  # type: ignore
        else:
            self.proj_int = None
        self.use_head_int = bool(q_head)
        if self.use_head_int:
            self.head_int = Int16Conv1x1Q88(out_ch, 2, bias=True)
            with torch.no_grad():
                self.head_int.load_float_weight(base.head.conv.weight, base.head.conv.bias)  # type: ignore
        else:
            self.head_int = None

        # Replace patch_embedding/output_layer_flat optionally
        self.use_patch_int = bool(q_patch_embed)
        if self.use_patch_int:
            pe = B.patch_embedding
            self.patch_int = Int16Conv1dKxQ88(in_ch=pe.in_channels, out_ch=pe.out_channels, kernel=pe.kernel_size[0], stride=pe.stride[0], bias=(pe.bias is not None))
            with torch.no_grad():
                self.patch_int.load_float_weight(pe.weight, pe.bias)
        else:
            self.patch_int = None
        self.use_outflat_int = bool(q_output_flat)
        if self.use_outflat_int:
            of = B.output_layer_flat
            self.outflat_int = Int16Conv1dKxQ88(in_ch=of.in_channels, out_ch=of.out_channels, kernel=of.kernel_size[0], stride=of.stride[0] if isinstance(of.stride, tuple) else 1, bias=(of.bias is not None))
            with torch.no_grad():
                self.outflat_int.load_float_weight(of.weight, of.bias)
        else:
            self.outflat_int = None

        # Patch backbone activations to LUT versions if requested
        if self.act_lut is not None:
            for blk in B.blocks:
                blk.act = self.act_lut  # type: ignore
        if self.sig_lut is not None:
            # wrap ssm to use sigmoid LUT for lam
            for blk in B.blocks:
                blk.ssm = _SelectiveScanSigmoidLUT(blk.ssm, self.sig_lut)  # type: ignore

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # x: (B,K,Din)
        x = x.permute(0, 2, 1)            # (B, Din, K)
        # proj stage
        if self.use_proj_int and self.proj_int is not None:
            x_proj = self.proj_int(x)
        else:
            x_proj = self.base.proj(x)  # type: ignore

        # Backbone forward with optional int16 patch/output and LUT activations/sigmoid
        B = self.base.backbone
        if self.use_patch_int and self.patch_int is not None:
            xp = self.patch_int(x_proj)                 # (B, d_model, num_patches)
        else:
            xp = B.patch_embedding(x_proj)              # (B, d_model, num_patches)
        x_seq = xp.permute(0, 2, 1)                     # (B, num_patches, d_model)
        if B.pe_on:
            pe = B.pe_buf.to(device=x_seq.device, dtype=x_seq.dtype)
            x_seq = x_seq + B.pe_scale * pe.unsqueeze(0)  # type: ignore
        for blk in B.blocks:
            x_seq = blk(x_seq)
        x_seq = B.norm_f(x_seq)
        if B.agg_pool == "avg":
            x_agg = x_seq.mean(dim=1)
            y_feat = B.output_layer_pool(x_agg.unsqueeze(-1))
        elif B.agg_pool == "max":
            x_agg, _ = x_seq.max(dim=1)
            y_feat = B.output_layer_pool(x_agg.unsqueeze(-1))
        else:
            xp2 = x_seq.permute(0, 2, 1)                # (B, d_model, num_patches)
            if self.use_outflat_int and self.outflat_int is not None:
                y_feat = self.outflat_int(xp2)
            else:
                y_feat = B.output_layer_flat(xp2)
        y_feat = y_feat.reshape(x_seq.size(0), B.args.num_channels, B.args.forecast_len)

        # head
        if self.use_head_int and self.head_int is not None:
            out = self.head_int(y_feat).squeeze(-1)
        else:
            out = self.base.head(y_feat).squeeze(-1)  # type: ignore
        return out


class _SelectiveScanSigmoidLUT(nn.Module):
    def __init__(self, ssm_orig: nn.Module, sig_lut: nn.Module):
        super().__init__()
        self.dt_proj = ssm_orig.dt_proj  # Conv1d
        self.sig = sig_lut

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # This mirrors SelectiveScanIC forward but uses LUT sigmoid
        B, K, D = x.shape
        s = torch.zeros(B, D, device=x.device, dtype=x.dtype)
        xp = x.permute(0, 2, 1)
        lam_all = self.sig(self.dt_proj(xp)).permute(0, 2, 1)
        ys = torch.empty(B, K, D, device=x.device, dtype=x.dtype)
        for t in range(K):
            u = x[:, t, :]
            lam = lam_all[:, t, :]
            s = lam * s + (1.0 - lam) * u
            ys[:, t, :] = s
        return ys
