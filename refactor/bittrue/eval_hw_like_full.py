from __future__ import annotations

import argparse
import json
import subprocess
import sys
from concurrent.futures import ProcessPoolExecutor, as_completed
from pathlib import Path

import numpy as np

from refactor.bittrue.eval_bittrue import _metric_dict
from refactor.bittrue.export_hw_debug import (
    _ActLut,
    _add_bias_q88_rows,
    _clamp_s16_arr,
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
    _ssm_update_scaled_state_q15_from_q88,
)


def _write_json(path: Path, obj: dict | list) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2), encoding="utf-8")


def _read_mem_matrix_rows_q88(path: Path, cols: int = 4) -> np.ndarray:
    rows: list[list[int]] = []
    with open(path, "r", encoding="utf-8") as f:
        for ln in f:
            s = ln.strip()
            if not s:
                continue
            word = int(s, 16)
            row = []
            for lane in range(cols):
                v = (word >> (16 * lane)) & 0xFFFF
                if v & 0x8000:
                    v -= 0x10000
                row.append(int(v))
            rows.append(row)
    if not rows:
        return np.zeros((0, cols), dtype=np.int16)
    return np.asarray(rows, dtype=np.int16)


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


def _ensure_chain4_batch_inputs(
    case_dir: Path,
    export_json: Path,
    required_samples: int,
    progress_every: int,
) -> tuple[np.ndarray, np.ndarray]:
    chain_stage = case_dir / "stages" / "reuse_mamba_block_top_chain4"
    y_batch_npy = chain_stage / "final_y_q88_batch.npy"
    h_batch_npy = chain_stage / "block3_h_in_q88_batch.npy"

    need_regen = True
    y_batch: np.ndarray | None = None
    h_batch: np.ndarray | None = None
    if y_batch_npy.exists() and h_batch_npy.exists():
        y_try = np.load(y_batch_npy).astype(np.int16)
        h_try = np.load(h_batch_npy).astype(np.int16)
        if y_try.shape == h_try.shape and int(y_try.shape[0]) >= int(required_samples):
            y_batch, h_batch = y_try, h_try
            need_regen = False

    if need_regen:
        cmd = [
            sys.executable,
            "-m",
            "refactor.bittrue.RTL_out2final",
            "--case_dir",
            str(case_dir),
            "--export_json",
            str(export_json),
            "--num_samples",
            str(int(required_samples)),
            "--start_idx",
            "0",
            "--progress_every",
            str(int(progress_every)),
        ]
        print(f"[eval] regenerating chain4 batch npy with {required_samples} samples...")
        subprocess.run(cmd, check=True)
        y_batch = np.load(y_batch_npy).astype(np.int16)
        h_batch = np.load(h_batch_npy).astype(np.int16)

    if y_batch is None or h_batch is None:
        raise RuntimeError("internal error: chain4 batch arrays are missing after regeneration")
    if y_batch.shape != h_batch.shape:
        raise ValueError(f"chain4 batch shape mismatch: y={y_batch.shape}, h={h_batch.shape}")
    if int(y_batch.shape[0]) < int(required_samples):
        raise ValueError(
            f"chain4 batch too short after regeneration: have={y_batch.shape[0]}, need={required_samples}"
        )
    return y_batch, h_batch


def _load_chain4_cached_batches(case_dir: Path, min_samples: int) -> tuple[np.ndarray, np.ndarray] | None:
    chain_stage = case_dir / "stages" / "reuse_mamba_block_top_chain4"
    y_batch_npy = chain_stage / "final_y_q88_batch.npy"
    h_batch_npy = chain_stage / "block3_h_in_q88_batch.npy"
    if not y_batch_npy.exists() or not h_batch_npy.exists():
        return None
    y_batch = np.load(y_batch_npy).astype(np.int16)
    h_batch = np.load(h_batch_npy).astype(np.int16)
    if y_batch.shape != h_batch.shape:
        return None
    if int(y_batch.shape[0]) < int(min_samples):
        return None
    return y_batch, h_batch


