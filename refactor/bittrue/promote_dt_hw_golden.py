from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np

from refactor.bittrue.export_hw_debug import (
    _conv1x1_q88_intmac,
    _mul_q88_q88_to_q88,
    _sigmoid_q016_from_q88,
    _ssm_update_q88_from_lam_q016,
    _write_mem_matrix_rows_q88,
)


def _load_packed_q88(path: Path) -> np.ndarray:
    rows = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        packed = int(line, 16)
        lanes = []
        for lane in range(4):
            v = (packed >> (16 * lane)) & 0xFFFF
            if v & 0x8000:
                v -= 0x10000
            lanes.append(v)
        rows.append(lanes)
    return np.asarray(rows, dtype=np.int16)


def _load_weight_banks_q88(stage_dir: Path, prefix: str, oc: int, ic: int, n_bank: int = 6, tile: int = 4) -> np.ndarray:
    row_tiles = oc // tile
    col_tiles = ic // tile
    weight = np.zeros((oc, ic), dtype=np.int16)
    bank_lines = []
    for bank in range(n_bank):
        path = stage_dir / f"{prefix}_bank{bank}.mem"
        lines = []
        for line in path.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if line:
                lines.append(int(line, 16))
        bank_lines.append(lines)

    for rt in range(row_tiles):
        for ct in range(col_tiles):
            tile_id = rt * col_tiles + ct
            bank = tile_id % n_bank
            addr = tile_id // n_bank
            packed = bank_lines[bank][addr]
            vals = []
            for idx in range(tile * tile):
                v = (packed >> (16 * idx)) & 0xFFFF
                if v & 0x8000:
                    v -= 0x10000
                vals.append(v)
            tile_mat = np.asarray(vals, dtype=np.int16).reshape(tile, tile)
            weight[rt * tile : (rt + 1) * tile, ct * tile : (ct + 1) * tile] = tile_mat
    return weight


def main() -> None:
    p = argparse.ArgumentParser(description="Promote standalone dt RTL outputs into top-level hw_debug goldens.")
    p.add_argument("--case_dir", required=True, help="HW_reconstruct/hw_debug/cases/<case_name>")
    p.add_argument("--replace_top", action="store_true", help="Overwrite top-stage dt/lam/ssm/gate_y default golden names")
    args = p.parse_args()

    case_dir = Path(args.case_dir)
    dt_rtl_dir = case_dir / "rtl_out" / "reuse_ssm_dt_scheduler"
    top_dir = case_dir / "stages" / "reuse_mamba_block_top"
    dt_stage_dir = case_dir / "stages" / "reuse_ssm_dt_scheduler"

    dt_rtl = _load_packed_q88(dt_rtl_dir / "dt_rtl_q88.mem")
    xt_rtl = _load_packed_q88(dt_rtl_dir / "xt_rtl_q88.mem")
    z_silu = _load_packed_q88(top_dir / "z_silu_golden_q88.mem")
    outproj_w_q88 = _load_weight_banks_q88(top_dir, "outproj_wbuf", oc=128, ic=256)

    lam_q016 = _sigmoid_q016_from_q88(dt_rtl)
    ssm_q88 = _ssm_update_q88_from_lam_q016(lam_q016, xt_rtl)
    gate_y_q88 = _mul_q88_q88_to_q88(z_silu, ssm_q88)
    y_q88 = _conv1x1_q88_intmac(outproj_w_q88.astype(np.float32) / 256.0, gate_y_q88.reshape(-1)).reshape(32, 4)

    _write_mem_matrix_rows_q88(dt_stage_dir / "dt_hw_golden_q88.mem", dt_rtl)
    _write_mem_matrix_rows_q88(dt_stage_dir / "xt_hw_golden_q88.mem", xt_rtl)
    _write_mem_matrix_rows_q88(top_dir / "dt_hw_golden_q88.mem", dt_rtl)
    _write_mem_matrix_rows_q88(top_dir / "xt_hw_golden_q88.mem", xt_rtl)
    _write_mem_matrix_rows_q88(top_dir / "lam_hw_golden_q016.mem", lam_q016.astype(np.uint16))
    _write_mem_matrix_rows_q88(top_dir / "ssm_hw_golden_q88.mem", ssm_q88)
    _write_mem_matrix_rows_q88(top_dir / "gate_y_hw_golden_q88.mem", gate_y_q88)
    _write_mem_matrix_rows_q88(top_dir / "y_hw_golden_q88.mem", y_q88)

    if args.replace_top:
        _write_mem_matrix_rows_q88(top_dir / "dt_golden_q88.mem", dt_rtl)
        _write_mem_matrix_rows_q88(top_dir / "lam_golden_q016.mem", lam_q016.astype(np.uint16))
        _write_mem_matrix_rows_q88(top_dir / "ssm_golden_q88.mem", ssm_q88)
        _write_mem_matrix_rows_q88(top_dir / "gate_y_golden_q88.mem", gate_y_q88)
        _write_mem_matrix_rows_q88(top_dir / "y_golden_q88.mem", y_q88)

    print(f"[promote_dt_hw_golden] wrote hardware-derived golden files under {top_dir}")


if __name__ == "__main__":
    main()
