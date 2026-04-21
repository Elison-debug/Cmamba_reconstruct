from __future__ import annotations

import argparse
import json
import os
import subprocess
from concurrent.futures import ProcessPoolExecutor, as_completed
from pathlib import Path

import numpy as np

from refactor.bittrue.eval_bittrue import _metric_dict
from refactor.bittrue.export_hw_debug import (
    _ActLut,
    _add_bias_q88_rows,
    _compute_block0_local_y_cppish,  # kept importable sanity anchor
    _conv1d_run_integer_desc,
    _conv1x1_q88_rne_clamp,
    _load_export_ir,
    _mul_q016_q88_to_q88,
    _mul_q88_q88_to_q88,
    _quant_q88,
    _rmsnorm_inplace_np,
    _rmsnorm_q88_hw,
    _sigmoid_q016_from_q88,
    _ssm_update_q88_from_lam_q016,
)


def _write_json(path: Path, obj: dict | list) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2), encoding="utf-8")


def _run_cpp_batch(
    cpp_batch_bin: Path,
    export_json: Path,
    samples_npy: Path,
    out_npy: Path,
    din: int,
    mode: str = "int16",
) -> np.ndarray:
    cmd = [
        str(cpp_batch_bin),
        str(export_json),
        str(samples_npy),
        str(out_npy),
        str(din),
        "--mode",
        mode,
    ]
    subprocess.run(cmd, check=True)
    return np.load(out_npy).astype(np.float32)


def _conv1x1_q88_rne_clamp_tc(weight_2d: np.ndarray, x_tc: np.ndarray) -> np.ndarray:
    rows = []
    for t in range(x_tc.shape[0]):
        rows.append(_conv1x1_q88_rne_clamp(weight_2d, _quant_q88(x_tc[t])))
    return np.stack(rows, axis=0).astype(np.int16)


def _rshift_rne_i64_vec(x: np.ndarray, shift: int) -> np.ndarray:
    base = 1 << int(shift)
    q = x // base
    r = x % base
    half = base >> 1
    return q + ((r > half) | ((r == half) & ((q & 1) != 0))).astype(np.int64)


def _ssm_update_scaled_state_q15(lam_q016_rows: np.ndarray, u_q88_rows: np.ndarray, t_len: int, d_inner: int) -> np.ndarray:
    u_q88 = u_q88_rows.reshape(t_len, d_inner).astype(np.int64)
    u_f = u_q88.astype(np.float32) / 256.0
    max_abs = np.max(np.abs(u_f), axis=0)
    state_scale = np.where(max_abs > 0.0, max_abs / 32767.0, 1.0 / 32767.0).astype(np.float32)
    u_state = np.rint(u_f / state_scale.reshape(1, -1)).astype(np.int64)
    u_state = np.clip(u_state, -(1 << 15), (1 << 15) - 1)

    lam_q15 = (lam_q016_rows.reshape(t_len, d_inner).astype(np.int64) >> 1)
    lam_q15 = np.clip(lam_q15, 0, 1 << 15)
    one_minus_q15 = (1 << 15) - lam_q15

    s_state = np.zeros((d_inner,), dtype=np.int64)
    out_state = np.zeros((t_len, d_inner), dtype=np.int64)
    for t in range(t_len):
        acc = lam_q15[t] * s_state + one_minus_q15[t] * u_state[t]
        s_state = _rshift_rne_i64_vec(acc, 15)
        s_state = np.clip(s_state, -(1 << 15), (1 << 15) - 1)
        out_state[t] = s_state

    ssm_f = out_state.astype(np.float32) * state_scale.reshape(1, -1)
    return _quant_q88(ssm_f).reshape(-1, 4)