def _load_weight_2d_from_desc(base_dir: Path, conv_desc: dict) -> np.ndarray:
    w = np.load(base_dir / conv_desc["weight"]).astype(np.float32)
    return w.reshape(int(conv_desc["out_channels"]), int(conv_desc["in_channels"]))


def _build_chain4_ctx(export_json: Path) -> dict:
    export, backbone, base_dir = _load_export_ir(export_json)
    blocks = backbone.get("blocks", [])
    if len(blocks) < 4:
        raise ValueError(f"chain4 expects >=4 blocks, got {len(blocks)}")
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
                "desc": blk,
                "norm_gamma_q88": _quant_q88(norm_gamma),
                "in_w": in_w,
                "dt_w": dt_w,
                "out_w": out_w,
                "dt_bias": dt_bias,
            }
        )
    return {
        "export": export,
        "backbone": backbone,
        "base_dir": base_dir,
        "blocks": blk_cache,
    }


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


def _ssm_update_scaled_state_q15_stateful(u_q88_rows: np.ndarray, lam_q016_rows: np.ndarray, runtime: dict) -> np.ndarray:
    state_depth = int(runtime["state_depth"])
    tile = int(runtime["tile"])
    u_q88 = u_q88_rows.astype(np.int64)
    u_to_state_q16 = runtime["u_to_state_q16"].astype(np.int64)
    state_to_q88_q16 = runtime["state_to_q88_q16"].astype(np.int64)
    state_runtime = runtime["state_runtime"].astype(np.int64)
    last_wr_valid = bool(runtime["last_wr_valid"])
    last_wr_addr = int(runtime["last_wr_addr"])
    last_wr_data = runtime["last_wr_data"].astype(np.int64)

    if u_q88.shape != (state_depth, tile):
        raise ValueError(f"u_q88_rows shape mismatch: got={u_q88.shape} exp={(state_depth, tile)}")
    if lam_q016_rows.shape != (state_depth, tile):
        raise ValueError(f"lam_q016_rows shape mismatch: got={lam_q016_rows.shape} exp={(state_depth, tile)}")

    u_state = _rshift_rne_i64_vec(u_q88 * u_to_state_q16, 16)
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
        s_new = _rshift_rne_i64_vec(acc, 15)
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
    ssm_q88 = _rshift_rne_i64_vec(out_state * state_to_q88_q16, 16)
    return np.clip(ssm_q88, -32768, 32767).astype(np.int16)


def _block_step_hw_q88(
    blk_cache: dict,
    h_in_q88: np.ndarray,
    scan_mode: str,
    runtime: dict | None = None,
) -> tuple[np.ndarray, np.ndarray]:
    h_raw_q88 = h_in_q88.astype(np.int16).reshape(-1)
    h_norm_q88, _ = _rmsnorm_q88_hw(h_raw_q88, blk_cache["norm_gamma_q88"], eps_q16=1, mode="exact_recip30")
    inner = int(blk_cache["desc"]["d_inner"])
    uv_q88 = _conv1x1_q88_rne_clamp(blk_cache["in_w"], h_norm_q88)
    u_q88_rows = uv_q88[:inner].reshape(64, 4)
    z_q88_rows = uv_q88[inner:].reshape(64, 4)
    u_sig_q016 = _sigmoid_q016_from_q88(u_q88_rows)
    z_sig_q016 = _sigmoid_q016_from_q88(z_q88_rows)
    u_act_q88 = _mul_q016_q88_to_q88(u_sig_q016, u_q88_rows)
    z_silu_q88 = _mul_q016_q88_to_q88(z_sig_q016, z_q88_rows)
    dt_q88_mac = _conv1x1_q88_rne_clamp(blk_cache["dt_w"], u_act_q88.reshape(-1)).reshape(64, 4)
    dt_q88 = _add_bias_q88_rows(dt_q88_mac, blk_cache["dt_bias"])
    lam_q016 = _sigmoid_q016_from_q88(dt_q88)
    if scan_mode == "scaled_state":
        if runtime is None:
            ssm_q88, _, _ = _ssm_update_scaled_state_q15_from_q88(u_act_q88, lam_q016)
        else:
            if runtime.get("state_runtime") is None:
                runtime.update(_make_scaled_state_runtime(u_act_q88))
            ssm_q88 = _ssm_update_scaled_state_q15_stateful(u_act_q88, lam_q016, runtime)
    else:
        ssm_q88 = _ssm_update_q88_from_lam_q016(lam_q016, u_act_q88)
    gate_y_q88 = _mul_q88_q88_to_q88(z_silu_q88, ssm_q88)
    y_q88 = _conv1x1_q88_rne_clamp(blk_cache["out_w"], gate_y_q88.reshape(-1)).reshape(32, 4)
    x_next_q88 = _clamp_s16_arr(h_raw_q88.astype(np.int64).reshape(32, 4) + y_q88.astype(np.int64)).reshape(-1)
    return x_next_q88.astype(np.int16), y_q88.astype(np.int16)


