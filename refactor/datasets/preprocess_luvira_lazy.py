#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Preprocess LuViRA radio -> NPZ features (lazy frames)  [INDEX-FAST + train/eval split]

Outputs:
- out_dir/train/<base>.npz
- out_dir/eval/<base>.npz
- out_dir/stats_train.npz

NPZ contents:
- feats: (T', Din) float16/32
- xy:    (T', 2) float32 (meters)
- ts:    (T',)  float64 (seconds)
- meta:  json string with minimal fields
"""
import argparse, os, glob, re, json, csv
from typing import Tuple, Dict, Any, Optional, List, cast
import numpy as np
from numpy.fft import ifft
from scipy.io import loadmat


def _infer_seconds(ts: np.ndarray) -> np.ndarray:
    ts = np.asarray(ts).astype(np.float64).reshape(-1)
    if ts.size < 2:
        return ts
    dif = np.diff(ts)
    dif = dif[np.isfinite(dif) & (dif > 0)]
    if dif.size == 0:
        return ts
    md = float(np.median(dif))
    if md > 1e-2:
        scale = 1.0
    elif md > 1e-4:
        scale = 1e-3
    else:
        scale = 1e-6
    return ts * scale


def _sniff_delimiter(path: str, encodings: tuple[str, ...] = ("utf-8", "utf-8-sig", "gbk", "latin1")) -> Tuple[str, str]:
    candidates = [",", ";", "\t", " "]
    candidate_str = ",;\t "
    for enc in encodings:
        try:
            with open(path, "r", encoding=enc, newline="") as f:
                sample = f.read(65536)
            if not sample:
                continue
            try:
                dialect = csv.Sniffer().sniff(sample, delimiters=candidate_str)
                delim = dialect.delimiter
            except Exception:
                counts = {d: sample.count(d) for d in candidates}
                delim = "," if sum(counts.values()) == 0 else max(counts.items(), key=lambda kv: kv[1])[0]
            return enc, delim
        except Exception:
            continue
    return "utf-8", ","


def load_gt_csv(path_csv: str, pos_units: str = "mm") -> Tuple[np.ndarray, np.ndarray]:
    enc, delim = _sniff_delimiter(path_csv)
    try:
        data = np.genfromtxt(path_csv, delimiter=delim, names=True, dtype=None, encoding=enc)
    except Exception:
        data = None
    have_header = (isinstance(data, np.ndarray) and getattr(data, "size", 0) > 0 and getattr(data.dtype, "names", None) is not None)
    if not have_header:
        try:
            raw = np.genfromtxt(path_csv, delimiter=delim, dtype=float, encoding=enc)
        except Exception:
            raw = np.genfromtxt(path_csv, delimiter=delim, dtype=float)
        if raw.ndim == 1:
            raw = raw.reshape(1, -1)
        raw = raw[np.isfinite(raw).all(axis=1)]
        if raw.shape[1] < 3 or raw.shape[0] < 2:
            raise ValueError(f"CSV {path_csv}: not enough numeric rows/cols")
        ts = raw[:, 0].astype(np.float64)
        xy = raw[:, 1:3].astype(np.float64)
    else:
        names = [n.lower() for n in (data.dtype.names or [])] # type: ignore[attr-defined]
        def _find(keys):
            for k in keys:
                if k in names:
                    return k
            return None
        tk = _find(["time", "timestamp", "ts", "t"]) or names[0]
        xk = _find(["x", "pos_x", "px"]) or names[1]
        yk = _find(["y", "pos_y", "py"]) or names[2]
        rec = cast(np.ndarray, data)
        ts = np.asarray(rec[tk], dtype=np.float64).reshape(-1)
        x  = np.asarray(rec[xk], dtype=np.float64).reshape(-1)
        y  = np.asarray(rec[yk], dtype=np.float64).reshape(-1)
        m = np.isfinite(ts) & np.isfinite(x) & np.isfinite(y)
        ts = ts[m]; x = x[m]; y = y[m]
        xy = np.stack([x, y], axis=1)
    ts = _infer_seconds(ts)
    if pos_units == "mm":
        xy = xy / 1000.0
    elif pos_units != "m":
        raise ValueError("pos_units must be 'mm' or 'm'")
    order = np.argsort(ts)
    return ts[order], xy[order].astype(np.float32)


PREF_KEYS = ["H_ueprocess", "H", "Yc", "CSI", "CIR"]


def select_radio_tensor(md: Dict[str, Any]) -> np.ndarray:
    key: Optional[str] = None
    for k in PREF_KEYS:
        if k in md and isinstance(md[k], np.ndarray):
            key = k; break
    if key is None:
        cands = [(k, v) for k, v in md.items() if isinstance(v, np.ndarray) and v.ndim == 3]
        if not cands:
            raise ValueError("No 3D ndarray in .mat")
        key, _ = max(cands, key=lambda kv: kv[1].size)
    A = np.asarray(md[key])
    if not np.iscomplexobj(A):
        re_key, im_key = key + "_real", key + "_imag"
        if re_key in md and im_key in md:
            A = np.asarray(md[re_key]) + 1j * np.asarray(md[im_key])
        else:
            raise ValueError(f"{key} is not complex and no ({re_key},{im_key}) provided")
    if A.ndim != 3:
        raise ValueError(f"{key} must be 3D, got {A.ndim}D")
    # ensure (T,F,A)
    dims = list(A.shape)
    t_ax = int(np.argmax(dims))
    if t_ax == 0:
        Yt = A
    elif t_ax == 1:
        Yt = np.transpose(A, (1, 0, 2))
    else:
        Yt = np.transpose(A, (2, 0, 1))
    T, a, b = Yt.shape
    Y = Yt if a >= b else np.transpose(Yt, (0, 2, 1))
    return Y


def load_radio_mat(path: str) -> Tuple[np.ndarray, Optional[np.ndarray]]:
    md = loadmat(path)
    Y = select_radio_tensor(md)
    ts = None
    for k in ['timestamp', 'timestamps', 'time', 't', 'ts']:
        if k in md and isinstance(md[k], np.ndarray):
            ts0 = np.asarray(md[k]).squeeze()
            if ts0.ndim == 1:
                ts = ts0.astype(np.float64); break
    if ts is not None:
        ts = _infer_seconds(ts)
    return Y, ts


def cir_features_batch(Y: np.ndarray, L: int) -> np.ndarray:
    D = ifft(Y, axis=1)[:, :L, :]  # (T, L, A)
    p = np.sqrt(np.mean(np.abs(D)**2, axis=(0, 1), keepdims=True)) + 1e-8  # (1,1,A)
    Dn = D / p
    T, _, A = Dn.shape
    feat_cir = np.stack([Dn.real, Dn.imag], axis=2)      # (T, L, 2, A)
    feat_cir = feat_cir.transpose(0, 1, 3, 2).reshape(T, L * A * 2)
    power = np.log1p(np.mean(np.abs(D)**2, axis=1))      # (T, A)
    feats = np.concatenate([feat_cir.astype(np.float32), power.astype(np.float32)], axis=1)
    return feats


def _extract_num_id(name: str) -> Optional[int]:
    m = re.findall(r'\d+', name)
    return None if not m else int(m[-1])


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
    base_low = base_noext.lower()
    cands.sort(key=lambda p: (base_low not in os.path.basename(p).lower(), os.path.basename(p).lower()))
    return cands[0]


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
    ap.add_argument("--split", type=float, default=0.8)
    ap.add_argument("--eval_ratio", type=float, default=1.0)
    args = ap.parse_args()

    train_dir = os.path.join(args.out_dir, "train")
    eval_dir  = os.path.join(args.out_dir, "eval")
    os.makedirs(train_dir, exist_ok=True)
    os.makedirs(eval_dir,  exist_ok=True)

    mat_paths = sorted(glob.glob(os.path.join(args.radio_dir, "*.mat")))
    if not mat_paths:
        raise RuntimeError("No .mat files found")
    csv_all = sorted(glob.glob(os.path.join(args.gt_dir, "*.csv")))

    sum_vec = None; sumsq_vec = None; count_total = 0
    Din_ref = None

    for mp in mat_paths:
        base = os.path.splitext(os.path.basename(mp))[0]
        csv_match = find_csv_for_base(base, csv_all)
        if not csv_match:
            print(f"[WARN] no GT for {base}"); continue
        Y, ts_radio = load_radio_mat(mp)  # (T,F,A)
        T, F, A = Y.shape
        if ts_radio is None:
            ts_radio = np.arange(T, dtype=np.float64) / max(1, args.fps)
        ts_gt, xy_gt = load_gt_csv(csv_match, args.pos_units)
        L = min(T, ts_gt.shape[0])
        # features
        feats_full = cir_features_batch(Y, args.taps)  # (T, Din)
        Din = feats_full.shape[1]
        if Din_ref is None: Din_ref = Din
        feats = feats_full[:L]
        xy_use = xy_gt[:L]
        ts_use = ts_gt[:L]

        # split: first split->train, last (eval_ratio) portion -> eval
        i_split = int(np.floor(L * float(np.clip(args.split, 0.0, 1.0))))
        e_split = L  # use tail as eval
        feats_tr, xy_tr, ts_tr = feats[:i_split], xy_use[:i_split], ts_use[:i_split]
        feats_ev, xy_ev, ts_ev = feats[i_split:e_split], xy_use[i_split:e_split], ts_use[i_split:e_split]

        out_tr = os.path.join(train_dir, f"{base}.npz")
        np.savez(out_tr, feats=feats_tr.astype(args.dtype), xy=xy_tr.astype(np.float32), ts=ts_tr.astype(np.float64),
                 meta=json.dumps(dict(taps=args.taps, input_dim=Din, split=dict(role="train", idx=[0,int(i_split)], total=int(L)))))
        print(f"[OK][train] {out_tr} feats={feats_tr.shape}")

        out_ev = os.path.join(eval_dir, f"{base}.npz")
        np.savez(out_ev, feats=feats_ev.astype(args.dtype), xy=xy_ev.astype(np.float32), ts=ts_ev.astype(np.float64),
                 meta=json.dumps(dict(taps=args.taps, input_dim=Din, split=dict(role="eval", idx=[int(i_split),int(e_split)], total=int(L)))))
        print(f"[OK][eval ] {out_ev} feats={feats_ev.shape}")

        # stats on train only
        if feats_tr.shape[0] > 0:
            f64 = feats_tr.astype(np.float64, copy=False)
            if sum_vec is None:
                sum_vec = f64.sum(axis=0)
                sumsq_vec = (f64 ** 2).sum(axis=0)
            else:
                sum_vec += f64.sum(axis=0)
                sumsq_vec += (f64 ** 2).sum(axis=0)
            count_total += f64.shape[0]

    if count_total == 0 or sum_vec is None or sumsq_vec is None:
        raise RuntimeError("No train frames to compute stats.")
    mean = (sum_vec / count_total).astype(np.float32)
    var = (sumsq_vec / count_total) - (mean.astype(np.float64) ** 2)
    var = np.maximum(var, 0.0)
    std = np.sqrt(var).astype(np.float32)
    std = np.maximum(std, args.std_floor).astype(np.float32)

    stats_path = os.path.join(args.out_dir, "stats_train.npz")
    np.savez(stats_path, feat_mean=mean, feat_std=std, count=int(count_total), Din=int(Din_ref or mean.shape[0]), std_floor=float(args.std_floor))
    print(f"[STATS] {stats_path} Din={int(Din_ref or mean.shape[0])} count={count_total}")


if __name__ == "__main__":
    main()

