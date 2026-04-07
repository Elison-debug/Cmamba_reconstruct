set_property SRC_FILE_INFO {cfile:E:/course/master/mamba/Cmamba_reconstruct/HW_reconstruct/minimal_timing.xdc rfile:../HW_reconstruct/minimal_timing.xdc id:1} [current_design]
set_property src_info {type:XDC file:1 line:16 export:INPUT save:INPUT read:READ} [current_design]
set_false_path -to [get_ports -quiet core_rst_n_o]
set_property src_info {type:XDC file:1 line:22 export:INPUT save:INPUT read:READ} [current_design]
set_input_delay 0.000 -clock [get_clocks sys_clk] [get_ports {
block_auto_mode
block_start
s_axis_tvalid
g_axis_tvalid
g_axis_tdata[*]
y_axis_tready
inproj_enable
inproj_start
h_wr_en
h_wr_addr[*]
h_wr_data[*]
u_rd_en
u_rd_addr[*]
z_rd_en
z_rd_addr[*]
outproj_enable
}]
set_property src_info {type:XDC file:1 line:41 export:INPUT save:INPUT read:READ} [current_design]
set_output_delay 0.000 -clock [get_clocks sys_clk] [get_ports {
core_rst_n_o
block_busy
block_done
s_axis_tready
g_axis_tready
y_axis_tvalid
y_axis_tdata[*]
inproj_busy
inproj_done
u_rd_data[*]
z_rd_data[*]
outproj_busy
}]
