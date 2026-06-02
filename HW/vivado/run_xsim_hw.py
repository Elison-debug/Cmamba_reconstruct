from __future__ import annotations

import argparse
import os
import stat
import shutil
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
HW_DIR = ROOT / "HW"
RUN_ROOT = HW_DIR / "vivado_runs"
RTL_MM_DIRS = [
    HW_DIR / "rtl" / "common",
    HW_DIR / "rtl" / "linear",
    HW_DIR / "rtl" / "state",
    HW_DIR / "rtl" / "block",
]
RTL_LEGACY_DIR = HW_DIR / "rtl" / "legacy_reuse_shared"
TB_DIR = HW_DIR / "tb"
IP_DIR = HW_DIR / "ip"
RTL_SHELL_DIR = HW_DIR / "rtl" / "shell"
LEGACY_PROJ_IP_GEN_DIR = ROOT / "final_hw" / "project_mamba_final_hw" / "project_mamba_final_hw.gen" / "sources_1" / "ip"


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


def _collect_slm_sources() -> list[str]:
    out: list[str] = []
    for d in RTL_MM_DIRS:
        if d.exists():
            for p in sorted(d.glob("*")):
                if p.suffix in {".sv", ".v"}:
                    out.append(str(p))
    # Ensure package declarations are compiled before dependent modules.
    pkg = str(HW_DIR / "rtl" / "linear" / "slm_gemv_job_pkg.sv")
    if pkg in out:
        out = [pkg] + [p for p in out if p != pkg]
    return out


def _collect_legacy_sources() -> list[str]:
    out: list[str] = []
    if RTL_LEGACY_DIR.exists():
        for p in sorted(RTL_LEGACY_DIR.glob("*")):
            if p.suffix in {".sv", ".v"}:
                out.append(str(p))
    return out


def _collect_ip_wrappers() -> list[str]:
    wrappers: list[str] = []
    for ip in sorted(IP_DIR.glob("*")):
        if ip.is_dir():
            sim_v = ip / "sim" / f"{ip.name}.v"
            stub_v = ip / f"{ip.name}_stub.v"
            net_v = ip / f"{ip.name}_sim_netlist.v"
            if sim_v.exists():
                wrappers.append(str(sim_v))
            elif stub_v.exists():
                wrappers.append(str(stub_v))
            elif net_v.exists():
                wrappers.append(str(net_v))
            else:
                # Fallback to generated wrappers from legacy project output.
                legacy_sim = LEGACY_PROJ_IP_GEN_DIR / ip.name / "sim" / f"{ip.name}.v"
                legacy_net = LEGACY_PROJ_IP_GEN_DIR / ip.name / f"{ip.name}_sim_netlist.v"
                if legacy_sim.exists():
                    wrappers.append(str(legacy_sim))
                elif legacy_net.exists():
                    wrappers.append(str(legacy_net))
    return wrappers