def _block_forward_cppish(blk: dict, base_dir: Path, x_seq: np.ndarray, lut: _ActLut) -> tuple[np.ndarray, dict]:
    residual = x_seq.astype(np.float32, copy=True)
    x_norm = residual.copy()
    _rmsnorm_inplace_np(x_norm, blk["norm"], base_dir)

    uv = _conv1d_run_integer_desc(blk["in_proj"], base_dir, x_norm, x_norm.shape[0], bits=16)
    inner = int(blk["d_inner"])
    u = uv[:, :inner]
    z = uv[:, inner:]
    u_act = lut.silu_fn(u)
    z_silu = lut.silu_fn(z)
    dt = _conv1d_run_integer_desc(blk["ssm"]["dt_proj"], base_dir, u_act, u_act.shape[0], bits=16)

    t_len = int(u_act.shape[0])
    d_inner = int(u_act.shape[1])
    ssm_scan = np.zeros_like(u_act, dtype=np.float32)
    gate_y = np.zeros_like(u_act, dtype=np.float32)
    frac_bits = 15
    qmin = -(1 << 15)
    qmax = (1 << 15) - 1

    state_scale = np.ones((d_inner,), dtype=np.float32) / 127.0
    for c in range(d_inner):
        mx = float(np.max(np.abs(u_act[:, c])))
        state_scale[c] = (mx / float(qmax)) if mx > 0.0 else (1.0 / float(qmax))
    gate_scale = np.ones((d_inner,), dtype=np.float32) / 127.0

    s_q = np.zeros((d_inner,), dtype=np.int32)
    lam = lut.sigmoid(dt)
    gate = z_silu
    for c in range(d_inner):
        mx = float(np.max(np.abs(gate[:, c])))
        gate_scale[c] = (mx / float(qmax)) if mx > 0.0 else (1.0 / float(qmax))

    for t in range(t_len):
        for c in range(d_inner):
            lam_q = int(np.rint(float(lam[t, c]) * float(1 << frac_bits)))
            lam_q = max(0, min(1 << frac_bits, lam_q))
            u_q = int(np.rint(float(u_act[t, c]) / float(state_scale[c])))
            u_q = max(qmin, min(qmax, u_q))
            acc = lam_q * int(s_q[c]) + ((1 << frac_bits) - lam_q) * u_q
            s_new = int(np.rint(acc / float(1 << frac_bits)))
            s_new = max(qmin, min(qmax, s_new))
            s_q[c] = s_new
            ssm_scan[t, c] = float(s_new) * float(state_scale[c])
        for c in range(d_inner):
            qg = int(np.rint(float(gate[t, c]) / float(gate_scale[c])))
            qg = max(qmin, min(qmax, qg))
            gate_y[t, c] = float(ssm_scan[t, c]) * float(qg) * float(gate_scale[c])

    y_blk = _conv1d_run_integer_desc(blk["out_proj"], base_dir, gate_y, gate_y.shape[0], bits=16)
    x_next = residual + y_blk
    return x_next.astype(np.float32), {
        "x_norm": x_norm,
        "u": u.astype(np.float32),
        "z": z.astype(np.float32),
        "u_act": u_act.astype(np.float32),
        "z_silu": z_silu.astype(np.float32),
        "dt": dt.astype(np.float32),
        "lam": lam.astype(np.float32),
        "ssm_scan": ssm_scan.astype(np.float32),
        "gate_y": gate_y.astype(np.float32),
        "y_blk": y_blk.astype(np.float32),
        "x_next": x_next.astype(np.float32),
    }


