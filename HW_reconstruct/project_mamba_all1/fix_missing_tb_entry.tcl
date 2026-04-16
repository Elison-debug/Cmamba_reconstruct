open_project {E:/course/smamba/HW_reconstruct/project_mamba_all1/project_mamba_all1.xpr}
set f [get_files -all {E:/course/smamba/HW_reconstruct/tb/tb_reuse_mamba_board_shell_com_ps.sv}]
if {[llength $f] > 0} {
  remove_files $f
  puts "REMOVED missing file entry"
} else {
  puts "No missing file entry found"
}
update_compile_order -fileset sim_3
save_project_as {E:/course/smamba/HW_reconstruct/project_mamba_all1/project_mamba_all1.xpr}
close_project
quit
