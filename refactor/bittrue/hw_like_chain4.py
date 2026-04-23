from __future__ import annotations

from concurrent.futures import ProcessPoolExecutor, as_completed
import json
import math
from pathlib import Path

import numpy as np

_MP_CHAIN4_CTX: dict | None = None
_MP_CHAIN4_SCAN_MODE: str = "scaled_state"


# RTL: helper used by reuse_mamba_chain4_core_adapter / reuse_mamba_4block_chain_top model.
def _signed_qmax_for_bits(bits: int) -> int:
    return (1 << (bits - 1)) - 1


# RTL: helper used by reuse_mamba_chain4_core_adapter / reuse_mamba_4block_chain_top model.
def _signed_qmin_for_bits(bits: int) -> int:
    return -(1 << (bits - 1))


# RTL: helper used by reuse_mamba_chain4_core_adapter / reuse_mamba_4block_chain_top model.
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


# RTL: helper used by reuse_mamba_chain4_core_adapter / reuse_mamba_4block_chain_top model.
def _rshift_rne_vec(x: np.ndarray, shift: int) -> np.ndarray:
    flat = x.reshape(-1)
    out = np.empty_like(flat, dtype=np.int64)
    for i in range(flat.shape[0]):
        out[i] = _rshift_rne_i64(int(flat[i]), shift)
    return out.reshape(x.shape)


