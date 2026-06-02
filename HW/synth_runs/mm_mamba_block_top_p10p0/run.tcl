read_verilog -sv "E:/course/smamba/HW/rtl/common/slm_array4x4.sv"
read_verilog -sv "E:/course/smamba/HW/rtl/common/slm_pe_unit_pipe.sv"
read_verilog -sv "E:/course/smamba/HW/rtl/common/slm_vec_fifo_axis.sv"
read_verilog -sv "E:/course/smamba/HW/rtl/linear/slm_gemv_dispatcher.sv"
read_verilog -sv "E:/course/smamba/HW/rtl/linear/slm_gemv_job_pkg.sv"
read_verilog -sv "E:/course/smamba/HW/rtl/linear/slm_gemv_scheduler.sv"
read_verilog -sv "E:/course/smamba/HW/rtl/linear/slm_shared_gemv_engine.sv"
read_verilog -sv "E:/course/smamba/HW/rtl/state/slm_gate_out_stage.sv"
read_verilog -sv "E:/course/smamba/HW/rtl/state/slm_gated_state_update_stage.sv"
read_verilog -sv "E:/course/smamba/HW/rtl/state/slm_runtime_state_scale_lane.sv"
read_verilog -sv "E:/course/smamba/HW/rtl/state/slm_runtime_state_scale_stage.sv"
read_verilog -sv "E:/course/smamba/HW/rtl/state/slm_state_datapath.sv"
read_verilog -sv "E:/course/smamba/HW/rtl/block/slm_block_controller.sv"
read_verilog -sv "E:/course/smamba/HW/rtl/block/slm_mamba_block_top.sv"
synth_design -top slm_mamba_block_top -part xczu9eg-ffvb1156-2-e -flatten_hierarchy rebuilt
if {[llength [get_ports clk]] > 0} { create_clock -period 10.0 -name clk [get_ports clk] }
if {[llength [get_ports sys_clk]] > 0} { create_clock -period 10.0 -name sys_clk [get_ports sys_clk] }
report_timing_summary -delay_type max -max_paths 10 -file "E:/course/smamba/HW/synth_runs/slm_mamba_block_top_p10p0/timing_summary.rpt"
report_utilization -file "E:/course/smamba/HW/synth_runs/slm_mamba_block_top_p10p0/utilization.rpt"
write_checkpoint -force "E:/course/smamba/HW/synth_runs/slm_mamba_block_top_p10p0/post_synth.dcp"
quit

