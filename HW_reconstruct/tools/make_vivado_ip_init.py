from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np


def q88_rne_clamp(x: np.ndarray) -> np.ndarray:
    scaled = np.rint(x.astype(np.float64) * 256.0)
    clipped = np.clip(scaled, -32768, 32767).astype(np.int16)
    return clipped


def pack_i16x4_to_u64(words: np.ndarray) -> list[int]:
    assert words.ndim == 1
    assert words.size % 4 == 0
    packed: list[int] = []
    u16 = words.astype(np.uint16)
    for i in range(0, u16.size, 4):
        w0 = int(u16[i + 0])
        w1 = int(u16[i + 1])
        w2 = int(u16[i + 2])
        w3 = int(u16[i + 3])
        packed.append(w0 | (w1 << 16) | (w2 << 32) | (w3 << 48))
    return packed


def write_mem(path: Path, values: list[int], width_bits: int) -> None:
    hex_digits = width_bits // 4
    path.write_text("\n".join(f"{v:0{hex_digits}X}" for v in values) + "\n", encoding="ascii")


def write_coe(path: Path, values: list[int], width_bits: int) -> None:
    hex_digits = width_bits // 4
    lines = [
        "memory_initialization_radix=16;",
        "memory_initialization_vector=",
    ]
    body = [f"{v:0{hex_digits}X}" for v in values]
    if body:
        body[-1] += ";"
    path.write_text("\n".join(lines) + "\n" + ",\n".join(body) + "\n", encoding="ascii")


def zero_words(depth: int) -> list[int]:
    return [0] * depth


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[2])
    ap.add_argument("--case-dir", type=Path, default=Path("HW_reconstruct/hw_debug/cases/test_case3_smoke"))
    ap.add_argument("--export-dir", type=Path, default=Path("export_bittrue/case1"))
    ap.add_argument("--block-index", type=int, default=0)
    ap.add_argument("--out-dir", type=Path, default=Path("HW_reconstruct/hw_debug/cases/test_case3_smoke/ip_init/block0"))
    args = ap.parse_args()

    repo_root = args.repo_root.resolve()
    case_dir = (repo_root / args.case_dir).resolve()
    export_dir = (repo_root / args.export_dir).resolve()
    out_dir = (repo_root / args.out_dir).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)

    stage_dir = case_dir / "stages" / "reuse_mamba_block_top"
    backbone = json.loads((export_dir / "backbone.json").read_text(encoding="utf-8"))
    dt_proj = backbone["blocks"][args.block_index]["ssm"]["dt_proj"]
    bias_path = export_dir / dt_proj["bias_file"]

    bias_f = np.load(bias_path).astype(np.float32).reshape(-1)
    if bias_f.size != 256:
        raise ValueError(f"expected 256 dt bias values, got {bias_f.size} from {bias_path}")
    bias_q88 = q88_rne_clamp(bias_f)
    bias_words = pack_i16x4_to_u64(bias_q88)
    if len(bias_words) != 64:
        raise ValueError(f"expected 64 packed bias words, got {len(bias_words)}")

    xt_mem_path = stage_dir / "xt_hw_golden_q88.mem"
    if not xt_mem_path.exists():
        xt_mem_path = stage_dir / "u_act_golden_q88.mem"
    xt_lines = [ln.strip() for ln in xt_mem_path.read_text(encoding="ascii").splitlines() if ln.strip()]
    xt_words = [int(ln, 16) for ln in xt_lines]
    if len(xt_words) != 64:
        raise ValueError(f"expected 64 xt words, got {len(xt_words)} from {xt_mem_path}")

    artifacts = {
        "bias_ROM_block.coe": bias_words,
        "bias_ROM_block.mem": bias_words,
        "u_xt_rom_block.coe": xt_words,
        "u_xt_rom_block.mem": xt_words,
        "inproj_ht_sram_zero.coe": zero_words(32),
        "inproj_ht_sram_zero.mem": zero_words(32),
        "inproj_vec_out_sram_zero.coe": zero_words(64),
        "inproj_vec_out_sram_zero.mem": zero_words(64),
        "s_buffer_zero.coe": zero_words(64),
        "s_buffer_zero.mem": zero_words(64),
    }

    for name, values in artifacts.items():
        path = out_dir / name
        if path.suffix.lower() == ".coe":
            write_coe(path, values, 64)
        else:
            write_mem(path, values, 64)

    manifest = {
        "block_index": args.block_index,
        "bias_source": str(bias_path.relative_to(repo_root)),
        "xt_source": str(xt_mem_path.relative_to(repo_root)),
        "generated": sorted(artifacts.keys()),
        "notes": {
            "bias_ROM": "real dt_proj bias for the selected block, quantized to Q8.8 and packed as 4x int16 per 64-bit word",
            "u_xt_rom": "debug/static xt preload for legacy MAC-controller tops only; not used by current board shell path",
            "inproj_ht_sram_ip": "optional zero-init debug image",
            "inproj_vec_out_sram_ip": "optional zero-init debug image",
            "s_buffer": "optional zero-init debug image"
        }
    }
    (out_dir / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
