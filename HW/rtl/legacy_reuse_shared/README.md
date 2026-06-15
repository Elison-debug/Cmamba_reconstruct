# Legacy Shared RTL

This directory contains the legacy shared RTL bundle that remains available
for regression and comparison. The modules here keep the original shell-facing
interfaces used by the older regression flow.

Current structure:

- `reuse_mamba_block_top.sv`
  - Block-level top for the legacy shell flow.
  - Organizes `in_proj -> ssm -> out_proj` around one shared MAC fabric.
- `reuse_ssm_core.sv`
  - SSM-internal post-processing path after dt-projection GEMV.
- `reuse_top_mac_plus_bias_fifo_sigmoid_ew_gate.sv`
  - Shell-facing top used by the legacy board integration flow.
- `reuse_slim_mac_mem_controller_combined_dp.sv`
  - Shared controller wrapper for the legacy SSM-facing interface.
- `reuse_ssm_dt_scheduler.sv`
  - Scheduler for the SSM `dt_proj` path.
- `reuse_mac_fabric_manager.sv`
  - Arbitration point for `dt_proj`, `in_proj`, and `out_proj`.
- `reuse_in_proj_scheduler.sv`
  - In-projection scheduler that reads `W_in` and `h_t` and writes `u_t`
    / `z_t` tiles.
- `reuse_out_proj_scheduler.sv`
  - Out-projection scheduler hook.
- `reuse_inproj_weight_sram.sv`
  - Read-only SRAM wrapper for `W_in`.
- `reuse_ht_sram.sv`
  - 4-read-port SRAM for `h_t` storage.
- `reuse_vec_out_sram.sv`
  - Output SRAM for `u_t` / `z_t` tile storage.
- `reuse_shared_mac_fabric.sv`
  - Wrapper for the 4-array MAC datapath.
- `reuse_pipeline_4array_with_reduction.sv`
- `reuse_pipeline_4array_top.sv`
- `reuse_array4x4.sv`
- `reuse_reduction_accumulator.sv`
  - Compute-path modules used by the legacy flow.
- Supporting RTL in this folder:
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
  - Placeholder declarations for generated/vendor IPs whose RTL sources are
    not present in this repository.

Recommended hierarchy:

- `reuse_mamba_block_top`
  - `reuse_in_proj_scheduler`
  - `reuse_ssm_dt_scheduler`
  - `reuse_out_proj_scheduler`
  - `reuse_mac_fabric_manager`
    - `reuse_shared_mac_fabric`
  - `reuse_ssm_core`

What the bundle provides:

- a complete legacy baseline for regression
- the original shell-facing interfaces used by the previous project flow
- the same 4x4x4 MAC datapath building blocks used by the older runtime

What remains out of scope:

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
