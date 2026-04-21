from __future__ import annotations

import argparse
import os
import shutil
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
RTL_DIR = ROOT / "HW_reconstruct" / "rtl_reuse_shared"
HW_DIR = ROOT / "HW_reconstruct"
TB_DIR = ROOT / "HW_reconstruct" / "tb"
RUN_ROOT = ROOT / "HW_reconstruct" / "hw_debug" / "vivado_runs"
PROJ_IP_GEN_DIR = ROOT / "HW_reconstruct" / "project_mamba_all1" / "project_mamba_all1.gen" / "sources_1" / "ip"


def _vivado_bin() -> Path:
    env = os.environ.get("VIVADO_BIN", "").strip()
    if env:
        p = Path(env)
        if p.exists():
            return p
    for p in [
        Path(r"E:\Xilinx\Vivado\2024.1\bin"),
        Path(r"C:\Xilinx\Vivado\2024.1\bin"),
    ]:
        if p.exists():
            return p
    raise FileNotFoundError("Vivado bin not found. Set VIVADO_BIN to <Vivado>/bin.")


def _lut_src(case_dir: str | None) -> Path:
    candidates = []
    if case_dir:
        case = Path(case_dir).resolve()
        candidates.extend(
            [
                case / "stages" / "sigmoid4_vec" / "lut_q016_2048.hex",
                case / "stages" / "reuse_mamba_block_top" / "lut_q016_2048.hex",
            ]
        )
    candidates.extend(
        [
            ROOT / "user" / "data" / "sigmoid_lut_q016_2048.hex",
            ROOT / "sigmoid_lut_q016_2048.hex",
        ]
    )
    for p in candidates:
        if p.exists():
            return p
    raise FileNotFoundError("No in-repo LUT found. Provide --case_dir or place LUT under user/data/.")


def _pick_first_existing(paths: list[Path]) -> Path | None:
    for p in paths:
        if p.exists():
            return p
    return None


def _collect_ip_wrappers() -> list[str]:
    """
    Resolve currently-available Vivado IP simulation wrapper/netlist files.
    Keep this dynamic so the script follows the live project IP set instead
    of stale hardcoded names.
    """
    candidates: list[Path | None] = [
        _pick_first_existing(
            [
                PROJ_IP_GEN_DIR / "bias_ROM" / "sim" / "bias_ROM.v",
                PROJ_IP_GEN_DIR / "bias_ROM" / "bias_ROM_sim_netlist.v",
            ]
        ),
        _pick_first_existing(
            [
                PROJ_IP_GEN_DIR / "bias2sigmoid_fifo" / "sim" / "bias2sigmoid_fifo.v",
                PROJ_IP_GEN_DIR / "bias2sigmoid_fifo" / "bias2sigmoid_fifo_sim_netlist.v",
            ]
        ),
        _pick_first_existing(
            [
                PROJ_IP_GEN_DIR / "inproj_ht_sram_ip" / "sim" / "inproj_ht_sram_ip.v",
                PROJ_IP_GEN_DIR / "inproj_ht_sram_ip_1" / "sim" / "inproj_ht_sram_ip.v",
                PROJ_IP_GEN_DIR / "inproj_ht_sram_ip" / "inproj_ht_sram_ip_sim_netlist.v",
            ]
        ),
        _pick_first_existing(
            [
                PROJ_IP_GEN_DIR / "inproj_vec_out_sram_ip" / "sim" / "inproj_vec_out_sram_ip.v",
                PROJ_IP_GEN_DIR / "inproj_vec_out_sram_ip" / "inproj_vec_out_sram_ip_sim_netlist.v",
            ]
        ),
        _pick_first_existing(
            [
                PROJ_IP_GEN_DIR / "s_buffer" / "sim" / "s_buffer.v",
                PROJ_IP_GEN_DIR / "s_buffer" / "s_buffer_sim_netlist.v",
            ]
        ),
        _pick_first_existing(
            [
                PROJ_IP_GEN_DIR / "outproj_WBUF_bank_dp" / "sim" / "outproj_WBUF_bank_dp.v",
                PROJ_IP_GEN_DIR / "outproj_WBUF_bank_dp" / "outproj_WBUF_bank_dp_sim_netlist.v",
            ]
        ),
        _pick_first_existing(
            [
                PROJ_IP_GEN_DIR / "slim_WBUF_bank_dp" / "sim" / "slim_WBUF_bank_dp.v",
                PROJ_IP_GEN_DIR / "slim_WBUF_bank_dp" / "slim_WBUF_bank_dp_sim_netlist.v",
            ]
        ),
        _pick_first_existing(
            [
                PROJ_IP_GEN_DIR / "u_xt_rom" / "sim" / "u_xt_rom.v",
                PROJ_IP_GEN_DIR / "u_xt_rom" / "u_xt_rom_sim_netlist.v",
            ]
        ),
    ]
    return [str(p) for p in candidates if p is not None]


