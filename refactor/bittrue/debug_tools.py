from __future__ import annotations

import json
from pathlib import Path

import numpy as np


def write_json(path: Path, obj: dict | list) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2), encoding="utf-8")


def read_mem_matrix_rows_q88(path: Path, cols: int = 4) -> np.ndarray:
    rows: list[list[int]] = []
    with open(path, "r", encoding="utf-8") as f:
        for ln in f:
            s = ln.strip()
            if not s:
                continue
            word = int(s, 16)
            row: list[int] = []
            for lane in range(cols):
                v = (word >> (16 * lane)) & 0xFFFF
                if v & 0x8000:
                    v -= 0x10000
                row.append(int(v))
            rows.append(row)
    if not rows:
        return np.zeros((0, cols), dtype=np.int16)
    return np.asarray(rows, dtype=np.int16)

