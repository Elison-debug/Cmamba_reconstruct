from __future__ import annotations

import argparse
import os
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
RTL_SHELL_DIR = HW_DIR / "rtl" / "shell"
RTL_LEGACY_DIR = HW_DIR / "rtl" / "legacy_reuse_shared"
RTL_IP_FALLBACK_DIR = HW_DIR / "rtl" / "ip_fallback"
IP_DIR = HW_DIR / "ip"
RUN_ROOT = HW_DIR / "synth_runs"
LEGACY_PROJ_IP_GEN_DIR = ROOT / "final_hw" / "project_mamba_final_hw" / "project_mamba_final_hw.gen" / "sources_1" / "ip"
HW_MOVED_IP_GEN_DIR = HW_DIR / "project_mamba_final_hw" / "project_mamba_final_hw.gen" / "sources_1" / "ip"


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
    if mode == "rtl":
        if RTL_IP_FALLBACK_DIR.exists():
            return sorted(p for p in RTL_IP_FALLBACK_DIR.glob("*") if p.suffix in {".sv", ".v"})
        return []
    for ip_name in ip_names:
        base = IP_DIR / ip_name
        if not base.exists():
            continue
        candidates: list[Path] = []
        if mode == "xci":
            candidates.extend([base / f"{ip_name}.xci"])
        elif mode == "stub":
            candidates.extend([base / f"{ip_name}_stub.v", base / "sim" / f"{ip_name}.v"])
        elif mode == "sim":
            candidates.extend([base / "sim" / f"{ip_name}.v", base / f"{ip_name}_stub.v"])
        else:
            candidates.extend([base / f"{ip_name}_sim_netlist.v", base / f"{ip_name}_stub.v", base / "sim" / f"{ip_name}.v"])
        for c in candidates:
            if c.exists():
                out.append(c)
                break
        else:
            legacy_xci = ROOT / "final_hw" / "ip" / ip_name / f"{ip_name}.xci"
            legacy_sim = LEGACY_PROJ_IP_GEN_DIR / ip_name / "sim" / f"{ip_name}.v"
            legacy_net = LEGACY_PROJ_IP_GEN_DIR / ip_name / f"{ip_name}_sim_netlist.v"
            if mode == "xci" and legacy_xci.exists():
                out.append(legacy_xci)
            elif mode == "netlist" and legacy_net.exists():
                out.append(legacy_net)
            elif legacy_sim.exists():
                out.append(legacy_sim)
            elif legacy_net.exists():
                out.append(legacy_net)
    return sorted(out)


def _slm_stage_like_sources(top: str) -> list[Path]:
    mm_sources = _rtl_sources("mm")
    legacy_sources = _rtl_sources("legacy")

    sources: list[Path] = []
    if top == "slim_mamba_block":
        shell_sources = [
            RTL_SHELL_DIR / "slm_block_controller.sv",
            RTL_SHELL_DIR / "slm_linear_cfg_pkg.sv",
            RTL_SHELL_DIR / "slm_block_cfg_pkg.sv",
            RTL_SHELL_DIR / "slm_linear_controller.sv",
            RTL_SHELL_DIR / "slm_linear_stage.sv",
            RTL_SHELL_DIR / "slm_fabric_scheduler.sv",
            RTL_SHELL_DIR / "slm_ssm_stage.sv",
            RTL_SHELL_DIR / "slim_mamba_block.sv",
            RTL_SHELL_DIR / "slim_mamba_block_from_stage_dir.sv",
        ]
        sources = [*legacy_sources, *shell_sources, *mm_sources]
    elif top == "slim_mamba_chain4_top":
        shell_sources = [
            RTL_SHELL_DIR / "slm_chain_cfg_pkg.sv",
            RTL_SHELL_DIR / "slm_block_launch_ctrl.sv",
            RTL_SHELL_DIR / "slm_chain_controller.sv",
            RTL_SHELL_DIR / "slm_linear_cfg_pkg.sv",
            RTL_SHELL_DIR / "slm_block_cfg_pkg.sv",
            RTL_SHELL_DIR / "slim_mamba_chain4_top.sv",
            RTL_SHELL_DIR / "slim_mamba_chain4_core_adapter.sv",
            RTL_SHELL_DIR / "slm_block_controller.sv",
            RTL_SHELL_DIR / "slm_linear_controller.sv",
            RTL_SHELL_DIR / "slm_linear_stage.sv",
            RTL_SHELL_DIR / "slm_fabric_scheduler.sv",
            RTL_SHELL_DIR / "slm_ssm_stage.sv",
            RTL_SHELL_DIR / "slim_mamba_block.sv",
            RTL_SHELL_DIR / "slim_mamba_block_from_stage_dir.sv",
            RTL_SHELL_DIR / "slim_mamba_chain4.sv",
        ]
        sources = [*legacy_sources, *shell_sources, *mm_sources]
    else:
        return _rtl_sources("slim")

    seen = set()
    ordered: list[Path] = []
    for p in sources:
        if p.exists() and p not in seen:
            seen.add(p)
            ordered.append(p)
    return ordered

