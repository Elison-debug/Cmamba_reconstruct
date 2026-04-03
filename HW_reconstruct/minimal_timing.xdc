# --------------------------------------------------------------------
# minimal_timing.xdc
# Minimal internal-timing constraints for bring-up synthesis/implementation.
# Current project top is `reuse_mamba_block_wrapper`.
# --------------------------------------------------------------------

# Core analysis clock.
# Use a realistic bring-up target first; tighten later after timing cleanup.
create_clock -name sys_clk -period 5.000 [get_ports sys_clk]

# Reset is asynchronous at the chip boundary but is synchronized inside the
# wrapper. Exclude the external reset port from timing closure.
set_false_path -from [get_ports ext_reset_n]

# The synchronized reset output is only for observation/debug.
set_false_path -to [get_ports -quiet core_rst_n_o]

# This project is still a kernel-level top, not a board-level shell.
# Suppress unrelated board-interface timing warnings for now by giving all
# functional top-level I/O simple delays relative to sys_clk. Replace these
# with real board constraints once AXI/DDR/board wrapper ports are defined.
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
