from __future__ import annotations
import argparse
from pathlib import Path
import sys

import torch


def _ensure_repo_root_on_path():
    here = Path(__file__).resolve()
    repo = here.parents[2] if len(here.parents) >= 3 else here.parent
    if str(repo) not in sys.path:
        sys.path.insert(0, str(repo))


def build_model_from_ckpt(ckpt_path: Path):
    from refactor.core.mamba_regressor import MambaRegressor

    ckpt = torch.load(str(ckpt_path), map_location="cpu")
    cfg = ckpt.get("cfg", {}) if isinstance(ckpt.get("cfg", None), dict) else {}
    arch = ckpt.get("arch", {}) if isinstance(ckpt.get("arch", None), dict) else {}

    def _geti(key: str, default: int):
        try:
            return int(arch.get(key, default))
        except Exception:
            return default

    # Dimensions (prefer ckpt.cfg like test.py, then fall back to ckpt.arch)
    def _get_from(dct, key, default):
        try:
            v = dct.get(key, None)
            return int(v) if isinstance(v, (int,)) else v if v is not None else default
        except Exception:
            return default
    Din = _get_from(cfg, "Din", None);   Din = Din if Din is not None else _get_from(arch, "Din", 2100)
    K = _get_from(cfg, "K", None);       K = K if K is not None else _get_from(arch, "K", 12)
    proj_dim = _get_from(cfg, "proj_dim", None); proj_dim = proj_dim if proj_dim is not None else _get_from(arch, "proj_dim", 64)
    d_model = _get_from(cfg, "d_model", None);   d_model = d_model if d_model is not None else _get_from(arch, "d_model", 96)
    n_layer = _get_from(cfg, "n_layer", None);   n_layer = n_layer if n_layer is not None else _get_from(arch, "n_layer", 3)
    patch_len = _get_from(cfg, "patch_len", None); patch_len = patch_len if patch_len is not None else _get_from(arch, "patch_len", 8)
    stride = _get_from(cfg, "stride", None);     stride = stride if stride is not None else _get_from(arch, "stride", 4)

    # Runtime toggles (best-effort from ckpt)
    pe_off = not bool(arch.get("pe_on", True))
    pe_scale = float(arch.get("pe_scale", 1.0))
    gate_off = bool(arch.get("gate_off", False))
    agg_pool = str(arch.get("agg_pool", ""))
    use_dwconv = bool(arch.get("use_dwconv", False))

    quantize_all = bool(arch.get("quantize_all", True))
    quant_backend = str(arch.get("quant_backend", "cpp"))
    quant_bits = int(arch.get("quant_bits", 8))

    m = MambaRegressor(
        Din=Din,
        K=K,
        proj_dim=proj_dim,
        d_model=d_model,
        n_layer=n_layer,
        patch_len=patch_len,
        stride=stride,
        pe_off=pe_off,
        pe_scale=pe_scale,
        gate_off=gate_off,
        agg_pool=agg_pool,
        use_dwconv=use_dwconv,
        quantize_all=quantize_all,
        quant_backend=quant_backend,
        quant_bits=quant_bits,
    )

    sd = ckpt.get("state_dict", ckpt)
    m.load_state_dict(sd, strict=False)
    return m, arch


def main():
    _ensure_repo_root_on_path()
    p = argparse.ArgumentParser(description="Export CMamba model to export.json/backbone.json for C++ Q8.8 inference")
    p.add_argument("--ckpt", type=str, default=r"./ckpt_refactor/logo_2100/calibrate_best.pt", help="checkpoint path (default: ./ckpt_refactor/logo_2100/calibrate_best.pt)")
    p.add_argument("--out_dir", type=str, default=r"./export_logo_2100", help="output directory for export files")
    # Optional overrides (only used if ckpt lacks arch fields)
    p.add_argument("--Din", type=int, default=None)
    p.add_argument("--K", type=int, default=None)
    p.add_argument("--proj_dim", type=int, default=None)
    p.add_argument("--d_model", type=int, default=None)
    p.add_argument("--n_layer", type=int, default=None)
    p.add_argument("--patch_len", type=int, default=None)
    p.add_argument("--stride", type=int, default=None)
    args = p.parse_args()

    ckpt_path = Path(args.ckpt)
    if not ckpt_path.exists():
        print({"error": f"ckpt not found: {ckpt_path}"})
        sys.exit(2)

    model, arch = build_model_from_ckpt(ckpt_path)
    try:
        print({
            "dims": {
                "Din": getattr(model, 'Din', None),
                "K": getattr(model, 'K', None),
                "proj_dim": getattr(model, 'backbone').args.num_channels if hasattr(model, 'backbone') else None,  # type: ignore
                "d_model": getattr(model, 'backbone').args.d_model if hasattr(model, 'backbone') else None,      # type: ignore
                "n_layer": getattr(model, 'backbone').args.n_layer if hasattr(model, 'backbone') else None,      # type: ignore
                "patch_len": getattr(model, 'backbone').args.patch_len if hasattr(model, 'backbone') else None,  # type: ignore
                "stride": getattr(model, 'backbone').args.stride if hasattr(model, 'backbone') else None,        # type: ignore
            }
        })
    except Exception:
        pass

    # Apply CLI overrides if provided (last resort when ckpt lacks cfg/arch)
    try:
        if args.Din is not None: model.Din = int(args.Din)  # type: ignore
        if args.K is not None: model.K = int(args.K)  # type: ignore
    except Exception:
        pass

    from refactor.export.pack import export_minimal
    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    export_json = export_minimal(model, str(out_dir))
    print({"export_json": str(Path(export_json).resolve())})


if __name__ == "__main__":
    main()