def _stage_cfg(stage: str) -> dict:
    all_rtl = sorted(str(p) for p in RTL_DIR.glob("*.sv") if p.name != "reuse_ip_blackboxes.sv")
    ip_wrappers = _collect_ip_wrappers()
    shared_sources = [*all_rtl, *ip_wrappers]
    if stage == "sigmoid4_vec":
        return {
            "tb_top": "tb_sigmoid4_vec",
            "tb_file": str(TB_DIR / "tb_sigmoid4_vec.sv"),
            "sources": shared_sources,
            "xsim_plusargs": [],
            "xvlog_defines": [],
        }
    if stage == "reuse_top_gate":
        return {
            "tb_top": "tb_reuse_top_mac_plus_bias_fifo_sigmoid_ew_gate",
            "tb_file": str(TB_DIR / "tb_reuse_top_mac_plus_bias_fifo_sigmoid_ew_gate.sv"),
            "sources": shared_sources,
            "xsim_plusargs": [],
            "xvlog_defines": [],
        }
    if stage == "reuse_mamba_block_top":
        return {
            "tb_top": "tb_reuse_mamba_block_top",
            "tb_file": str(TB_DIR / "tb_reuse_mamba_block_top.sv"),
            "sources": shared_sources,
            "xsim_plusargs": [],
            "xvlog_defines": [],
        }
    if stage == "reuse_mamba_block_top_hw_debug":
        return {
            "tb_top": "tb_reuse_mamba_block_top_hw_debug",
            "tb_file": str(TB_DIR / "tb_reuse_mamba_block_top_hw_debug.sv"),
            "sources": shared_sources,
            "xsim_plusargs": [],
            "xvlog_defines": [],
        }
    if stage == "reuse_ssm_core_hw_debug":
        return {
            "tb_top": "tb_reuse_ssm_core_hw_debug",
            "tb_file": str(TB_DIR / "tb_reuse_ssm_core_hw_debug.sv"),
            "sources": shared_sources,
            "xsim_plusargs": [],
            "xvlog_defines": [],
        }
    if stage == "reuse_ssm_dt_scheduler_hw_debug":
        return {
            "tb_top": "tb_reuse_ssm_dt_scheduler_hw_debug",
            "tb_file": str(TB_DIR / "tb_reuse_ssm_dt_scheduler_hw_debug.sv"),
            "sources": [
                *shared_sources,
                str(RTL_DIR / "reuse_slim_mac_mem_controller_combined_dp.sv"),
                str(RTL_DIR / "reuse_array4x4.sv"),
                str(RTL_DIR / "reuse_pipeline_4array_top.sv"),
                str(RTL_DIR / "reuse_pipeline_4array_with_reduction.sv"),
                str(RTL_DIR / "reuse_reduction_accumulator.sv"),
            ],
            "xsim_plusargs": [],
            "xvlog_defines": [],
        }
    if stage == "reuse_mamba_board_shell_ps":
        return {
            "tb_top": "tb_reuse_mamba_board_shell_ps",
            "tb_file": str(TB_DIR / "tb_reuse_mamba_board_shell_ps.sv"),
            "sources": [
                *shared_sources,
                str(RTL_DIR / "reuse_mamba_board_shell.v"),
                str(RTL_DIR / "reuse_mamba_h_stream_loader.v"),
            ],
            "xsim_plusargs": [],
            "xvlog_defines": [],
        }
    if stage == "reuse_mamba_4block_chain_top":
        return {
            "tb_top": "tb_reuse_mamba_4block_chain_top",
            "tb_file": str(TB_DIR / "tb_reuse_mamba_4block_chain_top.sv"),
            "sources": shared_sources,
            "xsim_plusargs": [],
            "xvlog_defines": [],
        }
    raise ValueError(f"unsupported stage: {stage}")


def _run(cmd: list[str], cwd: Path) -> None:
    print("[xsim]", " ".join(cmd))
    subprocess.run(cmd, cwd=str(cwd), check=True)