def _rtl_sources(source_set: str) -> list[Path]:
    out: list[Path] = []
    if source_set in {"mm", "slim", "all"}:
        for d in RTL_MM_DIRS:
            if d.exists():
                out.extend(sorted(p for p in d.glob("*") if p.suffix in {".sv", ".v"}))
    if source_set in {"slim", "all"}:
        if RTL_SHELL_DIR.exists():
            out.extend(sorted(p for p in RTL_SHELL_DIR.glob("*") if p.suffix in {".sv", ".v"}))
    if source_set in {"legacy", "all"}:
        if RTL_LEGACY_DIR.exists():
            exclude = {
                "reuse_mamba_board_shell.v",
                "reuse_mamba_board_shell_stream.v",
                "reuse_mamba_h_stream_loader.v",
            }
            out.extend(sorted(p for p in RTL_LEGACY_DIR.glob("*") if p.suffix in {".sv", ".v"} and p.name not in exclude))
    seen = set()
    uniq: list[Path] = []
    for p in out:
        if p not in seen:
            seen.add(p)
            uniq.append(p)
    pkg_priority = [
        str(HW_DIR / "rtl" / "linear" / "mm_gemv_job_pkg.sv"),
        str(RTL_SHELL_DIR / "slm_linear_cfg_pkg.sv"),
        str(RTL_SHELL_DIR / "slm_block_cfg_pkg.sv"),
        str(RTL_SHELL_DIR / "slm_chain_cfg_pkg.sv"),
    ]
    ordered: list[Path] = []
    used = set()
    for want in pkg_priority:
        for p in uniq:
            if str(p) == want and p not in used:
                ordered.append(p)
                used.add(p)
    for p in uniq:
        if p not in used:
            ordered.append(p)
    return ordered


def _default_lut_path() -> Path:
    for p in [
        HW_DIR / "ip" / "sigmoid_lut_q016_2048.hex",
        ROOT / "user" / "data" / "sigmoid_lut_q016_2048.hex",
    ]:
        if p.exists():
            return p.resolve()
    return (HW_DIR / "ip" / "sigmoid_lut_q016_2048.hex").resolve()


