from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np

from refactor.bittrue.export_hw_debug import _export_reuse_top_four_block_chain


def _read_q88_mem(path: Path, cols: int = 4) -> np.ndarray:
    rows: list[list[int]] = []
    with open(path, "r", encoding="utf-8") as f:
        for ln in f:
            s = ln.strip()
            if not s:
                continue
            w = int(s, 16)
            row: list[int] = []
            for lane in range(cols):
                v = (w >> (16 * lane)) & 0xFFFF
                if v & 0x8000:
                    v -= 0x10000
                row.append(int(v))
            rows.append(row)
    return np.asarray(rows, dtype=np.int16)


def main() -> None:
    p = argparse.ArgumentParser(description="Regenerate chain4 batch npy files from exported block mems.")
    p.add_argument("--case_dir", type=str, required=True, help="Case root, e.g. final_hw/cases/c02")
    p.add_argument(
        "--export_json",
        type=str,
        default="",
        help="Optional explicit export json path. Default: <case_dir>/export_ir/export.json",
    )
    p.add_argument("--num_samples", type=int, required=True, help="Number of samples to export into batch npy.")
    p.add_argument("--start_idx", type=int, default=0, help="Starting sample index in float/samples.npy")
    p.add_argument("--max_blocks", type=int, default=4)
    p.add_argument("--progress_every", type=int, default=100)
    args = p.parse_args()

    case_dir = Path(args.case_dir)
    export_json = Path(args.export_json) if args.export_json else (case_dir / "export_ir" / "export.json")
    chain_stage = case_dir / "stages" / "reuse_mamba_block_top_chain4"
    blk3_stage = case_dir / "stages" / "reuse_mamba_block_top_block3"

    if int(args.num_samples) <= 0:
        raise ValueError("--num_samples must be > 0")
    if int(args.start_idx) < 0:
        raise ValueError("--start_idx must be >= 0")
    if not export_json.exists():
        raise FileNotFoundError(f"missing export json: {export_json}")
    if not case_dir.exists():
        raise FileNotFoundError(f"missing case_dir: {case_dir}")

    n = int(args.num_samples)
    start = int(args.start_idx)
    y_batch = np.zeros((n, 32, 4), dtype=np.int16)
    h_batch = np.zeros((n, 32, 4), dtype=np.int16)
    indices = np.arange(start, start + n, dtype=np.int32)

    chain_stage.mkdir(parents=True, exist_ok=True)
    for i, sample_idx in enumerate(indices):
        _export_reuse_top_four_block_chain(
            case_dir=case_dir,
            export_json=export_json,
            sample_idx=int(sample_idx),
            max_blocks=int(args.max_blocks),
        )
        y_batch[i] = _read_q88_mem(chain_stage / "final_y_golden_q88.mem")
        h_batch[i] = _read_q88_mem(blk3_stage / "h_wr_data_s16_q8p8.mem")
        if int(args.progress_every) > 0 and ((i + 1) % int(args.progress_every) == 0):
            print(f"[RTL_out2final] {i + 1}/{n}")

    np.save(chain_stage / "final_y_q88_batch.npy", y_batch)
    np.save(chain_stage / "block3_h_in_q88_batch.npy", h_batch)
    np.save(chain_stage / "batch_indices.npy", indices)
    print(f"[RTL_out2final] saved {n} samples to {chain_stage}")


if __name__ == "__main__":
    main()
