# --------------------------------------------------------------------
# minimal_timing.xdc
# Top-level timing constraints for reuse_mamba_board_shell
# --------------------------------------------------------------------

# Main board clock
create_clock -name sys_clk -period 5.000 [get_ports sys_clk]

# External reset is asynchronous at chip boundary
set_false_path -from [get_ports ext_reset_n]

# Top-level input delays relative to sys_clk
set_input_delay 0.000 -clock [get_clocks sys_clk] [get_ports {
    s_axi_awaddr[*]
    s_axi_awvalid
    s_axi_wdata[*]
    s_axi_wstrb[*]
    s_axi_wvalid
    s_axi_bready
    s_axi_araddr[*]
    s_axi_arvalid
    s_axi_rready

    s_axis_h_tvalid
    s_axis_h_tdata[*]
    s_axis_h_tlast

    s_axis_g_tvalid
    s_axis_g_tdata[*]
    s_axis_g_tlast

    m_axis_y_tready
}]

# Top-level output delays relative to sys_clk
set_output_delay 0.000 -clock [get_clocks sys_clk] [get_ports {
    irq

    s_axi_awready
    s_axi_wready
    s_axi_bresp[*]
    s_axi_bvalid
    s_axi_arready
    s_axi_rdata[*]
    s_axi_rresp[*]
    s_axi_rvalid

    s_axis_h_tready
    s_axis_g_tready

    m_axis_y_tvalid
    m_axis_y_tdata[*]
    m_axis_y_tlast
}]