def _compute_chain4_pair_from_sample(
    ctx: dict,
    sample_kd: np.ndarray,
    scan_mode: str,
    runtimes: list[dict] | None = None,
) -> tuple[np.ndarray, np.ndarray]:
    export = ctx["export"]
    backbone = ctx["backbone"]
    base_dir = ctx["base_dir"]
    x = sample_kd.astype(np.float32)
    seq_len = int(export["model"]["seq_len"])
    proj = _conv1d_run_integer_desc(export["proj"], base_dir, x, seq_len, bits=16)
    patch = _conv1d_run_integer_desc(backbone["patch_embedding"], base_dir, proj, proj.shape[0], bits=16)
    if backbone.get("positional_encoding", {}).get("enabled") and backbone["positional_encoding"].get("file"):
        pe = np.load(base_dir / backbone["positional_encoding"]["file"]).astype(np.float32)
        patch += float(backbone["positional_encoding"].get("scale", 1.0)) * pe.reshape(patch.shape)
    x_q88 = _quant_q88(patch.reshape(-1)).astype(np.int16)
    h_block3 = np.zeros((32, 4), dtype=np.int16)
    y_block3 = np.zeros((32, 4), dtype=np.int16)
    for bi, blk_cache in enumerate(ctx["blocks"]):
        if bi == 3:
            h_block3 = x_q88.reshape(32, 4).astype(np.int16)
        runtime_i = None if runtimes is None else runtimes[bi]
        x_q88, y_q88 = _block_step_hw_q88(blk_cache, x_q88, scan_mode=scan_mode, runtime=runtime_i)
        if bi == 3:
            y_block3 = y_q88.astype(np.int16)
    return h_block3, y_block3


def _collect_chain4_q88_stream(
    export_json: Path,
    samples_eval: np.ndarray,
    workers: int,
    scan_mode: str,
    progress_every: int,
) -> tuple[np.ndarray, np.ndarray]:
    num_samples = int(samples_eval.shape[0])
    y_batch = np.zeros((num_samples, 32, 4), dtype=np.int16)
    h_batch = np.zeros((num_samples, 32, 4), dtype=np.int16)
    items = [(i, samples_eval[i].astype(np.float32, copy=False)) for i in range(num_samples)]
    if num_samples <= 1 or int(workers) <= 1:
        ctx = _build_chain4_ctx(export_json)
        for i, sample in items:
            h_i, y_i = _compute_chain4_pair_from_sample(ctx, sample, scan_mode=scan_mode)
            h_batch[i] = h_i
            y_batch[i] = y_i
            if int(progress_every) > 0 and ((i + 1) % int(progress_every) == 0):
                print(f"[eval] generated chain4 q88 {i + 1}/{num_samples}")
    else:
        with ProcessPoolExecutor(
            max_workers=int(workers),
            initializer=_mp_worker_init_chain_pair,
            initargs=(str(export_json), str(scan_mode)),
        ) as ex:
            futs = [ex.submit(_mp_collect_chain4_pair, it) for it in items]
            done_n = 0
            for fut in as_completed(futs):
                idx, h_i, y_i = fut.result()
                h_batch[idx] = h_i
                y_batch[idx] = y_i
                done_n += 1
                if int(progress_every) > 0 and (done_n % int(progress_every) == 0):
                    print(f"[eval] generated chain4 q88 {done_n}/{num_samples}")
    return y_batch, h_batch


