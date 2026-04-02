from __future__ import annotations

import argparse
import json
import math
from pathlib import Path

import numpy as np
import torch
from torch.utils.data import DataLoader

from refactor.bittrue.eval_bittrue import _arch_from_ckpt, _build_model, _cfg_from_ckpt, _load_or_prepare_float_cache
from refactor.bittrue.pack import export_minimal
from refactor.core.train import TrainConfig, set_seed
from refactor.datasets.frames_lazy import FramesLazyDataset


def _stage_spec() -> list[dict]:
    return [
        {
            "name": "sigmoid4_vec",
            "rtl_top": "sigmoid4_vec",
            "status": "ready_to_hook",
            "description": "Q8.8 -> clamp[-4,4) -> addr=x+1024 -> Q0.16 ROM output.",
            "golden_inputs": ["in_q88.mem"],
            "golden_outputs": ["out_q016.mem"],
            "notes": [
                "Best first stage for cocotb bit-exact verification.",
                "Should match RTL clamp, ROM address, and Q0.16 output exactly.",
            ],
        },
        {
            "name": "ew_update_vec4",
            "rtl_top": "ew_update_vec4",
            "status": "ready_to_hook",
            "description": "State update s_new = lam*s_prev + (1-lam)*u with SRAM timing.",
            "golden_inputs": ["lam_q016.mem", "u_q88.mem", "s_prev_q88.mem", "s_addr.mem"],
            "golden_outputs": ["s_new_q88.mem", "state_write_addr.mem", "state_write_data.mem"],
            "notes": [
                "Must align lam Q0.16 -> Q8.8 truncation, one_minus, SRAM read latency, and write-back address.",
            ],
        },
        {
            "name": "top_mac_plus_bias_fifo_sigmoid_ew_gate",
            "rtl_top": "top_mac_plus_bias_fifo_sigmoid_ew_gate",
            "status": "planned",
            "description": "SSM post-dt path including bias, sigmoid, EW update, and gate.",
            "golden_inputs": ["mac_vec_q88.mem", "xt_q88.mem", "gate_q88.mem"],
            "golden_outputs": ["y_q88.mem", "lam_q016.mem", "s_new_q88.mem"],
            "notes": [
                "Good integration target after sigmoid4_vec and ew_update_vec4 pass.",
            ],
        },
        {
            "name": "reuse_mamba_block_top",
            "rtl_top": "reuse_mamba_block_top",
            "status": "partial_ready",
            "description": "Block-level top around shared MAC fabric.",
            "golden_inputs": [
                "h_wr_addr.mem",
                "h_wr_data_q88.mem",
                "inproj_wbuf_bank*.mem",
                "dt_wbuf_bank*.mem",
                "control.json",
            ],
            "golden_outputs": [
                "u_golden_q88.mem",
                "z_golden_q88.mem",
                "u_act_golden_q88.mem",
                "z_silu_golden_q88.mem",
                "dt_golden_q88.mem",
                "lam_golden_q016.mem",
                "ssm_golden_q88.mem",
            ],
            "notes": [
                "Use only after in_proj and SSM subpaths are individually validated.",
                "Current hardware out_proj is still stub, so final y compare may be partial.",
                "Top compare currently targets internal SRAM / subpath outputs, not final y.",
            ],
        },
    ]


def _write_json(path: Path, obj: dict | list) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2), encoding="utf-8")


def _find_sigmoid_lut() -> Path | None:
    candidates = [
        Path("user/data/sigmoid_lut_q016_2048.hex"),
        Path("sigmoid_lut_q016_2048.hex"),
    ]
    for p in candidates:
        if p.exists():
            return p.resolve()
    return None


def _to_u16(v: int) -> int:
    return int(v) & 0xFFFF


def _from_u16_signed(v: int) -> int:
    v &= 0xFFFF
    return v - 0x10000 if v & 0x8000 else v


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


def _quant_q88(x: np.ndarray) -> np.ndarray:
    q = np.rint(x.astype(np.float64) * 256.0).astype(np.int64)
    q = np.clip(q, -32768, 32767).astype(np.int16)
    return q


def _quant_q016_from_sigmoid(x: np.ndarray) -> np.ndarray:
    s = 1.0 / (1.0 + np.exp(-x.astype(np.float64)))
    q = np.rint(s * 65536.0).astype(np.int64)
    q = np.clip(q, 0, 65535).astype(np.uint16)
    return q