def _block_forward_hw_like(blk: dict, base_dir: Path, x_seq: np.ndarray, scan_mode: str = "fixed_q88") -> tuple[np.ndarray, dict]:
    residual = x_seq.astype(np.float32, copy=True)
    norm_w = np.load(base_dir / blk["norm"]["weight"]).astype(np.float32).reshape(-1)
    norm_w_q88 = _quant_q88(norm_w)
    residual_q88 = _quant_q88(residual.reshape(-1))
    x_norm_q88, _rms_q88 = _rmsnorm_q88_hw(residual_q88, norm_w_q88)
    x_norm = (x_norm_q88.astype(np.float32) / 256.0).reshape(residual.shape)

    inner = int(blk["d_inner"])
    in_w = np.load(base_dir / blk["in_proj"]["weight"]).astype(np.float32).reshape(int(blk["in_proj"]["out_channels"]), int(blk["in_proj"]["in_channels"]))
    dt_w = np.load(base_dir / blk["ssm"]["dt_proj"]["weight"]).astype(np.float32).reshape(int(blk["ssm"]["dt_proj"]["out_channels"]), int(blk["ssm"]["dt_proj"]["in_channels"]))
    out_w = np.load(base_dir / blk["out_proj"]["weight"]).astype(np.float32).reshape(int(blk["out_proj"]["out_channels"]), int(blk["out_proj"]["in_channels"]))

    uv_q88_flat = _conv1x1_q88_rne_clamp(in_w, x_norm_q88)
    uv_q88 = uv_q88_flat.reshape(x_seq.shape[0], 2 * inner)
    u_q88 = uv_q88[:, :inner]
    z_q88 = uv_q88[:, inner:]

    u_q88_rows = u_q88.reshape(-1, 4)
    z_q88_rows = z_q88.reshape(-1, 4)
    u_sig_q016 = _sigmoid_q016_from_q88(u_q88_rows)
    z_sig_q016 = _sigmoid_q016_from_q88(z_q88_rows)
    u_act_q88_rows = _mul_q016_q88_to_q88(u_sig_q016, u_q88_rows)
    z_silu_q88_rows = _mul_q016_q88_to_q88(z_sig_q016, z_q88_rows)

    dt_q88_mac_flat = _conv1x1_q88_rne_clamp(dt_w, u_act_q88_rows.reshape(-1))
    dt_q88_mac = dt_q88_mac_flat.reshape(x_seq.shape[0], inner)
    dt_bias = blk["ssm"]["dt_proj"].get("bias_file", "")
    dt_bias_vec = None
    if dt_bias:
        dt_bias_vec = np.load(base_dir / dt_bias).astype(np.float32).reshape(-1)
    dt_q88 = _add_bias_q88_rows(dt_q88_mac.reshape(-1, 4), dt_bias_vec).reshape(x_seq.shape[0], inner)
    dt_q88_rows = dt_q88.reshape(-1, 4)
    lam_q016 = _sigmoid_q016_from_q88(dt_q88_rows)
    if scan_mode == "fixed_q88":
        ssm_q88_rows = _ssm_update_q88_from_lam_q016(lam_q016, u_act_q88_rows)
    elif scan_mode == "scaled_state":
        ssm_q88_rows = _ssm_update_scaled_state_q15(lam_q016, u_act_q88_rows, x_seq.shape[0], inner)
    else:
        raise ValueError(f"unknown scan_mode: {scan_mode}")
    gate_y_q88_rows = _mul_q88_q88_to_q88(z_silu_q88_rows, ssm_q88_rows)

    y_q88_flat = _conv1x1_q88_rne_clamp(out_w, gate_y_q88_rows.reshape(-1))
    y_q88 = y_q88_flat.reshape(x_seq.shape[0], blk["d_model"])
    y_blk = y_q88.astype(np.float32) / 256.0

    # The current RTL-verified block boundary ends at local out_proj y.
    # Residual add happens outside this block-level hardware flow, so keep
    # the block handoff aligned with the cpp path instead of re-quantizing
    # the residual sum at each block boundary.
    x_next = residual + y_blk
    return x_next.astype(np.float32), {
        "x_norm": x_norm.astype(np.float32),
        "u": (u_q88.astype(np.float32) / 256.0),
        "z": (z_q88.astype(np.float32) / 256.0),
        "u_act": (u_act_q88_rows.reshape(x_seq.shape[0], inner).astype(np.float32) / 256.0),
        "z_silu": (z_silu_q88_rows.reshape(x_seq.shape[0], inner).astype(np.float32) / 256.0),
        "dt": (dt_q88.astype(np.float32) / 256.0),
        "lam": (lam_q016.astype(np.float32) / float(1 << 16)),
        "ssm_scan": (ssm_q88_rows.reshape(x_seq.shape[0], inner).astype(np.float32) / 256.0),
        "gate_y": (gate_y_q88_rows.reshape(x_seq.shape[0], inner).astype(np.float32) / 256.0),
        "y_blk": y_blk.astype(np.float32),
        "x_next": x_next.astype(np.float32),
    }


