from __future__ import annotations

import argparse
import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
RTL_DIR = ROOT / "final_hw" / "rtl_reuse_shared"
IP_DIR = ROOT / "final_hw" / "ip"
PROJECT_IP_GEN_DIR = ROOT / "final_hw" / "project_mamba_final_hw" / "project_mamba_final_hw.gen" / "sources_1" / "ip"
PROJECT_IP_CACHE_DIR = ROOT / "final_hw" / "project_mamba_final_hw" / "project_mamba_final_hw.cache" / "ip" / "2024.1"
RUN_ROOT = ROOT / "final_hw" / "synth_runs"


def _vivado_bin() -> Path:
    for p in [
        Path(r"E:\Xilinx\Vivado\2024.1\bin\vivado.bat"),
        Path(r"C:\Xilinx\Vivado\2024.1\bin\vivado.bat"),
    ]:
        if p.exists():
            return p
    raise FileNotFoundError("Vivado 2024.1 not found")


def _ip_sources(mode: str) -> list[Path]:
    # Use only top-level IP wrappers/netlists to avoid pulling in encrypted
    # or behavioral-only support files (e.g. fifo_generator behavioral model).
    out: list[Path] = []
    ip_names = ["bias_ROM", "bias2sigmoid_fifo", "inproj_ht_sram_ip", "inproj_vec_out_sram_ip", "s_buffer"]
    for ip_name in ip_names:
        base_candidates = [
            IP_DIR / ip_name,
            PROJECT_IP_GEN_DIR / ip_name,
        ]
        # cache dir uses hashed subdirs, so we search lazily there as fallback
        candidates: list[Path] = []
        if mode == "stub":
            for base in base_candidates:
                candidates.extend([base / f"{ip_name}_stub.v", base / "sim" / f"{ip_name}.v"])
            if PROJECT_IP_CACHE_DIR.exists():
                candidates.extend(PROJECT_IP_CACHE_DIR.rglob(f"{ip_name}_stub.v"))
        elif mode == "sim":
            for base in base_candidates:
                candidates.extend([base / "sim" / f"{ip_name}.v", base / f"{ip_name}_stub.v"])
            if PROJECT_IP_CACHE_DIR.exists():
                candidates.extend(PROJECT_IP_CACHE_DIR.rglob(f"{ip_name}_sim_netlist.v"))
                candidates.extend(PROJECT_IP_CACHE_DIR.rglob(f"{ip_name}_stub.v"))
        else:
            # netlist mode can fail because many *_sim_netlist.v are
            # simulation-only; keep as optional fallback.
            for base in base_candidates:
                candidates.extend([base / f"{ip_name}_sim_netlist.v", base / f"{ip_name}_stub.v", base / "sim" / f"{ip_name}.v"])
            if PROJECT_IP_CACHE_DIR.exists():
                candidates.extend(PROJECT_IP_CACHE_DIR.rglob(f"{ip_name}_sim_netlist.v"))
                candidates.extend(PROJECT_IP_CACHE_DIR.rglob(f"{ip_name}_stub.v"))
        for c in candidates:
            if c.exists():
                out.append(c)
                break
    return sorted(out)


def _legacy_ip_dep_sources() -> list[Path]:
    out: list[Path] = []
    for p in IP_DIR.rglob("simulation/*.v"):
        out.append(p)
    for p in IP_DIR.rglob("hdl/*.v"):
        out.append(p)
    return sorted(set(out))


def _rtl_sources() -> list[Path]:
    skip = {
        "reuse_ip_blackboxes.sv",
        "reuse_mamba_board_shell.v",
        "reuse_mamba_board_shell_with_g_loader.v",
        "reuse_mamba_g_stream_loader.v",
    }
    return sorted(p for p in RTL_DIR.glob("*") if p.suffix in {".sv", ".v"} and p.name not in skip)


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
            "reuse_rmsnorm_scheduler",
            "reuse_in_proj_scheduler",
            "reuse_ssm_dt_scheduler",
            "reuse_ssm_core",
            "reuse_out_proj_scheduler",
            "reuse_mamba_block_top",
            "reuse_mamba_4block_chain_top",
            "reuse_mamba_board_shell",
        ],
    )
    ap.add_argument("--part", default="xczu9eg-ffvb1156-2-e")
    ap.add_argument("--ip_mode", choices=["stub", "sim", "netlist"], default="stub")
    ap.add_argument("--periods", nargs="+", type=float, default=[10.0], help="Clock periods (ns) to sweep, e.g. --periods 10 8 6 5")
    args = ap.parse_args()

    vivado = _vivado_bin()
    RUN_ROOT.mkdir(parents=True, exist_ok=True)
    rtl = _rtl_sources()
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
            rc = subprocess.run(cmd, cwd=str(ROOT)).returncode
            if rc == 0:
                wns, tns = _extract_wns(run_dir / "timing_summary.rpt")
            else:
                wns, tns = "FAIL", "FAIL"
            summary_rows.append(f"{top},{period_ns},{wns},{tns},{run_dir.as_posix()}")

    (RUN_ROOT / "summary.csv").write_text("\n".join(summary_rows) + "\n", encoding="utf-8")
    print("[synth] summary:", (RUN_ROOT / "summary.csv").as_posix())


if __name__ == "__main__":
    main()
