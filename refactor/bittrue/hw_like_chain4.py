from __future__ import annotations

from concurrent.futures import ProcessPoolExecutor, as_completed
from pathlib import Path

import numpy as np

from refactor.bittrue.export_hw_debug import (
    _add_bias_q88_rows,
    _clamp_s16_arr,
    _conv1d_run_integer_desc,
    _conv1x1_q88_rne_clamp,
    _load_export_ir,
    _mul_q016_q88_to_q88,
    _mul_q88_q88_to_q88,
    _quant_q88,
    _rmsnorm_q88_hw,
    _sigmoid_q016_from_q88,
    _ssm_update_q88_from_lam_q016,
)

_MP_CHAIN4_CTX: dict | None = None
_MP_CHAIN4_SCAN_MODE: str = "scaled_state"


def _load_weight_2d_from_desc(base_dir: Path, conv_desc: dict) -> np.ndarray:
    w = np.load(base_dir / conv_desc["weight"]).astype(np.float32)
    return w.reshape(int(conv_desc["out_channels"]), int(conv_desc["in_channels"]))


def _rshift_rne_i64_vec(x: np.ndarray, shift: int) -> np.ndarray:
    base = 1 << int(shift)
    q = x // base
    r = x % base
    half = base >> 1
    return q + ((r > half) | ((r == half) & ((q & 1) != 0))).astype(np.int64)


def build_chain4_ctx(export_json: Path) -> dict:
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


def make_scaled_state_runtime(u_q88_rows: np.ndarray) -> dict:
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


def ssm_update_scaled_state_q15_stateful(u_q88_rows: np.ndarray, lam_q016_rows: np.ndarray, runtime: dict) -> np.ndarray:
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