def _forward_full_cppish(export_json: Path, x_sample_kd: np.ndarray) -> tuple[np.ndarray, list[dict]]:
    export, backbone, base_dir = _load_export_ir(export_json)
    lut = _ActLut()
    seq_len = int(export["model"]["seq_len"])

    proj = _conv1d_run_integer_desc(export["proj"], base_dir, x_sample_kd.astype(np.float32), seq_len, bits=16)
    patch = _conv1d_run_integer_desc(backbone["patch_embedding"], base_dir, proj, proj.shape[0], bits=16)
    if backbone.get("positional_encoding", {}).get("enabled") and backbone["positional_encoding"].get("file"):
        pe = np.load(base_dir / backbone["positional_encoding"]["file"]).astype(np.float32)
        patch += float(backbone["positional_encoding"].get("scale", 1.0)) * pe.reshape(patch.shape)

    x_seq = patch.astype(np.float32)
    traces: list[dict] = [{"stage": "patch_embedding", "x_next": x_seq.copy()}]
    for blk in backbone["blocks"]:
        x_seq, trace = _block_forward_cppish(blk, base_dir, x_seq, lut)
        trace["stage"] = f"block{int(blk['index'])}"
        traces.append(trace)

    _rmsnorm_inplace_np(x_seq, backbone["final_norm"], base_dir)
    traces.append({"stage": "final_norm", "x_next": x_seq.copy()})

    if backbone["output_head"]["kind"] == "pool":
        pooled = np.mean(x_seq, axis=0, keepdims=True).astype(np.float32)
        backbone_out = _conv1d_run_integer_desc(backbone["output_head"]["pool"], base_dir, pooled, pooled.shape[0], bits=16)
    else:
        backbone_out = _conv1d_run_integer_desc(backbone["output_head"]["flat"], base_dir, x_seq, x_seq.shape[0], bits=16)
    traces.append({"stage": "output_head", "x_next": backbone_out.copy()})

    head_in = backbone_out.reshape(int(export["model"]["forecast_len"]), int(backbone["meta"]["num_channels"]))
    y = _conv1d_run_integer_desc(export["head"], base_dir, head_in, head_in.shape[0], bits=16)
    traces.append({"stage": "head", "x_next": y.copy()})
    return y.reshape(-1).astype(np.float32), traces


def _forward_full_hw_like(export_json: Path, x_sample_kd: np.ndarray, scan_mode: str = "fixed_q88") -> tuple[np.ndarray, list[dict]]:
    export, backbone, base_dir = _load_export_ir(export_json)
    seq_len = int(export["model"]["seq_len"])

    proj = _conv1d_run_integer_desc(export["proj"], base_dir, x_sample_kd.astype(np.float32), seq_len, bits=16)
    patch = _conv1d_run_integer_desc(backbone["patch_embedding"], base_dir, proj, proj.shape[0], bits=16)
    if backbone.get("positional_encoding", {}).get("enabled") and backbone["positional_encoding"].get("file"):
        pe = np.load(base_dir / backbone["positional_encoding"]["file"]).astype(np.float32)
        patch += float(backbone["positional_encoding"].get("scale", 1.0)) * pe.reshape(patch.shape)

    x_seq = (_quant_q88(patch).astype(np.float32) / 256.0).astype(np.float32)
    traces: list[dict] = [{"stage": "patch_embedding_q88_if", "x_next": x_seq.copy()}]
    for blk in backbone["blocks"]:
        x_seq, trace = _block_forward_hw_like(blk, base_dir, x_seq, scan_mode=scan_mode)
        trace["stage"] = f"block{int(blk['index'])}"
        traces.append(trace)

    x_post = x_seq.copy()
    _rmsnorm_inplace_np(x_post, backbone["final_norm"], base_dir)
    traces.append({"stage": "final_norm", "x_next": x_post.copy()})

    if backbone["output_head"]["kind"] == "pool":
        pooled = np.mean(x_post, axis=0, keepdims=True).astype(np.float32)
        backbone_out = _conv1d_run_integer_desc(backbone["output_head"]["pool"], base_dir, pooled, pooled.shape[0], bits=16)
    else:
        backbone_out = _conv1d_run_integer_desc(backbone["output_head"]["flat"], base_dir, x_post, x_post.shape[0], bits=16)
    traces.append({"stage": "output_head", "x_next": backbone_out.copy()})

    head_in = backbone_out.reshape(int(export["model"]["forecast_len"]), int(backbone["meta"]["num_channels"]))
    y = _conv1d_run_integer_desc(export["head"], base_dir, head_in, head_in.shape[0], bits=16)
    traces.append({"stage": "head", "x_next": y.copy()})
    return y.reshape(-1).astype(np.float32), traces


