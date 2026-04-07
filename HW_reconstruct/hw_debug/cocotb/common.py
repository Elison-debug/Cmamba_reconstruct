from __future__ import annotations

import json
import os
from pathlib import Path

import numpy as np


def case_dir() -> Path:
    raw = os.environ.get("CASE_DIR", "")
    if not raw:
        raise RuntimeError("CASE_DIR is not set")
    return Path(raw).resolve()


def stage_name() -> str:
    return os.environ.get("STAGE", "").strip()


def load_stage_manifest() -> dict:
    stg = stage_name()
    if not stg:
        raise RuntimeError("STAGE is not set")
    path = case_dir() / "stages" / stg / "manifest.json"
    return json.loads(path.read_text(encoding="utf-8"))


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def read_mem_hex(path: Path, signed: bool = False, bits: int = 16) -> np.ndarray:
    vals = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        v = int(line, 16)
        if signed and v >= (1 << (bits - 1)):
            v -= (1 << bits)
        vals.append(v)
    return np.asarray(vals)


def read_mem_packed_u16(path: Path, signed: bool = False, lanes: int = 4) -> np.ndarray:
    rows = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        raw = int(line, 16)
        row = []
        for lane in range(lanes):
            v = (raw >> (lane * 16)) & 0xFFFF
            if signed and (v & 0x8000):
                v -= 0x10000
            row.append(v)
        rows.append(row)
    return np.asarray(rows, dtype=np.int32)
