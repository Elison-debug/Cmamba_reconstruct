from __future__ import annotations

import argparse
import json
import math
import shutil
import subprocess
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
            "name": "reuse_ssm_core",
            "rtl_top": "reuse_ssm_core",
            "status": "partial_ready",
            "description": "Standalone SSM post-dt core: bias -> sigmoid -> join -> EW update -> gate.",
            "golden_inputs": ["mac_in_q88.mem", "xt_in_q88.mem", "g_in_q88.mem"],
            "golden_outputs": ["lam_golden_q016.mem", "ssm_golden_q88.mem", "gate_y_golden_q88.mem"],
            "notes": [
                "Current simulation model of bias_add_regslice_ip_A uses zero-initialized bias mem_sim unless TB explicitly initializes it.",
                "This stage isolates dt/lam/ssm/gate from the top-level scheduler.",
            ],
        },
        {
            "name": "reuse_ssm_dt_scheduler",
            "rtl_top": "reuse_ssm_dt_scheduler",
            "status": "partial_ready",
            "description": "Standalone dt scheduler with shared MAC fabric and u_act SRAM source.",
            "golden_inputs": ["u_act_in_q88.mem", "dt_wbuf_bank*.mem", "dt_scale_q15.mem"],
            "golden_outputs": ["dt_golden_q88.mem", "xt_golden_q88.mem"],
            "notes": [
                "This stage isolates dt GEMV + xt FIFO wavefront from top-level ownership switching.",
                "Use it to determine whether dt mismatch originates in the scheduler itself or in top-level integration.",
            ],
        },
        {
            "name": "reuse_mamba_block_top",
            "rtl_top": "reuse_mamba_block_top",
            "status": "partial_ready",
            "description": "Block-level top around shared MAC fabric.",
            "golden_inputs": [
                "h_wr_addr.mem",
                "h_wr_data_s16_q8p8.mem",
                "norm_gamma_s16_q8p8.mem",
                "inproj_wbuf_bank*.mem",
                "inproj_scale_q15.mem",
                "dt_wbuf_bank*.mem",
                "dt_scale_q15.mem",
                "outproj_wbuf_bank*.mem",
                "outproj_scale_q15.mem",
                "control.json",
            ],
            "golden_outputs": [
                "u_golden_q88.mem",
                "z_golden_q88.mem",
                "h_norm_golden_s16_q8p8.mem",
                "u_act_golden_q88.mem",
                "z_silu_golden_q88.mem",
                "dt_golden_q88.mem",
                "lam_golden_q016.mem",
                "ssm_golden_q88.mem",
                "gate_y_golden_q88.mem",
                "y_golden_q88.mem",
            ],
            "notes": [
                "Use only after in_proj and SSM subpaths are individually validated.",
                "Current top-level y golden is the block-local out_proj result before any residual add outside this RTL block.",
                "Top compare targets internal SRAM / subpath outputs and the final out_proj y stream/SRAM.",
            ],
        },
    ]


def _write_json(path: Path, obj: dict | list) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2), encoding="utf-8")


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


def _signed_qmax_for_bits(bits: int) -> int:
    return (1 << (bits - 1)) - 1


def _signed_qmin_for_bits(bits: int) -> int:
    return -(1 << (bits - 1))


def _rshift_rne_i64(x: int, frac_bits: int) -> int:
    if frac_bits <= 0:
        return int(x)
    base = 1 << frac_bits
    q = x // base
    r = x % base
    if r < 0:
        r += base
        q -= 1
    half = base >> 1
    if r > half or (r == half and (q & 1)):
        q += 1
    return int(q)


def _quantize_centered_input(x: float, scale: float, bits: int, zero_point: int, raw_qmin: int, raw_qmax: int) -> int:
    if scale == 0.0:
        return 0
    qmin = raw_qmin if raw_qmin < raw_qmax else _signed_qmin_for_bits(bits)
    qmax = raw_qmax if raw_qmax > raw_qmin else _signed_qmax_for_bits(bits)
    q = int(np.rint(float(x) / float(scale))) + int(zero_point)
    q = max(qmin, min(qmax, q))
    return q - int(zero_point)


def _conv1d_out_len(in_len: int, kernel_size: int, stride: int, padding: int) -> int:
    return (in_len + 2 * padding - kernel_size) // stride + 1


def _load_scale_vector(qdesc: dict, base_dir: Path) -> np.ndarray:
    scale_ref = qdesc.get("scale", "")
    if isinstance(scale_ref, str) and scale_ref:
        return np.load(base_dir / scale_ref).astype(np.float32).reshape(-1)
    return np.zeros((0,), dtype=np.float32)


def _make_activation_scales(qdesc: dict, channels: int, x: np.ndarray) -> np.ndarray:
    if qdesc.get("enabled") and qdesc.get("scheme") == "per_channel_sym":
        scales = _load_scale_vector(qdesc, x.base_dir if hasattr(x, "base_dir") else Path(".")) #type: ignore
        if scales.shape[0] == channels:
            return scales.astype(np.float32)

    scales = np.ones((channels,), dtype=np.float32)
    if qdesc.get("enabled") and qdesc.get("scheme") == "per_tensor_asym" and float(qdesc.get("scale", 0.0) or 0.0) > 0.0:
        scales.fill(float(qdesc["scale"]))
        return scales

    mx = float(np.max(np.abs(x))) if x.size else 0.0
    fallback = (mx / 127.0) if mx > 0.0 else (1.0 / 127.0)
    scales.fill(fallback)
    return scales


class _XWithBase(np.ndarray):
    base_dir: Path


def _attach_base_dir(x: np.ndarray, base_dir: Path) -> np.ndarray:
    y = np.asarray(x).view(_XWithBase)
    y.base_dir = base_dir
    return y


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