def block_step_hw_q88(
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
            from refactor.bittrue.export_hw_debug import _ssm_update_scaled_state_q15_from_q88

            ssm_q88, _, _ = _ssm_update_scaled_state_q15_from_q88(u_act_q88, lam_q016)
        else:
            if runtime.get("state_runtime") is None:
                runtime.update(make_scaled_state_runtime(u_act_q88))
            ssm_q88 = ssm_update_scaled_state_q15_stateful(u_act_q88, lam_q016, runtime)
    else:
        ssm_q88 = _ssm_update_q88_from_lam_q016(lam_q016, u_act_q88)
    gate_y_q88 = _mul_q88_q88_to_q88(z_silu_q88, ssm_q88)
    y_q88 = _conv1x1_q88_rne_clamp(blk_cache["out_w"], gate_y_q88.reshape(-1)).reshape(32, 4)
    x_next_q88 = _clamp_s16_arr(h_raw_q88.astype(np.int64).reshape(32, 4) + y_q88.astype(np.int64)).reshape(-1)
    return x_next_q88.astype(np.int16), y_q88.astype(np.int16)


def compute_chain4_triplet_from_sample(
    ctx: dict,
    sample_kd: np.ndarray,
    scan_mode: str,
    runtimes: list[dict] | None = None,
) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
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
    h_block0 = x_q88.reshape(32, 4).astype(np.int16)
    h_block3 = np.zeros((32, 4), dtype=np.int16)
    y_block3 = np.zeros((32, 4), dtype=np.int16)
    for bi, blk_cache in enumerate(ctx["blocks"]):
        if bi == 3:
            h_block3 = x_q88.reshape(32, 4).astype(np.int16)
        runtime_i = None if runtimes is None else runtimes[bi]
        x_q88, y_q88 = block_step_hw_q88(blk_cache, x_q88, scan_mode=scan_mode, runtime=runtime_i)
        if bi == 3:
            y_block3 = y_q88.astype(np.int16)
    return h_block0, h_block3, y_block3


def compute_chain4_pair_from_sample(
    ctx: dict,
    sample_kd: np.ndarray,
    scan_mode: str,
    runtimes: list[dict] | None = None,
) -> tuple[np.ndarray, np.ndarray]:
    _, h_block3, y_block3 = compute_chain4_triplet_from_sample(
        ctx=ctx,
        sample_kd=sample_kd,
        scan_mode=scan_mode,
        runtimes=runtimes,
    )
    return h_block3, y_block3


def _mp_worker_init_chain_pair(export_json_str: str, scan_mode: str) -> None:
    global _MP_CHAIN4_CTX, _MP_CHAIN4_SCAN_MODE
    _MP_CHAIN4_CTX = build_chain4_ctx(Path(export_json_str))
    _MP_CHAIN4_SCAN_MODE = str(scan_mode)


def _mp_collect_chain4_pair(item: tuple[int, np.ndarray]) -> tuple[int, np.ndarray, np.ndarray]:
    idx, sample = item
    assert _MP_CHAIN4_CTX is not None
    _, h_q88, y_q88 = compute_chain4_triplet_from_sample(_MP_CHAIN4_CTX, sample, scan_mode=_MP_CHAIN4_SCAN_MODE)
    return idx, h_q88.astype(np.int16), y_q88.astype(np.int16)


def _mp_collect_chain4_triplet(item: tuple[int, np.ndarray]) -> tuple[int, np.ndarray, np.ndarray, np.ndarray]:
    idx, sample = item
    assert _MP_CHAIN4_CTX is not None
    h0_q88, h3_q88, y_q88 = compute_chain4_triplet_from_sample(_MP_CHAIN4_CTX, sample, scan_mode=_MP_CHAIN4_SCAN_MODE)
    return idx, h0_q88.astype(np.int16), h3_q88.astype(np.int16), y_q88.astype(np.int16)


def collect_chain4_q88_parallel(
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
        ctx = build_chain4_ctx(export_json)
        for i, sample in items:
            h_i, y_i = compute_chain4_pair_from_sample(ctx, sample, scan_mode=scan_mode)
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


def collect_chain4_q88_continuous(
    export_json: Path,
    samples_eval: np.ndarray,
    scan_mode: str,
    progress_every: int,
) -> tuple[np.ndarray, np.ndarray]:
    num_samples = int(samples_eval.shape[0])
    y_batch = np.zeros((num_samples, 32, 4), dtype=np.int16)
    h_batch = np.zeros((num_samples, 32, 4), dtype=np.int16)
    ctx = build_chain4_ctx(export_json)
    runtimes: list[dict] = [{"state_runtime": None} for _ in range(4)]
    for i in range(num_samples):
        h_i, y_i = compute_chain4_pair_from_sample(ctx, samples_eval[i], scan_mode=scan_mode, runtimes=runtimes)
        h_batch[i] = h_i
        y_batch[i] = y_i
        if int(progress_every) > 0 and ((i + 1) % int(progress_every) == 0):
            print(f"[eval] generated continuous chain4 q88 {i + 1}/{num_samples}")
    return y_batch, h_batch


def collect_chain4_triplets_parallel(
    export_json: Path,
    samples_eval: np.ndarray,
    workers: int,
    scan_mode: str,
    progress_every: int,
) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    num_samples = int(samples_eval.shape[0])
    h0_batch = np.zeros((num_samples, 32, 4), dtype=np.int16)
    h3_batch = np.zeros((num_samples, 32, 4), dtype=np.int16)
    y_batch = np.zeros((num_samples, 32, 4), dtype=np.int16)
    items = [(i, samples_eval[i].astype(np.float32, copy=False)) for i in range(num_samples)]
    if num_samples <= 1 or int(workers) <= 1:
        ctx = build_chain4_ctx(export_json)
        for i, sample in items:
            h0_i, h3_i, y_i = compute_chain4_triplet_from_sample(ctx, sample, scan_mode=scan_mode)
            h0_batch[i] = h0_i
            h3_batch[i] = h3_i
            y_batch[i] = y_i
            if int(progress_every) > 0 and ((i + 1) % int(progress_every) == 0):
                print(f"[eval] generated chain4 triplets {i + 1}/{num_samples}")
    else:
        with ProcessPoolExecutor(
            max_workers=int(workers),
            initializer=_mp_worker_init_chain_pair,
            initargs=(str(export_json), str(scan_mode)),
        ) as ex:
            futs = [ex.submit(_mp_collect_chain4_triplet, it) for it in items]
            done_n = 0
            for fut in as_completed(futs):
                idx, h0_i, h3_i, y_i = fut.result()
                h0_batch[idx] = h0_i
                h3_batch[idx] = h3_i
                y_batch[idx] = y_i
                done_n += 1
                if int(progress_every) > 0 and (done_n % int(progress_every) == 0):
                    print(f"[eval] generated chain4 triplets {done_n}/{num_samples}")
    return h0_batch, h3_batch, y_batch


def collect_chain4_triplets_continuous(
    export_json: Path,
    samples_eval: np.ndarray,
    scan_mode: str,
    progress_every: int,
) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    num_samples = int(samples_eval.shape[0])
    h0_batch = np.zeros((num_samples, 32, 4), dtype=np.int16)
    h3_batch = np.zeros((num_samples, 32, 4), dtype=np.int16)
    y_batch = np.zeros((num_samples, 32, 4), dtype=np.int16)
    ctx = build_chain4_ctx(export_json)
    runtimes: list[dict] = [{"state_runtime": None} for _ in range(4)]
    for i in range(num_samples):
        h0_i, h3_i, y_i = compute_chain4_triplet_from_sample(ctx, samples_eval[i], scan_mode=scan_mode, runtimes=runtimes)
        h0_batch[i] = h0_i
        h3_batch[i] = h3_i
        y_batch[i] = y_i
        if int(progress_every) > 0 and ((i + 1) % int(progress_every) == 0):
            print(f"[eval] generated continuous chain4 triplets {i + 1}/{num_samples}")
    return h0_batch, h3_batch, y_batch


def _chain4_cache_paths(case_dir: Path) -> tuple[Path, Path]:
    chain_stage = case_dir / "stages" / "reuse_mamba_block_top_chain4"
    return chain_stage / "final_y_q88_batch.npy", chain_stage / "block3_h_in_q88_batch.npy"


def load_chain4_cache(case_dir: Path) -> tuple[np.ndarray, np.ndarray] | None:
    y_path, h_path = _chain4_cache_paths(case_dir)
    if not y_path.exists() or not h_path.exists():
        return None
    y = np.load(y_path).astype(np.int16)
    h = np.load(h_path).astype(np.int16)
    if y.shape != h.shape:
        return None
    return y, h


def save_chain4_cache(case_dir: Path, y_batch: np.ndarray, h_batch: np.ndarray) -> None:
    y_path, h_path = _chain4_cache_paths(case_dir)
    y_path.parent.mkdir(parents=True, exist_ok=True)
    np.save(y_path, y_batch.astype(np.int16))
    np.save(h_path, h_batch.astype(np.int16))


def _load_stream_golden_frames(case_dir: Path, mode_tag: str) -> np.ndarray | None:
    mem = case_dir / "stages" / "reuse_mamba_block_top_chain4" / f"stream_y_golden_{mode_tag}_q88.mem"
    if not mem.exists():
        return None
    rows: list[list[int]] = []
    with open(mem, "r", encoding="utf-8") as f:
        for ln in f:
            s = ln.strip()
            if not s:
                continue
            w = int(s, 16)
            row: list[int] = []
            for lane in range(4):
                v = (w >> (16 * lane)) & 0xFFFF
                if v & 0x8000:
                    v -= 0x10000
                row.append(int(v))
            rows.append(row)
    if len(rows) < 32:
        return None
    arr = np.asarray(rows, dtype=np.int16)
    n_frame = arr.shape[0] // 32
    return arr[: n_frame * 32].reshape(n_frame, 32, 4)


def validate_chain4_cache_with_stream_golden(
    case_dir: Path,
    y_batch: np.ndarray,
    mode_tag: str = "stateless",
    max_frames: int = 8,
) -> tuple[bool, dict]:
    golden = _load_stream_golden_frames(case_dir, mode_tag=mode_tag)
    if golden is None:
        return True, {"checked": False, "reason": "stream golden missing"}
    chk = min(int(max_frames), int(golden.shape[0]), int(y_batch.shape[0]))
    if chk <= 0:
        return True, {"checked": False, "reason": "no overlap"}
    same = bool(np.array_equal(y_batch[:chk], golden[:chk]))
    return same, {"checked": True, "frames_compared": int(chk), "match": same}
