from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
HW_DIR = ROOT / "HW"
OPEN_TCL = HW_DIR / "vivado" / "open_hw_project.tcl"


def _vivado_bin() -> Path:
    for p in [
        Path(r"E:\Xilinx\Vivado\2024.1\bin\vivado.bat"),
        Path(r"C:\Xilinx\Vivado\2024.1\bin\vivado.bat"),
    ]:
        if p.exists():
            return p
    raise FileNotFoundError("Vivado 2024.1 not found")


def main() -> None:
    p = argparse.ArgumentParser(description="Open the configured Slim-Mamba Vivado GUI project.")
    p.add_argument(
        "--tcl",
        default=str(OPEN_TCL),
        help="Tcl script used to open or create the HW Vivado project.",
    )
    args = p.parse_args()

    vivado = _vivado_bin()
    tcl = Path(args.tcl).resolve()
    if not tcl.exists():
        raise FileNotFoundError(f"Tcl script not found: {tcl}")

    cmd = [
        str(vivado),
        "-mode",
        "gui",
        "-source",
        str(tcl),
    ]
    print("[vivado-gui]", " ".join(cmd))
    raise SystemExit(subprocess.run(cmd, cwd=str(ROOT)).returncode)


if __name__ == "__main__":
    main()
