from __future__ import annotations

import argparse
import os
from pathlib import Path

import torch

from refactor.core.mamba_regressor import MambaRegressor
from refactor.bittrue.pack import export_minimal


def _cfg_from_ckpt(ckpt_obj: dict) -> dict:
    cfg = ckpt_obj.get("cfg", {})
    return cfg if isinstance(cfg, dict) else {}


def _build_model(args: argparse.Namespace, ckpt_cfg: dict) -> MambaRegressor:
    def pick(name: str, default):
        cli_val = getattr(args, name)
        if cli_val is not None:
            return cli_val
        return ckpt_cfg.get(name, default)

    quantize_all = bool(ckpt_cfg.get("quantize_all", False))
    q_proj = bool(ckpt_cfg.get("q_proj", ckpt_cfg.get("q_proj_head", False)))
    q_head = bool(ckpt_cfg.get("q_head", ckpt_cfg.get("q_proj_head", False)))
    q_block_linear = bool(ckpt_cfg.get("q_block_linear", False))
    q_backbone_linear = bool(ckpt_cfg.get("q_backbone_linear", False))
    quant_backend = str(ckpt_cfg.get("quant_backend", "python"))
    quant_bits = int(ckpt_cfg.get("quant_bits", 8))

    return MambaRegressor(
        Din=int(pick("Din", 2100)),
        K=int(pick("K", 12)),
        proj_dim=int(pick("proj_dim", 64)),
        d_model=int(pick("d_model", 96)),
        n_layer=int(pick("n_layer", 3)),
        patch_len=int(pick("patch_len", 8)),
        stride=int(pick("stride", 4)),
        pe_off=bool(pick("pe_off", False)),
        pe_scale=float(pick("pe_scale", 1.0)),
        gate_off=bool(pick("gate_off", False)),
        agg_pool=str(pick("agg_pool", "")),
        use_dwconv=bool(pick("use_dwconv", False)),
        quantize_all=quantize_all,
        q_proj=q_proj,
        q_head=q_head,
        q_block_linear=q_block_linear,
        q_backbone_linear=q_backbone_linear,
        quant_backend=quant_backend,
        quant_bits=quant_bits,
    )


def main():
    p = argparse.ArgumentParser(description="Export a trained checkpoint into the bit-true inference package.")
    p.add_argument("--ckpt", type=str, default="refactor/bittrue/reference.pt")
    p.add_argument("--out", type=str, required=True)
    p.add_argument("--Din", type=int, default=None)
    p.add_argument("--K", type=int, default=None)
    p.add_argument("--proj_dim", type=int, default=None)
    p.add_argument("--d_model", type=int, default=None)
    p.add_argument("--n_layer", type=int, default=None)
    p.add_argument("--patch_len", type=int, default=None)
    p.add_argument("--stride", type=int, default=None)
    p.add_argument("--pe_off", action="store_true", default=None)
    p.add_argument("--pe_scale", type=float, default=None)
    p.add_argument("--gate_off", action="store_true", default=None)
    p.add_argument("--agg_pool", type=str, default=None)
    p.add_argument("--use_dwconv", action="store_true", default=None)
    args = p.parse_args()

    if not os.path.exists(args.ckpt):
        raise FileNotFoundError(f"checkpoint not found: {args.ckpt}")

    ckpt = torch.load(args.ckpt, map_location="cpu")
    ckpt_cfg = _cfg_from_ckpt(ckpt)
    model = _build_model(args, ckpt_cfg)

    state_dict = ckpt.get("state_dict", ckpt)
    if not isinstance(state_dict, dict):
        raise TypeError("checkpoint does not contain a usable state_dict")
    model.load_state_dict(state_dict, strict=False)
    model.eval()

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)
    export_path = export_minimal(model, str(out_dir))
    print({"bittrue_export": export_path})


if __name__ == "__main__":
    main()
