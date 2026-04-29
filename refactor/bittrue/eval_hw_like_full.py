from __future__ import annotations

import argparse
import json
import subprocess
from concurrent.futures import ProcessPoolExecutor, as_completed
from pathlib import Path

import numpy as np

from refactor.bittrue.debug_tools import write_json
from refactor.bittrue.hw_like_chain4 import (
    _ActLut,
    _conv1d_run_integer_desc,
    _load_export_ir,
    _rmsnorm_inplace_np,
    collect_chain4_q88_continuous,
    collect_chain4_q88_parallel,
    load_chain4_cache,
    save_chain4_cache,
    validate_chain4_cache_with_stream_golden,
)


def _metric_dict(y_true: np.ndarray, y_pred: np.ndarray) -> dict:
    err = np.sqrt(np.sum((y_pred - y_true) ** 2, axis=1))
    return {
        "count": int(err.shape[0]),
        "mean_err": float(err.mean()),
        "median_err": float(np.median(err)),
        "p80_err": float(np.percentile(err, 80)),
        "p90_err": float(np.percentile(err, 90)),
        "max_err": float(err.max()),
    }



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


_MP_EXPORT_JSON_CHAIN: Path | None = None
_MP_EXPORT_JSON_CPPISH: Path | None = None




def _mp_worker_init_chain(export_json_str: str) -> None:
    global _MP_EXPORT_JSON_CHAIN
    _MP_EXPORT_JSON_CHAIN = Path(export_json_str)


def _mp_eval_case_chain4(item: tuple[int, np.ndarray, np.ndarray]) -> tuple[int, np.ndarray]:
    idx, h_q88, y_q88 = item
    assert _MP_EXPORT_JSON_CHAIN is not None
    y_out, _ = _forward_full_case_chain4_from_q88(_MP_EXPORT_JSON_CHAIN, h_q88, y_q88)
    return idx, y_out.astype(np.float32)


def _mp_worker_init_cppish(export_json_str: str) -> None:
    global _MP_EXPORT_JSON_CPPISH
    _MP_EXPORT_JSON_CPPISH = Path(export_json_str)