_MP_EXPORT_JSON: Path | None = None
_MP_SCAN_MODE: str = "scaled_state"
_MP_BLOCK_STAGE_NAMES: list[str] = []


def _mp_worker_init(export_json_str: str, scan_mode: str, block_stage_names: list[str]) -> None:
    global _MP_EXPORT_JSON, _MP_SCAN_MODE, _MP_BLOCK_STAGE_NAMES
    _MP_EXPORT_JSON = Path(export_json_str)
    _MP_SCAN_MODE = scan_mode
    _MP_BLOCK_STAGE_NAMES = list(block_stage_names)


def _mp_eval_one(item: tuple[int, np.ndarray]) -> tuple[int, np.ndarray, np.ndarray, list[float], list[float]]:
    idx, sample = item
    assert _MP_EXPORT_JSON is not None
    cppish_out, cppish_traces = _forward_full_cppish(_MP_EXPORT_JSON, sample.astype(np.float32))
    hw_out, hw_traces = _forward_full_hw_like(_MP_EXPORT_JSON, sample.astype(np.float32), scan_mode=_MP_SCAN_MODE)
    cppish_map = {t["stage"]: t["x_next"] for t in cppish_traces}
    hw_map = {t["stage"]: t["x_next"] for t in hw_traces}

    maes: list[float] = []
    maxes: list[float] = []
    for name in _MP_BLOCK_STAGE_NAMES:
        ref_name = "patch_embedding" if name == "patch_embedding_q88_if" else name
        hw_state = hw_map[name]
        ref_state = cppish_map[ref_name]
        diff = np.abs(hw_state.astype(np.float32) - ref_state.astype(np.float32))
        maes.append(float(np.mean(diff)))
        maxes.append(float(np.max(diff)))
    return idx, cppish_out.astype(np.float32), hw_out.astype(np.float32), maes, maxes


