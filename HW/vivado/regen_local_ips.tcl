set xpr "E:/course/smamba/final_hw/project_mamba_final_hw/project_mamba_final_hw.xpr"
open_project $xpr
set ips [list \
  "E:/course/smamba/final_hw/ip/bias2sigmoid_fifo/bias2sigmoid_fifo.xci" \
  "E:/course/smamba/final_hw/ip/bias_ROM/bias_ROM.xci" \
  "E:/course/smamba/final_hw/ip/inproj_ht_sram_ip/inproj_ht_sram_ip.xci" \
  "E:/course/smamba/final_hw/ip/inproj_vec_out_sram_ip/inproj_vec_out_sram_ip.xci" \
  "E:/course/smamba/final_hw/ip/s_buffer/s_buffer.xci" \
]
foreach ip $ips {
  if {[llength [get_files -quiet $ip]] == 0} { add_files -norecurse $ip }
}
update_compile_order -fileset sources_1
generate_target all [get_files $ips]
export_ip_user_files -of_objects [get_files $ips] -no_script -sync -force -quiet
close_project
exit