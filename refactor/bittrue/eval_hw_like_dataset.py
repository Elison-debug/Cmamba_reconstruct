from __future__ import annotations

import argparse
import csv
import json
import os
import time
from pathlib import Path

import numpy as np
import torch
from torch.utils.data import DataLoader

from refactor.bittrue.eval_bittrue import (
    _arch_from_ckpt,
    _build_model,
    _cfg_from_ckpt,
    _load_or_prepare_float_cache,
    _metric_dict,
    _run_cpp_batch,
)
from refactor.bittrue.eval_hw_like_full import _forward_full_hw_like
from refactor.bittrue.pack import export_minimal
from refactor.core.train import TrainConfig, set_seed
from refactor.datasets.frames_lazy import FramesLazyDataset


def _write_json(path: Path, obj: dict | list) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2), encoding="utf-8")


def _save_case_artifacts(
    case_dir: Path,
    *,
    y_true: np.ndarray,
    y_float: np.ndarray,
    y_case: np.ndarray,
    case_key: str,
    write_compare_csv: bool,
) -> tuple[float, float]:
    case_dir.mkdir(parents=True, exist_ok=True)
    np.save(case_dir / f"y_{case_key}.npy", y_case.astype(np.float32))

    float_err = np.sqrt(np.sum((y_float - y_true) ** 2, axis=1))
    case_err = np.sqrt(np.sum((y_case - y_true) ** 2, axis=1))
    diff_float_case = np.sqrt(np.sum((y_case - y_float) ** 2, axis=1))
    np.savez(
        case_dir / f"{case_key}_preds.npz",
        y_true=y_true,
        y_float=y_float,
        **{f"y_{case_key}": y_case},
        float_err=float_err,
        **{f"{case_key}_err": case_err},
        **{f"diff_float_{case_key}": diff_float_case},
    )

    mae = float(np.mean(np.abs(y_case - y_float)))
    max_abs = float(np.max(np.abs(y_case - y_float)))

    if write_compare_csv:
        rows = np.column_stack([
            y_true[:, 0], y_true[:, 1],
            y_float[:, 0], y_float[:, 1],
            y_case[:, 0], y_case[:, 1],
            float_err,
            case_err,
            diff_float_case,
        ])
        with open(case_dir / "compare.csv", "w", newline="", encoding="utf-8") as f:
            w = csv.writer(f)
            w.writerow([
                "y_true_x", "y_true_y",
                "y_float_x", "y_float_y",
                f"y_{case_key}_x", f"y_{case_key}_y",
                "float_err", f"{case_key}_err", f"float_{case_key}_diff",
            ])
            w.writerows(rows.tolist())

    return mae, max_abs


