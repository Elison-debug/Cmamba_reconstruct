from __future__ import annotations

import argparse
import csv
import json
import os
import re
import subprocess
import tempfile
from pathlib import Path
from typing import Iterable

import numpy as np
import torch
from torch.utils.data import DataLoader

from refactor.bittrue.pack import export_minimal
from refactor.core.mamba_regressor import MambaRegressor
from refactor.core.train import TrainConfig, set_seed
from refactor.datasets.frames_lazy import FramesLazyDataset


def _cfg_from_ckpt(ckpt_obj: dict) -> dict:
    cfg = ckpt_obj.get("cfg", {})
    return cfg if isinstance(cfg, dict) else {}


def _arch_from_ckpt(ckpt_obj: dict) -> dict:
    arch = ckpt_obj.get("arch", {})
    return arch if isinstance(arch, dict) else {}


def _build_model(ckpt_cfg: dict, ckpt_arch: dict) -> MambaRegressor:
    qph = bool(ckpt_arch.get("q_proj_head", False))
    return MambaRegressor(
        Din=int(ckpt_cfg["Din"]),
        K=int(ckpt_cfg["K"]),
        proj_dim=int(ckpt_cfg["proj_dim"]),
        d_model=int(ckpt_cfg["d_model"]),
        n_layer=int(ckpt_cfg["n_layer"]),
        patch_len=int(ckpt_cfg["patch_len"]),
        stride=int(ckpt_cfg["stride"]),
        pe_off=bool(ckpt_arch.get("pe_off", False)),
        pe_scale=float(ckpt_arch.get("pe_scale", 1.0)),
        gate_off=bool(ckpt_arch.get("gate_off", False)),
        agg_pool=str(ckpt_arch.get("agg_pool", "")),
        use_dwconv=bool(ckpt_arch.get("use_dwconv", False)),
        quantize_all=bool(ckpt_arch.get("quantize_all", False)),
        q_proj=bool(ckpt_arch.get("q_proj", qph)),
        q_head=bool(ckpt_arch.get("q_head", qph)),
        q_block_linear=bool(ckpt_arch.get("q_block_linear", False)),
        q_backbone_linear=bool(ckpt_arch.get("q_backbone_linear", False)),
        quant_backend=str(ckpt_arch.get("quant_backend", "python")),
        quant_bits=int(ckpt_arch.get("quant_bits", 8)),
    )


def _parse_main_full_stdout(text: str) -> np.ndarray:
    lines = [ln.strip() for ln in text.splitlines() if ln.strip()]
    if not lines:
        raise ValueError("empty C++ stdout")
    target = lines[-1]
    if ":" in target:
        target = target.split(":", 1)[1]
    nums = re.findall(r"[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?", target)
    vals = [float(v) for v in nums]
    if len(vals) < 2:
        raise ValueError(f"failed to parse C++ output: {text}")
    return np.asarray(vals[:2], dtype=np.float32)


def _run_cpp_sample(cpp_bin: str, export_json: str, x_kd: np.ndarray, din: int) -> np.ndarray:
    with tempfile.NamedTemporaryFile(suffix=".npy", delete=False) as f:
        tmp = Path(f.name)
    try:
        np.save(tmp, x_kd.astype(np.float32))
        proc = subprocess.run(
            [cpp_bin, export_json, str(tmp), str(din)],
            check=True,
            capture_output=True,
            text=True,
        )
        return _parse_main_full_stdout(proc.stdout.strip())
    finally:
        try:
            tmp.unlink(missing_ok=True)
        except Exception:
            pass


def _iter_loader_numpy(dl: Iterable, device: torch.device, model: torch.nn.Module):
    model.eval()
    with torch.inference_mode():
        for xb, yb in dl:
            xb = xb.to(device, non_blocking=True).float()
            yb = yb.squeeze(1).to(device, non_blocking=True).float()
            pred = model(xb)
            yield (
                xb.detach().cpu().numpy(),
                yb.detach().cpu().numpy(),
                pred.detach().cpu().numpy(),
            )


def _metric_dict(y_true: np.ndarray, y_pred: np.ndarray) -> dict:
    err = np.sqrt(np.sum((y_pred - y_true) ** 2, axis=1))
    return {
        "count": int(err.shape[0]),
        "mean_err": float(err.mean()),
        "median_err": float(np.median(err)),
        "p80_err": float(np.percentile(err, 80)),
        "p90_err": float(np.percentile(err, 90)),
        "max_err": float(err.max()),
    }


