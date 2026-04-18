open_project HW_reconstruct/project_mamba_all1/project_mamba_all1.xpr
set ipf [get_files *norm_gamma_rom_ip.xci]
puts "IP_FILE=$ipf"
if {[llength $ipf] > 0} {
  generate_target all $ipf
  export_ip_user_files -of_objects $ipf -no_script -sync -force
}
close_project
