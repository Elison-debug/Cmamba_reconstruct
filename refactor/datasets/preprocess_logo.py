#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Preprocess radio (.mat) + GT (.csv) into hardware/FPGA‑friendly NPY format
with LOGO (leave‑one‑grid‑out) split, temporal embargo, and explicit windowing.

For each grid file pair we write four companions sharing the same basename:
  - base.feats.npy  # (T, Din) float16/float32 features
  - base.xy.npy     # (T, 2)   float32 positions (meters)
  - base.ts.npy     # (T,)     float64 timestamps (seconds)
  - base.json       # metadata + role‑specific window target indices, e.g.:
        { "indices_train": [...],  "indices_eval": [...],  "win_len": K, ... }

Additionally, we compute train‑only global normalization stats and save to:
  - out_dir/stats_train.npz  with keys {feat_mean, feat_std, count, Din, std_floor}

This output is directly consumable by FramesLazyDataset, which constructs
grid‑pure windows on the fly using the stored target indices. Keeping the
features as per‑frame sequences keeps IO simple and quantization‑friendly.
"""
from __future__ import annotations

import argparse
import csv
import glob
import json
import os
import re
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple, cast

import numpy as np
from numpy.fft import ifft
from scipy.io import loadmat

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
    ts = _infer_seconds(ts)
    if pos_units == "mm":
        xy = xy / 1000.0
    elif pos_units != "m":
        raise ValueError("pos_units must be 'mm' or 'm'")
    order = np.argsort(ts)
    return ts[order], xy[order].astype(np.float32)

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

def _extract_num_id(name: str) -> Optional[int]:
    """Extract the last integer token from a basename as grid id, if any."""
    m = re.findall(r"\d+", name)
    return None if not m else int(m[-1])


def select_radio_tensor(md: Dict[str, np.ndarray]) -> np.ndarray:
    """Pick a 3D complex array and coerce to layout (T, F, A).

    Preference order tries common keys; otherwise pick the largest 3D array.
    Accepts split real/imag pairs as well.
    """
    PREF_KEYS = ["H_ueprocess", "H", "Yc", "CSI", "CIR"]
    key: Optional[str] = None
    for k in PREF_KEYS:
        if k in md and isinstance(md[k], np.ndarray):
            key = k
            break
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
    # ensure (T, F, A)
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


def cir_features_hw(
    Y: np.ndarray,
    Ltap: int,
    *,
    phase_center: bool = True,
    append_delta: bool = True,
) -> np.ndarray:
    """Hardware‑friendly CIR feature extraction with optional phase centering
    and delta channels. Output is strictly real‑valued and contiguous.

    Steps:
      1) IFFT across frequency to obtain CIR taps, take first Ltap.
      2) Per‑antenna power normalization.
      3) Optional phase centering: subtract mean phase per (tap, antenna).
      4) Concatenate [real, imag] and log‑power; optionally first‑order time delta.
    """
    D = ifft(Y, axis=1)[:, :Ltap, :]                        # (T, Ltap, A)
    p = np.sqrt(np.mean(np.abs(D) ** 2, axis=(0, 1), keepdims=True)) + 1e-8
    Dn = D / p                                              # (T, Ltap, A)
    if phase_center:
        ph = np.angle(Dn)
        ph -= np.mean(ph, axis=0, keepdims=True)
        Dn = np.abs(Dn) * np.exp(1j * ph)

    T, L, A = Dn.shape
    feat_cir = np.stack([Dn.real, Dn.imag], axis=2)         # (T, L, 2, A)
    feat_cir = feat_cir.transpose(0, 1, 3, 2).reshape(T, L * A * 2)
    power = np.log1p(np.mean(np.abs(D) ** 2, axis=1))       # (T, A)
    feats = np.concatenate([feat_cir.astype(np.float32), power.astype(np.float32)], axis=1)

    if append_delta:
        d = np.zeros_like(feats)
        d[1:] = feats[1:] - feats[:-1]
        feats = np.concatenate([feats, d], axis=1)

    return feats


def secs_to_frames(sec: float, fps: int) -> int:
    return int(round(max(0.0, float(sec)) * max(1, int(fps))))


def build_windows(L: int, K: int, stride: int, start: int, end: int):
    """Yield window [s, e) indices with length K and given stride within [start,end)."""
    i = int(start)
    end = int(end)
    while i + K <= end:
        yield (i, i + K)
        i += int(stride)


def _role_of_gid(gid: int, split: str, holdout: set[int]) -> str:
    if split == "oddeven":
        # Simple legacy split: odd -> train, even -> eval
        return "train" if (gid % 2 == 1) else "eval"
    # LOGO: held‑out gids are eval, others train
    return "eval" if gid in holdout else "train"


def _find_csv_for_base(base: str, csv_all: List[str]) -> Optional[str]:
    base_noext = os.path.splitext(os.path.basename(base))[0]
    # exact name match first
    for cp in csv_all:
        if os.path.splitext(os.path.basename(cp))[0].lower() == base_noext.lower():
            return cp
    # fallback: numeric id match
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
    cands.sort()
    return cands[0]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--radio_dir", type=str, default="./data/radio/grid", help="folder of .mat CSI/CIR files")
    ap.add_argument("--gt_dir", type=str, default="./data/truth/grid", help="folder of matching .csv ground truth")
    ap.add_argument("--out_dir", type=str, default="./data/features/logo", help="output folder for features and stats")

    # split + windowing
    ap.add_argument("--split", type=str, default="logo", choices=["logo", "oddeven"], help="split strategy")
    ap.add_argument("--logo_holdout_gids", type=str, default="109,125", help="comma‑separated held‑out grid IDs for LOGO (eval)")
    ap.add_argument("--logo_test_gids", type=str, default="107,140", help="optional comma‑separated grid IDs for TEST set")
    ap.add_argument("--embargo_sec", type=float, default=0.4, help="temporal buffer removed near split boundaries")
    ap.add_argument("--fps", type=int, default=100, help="frames per second fallback for missing timestamps")
    ap.add_argument("--win_len", type=int, default=16, help="window length K")
    ap.add_argument("--train_stride", type=int, default=4, help="stride for train windows")
    ap.add_argument("--eval_stride", type=int, default=4, help="stride for eval windows")

    # features
    ap.add_argument("--taps", type=int, default=10, help="number of CIR taps to keep")
    ap.add_argument("--phase_center", action="store_true", help="enable phase centering")
    ap.add_argument("--append_delta", action="store_true", help="append first‑order delta features")
    ap.add_argument("--dtype", type=str, default="float16", choices=["float16", "float32"], help="feature dtype on disk")
    ap.add_argument("--pos_units", type=str, default="mm", choices=["mm", "m"], help="position units in CSV")
    ap.add_argument("--std_floor", type=float, default=1e-5, help="minimum std for normalization")
    args = ap.parse_args()

    out = Path(args.out_dir)
    # 新布局：所有 NPY 放在 out/train/npy 下；所有 JSON 放在 out/train/json 下
    npy_dir = out / "npy"
    json_dir = out / "json"
    npy_dir.mkdir(parents=True, exist_ok=True)
    json_dir.mkdir(parents=True, exist_ok=True)

    mat_paths = sorted(glob.glob(os.path.join(args.radio_dir, "*.mat")))
    if not mat_paths:
        raise RuntimeError("No .mat files found")
    csv_all = sorted(glob.glob(os.path.join(args.gt_dir, "*.csv")))

    # parse holdout list for LOGO
    holdout: set[int] = set()
    testset: set[int] = set()
    if args.logo_holdout_gids.strip():
        for tok in args.logo_holdout_gids.split(','):
            tok = tok.strip()
            if tok:
                try:
                    holdout.add(int(tok))
                except Exception:
                    pass
    if args.logo_test_gids.strip():
        for tok in args.logo_test_gids.split(','):
            tok = tok.strip()
            if tok:
                try:
                    testset.add(int(tok))
                except Exception:
                    pass

    # stats over TRAIN windows only
    sum_vec: Optional[np.ndarray] = None
    sumsq_vec: Optional[np.ndarray] = None
    count_total: int = 0
    Din_ref: Optional[int] = None

    E = secs_to_frames(args.embargo_sec, args.fps)
    K = int(args.win_len)

    for mp in mat_paths:
        base = os.path.splitext(os.path.basename(mp))[0]
        gid = _extract_num_id(base)
        # unknown id -> treat as non‑held‑out train by default
        # role priority: TEST > EVAL(LOGO holdout) > TRAIN
        role = _role_of_gid(gid or -1, args.split, holdout)
        if (gid is not None) and (gid in testset):
            role = "test"

        csv_match = _find_csv_for_base(base, csv_all)
        if not csv_match:
            print(f"[WARN] no GT for {base}")
            continue

        md = loadmat(mp)
        Y = select_radio_tensor(md)                      # (T, F, A)
        T, F, A = Y.shape
        # timestamps from MAT, else synthetic by fps
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

        feats_full = cir_features_hw(
            Y, args.taps, phase_center=bool(args.phase_center), append_delta=bool(args.append_delta)
        )
        Din = int(feats_full.shape[1])
        if Din_ref is None:
            Din_ref = Din
        elif Din_ref != Din:
            raise ValueError(f"Din mismatch across files: {Din_ref} vs {Din}")

        feats = np.nan_to_num(feats_full[:L], nan=0.0, posinf=1e6, neginf=-1e6)
        xy = np.nan_to_num(xy_gt[:L],       nan=0.0, posinf=1e6, neginf=-1e6)
        ts = ts_gt[:L]

        # # window targets per role (end indices)
        # if role == "train":
        #     start = 0
        #     end = L
        #     stride = max(1, int(args.train_stride))
        # else:
        #     # eval/test: apply embargo on both sides
        #     start = min(E, L)
        #     end = max(start, L - E)
        #     stride = max(1, int(args.eval_stride))
        
        #apply embargo on all mode
        start = min(E, L)
        end = max(start, L - E)
        stride = max(1, int(args.eval_stride))

        indices = [e for (s, e) in build_windows(L, K, stride, start, end)]

        # 写入统一的 NPY 目录
        base_prefix = npy_dir / base
        np.save(str(base_prefix) + ".feats.npy", feats.astype(args.dtype))
        np.save(str(base_prefix) + ".xy.npy", xy.astype(np.float32))
        np.save(str(base_prefix) + ".ts.npy", ts.astype(np.float64))

        meta: Dict[str, object] = {
            "taps": int(args.taps),
            "input_dim": int(Din),
            "role": role,
            "length": int(L),
            "win_len": int(K),
            "stride": int(stride),
            "embargo_sec": float(args.embargo_sec),
            "dtype": str(args.dtype),
        }
        if role == "train":
            meta["indices_train"] = [int(i) for i in indices]
        elif role == "eval":
            meta["indices_eval"] = [int(i) for i in indices]
        elif role == "test":
            # FramesLazyDataset 支持读取通用键 "indices"（target=auto）
            meta["indices"] = [int(i) for i in indices]

        # JSON 与 NPY 分离，放到 json_dir，文件名与 base 对齐
        with open(str(json_dir / f"{base}.json"), "w", encoding="utf-8") as mf:
            json.dump(meta, mf, ensure_ascii=False, indent=2)
        print(f"[OK][{role:5s}] {base}  L={L}  windows={len(indices)}  Din={Din}")

        # accumulate train‑only stats across frames inside train windows
        if role == "train" and len(indices) > 0:
            # naive accumulation over all window frames (double counts overlapping frames by design)
            for s, e in build_windows(L, K, stride, start, end):
                f = feats[s:e].astype(np.float64, copy=False)
                if sum_vec is None:
                    sum_vec = f.sum(axis=0)
                    sumsq_vec = (f ** 2).sum(axis=0)
                else:
                    sum_vec += f.sum(axis=0)
                    sumsq_vec += (f ** 2).sum(axis=0)
                count_total += f.shape[0]

    # finalize stats
    if count_total == 0 or sum_vec is None or sumsq_vec is None:
        raise RuntimeError("No TRAIN windows to compute stats.")
    mean = (sum_vec / count_total).astype(np.float32)
    var = (sumsq_vec / count_total) - (mean.astype(np.float64) ** 2)
    var = np.maximum(var, 0.0)
    std = np.sqrt(var).astype(np.float32)
    std = np.maximum(std, float(args.std_floor)).astype(np.float32)

    stats_path = out / "stats_train.npz"
    np.savez(
        stats_path,
        feat_mean=mean,
        feat_std=std,
        count=int(count_total),
        Din=int(Din_ref or mean.shape[0]),
        std_floor=float(args.std_floor),
        note="LOGO+embargo windowed stats over train windows",
    )
    print(f"[STATS] {stats_path} Din={int(Din_ref or mean.shape[0])} frames={count_total}")


if __name__ == "__main__":
    main()