def _write_mem_matrix_rows_q88(path: Path, mat_2d: np.ndarray, tile: int = 4) -> None:
    rows = []
    for i in range(mat_2d.shape[0]):
        row = np.asarray(mat_2d[i]).reshape(-1)
        if row.shape[0] != tile:
            raise ValueError(f"expected row width {tile}, got {row.shape[0]} for {path}")
        rows.append([int(v) & 0xFFFF for v in row.tolist()])
    _write_mem_packed_u16(path, rows)


def _write_weight_banks_q88(
    path_prefix: Path,
    weight_oc_ic: np.ndarray,
    n_bank: int,
    depth: int,
    tile: int = 4,
) -> list[str]:
    oc, ic = weight_oc_ic.shape
    row_tiles = oc // tile
    col_tiles = ic // tile
    bank_lines = [[0 for _ in range(depth)] for _ in range(n_bank)]
    q = _quant_q88(weight_oc_ic)
    for rt in range(row_tiles):
        for ct in range(col_tiles):
            tile_id = rt * col_tiles + ct
            bank = tile_id % n_bank
            addr = tile_id // n_bank
            if addr >= depth:
                raise RuntimeError(f"bank addr overflow: tile_id={tile_id} addr={addr} depth={depth}")
            vals: list[int] = []
            tile_mat = q[rt * tile : (rt + 1) * tile, ct * tile : (ct + 1) * tile]
            for r in range(tile):
                for c in range(tile):
                    vals.append(int(tile_mat[r, c]) & 0xFFFF)
            packed = 0
            for idx, v in enumerate(vals):
                packed |= (v & 0xFFFF) << (16 * idx)
            bank_lines[bank][addr] = packed
    files = []
    for b in range(n_bank):
        name = f"{path_prefix.name}_bank{b}.mem"
        fpath = path_prefix.parent / name
        with open(fpath, "w", encoding="utf-8") as f:
            for line in bank_lines[b]:
                f.write(f"{line:064X}\n")
        files.append(name)
    return files


def _sigmoid_lut_values() -> list[int]:
    lut_path = _find_sigmoid_lut()
    if lut_path is not None:
        vals = []
        for line in lut_path.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line:
                continue
            vals.append(int(line, 16) & 0xFFFF)
        if len(vals) == 2048:
            return vals
    vals = []
    for raw in range(-1024, 1024):
        x = raw / 256.0
        s = 1.0 / (1.0 + math.exp(-x))
        q = int(round(s * 65536.0))
        q = max(0, min(0xFFFF, q))
        vals.append(q)
    return vals


def _export_sigmoid_stage(case_dir: Path) -> dict:
    stage_dir = case_dir / "stages" / "sigmoid4_vec"
    lut = _sigmoid_lut_values()
    in_rows: list[list[int]] = []
    out_rows: list[list[int]] = []
    lane_meta: list[dict] = []
    for vec_idx in range(512):
        in_row: list[int] = []
        out_row: list[int] = []
        for lane in range(4):
            addr = vec_idx * 4 + lane
            q88 = addr - 1024
            in_row.append(_to_u16(q88))
            out_row.append(lut[addr])
            lane_meta.append(
                {
                    "vec": vec_idx,
                    "lane": lane,
                    "in_q88_raw": q88,
                    "in_float": q88 / 256.0,
                    "lut_addr": addr,
                    "out_q016_raw": int(lut[addr]),
                    "out_float": int(lut[addr]) / 65536.0,
                }
            )
        in_rows.append(in_row)
        out_rows.append(out_row)

    _write_mem_packed_u16(stage_dir / "in_q88.mem", in_rows)
    _write_mem_packed_u16(stage_dir / "out_q016.mem", out_rows)
    _write_mem_u16_scalar(stage_dir / "lut_q016_2048.hex", lut, width_hex=4)
    _write_json(
        stage_dir / "vectors.json",
        {
            "vectors": len(in_rows),
            "lanes": 4,
            "format": {
                "in_q88": "packed 4x16b, lane0 in LSB",
                "out_q016": "packed 4x16b, lane0 in LSB",
            },
            "lane_meta": lane_meta[:32],
            "lut_file_source": str(_find_sigmoid_lut()) if _find_sigmoid_lut() else "generated_from_formula",
        },
    )
    return {
        "generated": True,
        "vector_count": len(in_rows),
        "files": ["in_q88.mem", "out_q016.mem", "lut_q016_2048.hex", "vectors.json"],
    }


def _mul_q88_unsigned_signed(a_u16: int, b_s16: int) -> int:
    prod = int(a_u16 & 0xFFFF) * int(b_s16)
    raw = (prod >> 8) & 0xFFFF
    return _from_u16_signed(raw)