def _stage_cfg(stage: str) -> dict:
    slm_sources = _collect_slm_sources()
    legacy_sources = _collect_legacy_sources()
    ip_sources = _collect_ip_wrappers()

    if stage == "slm_block_smoke":
        return {
            "tb_top": "tb_slm_mamba_block_top_smoke",
            "tb_file": str(TB_DIR / "tb_slm_mamba_block_top_smoke.sv"),
            "sources": [*slm_sources],
            "copy_case_mem": False,
        }

    if stage == "slim_block_smoke":
        return {
            "tb_top": "tb_slim_mamba_block_smoke",
            "tb_file": str(TB_DIR / "tb_slim_mamba_block_smoke.sv"),
            "sources": [
                *legacy_sources,
                str(RTL_SHELL_DIR / "slm_block_controller.sv"),
                str(RTL_SHELL_DIR / "slm_linear_cfg_pkg.sv"),
                str(RTL_SHELL_DIR / "slm_block_cfg_pkg.sv"),
                str(RTL_SHELL_DIR / "slm_linear_controller.sv"),
                str(RTL_SHELL_DIR / "slm_linear_stage.sv"),
                str(RTL_SHELL_DIR / "slm_fabric_scheduler.sv"),
                str(RTL_SHELL_DIR / "slm_ssm_stage.sv"),
                str(RTL_SHELL_DIR / "slim_mamba_block.sv"),
                *slm_sources,
                *ip_sources,
            ],
            "copy_case_mem": False,
        }

    if stage == "slim_block_hw_debug":
        return {
            "tb_top": "tb_slim_mamba_block_hw_debug",
            "tb_file": str(TB_DIR / "tb_slim_mamba_block_hw_debug.sv"),
            "sources": [
                *legacy_sources,
                str(RTL_SHELL_DIR / "slm_block_controller.sv"),
                str(RTL_SHELL_DIR / "slm_linear_cfg_pkg.sv"),
                str(RTL_SHELL_DIR / "slm_block_cfg_pkg.sv"),
                str(RTL_SHELL_DIR / "slm_linear_controller.sv"),
                str(RTL_SHELL_DIR / "slm_linear_stage.sv"),
                str(RTL_SHELL_DIR / "slm_fabric_scheduler.sv"),
                str(RTL_SHELL_DIR / "slm_ssm_stage.sv"),
                str(RTL_SHELL_DIR / "slim_mamba_block.sv"),
                *slm_sources,
                *ip_sources,
            ],
            "copy_case_mem": True,
        }

    if stage == "slim_chain4_debug":
        return {
            "tb_top": "tb_slim_mamba_chain4",
            "tb_file": str(TB_DIR / "tb_slim_mamba_chain4.sv"),
            "sources": [
                *legacy_sources,
                str(RTL_SHELL_DIR / "slm_chain_cfg_pkg.sv"),
                str(RTL_SHELL_DIR / "slm_block_launch_ctrl.sv"),
                str(RTL_SHELL_DIR / "slm_chain_controller.sv"),
                str(RTL_SHELL_DIR / "slm_block_controller.sv"),
                str(RTL_SHELL_DIR / "slm_linear_cfg_pkg.sv"),
                str(RTL_SHELL_DIR / "slm_block_cfg_pkg.sv"),
                str(RTL_SHELL_DIR / "slm_linear_controller.sv"),
                str(RTL_SHELL_DIR / "slm_linear_stage.sv"),
                str(RTL_SHELL_DIR / "slm_fabric_scheduler.sv"),
                str(RTL_SHELL_DIR / "slm_ssm_stage.sv"),
                str(RTL_SHELL_DIR / "slim_mamba_block.sv"),
                str(RTL_SHELL_DIR / "slim_mamba_block_from_stage_dir.sv"),
                str(RTL_SHELL_DIR / "slim_mamba_chain4.sv"),
                *slm_sources,
                *ip_sources,
            ],
            "copy_case_mem": True,
        }

    if stage == "slm_chain4_smoke":
        return {
            "tb_top": "tb_slm_chain4_top_smoke",
            "tb_file": str(TB_DIR / "tb_slm_chain4_top_smoke.sv"),
            "sources": [*slm_sources],
            "copy_case_mem": False,
        }

    if stage == "slim_chain4_top_debug":
        return {
            "tb_top": "tb_slim_mamba_chain4_top",
            "tb_file": str(TB_DIR / "tb_slim_mamba_chain4_top.sv"),
            "sources": [
                *legacy_sources,
                str(RTL_SHELL_DIR / "slm_chain_cfg_pkg.sv"),
                str(RTL_SHELL_DIR / "slm_block_launch_ctrl.sv"),
                str(RTL_SHELL_DIR / "slm_chain_controller.sv"),
                str(RTL_SHELL_DIR / "slm_linear_cfg_pkg.sv"),
                str(RTL_SHELL_DIR / "slm_block_cfg_pkg.sv"),
                str(RTL_SHELL_DIR / "slim_mamba_chain4_top.sv"),
                str(RTL_SHELL_DIR / "slim_mamba_chain4_core_adapter.sv"),
                str(RTL_SHELL_DIR / "slm_block_controller.sv"),
                str(RTL_SHELL_DIR / "slm_linear_controller.sv"),
                str(RTL_SHELL_DIR / "slm_linear_stage.sv"),
                str(RTL_SHELL_DIR / "slm_fabric_scheduler.sv"),
                str(RTL_SHELL_DIR / "slm_ssm_stage.sv"),
                str(RTL_SHELL_DIR / "slim_mamba_block.sv"),
                str(RTL_SHELL_DIR / "slim_mamba_block_from_stage_dir.sv"),
                str(RTL_SHELL_DIR / "slim_mamba_chain4.sv"),
                *slm_sources,
                *ip_sources,
            ],
            "copy_case_mem": True,
        }

    if stage == "slm_state_policy_smoke":
        return {
            "tb_top": "tb_slm_state_policy_smoke",
            "tb_file": str(TB_DIR / "tb_slm_state_policy_smoke.sv"),
            "sources": [*slm_sources],
            "copy_case_mem": False,
        }

    if stage == "legacy_block_hw_debug":
        return {
            "tb_top": "tb_reuse_mamba_block_top_hw_debug",
            "tb_file": str(TB_DIR / "tb_reuse_mamba_block_top_hw_debug.sv"),
            "sources": [*legacy_sources, *ip_sources],
            "copy_case_mem": True,
        }

    if stage == "legacy_board_shell_stream":
        return {
            "tb_top": "tb_reuse_mamba_board_shell_stream",
            "tb_file": str(TB_DIR / "tb_reuse_mamba_board_shell_stream.sv"),
            "sources": [*legacy_sources, *ip_sources],
            "copy_case_mem": True,
        }

    if stage == "legacy_chain4_debug":
        return {
            "tb_top": "tb_reuse_mamba_4block_chain_top",
            "tb_file": str(TB_DIR / "tb_reuse_mamba_4block_chain_top.sv"),
            "sources": [*legacy_sources, *ip_sources],
            "copy_case_mem": True,
        }

    raise ValueError(f"unsupported stage: {stage}")