def _write_slim_synth_wrapper(run_dir: Path, top: str, case_dir: Path, lut_path: Path) -> tuple[Path, str]:
    wrapper = run_dir / f"{top}_synth_wrapper.sv"
    case_posix = case_dir.resolve().as_posix()
    lut_posix = lut_path.resolve().as_posix()
    b0 = f"{case_posix}/stages/reuse_mamba_block_top_block0"
    b1 = f"{case_posix}/stages/reuse_mamba_block_top_block1"
    b2 = f"{case_posix}/stages/reuse_mamba_block_top_block2"
    b3 = f"{case_posix}/stages/reuse_mamba_block_top_block3"

    if top == "slim_mamba_block":
        module_name = "slim_mamba_block_synth_top"
        text = f"""`timescale 1ns/1ps
import slm_block_cfg_pkg::*;

module {module_name} (
    input  logic clk,
    input  logic rst_n,
    input  logic block_start,
    output logic block_busy,
    output logic block_done,
    input  logic                         h_wr_en,
    input  logic [4:0]                   h_wr_addr,
    input  logic signed [15:0]           h_wr_data [3:0],
    output logic                         y_axis_TVALID,
    input  logic                         y_axis_TREADY,
    output logic signed [15:0]           y_axis_TDATA [3:0]
);
    localparam string STAGE_DIR = "{b0}";
    localparam string LUT_FILE  = "{lut_posix}";

    slim_mamba_block_from_stage_dir #(
        .TILE_SIZE(4),
        .DATA_WIDTH(16),
        .LUT_FILE(LUT_FILE),
        .STAGE_DIR(STAGE_DIR),
        .BLOCK_CFG(make_block_cfg_from_flags(1'b0, 1'b0, 1'b0, 1'b1, 1'b0))
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .block_start(block_start),
        .block_busy(block_busy),
        .block_done(block_done),
        .h_wr_en(h_wr_en),
        .h_wr_addr(h_wr_addr),
        .h_wr_data(h_wr_data),
        .y_axis_TVALID(y_axis_TVALID),
        .y_axis_TREADY(y_axis_TREADY),
        .y_axis_TDATA(y_axis_TDATA)
    );
endmodule
"""
    elif top == "slim_mamba_chain4_top":
        module_name = "slim_mamba_chain4_top_synth_top"
        text = f"""`timescale 1ns/1ps
import slm_block_cfg_pkg::*;

module {module_name} (
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    output logic busy,
    output logic done,
    input  logic                         h_wr_en,
    input  logic [4:0]                   h_wr_addr,
    input  logic signed [15:0]           h_wr_data [3:0],
    output logic                         y_valid,
    input  logic                         y_ready,
    output logic signed [15:0]           y_data [3:0]
);
    localparam string LUT_FILE = "{lut_posix}";

    slim_mamba_chain4_top #(
        .TILE_SIZE(4),
        .DATA_WIDTH(16),
        .LUT_FILE(LUT_FILE),
        .STAGE_DIR_B0("{b0}"),
        .STAGE_DIR_B1("{b1}"),
        .STAGE_DIR_B2("{b2}"),
        .STAGE_DIR_B3("{b3}"),
        .BLOCK_CFG_B0(make_block_cfg_from_flags(1'b0, 1'b0, 1'b0, 1'b1, 1'b0)),
        .BLOCK_CFG_B1(make_block_cfg_from_flags(1'b0, 1'b0, 1'b0, 1'b1, 1'b0)),
        .BLOCK_CFG_B2(make_block_cfg_from_flags(1'b0, 1'b0, 1'b0, 1'b1, 1'b0)),
        .BLOCK_CFG_B3(make_block_cfg_from_flags(1'b0, 1'b0, 1'b0, 1'b1, 1'b0))
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .busy(busy),
        .done(done),
        .h_wr_en(h_wr_en),
        .h_wr_addr(h_wr_addr),
        .h_wr_data(h_wr_data),
        .y_valid(y_valid),
        .y_ready(y_ready),
        .y_data(y_data)
    );
endmodule
"""
    else:
        raise ValueError(f"Unsupported wrapper top: {top}")

    wrapper.write_text(text, encoding="utf-8")
    return wrapper, module_name


