from __future__ import annotations

import argparse
import json
import shutil
import subprocess
from pathlib import Path

import numpy as np
import torch
from torch.utils.data import DataLoader

from refactor.bittrue.debug_tools import write_json
from refactor.bittrue.eval_bittrue import _arch_from_ckpt, _build_model, _cfg_from_ckpt, _load_or_prepare_float_cache
from refactor.bittrue.pack import export_minimal
from refactor.core.train import TrainConfig, set_seed
from refactor.datasets.frames_lazy import FramesLazyDataset

def _write_json(path: Path, obj: dict | list) -> None:
    write_json(path, obj)

def _export_vivado_ip_init_assets(case_dir: Path, export_dir: Path, block_index: int = 0) -> dict:
    repo_root = Path(__file__).resolve().parents[2]
    script = repo_root / "HW_reconstruct" / "tools" / "make_vivado_ip_init.py"
    out_dir = case_dir / "ip_init" / f"block{int(block_index)}"
    out_dir.mkdir(parents=True, exist_ok=True)
    if not script.exists():
        return {"generated": False, "reason": f"script not found: {script}"}
    cmd = [
        "python",
        str(script),
        "--repo-root",
        str(repo_root),
        "--case-dir",
        str(case_dir),
        "--export-dir",
        str(export_dir),
        "--block-index",
        str(int(block_index)),
        "--out-dir",
        str(out_dir),
    ]
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as exc:
        return {"generated": False, "reason": f"ip-init export failed: {exc}"}
    manifest = out_dir / "manifest.json"
    return {
        "generated": True,
        "block_index": int(block_index),
        "out_dir": str(out_dir.resolve()),
        "manifest": str(manifest.resolve()) if manifest.exists() else "",
    }

def _to_u16(v: int) -> int:
    return int(v) & 0xFFFF

def _pack_lanes_u16(vals: list[int]) -> int:
    acc = 0
    for lane, v in enumerate(vals):
        acc |= (_to_u16(v) << (16 * lane))
    return acc

