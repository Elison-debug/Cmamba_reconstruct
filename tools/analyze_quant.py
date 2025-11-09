import argparse
import csv
import math
import os
from typing import Dict, List, Tuple


def safe_float(x: str) -> float:
    try:
        return float(x)
    except Exception:
        return float("nan")


def percentile(values: List[float], q: float) -> float:
    if not values:
        return float("nan")
    v = sorted(v for v in values if not (math.isnan(v) or math.isinf(v)))
    if not v:
        return float("nan")
    idx = int(round(q * (len(v) - 1)))
    idx = max(0, min(idx, len(v) - 1))
    return v[idx]


def mean(values: List[float]) -> float:
    clean = [v for v in values if not (math.isnan(v) or math.isinf(v))]
    if not clean:
        return float("nan")
    return sum(clean) / len(clean)


def rmse(values: List[float]) -> float:
    clean = [v for v in values if not (math.isnan(v) or math.isinf(v))]
    if not clean:
        return float("nan")
    return math.sqrt(sum(v * v for v in clean) / len(clean))


def load_pred_vs_true(csv_path: str) -> Dict[str, float]:
    errs: List[float] = []
    dx_list: List[float] = []
    dy_list: List[float] = []
    has_nan = False
    with open(csv_path, newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            ytx = safe_float(row.get("y_true_x", "nan"))
            yty = safe_float(row.get("y_true_y", "nan"))
            ypx = safe_float(row.get("y_pred_x", "nan"))
            ypy = safe_float(row.get("y_pred_y", "nan"))
            em = safe_float(row.get("err_m", "nan"))
            if any(math.isnan(v) or math.isinf(v) for v in [ytx, yty, ypx, ypy, em]):
                has_nan = True
            errs.append(em)
            if not (math.isnan(ytx) or math.isnan(ypx)):
                dx_list.append(abs(ypx - ytx))
            else:
                dx_list.append(float("nan"))
            if not (math.isnan(yty) or math.isnan(ypy)):
                dy_list.append(abs(ypy - yty))
            else:
                dy_list.append(float("nan"))

    metrics = {
        "count": len(errs),
        "mean_err_m": mean(errs),
        "median_err_m": percentile(errs, 0.5),
        "p95_err_m": percentile(errs, 0.95),
        "mae_x": mean(dx_list),
        "mae_y": mean(dy_list),
        "rmse_x": rmse(dx_list),
        "rmse_y": rmse(dy_list),
        "has_nan": has_nan,
    }
    return metrics


def scan_grids(run_dir: str) -> Dict[str, str]:
    grids: Dict[str, str] = {}
    if not os.path.isdir(run_dir):
        return grids
    for name in os.listdir(run_dir):
        if not name.lower().startswith("grid"):
            continue
        grid_path = os.path.join(run_dir, name)
        csv_path = os.path.join(grid_path, "pred_vs_true.csv")
        if os.path.isfile(csv_path):
            grids[name] = csv_path
    return grids


def try_pair_runs(root: str) -> List[Tuple[str, str, str]]:
    # Returns list of (label, baseline_dir, quant_dir)
    candidates = [d for d in os.listdir(root) if os.path.isdir(os.path.join(root, d))]
    pairs: List[Tuple[str, str, str]] = []

    def add_pair(label: str, base_name: str, quant_name: str):
        b = os.path.join(root, base_name)
        q = os.path.join(root, quant_name)
        if os.path.isdir(b) and os.path.isdir(q):
            pairs.append((label, b, q))

    # Prefer new naming: *_ori vs *_quant16
    add_pair("eval", "logo_eval_ori",   "logo_eval_quant16")
    add_pair("test",  "logo_test_ori",  "logo_test_quant16")
    add_pair("train", "logo_train_ori", "logo_train_quant16")
    if pairs:
        return pairs

    # Fallback: explicit older names
    add_pair("eval", "logo_eval_best_epe_mean.pt", "logo_eval_calibrate_best.pt")
    add_pair("test", "logo_test_best_epe_mean.pt", "logo_test_calibrate_best.pt")
    add_pair("train", "logo_train_best_epe_mean.pt", "logo_train_calibrate_best.pt")
    if pairs:
        return pairs

    # Last resort heuristic by keywords
    for split in ("eval", "test", "train"):
        base = None
        quant = None
        for d in candidates:
            low = d.lower()
            if split not in low:
                continue
            if any(k in low for k in ("quant16", "calibrate", "int", "qat", "quant")):
                if quant is None:
                    quant = d
            else:
                if base is None:
                    base = d
        if base and quant:
            pairs.append((split, os.path.join(root, base), os.path.join(root, quant)))

    return pairs


# Q-format validation removed per request.


def compare_metrics(base: Dict[str, float], quant: Dict[str, float]) -> Dict[str, float]:
    out = {}
    # copy base and quant with prefixes
    for k, v in base.items():
        out[f"base_{k}"] = v
    for k, v in quant.items():
        out[f"quant_{k}"] = v
    # deltas
    def safe_rel(qv: float, bv: float) -> float:
        if bv == 0 or math.isnan(bv) or math.isinf(bv) or math.isnan(qv) or math.isinf(qv):
            return float("nan")
        return (qv - bv) / bv

    for key in ("mean_err_m", "median_err_m", "p95_err_m", "mae_x", "mae_y", "rmse_x", "rmse_y"):
        b = base.get(key, float("nan"))
        q = quant.get(key, float("nan"))
        out[f"delta_{key}"] = q - b if not (math.isnan(q) or math.isnan(b)) else float("nan")
        out[f"rel_{key}"] = safe_rel(q, b)
    out["count_equal"] = int(base.get("count", -1) == quant.get("count", -2))
    out["has_nan_any"] = int(any([
        base.get("has_nan", False), quant.get("has_nan", False),
        any(math.isnan(out[k]) for k in out if k.startswith("base_") or k.startswith("quant_") or k.startswith("delta_") or k.startswith("rel_"))
    ]))
    return out


def decide_success(comp: Dict[str, float], rel_threshold: float) -> bool:
    if comp.get("has_nan_any", 1):
        return False
    if not comp.get("count_equal", 0):
        return False
    rel = comp.get("rel_mean_err_m", float("nan"))
    if math.isnan(rel) or math.isinf(rel):
        return False
    return rel <= rel_threshold


def write_csv(path: str, rows: List[Dict[str, object]]):
    if not rows:
        return
    # Stable header order
    base_keys = [
        "split", "grid", "success",
        "base_count", "quant_count", "count_equal",
        "base_mean_err_m", "quant_mean_err_m", "delta_mean_err_m", "rel_mean_err_m",
        "base_median_err_m", "quant_median_err_m", "delta_median_err_m", "rel_median_err_m",
        "base_p95_err_m", "quant_p95_err_m", "delta_p95_err_m", "rel_p95_err_m",
        "base_mae_x", "quant_mae_x", "delta_mae_x", "rel_mae_x",
        "base_mae_y", "quant_mae_y", "delta_mae_y", "rel_mae_y",
        "base_rmse_x", "quant_rmse_x", "delta_rmse_x", "rel_rmse_x",
        "base_rmse_y", "quant_rmse_y", "delta_rmse_y", "rel_rmse_y",
        "has_nan_any",
    ]
    # Ensure all keys exist
    fieldnames = base_keys
    with open(path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for r in rows:
            writer.writerow({k: r.get(k, "") for k in fieldnames})


def main():
    parser = argparse.ArgumentParser(description="Analyze quantization accuracy loss per grid from pred_vs_true.csv")
    parser.add_argument("--root", default="test_out", help="Root directory containing run folders")
    parser.add_argument("--rel-threshold", type=float, default=0.05, help="Max allowed relative increase on mean_err_m (e.g., 0.05 for 5%)")
    args = parser.parse_args()

    pairs = try_pair_runs(args.root)
    if not pairs:
        print(f"No baseline/quant pairs found under {args.root}")
        return 2

    all_rows: List[Dict[str, object]] = []

    for split, base_dir, quant_dir in pairs:
        base_grids = scan_grids(base_dir)
        quant_grids = scan_grids(quant_dir)
        common = sorted(set(base_grids).intersection(quant_grids))
        if not common:
            print(f"[{split}] No common Grid* found between {os.path.basename(base_dir)} and {os.path.basename(quant_dir)}")
            continue

        print(f"[{split}] Comparing {os.path.basename(base_dir)} vs {os.path.basename(quant_dir)} on {len(common)} grids...")
        for grid in common:
            base_metrics = load_pred_vs_true(base_grids[grid])
            quant_metrics = load_pred_vs_true(quant_grids[grid])
            comp = compare_metrics(base_metrics, quant_metrics)
            success = decide_success(comp, args.rel_threshold)
            row = {"split": split, "grid": grid, "success": int(success)}
            row.update(comp)
            all_rows.append(row)

            rel_pct = comp.get("rel_mean_err_m", float("nan"))
            rel_str = f"{rel_pct*100:.2f}%" if not (math.isnan(rel_pct) or math.isinf(rel_pct)) else "NaN"
            print(
                f"  - {grid}: mean_err base={comp.get('base_mean_err_m'):.6f} | quant={comp.get('quant_mean_err_m'):.6f} | rel={rel_str} | success={success}"
            )

    # Write summary CSV
    out_csv = os.path.join(args.root, "quant_analysis_summary.csv")
    write_csv(out_csv, all_rows)
    print(f"\nWrote summary: {out_csv} ({len(all_rows)} rows)")


if __name__ == "__main__":
    raise SystemExit(main())
