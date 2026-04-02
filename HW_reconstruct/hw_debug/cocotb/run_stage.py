from __future__ import annotations

import argparse
import os
from pathlib import Path

from cocotb_tools.runner import get_runner


ROOT = Path(__file__).resolve().parents[3]
RTL = ROOT / "HW_reconstruct" / "rtl_reuse_shared"
COCOTB_DIR = ROOT / "HW_reconstruct" / "hw_debug" / "cocotb"
STUBS = COCOTB_DIR / "stubs"


def _stage_cfg(stage: str) -> dict:
    if stage == "sigmoid4_vec":
        return {
            "hdl_toplevel": "sigmoid4_vec",
            "test_module": "test_sigmoid4_vec",
            "sources": [RTL / "sigmoid4_vec.sv"],
            "uses_lut": True,
        }
    if stage == "ew_update_vec4":
        return {
            "hdl_toplevel": "ew_update_vec4",
            "test_module": "test_ew_update_vec4",
            "sources": [
                RTL / "ewm_vec4.sv",
                RTL / "ewa_vec4.sv",
                RTL / "ew_update_vec4.sv",
                STUBS / "s_buffer.sv",
            ],
            "uses_lut": False,
        }
    if stage == "reuse_mamba_block_top":
        return {
            "hdl_toplevel": "reuse_mamba_block_top",
            "test_module": "test_reuse_mamba_block_top",
            "sources": [
                RTL / "axis_vec_join2.sv",
                RTL / "bias_add_regslice_ip.sv",
                RTL / "ewa_vec4.sv",
                RTL / "ewm_gate_sbuf_vec4.sv",
                RTL / "ewm_vec4.sv",
                RTL / "ew_update_vec4.sv",
                RTL / "pe_unit_pipe.sv",
                RTL / "pulse_to_stream_adapter.sv",
                RTL / "reuse_array4x4.sv",
                RTL / "reuse_ht_multi_copy_ip.sv",
                RTL / "reuse_ht_sram.sv",
                RTL / "reuse_ht_sram_sp.sv",
                RTL / "reuse_inproj_weight_sram.sv",
                RTL / "reuse_in_proj_scheduler.sv",
                RTL / "reuse_ip_blackboxes.sv",
                RTL / "reuse_mac_fabric_manager.sv",
                RTL / "reuse_mamba_block_top.sv",
                RTL / "reuse_outproj_multi_bank_wbuf_dp.sv",
                RTL / "reuse_outproj_weight_sram.sv",
                RTL / "reuse_out_proj_scheduler_stub.sv",
                RTL / "reuse_pipeline_4array_top.sv",
                RTL / "reuse_pipeline_4array_with_reduction.sv",
                RTL / "reuse_pt_capture.sv",
                RTL / "reuse_reduction_accumulator.sv",
                RTL / "reuse_shared_mac_fabric.sv",
                RTL / "reuse_silu_vec4.sv",
                RTL / "reuse_slim_mac_mem_controller_combined_dp.sv",
                RTL / "reuse_ssm_core.sv",
                RTL / "reuse_ssm_dt_scheduler.sv",
                RTL / "reuse_top_mac_plus_bias_fifo_sigmoid_ew_gate.sv",
                RTL / "reuse_vec_out_sram.sv",
                RTL / "reuse_vec_out_sram_ip.sv",
                RTL / "reuse_z_stream_reader.sv",
                RTL / "sigmoid4_vec.sv",
                RTL / "slim_multi_bank_wbuf_dp.sv",
                RTL / "vec_fifo_axis_ip.sv",
                RTL / "xt_input_buf.sv",
                STUBS / "bias_ROM.sv",
                STUBS / "s_buffer.sv",
                STUBS / "slim_WBUF_bank_dp.sv",
                STUBS / "u_xt_rom.sv",
            ],
            "uses_lut": True,
        }
    raise ValueError(f"unsupported stage: {stage}")


def main() -> None:
    p = argparse.ArgumentParser(description="Run a cocotb stage test without GNU make.")
    p.add_argument("--case_dir", required=True)
    p.add_argument("--stage", required=True, choices=["sigmoid4_vec", "ew_update_vec4", "reuse_mamba_block_top"])
    p.add_argument("--sim", default="icarus")
    p.add_argument("--clean", action="store_true")
    p.add_argument("--waves", action="store_true")
    p.add_argument("--verbose", action="store_true")
    p.add_argument("--max_vectors", type=int, default=0)
    args = p.parse_args()

    cfg = _stage_cfg(args.stage)
    case_dir = str(Path(args.case_dir).resolve())
    stage_dir = Path(case_dir) / "stages" / args.stage
    build_dir = ROOT / "HW_reconstruct" / "hw_debug" / "sim_build" / args.stage
    test_dir = ROOT / "HW_reconstruct" / "hw_debug" / "sim_run" / args.stage
    build_dir.mkdir(parents=True, exist_ok=True)
    test_dir.mkdir(parents=True, exist_ok=True)
    parameters = {}
    if cfg.get("uses_lut"):
        lut_path = (stage_dir / "lut_q016_2048.hex").resolve()
        if not lut_path.exists():
            lut_path = (Path(case_dir) / "stages" / "sigmoid4_vec" / "lut_q016_2048.hex").resolve()
        parameters["LUT_FILE"] = str(lut_path).replace("\\", "/")

    runner = get_runner(args.sim)
    runner.build(
        verilog_sources=[str(p) for p in cfg["sources"]],
        hdl_toplevel=cfg["hdl_toplevel"],
        parameters=parameters,
        build_dir=str(build_dir),
        clean=args.clean,
        always=True,
        verbose=args.verbose,
    )
    results_xml = test_dir / "results.xml"
    runner.test(
        test_module=cfg["test_module"],
        hdl_toplevel=cfg["hdl_toplevel"],
        test_dir=str(test_dir),
        build_dir=str(build_dir),
        results_xml=str(results_xml),
        extra_env={
            "CASE_DIR": case_dir,
            "STAGE": args.stage,
            "PYTHONPATH": str(COCOTB_DIR),
            "MAX_VECTORS": str(int(args.max_vectors)),
        },
        parameters=parameters,
        waves=args.waves,
        verbose=args.verbose,
    )
    print(f"[cocotb] done: stage={args.stage} case={case_dir}")
    print(f"[cocotb] results: {results_xml}")


if __name__ == "__main__":
    main()