def _write_mem_packed_u16(path: Path, rows: list[list[int]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        for row in rows:
            f.write(f"{_pack_lanes_u16(row):016X}\n")

def _write_mem_u16_scalar(path: Path, vals: list[int], width_hex: int = 4) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        for v in vals:
            f.write(f"{int(v) & ((1 << (4 * width_hex)) - 1):0{width_hex}X}\n")

class _ActLut:
    def __init__(self, a: float = -8.0, b: float = 8.0, n: int = 4096):
        self.xmin = float(a)
        self.xmax = float(b)
        self.n = int(n)
        xs = np.linspace(self.xmin, self.xmax, self.n, dtype=np.float32)
        sig = 1.0 / (1.0 + np.exp(-xs.astype(np.float64)))
        self.sig = sig.astype(np.float32)
        self.silu = (xs.astype(np.float64) * sig).astype(np.float32)

    def _interp(self, table: np.ndarray, x: np.ndarray) -> np.ndarray:
        xc = np.clip(x.astype(np.float32), self.xmin, self.xmax)
        t = (xc - self.xmin) / (self.xmax - self.xmin)
        idx = t * float(self.n - 1)
        i = np.floor(idx).astype(np.int32)
        i = np.clip(i, 0, self.n - 2)
        u = idx - i.astype(np.float32)
        return table[i] * (1.0 - u) + table[i + 1] * u

    def sigmoid(self, x: np.ndarray) -> np.ndarray:
        return self._interp(self.sig, x)

    def silu_fn(self, x: np.ndarray) -> np.ndarray:
        return self._interp(self.silu, x)

def _load_export_ir(export_json: Path) -> tuple[dict, dict, Path]:
    export = json.loads(export_json.read_text(encoding="utf-8"))
    base_dir = export_json.parent
    backbone = json.loads((base_dir / export["backbone"]["file"]).read_text(encoding="utf-8"))
    return export, backbone, base_dir

def _quant_q88(x: np.ndarray) -> np.ndarray:
    q = np.rint(x.astype(np.float64) * 256.0).astype(np.int64)
    q = np.clip(q, -32768, 32767).astype(np.int16)
    return q

def _write_mem_matrix_rows_q88(path: Path, mat_2d: np.ndarray, tile: int = 4) -> None:
    rows = []
    for i in range(mat_2d.shape[0]):
        row = np.asarray(mat_2d[i]).reshape(-1)
        if row.shape[0] != tile:
            raise ValueError(f"expected row width {tile}, got {row.shape[0]} for {path}")
        rows.append([int(v) & 0xFFFF for v in row.tolist()])
    _write_mem_packed_u16(path, rows)

def _write_scale_rows_q15(path: Path, scale_q15: np.ndarray, tile: int = 4) -> None:
    rows = []
    vec = np.asarray(scale_q15).reshape(-1)
    if vec.shape[0] % tile != 0:
        raise ValueError(f"expected scale vector multiple of {tile}, got {vec.shape[0]}")
    for i in range(0, vec.shape[0], tile):
        rows.append([int(v) & 0xFFFF for v in vec[i : i + tile].tolist()])
    _write_mem_packed_u16(path, rows)

def _write_scale_rows_q16_32(path: Path, scale_q16: np.ndarray, tile: int = 4) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    vec = np.asarray(scale_q16).reshape(-1)
    if vec.shape[0] % tile != 0:
        raise ValueError(f"expected scale vector multiple of {tile}, got {vec.shape[0]}")
    with open(path, "w", encoding="utf-8") as f:
        for i in range(0, vec.shape[0], tile):
            packed = 0
            for lane, v in enumerate(vec[i : i + tile].tolist()):
                packed |= (int(v) & 0xFFFFFFFF) << (32 * lane)
            f.write(f"{packed:032X}\n")

def _write_weight_banks_q88_aligned_4array(
    path_prefix: Path,
    weight_oc_ic: np.ndarray,
    n_bank: int = 6,
    depth: int = 1024,
    tile: int = 4,
) -> list[str]:
    """
    4-array-aligned bank layout shared by in_proj / dt_proj / out_proj.

    Mapping:
      - Array a in {0,1,2,3} always reads bank=a
      - One scheduler transaction computes one output row tile rt
      - Within that transaction, group g in [0, groups-1] reads:
          bank=a, addr=rt*groups + g  -> tile(rt, g*4 + a)
      - Banks 4 and 5 are left zero-filled for compatibility with existing
        6-bank wrappers / TB infrastructure.
    """
    oc, ic = weight_oc_ic.shape
    row_tiles = oc // tile
    col_tiles = ic // tile
    if col_tiles % 4 != 0:
        raise RuntimeError(f"dt aligned layout expects col_tiles divisible by 4, got {col_tiles}")
    groups = col_tiles // 4
    required_depth = row_tiles * groups
    if required_depth > depth:
        raise RuntimeError(
            f"dt aligned layout depth too small: need {required_depth}, got {depth}"
        )

    bank_lines = [[0 for _ in range(depth)] for _ in range(n_bank)]
    q = _quant_q88(weight_oc_ic)
    for rt in range(row_tiles):
        for g in range(groups):
            addr = rt * groups + g
            for a in range(4):
                ct = g * 4 + a
                tile_mat = q[rt * tile : (rt + 1) * tile, ct * tile : (ct + 1) * tile]
                vals: list[int] = []
                for r in range(tile):
                    for c in range(tile):
                        vals.append(int(tile_mat[r, c]) & 0xFFFF)
                packed = 0
                for idx, v in enumerate(vals):
                    packed |= (v & 0xFFFF) << (16 * idx)
                bank_lines[a][addr] = packed

    files = []
    for b in range(n_bank):
        name = f"{path_prefix.name}_bank{b}.mem"
        fpath = path_prefix.parent / name
        with open(fpath, "w", encoding="utf-8") as f:
            for line in bank_lines[b]:
                f.write(f"{line:064X}\n")
        files.append(name)
    return files

def _export_chain4_stream_golden(
    case_dir: Path,
    export_json: Path,
    n_frames: int = 3,
    continuous_state: bool = False,
    source_mode: str = "real_samples",
    workers: int = 0,
    progress_every: int = 100,
) -> dict:
    from refactor.bittrue.hw_like_chain4 import (
        build_chain4_ctx,
        block_step_hw_q88_trace,
        collect_chain4_triplets_continuous,
        collect_chain4_triplets_parallel,
        compute_chain4_trace_from_sample,
    )

    samples_npy = case_dir / "float" / "samples.npy"
    if not samples_npy.exists():
        return {"generated": False, "reason": f"missing samples cache: {samples_npy}"}
    samples = np.load(samples_npy).astype(np.float32)
    if samples.shape[0] <= 0:
        return {"generated": False, "reason": "samples cache is empty"}

    n_frames_i = max(1, int(n_frames))
    if str(source_mode) == "real_samples":
        if int(samples.shape[0]) < n_frames_i:
            return {
                "generated": False,
                "reason": f"not enough real samples for stream export: need={n_frames_i}, have={samples.shape[0]}",
            }
        samples_eval = samples[:n_frames_i]
    else:
        samples_eval = np.repeat(samples[:1], n_frames_i, axis=0)

    worker_n = int(workers) if int(workers) > 0 else max(1, int((__import__("os").cpu_count()) or 1))
    if bool(continuous_state):
        h0_batch, h_batch, y_batch = collect_chain4_triplets_continuous(
            export_json=export_json,
            case_dir=case_dir,
            samples_eval=samples_eval,
            scan_mode="scaled_state",
            progress_every=int(progress_every),
        )
    else:
        h0_batch, h_batch, y_batch = collect_chain4_triplets_parallel(
            export_json=export_json,
            case_dir=case_dir,
            samples_eval=samples_eval,
            workers=worker_n,
            scan_mode="scaled_state",
            progress_every=int(progress_every),
        )

    chain_dir = case_dir / "stages" / "reuse_mamba_block_top_chain4"
    chain_dir.mkdir(parents=True, exist_ok=True)
    dbg_dir = chain_dir / "stream_debug"
    dbg_dir.mkdir(parents=True, exist_ok=True)

    y_stream_rows: list[list[int]] = []
    b0_y_stream_rows: list[list[int]] = []
    h_stream_rows: list[list[int]] = []
    b1_h_stream_rows: list[list[int]] = []
    b2_h_stream_rows: list[list[int]] = []
    b3_h_stream_rows: list[list[int]] = []
    b0_hnorm_stream_rows: list[list[int]] = []
    b0_u_stream_rows: list[list[int]] = []
    b0_z_stream_rows: list[list[int]] = []
    b0_zsilu_stream_rows: list[list[int]] = []
    b0_dt_stream_rows: list[list[int]] = []
    b0_ssm_stream_rows: list[list[int]] = []
    b0_gate_stream_rows: list[list[int]] = []
    debug_files: list[str] = []
    trace_ctx = build_chain4_ctx(export_json=export_json, case_dir=case_dir)
    b0_runtime: dict | None = {"state_runtime": None} if bool(continuous_state) else None
    for fi in range(int(n_frames_i)):
        h_raw_q88 = h0_batch[fi].astype(np.int16)
        y_blk3 = y_batch[fi].astype(np.int16)
        h_blk3 = h_batch[fi].astype(np.int16)
        h_inputs_trace, _ = compute_chain4_trace_from_sample(
            trace_ctx,
            samples_eval[fi],
            scan_mode="scaled_state",
            runtimes=None,
        )
        b0_trace = block_step_hw_q88_trace(
            blk_cache=trace_ctx["blocks"][0],
            h_in_q88=h_inputs_trace[0].reshape(-1),
            scan_mode="scaled_state",
            runtime=b0_runtime if bool(continuous_state) else None,
        )
        for r in range(32):
            h_stream_rows.append([int(v) & 0xFFFF for v in h_raw_q88[r].tolist()])
            b1_h_stream_rows.append([int(v) & 0xFFFF for v in h_inputs_trace[1, r].tolist()])
            b2_h_stream_rows.append([int(v) & 0xFFFF for v in h_inputs_trace[2, r].tolist()])
            b3_h_stream_rows.append([int(v) & 0xFFFF for v in h_inputs_trace[3, r].tolist()])
            b0_hnorm_stream_rows.append([int(v) & 0xFFFF for v in b0_trace["h_norm_q88"][r].tolist()])
            b0_y_stream_rows.append([int(v) & 0xFFFF for v in b0_trace["y_q88"][r].tolist()])
        for r in range(32):
            y_stream_rows.append([int(v) & 0xFFFF for v in y_blk3[r].tolist()])
        for r in range(64):
            b0_u_stream_rows.append([int(v) & 0xFFFF for v in b0_trace["u_q88_rows"][r].tolist()])
            b0_z_stream_rows.append([int(v) & 0xFFFF for v in b0_trace["z_q88_rows"][r].tolist()])
            b0_zsilu_stream_rows.append([int(v) & 0xFFFF for v in b0_trace["z_silu_q88"][r].tolist()])
            b0_dt_stream_rows.append([int(v) & 0xFFFF for v in b0_trace["dt_q88_mac"][r].tolist()])
            b0_ssm_stream_rows.append([int(v) & 0xFFFF for v in b0_trace["ssm_q88"][r].tolist()])
            b0_gate_stream_rows.append([int(v) & 0xFFFF for v in b0_trace["gate_y_q88"][r].tolist()])
        fn_h_raw = f"stream_debug/frame{fi:02d}_h_in_raw_q88.mem"
        fn_h_in = f"stream_debug/frame{fi:02d}_block3_h_in_q88.mem"
        fn_out = f"stream_debug/frame{fi:02d}_block3_outproj_y_q88.mem"
        _write_mem_matrix_rows_q88(chain_dir / fn_h_raw, h_raw_q88)
        _write_mem_matrix_rows_q88(chain_dir / fn_h_in, h_blk3)
        _write_mem_matrix_rows_q88(chain_dir / fn_out, y_blk3)
        debug_files.extend([fn_h_raw, fn_h_in, fn_out])

    mode_tag = "continuous" if bool(continuous_state) else "stateless"
    in_mem_name = f"stream_h_input_{mode_tag}_q88.mem"
    b0_y_mem_name = f"stream_block0_y_{mode_tag}_q88.mem"
    b0_hnorm_mem_name = f"stream_block0_h_norm_{mode_tag}_q88.mem"
    b0_u_mem_name = f"stream_block0_u_{mode_tag}_q88.mem"
    b0_z_mem_name = f"stream_block0_z_{mode_tag}_q88.mem"
    b0_zsilu_mem_name = f"stream_block0_z_silu_{mode_tag}_q88.mem"
    b0_dt_mem_name = f"stream_block0_dt_{mode_tag}_q88.mem"
    b0_ssm_mem_name = f"stream_block0_ssm_{mode_tag}_q88.mem"
    b0_gate_mem_name = f"stream_block0_gate_y_{mode_tag}_q88.mem"
    b1_in_mem_name = f"stream_block1_h_in_{mode_tag}_q88.mem"
    b2_in_mem_name = f"stream_block2_h_in_{mode_tag}_q88.mem"
    b3_in_mem_name = f"stream_block3_h_in_{mode_tag}_q88.mem"
    out_mem_name = f"stream_y_golden_{mode_tag}_q88.mem"
    manifest_name = f"stream_manifest_{mode_tag}.json"
    in_mem = chain_dir / in_mem_name
    b0_y_mem = chain_dir / b0_y_mem_name
    b0_hnorm_mem = chain_dir / b0_hnorm_mem_name
    b0_u_mem = chain_dir / b0_u_mem_name
    b0_z_mem = chain_dir / b0_z_mem_name
    b0_zsilu_mem = chain_dir / b0_zsilu_mem_name
    b0_dt_mem = chain_dir / b0_dt_mem_name
    b0_ssm_mem = chain_dir / b0_ssm_mem_name
    b0_gate_mem = chain_dir / b0_gate_mem_name
    b1_in_mem = chain_dir / b1_in_mem_name
    b2_in_mem = chain_dir / b2_in_mem_name
    b3_in_mem = chain_dir / b3_in_mem_name
    out_mem = chain_dir / out_mem_name
    _write_mem_packed_u16(in_mem, h_stream_rows)
    _write_mem_packed_u16(b0_y_mem, b0_y_stream_rows)
    _write_mem_packed_u16(b0_hnorm_mem, b0_hnorm_stream_rows)
    _write_mem_packed_u16(b0_u_mem, b0_u_stream_rows)
    _write_mem_packed_u16(b0_z_mem, b0_z_stream_rows)
    _write_mem_packed_u16(b0_zsilu_mem, b0_zsilu_stream_rows)
    _write_mem_packed_u16(b0_dt_mem, b0_dt_stream_rows)
    _write_mem_packed_u16(b0_ssm_mem, b0_ssm_stream_rows)
    _write_mem_packed_u16(b0_gate_mem, b0_gate_stream_rows)
    _write_mem_packed_u16(b1_in_mem, b1_h_stream_rows)
    _write_mem_packed_u16(b2_in_mem, b2_h_stream_rows)
    _write_mem_packed_u16(
        b3_in_mem,
        b3_h_stream_rows,
    )
    _write_mem_packed_u16(out_mem, y_stream_rows)
    _write_json(
        chain_dir / manifest_name,
        {
            "generated": True,
            "n_frames": int(n_frames_i),
            "continuous_state": bool(continuous_state),
            "source_mode": str(source_mode),
            "rows_per_frame": 32,
            "input_file": in_mem_name,
            "block0_y_file": b0_y_mem_name,
            "block0_h_norm_file": b0_hnorm_mem_name,
            "block0_u_file": b0_u_mem_name,
            "block0_z_file": b0_z_mem_name,
            "block0_z_silu_file": b0_zsilu_mem_name,
            "block0_dt_file": b0_dt_mem_name,
            "block0_ssm_file": b0_ssm_mem_name,
            "block0_gate_file": b0_gate_mem_name,
            "block1_input_file": b1_in_mem_name,
            "block2_input_file": b2_in_mem_name,
            "block3_input_file": b3_in_mem_name,
            "file": out_mem_name,
            "notes": [
                "Stream golden for board-shell stream mode.",
                (
                    "Frames use real per-sample inputs from float/samples.npy."
                    if str(source_mode) == "real_samples"
                    else "Frames repeat the first sample input."
                ),
                (
                    "EW state is carried across frames." if bool(continuous_state) else "EW state is reset at each frame boundary."
                ),
            ],
            "debug_files": debug_files,
        },
    )
    return {
        "generated": True,
        "n_frames": int(n_frames_i),
        "continuous_state": bool(continuous_state),
        "source_mode": str(source_mode),
        "input_file": in_mem_name,
        "block0_y_file": b0_y_mem_name,
        "block0_h_norm_file": b0_hnorm_mem_name,
        "block0_u_file": b0_u_mem_name,
        "block0_z_file": b0_z_mem_name,
        "block0_z_silu_file": b0_zsilu_mem_name,
        "block0_dt_file": b0_dt_mem_name,
        "block0_ssm_file": b0_ssm_mem_name,
        "block0_gate_file": b0_gate_mem_name,
        "block1_input_file": b1_in_mem_name,
        "block2_input_file": b2_in_mem_name,
        "block3_input_file": b3_in_mem_name,
        "file": out_mem_name,
        "manifest": manifest_name,
        "debug_files": debug_files,
    }

def _export_reuse_top_block_from_ir(
    stage_dir: Path,
    blk_cache: dict,
    h_in_f32: np.ndarray,
) -> dict:
    from refactor.bittrue.hw_like_chain4 import block_step_hw_q88_trace

    blk_desc = blk_cache["desc"]
    d_model = int(blk_desc["d_model"])
    inner = int(blk_desc["d_inner"])
    h_in = h_in_f32.astype(np.float32).reshape(-1)
    if h_in.shape[0] != d_model:
        raise ValueError(f"block input shape mismatch: expected {d_model}, got {h_in.shape[0]}")

    h_raw_q88 = _quant_q88(h_in).reshape(32, 4)
    trace = block_step_hw_q88_trace(
        blk_cache=blk_cache,
        h_in_q88=h_raw_q88.reshape(-1),
        scan_mode="scaled_state",
        runtime=None,
    )

    inproj_w = blk_cache["in_w"]
    dtproj_w = blk_cache["dt_w"]
    outproj_w = blk_cache["out_w"]
    dt_bias = blk_cache.get("dt_bias")
    dt_bias_q88 = np.zeros((64, 4), dtype=np.int16)
    if dt_bias is not None:
        dt_bias_q88 = _quant_q88(np.asarray(dt_bias, dtype=np.float32)).reshape(64, 4)

    inproj_scale_q15 = np.full((inproj_w.shape[0],), 1 << 15, dtype=np.uint16)
    dt_scale_q15 = np.full((dtproj_w.shape[0],), 1 << 15, dtype=np.uint16)
    outproj_scale_q15 = np.full((outproj_w.shape[0],), 1 << 15, dtype=np.uint16)
    inproj_w_fold_q88 = _quant_q88(inproj_w)
    dt_w_fold_q88 = _quant_q88(dtproj_w)
    outproj_w_fold_q88 = _quant_q88(outproj_w)

    _write_mem_u16_scalar(stage_dir / "h_wr_addr.mem", list(range(32)), width_hex=2)
    _write_mem_matrix_rows_q88(stage_dir / "h_wr_data_s16_q8p8.mem", trace["h_raw_q88"])
    _write_mem_matrix_rows_q88(stage_dir / "h_norm_golden_s16_q8p8.mem", trace["h_norm_q88"])
    _write_mem_matrix_rows_q88(stage_dir / "norm_gamma_s16_q8p8.mem", blk_cache["norm_gamma_q88"].reshape(32, 4))
    _write_mem_u16_scalar(stage_dir / "norm_rms_s16_q8p8.mem", [int(trace["rms_q88"])], width_hex=4)
    _write_mem_matrix_rows_q88(stage_dir / "u_golden_q88.mem", trace["u_q88_rows"])
    _write_mem_matrix_rows_q88(stage_dir / "z_golden_q88.mem", trace["z_q88_rows"])
    _write_mem_matrix_rows_q88(stage_dir / "u_act_golden_q88.mem", trace["u_act_q88"])
    _write_mem_matrix_rows_q88(stage_dir / "z_silu_golden_q88.mem", trace["z_silu_q88"])
    _write_mem_matrix_rows_q88(stage_dir / "dt_golden_q88.mem", trace["dt_q88_mac"])
    _write_mem_matrix_rows_q88(stage_dir / "bias_ROM.mem", dt_bias_q88)
    _write_mem_matrix_rows_q88(stage_dir / "lam_golden_q016.mem", trace["lam_q016"])
    _write_mem_matrix_rows_q88(stage_dir / "ssm_golden_q88.mem", trace["ssm_q88"])
    _write_mem_matrix_rows_q88(stage_dir / "gate_y_golden_q88.mem", trace["gate_y_q88"])
    _write_mem_matrix_rows_q88(stage_dir / "y_golden_q88.mem", trace["y_q88"])
    _write_mem_matrix_rows_q88(stage_dir / "x_next_golden_q88.mem", trace["x_next_q88"])
    _write_scale_rows_q15(stage_dir / "inproj_scale_q15.mem", inproj_scale_q15)
    _write_scale_rows_q15(stage_dir / "dt_scale_q15.mem", dt_scale_q15)
    _write_scale_rows_q15(stage_dir / "outproj_scale_q15.mem", outproj_scale_q15)
    _write_scale_rows_q16_32(stage_dir / "state_u_to_state_q16.mem", trace["u_to_state_q16"])
    _write_scale_rows_q16_32(stage_dir / "state_to_q88_q16.mem", trace["state_to_q88_q16"])

    inproj_files = _write_weight_banks_q88_aligned_4array(
        stage_dir / "inproj_wbuf", inproj_w_fold_q88.astype(np.float32) / 256.0, n_bank=6, depth=1024
    )
    dt_files = _write_weight_banks_q88_aligned_4array(
        stage_dir / "dt_wbuf", dt_w_fold_q88.astype(np.float32) / 256.0, n_bank=6, depth=1024
    )
    outproj_files = _write_weight_banks_q88_aligned_4array(
        stage_dir / "outproj_wbuf", outproj_w_fold_q88.astype(np.float32) / 256.0, n_bank=6, depth=512
    )

    _write_json(
        stage_dir / "control.json",
        {
            "block_auto_mode": 1,
            "block_start_pulse_cycles": 1,
            "h_depth": 32,
            "u_depth": 64,
            "notes": [
                "Per-block export from export_json IR with hw-like integer math.",
                "h_wr_data is pre-norm block input in Q8.8.",
                "y_golden_q88 is block-local out_proj output.",
                "RMSNorm hardware-like mode: exact_recip30 (fixed).",
                "x_next_golden_q88 = clamp(h_wr_data + y_golden), used as next-block input.",
            ],
        },
    )
    _write_json(
        stage_dir / "vectors.json",
        {
            "d_model": d_model,
            "d_inner": inner,
            "files": {
                "h_wr_addr": "h_wr_addr.mem",
                "h_wr_data_s16_q8p8": "h_wr_data_s16_q8p8.mem",
                "h_norm_golden_s16_q8p8": "h_norm_golden_s16_q8p8.mem",
                "norm_gamma_s16_q8p8": "norm_gamma_s16_q8p8.mem",
                "norm_rms_s16_q8p8": "norm_rms_s16_q8p8.mem",
                "u_golden_q88": "u_golden_q88.mem",
                "z_golden_q88": "z_golden_q88.mem",
                "u_act_golden_q88": "u_act_golden_q88.mem",
                "z_silu_golden_q88": "z_silu_golden_q88.mem",
                "dt_golden_q88": "dt_golden_q88.mem",
                "bias_ROM": "bias_ROM.mem",
                "lam_golden_q016": "lam_golden_q016.mem",
                "ssm_golden_q88": "ssm_golden_q88.mem",
                "gate_y_golden_q88": "gate_y_golden_q88.mem",
                "y_golden_q88": "y_golden_q88.mem",
                "x_next_golden_q88": "x_next_golden_q88.mem",
                "inproj_scale_q15": "inproj_scale_q15.mem",
                "dt_scale_q15": "dt_scale_q15.mem",
                "outproj_scale_q15": "outproj_scale_q15.mem",
                "state_u_to_state_q16": "state_u_to_state_q16.mem",
                "state_to_q88_q16": "state_to_q88_q16.mem",
                "inproj_wbuf": inproj_files,
                "dt_wbuf": dt_files,
                "outproj_wbuf": outproj_files,
            },
        },
    )
    return {
        "x_next_f32": trace["x_next_q88"].astype(np.float32).reshape(-1) / 256.0,
        "files": [
            "h_wr_addr.mem",
            "h_wr_data_s16_q8p8.mem",
            "h_norm_golden_s16_q8p8.mem",
            "norm_gamma_s16_q8p8.mem",
            "norm_rms_s16_q8p8.mem",
            "u_golden_q88.mem",
            "z_golden_q88.mem",
            "u_act_golden_q88.mem",
            "z_silu_golden_q88.mem",
            "dt_golden_q88.mem",
            "bias_ROM.mem",
            "lam_golden_q016.mem",
            "ssm_golden_q88.mem",
            "gate_y_golden_q88.mem",
            "y_golden_q88.mem",
            "x_next_golden_q88.mem",
            "state_u_to_state_q16.mem",
            "state_to_q88_q16.mem",
            "control.json",
            "vectors.json",
            *inproj_files,
            *dt_files,
            *outproj_files,
        ],
    }

def _export_reuse_top_four_block_chain(
    case_dir: Path,
    export_json: Path,
    sample_idx: int = 0,
    max_blocks: int = 4,
) -> dict:
    from refactor.bittrue.hw_like_chain4 import build_chain4_ctx, compute_chain4_trace_from_sample

    samples = case_dir / "float" / "samples.npy"
    if not samples.exists():
        return {"generated": False, "reason": "float/samples.npy missing"}

    x_arr = np.load(samples).astype(np.float32)
    if x_arr.shape[0] <= int(sample_idx):
        return {"generated": False, "reason": f"sample_idx {sample_idx} out of range"}

    _, backbone, _base_dir = _load_export_ir(export_json)
    blocks = backbone.get("blocks", [])
    n_block = min(int(max_blocks), len(blocks))
    if n_block <= 0:
        return {"generated": False, "reason": "no blocks in backbone export"}

    ctx = build_chain4_ctx(export_json=export_json, case_dir=case_dir)
    h_inputs, _y_outputs = compute_chain4_trace_from_sample(
        ctx=ctx,
        sample_kd=x_arr[int(sample_idx)],
        scan_mode="scaled_state",
        runtimes=None,
    )
    x_in = (h_inputs[0].astype(np.float32).reshape(-1) / 256.0).astype(np.float32)
    block_manifests = []
    last_stage_dir: Path | None = None
    for bi in range(n_block):
        stage_name = f"reuse_mamba_block_top_block{bi}"
        stage_dir = case_dir / "stages" / stage_name
        stage_dir.mkdir(parents=True, exist_ok=True)
        block_out = _export_reuse_top_block_from_ir(stage_dir, ctx["blocks"][bi], x_in)
        x_in = block_out["x_next_f32"]
        last_stage_dir = stage_dir
        block_manifests.append(
            {
                "block_index": bi,
                "stage": stage_name,
                "generated": True,
                "files": block_out["files"],
            }
        )

    chain_dir = case_dir / "stages" / "reuse_mamba_block_top_chain4"
    chain_dir.mkdir(parents=True, exist_ok=True)
    if last_stage_dir is None:
        return {"generated": False, "reason": "missing final block y rows"}

    shutil.copyfile(last_stage_dir / "y_golden_q88.mem", chain_dir / "final_y_golden_q88.mem")
    _write_json(
        chain_dir / "manifest.json",
        {
            "generated": True,
            "num_blocks": n_block,
            "source_sample": int(sample_idx),
            "final_y_file": "final_y_golden_q88.mem",
            "block_stages": [m["stage"] for m in block_manifests],
        },
    )
    return {
        "generated": True,
        "num_blocks": n_block,
        "block_manifests": block_manifests,
        "chain_stage": "reuse_mamba_block_top_chain4",
        "chain_files": ["final_y_golden_q88.mem", "manifest.json"],
    }

def main() -> None:
    p = argparse.ArgumentParser(description="Prepare a hardware-debug package for cocotb/TB verification.")
    p.add_argument("--ckpt", type=str, default="refactor/bittrue/reference.pt")
    p.add_argument("--feat_root", type=str, default="./data/features/parity_2100")
    p.add_argument("--target", type=str, default="test", choices=["auto", "train", "eval", "test"])
    p.add_argument("--export_dir", type=str, default="export_bittrue/case1")
    p.add_argument("--out_dir", type=str, required=True, help="HW_reconstruct/hw_debug/cases/<case_name>")
    p.add_argument("--batch_size", type=int, default=64)
    p.add_argument("--workers", type=int, default=0)
    p.add_argument("--limit", type=int, default=0)
    p.add_argument("--preload", action="store_true")
    p.add_argument(
        "--chain4_stream_frames",
        type=int,
        default=3,
        help="Number of frames to export for chain4 stream golden mem.",
    )
    p.add_argument(
        "--chain4_stream_continuous_state",
        action="store_true",
        help="Carry EW state across exported stream frames (default: off, reset state every frame).",
    )
    p.add_argument(
        "--chain4_stream_source",
        type=str,
        default="real_samples",
        choices=["real_samples", "repeat_first_sample"],
        help="Source frames for chain4 stream export: real sample sequence or repeated first sample.",
    )
    p.add_argument(
        "--float_cache_dir",
        type=str,
        default="",
        help="Reuse existing float cache dir containing samples.npy/y_true.npy/y_float.npy/cache_meta.json",
    )
    p.add_argument("--skip_ip_init", action="store_true", help="Do not generate Vivado IP init .mem/.coe files")
    args = p.parse_args()

    set_seed(42)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    ckpt = torch.load(args.ckpt, map_location="cpu")
    ckpt_cfg = _cfg_from_ckpt(ckpt)
    ckpt_arch = _arch_from_ckpt(ckpt)
    model = _build_model(ckpt_cfg, ckpt_arch)
    state_dict = ckpt.get("state_dict", ckpt)
    if not isinstance(state_dict, dict):
        raise TypeError("checkpoint does not contain a usable state_dict")
    model.load_state_dict(state_dict, strict=False)
    model.to(device)
    model.eval()

    export_dir = Path(args.export_dir)
    export_dir.mkdir(parents=True, exist_ok=True)
    export_json = export_minimal(model.cpu(), str(export_dir))
    model.to(device)

    cfg = TrainConfig(
        Din=int(ckpt_cfg["Din"]),
        K=int(ckpt_cfg["K"]),
        proj_dim=int(ckpt_cfg["proj_dim"]),
        d_model=int(ckpt_cfg["d_model"]),
        n_layer=int(ckpt_cfg["n_layer"]),
        patch_len=int(ckpt_cfg["patch_len"]),
        stride=int(ckpt_cfg["stride"]),
        batch_size=args.batch_size,
        feat_root=args.feat_root,
    )
    ds = FramesLazyDataset(
        root=args.feat_root,
        seq_len=cfg.K,
        predict="current",
        mmap=True,
        target=args.target,
        in_memory=bool(args.preload),
    )
    dl = DataLoader(
        ds,
        batch_size=args.batch_size,
        shuffle=False,
        num_workers=int(args.workers),
        pin_memory=True,
        persistent_workers=(int(args.workers) > 0),
        prefetch_factor=(2 if int(args.workers) > 0 else None),
    )

    out_dir = Path(args.out_dir)
    if args.float_cache_dir:
        src_float = Path(args.float_cache_dir)
        dst_float = out_dir / "float"
        dst_float.mkdir(parents=True, exist_ok=True)
        for fn in ["samples.npy", "y_true.npy", "y_float.npy", "cache_meta.json"]:
            src = src_float / fn
            if src.exists():
                shutil.copy2(src, dst_float / fn)
    float_dir = out_dir / "float"
    x_arr, y_true_arr, y_float_arr = _load_or_prepare_float_cache(
        args, ckpt_cfg, ckpt_arch, dl, device, model, out_dir
    )

    _write_json(
        out_dir / "meta" / "run.json",
        {
            "ckpt": str(Path(args.ckpt).resolve()),
            "feat_root": str(Path(args.feat_root).resolve()),
            "target": args.target,
            "limit": int(args.limit),
            "preload": bool(args.preload),
            "samples": int(x_arr.shape[0]),
            "seq_len": int(x_arr.shape[1]),
            "din": int(x_arr.shape[2]),
            "rmsnorm_mode": "exact_recip30",
            "export_json": str(Path(export_json).resolve()),
            "export_dir": str(export_dir.resolve()),
        },
    )
    _write_json(
        out_dir / "meta" / "stages.json",
        {
            "stages": [
                {
                    "name": "reuse_mamba_block_top_chain4",
                    "rtl_top": "reuse_mamba_board_shell_stream",
                    "status": "active_mainline",
                    "description": "Main chain4 stateless stream export driven by hw_like_chain4.",
                }
            ]
        },
    )

    npy_manifest = {
        "samples": str((float_dir / "samples.npy").resolve()),
        "y_true": str((float_dir / "y_true.npy").resolve()),
        "y_float": str((float_dir / "y_float.npy").resolve()),
    }
    _write_json(out_dir / "meta" / "artifacts.json", npy_manifest)

    chain4_summary = _export_reuse_top_four_block_chain(
        out_dir,
        Path(export_json),
        sample_idx=0,
        max_blocks=4,
    )
    _write_json(out_dir / "logs" / "block_chain4_manifest.json", chain4_summary)
    stream_chain4_summary = _export_chain4_stream_golden(
        out_dir,
        Path(export_json),
        n_frames=max(1, int(args.chain4_stream_frames)),
        continuous_state=bool(args.chain4_stream_continuous_state),
        source_mode=str(args.chain4_stream_source),
        workers=int(args.workers),
        progress_every=100,
    )
    stream_mode_tag = "continuous" if bool(args.chain4_stream_continuous_state) else "stateless"
    _write_json(
        out_dir / "logs" / f"block_chain4_stream_{stream_mode_tag}_manifest.json",
        stream_chain4_summary,
    )
    ip_init_summary = {"generated": False, "reason": "skipped"}
    if not bool(args.skip_ip_init):
        ip_entries = []
        for bi in range(4):
            ip_entries.append(_export_vivado_ip_init_assets(out_dir, export_dir, block_index=bi))
        ip_init_summary = {"generated": True, "entries": ip_entries}
        _write_json(out_dir / "logs" / "ip_init_manifest.json", ip_init_summary)

    (out_dir / "rtl_out").mkdir(parents=True, exist_ok=True)
    (out_dir / "logs").mkdir(parents=True, exist_ok=True)
    (out_dir / "tb").mkdir(parents=True, exist_ok=True)
    (out_dir / "mem").mkdir(parents=True, exist_ok=True)

    summary = {
        "hw_debug_root": str(out_dir.resolve()),
        "float_cache_dir": str(float_dir.resolve()),
        "export_json": str(Path(export_json).resolve()),
        "chain4_debug": chain4_summary,
        "chain4_stream_debug": stream_chain4_summary,
        "ip_init": ip_init_summary,
        "next_steps": [
            "Run stateless stream TB against stages/reuse_mamba_block_top_chain4/stream_y_golden_stateless_q88.mem.",
            "Run final_hw/vivado/run_xsim_stage.py for reuse_mamba_board_shell_stream and reuse_mamba_board_shell_stream_ps.",
            "Collect rtl_out/* and compare against golden stage outputs.",
        ],
    }
    print(json.dumps(summary, indent=2))

if __name__ == "__main__":
    main()
