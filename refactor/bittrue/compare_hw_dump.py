from __future__ import annotations

import argparse
import json
from pathlib import Path


def _read_lines(path: Path) -> list[str]:
    return [ln.strip() for ln in path.read_text(encoding="utf-8").splitlines() if ln.strip()]


def _decode_hex64_lanes(line: str, signed: bool, lane_bits: int, lanes: int) -> list[int]:
    raw = int(line, 16)
    out = []
    mask = (1 << lane_bits) - 1
    sign_bit = 1 << (lane_bits - 1)
    for lane in range(lanes):
        v = (raw >> (lane * lane_bits)) & mask
        if signed and (v & sign_bit):
            v -= (1 << lane_bits)
        out.append(v)
    return out


def _compare_one(golden: Path, rtl: Path, signed: bool, lane_bits: int, lanes: int) -> dict:
    g_lines = _read_lines(golden)
    r_lines = _read_lines(rtl)
    count = min(len(g_lines), len(r_lines))
    for idx in range(count):
        if g_lines[idx].upper() != r_lines[idx].upper():
            return {
                "match": False,
                "reason": "line_mismatch",
                "line": idx + 1,
                "golden_raw": g_lines[idx],
                "rtl_raw": r_lines[idx],
                "golden_decoded": _decode_hex64_lanes(g_lines[idx], signed, lane_bits, lanes),
                "rtl_decoded": _decode_hex64_lanes(r_lines[idx], signed, lane_bits, lanes),
                "golden_file": str(golden.resolve()),
                "rtl_file": str(rtl.resolve()),
            }
    if len(g_lines) != len(r_lines):
        return {
            "match": False,
            "reason": "line_count_mismatch",
            "golden_lines": len(g_lines),
            "rtl_lines": len(r_lines),
            "golden_file": str(golden.resolve()),
            "rtl_file": str(rtl.resolve()),
        }
    return {
        "match": True,
        "lines": len(g_lines),
        "golden_file": str(golden.resolve()),
        "rtl_file": str(rtl.resolve()),
    }


def main() -> None:
    p = argparse.ArgumentParser(description="Compare RTL dump mem files against hardware-debug golden mem files.")
    p.add_argument("--case_dir", type=str, required=True)
    p.add_argument("--stage", type=str, required=True)
    p.add_argument("--rtl_dir", type=str, default="")
    p.add_argument("--signed", action="store_true")
    p.add_argument("--lane_bits", type=int, default=16)
    p.add_argument("--lanes", type=int, default=4)
    p.add_argument("--files", nargs="*", default=[], help="optional explicit filenames to compare")
    args = p.parse_args()

    case_dir = Path(args.case_dir)
    stage_dir = case_dir / "stages" / args.stage
    rtl_dir = Path(args.rtl_dir) if args.rtl_dir else (case_dir / "rtl_out" / args.stage)
    log_dir = case_dir / "logs"
    log_dir.mkdir(parents=True, exist_ok=True)

    if not stage_dir.exists():
        raise FileNotFoundError(f"stage dir not found: {stage_dir}")
    if not rtl_dir.exists():
        raise FileNotFoundError(f"rtl dir not found: {rtl_dir}")

    if args.files:
        names = args.files
    else:
        names = sorted([p.name for p in stage_dir.glob("*.mem") if (rtl_dir / p.name).exists()])

    results = []
    first_fail = None
    for name in names:
        res = _compare_one(stage_dir / name, rtl_dir / name, args.signed, args.lane_bits, args.lanes)
        res["file"] = name
        results.append(res)
        if first_fail is None and not res["match"]:
            first_fail = res

    summary = {
        "case_dir": str(case_dir.resolve()),
        "stage": args.stage,
        "rtl_dir": str(rtl_dir.resolve()),
        "match": all(r["match"] for r in results),
        "files": results,
        "first_fail": first_fail,
    }
    out_path = log_dir / f"compare_{args.stage}.json"
    out_path.write_text(json.dumps(summary, indent=2), encoding="utf-8")
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