# RTL: reuse_state_scale_pingpong exact integer scale calculation from current u(q8.8).
def _runtime_scales_from_u_q88(u_q88_rows: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    u_i = u_q88_rows.astype(np.int64)
    abs_u = np.abs(u_i)
    abs_u_eff = np.where(abs_u == 0, 256, abs_u).astype(np.int64)
    u_to_state_q16 = ((int(32767) << 16) + (abs_u_eff >> 1)) // abs_u_eff
    state_to_q88_q16 = ((abs_u_eff << 16) + int(16383)) // int(32767)
    u_to_state_q16 = np.clip(u_to_state_q16, 0, 0xFFFFFFFF).astype(np.int64)
    state_to_q88_q16 = np.clip(state_to_q88_q16, 0, 0xFFFFFFFF).astype(np.int64)
    return u_to_state_q16, state_to_q88_q16


# RTL: helper used by reuse_mamba_chain4_core_adapter / reuse_mamba_4block_chain_top model.
def _to_u16(v: int) -> int:
    return int(v) & 0xFFFF


# RTL: helper used by reuse_mamba_chain4_core_adapter / reuse_mamba_4block_chain_top model.
def _from_u16_signed(v: int) -> int:
    v &= 0xFFFF
    return v - 0x10000 if (v & 0x8000) else v


# RTL: helper used by reuse_mamba_chain4_core_adapter / reuse_mamba_4block_chain_top model.
def _mul_q88_unsigned_signed(a_u16: int, b_s16: int) -> int:
    prod = int(a_u16 & 0xFFFF) * int(b_s16)
    raw = (prod >> 8) & 0xFFFF
    return _from_u16_signed(raw)


# RTL: helper used by reuse_mamba_chain4_core_adapter / reuse_mamba_4block_chain_top model.
def _add_wrap_s16(a_s16: int, b_s16: int) -> int:
    return _from_u16_signed((int(a_s16) + int(b_s16)) & 0xFFFF)


# RTL: Q8.8 quantizer used at block IO boundaries in chain4 model.
def _quant_q88(x: np.ndarray) -> np.ndarray:
    q = np.rint(x.astype(np.float64) * 256.0).astype(np.int64)
    return np.clip(q, -32768, 32767).astype(np.int16)


# RTL: helper used by reuse_mamba_chain4_core_adapter / reuse_mamba_4block_chain_top model.
def _wrap_s16_arr(x: np.ndarray) -> np.ndarray:
    x_i = x.astype(np.int64) & 0xFFFF
    x_s = np.where((x_i & 0x8000) != 0, x_i - 0x10000, x_i)
    return x_s.astype(np.int16)


# RTL: helper used by reuse_mamba_chain4_core_adapter / reuse_mamba_4block_chain_top model.
def _clamp_s16_arr(x: np.ndarray) -> np.ndarray:
    return np.clip(x.astype(np.int64), -32768, 32767).astype(np.int16)


# RTL: helper used by reuse_mamba_chain4_core_adapter / reuse_mamba_4block_chain_top model.
def _find_sigmoid_lut() -> Path | None:
    for p in (Path("user/data/sigmoid_lut_q016_2048.hex"), Path("sigmoid_lut_q016_2048.hex")):
        if p.exists():
            return p.resolve()
    return None


# RTL: loads sigmoid4_vec ROM contents used by dt/gate sigmoid.
def _sigmoid_lut_values() -> list[int]:
    lut_path = _find_sigmoid_lut()
    if lut_path is not None:
        vals = [int(line.strip(), 16) & 0xFFFF for line in lut_path.read_text(encoding="utf-8").splitlines() if line.strip()]
        if len(vals) == 2048:
            return vals
    vals: list[int] = []
    for raw in range(-1024, 1024):
        x = raw / 256.0
        s = 1.0 / (1.0 + math.exp(-x))
        vals.append(max(0, min(0xFFFF, int(round(s * 65536.0)))))
    return vals


# RTL: maps to sigmoid4_vec LUT address/lookup path.
def _sigmoid_q016_from_q88(x_q88: np.ndarray) -> np.ndarray:
    x_i = x_q88.astype(np.int64)
    x_clamp = np.clip(x_i, -1024, 1023)
    addr = (x_clamp + 1024).astype(np.int64)
    lut = np.asarray(_sigmoid_lut_values(), dtype=np.uint16)
    return lut[addr]


# RTL: Q0.16*Q8.8 multiply used in silu/gate datapaths.
def _mul_q016_q88_to_q88(a_q016: np.ndarray, b_q88: np.ndarray) -> np.ndarray:
    prod = a_q016.astype(np.int64) * b_q88.astype(np.int64)
    return _wrap_s16_arr(prod >> 16)


# RTL: Q8.8*Q8.8 multiply used by gate*ssm datapath.
def _mul_q88_q88_to_q88(a_q88: np.ndarray, b_q88: np.ndarray) -> np.ndarray:
    prod = a_q88.astype(np.int64) * b_q88.astype(np.int64)
    return _wrap_s16_arr(prod >> 8)


# RTL: dt bias ROM add path in reuse_mamba_block_top.
def _add_bias_q88_rows(x_rows: np.ndarray, bias_vec: np.ndarray | None) -> np.ndarray:
    if bias_vec is None:
        return x_rows.astype(np.int16, copy=True)
    x_i = x_rows.astype(np.int64)
    b_q88 = _quant_q88(np.asarray(bias_vec, dtype=np.float32).reshape(-1)).astype(np.int64)
    return _wrap_s16_arr(x_i + b_q88.reshape(x_i.shape))


# RTL: helper carrier for quant metadata during integer front-end conv modeling.
class _XWithBase(np.ndarray):
    base_dir: Path


# RTL: helper used by reuse_mamba_chain4_core_adapter / reuse_mamba_4block_chain_top model.
def _attach_base_dir(x: np.ndarray, base_dir: Path) -> np.ndarray:
    y = np.asarray(x).view(_XWithBase)
    y.base_dir = base_dir
    return y


# RTL: helper used by reuse_mamba_chain4_core_adapter / reuse_mamba_4block_chain_top model.
def _conv1d_out_len(in_len: int, kernel_size: int, stride: int, padding: int) -> int:
    return (in_len + 2 * padding - kernel_size) // stride + 1


# RTL: helper used by reuse_mamba_chain4_core_adapter / reuse_mamba_4block_chain_top model.
def _load_scale_vector(qdesc: dict, base_dir: Path) -> np.ndarray:
    scale_ref = qdesc.get("scale", "")
    if isinstance(scale_ref, str) and scale_ref:
        return np.load(base_dir / scale_ref).astype(np.float32).reshape(-1)
    return np.zeros((0,), dtype=np.float32)


# RTL: helper used by reuse_mamba_chain4_core_adapter / reuse_mamba_4block_chain_top model.
def _make_activation_scales(qdesc: dict, channels: int, x: np.ndarray) -> np.ndarray:
    if qdesc.get("enabled") and qdesc.get("scheme") == "per_channel_sym":
        scales = _load_scale_vector(qdesc, x.base_dir if hasattr(x, "base_dir") else Path("."))  # type: ignore
        if scales.shape[0] == channels:
            return scales.astype(np.float32)
    scales = np.ones((channels,), dtype=np.float32)
    if qdesc.get("enabled") and qdesc.get("scheme") == "per_tensor_asym" and float(qdesc.get("scale", 0.0) or 0.0) > 0.0:
        scales.fill(float(qdesc["scale"]))
        return scales
    mx = float(np.max(np.abs(x))) if x.size else 0.0
    scales.fill((mx / 127.0) if mx > 0.0 else (1.0 / 127.0))
    return scales


# RTL: helper used by reuse_mamba_chain4_core_adapter / reuse_mamba_4block_chain_top model.
def _quantize_centered_input(x: float, scale: float, bits: int, zero_point: int, raw_qmin: int, raw_qmax: int) -> int:
    if scale == 0.0:
        return 0
    qmin = raw_qmin if raw_qmin < raw_qmax else _signed_qmin_for_bits(bits)
    qmax = raw_qmax if raw_qmax > raw_qmin else _signed_qmax_for_bits(bits)
    q = int(np.rint(float(x) / float(scale))) + int(zero_point)
    q = max(qmin, min(qmax, q))
    return q - int(zero_point)


# RTL: front-end proj/patch integer conv model before chain4 core.
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
                w_eff[oc, icg, k] = max(qmin, min(qmax, int(np.rint(folded))))
    for t in range(t_out):
        for oc in range(desc["out_channels"]):
            g = oc // cout_per_group
            acc = int(np.rint(float(bias[oc]) / float(out_scales[oc]))) if bias is not None else 0
            for icg in range(cin_per_group):
                ic = g * cin_per_group + icg
                for k in range(desc["kernel_size"]):
                    ti = t * desc["stride"] - desc["padding"] + k
                    if 0 <= ti < t_in:
                        acc += int(xq[ti, ic]) * int(w_eff[oc, icg, k])
            y_tc[t, oc] = float(acc) * float(out_scales[oc])
    return y_tc


# RTL: final_norm float-side helper after chain4 block outputs.
def _rmsnorm_inplace_np(x_tc: np.ndarray, norm_desc: dict, base_dir: Path) -> None:
    weight = np.load(base_dir / norm_desc["weight"]).astype(np.float32).reshape(-1)
    eps = float(norm_desc.get("eps", 1e-5))
    for t in range(x_tc.shape[0]):
        mean_sq = float(np.mean(np.square(x_tc[t].astype(np.float64))))
        inv = 1.0 / math.sqrt(mean_sq + eps)
        x_tc[t] = x_tc[t] * np.float32(inv) * weight


# RTL: activation LUT helper aligned with sigmoid/silu lookup approximation flow.
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


# RTL: resolves exported IR assets used to initialize chain4 model parameters.
def _load_export_ir(export_json: Path) -> tuple[dict, dict, Path]:
    export = json.loads(export_json.read_text(encoding="utf-8"))
    base_dir = export_json.parent
    backbone = json.loads((base_dir / export["backbone"]["file"]).read_text(encoding="utf-8"))
    return export, backbone, base_dir


# RTL: models mac_mem_controller + rounding/saturation in reuse_mamba_block_top.
def _conv1x1_q88_rne_clamp(weight_2d: np.ndarray, x_q88: np.ndarray) -> np.ndarray:
    w_q88 = _quant_q88(weight_2d).astype(np.int64)
    acc_q1616 = w_q88 @ x_q88.astype(np.int64)
    return _clamp_s16_arr(_rshift_rne_vec(acc_q1616, 8))


# RTL: models RMSNorm fixed-point block in reuse_mamba_block_top.
def _rmsnorm_q88_hw(raw_q88: np.ndarray, gamma_q88: np.ndarray, eps_q16: int = 1, mode: str = "exact_recip30") -> tuple[np.ndarray, int]:
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
    recip_frac_bits = 30 if mode == "exact_recip30" else 24
    recip = int(((1 << recip_frac_bits) + (int(rms_q88) >> 1)) // int(rms_q88))
    half = 1 << (recip_frac_bits - 1)
    out = np.zeros((dim,), dtype=np.int16)
    for i in range(dim):
        mul = int(raw_i[i] * gamma_i[i]) * recip
        out[i] = np.int16(max(-32768, min(32767, int((mul + half) >> recip_frac_bits) if mul >= 0 else int((mul - half) >> recip_frac_bits))))
    return out, rms_q88


# RTL: models ew_update_vec4 fixed-Q8.8 state update datapath.
def _ssm_update_q88_from_lam_q016(lam_q016: np.ndarray, u_q88_rows: np.ndarray) -> np.ndarray:
    state_depth = int(u_q88_rows.shape[0])
    state_runtime = [[0 for _ in range(u_q88_rows.shape[1])] for _ in range(state_depth)]
    last_wr_valid = False
    last_wr_addr = 0
    last_wr_data = [0 for _ in range(u_q88_rows.shape[1])]
    out_rows: list[list[int]] = []
    for t in range(u_q88_rows.shape[0]):
        s_addr = t % state_depth
        s_prev = last_wr_data[:] if (last_wr_valid and last_wr_addr == s_addr) else state_runtime[s_addr][:]
        s_new: list[int] = []
        for lane in range(u_q88_rows.shape[1]):
            lam_r = (int(lam_q016[t, lane]) >> 8) & 0xFFFF
            one_minus = (0x0100 - lam_r) & 0xFFFF
            s_prev_s = _from_u16_signed(int(s_prev[lane]))
            u_s = int(np.int16(u_q88_rows[t, lane]))
            s_new_lane = _add_wrap_s16(_mul_q88_unsigned_signed(lam_r, s_prev_s), _mul_q88_unsigned_signed(one_minus, u_s))
            s_new.append(_to_u16(s_new_lane))
        s_addr_w = (s_addr + 1) % state_depth
        state_runtime[s_addr_w] = s_new[:]
        last_wr_valid = True
        last_wr_addr = s_addr_w
        last_wr_data = s_new[:]
        out_rows.append([_from_u16_signed(v) for v in s_new])
    return np.asarray(out_rows, dtype=np.int16)


# RTL: models scaled-state ew_update_vec4 quantized update path.
def _ssm_update_scaled_state_q15_from_q88(u_q88_rows: np.ndarray, lam_q016_rows: np.ndarray) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    state_depth, tile = u_q88_rows.shape
    u_q88 = u_q88_rows.astype(np.int64)
    u_to_state_q16, state_to_q88_q16 = _runtime_scales_from_u_q88(u_q88_rows)
    u_state = _rshift_rne_vec(u_q88 * u_to_state_q16.astype(np.int64), 16)
    u_state = np.clip(u_state, -(1 << 15), (1 << 15) - 1)
    lam_q15 = np.clip(lam_q016_rows.astype(np.int64) >> 1, 0, 1 << 15)
    one_minus_q15 = (1 << 15) - lam_q15
    state_runtime = np.zeros((state_depth, tile), dtype=np.int64)
    last_wr_valid = False
    last_wr_addr = 0
    last_wr_data = np.zeros((tile,), dtype=np.int64)
    out_state = np.zeros((state_depth, tile), dtype=np.int64)
    for t in range(state_depth):
        s_addr = t % state_depth
        s_prev = last_wr_data.copy() if (last_wr_valid and last_wr_addr == s_addr) else state_runtime[s_addr].copy()
        acc = lam_q15[t] * s_prev + one_minus_q15[t] * u_state[t]
        s_new = np.clip(_rshift_rne_vec(acc, 15), -(1 << 15), (1 << 15) - 1)
        s_addr_w = (s_addr + 1) % state_depth
        state_runtime[s_addr_w] = s_new
        last_wr_valid = True
        last_wr_addr = s_addr_w
        last_wr_data = s_new.copy()
        out_state[t] = s_new
    ssm_q88 = np.clip(_rshift_rne_vec(out_state * state_to_q88_q16.astype(np.int64), 16), -32768, 32767).astype(np.int16)
    return ssm_q88, u_to_state_q16, state_to_q88_q16


# RTL: loads inproj/dtproj/outproj weights for block MAC path model.
def _load_weight_2d_from_desc(base_dir: Path, conv_desc: dict) -> np.ndarray:
    w = np.load(base_dir / conv_desc["weight"]).astype(np.float32)
    return w.reshape(int(conv_desc["out_channels"]), int(conv_desc["in_channels"]))


# RTL: helper used by reuse_mamba_chain4_core_adapter / reuse_mamba_4block_chain_top model.
def _rshift_rne_i64_vec(x: np.ndarray, shift: int) -> np.ndarray:
    base = 1 << int(shift)
    q = x // base
    r = x % base
    half = base >> 1
    return q + ((r > half) | ((r == half) & ((q & 1) != 0))).astype(np.int64)


# RTL: binds STAGE_DIR_B* assets like reuse_mamba_chain4_core_adapter.
def build_chain4_ctx(export_json: Path, case_dir: Path | None = None) -> dict:
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


# RTL: models per-channel state scale setup used around ew_update_vec4.
def make_scaled_state_runtime(
    u_q88_rows: np.ndarray,
    fixed_u_to_state_q16: np.ndarray | None = None,
    fixed_state_to_q88_q16: np.ndarray | None = None,
) -> dict:
    state_depth, tile = u_q88_rows.shape
    if fixed_u_to_state_q16 is not None:
        u_to_state_q16 = np.asarray(fixed_u_to_state_q16, dtype=np.int64).reshape(state_depth, tile)
    else:
        u_to_state_q16, _ = _runtime_scales_from_u_q88(u_q88_rows)
    if fixed_state_to_q88_q16 is not None:
        state_to_q88_q16 = np.asarray(fixed_state_to_q88_q16, dtype=np.int64).reshape(state_depth, tile)
    else:
        _, state_to_q88_q16 = _runtime_scales_from_u_q88(u_q88_rows)
    return {
        "state_depth": int(state_depth),
        "tile": int(tile),
        "u_to_state_q16": u_to_state_q16,
        "state_to_q88_q16": state_to_q88_q16,
        "state_runtime": np.zeros((state_depth, tile), dtype=np.int64),
        "last_wr_valid": False,
        "last_wr_addr": 0,
        "last_wr_data": np.zeros((tile,), dtype=np.int64),
    }


# RTL: models state RAM read/write-forward behavior in ew_update_vec4.
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


# RTL: block boundary step used by reuse_mamba_4block_chain_top.
def block_step_hw_q88(
    blk_cache: dict,
    h_in_q88: np.ndarray,
    scan_mode: str,
    runtime: dict | None = None,
) -> tuple[np.ndarray, np.ndarray]:
    trace = block_step_hw_q88_trace(
        blk_cache=blk_cache,
        h_in_q88=h_in_q88,
        scan_mode=scan_mode,
        runtime=runtime,
    )
    return trace["x_next_q88"].astype(np.int16), trace["y_q88"].astype(np.int16)


# RTL: block-level trace for reuse_mamba_block_top (rmsnorm/inproj/dt/ssm/outproj).
def block_step_hw_q88_trace(
    blk_cache: dict,
    h_in_q88: np.ndarray,
    scan_mode: str,
    runtime: dict | None = None,
) -> dict:
    h_raw_q88 = h_in_q88.astype(np.int16).reshape(-1)
    h_norm_q88, rms_q88 = _rmsnorm_q88_hw(h_raw_q88, blk_cache["norm_gamma_q88"], eps_q16=1, mode="exact_recip30")
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
    u_to_state_q16 = None
    state_to_q88_q16 = None
    if scan_mode == "scaled_state":
        if runtime is None:
            ssm_q88, u_to_state_q16, state_to_q88_q16 = _ssm_update_scaled_state_q15_from_q88(u_act_q88, lam_q016)
        else:
            if runtime.get("state_runtime") is None:
                runtime.update(make_scaled_state_runtime(u_act_q88))
            ssm_q88 = ssm_update_scaled_state_q15_stateful(u_act_q88, lam_q016, runtime)
            u_to_state_q16 = runtime["u_to_state_q16"].copy()
            state_to_q88_q16 = runtime["state_to_q88_q16"].copy()
    else:
        ssm_q88 = _ssm_update_q88_from_lam_q016(lam_q016, u_act_q88)
    gate_y_q88 = _mul_q88_q88_to_q88(z_silu_q88, ssm_q88)
    y_q88 = _conv1x1_q88_rne_clamp(blk_cache["out_w"], gate_y_q88.reshape(-1)).reshape(32, 4)
    x_next_q88 = _clamp_s16_arr(h_raw_q88.astype(np.int64).reshape(32, 4) + y_q88.astype(np.int64)).reshape(-1)
    if u_to_state_q16 is None or state_to_q88_q16 is None:
        runtime_tmp = make_scaled_state_runtime(u_act_q88)
        u_to_state_q16 = runtime_tmp["u_to_state_q16"].copy()
        state_to_q88_q16 = runtime_tmp["state_to_q88_q16"].copy()
    return {
        "h_raw_q88": h_raw_q88.reshape(32, 4).astype(np.int16),
        "h_norm_q88": h_norm_q88.reshape(32, 4).astype(np.int16),
        "rms_q88": int(rms_q88),
        "u_q88_rows": u_q88_rows.astype(np.int16),
        "z_q88_rows": z_q88_rows.astype(np.int16),
        "u_act_q88": u_act_q88.astype(np.int16),
        "z_silu_q88": z_silu_q88.astype(np.int16),
        "dt_q88_mac": dt_q88_mac.astype(np.int16),
        "dt_q88": dt_q88.astype(np.int16),
        "lam_q016": lam_q016.astype(np.uint16),
        "ssm_q88": ssm_q88.astype(np.int16),
        "gate_y_q88": gate_y_q88.astype(np.int16),
        "y_q88": y_q88.astype(np.int16),
        "x_next_q88": x_next_q88.astype(np.int16).reshape(32, 4),
        "u_to_state_q16": u_to_state_q16.astype(np.int64),
        "state_to_q88_q16": state_to_q88_q16.astype(np.int64),
    }


# RTL: exports block0-h/block3-h/block3-y stream tuple for board-shell TB.
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


# RTL: 4-block chain trace matching reuse_mamba_4block_chain_top stream order.
def compute_chain4_trace_from_sample(
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

    h_inputs = np.zeros((4, 32, 4), dtype=np.int16)
    y_outputs = np.zeros((4, 32, 4), dtype=np.int16)
    for bi, blk_cache in enumerate(ctx["blocks"]):
        h_inputs[bi] = x_q88.reshape(32, 4).astype(np.int16)
        runtime_i = None if runtimes is None else runtimes[bi]
        x_q88, y_q88 = block_step_hw_q88(blk_cache, x_q88, scan_mode=scan_mode, runtime=runtime_i)
        y_outputs[bi] = y_q88.astype(np.int16)
    return h_inputs, y_outputs


# RTL: exports block3 input/output pair consumed by eval post-chain.
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


# RTL: multiprocessing init for chain4 per-sample stateless worker.
def _mp_worker_init_chain_pair(export_json_str: str, scan_mode: str, case_dir_str: str | None) -> None:
    global _MP_CHAIN4_CTX, _MP_CHAIN4_SCAN_MODE
    case_dir = Path(case_dir_str) if case_dir_str else None
    _MP_CHAIN4_CTX = build_chain4_ctx(Path(export_json_str), case_dir=case_dir)
    _MP_CHAIN4_SCAN_MODE = str(scan_mode)


# RTL: multiprocessing worker producing block3 h/y pair.
def _mp_collect_chain4_pair(item: tuple[int, np.ndarray]) -> tuple[int, np.ndarray, np.ndarray]:
    idx, sample = item
    assert _MP_CHAIN4_CTX is not None
    _, h_q88, y_q88 = compute_chain4_triplet_from_sample(_MP_CHAIN4_CTX, sample, scan_mode=_MP_CHAIN4_SCAN_MODE)
    return idx, h_q88.astype(np.int16), y_q88.astype(np.int16)


# RTL: multiprocessing worker producing block0 h + block3 h/y triplet.
def _mp_collect_chain4_triplet(item: tuple[int, np.ndarray]) -> tuple[int, np.ndarray, np.ndarray, np.ndarray]:
    idx, sample = item
    assert _MP_CHAIN4_CTX is not None
    h0_q88, h3_q88, y_q88 = compute_chain4_triplet_from_sample(_MP_CHAIN4_CTX, sample, scan_mode=_MP_CHAIN4_SCAN_MODE)
    return idx, h0_q88.astype(np.int16), h3_q88.astype(np.int16), y_q88.astype(np.int16)


# RTL: stateless per-sample chain4 generation matching stream frame reset behavior.
def collect_chain4_q88_parallel(
    export_json: Path,
    case_dir: Path | None,
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
        ctx = build_chain4_ctx(export_json, case_dir=case_dir)
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
            initargs=(str(export_json), str(scan_mode), (str(case_dir) if case_dir is not None else None)),
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


# RTL: continuous-state debug generation across samples (legacy check path).
def collect_chain4_q88_continuous(
    export_json: Path,
    case_dir: Path | None,
    samples_eval: np.ndarray,
    scan_mode: str,
    progress_every: int,
) -> tuple[np.ndarray, np.ndarray]:
    num_samples = int(samples_eval.shape[0])
    y_batch = np.zeros((num_samples, 32, 4), dtype=np.int16)
    h_batch = np.zeros((num_samples, 32, 4), dtype=np.int16)
    ctx = build_chain4_ctx(export_json, case_dir=case_dir)
    runtimes: list[dict] = [{"state_runtime": None} for _ in range(4)]
    for i in range(num_samples):
        h_i, y_i = compute_chain4_pair_from_sample(ctx, samples_eval[i], scan_mode=scan_mode, runtimes=runtimes)
        h_batch[i] = h_i
        y_batch[i] = y_i
        if int(progress_every) > 0 and ((i + 1) % int(progress_every) == 0):
            print(f"[eval] generated continuous chain4 q88 {i + 1}/{num_samples}")
    return y_batch, h_batch


# RTL: stateless triplet batch for board-shell stream golden export.
def collect_chain4_triplets_parallel(
    export_json: Path,
    case_dir: Path | None,
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
        ctx = build_chain4_ctx(export_json, case_dir=case_dir)
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
            initargs=(str(export_json), str(scan_mode), (str(case_dir) if case_dir is not None else None)),
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


# RTL: continuous-state triplet batch for legacy stream debug.
def collect_chain4_triplets_continuous(
    export_json: Path,
    case_dir: Path | None,
    samples_eval: np.ndarray,
    scan_mode: str,
    progress_every: int,
) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    num_samples = int(samples_eval.shape[0])
    h0_batch = np.zeros((num_samples, 32, 4), dtype=np.int16)
    h3_batch = np.zeros((num_samples, 32, 4), dtype=np.int16)
    y_batch = np.zeros((num_samples, 32, 4), dtype=np.int16)
    ctx = build_chain4_ctx(export_json, case_dir=case_dir)
    runtimes: list[dict] = [{"state_runtime": None} for _ in range(4)]
    for i in range(num_samples):
        h0_i, h3_i, y_i = compute_chain4_triplet_from_sample(ctx, samples_eval[i], scan_mode=scan_mode, runtimes=runtimes)
        h0_batch[i] = h0_i
        h3_batch[i] = h3_i
        y_batch[i] = y_i
        if int(progress_every) > 0 and ((i + 1) % int(progress_every) == 0):
            print(f"[eval] generated continuous chain4 triplets {i + 1}/{num_samples}")
    return h0_batch, h3_batch, y_batch


# RTL: cache file mapping for chain4 stream-equivalent outputs.
def _chain4_cache_paths(case_dir: Path) -> tuple[Path, Path]:
    chain_stage = case_dir / "stages" / "reuse_mamba_block_top_chain4"
    return chain_stage / "final_y_q88_batch.npy", chain_stage / "block3_h_in_q88_batch.npy"


# RTL: loads cached chain4 block3 io batches for eval fast path.
def load_chain4_cache(case_dir: Path) -> tuple[np.ndarray, np.ndarray] | None:
    y_path, h_path = _chain4_cache_paths(case_dir)
    if not y_path.exists() or not h_path.exists():
        return None
    y = np.load(y_path).astype(np.int16)
    h = np.load(h_path).astype(np.int16)
    if y.shape != h.shape:
        return None
    return y, h


# RTL: persists chain4 block3 io batches for eval fast path.
def save_chain4_cache(case_dir: Path, y_batch: np.ndarray, h_batch: np.ndarray) -> None:
    y_path, h_path = _chain4_cache_paths(case_dir)
    y_path.parent.mkdir(parents=True, exist_ok=True)
    np.save(y_path, y_batch.astype(np.int16))
    np.save(h_path, h_batch.astype(np.int16))


# RTL: reads packed stream_y_golden_* mem frames for cache consistency checks.
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


# RTL: verifies cached chain4 outputs against exported stream mem golden.
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