def _conv1d_run_integer_desc(desc: dict, base_dir: Path, x_tc: np.ndarray, t_in: int, bits: int = 16) -> np.ndarray:
    weight = np.load(base_dir / desc["weight"]).astype(np.float32)
    w_raw = weight.reshape(desc["out_channels"], desc["in_channels"] // desc["groups"], desc["kernel_size"])
    bias = None
    if desc.get("bias") and desc.get("bias_file"):
        bias = np.load(base_dir / desc["bias_file"]).astype(np.float32).reshape(-1)

    qmax = _signed_qmax_for_bits(bits)
    qmin = _signed_qmin_for_bits(bits)
    act_q = desc.get("quant", {}).get("activation", {})
    act_asym = bool(act_q.get("enabled")) and act_q.get("scheme") == "per_tensor_asym"
    act_zp = int(act_q.get("zero_point", 0)) if act_asym else 0
    act_raw_qmin = int(act_q.get("qmin", qmin)) if act_asym else qmin
    act_raw_qmax = int(act_q.get("qmax", qmax)) if act_asym else qmax

    a_scales = _make_activation_scales(act_q, desc["in_channels"], _attach_base_dir(x_tc, base_dir))
    xq = np.zeros_like(x_tc, dtype=np.int32)
    for t in range(t_in):
        for c in range(desc["in_channels"]):
            xq[t, c] = _quantize_centered_input(float(x_tc[t, c]), float(a_scales[c]), bits, act_zp, act_raw_qmin, act_raw_qmax)

    t_out = _conv1d_out_len(t_in, int(desc["kernel_size"]), int(desc["stride"]), int(desc["padding"]))
    cin_per_group = desc["in_channels"] // desc["groups"]
    cout_per_group = desc["out_channels"] // desc["groups"]
    y_tc = np.zeros((t_out, desc["out_channels"]), dtype=np.float32)
    out_scales = np.ones((desc["out_channels"],), dtype=np.float32)
    w_eff = np.zeros_like(w_raw, dtype=np.int32)

    for oc in range(desc["out_channels"]):
        g = oc // cout_per_group
        max_abs = 0.0
        for icg in range(cin_per_group):
            ic = g * cin_per_group + icg
            for k in range(desc["kernel_size"]):
                max_abs = max(max_abs, abs(float(w_raw[oc, icg, k]) * float(a_scales[ic])))
        sy = (max_abs / float(qmax)) if max_abs > 0.0 else (1.0 / float(qmax))
        out_scales[oc] = sy
        for icg in range(cin_per_group):
            ic = g * cin_per_group + icg
            for k in range(desc["kernel_size"]):
                folded = float(w_raw[oc, icg, k]) * float(a_scales[ic]) / float(sy)
                q = int(np.rint(folded))
                q = max(qmin, min(qmax, q))
                w_eff[oc, icg, k] = q

    for t in range(t_out):
        for oc in range(desc["out_channels"]):
            g = oc // cout_per_group
            acc = 0
            if bias is not None:
                acc += int(np.rint(float(bias[oc]) / float(out_scales[oc])))
            for icg in range(cin_per_group):
                ic = g * cin_per_group + icg
                for k in range(desc["kernel_size"]):
                    ti = t * desc["stride"] - desc["padding"] + k
                    if ti < 0 or ti >= t_in:
                        continue
                    acc += int(xq[ti, ic]) * int(w_eff[oc, icg, k])
            y_tc[t, oc] = float(acc) * float(out_scales[oc])

    return y_tc


def _rmsnorm_inplace_np(x_tc: np.ndarray, norm_desc: dict, base_dir: Path) -> None:
    weight = np.load(base_dir / norm_desc["weight"]).astype(np.float32).reshape(-1)
    eps = float(norm_desc.get("eps", 1e-5))
    for t in range(x_tc.shape[0]):
        mean_sq = float(np.mean(np.square(x_tc[t].astype(np.float64))))
        inv = 1.0 / math.sqrt(mean_sq + eps)
        x_tc[t] = x_tc[t] * np.float32(inv) * weight


def _selective_scan_run_int16(blk_desc: dict, u: np.ndarray, z: np.ndarray, dt: np.ndarray, lut: _ActLut) -> np.ndarray:
    t_len, d_inner = u.shape
    bits = 16
    frac_bits = 15
    qmin = _signed_qmin_for_bits(bits)
    qmax = _signed_qmax_for_bits(bits)

    state_scale = np.ones((d_inner,), dtype=np.float32) / 127.0
    for c in range(d_inner):
        mx = float(np.max(np.abs(u[:, c])))
        state_scale[c] = (mx / float(qmax)) if mx > 0.0 else (1.0 / float(qmax))

    s_q = np.zeros((d_inner,), dtype=np.int32)
    ssm_out = np.zeros_like(u, dtype=np.float32)
    lam = lut.sigmoid(dt)
    for t in range(t_len):
        for c in range(d_inner):
            lam_q = int(np.rint(float(lam[t, c]) * float(1 << frac_bits)))
            lam_q = max(0, min(1 << frac_bits, lam_q))
            u_q = int(np.rint(float(u[t, c]) / float(state_scale[c])))
            u_q = max(qmin, min(qmax, u_q))
            acc = lam_q * int(s_q[c]) + ((1 << frac_bits) - lam_q) * u_q
            s_new = _rshift_rne_i64(acc, frac_bits)
            s_new = max(qmin, min(qmax, s_new))
            s_q[c] = s_new
            ssm_out[t, c] = float(s_new) * float(state_scale[c])

    gate_scale = np.ones((d_inner,), dtype=np.float32) / 127.0
    gate = lut.silu_fn(z)
    for c in range(d_inner):
        mx = float(np.max(np.abs(gate[:, c])))
        gate_scale[c] = (mx / float(qmax)) if mx > 0.0 else (1.0 / float(qmax))
    for t in range(t_len):
        for c in range(d_inner):
            qg = int(np.rint(float(gate[t, c]) / float(gate_scale[c])))
            qg = max(qmin, min(qmax, qg))
            ssm_out[t, c] = float(ssm_out[t, c]) * float(qg) * float(gate_scale[c])

    return ssm_out


def _load_export_ir(export_json: Path) -> tuple[dict, dict, Path]:
    export = json.loads(export_json.read_text(encoding="utf-8"))
    base_dir = export_json.parent
    backbone = json.loads((base_dir / export["backbone"]["file"]).read_text(encoding="utf-8"))
    return export, backbone, base_dir


def _compute_block0_local_y_cppish(export_json: Path, x_sample_kd: np.ndarray) -> np.ndarray:
    export, backbone, base_dir = _load_export_ir(export_json)
    lut = _ActLut()
    proj = _conv1d_run_integer_desc(export["proj"], base_dir, x_sample_kd.astype(np.float32), int(export["model"]["seq_len"]), bits=16)
    patch = _conv1d_run_integer_desc(backbone["patch_embedding"], base_dir, proj, proj.shape[0], bits=16)
    if backbone.get("positional_encoding", {}).get("enabled") and backbone["positional_encoding"].get("file"):
        pe = np.load(base_dir / backbone["positional_encoding"]["file"]).astype(np.float32)
        patch += float(backbone["positional_encoding"].get("scale", 1.0)) * pe.reshape(patch.shape)

    blk = backbone["blocks"][0]
    x_seq = patch.copy()
    _rmsnorm_inplace_np(x_seq, blk["norm"], base_dir)
    uv = _conv1d_run_integer_desc(blk["in_proj"], base_dir, x_seq, x_seq.shape[0], bits=16)
    inner = int(blk["d_inner"])
    u = uv[:, :inner]
    z = uv[:, inner:]
    u_act = lut.silu_fn(u)
    dt = _conv1d_run_integer_desc(blk["ssm"]["dt_proj"], base_dir, u_act, u_act.shape[0], bits=16)
    ssm_out = _selective_scan_run_int16(blk, u_act, z, dt, lut)
    y = _conv1d_run_integer_desc(blk["out_proj"], base_dir, ssm_out, ssm_out.shape[0], bits=16)
    return y.reshape(-1)


def _load_packed_mem_q88(path: Path) -> np.ndarray:
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
            lanes.append(v / 256.0)
        rows.append(lanes)
    return np.asarray(rows, dtype=np.float32)


def _write_compare_csv(path: Path, a: np.ndarray, b: np.ndarray, labels: tuple[str, str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(f"row,col,{labels[0]},{labels[1]},diff\n")
        for r in range(a.shape[0]):
            for c in range(a.shape[1]):
                diff = float(a[r, c] - b[r, c])
                f.write(f"{r},{c},{float(a[r,c])},{float(b[r,c])},{diff}\n")


_DT_CHAIN_STAGE_PLAN: list[tuple[str, str]] = [
    ("norm", "x_norm"),
    ("inproj_u", "u"),
    ("inproj_z", "z"),
    ("silu_gate", "z_silu"),
    ("dtproj", "dt"),
    ("dt_sigmoid", "lam"),
    ("selective_scan", "ssm_scan"),
    ("ewm_gating", "gate_y"),
    ("outproj", "y_blk"),
    ("block_output", "x_next"),
]


def _tensor_diff_stats(a: np.ndarray, b: np.ndarray, topk: int = 8) -> dict:
    if a.shape != b.shape:
        if a.size != b.size:
            raise ValueError(f"shape mismatch with different element count: {a.shape} vs {b.shape}")
        a = a.reshape(-1)
        b = b.reshape(-1)

    a32 = a.astype(np.float32)
    b32 = b.astype(np.float32)
    diff = a32 - b32
    abs_diff = np.abs(diff)
    flat_abs = abs_diff.reshape(-1)
    flat_diff = diff.reshape(-1)
    flat_a = a32.reshape(-1)
    flat_b = b32.reshape(-1)
    max_idx = int(np.argmax(flat_abs)) if flat_abs.size else 0
    top_indices = np.argsort(flat_abs)[::-1][: min(int(topk), int(flat_abs.size))]

    return {
        "shape": list(a.shape),
        "mae": float(np.mean(flat_abs)) if flat_abs.size else 0.0,
        "max_abs": float(flat_abs[max_idx]) if flat_abs.size else 0.0,
        "max_abs_flat_index": max_idx,
        "cpp_at_max": float(flat_a[max_idx]) if flat_abs.size else 0.0,
        "hw_like_at_max": float(flat_b[max_idx]) if flat_abs.size else 0.0,
        "signed_diff_at_max": float(flat_diff[max_idx]) if flat_abs.size else 0.0,
        "top_abs_errors": [
            {
                "flat_index": int(i),
                "cpp": float(flat_a[i]),
                "hw_like": float(flat_b[i]),
                "signed_diff": float(flat_diff[i]),
                "abs_diff": float(flat_abs[i]),
            }
            for i in top_indices
        ],
    }


def _export_dt_chain_debug(case_dir: Path, export_json: Path, sample_idx: int = 0, scan_mode: str = "scaled_state") -> dict:
    samples = case_dir / "float" / "samples.npy"
    if not samples.exists():
        return {"generated": False, "reason": "float/samples.npy missing"}

    try:
        from refactor.bittrue.eval_hw_like_full import _forward_full_cppish, _forward_full_hw_like
    except Exception as exc:  # pragma: no cover - diagnostic export path.
        return {"generated": False, "reason": f"failed to import eval_hw_like_full: {exc}"}

    x_arr = np.load(samples).astype(np.float32)
    if x_arr.shape[0] <= int(sample_idx):
        return {
            "generated": False,
            "reason": f"sample_idx {sample_idx} out of range for {x_arr.shape[0]} samples",
        }

    x = x_arr[int(sample_idx)]
    _, cpp_traces = _forward_full_cppish(export_json, x)
    _, hw_traces = _forward_full_hw_like(export_json, x, scan_mode=scan_mode)
    cpp_map = {t["stage"]: t for t in cpp_traces}
    hw_map = {t["stage"]: t for t in hw_traces}
    cpp_b0 = cpp_map["block0"]
    hw_b0 = hw_map["block0"]

    report = {
        "sample_idx": int(sample_idx),
        "reference": "cppish",
        "candidate": "hw_like",
        "scan_mode": scan_mode,
        "stage_order": [name for name, _ in _DT_CHAIN_STAGE_PLAN],
        "block0": {},
    }
    trace_arrays: dict[str, np.ndarray] = {}
    for stage_name, trace_key in _DT_CHAIN_STAGE_PLAN:
        cpp_val = np.asarray(cpp_b0[trace_key])
        hw_val = np.asarray(hw_b0[trace_key])
        report["block0"][stage_name] = _tensor_diff_stats(cpp_val, hw_val)
        trace_arrays[f"cpp_{stage_name}"] = cpp_val
        trace_arrays[f"hw_like_{stage_name}"] = hw_val

    log_dir = case_dir / "logs"
    out_json = log_dir / f"dt_chain_debug_sample{sample_idx}.json"
    out_npz = log_dir / f"dt_chain_debug_sample{sample_idx}_traces.npz"
    _write_json(out_json, report)
    log_dir.mkdir(parents=True, exist_ok=True)
    np.savez_compressed(out_npz, **trace_arrays)

    return {
        "generated": True,
        "sample_idx": int(sample_idx),
        "scan_mode": scan_mode,
        "stage_order": report["stage_order"],
        "files": [
            str(out_json.relative_to(case_dir)),
            str(out_npz.relative_to(case_dir)),
        ],
    }


def _export_block0_cpp_compare(case_dir: Path, export_json: Path) -> dict:
    exe = Path("build/bittrue/main_block0_y.exe")
    samples = case_dir / "float" / "samples.npy"
    if not exe.exists() or not samples.exists():
        return {"generated": False, "reason": "cpp exe or samples.npy missing"}

    out_npy = case_dir / "float" / "cpp_block0_y_cppbittrue.npy"
    cmd = [
        str(exe),
        str(export_json),
        str(samples),
        "2100",
        str(out_npy),
        "--mode",
        "int16",
    ]
    subprocess.run(cmd, check=True)

    cpp = np.load(out_npy).astype(np.float32)
    sample0 = np.load(samples).astype(np.float32)[0]
    py_cppish = _compute_block0_local_y_cppish(export_json, sample0).reshape(32, 4)
    legacy = _load_packed_mem_q88(case_dir / "stages" / "reuse_mamba_block_top" / "y_golden_q88.mem")
    cpp0 = cpp[0]

    legacy_mae = float(np.mean(np.abs(cpp0 - legacy)))
    legacy_max = float(np.max(np.abs(cpp0 - legacy)))
    cppish_mae = float(np.mean(np.abs(cpp0 - py_cppish)))
    cppish_max = float(np.max(np.abs(cpp0 - py_cppish)))

    _write_compare_csv(case_dir / "logs" / "final_compare_cpp_export_hw_cppish.csv", cpp0, py_cppish, ("cpp", "export_cppish"))
    _write_json(
        case_dir / "logs" / "final_compare_cpp_export_hw_cppish.json",
        {
            "sample_index": 0,
            "shape": list(cpp0.shape),
            "cpp_vs_legacy_export_mae": legacy_mae,
            "cpp_vs_legacy_export_max_abs": legacy_max,
            "cpp_vs_cppish_export_mae": cppish_mae,
            "cpp_vs_cppish_export_max_abs": cppish_max,
            "row0_cpp": cpp0[0].astype(float).tolist(),
            "row0_legacy_export_hw": legacy[0].astype(float).tolist(),
            "row0_cppish_export_hw": py_cppish[0].astype(float).tolist(),
        },
    )
    return {
        "generated": True,
        "cpp_vs_legacy_export_mae": legacy_mae,
        "cpp_vs_cppish_export_mae": cppish_mae,
        "cpp_vs_legacy_export_max_abs": legacy_max,
        "cpp_vs_cppish_export_max_abs": cppish_max,
        "files": [
            "logs/final_compare_cpp_export_hw_cppish.json",
            "logs/final_compare_cpp_export_hw_cppish.csv",
            "float/cpp_block0_y_cppbittrue.npy",
        ],
    }


def _quant_q88(x: np.ndarray) -> np.ndarray:
    q = np.rint(x.astype(np.float64) * 256.0).astype(np.int64)
    q = np.clip(q, -32768, 32767).astype(np.int16)
    return q


def _wrap_s16_arr(x: np.ndarray) -> np.ndarray:
    x_i = x.astype(np.int64) & 0xFFFF
    x_s = np.where((x_i & 0x8000) != 0, x_i - 0x10000, x_i)
    return x_s.astype(np.int16)


def _clamp_s16_arr(x: np.ndarray) -> np.ndarray:
    return np.clip(x.astype(np.int64), -32768, 32767).astype(np.int16)


def _quant_q15_scale(x: np.ndarray) -> np.ndarray:
    q = np.rint(x.astype(np.float64) * 32768.0).astype(np.int64)
    q = np.clip(q, 1, 0xFFFF).astype(np.uint16)
    return q


def _rmsnorm_q88_hw(
    raw_q88: np.ndarray,
    gamma_q88: np.ndarray,
    eps_q16: int = 1,
    mode: str = "exact_recip30",
) -> tuple[np.ndarray, int]:
    raw_i = raw_q88.astype(np.int64).reshape(-1)
    gamma_i = gamma_q88.astype(np.int64).reshape(-1)
    dim = int(raw_i.shape[0])
    if dim == 0:
        return np.zeros((0,), dtype=np.int16), 1

    sum_sq = int(np.sum(raw_i * raw_i))
    mean_sq_q16 = int((sum_sq + (dim // 2)) // dim)
    rms_q88 = int(math.isqrt(max(0, mean_sq_q16 + int(eps_q16))))
    if rms_q88 <= 0:
        rms_q88 = 1

    def _recip_q24_lut8(den: int) -> int:
        if den <= 0:
            return 1 << 24
        msb = int(den.bit_length() - 1)
        sh = max(0, msb - 8)
        den_hi = int((den + (1 << (sh - 1))) >> sh) if sh > 0 else int(den)
        den_hi = max(256, min(511, den_hi))
        # 256-entry LUT over normalized den_hi in [256, 511]
        lut_q24 = np.array([int(np.rint((1 << 24) / i)) for i in range(256, 512)], dtype=np.int64)
        recip = int(lut_q24[den_hi - 256])
        if msb >= 8:
            rs = msb - 8
            recip = int((recip + (1 << (rs - 1))) >> rs) if rs > 0 else recip
        else:
            recip = int(recip << (8 - msb))
        return max(1, recip)

    def _recip_q24_nr1_lut8(den: int) -> int:
        if den <= 0:
            return 1 << 24
        msb = int(den.bit_length() - 1)
        # normalize den to Q1.15 in [1.0, 2.0)
        den_q15 = int((den << 15) >> msb)
        den_q15 = max(1 << 15, min((1 << 16) - 1, den_q15))
        # seed LUT indexed by top-8 fractional bits of den_q15
        idx = (den_q15 - (1 << 15)) >> 7  # 0..255
        centers = np.array([(1 << 15) + (i << 7) + 64 for i in range(256)], dtype=np.int64)
        x0_lut_q15 = np.array([int(np.rint((1 << 30) / c)) for c in centers], dtype=np.int64)  # approx 1/c in Q1.15
        x = int(x0_lut_q15[int(idx)])
        # one Newton step: x1 = x * (2 - d*x)
        prod = int((den_q15 * x + (1 << 14)) >> 15)  # Q1.15
        term = int((2 << 15) - prod)                 # Q1.15
        x1 = int((x * term + (1 << 14)) >> 15)       # Q1.15
        x1 = max(0, min((1 << 16) - 1, x1))
        # denormalize and convert to Q0.24 reciprocal
        recip = int((x1 << 9) >> msb)  # (x1 / 2^15) / 2^msb * 2^24
        return max(1, recip)

    out = np.zeros((dim,), dtype=np.int16)
    if mode in ("approx_pow2", "lut8", "nr1_lut8", "nr2_lut8", "exact_recip30"):
        recip_frac_bits = 24
        if mode == "approx_pow2":
            if rms_q88 <= 0:
                recip_q24 = 1 << recip_frac_bits
            else:
                msb_idx = int(int(rms_q88).bit_length() - 1)
                sh = recip_frac_bits - msb_idx
                sh = max(0, min(31, sh))
                recip_q24 = 1 << sh
        elif mode == "lut8":
            recip_q24 = _recip_q24_lut8(int(rms_q88))
        elif mode == "nr2_lut8":
            # first NR from LUT seed in Q1.15
            den = int(max(1, rms_q88))
            msb = int(den.bit_length() - 1)
            den_q15 = int((den << 15) >> msb)
            den_q15 = max(1 << 15, min((1 << 16) - 1, den_q15))
            idx = (den_q15 - (1 << 15)) >> 7
            centers = np.array([(1 << 15) + (i << 7) + 64 for i in range(256)], dtype=np.int64)
            x0_lut_q15 = np.array([int(np.rint((1 << 30) / c)) for c in centers], dtype=np.int64)
            x = int(x0_lut_q15[int(idx)])
            for _ in range(2):
                prod = int((den_q15 * x + (1 << 14)) >> 15)
                term = int((2 << 15) - prod)
                x = int((x * term + (1 << 14)) >> 15)
                x = max(0, min((1 << 16) - 1, x))
            recip_q24 = int((x << 9) >> msb)
            recip_q24 = max(1, recip_q24)
        elif mode == "exact_recip30":
            recip_frac_bits = 30
            if rms_q88 <= 0:
                recip_q24 = 1 << recip_frac_bits
            else:
                recip_q24 = int(((1 << recip_frac_bits) + (int(rms_q88) >> 1)) // int(rms_q88))
        else:
            recip_q24 = _recip_q24_nr1_lut8(int(rms_q88))
        half = 1 << (recip_frac_bits - 1)
        for i in range(dim):
            num = int(raw_i[i] * gamma_i[i])
            mul = int(num * recip_q24)
            if mul >= 0:
                rounded = mul + half
            else:
                rounded = mul - half
            q = int(rounded >> recip_frac_bits)
            q = max(-32768, min(32767, q))
            out[i] = np.int16(q)
    else:
        half = rms_q88 >> 1
        for i in range(dim):
            num = int(raw_i[i] * gamma_i[i])
            if num >= 0:
                q = (num + half) // rms_q88
            else:
                q = -(((-num) + half) // rms_q88)
            q = max(-32768, min(32767, q))
            out[i] = np.int16(q)
    return out, rms_q88


def _quant_q016_from_sigmoid(x: np.ndarray) -> np.ndarray:
    s = 1.0 / (1.0 + np.exp(-x.astype(np.float64)))
    q = np.rint(s * 65536.0).astype(np.int64)
    q = np.clip(q, 0, 65535).astype(np.uint16)
    return q


def _conv1x1_q88_intmac(weight_2d: np.ndarray, x_q88: np.ndarray) -> np.ndarray:
    w_q88 = _quant_q88(weight_2d).astype(np.int64)
    x_q88_i64 = x_q88.astype(np.int64)
    acc_q1616 = w_q88 @ x_q88_i64
    y_q88 = (acc_q1616 >> 8).astype(np.int64)
    return _wrap_s16_arr(y_q88)


def _conv1x1_q88_rne_clamp(weight_2d: np.ndarray, x_q88: np.ndarray) -> np.ndarray:
    w_q88 = _quant_q88(weight_2d).astype(np.int64)
    x_q88_i64 = x_q88.astype(np.int64)
    acc_q1616 = w_q88 @ x_q88_i64
    y_q88 = _rshift_rne_vec(acc_q1616, 8)
    return _clamp_s16_arr(y_q88)


def _choose_row_scale_q15(weight_2d: np.ndarray) -> np.ndarray:
    row_max = np.max(np.abs(weight_2d.astype(np.float64)), axis=1)
    scale = np.where(row_max > 0.0, row_max / 127.0, 1.0 / 32768.0)
    scale = np.clip(scale, 1.0 / 32768.0, 65535.0 / 32768.0)
    return _quant_q15_scale(scale)


def _rshift_rne_vec(x: np.ndarray, shift: int) -> np.ndarray:
    flat = x.reshape(-1)
    out = np.empty_like(flat, dtype=np.int64)
    for i in range(flat.shape[0]):
        out[i] = _rshift_rne_i64(int(flat[i]), shift)
    return out.reshape(x.shape)


def _conv1x1_q88_scaled_intmac(
    weight_2d: np.ndarray,
    x_q88: np.ndarray,
    scale_q15: np.ndarray | None = None,
    clamp: bool = True,
) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    if scale_q15 is None:
        scale_q15 = _choose_row_scale_q15(weight_2d)
    scale_f = scale_q15.astype(np.float64) / 32768.0
    w_fold = weight_2d.astype(np.float64) / scale_f[:, None]
    w_fold_q88 = _quant_q88(w_fold).astype(np.int64)
    x_q88_i64 = x_q88.astype(np.int64)
    acc = w_fold_q88 @ x_q88_i64
    scaled = acc * scale_q15.astype(np.int64)
    y_q88 = _rshift_rne_vec(scaled, 23)
    y = _clamp_s16_arr(y_q88) if clamp else _wrap_s16_arr(y_q88)
    return y, scale_q15.astype(np.uint16), w_fold_q88.astype(np.int16)


def _sigmoid_q016_from_q88(x_q88: np.ndarray) -> np.ndarray:
    x_i = x_q88.astype(np.int64)
    x_clamp = np.clip(x_i, -1024, 1023)
    addr = (x_clamp + 1024).astype(np.int64)
    lut = np.asarray(_sigmoid_lut_values(), dtype=np.uint16)
    return lut[addr]


def _mul_q016_q88_to_q88(a_q016: np.ndarray, b_q88: np.ndarray) -> np.ndarray:
    a_i = a_q016.astype(np.int64)
    b_i = b_q88.astype(np.int64)
    prod = a_i * b_i
    y = (prod >> 16).astype(np.int64)
    return _wrap_s16_arr(y)


def _mul_q88_q88_to_q88(a_q88: np.ndarray, b_q88: np.ndarray) -> np.ndarray:
    a_i = a_q88.astype(np.int64)
    b_i = b_q88.astype(np.int64)
    prod = a_i * b_i
    y = (prod >> 8).astype(np.int64)
    return _wrap_s16_arr(y)


def _add_bias_q88_rows(x_rows: np.ndarray, bias_vec: np.ndarray | None) -> np.ndarray:
    if bias_vec is None:
        return x_rows.astype(np.int16, copy=True)
    x_i = x_rows.astype(np.int64)
    b_q88 = _quant_q88(np.asarray(bias_vec, dtype=np.float32).reshape(-1)).astype(np.int64)
    if b_q88.size != x_i.size:
        raise ValueError(f"bias size mismatch: bias={b_q88.size} rows={x_i.size}")
    return _wrap_s16_arr(x_i + b_q88.reshape(x_i.shape))


def _ssm_update_q88_from_lam_q016(lam_q016: np.ndarray, u_q88_rows: np.ndarray) -> np.ndarray:
    state_depth = int(u_q88_rows.shape[0])
    state_runtime = [[0 for _ in range(u_q88_rows.shape[1])] for _ in range(state_depth)]
    last_wr_valid = False
    last_wr_addr = 0
    last_wr_data = [0 for _ in range(u_q88_rows.shape[1])]
    out_rows: list[list[int]] = []

    for t in range(u_q88_rows.shape[0]):
        s_addr = t % state_depth
        lam_row = lam_q016[t]
        u_row = u_q88_rows[t]
        s_prev = last_wr_data[:] if (last_wr_valid and last_wr_addr == s_addr) else state_runtime[s_addr][:]
        s_new: list[int] = []
        for lane in range(u_q88_rows.shape[1]):
            lam_r = (int(lam_row[lane]) >> 8) & 0xFFFF
            one_minus = (0x0100 - lam_r) & 0xFFFF
            s_prev_s = _from_u16_signed(int(s_prev[lane]))
            u_s = int(np.int16(u_row[lane]))
            mul_a = _mul_q88_unsigned_signed(lam_r, s_prev_s)
            mul_b = _mul_q88_unsigned_signed(one_minus, u_s)
            s_new_lane = _add_wrap_s16(mul_a, mul_b)
            s_new.append(_to_u16(s_new_lane))

        s_addr_w = (s_addr + 1) % state_depth
        state_runtime[s_addr_w] = s_new[:]
        last_wr_valid = True
        last_wr_addr = s_addr_w
        last_wr_data = s_new[:]
        out_rows.append([_from_u16_signed(v) for v in s_new])

    return np.asarray(out_rows, dtype=np.int16)


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


def _ssm_update_scaled_state_q15_from_q88(u_q88_rows: np.ndarray, lam_q016_rows: np.ndarray) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    state_depth, tile = u_q88_rows.shape
    u_q88 = u_q88_rows.astype(np.int64)
    u_f = u_q88.astype(np.float32) / 256.0
    max_abs = np.abs(u_f)
    state_scale = np.where(max_abs > 0.0, max_abs / 32767.0, 1.0 / 32767.0).astype(np.float64)

    u_to_state = 1.0 / (256.0 * state_scale)
    state_to_q88 = state_scale * 256.0
    u_to_state_q16 = np.clip(np.rint(u_to_state * 65536.0), 0, 0xFFFFFFFF).astype(np.uint32)
    state_to_q88_q16 = np.clip(np.rint(state_to_q88 * 65536.0), 0, 0xFFFFFFFF).astype(np.uint32)

    # Match RTL exactly: both conversions use the emitted Q16 scale rows and
    # requant_round_sat_engine's round-to-nearest-even integer path.
    u_state = _rshift_rne_vec(u_q88 * u_to_state_q16.astype(np.int64), 16)
    u_state = np.clip(u_state, -(1 << 15), (1 << 15) - 1)
    lam_q15 = (lam_q016_rows.astype(np.int64) >> 1)
    lam_q15 = np.clip(lam_q15, 0, 1 << 15)
    one_minus_q15 = (1 << 15) - lam_q15

    state_runtime = np.zeros((state_depth, tile), dtype=np.int64)
    last_wr_valid = False
    last_wr_addr = 0
    last_wr_data = np.zeros((tile,), dtype=np.int64)
    out_state = np.zeros((state_depth, tile), dtype=np.int64)

    for t in range(state_depth):
        s_addr = t % state_depth
        if last_wr_valid and last_wr_addr == s_addr:
            s_prev = last_wr_data.copy()
        else:
            s_prev = state_runtime[s_addr].copy()

        acc = lam_q15[t] * s_prev + one_minus_q15[t] * u_state[t]
        s_new = _rshift_rne_vec(acc, 15)
        s_new = np.clip(s_new, -(1 << 15), (1 << 15) - 1)

        s_addr_w = (s_addr + 1) % state_depth
        state_runtime[s_addr_w] = s_new
        last_wr_valid = True
        last_wr_addr = s_addr_w
        last_wr_data = s_new.copy()
        out_state[t] = s_new

    ssm_q88 = _rshift_rne_vec(out_state * state_to_q88_q16.astype(np.int64), 16)
    ssm_q88 = np.clip(ssm_q88, -32768, 32767).astype(np.int16)
    return ssm_q88, u_to_state_q16, state_to_q88_q16


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


def _export_reuse_top_stage(
    case_dir: Path,
    model: torch.nn.Module,
    x_arr: np.ndarray,
) -> dict:
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

    h_raw_np = patch[0, 0].cpu().numpy()
    h_np = h[0, 0].cpu().numpy()
    u_act_np = u_act[0, 0].cpu().numpy()
    z_silu_np = z_silu[0, 0].cpu().numpy()
    dt_np = dt[0, 0].cpu().numpy()
    lam_np = lam[0, 0].cpu().numpy()
    ssm_np = ssm[0, 0].cpu().numpy()

    inproj_conv = getattr(blk.in_proj, "conv", None)
    if inproj_conv is None and hasattr(blk.in_proj, "qconv") and hasattr(blk.in_proj.qconv, "conv"):
        inproj_conv = blk.in_proj.qconv.conv
    dtproj_conv = blk.ssm.dt_proj
    outproj_conv = getattr(blk.out_proj, "conv", None)
    if outproj_conv is None and hasattr(blk.out_proj, "qconv") and hasattr(blk.out_proj.qconv, "conv"):
        outproj_conv = blk.out_proj.qconv.conv
    if inproj_conv is None:
        return {"generated": False, "reason": "unable to unwrap in_proj conv weights"}
    if outproj_conv is None:
        return {"generated": False, "reason": "unable to unwrap out_proj conv weights"}
    inproj_w = inproj_conv.weight.detach().cpu().numpy().reshape(inproj_conv.out_channels, inproj_conv.in_channels)
    dt_w = dtproj_conv.weight.detach().cpu().numpy().reshape(dtproj_conv.out_channels, dtproj_conv.in_channels)
    outproj_w = outproj_conv.weight.detach().cpu().numpy().reshape(outproj_conv.out_channels, outproj_conv.in_channels)
    h_raw_q88 = _quant_q88(h_raw_np)
    norm_gamma_q88 = _quant_q88(blk.norm.weight.detach().cpu().numpy().reshape(-1))
    h_norm_q88, rms_q88 = _rmsnorm_q88_hw(h_raw_q88, norm_gamma_q88, eps_q16=1, mode="exact_recip30")
    uv_q88 = _conv1x1_q88_rne_clamp(inproj_w, h_norm_q88)
    inproj_scale_q15 = np.full((inproj_w.shape[0],), 1 << 15, dtype=np.uint16)
    inproj_w_fold_q88 = _quant_q88(inproj_w)
    u_q88 = uv_q88[:inner]
    z_q88 = uv_q88[inner:]
    _write_mem_u16_scalar(stage_dir / "h_wr_addr.mem", list(range(32)), width_hex=2)
    _write_mem_matrix_rows_q88(stage_dir / "h_wr_data_s16_q8p8.mem", h_raw_q88.reshape(32, 4))
    _write_mem_matrix_rows_q88(stage_dir / "h_norm_golden_s16_q8p8.mem", h_norm_q88.reshape(32, 4))
    _write_mem_matrix_rows_q88(stage_dir / "norm_gamma_s16_q8p8.mem", norm_gamma_q88.reshape(32, 4))
    _write_mem_u16_scalar(stage_dir / "norm_rms_s16_q8p8.mem", [rms_q88], width_hex=4)
    _write_mem_matrix_rows_q88(stage_dir / "u_golden_q88.mem", u_q88.reshape(64, 4))
    _write_mem_matrix_rows_q88(stage_dir / "z_golden_q88.mem", z_q88.reshape(64, 4))
    u_q88_rows = u_q88.reshape(64, 4)
    u_sig_q016 = _sigmoid_q016_from_q88(u_q88_rows)
    u_act_q88 = _mul_q016_q88_to_q88(u_sig_q016, u_q88_rows)
    z_q88_rows = z_q88.reshape(64, 4)
    z_sig_q016 = _sigmoid_q016_from_q88(z_q88_rows)
    z_silu_q88 = _mul_q016_q88_to_q88(z_sig_q016, z_q88_rows)
    dt_q88_mac_flat = _conv1x1_q88_rne_clamp(dt_w, u_act_q88.reshape(-1))
    dt_scale_q15 = np.full((dt_w.shape[0],), 1 << 15, dtype=np.uint16)
    dt_w_fold_q88 = _quant_q88(dt_w)
    dt_q88_mac = dt_q88_mac_flat.reshape(64, 4)
    dt_bias = None if dtproj_conv.bias is None else dtproj_conv.bias.detach().cpu().numpy().reshape(-1)
    dt_q88 = _add_bias_q88_rows(dt_q88_mac, dt_bias)
    lam_q016 = _sigmoid_q016_from_q88(dt_q88)
    ssm_q88, state_u_to_state_q16, state_to_q88_q16 = _ssm_update_scaled_state_q15_from_q88(u_act_q88, lam_q016)
    gate_y_q88 = _mul_q88_q88_to_q88(z_silu_q88, ssm_q88)
    y_q88_flat = _conv1x1_q88_rne_clamp(outproj_w, gate_y_q88.reshape(-1))
    outproj_scale_q15 = np.full((outproj_w.shape[0],), 1 << 15, dtype=np.uint16)
    outproj_w_fold_q88 = _quant_q88(outproj_w)
    y_q88 = y_q88_flat.reshape(32, 4)

    _write_mem_matrix_rows_q88(stage_dir / "u_act_golden_q88.mem", u_act_q88)
    _write_mem_matrix_rows_q88(stage_dir / "z_silu_golden_q88.mem", z_silu_q88)
    _write_mem_matrix_rows_q88(stage_dir / "dt_golden_q88.mem", dt_q88_mac)
    _write_mem_matrix_rows_q88(stage_dir / "lam_golden_q016.mem", lam_q016.astype(np.uint16))
    _write_mem_matrix_rows_q88(stage_dir / "ssm_golden_q88.mem", ssm_q88)
    _write_mem_matrix_rows_q88(stage_dir / "gate_y_golden_q88.mem", gate_y_q88)
    _write_mem_matrix_rows_q88(stage_dir / "y_golden_q88.mem", y_q88)
    _write_scale_rows_q15(stage_dir / "inproj_scale_q15.mem", inproj_scale_q15)
    _write_scale_rows_q15(stage_dir / "dt_scale_q15.mem", dt_scale_q15)
    _write_scale_rows_q15(stage_dir / "outproj_scale_q15.mem", outproj_scale_q15)
    _write_scale_rows_q16_32(stage_dir / "state_u_to_state_q16.mem", state_u_to_state_q16)
    _write_scale_rows_q16_32(stage_dir / "state_to_q88_q16.mem", state_to_q88_q16)
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
                "Current top-level golden is block-local and ends at out_proj output before any residual add outside this RTL block.",
                "h_wr_data_s16_q8p8 is raw pre-norm patch vector; h_norm_golden_s16_q8p8 is RMSNorm output expected at in_proj input.",
                "Compare h->in_proj->u/z SRAM first, then dt/lam/ssm/gate, then y.",
                "Golden uses aligned 4-array weight banking with direct row_idx addressing for in_proj/dt/out_proj plus row-tile scale_q15 mems.",
                "Current RTL path uses ties-to-even/clamp with packed per-row scale_q15 for in_proj/dt/out_proj and dynamic scaled-state EW scan.",
                "RMSNorm hardware-like mode: exact_recip30 (fixed).",
                "For cpp-bittrue style ties-to-even/clamp/per-channel-scale comparison, see logs/final_compare_cpp_export_hw_cppish.json.",
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
                "h_wr_data_s16_q8p8": "h_wr_data_s16_q8p8.mem",
                "h_norm_golden_s16_q8p8": "h_norm_golden_s16_q8p8.mem",
                "norm_gamma_s16_q8p8": "norm_gamma_s16_q8p8.mem",
                "norm_rms_s16_q8p8": "norm_rms_s16_q8p8.mem",
                "u_golden_q88": "u_golden_q88.mem",
                "z_golden_q88": "z_golden_q88.mem",
                "u_act_golden_q88": "u_act_golden_q88.mem",
                "z_silu_golden_q88": "z_silu_golden_q88.mem",
                "dt_golden_q88": "dt_golden_q88.mem",
                "lam_golden_q016": "lam_golden_q016.mem",
                "ssm_golden_q88": "ssm_golden_q88.mem",
                "gate_y_golden_q88": "gate_y_golden_q88.mem",
                "y_golden_q88": "y_golden_q88.mem",
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
        "generated": True,
        "partial_only": False,
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
            "lam_golden_q016.mem",
            "ssm_golden_q88.mem",
            "gate_y_golden_q88.mem",
            "y_golden_q88.mem",
            "state_u_to_state_q16.mem",
            "state_to_q88_q16.mem",
            "control.json",
            "vectors.json",
            *inproj_files,
            *dt_files,
            *outproj_files,
        ],
    }


def _load_weight_2d_from_desc(base_dir: Path, conv_desc: dict) -> np.ndarray:
    w = np.load(base_dir / conv_desc["weight"]).astype(np.float32)
    return w.reshape(int(conv_desc["out_channels"]), int(conv_desc["in_channels"]))


def _make_scaled_state_runtime(u_q88_rows: np.ndarray) -> dict:
    state_depth, tile = u_q88_rows.shape
    u_q88 = u_q88_rows.astype(np.int64)
    u_f = u_q88.astype(np.float32) / 256.0
    max_abs = np.abs(u_f)
    state_scale = np.where(max_abs > 0.0, max_abs / 32767.0, 1.0 / 32767.0).astype(np.float64)
    u_to_state = 1.0 / (256.0 * state_scale)
    state_to_q88 = state_scale * 256.0
    u_to_state_q16 = np.clip(np.rint(u_to_state * 65536.0), 0, 0xFFFFFFFF).astype(np.uint32)
    state_to_q88_q16 = np.clip(np.rint(state_to_q88 * 65536.0), 0, 0xFFFFFFFF).astype(np.uint32)
    return {
        "state_depth": int(state_depth),
        "tile": int(tile),
        "u_to_state_q16": u_to_state_q16.astype(np.int64),
        "state_to_q88_q16": state_to_q88_q16.astype(np.int64),
        "state_runtime": np.zeros((state_depth, tile), dtype=np.int64),
        "last_wr_valid": False,
        "last_wr_addr": 0,
        "last_wr_data": np.zeros((tile,), dtype=np.int64),
    }


def _ssm_update_scaled_state_q15_from_q88_stateful(
    u_q88_rows: np.ndarray,
    lam_q016_rows: np.ndarray,
    runtime: dict,
) -> np.ndarray:
    state_depth = int(runtime["state_depth"])
    tile = int(runtime["tile"])
    if u_q88_rows.shape != (state_depth, tile):
        raise ValueError(f"u_q88_rows shape mismatch: got={u_q88_rows.shape} exp={(state_depth, tile)}")
    if lam_q016_rows.shape != (state_depth, tile):
        raise ValueError(f"lam_q016_rows shape mismatch: got={lam_q016_rows.shape} exp={(state_depth, tile)}")

    u_q88 = u_q88_rows.astype(np.int64)
    u_to_state_q16 = runtime["u_to_state_q16"].astype(np.int64)
    state_to_q88_q16 = runtime["state_to_q88_q16"].astype(np.int64)
    state_runtime = runtime["state_runtime"].astype(np.int64)
    last_wr_valid = bool(runtime["last_wr_valid"])
    last_wr_addr = int(runtime["last_wr_addr"])
    last_wr_data = runtime["last_wr_data"].astype(np.int64)

    u_state = _rshift_rne_vec(u_q88 * u_to_state_q16, 16)
    u_state = np.clip(u_state, -(1 << 15), (1 << 15) - 1)
    lam_q15 = (lam_q016_rows.astype(np.int64) >> 1)
    lam_q15 = np.clip(lam_q15, 0, 1 << 15)
    one_minus_q15 = (1 << 15) - lam_q15

    out_state = np.zeros((state_depth, tile), dtype=np.int64)
    for t in range(state_depth):
        s_addr = t % state_depth
        if last_wr_valid and last_wr_addr == s_addr:
            s_prev = last_wr_data.copy()
        else:
            s_prev = state_runtime[s_addr].copy()

        acc = lam_q15[t] * s_prev + one_minus_q15[t] * u_state[t]
        s_new = _rshift_rne_vec(acc, 15)
        s_new = np.clip(s_new, -(1 << 15), (1 << 15) - 1)

        s_addr_w = (s_addr + 1) % state_depth
        state_runtime[s_addr_w] = s_new
        last_wr_valid = True
        last_wr_addr = s_addr_w
        last_wr_data = s_new.copy()
        out_state[t] = s_new

    runtime["state_runtime"] = state_runtime
    runtime["last_wr_valid"] = bool(last_wr_valid)
    runtime["last_wr_addr"] = int(last_wr_addr)
    runtime["last_wr_data"] = last_wr_data

    ssm_q88 = _rshift_rne_vec(out_state * state_to_q88_q16, 16)
    ssm_q88 = np.clip(ssm_q88, -32768, 32767).astype(np.int16)
    return ssm_q88


def _export_chain4_stream_continuous_golden(
    case_dir: Path,
    export_json: Path,
    n_frames: int = 3,
) -> dict:
    export, backbone, base_dir = _load_export_ir(export_json)
    blocks = backbone.get("blocks", [])
    if len(blocks) < 4:
        return {"generated": False, "reason": f"need >=4 blocks, got {len(blocks)}"}

    stage_b0 = case_dir / "stages" / "reuse_mamba_block_top_block0"
    if not (stage_b0 / "h_wr_data_s16_q8p8.mem").exists():
        return {"generated": False, "reason": "missing block0 input mem"}

    h_rows = _load_packed_mem_q88(stage_b0 / "h_wr_data_s16_q8p8.mem")
    if h_rows.shape != (32, 4):
        return {"generated": False, "reason": f"unexpected h shape: {h_rows.shape}"}
    h0_q88 = _quant_q88(h_rows.reshape(-1)).astype(np.int16)

    blk_cache = []
    for bi in range(4):
        blk = blocks[bi]
        norm_gamma = np.load(base_dir / blk["norm"]["weight"]).astype(np.float32).reshape(-1)
        in_w = _load_weight_2d_from_desc(base_dir, blk["in_proj"])
        dt_w = _load_weight_2d_from_desc(base_dir, blk["ssm"]["dt_proj"])
        out_w = _load_weight_2d_from_desc(base_dir, blk["out_proj"])
        dt_bias = None
        if blk["ssm"]["dt_proj"].get("bias_file"):
            dt_bias = np.load(base_dir / blk["ssm"]["dt_proj"]["bias_file"]).astype(np.float32).reshape(-1)
        blk_cache.append(
            {
                "norm_gamma_q88": _quant_q88(norm_gamma),
                "in_w": in_w,
                "dt_w": dt_w,
                "out_w": out_w,
                "dt_bias": dt_bias,
                "runtime": None,
            }
        )

    chain_dir = case_dir / "stages" / "reuse_mamba_block_top_chain4"
    chain_dir.mkdir(parents=True, exist_ok=True)
    dbg_dir = chain_dir / "stream_debug"
    dbg_dir.mkdir(parents=True, exist_ok=True)

    y_stream_rows: list[list[int]] = []
    debug_files: list[str] = []
    x_in = h0_q88.copy()
    for fi in range(int(n_frames)):
        x_blk = x_in.copy()
        y_blk3 = np.zeros((32, 4), dtype=np.int16)
        b3_h_norm = np.zeros((32, 4), dtype=np.int16)
        b3_u_act = np.zeros((64, 4), dtype=np.int16)
        b3_dt = np.zeros((64, 4), dtype=np.int16)
        b3_gate = np.zeros((64, 4), dtype=np.int16)
        for bi in range(4):
            bc = blk_cache[bi]
            inner = int(blocks[bi]["d_inner"])
            h_norm_q88, _ = _rmsnorm_q88_hw(x_blk, bc["norm_gamma_q88"], eps_q16=1, mode="exact_recip30")
            uv_q88 = _conv1x1_q88_rne_clamp(bc["in_w"], h_norm_q88)
            u_q88_rows = uv_q88[:inner].reshape(64, 4)
            z_q88_rows = uv_q88[inner:].reshape(64, 4)
            u_sig_q016 = _sigmoid_q016_from_q88(u_q88_rows)
            z_sig_q016 = _sigmoid_q016_from_q88(z_q88_rows)
            u_act_q88 = _mul_q016_q88_to_q88(u_sig_q016, u_q88_rows)
            z_silu_q88 = _mul_q016_q88_to_q88(z_sig_q016, z_q88_rows)
            dt_q88_mac = _conv1x1_q88_rne_clamp(bc["dt_w"], u_act_q88.reshape(-1)).reshape(64, 4)
            dt_q88 = _add_bias_q88_rows(dt_q88_mac, bc["dt_bias"])
            lam_q016 = _sigmoid_q016_from_q88(dt_q88)
            if bc["runtime"] is None:
                bc["runtime"] = _make_scaled_state_runtime(u_act_q88)
            ssm_q88 = _ssm_update_scaled_state_q15_from_q88_stateful(u_act_q88, lam_q016, bc["runtime"])
            gate_y_q88 = _mul_q88_q88_to_q88(z_silu_q88, ssm_q88)
            y_q88 = _conv1x1_q88_rne_clamp(bc["out_w"], gate_y_q88.reshape(-1)).reshape(32, 4).astype(np.int16)
            x_next_q88 = _clamp_s16_arr(x_blk.astype(np.int64).reshape(32, 4) + y_q88.astype(np.int64)).reshape(-1).astype(np.int16)
            x_blk = x_next_q88
            if bi == 3:
                b3_h_norm = h_norm_q88.reshape(32, 4).astype(np.int16)
                b3_u_act = u_act_q88.reshape(64, 4).astype(np.int16)
                b3_dt = dt_q88_mac.reshape(64, 4).astype(np.int16)
                b3_gate = gate_y_q88.reshape(64, 4).astype(np.int16)
                y_blk3 = y_q88.copy()
        for r in range(32):
            y_stream_rows.append([int(v) & 0xFFFF for v in y_blk3[r].tolist()])
        fn_h_norm = f"stream_debug/frame{fi:02d}_block3_rmsnorm_q88.mem"
        fn_u_act = f"stream_debug/frame{fi:02d}_block3_uact_q88.mem"
        fn_dt = f"stream_debug/frame{fi:02d}_block3_dt_q88.mem"
        fn_gate = f"stream_debug/frame{fi:02d}_block3_gate_y_q88.mem"
        fn_out = f"stream_debug/frame{fi:02d}_block3_outproj_y_q88.mem"
        _write_mem_matrix_rows_q88(chain_dir / fn_h_norm, b3_h_norm)
        _write_mem_matrix_rows_q88(chain_dir / fn_u_act, b3_u_act)
        _write_mem_matrix_rows_q88(chain_dir / fn_dt, b3_dt)
        _write_mem_matrix_rows_q88(chain_dir / fn_gate, b3_gate)
        _write_mem_matrix_rows_q88(chain_dir / fn_out, y_blk3)
        debug_files.extend([fn_h_norm, fn_u_act, fn_dt, fn_gate, fn_out])
        x_in = h0_q88.copy()

    out_mem = chain_dir / "stream_y_golden_q88.mem"
    _write_mem_packed_u16(out_mem, y_stream_rows)
    _write_json(
        chain_dir / "stream_manifest.json",
        {
            "generated": True,
            "n_frames": int(n_frames),
            "rows_per_frame": 32,
            "file": "stream_y_golden_q88.mem",
            "notes": [
                "Continuous-state golden for board-shell stream mode.",
                "Each frame reuses the same block0 h input; EW state is carried across frames.",
            ],
            "debug_files": debug_files,
        },
    )
    return {
        "generated": True,
        "n_frames": int(n_frames),
        "file": "stream_y_golden_q88.mem",
        "manifest": "stream_manifest.json",
        "debug_files": debug_files,
    }


def _export_reuse_top_block_from_ir(
    stage_dir: Path,
    blk_desc: dict,
    base_dir: Path,
    h_in_f32: np.ndarray,
) -> dict:
    inner = int(blk_desc["d_inner"])
    d_model = int(blk_desc["d_model"])
    h_in = h_in_f32.astype(np.float32).reshape(-1)
    if h_in.shape[0] != d_model:
        raise ValueError(f"block input shape mismatch: expected {d_model}, got {h_in.shape[0]}")

    norm_gamma = np.load(base_dir / blk_desc["norm"]["weight"]).astype(np.float32).reshape(-1)
    norm_gamma_q88 = _quant_q88(norm_gamma)
    h_raw_q88 = _quant_q88(h_in)
    h_norm_q88, rms_q88 = _rmsnorm_q88_hw(h_raw_q88, norm_gamma_q88, eps_q16=1, mode="exact_recip30")

    inproj_w = _load_weight_2d_from_desc(base_dir, blk_desc["in_proj"])
    dtproj_w = _load_weight_2d_from_desc(base_dir, blk_desc["ssm"]["dt_proj"])
    outproj_w = _load_weight_2d_from_desc(base_dir, blk_desc["out_proj"])
    dt_bias = None
    if blk_desc["ssm"]["dt_proj"].get("bias_file"):
        dt_bias = np.load(base_dir / blk_desc["ssm"]["dt_proj"]["bias_file"]).astype(np.float32).reshape(-1)
    dt_bias_q88 = np.zeros((64, 4), dtype=np.int16)
    if dt_bias is not None:
        dt_bias_q88 = _quant_q88(dt_bias).reshape(64, 4)

    uv_q88 = _conv1x1_q88_rne_clamp(inproj_w, h_norm_q88)
    u_q88 = uv_q88[:inner]
    z_q88 = uv_q88[inner:]

    u_q88_rows = u_q88.reshape(64, 4)
    z_q88_rows = z_q88.reshape(64, 4)
    u_sig_q016 = _sigmoid_q016_from_q88(u_q88_rows)
    z_sig_q016 = _sigmoid_q016_from_q88(z_q88_rows)
    u_act_q88 = _mul_q016_q88_to_q88(u_sig_q016, u_q88_rows)
    z_silu_q88 = _mul_q016_q88_to_q88(z_sig_q016, z_q88_rows)

    dt_q88_mac = _conv1x1_q88_rne_clamp(dtproj_w, u_act_q88.reshape(-1)).reshape(64, 4)
    dt_q88 = _add_bias_q88_rows(dt_q88_mac, dt_bias)
    lam_q016 = _sigmoid_q016_from_q88(dt_q88)
    ssm_q88, state_u_to_state_q16, state_to_q88_q16 = _ssm_update_scaled_state_q15_from_q88(u_act_q88, lam_q016)
    gate_y_q88 = _mul_q88_q88_to_q88(z_silu_q88, ssm_q88)

    y_q88 = _conv1x1_q88_rne_clamp(outproj_w, gate_y_q88.reshape(-1)).reshape(32, 4)
    x_next_q88 = _clamp_s16_arr(h_raw_q88.astype(np.int64).reshape(32, 4) + y_q88.astype(np.int64))
    x_next_f32 = x_next_q88.astype(np.float32).reshape(-1) / 256.0

    inproj_scale_q15 = np.full((inproj_w.shape[0],), 1 << 15, dtype=np.uint16)
    dt_scale_q15 = np.full((dtproj_w.shape[0],), 1 << 15, dtype=np.uint16)
    outproj_scale_q15 = np.full((outproj_w.shape[0],), 1 << 15, dtype=np.uint16)
    inproj_w_fold_q88 = _quant_q88(inproj_w)
    dt_w_fold_q88 = _quant_q88(dtproj_w)
    outproj_w_fold_q88 = _quant_q88(outproj_w)

    _write_mem_u16_scalar(stage_dir / "h_wr_addr.mem", list(range(32)), width_hex=2)
    _write_mem_matrix_rows_q88(stage_dir / "h_wr_data_s16_q8p8.mem", h_raw_q88.reshape(32, 4))
    _write_mem_matrix_rows_q88(stage_dir / "h_norm_golden_s16_q8p8.mem", h_norm_q88.reshape(32, 4))
    _write_mem_matrix_rows_q88(stage_dir / "norm_gamma_s16_q8p8.mem", norm_gamma_q88.reshape(32, 4))
    _write_mem_u16_scalar(stage_dir / "norm_rms_s16_q8p8.mem", [rms_q88], width_hex=4)
    _write_mem_matrix_rows_q88(stage_dir / "u_golden_q88.mem", u_q88.reshape(64, 4))
    _write_mem_matrix_rows_q88(stage_dir / "z_golden_q88.mem", z_q88.reshape(64, 4))
    _write_mem_matrix_rows_q88(stage_dir / "u_act_golden_q88.mem", u_act_q88)
    _write_mem_matrix_rows_q88(stage_dir / "z_silu_golden_q88.mem", z_silu_q88)
    _write_mem_matrix_rows_q88(stage_dir / "dt_golden_q88.mem", dt_q88_mac)
    _write_mem_matrix_rows_q88(stage_dir / "bias_ROM.mem", dt_bias_q88)
    _write_mem_matrix_rows_q88(stage_dir / "lam_golden_q016.mem", lam_q016.astype(np.uint16))
    _write_mem_matrix_rows_q88(stage_dir / "ssm_golden_q88.mem", ssm_q88)
    _write_mem_matrix_rows_q88(stage_dir / "gate_y_golden_q88.mem", gate_y_q88)
    _write_mem_matrix_rows_q88(stage_dir / "y_golden_q88.mem", y_q88)
    _write_mem_matrix_rows_q88(stage_dir / "x_next_golden_q88.mem", x_next_q88)
    _write_scale_rows_q15(stage_dir / "inproj_scale_q15.mem", inproj_scale_q15)
    _write_scale_rows_q15(stage_dir / "dt_scale_q15.mem", dt_scale_q15)
    _write_scale_rows_q15(stage_dir / "outproj_scale_q15.mem", outproj_scale_q15)
    _write_scale_rows_q16_32(stage_dir / "state_u_to_state_q16.mem", state_u_to_state_q16)
    _write_scale_rows_q16_32(stage_dir / "state_to_q88_q16.mem", state_to_q88_q16)

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
        "x_next_f32": x_next_f32,
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
    samples = case_dir / "float" / "samples.npy"
    if not samples.exists():
        return {"generated": False, "reason": "float/samples.npy missing"}

    try:
        from refactor.bittrue.eval_hw_like_full import _forward_full_hw_like
    except Exception as exc:
        return {"generated": False, "reason": f"failed to import eval_hw_like_full: {exc}"}

    x_arr = np.load(samples).astype(np.float32)
    if x_arr.shape[0] <= int(sample_idx):
        return {"generated": False, "reason": f"sample_idx {sample_idx} out of range"}

    _, backbone, base_dir = _load_export_ir(export_json)
    blocks = backbone.get("blocks", [])
    n_block = min(int(max_blocks), len(blocks))
    if n_block <= 0:
        return {"generated": False, "reason": "no blocks in backbone export"}

    _, hw_traces = _forward_full_hw_like(export_json, x_arr[int(sample_idx)], scan_mode="scaled_state")
    trace_map = {t["stage"]: t for t in hw_traces}
    if "patch_embedding_q88_if" not in trace_map:
        return {"generated": False, "reason": "patch_embedding_q88_if trace missing"}

    x_in = trace_map["patch_embedding_q88_if"]["x_next"][0].astype(np.float32).reshape(-1)
    block_manifests = []
    last_stage_dir: Path | None = None
    for bi in range(n_block):
        stage_name = f"reuse_mamba_block_top_block{bi}"
        stage_dir = case_dir / "stages" / stage_name
        stage_dir.mkdir(parents=True, exist_ok=True)
        block_out = _export_reuse_top_block_from_ir(stage_dir, blocks[bi], base_dir, x_in)
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


def _export_reuse_ssm_core_stage(case_dir: Path, model: torch.nn.Module, x_arr: np.ndarray) -> dict:
    stage_dir = case_dir / "stages" / "reuse_ssm_core"
    bb = model.backbone
    if len(bb.blocks) == 0:
        return {"generated": False, "reason": "backbone has no blocks"}
    blk = bb.blocks[0]
    dev = next(model.parameters()).device
    x0 = torch.from_numpy(x_arr[:1]).float().to(dev)
    with torch.inference_mode():
        xp = x0.permute(0, 2, 1)
        proj = model.proj(xp)
        patch = bb.patch_embedding(proj).permute(0, 2, 1)
        if bb.pe_on:
            pe = bb.pe_buf.to(device=patch.device, dtype=patch.dtype)
            patch = patch + bb.pe_scale * pe.unsqueeze(0)
        if patch.shape[1] != 1:
            return {
                "generated": False,
                "reason": f"reuse_ssm_core currently assumes one patch/token, got num_patches={int(patch.shape[1])}",
            }
        h = blk.norm(patch)
        uv = blk.in_proj(h.permute(0, 2, 1)).permute(0, 2, 1)
        inner = blk.args.d_inner
        u = uv[..., :inner]
        z = uv[..., inner:]
        if blk.dw_conv is not None:
            u = blk.dw_conv(u.permute(0, 2, 1)).permute(0, 2, 1)
        u_act = blk.act(u)
        z_silu = blk.act(z)
        dt = blk.ssm.dt_proj(u_act.permute(0, 2, 1)).permute(0, 2, 1)

    inproj_conv = getattr(blk.in_proj, "conv", None)
    if inproj_conv is None and hasattr(blk.in_proj, "qconv") and hasattr(blk.in_proj.qconv, "conv"):
        inproj_conv = blk.in_proj.qconv.conv
    dtproj_conv = blk.ssm.dt_proj
    if inproj_conv is None:
        return {"generated": False, "reason": "unable to unwrap in_proj conv weights"}
    inproj_w = inproj_conv.weight.detach().cpu().numpy().reshape(inproj_conv.out_channels, inproj_conv.in_channels)
    dt_w = dtproj_conv.weight.detach().cpu().numpy().reshape(dtproj_conv.out_channels, dtproj_conv.in_channels)

    h_q88 = _quant_q88(h[0, 0].cpu().numpy())
    uv_q88 = _conv1x1_q88_intmac(inproj_w, h_q88)
    u_q88 = uv_q88[:inner]
    z_q88 = uv_q88[inner:]
    u_q88_rows = u_q88.reshape(64, 4)
    u_sig_q016 = _sigmoid_q016_from_q88(u_q88_rows)
    u_act_q88 = _mul_q016_q88_to_q88(u_sig_q016, u_q88_rows)
    z_q88_rows = z_q88.reshape(64, 4)
    z_sig_q016 = _sigmoid_q016_from_q88(z_q88_rows)
    z_silu_q88 = _mul_q016_q88_to_q88(z_sig_q016, z_q88_rows)
    dt_q88_mac = _conv1x1_q88_intmac(dt_w, u_act_q88.reshape(-1)).reshape(64, 4)
    dt_bias = None if dtproj_conv.bias is None else dtproj_conv.bias.detach().cpu().numpy().reshape(-1)
    dt_q88 = _add_bias_q88_rows(dt_q88_mac, dt_bias)
    lam_q016 = _sigmoid_q016_from_q88(dt_q88)
    ssm_q88, state_u_to_state_q16, state_to_q88_q16 = _ssm_update_scaled_state_q15_from_q88(u_act_q88, lam_q016)
    gate_y_q88 = _mul_q88_q88_to_q88(z_silu_q88, ssm_q88)

    _write_mem_matrix_rows_q88(stage_dir / "mac_in_q88.mem", dt_q88_mac)
    _write_mem_matrix_rows_q88(stage_dir / "xt_in_q88.mem", u_act_q88)
    _write_mem_matrix_rows_q88(stage_dir / "g_in_q88.mem", z_silu_q88)
    _write_mem_matrix_rows_q88(stage_dir / "dt_golden_q88.mem", dt_q88_mac)
    _write_mem_matrix_rows_q88(stage_dir / "lam_golden_q016.mem", lam_q016.astype(np.uint16))
    _write_mem_matrix_rows_q88(stage_dir / "ssm_golden_q88.mem", ssm_q88)
    _write_mem_matrix_rows_q88(stage_dir / "gate_y_golden_q88.mem", gate_y_q88)
    _write_scale_rows_q16_32(stage_dir / "state_u_to_state_q16.mem", state_u_to_state_q16)
    _write_scale_rows_q16_32(stage_dir / "state_to_q88_q16.mem", state_to_q88_q16)
    _write_json(
        stage_dir / "vectors.json",
        {
            "d_inner": int(inner),
            "files": {
                "mac_in_q88": "mac_in_q88.mem",
                "xt_in_q88": "xt_in_q88.mem",
                "g_in_q88": "g_in_q88.mem",
                "dt_golden_q88": "dt_golden_q88.mem",
                "lam_golden_q016": "lam_golden_q016.mem",
                "ssm_golden_q88": "ssm_golden_q88.mem",
                "gate_y_golden_q88": "gate_y_golden_q88.mem",
                "state_u_to_state_q16": "state_u_to_state_q16.mem",
                "state_to_q88_q16": "state_to_q88_q16.mem",
            },
            "notes": [
                "mac_in_q88/dt_golden_q88 are pre-bias dt_mac vectors that feed reuse_ssm_core mac_m_valid/mac_vec directly.",
                "lam/ssm/gate_y golden include on-chip bias ROM addition before sigmoid.",
            ],
        },
    )
    return {
        "generated": True,
        "files": [
            "mac_in_q88.mem",
            "xt_in_q88.mem",
            "g_in_q88.mem",
            "dt_golden_q88.mem",
            "lam_golden_q016.mem",
            "ssm_golden_q88.mem",
            "gate_y_golden_q88.mem",
            "state_u_to_state_q16.mem",
            "state_to_q88_q16.mem",
            "vectors.json",
        ],
    }


def _export_reuse_ssm_dt_scheduler_stage(case_dir: Path, model: torch.nn.Module, x_arr: np.ndarray) -> dict:
    stage_dir = case_dir / "stages" / "reuse_ssm_dt_scheduler"
    bb = model.backbone
    if len(bb.blocks) == 0:
        return {"generated": False, "reason": "backbone has no blocks"}
    blk = bb.blocks[0]
    dev = next(model.parameters()).device
    x0 = torch.from_numpy(x_arr[:1]).float().to(dev)
    with torch.inference_mode():
        xp = x0.permute(0, 2, 1)
        proj = model.proj(xp)
        patch = bb.patch_embedding(proj).permute(0, 2, 1)
        if bb.pe_on:
            pe = bb.pe_buf.to(device=patch.device, dtype=patch.dtype)
            patch = patch + bb.pe_scale * pe.unsqueeze(0)
        if patch.shape[1] != 1:
            return {
                "generated": False,
                "reason": f"reuse_ssm_dt_scheduler currently assumes one patch/token, got num_patches={int(patch.shape[1])}",
            }
        h = blk.norm(patch)

    inproj_conv = getattr(blk.in_proj, "conv", None)
    if inproj_conv is None and hasattr(blk.in_proj, "qconv") and hasattr(blk.in_proj.qconv, "conv"):
        inproj_conv = blk.in_proj.qconv.conv
    dtproj_conv = blk.ssm.dt_proj
    if inproj_conv is None:
        return {"generated": False, "reason": "unable to unwrap in_proj conv weights"}
    inproj_w = inproj_conv.weight.detach().cpu().numpy().reshape(inproj_conv.out_channels, inproj_conv.in_channels)
    dt_w = dtproj_conv.weight.detach().cpu().numpy().reshape(dtproj_conv.out_channels, dtproj_conv.in_channels)

    h_q88 = _quant_q88(h[0, 0].cpu().numpy())
    uv_q88 = _conv1x1_q88_rne_clamp(inproj_w, h_q88)
    inproj_w_fold_q88 = _quant_q88(inproj_w)
    inner = blk.args.d_inner
    u_q88 = uv_q88[:inner]
    u_q88_rows = u_q88.reshape(64, 4)
    u_sig_q016 = _sigmoid_q016_from_q88(u_q88_rows)
    u_act_q88 = _mul_q016_q88_to_q88(u_sig_q016, u_q88_rows)
    dt_q88_flat = _conv1x1_q88_rne_clamp(dt_w, u_act_q88.reshape(-1))
    dt_scale_q15 = np.full((dt_w.shape[0],), 1 << 15, dtype=np.uint16)
    dt_w_fold_q88 = _quant_q88(dt_w)
    dt_q88 = dt_q88_flat.reshape(64, 4)
    xt_q88 = u_act_q88.copy()

    _write_mem_matrix_rows_q88(stage_dir / "u_act_in_q88.mem", u_act_q88)
    _write_mem_matrix_rows_q88(stage_dir / "dt_golden_q88.mem", dt_q88)
    _write_mem_matrix_rows_q88(stage_dir / "xt_golden_q88.mem", xt_q88)
    _write_scale_rows_q15(stage_dir / "dt_scale_q15.mem", dt_scale_q15)
    dt_files = _write_weight_banks_q88_aligned_4array(
        stage_dir / "dt_wbuf", dt_w_fold_q88.astype(np.float32) / 256.0, n_bank=6, depth=1024
    )
    _write_json(
        stage_dir / "vectors.json",
        {
            "d_inner": int(inner),
            "files": {
                "u_act_in_q88": "u_act_in_q88.mem",
                "dt_golden_q88": "dt_golden_q88.mem",
                "xt_golden_q88": "xt_golden_q88.mem",
                "dt_scale_q15": "dt_scale_q15.mem",
                "dt_wbuf": dt_files,
            },
            "notes": [
                "u_act_in_q88 is the dt scheduler read source.",
                "xt_golden_q88 is the direct u_act row stream aligned one-to-one with dt output rows.",
                "dt_wbuf uses the aligned 4-array bank layout (bank=array index, addr=row_tile*groups+group).",
            ],
        },
    )
    return {
        "generated": True,
        "files": [
            "u_act_in_q88.mem",
            "dt_golden_q88.mem",
            "xt_golden_q88.mem",
            "dt_scale_q15.mem",
            "vectors.json",
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
        elif stage["name"] == "reuse_ssm_core":
            manifest["generated_artifacts"] = _export_reuse_ssm_core_stage(out_dir, model, x_arr)
        elif stage["name"] == "reuse_ssm_dt_scheduler":
            manifest["generated_artifacts"] = _export_reuse_ssm_dt_scheduler_stage(out_dir, model, x_arr)
        elif stage["name"] == "reuse_mamba_block_top":
            manifest["generated_artifacts"] = _export_reuse_top_stage(
                out_dir,
                model,
                x_arr,
            )
        else:
            manifest["generated_artifacts"] = {"generated": False}
        _write_json(stage_dir / "manifest.json", manifest)

    compare_summary = _export_block0_cpp_compare(out_dir, Path(export_json))
    _write_json(out_dir / "logs" / "block0_cpp_compare_manifest.json", compare_summary)
    dt_chain_summary = _export_dt_chain_debug(out_dir, Path(export_json), sample_idx=0)
    _write_json(out_dir / "logs" / "dt_chain_debug_manifest.json", dt_chain_summary)
    chain4_summary = _export_reuse_top_four_block_chain(
        out_dir,
        Path(export_json),
        sample_idx=0,
        max_blocks=4,
    )
    _write_json(out_dir / "logs" / "block_chain4_manifest.json", chain4_summary)
    stream_chain4_summary = _export_chain4_stream_continuous_golden(
        out_dir,
        Path(export_json),
        n_frames=3,
    )
    _write_json(out_dir / "logs" / "block_chain4_stream_manifest.json", stream_chain4_summary)
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
        "dt_chain_debug": dt_chain_summary,
        "chain4_debug": chain4_summary,
        "chain4_stream_debug": stream_chain4_summary,
        "ip_init": ip_init_summary,
        "next_steps": [
            "Populate stage-specific mem files under stages/<stage>/ or mem/<stage>/.",
            "Run cocotb tests from HW_reconstruct/hw_debug/cocotb.",
            "Collect rtl_out/* and compare against golden stage outputs.",
        ],
    }
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