def _collect_chain4_q88_stream_continuous(
    export_json: Path,
    samples_eval: np.ndarray,
    scan_mode: str,
    progress_every: int,
) -> tuple[np.ndarray, np.ndarray]:
    num_samples = int(samples_eval.shape[0])
    y_batch = np.zeros((num_samples, 32, 4), dtype=np.int16)
    h_batch = np.zeros((num_samples, 32, 4), dtype=np.int16)
    ctx = _build_chain4_ctx(export_json)
    runtimes: list[dict] = [{"state_runtime": None} for _ in range(4)]
    for i in range(num_samples):
        h_i, y_i = _compute_chain4_pair_from_sample(ctx, samples_eval[i], scan_mode=scan_mode, runtimes=runtimes)
        h_batch[i] = h_i
        y_batch[i] = y_i
        if int(progress_every) > 0 and ((i + 1) % int(progress_every) == 0):
            print(f"[eval] generated continuous chain4 q88 {i + 1}/{num_samples}")
    return y_batch, h_batch


def _save_chain4_cached_batches(case_dir: Path, y_batch: np.ndarray, h_batch: np.ndarray) -> None:
    chain_stage = case_dir / "stages" / "reuse_mamba_block_top_chain4"
    chain_stage.mkdir(parents=True, exist_ok=True)
    np.save(chain_stage / "final_y_q88_batch.npy", y_batch.astype(np.int16))
    np.save(chain_stage / "block3_h_in_q88_batch.npy", h_batch.astype(np.int16))


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
    x_norm_q88, _rms_q88 = _rmsnorm_q88_hw(
        residual_q88,
        norm_w_q88,
        eps_q16=1,
        mode="exact_recip30",
    )
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


def _forward_full_case_chain4(export_json: Path, case_dir: Path) -> tuple[np.ndarray, list[dict]]:
    export, backbone, base_dir = _load_export_ir(export_json)
    stage_b3 = case_dir / "stages" / "reuse_mamba_block_top_block3"
    chain4_stage = case_dir / "stages" / "reuse_mamba_block_top_chain4"
    h_in_mem = stage_b3 / "h_wr_data_s16_q8p8.mem"
    y_blk_mem = chain4_stage / "final_y_golden_q88.mem"
    if not h_in_mem.exists():
        raise FileNotFoundError(f"missing block3 input mem: {h_in_mem}")
    if not y_blk_mem.exists():
        raise FileNotFoundError(f"missing chain4 final y mem: {y_blk_mem}")

    h_in_q88 = _read_mem_matrix_rows_q88(h_in_mem, cols=4).astype(np.int64).reshape(1, -1)  # (1,128)
    y_blk_q88 = _read_mem_matrix_rows_q88(y_blk_mem, cols=4).astype(np.int64).reshape(1, -1)  # (1,128)
    x_post_q88 = np.clip(h_in_q88 + y_blk_q88, -32768, 32767).astype(np.int16)
    x_post = x_post_q88.astype(np.float32) / 256.0

    traces: list[dict] = [{"stage": "chain4_hw", "x_next": x_post.copy()}]
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


