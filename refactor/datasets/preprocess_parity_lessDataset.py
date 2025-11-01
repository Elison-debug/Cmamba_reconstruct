#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import argparse, os, glob, re, json
from typing import Optional, List
import numpy as np
from scipy.io import loadmat
from .preprocess_luvira_lazy import _infer_seconds, load_gt_csv, select_radio_tensor, cir_features_batch


def _extract_num_id(name: str) -> Optional[int]:
    import re as _re
    m = _re.findall(r'\d+', name)
    return None if not m else int(m[-1])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--radio_dir", required=True)
    ap.add_argument("--gt_dir", required=True)
    ap.add_argument("--out_dir", required=True)
    ap.add_argument("--taps", type=int, default=10)
    ap.add_argument("--fps", type=int, default=100)
    ap.add_argument("--pos_units", choices=["mm", "m"], default="mm")
    ap.add_argument("--dtype", choices=["float16", "float32"], default="float16")
    ap.add_argument("--std_floor", type=float, default=1e-3)
    ap.add_argument("--per_block", type=int, default=5)
    ap.add_argument("--n_per_block", type=int, default=4)
    ap.add_argument("--m_per_block", type=int, default=1)
    ap.add_argument("--odd_even", choices=["odd","even"], default="odd")
    args = ap.parse_args()

    train_dir = os.path.join(args.out_dir, "train")
    eval_dir  = os.path.join(args.out_dir, "eval")
    os.makedirs(train_dir, exist_ok=True)
    os.makedirs(eval_dir,  exist_ok=True)

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
        is_train = (gid % 2 == 1 and args.odd_even=="odd") or (gid % 2 == 0 and args.odd_even=="even")
        role = "train" if is_train else "eval"

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

        feats = feats_full[idxs]
        xy_use = xy_gt[idxs]
        ts_use = ts_gt[idxs]

        out_dir = train_dir if role=="train" else eval_dir
        out_path = os.path.join(out_dir, f"{base}.npz")
        np.savez(out_path, feats=feats.astype(args.dtype), xy=xy_use.astype(np.float32), ts=ts_use.astype(np.float64),
                 meta=json.dumps(dict(taps=args.taps, input_dim=Din, split=dict(role=role, idx=[0,int(len(idxs))], total=int(L), less=True))))
        print(f"[OK][{role:5s}] {out_path} feats={feats.shape}")

        if role=="train" and feats.shape[0]>0:
            f64 = feats.astype(np.float64, copy=False)
            if sum_vec is None:
                sum_vec = f64.sum(axis=0)
                sumsq_vec = (f64 ** 2).sum(axis=0)
            else:
                sum_vec += f64.sum(axis=0)
                sumsq_vec += (f64 ** 2).sum(axis=0)
            count_total += f64.shape[0]

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