def _add_wrap_s16(a_s16: int, b_s16: int) -> int:
    return _from_u16_signed((int(a_s16) + int(b_s16)) & 0xFFFF)


def _export_ew_update_stage(case_dir: Path, state_depth: int = 64, vector_count: int = 128) -> dict:
    stage_dir = case_dir / "stages" / "ew_update_vec4"
    state_mem: list[list[int]] = []
    for addr in range(state_depth):
        row = []
        for lane in range(4):
            base = ((addr * 17 + lane * 29) % 257) - 128
            row.append(_to_u16(base << 3))
        state_mem.append(row)

    lam_rows: list[list[int]] = []
    u_rows: list[list[int]] = []
    s_addr_rows: list[int] = []
    s_prev_rows: list[list[int]] = []
    s_new_rows: list[list[int]] = []
    state_write_rows: list[dict] = []
    state_runtime = [row[:] for row in state_mem]
    last_wr_valid = False
    last_wr_addr = 0
    last_wr_data = [0, 0, 0, 0]

    for t in range(vector_count):
        s_addr = (t * 5) % state_depth
        lam_q016 = []
        u_q88 = []
        for lane in range(4):
            lam_raw = ((t * 37 + lane * 101) % 257) << 8  # [0, 256] in Q0.16 so lam_r becomes Q8.8 in [0,256]
            u_raw = (((t * 53 + lane * 31) % 513) - 256) << 2
            lam_q016.append(_to_u16(lam_raw))
            u_q88.append(_to_u16(u_raw))

        s_prev = last_wr_data[:] if (last_wr_valid and last_wr_addr == s_addr) else state_runtime[s_addr][:]
        s_new = []
        for lane in range(4):
            lam_r = (lam_q016[lane] >> 8) & 0xFFFF
            lam_r_u = lam_r
            one_minus = (0x0100 - lam_r_u) & 0xFFFF
            s_prev_s = _from_u16_signed(s_prev[lane])
            u_s = _from_u16_signed(u_q88[lane])
            mul_a = _mul_q88_unsigned_signed(lam_r_u, s_prev_s)
            mul_b = _mul_q88_unsigned_signed(one_minus, u_s)
            s_new_lane = _add_wrap_s16(mul_a, mul_b)
            s_new.append(_to_u16(s_new_lane))

        s_addr_w = (s_addr + 1) % state_depth
        state_runtime[s_addr_w] = s_new[:]
        last_wr_valid = True
        last_wr_addr = s_addr_w
        last_wr_data = s_new[:]

        lam_rows.append(lam_q016)
        u_rows.append(u_q88)
        s_addr_rows.append(s_addr)
        s_prev_rows.append(s_prev)
        s_new_rows.append(s_new)
        state_write_rows.append({"token": t, "read_addr": s_addr, "write_addr": s_addr_w, "write_data": s_new[:]})

    _write_mem_packed_u16(stage_dir / "state_init_q88.mem", state_mem)
    _write_mem_packed_u16(stage_dir / "lam_q016.mem", lam_rows)
    _write_mem_packed_u16(stage_dir / "u_q88.mem", u_rows)
    _write_mem_u16_scalar(stage_dir / "s_addr.mem", s_addr_rows, width_hex=2)
    _write_mem_packed_u16(stage_dir / "s_prev_q88.mem", s_prev_rows)
    _write_mem_packed_u16(stage_dir / "s_new_q88.mem", s_new_rows)
    _write_mem_u16_scalar(stage_dir / "state_write_addr.mem", [r["write_addr"] for r in state_write_rows], width_hex=2)
    _write_mem_packed_u16(stage_dir / "state_write_data.mem", [r["write_data"] for r in state_write_rows])
    _write_json(
        stage_dir / "vectors.json",
        {
            "state_depth": state_depth,
            "vector_count": vector_count,
            "format": {
                "lam_q016": "packed 4x16b, unsigned Q0.16, lane0 in LSB",
                "u_q88": "packed 4x16b, signed Q8.8, lane0 in LSB",
                "s_prev_q88": "packed 4x16b, signed Q8.8, lane0 in LSB",
                "s_new_q88": "packed 4x16b, signed Q8.8, lane0 in LSB",
                "s_addr": "8-bit hex per line",
            },
            "notes": [
                "Golden model matches ew_update_vec4.sv semantics: lam>>8, two EWM truncations, one EWA wrap, write to s_addr+1.",
                "Bypass semantics are modeled using last write address/data.",
            ],
            "sample_rows": state_write_rows[:16],
        },
    )
    return {
        "generated": True,
        "vector_count": vector_count,
        "state_depth": state_depth,
        "files": [
            "state_init_q88.mem",
            "lam_q016.mem",
            "u_q88.mem",
            "s_addr.mem",
            "s_prev_q88.mem",
            "s_new_q88.mem",
            "state_write_addr.mem",
            "state_write_data.mem",
            "vectors.json",
        ],
    }


