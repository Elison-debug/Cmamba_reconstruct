// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Wed Apr  8 19:38:32 2026
// Host        : 13600kf running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               e:/course/master/mamba/Cmamba_reconstruct/HW_reconstruct/project_mamba_all1/project_mamba_all1.gen/sources_1/bd/design_1/ip/design_1_reuse_mamba_board_sh_0_1/design_1_reuse_mamba_board_sh_0_1_stub.v
// Design      : design_1_reuse_mamba_board_sh_0_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "reuse_mamba_board_shell,Vivado 2024.1" *)
module design_1_reuse_mamba_board_sh_0_1(sys_clk, ext_reset_n, irq, s_axi_awaddr, 
  s_axi_awvalid, s_axi_awready, s_axi_wdata, s_axi_wstrb, s_axi_wvalid, s_axi_wready, 
  s_axi_bresp, s_axi_bvalid, s_axi_bready, s_axi_araddr, s_axi_arvalid, s_axi_arready, 
  s_axi_rdata, s_axi_rresp, s_axi_rvalid, s_axi_rready, s_axis_h_tvalid, s_axis_h_tready, 
  s_axis_h_tdata, s_axis_h_tlast, s_axis_g_tvalid, s_axis_g_tready, s_axis_g_tdata, 
  s_axis_g_tlast, m_axis_y_tvalid, m_axis_y_tready, m_axis_y_tdata, m_axis_y_tlast)
/* synthesis syn_black_box black_box_pad_pin="ext_reset_n,irq,s_axi_awaddr[11:0],s_axi_awvalid,s_axi_awready,s_axi_wdata[31:0],s_axi_wstrb[3:0],s_axi_wvalid,s_axi_wready,s_axi_bresp[1:0],s_axi_bvalid,s_axi_bready,s_axi_araddr[11:0],s_axi_arvalid,s_axi_arready,s_axi_rdata[31:0],s_axi_rresp[1:0],s_axi_rvalid,s_axi_rready,s_axis_h_tvalid,s_axis_h_tready,s_axis_h_tdata[63:0],s_axis_h_tlast,s_axis_g_tvalid,s_axis_g_tready,s_axis_g_tdata[63:0],s_axis_g_tlast,m_axis_y_tvalid,m_axis_y_tready,m_axis_y_tdata[63:0],m_axis_y_tlast" */
/* synthesis syn_force_seq_prim="sys_clk" */;
  input sys_clk /* synthesis syn_isclock = 1 */;
  input ext_reset_n;
  output irq;
  input [11:0]s_axi_awaddr;
  input s_axi_awvalid;
  output s_axi_awready;
  input [31:0]s_axi_wdata;
  input [3:0]s_axi_wstrb;
  input s_axi_wvalid;
  output s_axi_wready;
  output [1:0]s_axi_bresp;
  output s_axi_bvalid;
  input s_axi_bready;
  input [11:0]s_axi_araddr;
  input s_axi_arvalid;
  output s_axi_arready;
  output [31:0]s_axi_rdata;
  output [1:0]s_axi_rresp;
  output s_axi_rvalid;
  input s_axi_rready;
  input s_axis_h_tvalid;
  output s_axis_h_tready;
  input [63:0]s_axis_h_tdata;
  input s_axis_h_tlast;
  input s_axis_g_tvalid;
  output s_axis_g_tready;
  input [63:0]s_axis_g_tdata;
  input s_axis_g_tlast;
  output m_axis_y_tvalid;
  input m_axis_y_tready;
  output [63:0]m_axis_y_tdata;
  output m_axis_y_tlast;
endmodule
