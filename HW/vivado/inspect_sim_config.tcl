open_project E:/course/smamba/final_hw/project_mamba_final_hw/project_mamba_final_hw.xpr
puts "SIM1_TOP=[get_property top [get_filesets sim_1]]"
puts "SIM1_MODE=[get_property top_lib [get_filesets sim_1]]"
puts "SIM1_SRC=[get_files -of [get_filesets sim_1]]"
puts "SYNTH_TOP=[get_property top [get_filesets sources_1]]"
puts "SYNTH_RUN_TOP=[get_property top [get_runs synth_1]]"
close_project
exit