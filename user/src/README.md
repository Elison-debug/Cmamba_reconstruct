# Reuse-Oriented SSM RTL

This directory contains a behavior-preserving copy of the current Slim-Mamba SSM RTL, reorganized so the 4x4x4 MAC pipeline is exposed as a standalone shared fabric.

Current structure:

- `reuse_mamba_block_top.sv`
  - New block-level top.
  - Explicitly organizes `in_proj -> ssm -> out_proj` around one shared MAC fabric.
- `reuse_ssm_core.sv`
  - The SSM-internal post-processing path after dt-projection GEMV.
  - Keeps the original `bias -> sigmoid -> join -> EW update -> gate` logic intact.
- `reuse_top_mac_plus_bias_fifo_sigmoid_ew_gate.sv`
  - Legacy compatibility top from the earlier refactor stage.
  - Kept to avoid breaking existing checks, but no longer the recommended block-level top.
- `reuse_slim_mac_mem_controller_combined_dp.sv`
  - Compatibility wrapper that preserves the old SSM-facing controller ports.
  - Internally instantiates the new reusable hierarchy.
- `reuse_ssm_dt_scheduler.sv`
  - Current implemented scheduler for the SSM `dt_proj` path.
  - Owns the original SSM visit pattern to WBUF/XT and emits tile streams into the shared fabric.
- `reuse_mac_fabric_manager.sv`
  - Central place for future arbitration across `dt_proj`, `in_proj`, and `out_proj`.
  - Now routes the active scheduler into the shared fabric using `busy`-based ownership.
- `reuse_in_proj_scheduler.sv`
  - First concrete in-proj scheduler using the shared 4x4x4 MAC fabric.
  - Reads `W_in` from a dedicated weight SRAM, reads `h_t` from a dedicated activation SRAM, and writes results into `u_t` / `z_t` SRAMs.
- `reuse_out_proj_scheduler_stub.sv`
  - Empty placeholder for the future out-proj scheduler.
- `reuse_inproj_weight_sram.sv`
  - Dedicated read-only SRAM wrapper for `W_in`.
- `reuse_ht_sram.sv`
  - 4-read-port SRAM for `h_t` storage.
- `reuse_vec_out_sram.sv`
  - Output SRAM used for `u_t` / `z_t` tile storage.
- `reuse_shared_mac_fabric.sv`
  - Thin wrapper that marks the 4-array MAC datapath as a reusable compute fabric.
- `reuse_pipeline_4array_with_reduction.sv`
- `reuse_pipeline_4array_top.sv`
- `reuse_array4x4.sv`
- `reuse_reduction_accumulator.sv`
  - Copied compute-path modules renamed with a `reuse_` prefix to avoid collisions with the original RTL.
- Supporting RTL copied into this folder:
  - `pulse_to_stream_adapter.sv`
  - `bias_add_regslice_ip.sv`
  - `vec_fifo_axis_ip.sv`
  - `sigmoid4_vec.sv`
  - `axis_vec_join2.sv`
  - `ew_update_vec4.sv`
  - `ewm_gate_sbuf_vec4.sv`
  - `ewm_vec4.sv`
  - `ewa_vec4.sv`
  - `pe_unit_pipe.sv`
  - `slim_multi_bank_wbuf_dp.sv`
  - `xt_input_buf.sv`
- `reuse_ip_blackboxes.sv`
  - Placeholder declarations for generated/vendor IPs whose RTL sources are not present in this repository.

Recommended hierarchy:

- `reuse_mamba_block_top`
  - `reuse_in_proj_scheduler`
  - `reuse_ssm_dt_scheduler`
  - `reuse_out_proj_scheduler_stub`
  - `reuse_mac_fabric_manager`
    - `reuse_shared_mac_fabric`
  - `reuse_ssm_core`

What changed:

- No arithmetic or memory-access behavior was intentionally changed for the currently active SSM `dt_proj` path.
- No AXI/FIFO protocol behavior was intentionally changed at the SSM top wrapper.
- The original controller has been split conceptually into:
  - `reuse_ssm_dt_scheduler`: SSM-specific tile generation
  - `reuse_mac_fabric_manager`: shared fabric arbitration point
  - `reuse_shared_mac_fabric`: unique 4x4x4 MAC fabric
- This is now the reusable hierarchy that both the current SSM `dt_proj` path and the new `in_proj` path plug into.
- A new explicit block-level top (`reuse_mamba_block_top`) has been added so the architectural order is visible as `in_proj -> ssm -> out_proj`.

What has not been done yet:

- The in-proj scheduler is implemented in a first functional form, but it has not been validated against a dedicated projection-only TB yet.
- The out-proj scheduler is still a stub.
- The manager still assumes non-overlapping task execution; it is not a full concurrent multi-client arbiter.
- This folder is self-contained for local handwritten RTL, but still depends on the following generated/vendor IP names:
  - `bias_ROM`
  - `bias2sigmoid_fifo`
  - `s_buffer`
  - `slim_WBUF_bank_dp`
  - `u_xt_rom`
  Their interfaces are captured in `reuse_ip_blackboxes.sv`.