def main() -> None:
    p = argparse.ArgumentParser(description="Estimate end-to-end error using current hw-like block semantics.")
    p.add_argument("--export_json", type=str, required=True)
    p.add_argument("--case_dir", type=str, required=True)
    p.add_argument("--cpp_batch_bin", type=str, default="build/bittrue/main_batch.exe")
    p.add_argument("--din", type=int, default=2100)
    p.add_argument("--limit", type=int, default=0, help="Evaluate only the first N samples; 0 means all samples.")
    p.add_argument("--progress_every", type=int, default=100, help="Print progress every N samples; 0 disables progress.")
    p.add_argument(
        "--scan_mode",
        type=str,
        default="scaled_state",
        choices=["fixed_q88", "scaled_state"],
        help="SSM scan quantization model for the hw-like path.",
    )
    p.add_argument(
        "--workers",
        type=int,
        default=0,
        help="Parallel worker processes for hw/cppish sample evaluation. 0 uses os.cpu_count().",
    )
    args = p.parse_args()

    export_json = Path(args.export_json)
    case_dir = Path(args.case_dir)
    cpp_batch_bin = Path(args.cpp_batch_bin)
    float_dir = case_dir / "float"
    log_dir = case_dir / "logs"
    log_dir.mkdir(parents=True, exist_ok=True)

    samples = np.load(float_dir / "samples.npy").astype(np.float32)
    y_true = np.load(float_dir / "y_true.npy").astype(np.float32)
    y_float = np.load(float_dir / "y_float.npy").astype(np.float32)

    cpp_out_path = float_dir / "cpp_full_int16.npy"
    if cpp_out_path.exists():
        y_cpp = np.load(cpp_out_path).astype(np.float32)
    else:
        y_cpp = _run_cpp_batch(cpp_batch_bin, export_json, float_dir / "samples.npy", cpp_out_path, int(args.din), mode="int16")

    total_samples = int(samples.shape[0])
    eval_samples = total_samples if int(args.limit) <= 0 else min(int(args.limit), total_samples)
    samples_eval = samples[:eval_samples]
    y_true_eval = y_true[:eval_samples]
    y_float_eval = y_float[:eval_samples]
    y_cpp_eval = y_cpp[:eval_samples]

    y_cppish = np.zeros_like(y_cpp_eval, dtype=np.float32)
    y_hw = np.zeros_like(y_cpp_eval, dtype=np.float32)
    block_mae_accum: dict[str, list[float]] = {}
    block_max_accum: dict[str, list[float]] = {}

    # probe first sample once to derive stable stage-name mapping
    probe_cppish, probe_cppish_traces = _forward_full_cppish(export_json, samples_eval[0])
    probe_hw, probe_hw_traces = _forward_full_hw_like(export_json, samples_eval[0], scan_mode=args.scan_mode)
    y_cppish[0] = probe_cppish
    y_hw[0] = probe_hw
    block_stage_names = [t["stage"] for t in probe_hw_traces if t["stage"].startswith("block") or t["stage"].startswith("patch_embedding")]
    for name in block_stage_names:
        block_mae_accum[name] = []
        block_max_accum[name] = []
    probe_cppish_map = {t["stage"]: t["x_next"] for t in probe_cppish_traces}
    probe_hw_map = {t["stage"]: t["x_next"] for t in probe_hw_traces}
    for name in block_stage_names:
        ref_name = "patch_embedding" if name == "patch_embedding_q88_if" else name
        probe_diff = np.abs(probe_hw_map[name].astype(np.float32) - probe_cppish_map[ref_name].astype(np.float32))
        block_mae_accum[name].append(float(np.mean(probe_diff)))
        block_max_accum[name].append(float(np.max(probe_diff)))

    remaining = [(i, samples_eval[i]) for i in range(1, eval_samples)]
    workers = int(args.workers) if int(args.workers) > 0 else max(1, int(os.cpu_count() or 1))
    if remaining:
        with ProcessPoolExecutor(
            max_workers=workers,
            initializer=_mp_worker_init,
            initargs=(str(export_json), args.scan_mode, block_stage_names),
        ) as ex:
            futs = [ex.submit(_mp_eval_one, item) for item in remaining]
            done_n = 1
            for fut in as_completed(futs):
                idx, cppish_out, hw_out, maes, maxes = fut.result()
                y_cppish[idx] = cppish_out
                y_hw[idx] = hw_out
                for j, name in enumerate(block_stage_names):
                    block_mae_accum[name].append(maes[j])
                    block_max_accum[name].append(maxes[j])
                done_n += 1
                if int(args.progress_every) > 0 and (done_n == 1 or done_n % int(args.progress_every) == 0):
                    print(f"[eval] sample {done_n}/{eval_samples}")

    hw_vs_cpp = np.abs(y_hw - y_cpp_eval)
    hw_vs_float = np.abs(y_hw - y_float_eval)
    cppish_vs_cpp = np.abs(y_cppish - y_cpp_eval)

    summary = {
        "samples": int(eval_samples),
        "total_available_samples": int(total_samples),
        "limit": int(args.limit),
        "scan_mode": args.scan_mode,
        "hw_like_vs_cpp": {
            "mae": float(np.mean(hw_vs_cpp)),
            "max_abs": float(np.max(hw_vs_cpp)),
            "metrics_vs_y_true": _metric_dict(y_true_eval, y_hw),
        },
        "hw_like_vs_float": {
            "mae": float(np.mean(hw_vs_float)),
            "max_abs": float(np.max(hw_vs_float)),
            "metrics_vs_y_true": _metric_dict(y_true_eval, y_hw),
        },
        "cppish_vs_cpp": {
            "mae": float(np.mean(cppish_vs_cpp)),
            "max_abs": float(np.max(cppish_vs_cpp)),
        },
        "block_error_accumulation": {
            name: {
                "mean_mae": float(np.mean(block_mae_accum[name])),
                "mean_max_abs": float(np.mean(block_max_accum[name])),
            }
            for name in (block_stage_names or [])
        },
        "sample0": {
            "y_cpp": y_cpp_eval[0].astype(float).tolist(),
            "y_cppish": y_cppish[0].astype(float).tolist(),
            "y_hw_like": y_hw[0].astype(float).tolist(),
            "y_true": y_true_eval[0].astype(float).tolist(),
            "y_float": y_float_eval[0].astype(float).tolist(),
        },
    }

    np.save(float_dir / "hw_like_full.npy", y_hw.astype(np.float32))
    np.save(float_dir / "cppish_full.npy", y_cppish.astype(np.float32))
    _write_json(log_dir / "full_hw_like_eval.json", summary)
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