def _mp_eval_cppish(item: tuple[int, np.ndarray]) -> tuple[int, np.ndarray]:
    idx, sample = item
    assert _MP_EXPORT_JSON_CPPISH is not None
    y_out, _ = _forward_full_cppish(_MP_EXPORT_JSON_CPPISH, sample)
    return idx, y_out.astype(np.float32)


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
        help="Legacy debug mode: carry chain4 state across samples. Hardware reference flow uses stateless mode (default).",
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

    if eval_samples <= 0:
        raise ValueError("no samples to evaluate")

    threshold = max(1, int(args.cache_threshold))
    workers = int(args.workers) if int(args.workers) > 0 else max(1, int((__import__("os").cpu_count()) or 1))
    cache_validation: dict = {"checked": False}
    if bool(args.continuous_state):
        print(f"[eval] continuous_state mode: sequential chain4 generation for {eval_samples} samples")
        y_batch, h_batch = collect_chain4_q88_continuous(
            export_json=export_json,
            case_dir=case_dir,
            samples_eval=samples_eval,
            scan_mode=str(args.scan_mode),
            progress_every=int(args.progress_every),
        )
        chain4_input_mode = "stream_continuous"
    else:
        # Cache policy:
        # - eval_samples < cache_threshold: allow cache hit/extend/build
        # - eval_samples >= cache_threshold: bypass cache and stream-generate
        # This avoids unintentionally reusing stale/old cache on full-dataset runs.
        use_cache = int(eval_samples) < int(threshold)
        if use_cache:
            cached = load_chain4_cache(case_dir)
            if cached is not None:
                ok_cache, cache_validation = validate_chain4_cache_with_stream_golden(
                    case_dir=case_dir,
                    y_batch=cached[0],
                    mode_tag="stateless",
                    max_frames=max(1, min(8, int(eval_samples))),
                )
                if not ok_cache:
                    print("[eval] chain4 cache mismatch vs stream golden prefix; rebuilding cache")
                    cached = None
            if cached is not None and int(cached[0].shape[0]) >= int(eval_samples):
                print(f"[eval] using chain4 cache prefix for {eval_samples} samples")
                y_batch, h_batch = cached[0][:eval_samples], cached[1][:eval_samples]
                chain4_input_mode = "cache_hit"
            elif cached is not None:
                have = int(cached[0].shape[0])
                need = int(eval_samples)
                print(f"[eval] extending chain4 cache from {have} to {need} samples")
                y_more, h_more = collect_chain4_q88_parallel(
                    export_json=export_json,
                    case_dir=case_dir,
                    samples_eval=samples_eval[have:need],
                    workers=workers,
                    scan_mode=str(args.scan_mode),
                    progress_every=int(args.progress_every),
                )
                y_batch = np.concatenate([cached[0], y_more], axis=0)
                h_batch = np.concatenate([cached[1], h_more], axis=0)
                save_chain4_cache(case_dir, y_batch, h_batch)
                y_batch = y_batch[:eval_samples]
                h_batch = h_batch[:eval_samples]
                chain4_input_mode = "cache_extend"
            else:
                print(f"[eval] building chain4 cache with {workers} worker(s) for {eval_samples} samples")
                y_batch, h_batch = collect_chain4_q88_parallel(
                    export_json=export_json,
                    case_dir=case_dir,
                    samples_eval=samples_eval,
                    workers=workers,
                    scan_mode=str(args.scan_mode),
                    progress_every=int(args.progress_every),
                )
                save_chain4_cache(case_dir, y_batch, h_batch)
                chain4_input_mode = "cache_build"
                cache_validation = {"checked": False, "reason": "cache newly built"}
        else:
            print(
                f"[eval] bypass chain4 cache: eval_samples={eval_samples} >= cache_threshold={threshold}; "
                f"stream-generating with {workers} worker(s)"
            )
            y_batch, h_batch = collect_chain4_q88_parallel(
                export_json=export_json,
                case_dir=case_dir,
                samples_eval=samples_eval,
                workers=workers,
                scan_mode=str(args.scan_mode),
                progress_every=int(args.progress_every),
            )
            chain4_input_mode = "stream_parallel_nocache"
            cache_validation = {
                "checked": False,
                "reason": "cache bypassed by threshold",
                "cache_threshold": int(threshold),
            }

    # Optional cppish cache for long-run comparison/debug reuse.
    cppish_path = float_dir / "cppish_full.npy"
    if cppish_path.exists():
        y_cppish_all = np.load(cppish_path).astype(np.float32)
    else:
        y_cppish_all = np.zeros((0, y_cpp_eval.shape[1]), dtype=np.float32)
    if int(y_cppish_all.shape[0]) < int(eval_samples):
        start_i = int(y_cppish_all.shape[0])
        remain = int(eval_samples) - start_i
        y_dim = int(y_cpp_eval.shape[1])
        print(f"[eval] building cppish cache from {start_i} to {eval_samples} with {workers} worker(s)")
        if remain <= 1 or workers <= 1:
            y_more = np.zeros((remain, y_dim), dtype=np.float32)
            done = 0
            for i in range(start_i, int(eval_samples)):
                y_i, _ = _forward_full_cppish(export_json, samples_eval[i])
                y_more[i - start_i] = y_i.astype(np.float32)
                done += 1
                if int(args.progress_every) > 0 and (done % int(args.progress_every) == 0):
                    print(f"[eval] cppish cache {start_i + done}/{eval_samples}")
        else:
            y_more = np.zeros((remain, y_dim), dtype=np.float32)
            items_cppish = [(i, samples_eval[i]) for i in range(start_i, int(eval_samples))]
            with ProcessPoolExecutor(
                max_workers=workers,
                initializer=_mp_worker_init_cppish,
                initargs=(str(export_json),),
            ) as ex:
                futs = [ex.submit(_mp_eval_cppish, it) for it in items_cppish]
                done = 0
                for fut in as_completed(futs):
                    idx, y_out = fut.result()
                    y_more[idx - start_i] = y_out
                    done += 1
                    if int(args.progress_every) > 0 and (done % int(args.progress_every) == 0):
                        print(f"[eval] cppish cache {start_i + done}/{eval_samples}")
        if remain > 0:
            if start_i > 0:
                y_cppish_all = np.concatenate([y_cppish_all, y_more], axis=0)
            else:
                y_cppish_all = y_more
            np.save(cppish_path, y_cppish_all.astype(np.float32))
    y_cppish_eval = y_cppish_all[:eval_samples]

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
    cppish_vs_cpp = np.abs(y_cppish_eval - y_cpp_eval)
    summary = {
        "samples": int(eval_samples),
        "total_available_samples": int(total_samples),
        "limit": int(args.limit),
        "scan_mode": args.scan_mode,
        "continuous_state": bool(args.continuous_state),
        "chain4_input_mode": chain4_input_mode,
        "cache_threshold": int(threshold),
        "chain4_cache_validation": cache_validation,
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
        "cppish_vs_cpp": {
            "mae": float(np.mean(cppish_vs_cpp)),
            "max_abs": float(np.max(cppish_vs_cpp)),
        },
        "block_error_accumulation": {},
        "sample0": {
            "y_cpp": y_cpp_eval[0].astype(float).tolist(),
            "y_cppish": y_cppish_eval[0].astype(float).tolist(),
            "y_hw_like": y_hw[0].astype(float).tolist(),
            "y_true": y_true_eval[0].astype(float).tolist(),
            "y_float": y_float_eval[0].astype(float).tolist(),
        },
    }

    np.save(float_dir / "hw_like_full.npy", y_hw.astype(np.float32))
    write_json(log_dir / "full_hw_like_eval.json", summary)
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
