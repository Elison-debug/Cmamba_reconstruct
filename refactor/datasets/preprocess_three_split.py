#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Make three splits from a folder of grids (.mat + .csv):
  - First grid  -> train
  - Second grid -> eval
  - Third grid  -> test

For dataset size reduction, select only m_per_block frames within every temporal
block of length per_block as target positions. We save full sequences as
NPY tensors and put role-specific indices into JSON:
  - train/*.json contains indices_train (list[int])
  - eval/*.json  contains indices_eval  (list[int])
  - test/*.json  does not contain indices (evaluated as full sequence)

The output format is compatible with FramesLazyDataset.
"""

import argparse
import glob
import json
import os
from typing import List, Optional

import numpy as np
from scipy.io import loadmat

from .preprocess_luvira_lazy import (
    _infer_seconds,
    load_gt_csv,
    select_radio_tensor,
    cir_features_batch,
)


def _extract_num_id(name: str) -> Optional[int]:
    import re as _re

    m = _re.findall(r"\d+", name)
    return None if not m else int(m[-1])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--radio_dir", type=str, default="./data/radio/grid")
    ap.add_argument("--gt_dir", type=str, default="./data/truth/grid")
    ap.add_argument("--out_dir", type=str, default="./data/features/lessData")
    ap.add_argument("--taps", type=int, default=10)
    ap.add_argument("--fps", type=int, default=100)
    ap.add_argument("--pos_units", choices=["mm", "m"], default="mm")
    ap.add_argument("--dtype", choices=["float16", "float32"], default="float16")
    ap.add_argument("--std_floor", type=float, default=1e-3)
    ap.add_argument("--per_block", type=int, default=10)
    ap.add_argument("--m_per_block", type=int, default=3)
    ap.add_argument(
        "--assign_mode",
        choices=["first3", "roundrobin"],
        default="first3",
        help="first3: only first three grids -> train/eval/test; roundrobin: assign 0,1,2 modulo",
    )
    args = ap.parse_args()

    train_dir = os.path.join(args.out_dir, "train")
    eval_dir = os.path.join(args.out_dir, "eval")
    test_dir = os.path.join(args.out_dir, "test")
    os.makedirs(train_dir, exist_ok=True)
    os.makedirs(eval_dir, exist_ok=True)
    os.makedirs(test_dir, exist_ok=True)

    mat_paths = sorted(glob.glob(os.path.join(args.radio_dir, "*.mat")))
    if not mat_paths:
        raise RuntimeError("No .mat files found")
    csv_all = sorted(glob.glob(os.path.join(args.gt_dir, "*.csv")))

    def find_csv_for_base(base: str, csv_all_in: List[str]) -> Optional[str]:
        base_noext = os.path.splitext(os.path.basename(base))[0]
        for cp in csv_all_in:
            if os.path.splitext(os.path.basename(cp))[0].lower() == base_noext.lower():
                return cp
        bid = _extract_num_id(base_noext)
        if bid is None:
            return None
        cands = []
        for cp in csv_all_in:
            name = os.path.splitext(os.path.basename(cp))[0]
            cid = _extract_num_id(name)
            if cid is not None and cid == bid:
                cands.append(cp)
        if not cands:
            return None
        cands.sort()
        return cands[0]

    # stats accumulation over TRAIN targets only
    sum_vec = None
    sumsq_vec = None
    count_total = 0
    Din_ref = None

    # grid assignment helper
    def assign_role(idx: int) -> Optional[str]:
        if args.assign_mode == "first3":
            if idx == 0:
                return "train"
            if idx == 1:
                return "eval"
            if idx == 2:
                return "test"
            return None  # ignore others
        # round-robin
        r = idx % 3
        return ("train" if r == 0 else ("eval" if r == 1 else "test"))

    for gi, mp in enumerate(mat_paths):
        role = assign_role(gi)
        if role is None:
            print(f"[SKIP] ignoring extra grid beyond first3: {os.path.basename(mp)}")
            continue

        base = os.path.splitext(os.path.basename(mp))[0]
        csv_match = find_csv_for_base(base, csv_all)
        if not csv_match:
            print(f"[WARN] no GT for {base}")
            continue

        md = loadmat(mp)
        Y = select_radio_tensor(md)
        T, F, A = Y.shape
        ts_radio = None
        for k in ["timestamp", "timestamps", "time", "t", "ts"]:
            if k in md and isinstance(md[k], np.ndarray):
                ts0 = np.asarray(md[k]).squeeze()
                if ts0.ndim == 1:
                    ts_radio = _infer_seconds(ts0.astype(np.float64))
                    break
        if ts_radio is None:
            ts_radio = np.arange(T, dtype=np.float64) / max(1, args.fps)

        ts_gt, xy_gt = load_gt_csv(csv_match, args.pos_units)
        L = min(T, ts_gt.shape[0])

        feats_full = cir_features_batch(Y, args.taps)
        Din = feats_full.shape[1]
        if Din_ref is None:
            Din_ref = Din
        elif Din != Din_ref:
            raise ValueError(f"Din mismatch: {Din} vs {Din_ref}")

        # pick targets per block
        per_block = max(1, int(args.per_block))
        m_blk = max(0, int(args.m_per_block))
        tgt_idxs: List[int] = []
        for start in range(0, L, per_block):
            end = min(start + per_block, L)
            block = list(range(start, end))
            take = min(m_blk, len(block))
            tgt_idxs.extend(block[:take])
        tgt_idxs = sorted(set(int(i) for i in tgt_idxs))

        # write full sequences (truncated to L) + role-specific indices
        feats_all = np.nan_to_num(feats_full[:L], nan=0.0, posinf=1e6, neginf=-1e6)
        xy_all = np.nan_to_num(xy_gt[:L], nan=0.0, posinf=1e6, neginf=-1e6)
        ts_all = ts_gt[:L]

        if role == "train":
            out_dir = train_dir
        elif role == "eval":
            out_dir = eval_dir
        else:
            out_dir = test_dir

        base_prefix = os.path.join(out_dir, base)
        np.save(f"{base_prefix}.feats.npy", feats_all.astype(args.dtype))
        np.save(f"{base_prefix}.xy.npy", xy_all.astype(np.float32))
        np.save(f"{base_prefix}.ts.npy", ts_all.astype(np.float64))

        meta = {
            "taps": args.taps,
            "input_dim": int(Din),
            "role": role,
            "length": int(L),
            "total_frames": int(L),
            "per_block": per_block,
            "m_per_block": m_blk,
            "dtype": str(args.dtype),
        }
        # put role-specific indices into dedicated field to match loader target selection
        if role == "train":
            meta["indices_train"] = [int(i) for i in tgt_idxs]
        elif role == "eval":
            meta["indices_eval"] = [int(i) for i in tgt_idxs]
        else:
            # keep test without indices to use full-seq evaluation by default
            pass

        with open(f"{base_prefix}.json", "w", encoding="utf-8") as mf:
            json.dump(meta, mf, ensure_ascii=False, indent=2)
        print(f"[OK][{role:5s}] {base_prefix}.feats.npy L={L} targets={len(tgt_idxs)}")

        # accumulate stats on TRAIN targets only
        if role == "train" and len(tgt_idxs) > 0:
            f64 = feats_all[np.asarray(tgt_idxs, dtype=np.int64)].astype(np.float64, copy=False)
            if sum_vec is None:
                sum_vec = f64.sum(axis=0)
                sumsq_vec = (f64 ** 2).sum(axis=0)
            else:
                sum_vec += f64.sum(axis=0)
                sumsq_vec += (f64 ** 2).sum(axis=0)
            count_total += f64.shape[0]

    # finalize stats
    if count_total == 0 or sum_vec is None or sumsq_vec is None:
        raise RuntimeError("No TRAIN frames to compute stats.")
    mean = (sum_vec / count_total).astype(np.float32)
    var = (sumsq_vec / count_total) - (mean.astype(np.float64) ** 2)
    var = np.maximum(var, 0.0)
    std = np.sqrt(var).astype(np.float32)
    std = np.maximum(std, args.std_floor).astype(np.float32)

    stats_path = os.path.join(args.out_dir, "stats_train.npz")
    np.savez(
        stats_path,
        feat_mean=mean,
        feat_std=std,
        count=int(count_total),
        Din=int(Din_ref or mean.shape[0]),
        std_floor=float(args.std_floor),
        note="three-way split (train/eval/test) with per-block target sampling",
    )
    print(
        f"[STATS] {stats_path} Din={int(Din_ref or mean.shape[0])} count={count_total} per_block={args.per_block} m_per_block={args.m_per_block}"
    )


if __name__ == "__main__":
    main()

