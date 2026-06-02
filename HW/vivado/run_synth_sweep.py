from __future__ import annotations

import argparse
import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
HW_DIR = ROOT / "HW"
RTL_MM_DIRS = [
    HW_DIR / "rtl" / "common",
    HW_DIR / "rtl" / "linear",
    HW_DIR / "rtl" / "state",
    HW_DIR / "rtl" / "block",
]
RTL_LEGACY_DIR = HW_DIR / "rtl" / "legacy_reuse_shared"
IP_DIR = HW_DIR / "ip"
RUN_ROOT = HW_DIR / "synth_runs"


def _vivado_bin() -> Path:
    for p in [
        Path(r"E:\Xilinx\Vivado\2024.1\bin\vivado.bat"),
        Path(r"C:\Xilinx\Vivado\2024.1\bin\vivado.bat"),
    ]:
        if p.exists():
            return p
    raise FileNotFoundError("Vivado 2024.1 not found")


def _ip_sources(mode: str) -> list[Path]:
    out: list[Path] = []
    ip_names = ["bias_ROM", "bias2sigmoid_fifo", "inproj_ht_sram_ip", "inproj_vec_out_sram_ip", "s_buffer"]
    for ip_name in ip_names:
        base = IP_DIR / ip_name
        if not base.exists():
            continue
        candidates: list[Path] = []
        if mode == "stub":
            candidates.extend([base / f"{ip_name}_stub.v", base / "sim" / f"{ip_name}.v"])
        elif mode == "sim":
            candidates.extend([base / "sim" / f"{ip_name}.v", base / f"{ip_name}_stub.v"])
        else:
            candidates.extend([base / f"{ip_name}_sim_netlist.v", base / f"{ip_name}_stub.v", base / "sim" / f"{ip_name}.v"])
        for c in candidates:
            if c.exists():
                out.append(c)
                break
    return sorted(out)

def _rtl_sources(source_set: str) -> list[Path]:
    out: list[Path] = []
    if source_set in {"mm", "all"}:
        for d in RTL_MM_DIRS:
            if d.exists():
                out.extend(sorted(p for p in d.glob("*") if p.suffix in {".sv", ".v"}))
    if source_set in {"legacy", "all"}:
        if RTL_LEGACY_DIR.exists():
            out.extend(sorted(p for p in RTL_LEGACY_DIR.glob("*") if p.suffix in {".sv", ".v"}))
    seen = set()
    uniq: list[Path] = []
    for p in out:
        if p not in seen:
            seen.add(p)
            uniq.append(p)
    return uniq


def _write_tcl(run_dir: Path, top: str, part: str, rtl: list[Path], ip: list[Path], period_ns: float) -> Path:
    tcl = run_dir / "run.tcl"
    lines: list[str] = []
    for src in rtl:
        if src.suffix == ".sv":
            lines.append(f'read_verilog -sv "{src.as_posix()}"')
        else:
            lines.append(f'read_verilog "{src.as_posix()}"')
    for src in ip:
        lines.append(f'read_verilog "{src.as_posix()}"')
    lines.append(f"synth_design -top {top} -part {part} -flatten_hierarchy rebuilt")
    lines.append(f'if {{[llength [get_ports clk]] > 0}} {{ create_clock -period {period_ns} -name clk [get_ports clk] }}')
    lines.append(f'if {{[llength [get_ports sys_clk]] > 0}} {{ create_clock -period {period_ns} -name sys_clk [get_ports sys_clk] }}')
    lines.append(f'report_timing_summary -delay_type max -max_paths 10 -file "{(run_dir / "timing_summary.rpt").as_posix()}"')
    lines.append(f'report_utilization -file "{(run_dir / "utilization.rpt").as_posix()}"')
    lines.append(f'write_checkpoint -force "{(run_dir / "post_synth.dcp").as_posix()}"')
    lines.append("quit")
    tcl.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return tcl


def _extract_wns(report_path: Path) -> tuple[str, str]:
    if not report_path.exists():
        return "NA", "NA"
    txt = report_path.read_text(encoding="utf-8", errors="ignore")
    m_wns = re.search(r"WNS\(ns\)\s+TNS\(ns\).*?\n[-\s]+\n\s*([-\d\.]+)\s+([-\d\.]+)", txt, re.S)
    if m_wns:
        return m_wns.group(1), m_wns.group(2)
    m2 = re.search(r"Design Timing Summary.*?WNS.*?\n.*?\n\s*([-\d\.]+)\s+([-\d\.]+)", txt, re.S)
    if m2:
        return m2.group(1), m2.group(2)
    return "NA", "NA"


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--tops",
        nargs="+",
        default=[
            "slm_gemv_scheduler",
            "slm_state_datapath",
            "slm_mamba_block_top",
        ],
    )
    ap.add_argument("--part", default="xczu9eg-ffvb1156-2-e")
    ap.add_argument("--ip_mode", choices=["stub", "sim", "netlist"], default="stub")
    ap.add_argument("--source_set", choices=["mm", "legacy", "all"], default="mm")
    ap.add_argument("--periods", nargs="+", type=float, default=[10.0], help="Clock periods (ns) to sweep, e.g. --periods 10 8 6 5")
    args = ap.parse_args()

    vivado = _vivado_bin()
    RUN_ROOT.mkdir(parents=True, exist_ok=True)
    rtl = _rtl_sources(args.source_set)
    ip = _ip_sources(args.ip_mode)
    summary_rows: list[str] = ["top,period_ns,wns_ns,tns_ns,run_dir"]

    for period_ns in args.periods:
        for top in args.tops:
            tag = f"{top}_p{str(period_ns).replace('.', 'p')}"
            run_dir = RUN_ROOT / tag
            run_dir.mkdir(parents=True, exist_ok=True)
            tcl = _write_tcl(run_dir, top, args.part, rtl, ip, period_ns)
            cmd = [str(vivado), "-mode", "batch", "-source", str(tcl), "-log", str(run_dir / "vivado.log"), "-journal", str(run_dir / "vivado.jou")]
            print("[synth]", " ".join(cmd))
            rc = subprocess.run(cmd, cwd=str(run_dir)).returncode
            if rc == 0:
                wns, tns = _extract_wns(run_dir / "timing_summary.rpt")
            else:
                wns, tns = "FAIL", "FAIL"
            summary_rows.append(f"{top},{period_ns},{wns},{tns},{run_dir.as_posix()}")

    (RUN_ROOT / "summary.csv").write_text("\n".join(summary_rows) + "\n", encoding="utf-8")
    print("[synth] summary:", (RUN_ROOT / "summary.csv").as_posix())


if __name__ == "__main__":
    main()