def _write_tcl(run_dir: Path, top: str, synth_top: str, part: str, rtl: list[Path], ip: list[Path], period_ns: float) -> Path:
    tcl = run_dir / "run.tcl"
    lines: list[str] = [f"create_project -in_memory -part {part}"]
    for src in rtl:
        if src.suffix == ".sv":
            lines.append(f'read_verilog -sv "{src.as_posix()}"')
        else:
            lines.append(f'read_verilog "{src.as_posix()}"')
    for src in ip:
        if src.suffix == ".xci":
            lines.append(f'read_ip "{src.as_posix()}"')
        else:
            lines.append(f'read_verilog "{src.as_posix()}"')
    if any(src.suffix == ".xci" for src in ip):
        lines.append("generate_target synthesis [get_ips *]")
        for src in ip:
            if src.suffix != ".xci":
                continue
            ip_name = src.stem
            gen_dir = HW_MOVED_IP_GEN_DIR / ip_name
            synth_vhd = gen_dir / "synth" / f"{ip_name}.vhd"
            hdl_glob = (gen_dir / "hdl" / "*.vhd").as_posix()
            lines.append(f'if {{[file exists "{synth_vhd.as_posix()}"]}} {{ read_vhdl "{synth_vhd.as_posix()}" }}')
            lines.append(f'foreach f [glob -nocomplain "{hdl_glob}"] {{ read_vhdl $f }}')
    lines.append(f"synth_design -top {synth_top} -part {part} -flatten_hierarchy rebuilt")
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
            "slim_mamba_block",
            "slim_mamba_chain4_top",
        ],
    )
    ap.add_argument("--part", default="xczu9eg-ffvb1156-2-e")
    ap.add_argument("--ip_mode", choices=["rtl", "xci", "stub", "sim", "netlist"], default="rtl")
    ap.add_argument("--source_set", choices=["mm", "slim", "legacy", "all"], default="slim")
    ap.add_argument("--periods", nargs="+", type=float, default=[10.0], help="Clock periods (ns) to sweep, e.g. --periods 10 8 6 5")
    ap.add_argument("--run_root", default="", help="Override synthesis run root directory")
    ap.add_argument("--case_dir", default=str(ROOT / "final_hw" / "cases" / "c01"))
    ap.add_argument("--lut_file", default="", help="Override LUT init hex path")
    args = ap.parse_args()

    vivado = _vivado_bin()
    run_root = Path(args.run_root).resolve() if args.run_root else RUN_ROOT
    run_root.mkdir(parents=True, exist_ok=True)
    case_dir = Path(args.case_dir).resolve()
    lut_path = Path(args.lut_file).resolve() if args.lut_file else _default_lut_path()
    ip = _ip_sources(args.ip_mode)
    summary_rows: list[str] = ["top,period_ns,wns_ns,tns_ns,run_dir"]

    for period_ns in args.periods:
        for top in args.tops:
            rtl = _slm_stage_like_sources(top) if top in {"slim_mamba_block", "slim_mamba_chain4_top"} else _rtl_sources(args.source_set)
            tag = f"{top}_p{str(period_ns).replace('.', 'p')}"
            run_dir = run_root / tag
            run_dir.mkdir(parents=True, exist_ok=True)
            synth_top = top
            if top in {"slim_mamba_block", "slim_mamba_chain4_top"}:
                wrapper, synth_top = _write_slim_synth_wrapper(run_dir, top, case_dir, lut_path)
                rtl = [*rtl, wrapper]
            tcl = _write_tcl(run_dir, top, synth_top, args.part, rtl, ip, period_ns)
            cmd = [str(vivado), "-mode", "batch", "-source", str(tcl), "-log", str(run_dir / "vivado.log"), "-journal", str(run_dir / "vivado.jou")]
            print("[synth]", " ".join(cmd))
            rc = subprocess.run(cmd, cwd=str(run_dir)).returncode
            if rc == 0:
                wns, tns = _extract_wns(run_dir / "timing_summary.rpt")
            else:
                wns, tns = "FAIL", "FAIL"
            summary_rows.append(f"{top},{period_ns},{wns},{tns},{run_dir.as_posix()}")

    (run_root / "summary.csv").write_text("\n".join(summary_rows) + "\n", encoding="utf-8")
    print("[synth] summary:", (run_root / "summary.csv").as_posix())


if __name__ == "__main__":
    main()

