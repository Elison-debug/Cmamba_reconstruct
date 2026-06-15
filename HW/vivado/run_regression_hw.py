from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
RUN_XSIM = ROOT / "HW" / "vivado" / "run_xsim_hw.py"


def _run(cmd: list[str]) -> int:
    print("[reg]", " ".join(cmd))
    cp = subprocess.run(cmd, cwd=str(ROOT))
    return cp.returncode


def main() -> None:
    p = argparse.ArgumentParser(
        description="Run focused HW regression. Default gate is final-y correctness."
    )
    p.add_argument("--case_dir", default=str(ROOT / "final_hw" / "cases" / "c01"))
    p.add_argument("--run_tag", default="reg")
    p.add_argument(
        "--include_legacy_block_debug",
        action="store_true",
        help="Also run legacy_block_hw_debug (non-gating debug path).",
    )
    args = p.parse_args()

    tests: list[tuple[str, bool]] = [
        ("slim_block_smoke", True),
        ("slim_block_hw_debug", True),
        ("slim_chain4_smoke", True),
        ("slim_chain4_debug", True),
        ("slim_chain4_top_debug", True),
        ("legacy_chain4_debug", True),
    ]
    if args.include_legacy_block_debug:
        tests.append(("legacy_block_hw_debug", False))

    results: list[tuple[str, int, bool]] = []
    for stage, gating in tests:
        cmd = [
            sys.executable,
            str(RUN_XSIM),
            "--stage",
            stage,
            "--run_name",
            f"{args.run_tag}_{stage}",
        ]
        if stage.startswith("legacy_") or stage.endswith("_hw_debug") or stage.endswith("_chain4_debug") or stage in {"slim_chain4_top_debug", "slim_chain4_smoke"}:
            cmd.extend(["--case_dir", args.case_dir])
        rc = _run(cmd)
        results.append((stage, rc, gating))

    print("\n[reg] summary")
    fail_gating = False
    for stage, rc, gating in results:
        status = "PASS" if rc == 0 else "FAIL"
        gate = "gating" if gating else "non-gating"
        print(f"  - {stage:24s} {status:4s} ({gate})")
        if gating and rc != 0:
            fail_gating = True

    if fail_gating:
        raise SystemExit(1)


if __name__ == "__main__":
    main()