def _forward_full_case_chain4_from_q88(export_json: Path, h_in_q88: np.ndarray, y_blk_q88: np.ndarray) -> tuple[np.ndarray, list[dict]]:
    export, backbone, base_dir = _load_export_ir(export_json)
    h_in_i = h_in_q88.astype(np.int64).reshape(1, -1)
    y_blk_i = y_blk_q88.astype(np.int64).reshape(1, -1)
    x_post_q88 = np.clip(h_in_i + y_blk_i, -32768, 32767).astype(np.int16)
    x_post = x_post_q88.astype(np.float32) / 256.0
    traces: list[dict] = [{"stage": "chain4_hw", "x_next": x_post.copy()}]
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
_MP_EXPORT_JSON_CHAIN: Path | None = None
_MP_CHAIN4_CTX: dict | None = None
_MP_CHAIN4_SCAN_MODE: str = "scaled_state"


def _mp_worker_init(export_json_str: str, scan_mode: str, block_stage_names: list[str]) -> None:
    global _MP_EXPORT_JSON, _MP_SCAN_MODE, _MP_BLOCK_STAGE_NAMES
    _MP_EXPORT_JSON = Path(export_json_str)
    _MP_SCAN_MODE = scan_mode
    _MP_BLOCK_STAGE_NAMES = list(block_stage_names)


def _mp_worker_init_chain(export_json_str: str) -> None:
    global _MP_EXPORT_JSON_CHAIN
    _MP_EXPORT_JSON_CHAIN = Path(export_json_str)


def _mp_eval_case_chain4(item: tuple[int, np.ndarray, np.ndarray]) -> tuple[int, np.ndarray]:
    idx, h_q88, y_q88 = item
    assert _MP_EXPORT_JSON_CHAIN is not None
    y_out, _ = _forward_full_case_chain4_from_q88(_MP_EXPORT_JSON_CHAIN, h_q88, y_q88)
    return idx, y_out.astype(np.float32)


def _mp_worker_init_chain_pair(export_json_str: str, scan_mode: str) -> None:
    global _MP_CHAIN4_CTX, _MP_CHAIN4_SCAN_MODE
    _MP_CHAIN4_CTX = _build_chain4_ctx(Path(export_json_str))
    _MP_CHAIN4_SCAN_MODE = str(scan_mode)