def main() -> None:
    p = argparse.ArgumentParser(description="Evaluate full-dataset hw-like semantics against y_true.")
    p.add_argument("--feat_root", type=str, default="./data/features/logo")
    p.add_argument("--ckpt", type=str, default="refactor/bittrue/reference.pt")
    p.add_argument("--export_dir", type=str, required=True)
    p.add_argument("--out_dir", type=str, default="./eval_bittrue_out/hw_like_fullset")
    p.add_argument("--cpp_batch_bin", type=str, default="", help="optional main_batch executable for cpp int16 baseline")
    p.add_argument("--batch_size", type=int, default=64)
    p.add_argument("--workers", type=int, default=0)
    p.add_argument("--target", type=str, default="eval", choices=["auto", "train", "eval", "test"])
    p.add_argument("--preload", action="store_true")
    p.add_argument("--limit", type=int, default=0, help="limit number of samples for quick verification")
    p.add_argument("--write_compare_csv", action="store_true")
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

    x_arr, y_true_arr, y_float_arr = _load_or_prepare_float_cache(
        args, ckpt_cfg, ckpt_arch, dl, device, model, out_dir
    )
    np.savez(out_dir / "float_preds.npz", y_true=y_true_arr, y_pred=y_float_arr)

    y_hw_like = np.zeros_like(y_true_arr, dtype=np.float32)
    t0 = time.time()
    report_next = 500
    export_json_path = Path(export_json)
    for i in range(x_arr.shape[0]):
        y_hw_like[i], _ = _forward_full_hw_like(export_json_path, x_arr[i].astype(np.float32))
        done = i + 1
        if done >= report_next or done == x_arr.shape[0]:
            elapsed = time.time() - t0
            rate = done / max(elapsed, 1e-6)
            eta = (x_arr.shape[0] - done) / max(rate, 1e-6)
            print(f"[hw_like] {done}/{x_arr.shape[0]} samples elapsed={elapsed:.1f}s eta={eta:.1f}s", flush=True)
            report_next += 500

    result: dict[str, object] = {
        "export_json": str(Path(export_json).resolve()),
        "samples": int(y_true_arr.shape[0]),
        "float_metrics": _metric_dict(y_true_arr, y_float_arr),
        "cpp_batch_bin": args.cpp_batch_bin or None,
        "cases": {},
    }

    sweep_rows: list[list[object]] = []

    hw_like_dir = out_dir / "hw_like"
    hw_float_mae, hw_float_max_abs = _save_case_artifacts(
        hw_like_dir,
        y_true=y_true_arr,
        y_float=y_float_arr,
        y_case=y_hw_like,
        case_key="hw_like",
        write_compare_csv=bool(args.write_compare_csv),
    )
    hw_metrics = _metric_dict(y_true_arr, y_hw_like)
    result["cases"]["hw_like"] = {
        "mode": "python_hw_like",
        "overrides": "",
        "metrics": hw_metrics,
        "float_vs_hw_like_mae": hw_float_mae,
        "float_vs_hw_like_max_abs": hw_float_max_abs,
    }
    sweep_rows.append([
        "hw_like",
        "python_hw_like",
        "",
        hw_metrics["mean_err"],
        hw_metrics["median_err"],
        hw_metrics["p80_err"],
        hw_metrics["p90_err"],
        hw_float_mae,
        hw_float_max_abs,
    ])

    if args.cpp_batch_bin:
        cpp_dir = out_dir / "cpp_int16"
        y_cpp = _run_cpp_batch(
            args.cpp_batch_bin,
            export_json,
            out_dir / "float" / "samples.npy",
            cpp_dir / "y_cpp.npy",
            int(ckpt_cfg["Din"]),
            "int16",
            "ssm_state=int16,gate=int16",
            verbose=False,
        )
        cpp_float_mae, cpp_float_max_abs = _save_case_artifacts(
            cpp_dir,
            y_true=y_true_arr,
            y_float=y_float_arr,
            y_case=y_cpp,
            case_key="cpp",
            write_compare_csv=bool(args.write_compare_csv),
        )
        cpp_metrics = _metric_dict(y_true_arr, y_cpp)
        hw_cpp_mae = float(np.mean(np.abs(y_hw_like - y_cpp)))
        hw_cpp_max_abs = float(np.max(np.abs(y_hw_like - y_cpp)))
        result["cases"]["cpp_int16"] = {
            "mode": "int16",
            "overrides": "ssm_state=int16,gate=int16",
            "metrics": cpp_metrics,
            "float_vs_cpp_mae": cpp_float_mae,
            "float_vs_cpp_max_abs": cpp_float_max_abs,
        }
        result["cases"]["hw_like"]["cpp_vs_hw_like_mae"] = hw_cpp_mae
        result["cases"]["hw_like"]["cpp_vs_hw_like_max_abs"] = hw_cpp_max_abs
        sweep_rows.insert(0, [
            "cpp_int16",
            "int16",
            "ssm_state=int16,gate=int16",
            cpp_metrics["mean_err"],
            cpp_metrics["median_err"],
            cpp_metrics["p80_err"],
            cpp_metrics["p90_err"],
            cpp_float_mae,
            cpp_float_max_abs,
        ])
        sweep_rows[1].extend([hw_cpp_mae, hw_cpp_max_abs])
    else:
        result["cases"]["hw_like"]["cpp_vs_hw_like_mae"] = None
        result["cases"]["hw_like"]["cpp_vs_hw_like_max_abs"] = None

    with open(out_dir / "sweep_summary.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow([
            "label",
            "mode",
            "overrides",
            "mean_err",
            "median_err",
            "p80_err",
            "p90_err",
            "float_vs_case_mae",
            "float_vs_case_max_abs",
            "cpp_vs_hw_like_mae",
            "cpp_vs_hw_like_max_abs",
        ])
        for row in sweep_rows:
            if len(row) == 9:
                row = row + ["", ""]
            w.writerow(row)

    _write_json(out_dir / "summary.json", result)
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