def _export_reuse_top_stage(case_dir: Path, model: torch.nn.Module, x_arr: np.ndarray) -> dict:
    stage_dir = case_dir / "stages" / "reuse_mamba_block_top"
    bb = model.backbone
    if len(bb.blocks) == 0:
        return {"generated": False, "reason": "backbone has no blocks"}
    blk = bb.blocks[0]
    dev = next(model.parameters()).device
    x0 = torch.from_numpy(x_arr[:1]).float().to(dev)  # (1,K,Din)
    with torch.inference_mode():
        xp = x0.permute(0, 2, 1)  # (B, Din, K)
        proj = model.proj(xp)
        patch = bb.patch_embedding(proj).permute(0, 2, 1)  # (B, num_patches, d_model)
        if bb.pe_on:
            pe = bb.pe_buf.to(device=patch.device, dtype=patch.dtype)
            patch = patch + bb.pe_scale * pe.unsqueeze(0)
        if patch.shape[1] != 1:
            return {
                "generated": False,
                "reason": f"reuse_mamba_block_top currently assumes one patch/token, got num_patches={int(patch.shape[1])}",
            }
        h = blk.norm(patch)  # (1,1,D)
        uv = blk.in_proj(h.permute(0, 2, 1)).permute(0, 2, 1)  # (1,1,2*inner)
        inner = blk.args.d_inner
        u = uv[..., :inner]
        z = uv[..., inner:]
        if blk.dw_conv is not None:
            u = blk.dw_conv(u.permute(0, 2, 1)).permute(0, 2, 1)
        u_act = blk.act(u)
        z_silu = blk.act(z)
        dt = blk.ssm.dt_proj(u_act.permute(0, 2, 1)).permute(0, 2, 1)
        lam = torch.sigmoid(dt)
        s = torch.zeros((1, inner), dtype=u.dtype, device=u.device)
        ssm = torch.empty_like(u_act)
        for t in range(u_act.shape[1]):
            s = lam[:, t, :] * s + (1.0 - lam[:, t, :]) * u_act[:, t, :]
            ssm[:, t, :] = s

    h_np = h[0, 0].cpu().numpy()
    u_np = u[0, 0].cpu().numpy()
    z_np = z[0, 0].cpu().numpy()
    u_act_np = u_act[0, 0].cpu().numpy()
    z_silu_np = z_silu[0, 0].cpu().numpy()
    dt_np = dt[0, 0].cpu().numpy()
    lam_np = lam[0, 0].cpu().numpy()
    ssm_np = ssm[0, 0].cpu().numpy()

    _write_mem_u16_scalar(stage_dir / "h_wr_addr.mem", list(range(32)), width_hex=2)
    _write_mem_matrix_rows_q88(stage_dir / "h_wr_data_q88.mem", _quant_q88(h_np).reshape(32, 4))
    _write_mem_matrix_rows_q88(stage_dir / "u_golden_q88.mem", _quant_q88(u_np).reshape(64, 4))
    _write_mem_matrix_rows_q88(stage_dir / "z_golden_q88.mem", _quant_q88(z_np).reshape(64, 4))
    _write_mem_matrix_rows_q88(stage_dir / "u_act_golden_q88.mem", _quant_q88(u_act_np).reshape(64, 4))
    _write_mem_matrix_rows_q88(stage_dir / "z_silu_golden_q88.mem", _quant_q88(z_silu_np).reshape(64, 4))
    _write_mem_matrix_rows_q88(stage_dir / "dt_golden_q88.mem", _quant_q88(dt_np).reshape(64, 4))
    _write_mem_matrix_rows_q88(stage_dir / "lam_golden_q016.mem", _quant_q016_from_sigmoid(dt_np).reshape(64, 4))
    _write_mem_matrix_rows_q88(stage_dir / "ssm_golden_q88.mem", _quant_q88(ssm_np).reshape(64, 4))

    inproj_conv = getattr(blk.in_proj, "conv", None)
    if inproj_conv is None and hasattr(blk.in_proj, "qconv") and hasattr(blk.in_proj.qconv, "conv"):
        inproj_conv = blk.in_proj.qconv.conv
    dtproj_conv = blk.ssm.dt_proj
    if inproj_conv is None:
        return {"generated": False, "reason": "unable to unwrap in_proj conv weights"}
    inproj_w = inproj_conv.weight.detach().cpu().numpy().reshape(inproj_conv.out_channels, inproj_conv.in_channels)
    dt_w = dtproj_conv.weight.detach().cpu().numpy().reshape(dtproj_conv.out_channels, dtproj_conv.in_channels)
    inproj_files = _write_weight_banks_q88(stage_dir / "inproj_wbuf", inproj_w, n_bank=6, depth=683)
    dt_files = _write_weight_banks_q88(stage_dir / "dt_wbuf", dt_w, n_bank=6, depth=683)

    _write_json(
        stage_dir / "control.json",
        {
            "block_auto_mode": 1,
            "block_start_pulse_cycles": 1,
            "h_depth": 32,
            "u_depth": 64,
            "notes": [
                "Current top-level golden is partial.",
                "Compare h->in_proj->u/z SRAM first.",
                "Final y is not a valid top-level golden yet because out_proj is still stub in RTL.",
                "Software path uses u_act before dt_proj, while current RTL top still reads raw u from SRAM for dt scheduling.",
            ],
        },
    )
    _write_json(
        stage_dir / "vectors.json",
        {
            "num_patches": int(patch.shape[1]),
            "d_model": int(blk.args.d_model),
            "d_inner": int(inner),
            "files": {
                "h_wr_addr": "h_wr_addr.mem",
                "h_wr_data_q88": "h_wr_data_q88.mem",
                "u_golden_q88": "u_golden_q88.mem",
                "z_golden_q88": "z_golden_q88.mem",
                "u_act_golden_q88": "u_act_golden_q88.mem",
                "z_silu_golden_q88": "z_silu_golden_q88.mem",
                "dt_golden_q88": "dt_golden_q88.mem",
                "lam_golden_q016": "lam_golden_q016.mem",
                "ssm_golden_q88": "ssm_golden_q88.mem",
                "inproj_wbuf": inproj_files,
                "dt_wbuf": dt_files,
            },
        },
    )
    return {
        "generated": True,
        "partial_only": True,
        "files": [
            "h_wr_addr.mem",
            "h_wr_data_q88.mem",
            "u_golden_q88.mem",
            "z_golden_q88.mem",
            "u_act_golden_q88.mem",
            "z_silu_golden_q88.mem",
            "dt_golden_q88.mem",
            "lam_golden_q016.mem",
            "ssm_golden_q88.mem",
            "control.json",
            "vectors.json",
            *inproj_files,
            *dt_files,
        ],
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
            "export_json": str(Path(export_json).resolve()),
            "export_dir": str(export_dir.resolve()),
        },
    )
    _write_json(out_dir / "meta" / "stages.json", {"stages": _stage_spec()})

    npy_manifest = {
        "samples": str((float_dir / "samples.npy").resolve()),
        "y_true": str((float_dir / "y_true.npy").resolve()),
        "y_float": str((float_dir / "y_float.npy").resolve()),
    }
    _write_json(out_dir / "meta" / "artifacts.json", npy_manifest)

    for stage in _stage_spec():
        stage_dir = out_dir / "stages" / stage["name"]
        stage_dir.mkdir(parents=True, exist_ok=True)
        manifest = dict(stage)
        if stage["name"] == "sigmoid4_vec":
            manifest["generated_artifacts"] = _export_sigmoid_stage(out_dir)
        elif stage["name"] == "ew_update_vec4":
            manifest["generated_artifacts"] = _export_ew_update_stage(out_dir)
        elif stage["name"] == "reuse_mamba_block_top":
            manifest["generated_artifacts"] = _export_reuse_top_stage(out_dir, model, x_arr)
        else:
            manifest["generated_artifacts"] = {"generated": False}
        _write_json(stage_dir / "manifest.json", manifest)

    (out_dir / "rtl_out").mkdir(parents=True, exist_ok=True)
    (out_dir / "logs").mkdir(parents=True, exist_ok=True)
    (out_dir / "tb").mkdir(parents=True, exist_ok=True)
    (out_dir / "mem").mkdir(parents=True, exist_ok=True)

    summary = {
        "hw_debug_root": str(out_dir.resolve()),
        "float_cache_dir": str(float_dir.resolve()),
        "export_json": str(Path(export_json).resolve()),
        "next_steps": [
            "Populate stage-specific mem files under stages/<stage>/ or mem/<stage>/.",
            "Run cocotb tests from HW_reconstruct/hw_debug/cocotb.",
            "Collect rtl_out/* and compare against golden stage outputs.",
        ],
    }
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