def main():
    p = argparse.ArgumentParser(description="Evaluate exported bit-true reference against Python model.")
    p.add_argument("--feat_root", type=str, default="./data/features/logo")
    p.add_argument("--ckpt", type=str, default="refactor/bittrue/reference.pt")
    p.add_argument("--export_dir", type=str, required=True)
    p.add_argument("--out_dir", type=str, default="./eval_bittrue_out")
    p.add_argument("--cpp_bin", type=str, default="", help="compiled main_full executable path")
    p.add_argument("--batch_size", type=int, default=64)
    p.add_argument("--workers", type=int, default=0)
    p.add_argument("--target", type=str, default="eval", choices=["auto", "train", "eval", "test"])
    p.add_argument("--preload", action="store_true")
    p.add_argument("--limit", type=int, default=0, help="limit number of samples for quick verification")
    args = p.parse_args()

    set_seed(42)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    if not os.path.exists(args.ckpt):
        raise FileNotFoundError(f"checkpoint not found: {args.ckpt}")

    ckpt = torch.load(args.ckpt, map_location="cpu")
    ckpt_cfg = _cfg_from_ckpt(ckpt)
    ckpt_arch = _arch_from_ckpt(ckpt)
    required = ["Din", "K", "proj_dim", "d_model", "n_layer", "patch_len", "stride"]
    missing = [k for k in required if k not in ckpt_cfg]
    if missing:
        raise RuntimeError(f"checkpoint cfg missing keys: {missing}")

    model = _build_model(ckpt_cfg, ckpt_arch)
    state_dict = ckpt.get("state_dict", ckpt)
    if not isinstance(state_dict, dict):
        raise TypeError("checkpoint does not contain a usable state_dict")
    model.load_state_dict(state_dict, strict=False)
    model.to(device)
    model.eval()

    export_dir = Path(args.export_dir)
    export_dir.mkdir(parents=True, exist_ok=True)
    export_json = export_minimal(model.cpu(), str(export_dir))
    model.to(device)

    cfg = TrainConfig(
        Din=int(ckpt_cfg["Din"]),
        K=int(ckpt_cfg["K"]),
        proj_dim=int(ckpt_cfg["proj_dim"]),
        d_model=int(ckpt_cfg["d_model"]),
        n_layer=int(ckpt_cfg["n_layer"]),
        patch_len=int(ckpt_cfg["patch_len"]),
        stride=int(ckpt_cfg["stride"]),
        batch_size=args.batch_size,
        feat_root=args.feat_root,
    )
    ds = FramesLazyDataset(
        root=args.feat_root,
        seq_len=cfg.K,
        predict="current",
        mmap=True,
        target=args.target,
        in_memory=bool(args.preload),
    )
    dl = DataLoader(
        ds,
        batch_size=args.batch_size,
        shuffle=False,
        num_workers=int(args.workers),
        pin_memory=True,
        persistent_workers=(int(args.workers) > 0),
        prefetch_factor=(2 if int(args.workers) > 0 else None),
    )

    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    y_true_all: list[np.ndarray] = []
    y_float_all: list[np.ndarray] = []
    y_bittrue_all: list[np.ndarray] = []
    rows: list[list[float]] = []

    run_cpp = bool(args.cpp_bin)
    sample_count = 0

    for xb_np, yb_np, y_float_np in _iter_loader_numpy(dl, device, model):
        for i in range(xb_np.shape[0]):
            x_kd = xb_np[i]
            y_true = yb_np[i]
            y_float = y_float_np[i]

            y_true_all.append(y_true[None, :])
            y_float_all.append(y_float[None, :])

            if run_cpp:
                y_bittrue = _run_cpp_sample(args.cpp_bin, export_json, x_kd, int(ckpt_cfg["Din"]))
                y_bittrue_all.append(y_bittrue[None, :])
                rows.append([
                    float(y_true[0]), float(y_true[1]),
                    float(y_float[0]), float(y_float[1]),
                    float(y_bittrue[0]), float(y_bittrue[1]),
                    float(np.linalg.norm(y_float - y_true)),
                    float(np.linalg.norm(y_bittrue - y_true)),
                    float(np.linalg.norm(y_bittrue - y_float)),
                ])

            sample_count += 1
            if args.limit > 0 and sample_count >= args.limit:
                break
        if args.limit > 0 and sample_count >= args.limit:
            break

    y_true_arr = np.concatenate(y_true_all, axis=0)
    y_float_arr = np.concatenate(y_float_all, axis=0)
    np.savez(
        out_dir / "float_preds.npz",
        y_true=y_true_arr,
        y_pred=y_float_arr,
    )

    result = {
        "export_json": str(Path(export_json).resolve()),
        "samples": int(y_true_arr.shape[0]),
        "float_metrics": _metric_dict(y_true_arr, y_float_arr),
        "cpp_bin": args.cpp_bin if run_cpp else None,
    }

    if run_cpp and y_bittrue_all:
        y_bittrue_arr = np.concatenate(y_bittrue_all, axis=0)
        np.savez(
            out_dir / "bittrue_preds.npz",
            y_true=y_true_arr,
            y_float=y_float_arr,
            y_bittrue=y_bittrue_arr,
            float_err=np.sqrt(np.sum((y_float_arr - y_true_arr) ** 2, axis=1)),
            bittrue_err=np.sqrt(np.sum((y_bittrue_arr - y_true_arr) ** 2, axis=1)),
            diff_float_bittrue=np.sqrt(np.sum((y_bittrue_arr - y_float_arr) ** 2, axis=1)),
        )
        result["bittrue_metrics"] = _metric_dict(y_true_arr, y_bittrue_arr)
        result["float_vs_bittrue_mae"] = float(np.mean(np.abs(y_bittrue_arr - y_float_arr)))
        result["float_vs_bittrue_max_abs"] = float(np.max(np.abs(y_bittrue_arr - y_float_arr)))

        with open(out_dir / "bittrue_compare.csv", "w", newline="", encoding="utf-8") as f:
            w = csv.writer(f)
            w.writerow([
                "y_true_x", "y_true_y",
                "y_float_x", "y_float_y",
                "y_bittrue_x", "y_bittrue_y",
                "float_err", "bittrue_err", "float_bittrue_diff",
            ])
            w.writerows(rows)

    with open(out_dir / "summary.json", "w", encoding="utf-8") as f:
        json.dump(result, f, indent=2)

    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