def _run(cmd: list[str], cwd: Path, *, allow_snapshot_lock_error: bool = False, log_file: Path | None = None, fail_on_log_patterns: list[str] | None = None) -> None:
    print("[xsim]", " ".join(cmd))
    cp = subprocess.run(cmd, cwd=str(cwd))
    if cp.returncode == 0:
        if log_file and log_file.exists() and fail_on_log_patterns:
            txt = log_file.read_text(encoding="utf-8", errors="ignore")
            for p in fail_on_log_patterns:
                if p in txt:
                    raise subprocess.CalledProcessError(1, cmd)
        return
    if allow_snapshot_lock_error and log_file and log_file.exists():
        txt = log_file.read_text(encoding="utf-8", errors="ignore")
        if "Built simulation snapshot" in txt and "Could not remove the obj directory" in txt:
            return
    raise subprocess.CalledProcessError(cp.returncode, cmd)


def _on_rm_error(func, path, exc_info):
    try:
        os.chmod(path, stat.S_IWRITE)
        func(path)
    except Exception:
        pass


def _dedup_paths(paths: list[str]) -> list[str]:
    seen: set[str] = set()
    out: list[str] = []
    for p in paths:
        if p not in seen:
            seen.add(p)
            out.append(p)
    return out


def _copy_case_assets(case_dir: Path, run_dir: Path) -> None:
    lut = IP_DIR / "sigmoid_lut_q016_2048.hex"
    if lut.exists():
        shutil.copyfile(lut, run_dir / lut.name)
    for mif in IP_DIR.rglob("*.mif"):
        shutil.copyfile(mif, run_dir / mif.name)
    if case_dir.exists():
        # Keep relative case path semantics in legacy TBs.
        pass


def main() -> None:
    p = argparse.ArgumentParser(description="Run HW xsim stages (new Slim-Mamba RTL + migrated legacy TB).")
    p.add_argument(
        "--stage",
        required=True,
        choices=[
            "slm_block_smoke",
            "slim_block_smoke",
            "slim_block_hw_debug",
            "slim_chain4_debug",
            "slm_chain4_smoke",
            "slim_chain4_top_debug",
            "slm_state_policy_smoke",
            "legacy_block_hw_debug",
            "legacy_board_shell_stream",
            "legacy_chain4_debug",
        ],
    )
    p.add_argument("--case_dir", default=str(HW_DIR / "cases" / "04"))
    p.add_argument("--run_name", default="")
    p.add_argument("--clean", action="store_true")
    p.add_argument("--gui", action="store_true")
    args = p.parse_args()

    vivado_bin = _vivado_bin()
    vivado_root = vivado_bin.parent
    glbl_v = vivado_root / "data" / "verilog" / "src" / "glbl.v"
    cfg = _stage_cfg(args.stage)
    cfg["sources"] = _dedup_paths(cfg["sources"])
    run_name = args.run_name or args.stage
    run_dir = RUN_ROOT / run_name
    case_dir = Path(args.case_dir).resolve()

    if args.clean and run_dir.exists():
        try:
            shutil.rmtree(run_dir, onexc=_on_rm_error)
        except Exception:
            run_dir = RUN_ROOT / f"{run_name}_rerun"
    run_dir.mkdir(parents=True, exist_ok=True)

    if cfg["copy_case_mem"]:
        _copy_case_assets(case_dir, run_dir)
        (run_dir / "tb_hw_debug_case_path.svh").write_text(
            f'`define HW_DEBUG_CASE_DIR "{case_dir.as_posix()}"\n',
            encoding="utf-8",
        )

    prj = run_dir / "files.prj"
    with open(prj, "w", encoding="utf-8") as f:
        for src in cfg["sources"]:
            f.write(f'sv work "{src}"\n')
        f.write(f'sv work "{cfg["tb_file"]}"\n')
        if glbl_v.exists():
            f.write(f'verilog work "{glbl_v}"\n')

    tcl = run_dir / "run.tcl"
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
        ]
    else:
        # Default batch regressions should not record recursive waveforms.
        # When a test stalls, WDB growth can consume the entire workspace disk.
        tcl.write_text("run all\nexit\n", encoding="utf-8")
        xsim_args = [
            cfg["tb_top"],
            "-tclbatch",
            "run.tcl",
            "-log",
            "xsim.log",
        ]

    xvlog_cmd = [str(vivado_bin / "xvlog.bat"), "--sv", "--relax", "-i", ".", "-prj", "files.prj", "-log", "xvlog.log"]
    _run(xvlog_cmd, run_dir)
    xelab_log = run_dir / "xelab.log"
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
        allow_snapshot_lock_error=True,
        log_file=xelab_log,
    )
    _run(
        [str(vivado_bin / "xsim.bat"), *xsim_args],
        run_dir,
        log_file=run_dir / "xsim.log",
        fail_on_log_patterns=["Fatal:", "ERROR:"],
    )

    print(f"[xsim] done: {run_dir}")


if __name__ == "__main__":
    main()

