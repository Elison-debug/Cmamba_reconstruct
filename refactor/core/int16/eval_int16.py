import os
from pathlib import Path
import argparse
import numpy as np
import torch
from torch.utils.data import DataLoader

from ..train import TrainConfig, set_seed
from ...datasets.frames_lazy import FramesLazyDataset
from ..losses import HuberEPE
from .model_int16 import MambaRegressorINT16
from ..mamba_regressor import MambaRegressor


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--feat_root", type=str, default="./data/features/logo")
    p.add_argument("--ckpt", type=str, required=True)
    p.add_argument("--batch_size", type=int, default=64)
    p.add_argument("--workers", type=int, default=4)
    p.add_argument("--out_dir", type=str, default="./eval_out_int16")
    p.add_argument("--target", type=str, default="eval", choices=["auto","train","eval","test"])
    # quant/int16 toggles similar to eval
    p.add_argument("--q_proj", action="store_true")
    p.add_argument("--q_head", action="store_true")
    p.add_argument("--q_patch_embed", action="store_true")
    p.add_argument("--q_output_flat", action="store_true")
    p.add_argument("--lut_act", action="store_true")
    p.add_argument("--lut_sigmoid", action="store_true")
    args = p.parse_args()

    set_seed(42)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    ckpt = torch.load(args.ckpt, map_location="cpu")
    cfg_j = ckpt.get("cfg", {})
    dims = {k: int(cfg_j[k]) for k in ("Din","K","proj_dim","d_model","n_layer","patch_len","stride")}
    cfg = TrainConfig(**dims, batch_size=args.batch_size, feat_root=args.feat_root)

    ds = FramesLazyDataset(root=cfg.feat_root, seq_len=cfg.K, predict="current", mmap=True, target=args.target)
    dl = DataLoader(ds, batch_size=cfg.batch_size, shuffle=False, num_workers=args.workers, pin_memory=True)

    # Build float base model, load weights, then wrap into INT16 front/head
    base = MambaRegressor(Din=cfg.Din, K=cfg.K, proj_dim=cfg.proj_dim, d_model=cfg.d_model,
                          n_layer=cfg.n_layer, patch_len=cfg.patch_len, stride=cfg.stride,
                          pe_off=False, pe_scale=1.0, gate_off=False, agg_pool="",
                          use_dwconv=False, quantize_all=False, q_proj=False, q_head=False,
                          q_block_linear=False, q_backbone_linear=False,
                          quant_backend=None, quant_bits=8).to(device)
    sd = ckpt.get("state_dict", ckpt)
    base.load_state_dict(sd, strict=False)
    model = MambaRegressorINT16(base,
                                q_proj=bool(args.q_proj),
                                q_head=bool(args.q_head),
                                q_patch_embed=bool(args.q_patch_embed),
                                q_output_flat=bool(args.q_output_flat),
                                use_lut_act=bool(args.lut_act),
                                use_lut_sigmoid=bool(args.lut_sigmoid)).to(device)
    model.eval()

    loss_fn = HuberEPE(delta=1.0)
    tot, n = 0.0, 0
    all_err = []
    with torch.no_grad():
        for xb, yb in dl:
            xb = xb.to(device).float()
            yb = yb.squeeze(1).to(device).float()
            pred = model(xb)
            loss = loss_fn(pred, yb).item()
            tot += loss * xb.size(0)
            n += xb.size(0)
            all_err.append((pred - yb).cpu())
    dist = torch.linalg.norm(torch.cat(all_err, 0), dim=1).numpy()
    mean = float(dist.mean()); median = float(np.median(dist))
    p80 = float(np.percentile(dist, 80)); p90 = float(np.percentile(dist, 90))
    out_dir = Path(args.out_dir); out_dir.mkdir(parents=True, exist_ok=True)
    np.savez(out_dir / 'val_preds.npz', err=dist, mean=np.float32(mean), median=np.float32(median), p80=np.float32(p80), p90=np.float32(p90))
    print({"eval_int16": {"loss": tot/max(1,n), "epe_mean": mean, "epe_median": median, "epe_p80": p80, "epe_p90": p90}})

if __name__ == "__main__":
    main()