def _mp_collect_chain4_pair(item: tuple[int, np.ndarray]) -> tuple[int, np.ndarray, np.ndarray]:
    idx, sample = item
    assert _MP_CHAIN4_CTX is not None
    h_q88, y_q88 = _compute_chain4_pair_from_sample(_MP_CHAIN4_CTX, sample, scan_mode=_MP_CHAIN4_SCAN_MODE)
    return idx, h_q88.astype(np.int16), y_q88.astype(np.int16)


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
    p.add_argument("--scan_mode", type=str, default="scaled_state", choices=["fixed_q88", "scaled_state"])
    p.add_argument(
        "--cache_threshold",
        type=int,
        default=64,
        help="Use cached chain4 batch files only when eval_samples < threshold; otherwise stream-generate per sample.",
    )
    p.add_argument(
        "--workers",
        type=int,
        default=0,
        help="Parallel worker processes for case_chain4 post-block evaluation. 0 uses os.cpu_count().",
    )
    p.add_argument(
        "--continuous_state",
        action="store_true",
        help="Generate/use chain4 golden with state carried across samples (matches stream hardware).",
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

    y_hw = np.zeros_like(y_cpp_eval, dtype=np.float32)
    block_stage_names: list[str] = []
    block_mae_accum: dict[str, list[float]] = {}
    block_max_accum: dict[str, list[float]] = {}

    if eval_samples <= 0:
        raise ValueError("no samples to evaluate")

    threshold = max(1, int(args.cache_threshold))
    use_cache_mode = (not bool(args.continuous_state)) and (int(eval_samples) < threshold)
    workers = int(args.workers) if int(args.workers) > 0 else max(1, int((__import__("os").cpu_count()) or 1))
    cached = None if bool(args.continuous_state) else _load_chain4_cached_batches(case_dir, min_samples=int(eval_samples))
    if bool(args.continuous_state):
        print(f"[eval] continuous_state mode: sequential chain4 generation for {eval_samples} samples")
        y_batch, h_batch = _collect_chain4_q88_stream_continuous(
            export_json=export_json,
            samples_eval=samples_eval,
            scan_mode=str(args.scan_mode),
            progress_every=int(args.progress_every),
        )
        chain4_input_mode = "stream_continuous"
    elif cached is not None:
        print(f"[eval] using existing chain4 cache for {eval_samples} samples")
        y_batch, h_batch = cached[0][:eval_samples], cached[1][:eval_samples]
        chain4_input_mode = "cache"
    elif use_cache_mode:
        regen_n = min(int(total_samples), max(int(eval_samples), threshold))
        print(f"[eval] cache mode: regenerating chain4 batch cache to {regen_n} samples")
        y_batch_all, h_batch_all = _ensure_chain4_batch_inputs(
            case_dir=case_dir,
            export_json=export_json,
            required_samples=regen_n,
            progress_every=int(args.progress_every),
        )
        y_batch, h_batch = y_batch_all[:eval_samples], h_batch_all[:eval_samples]
        chain4_input_mode = "cache"
    else:
        print(f"[eval] stream mode: generating chain4 q88 with {workers} worker(s) for {eval_samples} samples")
        y_batch, h_batch = _collect_chain4_q88_stream(
            export_json=export_json,
            samples_eval=samples_eval,
            workers=workers,
            scan_mode=str(args.scan_mode),
            progress_every=int(args.progress_every),
        )
        _save_chain4_cached_batches(case_dir, y_batch, h_batch)
        print(f"[eval] stream mode: saved cache with {eval_samples} samples")
        chain4_input_mode = "stream"

    y_hw = np.zeros_like(y_cpp_eval, dtype=np.float32)
    items = [(i, h_batch[i], y_batch[i]) for i in range(eval_samples)]
    if eval_samples <= 1 or workers <= 1:
        for i, h_i, y_i in items:
            y_hw[i], _ = _forward_full_case_chain4_from_q88(export_json, h_i, y_i)
            if int(args.progress_every) > 0 and ((i + 1) % int(args.progress_every) == 0):
                print(f"[eval] sample {i + 1}/{eval_samples}")
    else:
        with ProcessPoolExecutor(max_workers=workers, initializer=_mp_worker_init_chain, initargs=(str(export_json),)) as ex:
            futs = [ex.submit(_mp_eval_case_chain4, it) for it in items]
            done_n = 0
            for fut in as_completed(futs):
                idx, y_out = fut.result()
                y_hw[idx] = y_out
                done_n += 1
                if int(args.progress_every) > 0 and (done_n % int(args.progress_every) == 0):
                    print(f"[eval] sample {done_n}/{eval_samples}")

    hw_vs_cpp = np.abs(y_hw - y_cpp_eval)
    hw_vs_float = np.abs(y_hw - y_float_eval)
    summary = {
        "samples": int(eval_samples),
        "total_available_samples": int(total_samples),
        "limit": int(args.limit),
        "scan_mode": args.scan_mode,
        "continuous_state": bool(args.continuous_state),
        "chain4_input_mode": chain4_input_mode,
        "cache_threshold": int(threshold),
        "block_source": "case_chain4",
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
        "cppish_vs_cpp": None,
        "block_error_accumulation": {
            name: {
                "mean_mae": float(np.mean(block_mae_accum[name])),
                "mean_max_abs": float(np.mean(block_max_accum[name])),
            }
            for name in (block_stage_names or [])
        },
        "sample0": {
            "y_cpp": y_cpp_eval[0].astype(float).tolist(),
            "y_cppish": None,
            "y_hw_like": y_hw[0].astype(float).tolist(),
            "y_true": y_true_eval[0].astype(float).tolist(),
            "y_float": y_float_eval[0].astype(float).tolist(),
        },
    }

    np.save(float_dir / "hw_like_full.npy", y_hw.astype(np.float32))
    _write_json(log_dir / "full_hw_like_eval.json", summary)
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
