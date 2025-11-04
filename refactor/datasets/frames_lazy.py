from __future__ import annotations
import os
import json
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple

import numpy as np
import torch
from torch.utils.data import Dataset


class FramesLazyDataset(Dataset):
    """
    Dataset reader for the refactored training pipeline.

    Expected layout per sequence (all files share the same basename):
        base.feats.npy  # (T, Din) float16/float32
        base.xy.npy     # (T, 2)   float32
        base.ts.npy     # optional (T,) float64 timestamps
        base.json       # optional metadata (length, etc.)

    This loader only supports the new .npy-based format. Legacy .npz files are intentionally
    unsupported to keep the IO path simple and FPGA-friendly.
    """

    def __init__(
        self,
        root: Optional[str | os.PathLike] = None,
        *,
        seq_len: int = 12,
        predict: str = "current",
        mmap: bool = True,
        in_memory: bool = True,
        stats_root: Optional[str | os.PathLike] = None,
        target: str = "auto",  # "train" | "eval" | "test" | "auto"
        role_filter: Optional[str] = None,
    ) -> None:
        super().__init__()
        # 新规范：仅支持传入 feature 根目录 root，并在其下查找 json/ 与 npy/
        if root is None:
            raise AssertionError("必须提供 feature 根目录 root（其下包含子目录 npy 与 json）")
        use_json_mode = True

        self.seq_len: int = int(seq_len)
        if predict not in ("current", "next"):
            raise ValueError("predict must be 'current' or 'next'")
        self.predict: str = predict
        self._mmap: bool = bool(mmap)
        self._in_memory: bool = bool(in_memory)

        entries: List[Dict[str, object]] = []
        if use_json_mode:
            # 统一从 root/json 与 root/npy 读取
            npy_base = Path(root)  # type: ignore[arg-type]
            npy_base = npy_base / "npy"
            js_base = Path(root) / "json"
            json_files = sorted(p for p in js_base.glob("*.json"))
            if not json_files:
                raise FileNotFoundError(f"No JSON under {js_base}")
            for jp in json_files:
                base = jp.stem
                meta: Dict[str, object] = {}
                with open(jp, "r", encoding="utf-8") as mf:
                    meta = json.load(mf)
                role = str(meta.get("role", "train")).lower()
                if role_filter and role != role_filter:
                    continue
                # 当 target 指定为 train/eval/test 时，严格过滤到相同 role 的文件
                if target in ("train", "eval", "test") and role != target:
                    continue
                feats_path = npy_base / f"{base}.feats.npy"
                xy_path = npy_base / f"{base}.xy.npy"
                ts_path = npy_base / f"{base}.ts.npy"
                if (not feats_path.exists()) or (not xy_path.exists()):
                    continue
                arr = np.load(feats_path, mmap_mode="r")
                length = int(arr.shape[0]); del arr
                targets = None
                if target == "train":
                    indices = meta.get("indices_train")
                    if isinstance(indices, list) and len(indices) > 0:
                        targets = [int(i) for i in indices]
                elif target == "eval":
                    indices = meta.get("indices_eval")
                    if isinstance(indices, list) and len(indices) > 0:
                        targets = [int(i) for i in indices]
                elif target == "test":
                    indices = meta.get("indices_test", meta.get("indices"))
                    if isinstance(indices, list) and len(indices) > 0:
                        targets = [int(i) for i in indices]
                else:
                    indices = meta.get("indices")
                    if isinstance(indices, list) and len(indices) > 0:
                        targets = [int(i) for i in indices]
                # 指定 target 时，必须存在对应索引，否则跳过该文件，避免退化为全序列抽样
                if target in ("train", "eval", "test") and (not isinstance(targets, list) or len(targets) == 0):
                    continue
                entries.append({
                    "base": base,
                    "feats": str(feats_path),
                    "xy": str(xy_path),
                    "ts": str(ts_path) if ts_path.exists() else None,
                    "length": length,
                    "targets": targets,
                })
            if not entries:
                raise RuntimeError(f"No entries built from JSON at {js_base}")

        self.entries: List[Dict[str, object]] = entries
        self._cache: Dict[int, Dict[str, np.ndarray]] = {}

        # build global index
        self.index: List[Tuple[int, int, int]] = []
        total_frames = 0
        for fi, entry in enumerate(self.entries):
            T = int(entry["length"]) # type: ignore[assignment]
            total_frames += T
            t_list = entry.get("targets")
            if isinstance(t_list, list) and len(t_list) > 0:
                if self.predict == "current":
                    for t in t_list:
                        ti = int(t)
                        if ti >= self.seq_len and ti < T:
                            self.index.append((fi, ti - self.seq_len, ti))
                else:
                    for t in t_list:
                        ti = int(t)
                        if ti >= self.seq_len and (ti + 1) < T:
                            self.index.append((fi, ti - self.seq_len, ti + 1))
            else:
                if self.predict == "current":
                    for t in range(self.seq_len, T):
                        self.index.append((fi, t - self.seq_len, t))
                else:
                    for t in range(self.seq_len, T - 1):
                        self.index.append((fi, t - self.seq_len, t + 1))

        if not self.index:
            raise RuntimeError(
                f"No samples built: files={len(self.entries)}, total_frames={total_frames}, "
                f"seq_len={self.seq_len}, predict={self.predict}"
            )

        # load stats for normalization
        self.stats = None
        stats_roots: List[Path] = []
        if stats_root is not None:
            stats_roots.append(Path(stats_root))
        default_root = Path(self.entries[0]["feats"]).parent # type: ignore[assignment]
        stats_roots += [default_root, default_root.parent, Path(root), Path(root).parent]
        for sr in stats_roots:
            sp = sr / "stats_train.npz"
            if sp.exists():
                try:
                    s = np.load(sp)
                    m = s["feat_mean"].astype(np.float32)
                    sd = s["feat_std"].astype(np.float32)
                    std_floor = float(s["std_floor"]) if "std_floor" in s else 1e-3
                    sd = np.maximum(sd, std_floor).astype(np.float32)
                    self.stats = (m, sd)
                    print(f"[OK] Loaded stats (train): {sp} Din={m.shape[0]}")
                    break
                except Exception as e:
                    print(f"[WARN] fail to load stats from {sp}: {e}")

    def __len__(self) -> int:
        return len(self.index)

    def __getstate__(self):
        state = self.__dict__.copy()
        state["_cache"] = {}
        return state

    def _get_arrays(self, fi: int) -> Dict[str, np.ndarray]:
        cached = self._cache.get(fi)
        if cached is not None:
            return cached
        entry = self.entries[fi]
        feats = np.load(entry["feats"], mmap_mode="r" if self._mmap else None) # type: ignore[assignment]
        xy = np.load(entry["xy"], mmap_mode="r" if self._mmap else None) # type: ignore[assignment]
        ts = None
        ts_path = entry["ts"]
        if ts_path:
            ts = np.load(ts_path, mmap_mode="r" if self._mmap else None) # type: ignore[assignment]
        if self._in_memory:
            feats = np.array(feats, copy=True)
            xy = np.array(xy, copy=True)
            ts = (np.array(ts, copy=True) if ts is not None else None)
        cached = {"feats": feats, "xy": xy, "ts": ts}
        self._cache[fi] = cached
        return cached

    def __getitem__(self, idx: int):
        fi, s, t = self.index[idx]
        data = self._get_arrays(fi)
        feats = data["feats"]
        xy = data["xy"]
        x = np.asarray(feats[s:t], dtype=np.float32)
        y = np.asarray(xy[t], dtype=np.float32)
        if self.stats is not None:
            m, sd = self.stats
            x = (x - m) / sd
        x = np.nan_to_num(x, nan=0.0, posinf=1e6, neginf=-1e6)
        y = np.nan_to_num(y, nan=0.0, posinf=1e6, neginf=-1e6)
        return torch.from_numpy(x), torch.from_numpy(y)[None, :]

    @classmethod
    def from_filelist(
        cls,
        files: Iterable[str | os.PathLike],
        *,
        seq_len: int = 12,
        predict: str = "current",
        mmap: bool = True,
        in_memory: bool = False,
        stats_root: Optional[str | os.PathLike] = None,
        target: str = "auto",
        role_filter: Optional[str] = None,
    ) -> "FramesLazyDataset":
        # 兼容函数：从 feats.npy 列表推断 feature 根目录（要求位于 .../npy 下）
        files = [Path(p) for p in files]
        if not files:
            raise ValueError("empty file list")
        parents = []
        for p in files:
            if p.suffix != ".npy" or not p.name.endswith(".feats.npy"):
                raise ValueError(f"expect *.feats.npy, got {p}")
            if p.parent.name != "npy":
                raise ValueError(f"expect files under .../npy, got {p.parent}")
            parents.append(p.parent.parent)
        # 所有文件应共用同一 feature 根目录
        root = parents[0]
        if any(pr != root for pr in parents):
            raise ValueError("files belong to different feature roots")
        return cls(
            root=str(root),
            seq_len=seq_len,
            predict=predict,
            mmap=mmap,
            in_memory=in_memory,
            stats_root=stats_root,
            target=target,
            role_filter=role_filter,
        )
