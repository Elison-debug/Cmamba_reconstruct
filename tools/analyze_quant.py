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

    # Heuristic: group by 'eval' vs 'test'; pair one baseline (no 'calibrate') with one quant ('calibrate').
    for split in ("eval", "test"):
        base = None
        quant = None
        for d in candidates:
            low = d.lower()
            if split not in low:
                continue
            if "calibrate" in low or "int" in low or "qat" in low or "quant" in low:
                quant = d if quant is None else quant
            else:
                base = d if base is None else base
        if base and quant:
            pairs.append((split, os.path.join(root, base), os.path.join(root, quant)))

    # Fallback: explicit known names if heuristic failed
    explicit = [
        ("eval", os.path.join(root, "logo_eval_best_epe_mean.pt"), os.path.join(root, "logo_eval_calibrate_best.pt")),
        ("test", os.path.join(root, "logo_test_best_epe_mean.pt"), os.path.join(root, "logo_test_calibrate_best.pt")),
    ]
    for label, b, q in explicit:
        if os.path.isdir(b) and os.path.isdir(q) and (label, b, q) not in pairs:
            pairs.append((label, b, q))

    return pairs


def validate_q88(csv_path: str, frac_bits: int = 8, eps_lsb: float = 1e-3) -> Dict[str, float]:
    # Validate that y_pred_x/y_pred_y align to Q8.8 grid and within int16 range
    scale = float(1 << frac_bits)
    code_min = -32768
    code_max = 32767
    total = 0
    aligned = 0
    max_resid = 0.0
    oob = 0
    min_code = None
    max_code = None
    # Track per-axis as well
    total_x = total_y = 0
    aligned_x = aligned_y = 0
    max_resid_x = 0.0
    max_resid_y = 0.0

    with open(csv_path, newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            for axis in ("y_pred_x", "y_pred_y"):
                v = safe_float(row.get(axis, "nan"))
                if math.isnan(v) or math.isinf(v):
                    # Treat NaN/Inf as not aligned and out-of-bounds
                    total += 1
                    if axis.endswith("_x"):
                        total_x += 1
                    else:
                        total_y += 1
                    oob += 1
                    continue
                raw = v * scale
                code = int(round(raw))
                resid = abs(raw - code)
                total += 1
                if axis.endswith("_x"):
                    total_x += 1
                else:
                    total_y += 1
                if resid <= eps_lsb:
                    aligned += 1
                    if axis.endswith("_x"):
                        aligned_x += 1
                    else:
                        aligned_y += 1
                max_resid = max(max_resid, resid)
                if axis.endswith("_x"):
                    max_resid_x = max(max_resid_x, resid)
                else:
                    max_resid_y = max(max_resid_y, resid)
                if code < code_min or code > code_max:
                    oob += 1
                if min_code is None or code < min_code:
                    min_code = code
                if max_code is None or code > max_code:
                    max_code = code

    aligned_ratio = (aligned / total) if total else float("nan")
    aligned_ratio_x = (aligned_x / total_x) if total_x else float("nan")
    aligned_ratio_y = (aligned_y / total_y) if total_y else float("nan")
    oob_ratio = (oob / total) if total else float("nan")
    ok = (
        (not math.isnan(aligned_ratio))
        and aligned_ratio >= 0.999
        and oob_ratio == 0.0
        and max_resid <= max(5e-4, eps_lsb)
    )
    return {
        "q88_ok": int(bool(ok)),
        "q88_aligned_ratio": aligned_ratio,
        "q88_aligned_ratio_x": aligned_ratio_x,
        "q88_aligned_ratio_y": aligned_ratio_y,
        "q88_max_residual_lsb": max_resid,
        "q88_max_residual_lsb_x": max_resid_x,
        "q88_max_residual_lsb_y": max_resid_y,
        "q88_oob_ratio": oob_ratio,
        "q88_min_code": min_code if min_code is not None else "",
        "q88_max_code": max_code if max_code is not None else "",
    } # type: ignore


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
        # Q8.8 validation on quant predictions
        "q88_ok", "q88_aligned_ratio", "q88_max_residual_lsb", "q88_oob_ratio",
        "q88_min_code", "q88_max_code",
        "q88_aligned_ratio_x", "q88_aligned_ratio_y",
        "q88_max_residual_lsb_x", "q88_max_residual_lsb_y",
    ]
    # Ensure all keys exist
    fieldnames = base_keys
    with open(path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for r in rows:
            writer.writerow({k: r.get(k, "") for k in fieldnames})


def main():
    parser = argparse.ArgumentParser(description="Analyze quantization accuracy loss and Q8.8 conformity per grid from pred_vs_true.csv")
    parser.add_argument("--root", default="test_out", help="Root directory containing run folders")
    parser.add_argument("--rel-threshold", type=float, default=0.05, help="Max allowed relative increase on mean_err_m (e.g., 0.05 for 5%)")
    parser.add_argument("--q-frac-bits", type=int, default=8, help="Fractional bits for Q format (default 8 for Q8.8)")
    parser.add_argument("--q-eps-lsb", type=float, default=1e-3, help="Alignment tolerance in LSB units for Q check")
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
            # Q8.8 conformity on quant predictions
            qchk = validate_q88(quant_grids[grid], frac_bits=args.q_frac_bits, eps_lsb=args.q_eps_lsb)
            row.update(qchk)
            all_rows.append(row)

            rel_pct = comp.get("rel_mean_err_m", float("nan"))
            rel_str = f"{rel_pct*100:.2f}%" if not (math.isnan(rel_pct) or math.isinf(rel_pct)) else "NaN"
            print(
                f"  - {grid}: mean_err base={comp.get('base_mean_err_m'):.6f} | quant={comp.get('quant_mean_err_m'):.6f} | rel={rel_str} | success={success} | q88_ok={qchk.get('q88_ok')}"
            )

    # Write summary CSV
    out_csv = os.path.join(args.root, "quant_analysis_summary.csv")
    write_csv(out_csv, all_rows)
    print(f"\nWrote summary: {out_csv} ({len(all_rows)} rows)")


if __name__ == "__main__":
    raise SystemExit(main())
