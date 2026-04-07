from __future__ import annotations

import argparse
import concurrent.futures
import csv
import json
import os
import re
import subprocess
import tempfile
import time
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


def _run_cpp_sample(cpp_bin: str, export_json: str, x_kd: np.ndarray, din: int, mode: str, overrides: str, verbose: bool = False) -> np.ndarray:
    with tempfile.NamedTemporaryFile(suffix=".npy", delete=False) as f:
        tmp = Path(f.name)
    try:
        np.save(tmp, x_kd.astype(np.float32))
        cmd = [cpp_bin, export_json, str(tmp), str(din), "--mode", mode]
        if overrides:
            cmd.extend(["--overrides", overrides])
        if verbose:
            cmd.append("--verbose")
        proc = subprocess.run(
            cmd,
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


def _run_cpp_batch(
    cpp_batch_bin: str,
    export_json: str,
    x_path: Path,
    y_path: Path,
    din: int,
    mode: str,
    overrides: str,
    verbose: bool = False,
) -> np.ndarray:
    cmd = [cpp_batch_bin, export_json, str(x_path), str(y_path), str(din), "--mode", mode]
    if overrides:
        cmd.extend(["--overrides", overrides])
    if verbose:
        cmd.append("--verbose")
    subprocess.run(cmd, check=True)
    y_pred = np.load(y_path)
    return y_pred.astype(np.float32, copy=False)


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


def _parse_sweep_case(text: str) -> dict:
    parts = text.split("|")
    if len(parts) < 2 or len(parts) > 3:
        raise ValueError(f"invalid sweep case '{text}', expected label|mode|overrides")
    label = parts[0].strip()
    mode = parts[1].strip()
    overrides = parts[2].strip() if len(parts) == 3 else ""
    if not label or not mode:
        raise ValueError(f"invalid sweep case '{text}'")
    return {"label": label, "mode": mode, "overrides": overrides}


def _default_cases(cpp_mode: str, cpp_overrides: str) -> list[dict]:
    return [{"label": f"cpp_{cpp_mode}", "mode": cpp_mode, "overrides": cpp_overrides.strip()}]


def _cache_meta(args: argparse.Namespace, ckpt_cfg: dict, ckpt_arch: dict) -> dict:
    return {
        "ckpt": str(Path(args.ckpt).resolve()),
        "feat_root": str(Path(args.feat_root).resolve()),
        "target": args.target,
        "limit": int(args.limit),
        "batch_size": int(args.batch_size),
        "Din": int(ckpt_cfg["Din"]),
        "K": int(ckpt_cfg["K"]),
        "proj_dim": int(ckpt_cfg["proj_dim"]),
        "d_model": int(ckpt_cfg["d_model"]),
        "n_layer": int(ckpt_cfg["n_layer"]),
        "patch_len": int(ckpt_cfg["patch_len"]),
        "stride": int(ckpt_cfg["stride"]),
        "quantize_all": bool(ckpt_arch.get("quantize_all", False)),
        "quant_backend": str(ckpt_arch.get("quant_backend", "python")),
        "quant_bits": int(ckpt_arch.get("quant_bits", 8)),
    }


def _load_or_prepare_float_cache(
    args: argparse.Namespace,
    ckpt_cfg: dict,
    ckpt_arch: dict,
    dl: DataLoader,
    device: torch.device,
    model: torch.nn.Module,
    out_dir: Path,
):
    float_dir = out_dir / "float"
    float_dir.mkdir(parents=True, exist_ok=True)
    samples_path = float_dir / "samples.npy"
    y_true_path = float_dir / "y_true.npy"
    y_float_path = float_dir / "y_float.npy"
    meta_path = float_dir / "cache_meta.json"

    wanted_meta = _cache_meta(args, ckpt_cfg, ckpt_arch)
    if samples_path.exists() and y_true_path.exists() and y_float_path.exists() and meta_path.exists():
        try:
            cached_meta = json.loads(meta_path.read_text(encoding="utf-8"))
            if cached_meta == wanted_meta:
                x_arr = np.load(samples_path)
                y_true_arr = np.load(y_true_path)
                y_float_arr = np.load(y_float_path)
                print(
                    f"[cache] reuse float cache from {float_dir} with {x_arr.shape[0]} samples",
                    flush=True,
                )
                return x_arr, y_true_arr, y_float_arr
        except Exception:
            pass

    y_true_all: list[np.ndarray] = []
    y_float_all: list[np.ndarray] = []
    x_all: list[np.ndarray] = []
    sample_count = 0
    t_collect0 = time.time()
    collect_report_next = 500

    for xb_np, yb_np, y_float_np in _iter_loader_numpy(dl, device, model):
        for i in range(xb_np.shape[0]):
            x_all.append(xb_np[i][None, ...])
            y_true_all.append(yb_np[i][None, :])
            y_float_all.append(y_float_np[i][None, :])
            sample_count += 1
            if sample_count >= collect_report_next:
                elapsed = time.time() - t_collect0
                print(f"[collect] {sample_count} samples prepared in {elapsed:.1f}s", flush=True)
                collect_report_next += 500
            if args.limit > 0 and sample_count >= args.limit:
                break
        if args.limit > 0 and sample_count >= args.limit:
            break

    x_arr = np.concatenate(x_all, axis=0)
    y_true_arr = np.concatenate(y_true_all, axis=0)
    y_float_arr = np.concatenate(y_float_all, axis=0)
    np.save(samples_path, x_arr.astype(np.float32))
    np.save(y_true_path, y_true_arr.astype(np.float32))
    np.save(y_float_path, y_float_arr.astype(np.float32))
    meta_path.write_text(json.dumps(wanted_meta, indent=2), encoding="utf-8")
    print(f"[cache] wrote float cache to {float_dir}", flush=True)
    return x_arr, y_true_arr, y_float_arr


def _run_one_batch_case(
    case: dict,
    cpp_batch_bin: str,
    export_json: str,
    x_path: Path,
    din: int,
    out_dir: Path,
    y_true_arr: np.ndarray,
    y_float_arr: np.ndarray,
    write_compare_csv: bool,
    cpp_verbose: bool,
):
    label = case["label"]
    case_dir = out_dir / label
    case_dir.mkdir(parents=True, exist_ok=True)
    y_path = case_dir / "y_cpp.npy"
    case_t0 = time.time()
    y_cpp_arr = _run_cpp_batch(
        cpp_batch_bin,
        export_json,
        x_path,
        y_path,
        din,
        case["mode"],
        case["overrides"],
        verbose=cpp_verbose,
    )
    case_elapsed = time.time() - case_t0
    np.savez(
        case_dir / "cpp_preds.npz",
        y_true=y_true_arr,
        y_float=y_float_arr,
        y_cpp=y_cpp_arr,
        float_err=np.sqrt(np.sum((y_float_arr - y_true_arr) ** 2, axis=1)),
        cpp_err=np.sqrt(np.sum((y_cpp_arr - y_true_arr) ** 2, axis=1)),
        diff_float_cpp=np.sqrt(np.sum((y_cpp_arr - y_float_arr) ** 2, axis=1)),
    )
    if write_compare_csv:
        rows = np.column_stack([
            y_true_arr[:, 0], y_true_arr[:, 1],
            y_float_arr[:, 0], y_float_arr[:, 1],
            y_cpp_arr[:, 0], y_cpp_arr[:, 1],
            np.sqrt(np.sum((y_float_arr - y_true_arr) ** 2, axis=1)),
            np.sqrt(np.sum((y_cpp_arr - y_true_arr) ** 2, axis=1)),
            np.sqrt(np.sum((y_cpp_arr - y_float_arr) ** 2, axis=1)),
        ])
        with open(case_dir / "compare.csv", "w", newline="", encoding="utf-8") as f:
            w = csv.writer(f)
            w.writerow([
                "y_true_x", "y_true_y",
                "y_float_x", "y_float_y",
                "y_cpp_x", "y_cpp_y",
                "float_err", "cpp_err", "float_cpp_diff",
            ])
            w.writerows(rows.tolist())

    case_metrics = _metric_dict(y_true_arr, y_cpp_arr)
    mae = float(np.mean(np.abs(y_cpp_arr - y_float_arr)))
    max_abs = float(np.max(np.abs(y_cpp_arr - y_float_arr)))
    return {
        "label": label,
        "mode": case["mode"],
        "overrides": case["overrides"],
        "metrics": case_metrics,
        "float_vs_cpp_mae": mae,
        "float_vs_cpp_max_abs": max_abs,
        "elapsed_sec": case_elapsed,
    }


def main():
    p = argparse.ArgumentParser(description="Evaluate exported bit-true reference against Python model.")
    p.add_argument("--feat_root", type=str, default="./data/features/logo")
    p.add_argument("--ckpt", type=str, default="refactor/bittrue/reference.pt")
    p.add_argument("--export_dir", type=str, required=True)
    p.add_argument("--out_dir", type=str, default="./eval_bittrue_out")
    p.add_argument("--cpp_bin", type=str, default="", help="compiled main_full executable path")
    p.add_argument("--cpp_batch_bin", type=str, default="", help="compiled main_batch executable path")
    p.add_argument("--batch_size", type=int, default=64)
    p.add_argument("--workers", type=int, default=0)
    p.add_argument("--target", type=str, default="eval", choices=["auto", "train", "eval", "test"])
    p.add_argument("--preload", action="store_true")
    p.add_argument("--limit", type=int, default=0, help="limit number of samples for quick verification")
    p.add_argument("--write_compare_csv", action="store_true", help="write per-sample compare.csv for each case")
    p.add_argument("--case_parallel", type=int, default=1, help="number of C++ batch cases to run in parallel")
    p.add_argument("--cpp_mode", type=str, default="fake", choices=["fake", "int8", "int16"])
    p.add_argument("--cpp_overrides", type=str, default="", help="role=mode,name:layer=mode,...")
    p.add_argument(
        "--sweep_case",
        action="append",
        default=[],
        help="batch case as label|mode|overrides, e.g. all_int16|int16| or dtproj_i8|int16|dt_proj=int8",
    )
    p.add_argument("--cpp_verbose", action="store_true")
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

    run_cpp = bool(args.cpp_bin) or bool(args.cpp_batch_bin)
    run_cpp_batch = bool(args.cpp_batch_bin)
    sweep_cases = [_parse_sweep_case(s) for s in args.sweep_case] if args.sweep_case else _default_cases(args.cpp_mode, args.cpp_overrides)
    case_preds: dict[str, list[np.ndarray]] = {case["label"]: [] for case in sweep_cases} if run_cpp else {}
    case_rows: dict[str, list[list[float]]] = {case["label"]: [] for case in sweep_cases} if run_cpp else {}
    x_arr, y_true_arr, y_float_arr = _load_or_prepare_float_cache(
        args, ckpt_cfg, ckpt_arch, dl, device, model, out_dir
    )
    np.savez(out_dir / "float_preds.npz", y_true=y_true_arr, y_pred=y_float_arr)

    result = {
        "export_json": str(Path(export_json).resolve()),
        "samples": int(y_true_arr.shape[0]),
        "float_metrics": _metric_dict(y_true_arr, y_float_arr),
        "cpp_bin": args.cpp_bin if run_cpp else None,
        "cpp_batch_bin": args.cpp_batch_bin if run_cpp_batch else None,
    }

    if run_cpp and not run_cpp_batch and case_preds:
        sweep_summary_rows: list[list[object]] = []
        result["cases"] = {}
        for case in sweep_cases:
            label = case["label"]
            y_cpp_arr = np.concatenate(case_preds[label], axis=0)
            case_dir = out_dir / label
            case_dir.mkdir(parents=True, exist_ok=True)
            np.savez(
                case_dir / "cpp_preds.npz",
                y_true=y_true_arr,
                y_float=y_float_arr,
                y_cpp=y_cpp_arr,
                float_err=np.sqrt(np.sum((y_float_arr - y_true_arr) ** 2, axis=1)),
                cpp_err=np.sqrt(np.sum((y_cpp_arr - y_true_arr) ** 2, axis=1)),
                diff_float_cpp=np.sqrt(np.sum((y_cpp_arr - y_float_arr) ** 2, axis=1)),
            )
            case_metrics = _metric_dict(y_true_arr, y_cpp_arr)
            mae = float(np.mean(np.abs(y_cpp_arr - y_float_arr)))
            max_abs = float(np.max(np.abs(y_cpp_arr - y_float_arr)))
            result["cases"][label] = {
                "mode": case["mode"],
                "overrides": case["overrides"],
                "metrics": case_metrics,
                "float_vs_cpp_mae": mae,
                "float_vs_cpp_max_abs": max_abs,
            }
            sweep_summary_rows.append([
                label,
                case["mode"],
                case["overrides"],
                case_metrics["mean_err"],
                case_metrics["median_err"],
                case_metrics["p80_err"],
                case_metrics["p90_err"],
                mae,
                max_abs,
            ])

            with open(case_dir / "compare.csv", "w", newline="", encoding="utf-8") as f:
                w = csv.writer(f)
                w.writerow([
                    "y_true_x", "y_true_y",
                    "y_float_x", "y_float_y",
                    "y_cpp_x", "y_cpp_y",
                    "float_err", "cpp_err", "float_cpp_diff",
                ])
                w.writerows(case_rows[label])

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
                "float_vs_cpp_mae",
                "float_vs_cpp_max_abs",
            ])
            w.writerows(sweep_summary_rows)

    if run_cpp_batch:
        sweep_summary_rows: list[list[object]] = []
        result["cases"] = {}
        t_cases0 = time.time()
        float_dir = out_dir / "float"
        x_path = float_dir / "samples.npy"
        for idx, case in enumerate(sweep_cases, start=1):
            print(
                f"[case {idx}/{len(sweep_cases)}] queued label={case['label']} mode={case['mode']} overrides={case['overrides']}",
                flush=True,
            )

        max_workers = max(1, int(args.case_parallel))
        with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as ex:
            future_map = {
                ex.submit(
                    _run_one_batch_case,
                    case,
                    args.cpp_batch_bin,
                    export_json,
                    x_path,
                    int(ckpt_cfg["Din"]),
                    out_dir,
                    y_true_arr,
                    y_float_arr,
                    bool(args.write_compare_csv),
                    bool(args.cpp_verbose),
                ): case
                for case in sweep_cases
            }
            done = 0
            for fut in concurrent.futures.as_completed(future_map):
                case = future_map[fut]
                label = case["label"]
                case_info = fut.result()
                done += 1
                result["cases"][label] = {
                    "mode": case_info["mode"],
                    "overrides": case_info["overrides"],
                    "metrics": case_info["metrics"],
                    "float_vs_cpp_mae": case_info["float_vs_cpp_mae"],
                    "float_vs_cpp_max_abs": case_info["float_vs_cpp_max_abs"],
                    "elapsed_sec": case_info["elapsed_sec"],
                }
                sweep_summary_rows.append([
                    label,
                    case_info["mode"],
                    case_info["overrides"],
                    case_info["metrics"]["mean_err"],
                    case_info["metrics"]["median_err"],
                    case_info["metrics"]["p80_err"],
                    case_info["metrics"]["p90_err"],
                    case_info["float_vs_cpp_mae"],
                    case_info["float_vs_cpp_max_abs"],
                    case_info["elapsed_sec"],
                ])
                total_elapsed = time.time() - t_cases0
                avg_case = total_elapsed / done
                eta = avg_case * (len(sweep_cases) - done)
                print(
                    f"[case {done}/{len(sweep_cases)}] done label={label} "
                    f"elapsed={case_info['elapsed_sec']:.1f}s total_elapsed={total_elapsed:.1f}s eta={eta:.1f}s",
                    flush=True,
                )

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
                "float_vs_cpp_mae",
                "float_vs_cpp_max_abs",
                "elapsed_sec",
            ])
            w.writerows(sweep_summary_rows)

    with open(out_dir / "summary.json", "w", encoding="utf-8") as f:
        json.dump(result, f, indent=2)

    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