def main() -> None:
    p = argparse.ArgumentParser(description="Run non-GUI Vivado xsim stage with in-repo relative assets.")
    p.add_argument(
        "--stage",
        required=True,
        choices=[
            "sigmoid4_vec",
            "reuse_top_gate",
            "reuse_mamba_block_top",
            "reuse_mamba_block_top_hw_debug",
            "reuse_ssm_core_hw_debug",
            "reuse_ssm_dt_scheduler_hw_debug",
            "reuse_mamba_board_shell_ps",
            "reuse_mamba_4block_chain_top",
        ],
    )
    p.add_argument("--case_dir", default="", help="Optional hw_debug case dir used to source LUT/mem files.")
    p.add_argument("--run_name", default="", help="Optional run directory name.")
    p.add_argument("--gui", action="store_true")
    p.add_argument("--clean", action="store_true")
    args = p.parse_args()

    vivado_bin = _vivado_bin()
    vivado_root = vivado_bin.parent
    glbl_v = vivado_root / "data" / "verilog" / "src" / "glbl.v"
    cfg = _stage_cfg(args.stage)
    run_name = args.run_name or args.stage
    run_dir = RUN_ROOT / run_name
    if args.clean and run_dir.exists():
        shutil.rmtree(run_dir)
    run_dir.mkdir(parents=True, exist_ok=True)

    lut_src = _lut_src(args.case_dir or None)
    shutil.copyfile(lut_src, run_dir / "sigmoid_lut_q016_2048.hex")
    for mif in PROJ_IP_GEN_DIR.rglob("*.mif"):
        shutil.copyfile(mif, run_dir / mif.name)

    prj = run_dir / "files.prj"
    with open(prj, "w", encoding="utf-8") as f:
        for src in cfg["sources"]:
            lang = "verilog" if src.endswith(".v") else "sv"
            f.write(f'{lang} work "{src}"\n')
        f.write(f'sv work "{cfg["tb_file"]}"\n')
        if glbl_v.exists():
            f.write(f'verilog work "{glbl_v}"\n')

    tcl = run_dir / "run.tcl"
    case_dir_norm = ""
    case_dir_define = ""
    if args.case_dir:
        case_dir_abs = Path(args.case_dir).resolve()
        case_dir_norm = os.path.relpath(case_dir_abs, run_dir).replace("\\", "/")
        case_dir_define = case_dir_abs.as_posix()
        (case_dir_abs / "rtl_out" / args.stage.replace("_hw_debug", "")).mkdir(parents=True, exist_ok=True)
        (case_dir_abs / "rtl_out" / args.stage).mkdir(parents=True, exist_ok=True)

    if args.stage in {"reuse_mamba_block_top_hw_debug", "reuse_ssm_core_hw_debug", "reuse_ssm_dt_scheduler_hw_debug"}:
        (run_dir / "tb_hw_debug_case_path.svh").write_text(
            f'`define HW_DEBUG_CASE_DIR "{case_dir_define}"\n', encoding="utf-8"
        )

    plusargs = [arg.format(case_dir=case_dir_norm) for arg in cfg.get("xsim_plusargs", [])]
    xvlog_defines = [arg.format(case_dir=case_dir_norm) for arg in cfg.get("xvlog_defines", [])]
    xsim_testplusargs: list[str] = []
    for arg in plusargs:
        xsim_testplusargs.extend(["--testplusarg", arg])

    if args.gui:
        tcl.write_text("log_wave -recursive *\n", encoding="utf-8")
        xsim_args = [
            cfg["tb_top"],
            "-gui",
            "-wdb",
            f"{cfg['tb_top']}.wdb",
            "-tclbatch",
            "run.tcl",
            "-log",
            "xsim.log",
            *xsim_testplusargs,
        ]
    else:
        tcl.write_text("log_wave -recursive *\nrun all\nexit\n", encoding="utf-8")
        xsim_args = [
            cfg["tb_top"],
            "-wdb",
            f"{cfg['tb_top']}.wdb",
            "-tclbatch",
            "run.tcl",
            "-log",
            "xsim.log",
            *xsim_testplusargs,
        ]

    xvlog_cmd = [str(vivado_bin / "xvlog.bat"), "--sv", "--relax", "-i", "."]
    for define in xvlog_defines:
        xvlog_cmd.extend(["-d", define])
    xvlog_cmd.extend(["-prj", "files.prj", "-log", "xvlog.log"])
    _run(xvlog_cmd, run_dir)
    _run(
        [
            str(vivado_bin / "xelab.bat"),
            "--relax",
            "--timescale",
            "1ns/1ps",
            "--debug",
            "typical",
            "-L",
            "xpm",
            "-L",
            "blk_mem_gen_v8_4_8",
            "-L",
            "fifo_generator_v13_2_10",
            "-L",
            "unisims_ver",
            "-L",
            "unimacro_ver",
            "-L",
            "secureip",
            cfg["tb_top"],
            "glbl",
            "-s",
            cfg["tb_top"],
            "-log",
            "xelab.log",
        ],
        run_dir,
    )
    _run([str(vivado_bin / "xsim.bat"), *xsim_args], run_dir)

    print(f"[xsim] done: {run_dir}")


if __name__ == "__main__":
    main()
