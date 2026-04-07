open_project ./HW_reconstruct/project_mamba_all1/project_mamba_all1.xpr

set src_tb [file normalize ./HW_reconstruct/tb/tb_reuse_mamba_block_top_hw_debug.sv]
if {[llength [get_files -quiet $src_tb]] == 0} {
  add_files -fileset sim_1 $src_tb
}

set_property top tb_reuse_mamba_block_top_hw_debug [get_filesets sim_1]
update_compile_order -fileset sim_1

puts "Project opened."
puts "Top for sim_1 set to tb_reuse_mamba_block_top_hw_debug."
puts "Use Flow Navigator -> Simulation -> Run Simulation -> Run Behavioral Simulation"
puts "For lint-like checks in GUI:"
puts "  1. Open Elaborated Design"
puts "  2. Tools/Reports: run lint or report methodology/DRC depending on your Vivado install"
puts "  3. For timing/resource debug after synthesis, run synthesis then open synthesized design"

