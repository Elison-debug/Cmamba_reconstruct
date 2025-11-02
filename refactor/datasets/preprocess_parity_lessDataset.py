#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Preprocess LuViRA radio -> NPZ features (lazy frames)  [INDEX-FAST + train/eval test split]

Outputs:
- out_dir/train/<base>.npz
- out_dir/test/<base>.npz
- out_dir/stats_train.npz

NPZ contents:
- feats: (T', Din) float16/32
- xy:    (T', 2) float32 (meters)
- ts:    (T',)  float64 (seconds)
- meta:  json string with minimal fields
"""
import argparse, os, glob, re, json, csv
from typing import Optional, List , Tuple, Dict, cast, Any
import numpy as np
from scipy.io import loadmat
from numpy.fft import ifft

from .preprocess_luvira_lazy import (
    _infer_seconds,
    load_gt_csv,
    select_radio_tensor,
    cir_features_batch,
)

def _extract_num_id(name: str) -> Optional[int]:
    import re as _re
    m = _re.findall(r'\d+', name)
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
    ap.add_argument("--per_block", type=int, default=5)
    ap.add_argument("--n_per_block", type=int, default=1)
    ap.add_argument("--m_per_block", type=int, default=4)
    ap.add_argument("--odd_even", choices=["odd","even"], default="odd")
    args = ap.parse_args()

    train_dir = os.path.join(args.out_dir, "train")
    test_dir  = os.path.join(args.out_dir, "test")
    os.makedirs(train_dir, exist_ok=True)
    os.makedirs(test_dir,  exist_ok=True)

    mat_paths = sorted(glob.glob(os.path.join(args.radio_dir, "*.mat")))
    if not mat_paths:
        raise RuntimeError("No .mat files found")
    csv_all = sorted(glob.glob(os.path.join(args.gt_dir, "*.csv")))

    def find_csv_for_base(base: str, csv_all: List[str]) -> Optional[str]:
        base_noext = os.path.splitext(os.path.basename(base))[0]
        for cp in csv_all:
            if os.path.splitext(os.path.basename(cp))[0].lower() == base_noext.lower():
                return cp
        bid = _extract_num_id(base_noext)
        if bid is None:
            return None
        cands = []
        for cp in csv_all:
            name = os.path.splitext(os.path.basename(cp))[0]
            cid = _extract_num_id(name)
            if cid is not None and cid == bid:
                cands.append(cp)
        if not cands:
            return None
        cands.sort(); return cands[0]

    sum_vec = None; sumsq_vec = None; count_total = 0; Din_ref = None

    for mp in mat_paths:
        base = os.path.splitext(os.path.basename(mp))[0]
        gid = _extract_num_id(base) or 0
        # select by odd/even
        is_train_source = (gid % 2 == 1 and args.odd_even=="odd") or (gid % 2 == 0 and args.odd_even=="even")

        csv_match = find_csv_for_base(base, csv_all)
        if not csv_match:
            print(f"[WARN] no GT for {base}"); continue
        md = loadmat(mp)
        Y = select_radio_tensor(md)
        T, F, A = Y.shape
        ts_radio = None
        for k in ['timestamp','timestamps','time','t','ts']:
            if k in md and isinstance(md[k], np.ndarray):
                ts0 = np.asarray(md[k]).squeeze()
                if ts0.ndim==1: ts_radio = _infer_seconds(ts0.astype(np.float64)); break
        if ts_radio is None:
            ts_radio = np.arange(T, dtype=np.float64) / max(1, args.fps)
        ts_gt, xy_gt = load_gt_csv(csv_match, args.pos_units)
        L = min(T, ts_gt.shape[0])

        feats_full = cir_features_batch(Y, args.taps)
        Din = feats_full.shape[1]
        if Din_ref is None: Din_ref = Din

        # build selected indices for less dataset
        idxs: List[int] = []
        step = max(1, int(args.m_per_block))
        take = max(1, int(args.n_per_block))
        for b in range(max(0, int(args.per_block))):
            start = b * step
            for j in range(take):
                t = start + j
                if t < L:
                    idxs.append(t)
        idxs = sorted(set(idxs))
        if not idxs:
            idxs = list(range(min(L, take)))

        per_block = max(1, int(args.per_block))
        n_blk = max(0, int(args.n_per_block))
        m_blk = max(0, int(args.m_per_block))
        if (n_blk + m_blk) > per_block:
            raise ValueError(f"Invalid block split: m_per_block={m_blk} + n_per_block={n_blk} exceeds per_block={per_block}")

        if is_train_source:
            # Build target indices for train/eval within each temporal block
            train_idxs: List[int] = []
            eval_idxs: List[int] = []
            for start in range(0, L, per_block):
                end = min(start + per_block, L)
                block = list(range(start, end))
                m_take = min(m_blk, len(block))
                train_idxs.extend(block[:m_take])
                rem = block[m_take:]
                n_take = min(n_blk, len(rem))
                eval_idxs.extend(rem[:n_take])
            if not train_idxs and m_blk > 0:
                train_idxs = list(range(min(L, m_blk)))
                eval_idxs = [i for i in eval_idxs if i not in train_idxs]
            if not eval_idxs and n_blk > 0:
                candidates = sorted(set(range(L)) - set(train_idxs))
                eval_idxs = candidates[:n_blk]

            # Write single copy under train/, with both indices sets in JSON
            base_prefix = os.path.join(train_dir, base)
            feats_all = np.nan_to_num(feats_full[:L], nan=0.0, posinf=1e6, neginf=-1e6)
            xy_all = np.nan_to_num(xy_gt[:L], nan=0.0, posinf=1e6, neginf=-1e6)
            ts_all = ts_gt[:L]
            np.save(f"{base_prefix}.feats.npy", feats_all.astype(args.dtype))
            np.save(f"{base_prefix}.xy.npy", xy_all.astype(np.float32))
            np.save(f"{base_prefix}.ts.npy", ts_all.astype(np.float64))
            meta = {
                "taps": args.taps,
                "input_dim": int(Din),
                "role": "train",
                "length": int(L),
                "total_frames": int(L),
                "indices_train": [int(i) for i in train_idxs],
                "indices_eval": [int(i) for i in eval_idxs],
                "per_block": per_block,
                "m_per_block": m_blk,
                "n_per_block": n_blk,
                "dtype": str(args.dtype),
            }
            with open(f"{base_prefix}.json", "w", encoding="utf-8") as mf:
                json.dump(meta, mf, ensure_ascii=False, indent=2)
            print(f"[OK][train] {base_prefix}.feats.npy feats={feats_all.shape} idx_train={len(train_idxs)} idx_eval={len(eval_idxs)}")

            # Accumulate stats using TRAIN targets only
            if len(train_idxs) > 0:
                f64 = feats_all[np.asarray(train_idxs, dtype=np.int64)].astype(np.float64, copy=False)
                if sum_vec is None:
                    sum_vec = f64.sum(axis=0)
                    sumsq_vec = (f64 ** 2).sum(axis=0)
                else:
                    sum_vec += f64.sum(axis=0)
                    sumsq_vec += (f64 ** 2).sum(axis=0)
                count_total += f64.shape[0]
        else:
            base_prefix = os.path.join(test_dir, base)
            feats_all = np.nan_to_num(feats_full[:L], nan=0.0, posinf=1e6, neginf=-1e6)
            xy_all = np.nan_to_num(xy_gt[:L], nan=0.0, posinf=1e6, neginf=-1e6)
            ts_all = ts_gt[:L]
            np.save(f"{base_prefix}.feats.npy", feats_all.astype(args.dtype))
            np.save(f"{base_prefix}.xy.npy", xy_all.astype(np.float32))
            np.save(f"{base_prefix}.ts.npy", ts_all.astype(np.float64))
            meta = {
                "taps": args.taps,
                "input_dim": int(Din),
                "role": "test",
                "length": int(L),
                "total_frames": int(L),
                "dtype": str(args.dtype),
            }
            with open(f"{base_prefix}.json", "w", encoding="utf-8") as mf:
                json.dump(meta, mf, ensure_ascii=False, indent=2)
            print(f"[OK][test ] {base_prefix}.feats.npy feats={feats_all.shape}")

    if count_total == 0 or sum_vec is None or sumsq_vec is None:
        raise RuntimeError("No TRAIN frames to compute stats.")
    mean = (sum_vec / count_total).astype(np.float32)
    var = (sumsq_vec / count_total) - (mean.astype(np.float64) ** 2)
    var = np.maximum(var, 0.0)
    std = np.sqrt(var).astype(np.float32)
    std = np.maximum(std, args.std_floor).astype(np.float32)

    stats_path = os.path.join(args.out_dir, "stats_train.npz")
    np.savez(stats_path, feat_mean=mean, feat_std=std, count=int(count_total), Din=int(Din_ref or mean.shape[0]), std_floor=float(args.std_floor), note="less dataset train stats")
    print(f"[STATS] {stats_path} Din={int(Din_ref or mean.shape[0])} count={count_total}")


if __name__ == "__main__":
    main()
