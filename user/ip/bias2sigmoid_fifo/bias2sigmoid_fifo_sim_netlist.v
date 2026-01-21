// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Thu Dec 25 09:52:28 2025
// Host        : DESKTOP-JL9PPGK running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/Mamba/project_reconstruct/project_reconstruct.gen/sources_1/ip/bias2sigmoid_fifo/bias2sigmoid_fifo_sim_netlist.v
// Design      : bias2sigmoid_fifo
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bias2sigmoid_fifo,fifo_generator_v13_2_10,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "fifo_generator_v13_2_10,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module bias2sigmoid_fifo
   (s_aclk,
    s_aresetn,
    s_axis_tvalid,
    s_axis_tready,
    s_axis_tdata,
    m_axis_tvalid,
    m_axis_tready,
    m_axis_tdata);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 slave_aclk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME slave_aclk, ASSOCIATED_BUSIF S_AXIS:S_AXI, ASSOCIATED_RESET s_aresetn, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *) input s_aclk;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 slave_aresetn RST" *) (* x_interface_parameter = "XIL_INTERFACENAME slave_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input s_aresetn;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS TVALID" *) (* x_interface_parameter = "XIL_INTERFACENAME S_AXIS, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) input s_axis_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS TREADY" *) output s_axis_tready;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS TDATA" *) input [63:0]s_axis_tdata;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS TVALID" *) (* x_interface_parameter = "XIL_INTERFACENAME M_AXIS, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) output m_axis_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS TREADY" *) input m_axis_tready;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS TDATA" *) output [63:0]m_axis_tdata;

  wire [63:0]m_axis_tdata;
  wire m_axis_tready;
  wire m_axis_tvalid;
  wire s_aclk;
  wire s_aresetn;
  wire [63:0]s_axis_tdata;
  wire s_axis_tready;
  wire s_axis_tvalid;
  wire NLW_U0_almost_empty_UNCONNECTED;
  wire NLW_U0_almost_full_UNCONNECTED;
  wire NLW_U0_axi_ar_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_ar_overflow_UNCONNECTED;
  wire NLW_U0_axi_ar_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_ar_prog_full_UNCONNECTED;
  wire NLW_U0_axi_ar_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_ar_underflow_UNCONNECTED;
  wire NLW_U0_axi_aw_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_aw_overflow_UNCONNECTED;
  wire NLW_U0_axi_aw_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_aw_prog_full_UNCONNECTED;
  wire NLW_U0_axi_aw_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_aw_underflow_UNCONNECTED;
  wire NLW_U0_axi_b_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_b_overflow_UNCONNECTED;
  wire NLW_U0_axi_b_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_b_prog_full_UNCONNECTED;
  wire NLW_U0_axi_b_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_b_underflow_UNCONNECTED;
  wire NLW_U0_axi_r_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_r_overflow_UNCONNECTED;
  wire NLW_U0_axi_r_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_r_prog_full_UNCONNECTED;
  wire NLW_U0_axi_r_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_r_underflow_UNCONNECTED;
  wire NLW_U0_axi_w_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_w_overflow_UNCONNECTED;
  wire NLW_U0_axi_w_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_w_prog_full_UNCONNECTED;
  wire NLW_U0_axi_w_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_w_underflow_UNCONNECTED;
  wire NLW_U0_axis_dbiterr_UNCONNECTED;
  wire NLW_U0_axis_overflow_UNCONNECTED;
  wire NLW_U0_axis_prog_empty_UNCONNECTED;
  wire NLW_U0_axis_prog_full_UNCONNECTED;
  wire NLW_U0_axis_sbiterr_UNCONNECTED;
  wire NLW_U0_axis_underflow_UNCONNECTED;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_empty_UNCONNECTED;
  wire NLW_U0_full_UNCONNECTED;
  wire NLW_U0_m_axi_arvalid_UNCONNECTED;
  wire NLW_U0_m_axi_awvalid_UNCONNECTED;
  wire NLW_U0_m_axi_bready_UNCONNECTED;
  wire NLW_U0_m_axi_rready_UNCONNECTED;
  wire NLW_U0_m_axi_wlast_UNCONNECTED;
  wire NLW_U0_m_axi_wvalid_UNCONNECTED;
  wire NLW_U0_m_axis_tlast_UNCONNECTED;
  wire NLW_U0_overflow_UNCONNECTED;
  wire NLW_U0_prog_empty_UNCONNECTED;
  wire NLW_U0_prog_full_UNCONNECTED;
  wire NLW_U0_rd_rst_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire NLW_U0_underflow_UNCONNECTED;
  wire NLW_U0_valid_UNCONNECTED;
  wire NLW_U0_wr_ack_UNCONNECTED;
  wire NLW_U0_wr_rst_busy_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_wr_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_wr_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_wr_data_count_UNCONNECTED;
  wire [9:0]NLW_U0_axis_data_count_UNCONNECTED;
  wire [9:0]NLW_U0_axis_rd_data_count_UNCONNECTED;
  wire [9:0]NLW_U0_axis_wr_data_count_UNCONNECTED;
  wire [9:0]NLW_U0_data_count_UNCONNECTED;
  wire [17:0]NLW_U0_dout_UNCONNECTED;
  wire [31:0]NLW_U0_m_axi_araddr_UNCONNECTED;
  wire [1:0]NLW_U0_m_axi_arburst_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arcache_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_arid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_arlen_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_arlock_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_arprot_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arqos_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arregion_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_arsize_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_aruser_UNCONNECTED;
  wire [31:0]NLW_U0_m_axi_awaddr_UNCONNECTED;
  wire [1:0]NLW_U0_m_axi_awburst_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awcache_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_awlen_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awlock_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_awprot_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awqos_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awregion_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_awsize_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awuser_UNCONNECTED;
  wire [63:0]NLW_U0_m_axi_wdata_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_wid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_wstrb_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_wuser_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tdest_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axis_tkeep_UNCONNECTED;
  wire [7:0]NLW_U0_m_axis_tstrb_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tuser_UNCONNECTED;
  wire [9:0]NLW_U0_rd_data_count_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_buser_UNCONNECTED;
  wire [63:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_ruser_UNCONNECTED;
  wire [9:0]NLW_U0_wr_data_count_UNCONNECTED;

  (* C_ADD_NGC_CONSTRAINT = "0" *) 
  (* C_APPLICATION_TYPE_AXIS = "4" *) 
  (* C_APPLICATION_TYPE_RACH = "0" *) 
  (* C_APPLICATION_TYPE_RDCH = "4" *) 
  (* C_APPLICATION_TYPE_WACH = "0" *) 
  (* C_APPLICATION_TYPE_WDCH = "4" *) 
  (* C_APPLICATION_TYPE_WRCH = "0" *) 
  (* C_AXIS_TDATA_WIDTH = "64" *) 
  (* C_AXIS_TDEST_WIDTH = "1" *) 
  (* C_AXIS_TID_WIDTH = "1" *) 
  (* C_AXIS_TKEEP_WIDTH = "8" *) 
  (* C_AXIS_TSTRB_WIDTH = "8" *) 
  (* C_AXIS_TUSER_WIDTH = "1" *) 
  (* C_AXIS_TYPE = "0" *) 
  (* C_AXI_ADDR_WIDTH = "32" *) 
  (* C_AXI_ARUSER_WIDTH = "1" *) 
  (* C_AXI_AWUSER_WIDTH = "1" *) 
  (* C_AXI_BUSER_WIDTH = "1" *) 
  (* C_AXI_DATA_WIDTH = "64" *) 
  (* C_AXI_ID_WIDTH = "1" *) 
  (* C_AXI_LEN_WIDTH = "8" *) 
  (* C_AXI_LOCK_WIDTH = "1" *) 
  (* C_AXI_RUSER_WIDTH = "1" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_AXI_WUSER_WIDTH = "1" *) 
  (* C_COMMON_CLOCK = "1" *) 
  (* C_COUNT_TYPE = "0" *) 
  (* C_DATA_COUNT_WIDTH = "10" *) 
  (* C_DEFAULT_VALUE = "BlankString" *) 
  (* C_DIN_WIDTH = "18" *) 
  (* C_DIN_WIDTH_AXIS = "64" *) 
  (* C_DIN_WIDTH_RACH = "32" *) 
  (* C_DIN_WIDTH_RDCH = "64" *) 
  (* C_DIN_WIDTH_WACH = "32" *) 
  (* C_DIN_WIDTH_WDCH = "64" *) 
  (* C_DIN_WIDTH_WRCH = "2" *) 
  (* C_DOUT_RST_VAL = "0" *) 
  (* C_DOUT_WIDTH = "18" *) 
  (* C_ENABLE_RLOCS = "0" *) 
  (* C_ENABLE_RST_SYNC = "1" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_ERROR_INJECTION_TYPE = "0" *) 
  (* C_ERROR_INJECTION_TYPE_AXIS = "0" *) 
  (* C_ERROR_INJECTION_TYPE_RACH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_RDCH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WACH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WDCH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WRCH = "0" *) 
  (* C_FAMILY = "zynquplus" *) 
  (* C_FULL_FLAGS_RST_VAL = "0" *) 
  (* C_HAS_ALMOST_EMPTY = "0" *) 
  (* C_HAS_ALMOST_FULL = "0" *) 
  (* C_HAS_AXIS_TDATA = "1" *) 
  (* C_HAS_AXIS_TDEST = "0" *) 
  (* C_HAS_AXIS_TID = "0" *) 
  (* C_HAS_AXIS_TKEEP = "0" *) 
  (* C_HAS_AXIS_TLAST = "0" *) 
  (* C_HAS_AXIS_TREADY = "1" *) 
  (* C_HAS_AXIS_TSTRB = "0" *) 
  (* C_HAS_AXIS_TUSER = "0" *) 
  (* C_HAS_AXI_ARUSER = "0" *) 
  (* C_HAS_AXI_AWUSER = "0" *) 
  (* C_HAS_AXI_BUSER = "0" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_AXI_RD_CHANNEL = "1" *) 
  (* C_HAS_AXI_RUSER = "0" *) 
  (* C_HAS_AXI_WR_CHANNEL = "1" *) 
  (* C_HAS_AXI_WUSER = "0" *) 
  (* C_HAS_BACKUP = "0" *) 
  (* C_HAS_DATA_COUNT = "0" *) 
  (* C_HAS_DATA_COUNTS_AXIS = "0" *) 
  (* C_HAS_DATA_COUNTS_RACH = "0" *) 
  (* C_HAS_DATA_COUNTS_RDCH = "0" *) 
  (* C_HAS_DATA_COUNTS_WACH = "0" *) 
  (* C_HAS_DATA_COUNTS_WDCH = "0" *) 
  (* C_HAS_DATA_COUNTS_WRCH = "0" *) 
  (* C_HAS_INT_CLK = "0" *) 
  (* C_HAS_MASTER_CE = "0" *) 
  (* C_HAS_MEMINIT_FILE = "0" *) 
  (* C_HAS_OVERFLOW = "0" *) 
  (* C_HAS_PROG_FLAGS_AXIS = "0" *) 
  (* C_HAS_PROG_FLAGS_RACH = "0" *) 
  (* C_HAS_PROG_FLAGS_RDCH = "0" *) 
  (* C_HAS_PROG_FLAGS_WACH = "0" *) 
  (* C_HAS_PROG_FLAGS_WDCH = "0" *) 
  (* C_HAS_PROG_FLAGS_WRCH = "0" *) 
  (* C_HAS_RD_DATA_COUNT = "0" *) 
  (* C_HAS_RD_RST = "0" *) 
  (* C_HAS_RST = "0" *) 
  (* C_HAS_SLAVE_CE = "0" *) 
  (* C_HAS_SRST = "1" *) 
  (* C_HAS_UNDERFLOW = "0" *) 
  (* C_HAS_VALID = "0" *) 
  (* C_HAS_WR_ACK = "0" *) 
  (* C_HAS_WR_DATA_COUNT = "0" *) 
  (* C_HAS_WR_RST = "0" *) 
  (* C_IMPLEMENTATION_TYPE = "0" *) 
  (* C_IMPLEMENTATION_TYPE_AXIS = "5" *) 
  (* C_IMPLEMENTATION_TYPE_RACH = "2" *) 
  (* C_IMPLEMENTATION_TYPE_RDCH = "5" *) 
  (* C_IMPLEMENTATION_TYPE_WACH = "2" *) 
  (* C_IMPLEMENTATION_TYPE_WDCH = "5" *) 
  (* C_IMPLEMENTATION_TYPE_WRCH = "2" *) 
  (* C_INIT_WR_PNTR_VAL = "0" *) 
  (* C_INTERFACE_TYPE = "1" *) 
  (* C_MEMORY_TYPE = "1" *) 
  (* C_MIF_FILE_NAME = "BlankString" *) 
  (* C_MSGON_VAL = "1" *) 
  (* C_OPTIMIZATION_MODE = "0" *) 
  (* C_OVERFLOW_LOW = "0" *) 
  (* C_POWER_SAVING_MODE = "0" *) 
  (* C_PRELOAD_LATENCY = "2" *) 
  (* C_PRELOAD_REGS = "1" *) 
  (* C_PRIM_FIFO_TYPE = "4kx4" *) 
  (* C_PRIM_FIFO_TYPE_AXIS = "512x72" *) 
  (* C_PRIM_FIFO_TYPE_RACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_RDCH = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_WACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_WDCH = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_WRCH = "512x36" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL = "2" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS = "510" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH = "14" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH = "14" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH = "14" *) 
  (* C_PROG_EMPTY_THRESH_NEGATE_VAL = "3" *) 
  (* C_PROG_EMPTY_TYPE = "0" *) 
  (* C_PROG_EMPTY_TYPE_AXIS = "0" *) 
  (* C_PROG_EMPTY_TYPE_RACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_RDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WRCH = "0" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_AXIS = "511" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RACH = "15" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WACH = "15" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WRCH = "15" *) 
  (* C_PROG_FULL_THRESH_NEGATE_VAL = "1022" *) 
  (* C_PROG_FULL_TYPE = "0" *) 
  (* C_PROG_FULL_TYPE_AXIS = "0" *) 
  (* C_PROG_FULL_TYPE_RACH = "0" *) 
  (* C_PROG_FULL_TYPE_RDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WACH = "0" *) 
  (* C_PROG_FULL_TYPE_WDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WRCH = "0" *) 
  (* C_RACH_TYPE = "0" *) 
  (* C_RDCH_TYPE = "0" *) 
  (* C_RD_DATA_COUNT_WIDTH = "10" *) 
  (* C_RD_DEPTH = "1024" *) 
  (* C_RD_FREQ = "1" *) 
  (* C_RD_PNTR_WIDTH = "10" *) 
  (* C_REG_SLICE_MODE_AXIS = "0" *) 
  (* C_REG_SLICE_MODE_RACH = "0" *) 
  (* C_REG_SLICE_MODE_RDCH = "0" *) 
  (* C_REG_SLICE_MODE_WACH = "0" *) 
  (* C_REG_SLICE_MODE_WDCH = "0" *) 
  (* C_REG_SLICE_MODE_WRCH = "0" *) 
  (* C_SELECT_XPM = "0" *) 
  (* C_SYNCHRONIZER_STAGE = "2" *) 
  (* C_UNDERFLOW_LOW = "0" *) 
  (* C_USE_COMMON_OVERFLOW = "0" *) 
  (* C_USE_COMMON_UNDERFLOW = "0" *) 
  (* C_USE_DEFAULT_SETTINGS = "0" *) 
  (* C_USE_DOUT_RST = "1" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_ECC_AXIS = "0" *) 
  (* C_USE_ECC_RACH = "0" *) 
  (* C_USE_ECC_RDCH = "0" *) 
  (* C_USE_ECC_WACH = "0" *) 
  (* C_USE_ECC_WDCH = "0" *) 
  (* C_USE_ECC_WRCH = "0" *) 
  (* C_USE_EMBEDDED_REG = "0" *) 
  (* C_USE_FIFO16_FLAGS = "0" *) 
  (* C_USE_FWFT_DATA_COUNT = "0" *) 
  (* C_USE_PIPELINE_REG = "0" *) 
  (* C_VALID_LOW = "0" *) 
  (* C_WACH_TYPE = "0" *) 
  (* C_WDCH_TYPE = "0" *) 
  (* C_WRCH_TYPE = "0" *) 
  (* C_WR_ACK_LOW = "0" *) 
  (* C_WR_DATA_COUNT_WIDTH = "10" *) 
  (* C_WR_DEPTH = "1024" *) 
  (* C_WR_DEPTH_AXIS = "512" *) 
  (* C_WR_DEPTH_RACH = "16" *) 
  (* C_WR_DEPTH_RDCH = "1024" *) 
  (* C_WR_DEPTH_WACH = "16" *) 
  (* C_WR_DEPTH_WDCH = "1024" *) 
  (* C_WR_DEPTH_WRCH = "16" *) 
  (* C_WR_FREQ = "1" *) 
  (* C_WR_PNTR_WIDTH = "10" *) 
  (* C_WR_PNTR_WIDTH_AXIS = "9" *) 
  (* C_WR_PNTR_WIDTH_RACH = "4" *) 
  (* C_WR_PNTR_WIDTH_RDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WACH = "4" *) 
  (* C_WR_PNTR_WIDTH_WDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WRCH = "4" *) 
  (* C_WR_RESPONSE_LATENCY = "1" *) 
  (* is_du_within_envelope = "true" *) 
  bias2sigmoid_fifo_fifo_generator_v13_2_10 U0
       (.almost_empty(NLW_U0_almost_empty_UNCONNECTED),
        .almost_full(NLW_U0_almost_full_UNCONNECTED),
        .axi_ar_data_count(NLW_U0_axi_ar_data_count_UNCONNECTED[4:0]),
        .axi_ar_dbiterr(NLW_U0_axi_ar_dbiterr_UNCONNECTED),
        .axi_ar_injectdbiterr(1'b0),
        .axi_ar_injectsbiterr(1'b0),
        .axi_ar_overflow(NLW_U0_axi_ar_overflow_UNCONNECTED),
        .axi_ar_prog_empty(NLW_U0_axi_ar_prog_empty_UNCONNECTED),
        .axi_ar_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_ar_prog_full(NLW_U0_axi_ar_prog_full_UNCONNECTED),
        .axi_ar_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_ar_rd_data_count(NLW_U0_axi_ar_rd_data_count_UNCONNECTED[4:0]),
        .axi_ar_sbiterr(NLW_U0_axi_ar_sbiterr_UNCONNECTED),
        .axi_ar_underflow(NLW_U0_axi_ar_underflow_UNCONNECTED),
        .axi_ar_wr_data_count(NLW_U0_axi_ar_wr_data_count_UNCONNECTED[4:0]),
        .axi_aw_data_count(NLW_U0_axi_aw_data_count_UNCONNECTED[4:0]),
        .axi_aw_dbiterr(NLW_U0_axi_aw_dbiterr_UNCONNECTED),
        .axi_aw_injectdbiterr(1'b0),
        .axi_aw_injectsbiterr(1'b0),
        .axi_aw_overflow(NLW_U0_axi_aw_overflow_UNCONNECTED),
        .axi_aw_prog_empty(NLW_U0_axi_aw_prog_empty_UNCONNECTED),
        .axi_aw_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_aw_prog_full(NLW_U0_axi_aw_prog_full_UNCONNECTED),
        .axi_aw_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_aw_rd_data_count(NLW_U0_axi_aw_rd_data_count_UNCONNECTED[4:0]),
        .axi_aw_sbiterr(NLW_U0_axi_aw_sbiterr_UNCONNECTED),
        .axi_aw_underflow(NLW_U0_axi_aw_underflow_UNCONNECTED),
        .axi_aw_wr_data_count(NLW_U0_axi_aw_wr_data_count_UNCONNECTED[4:0]),
        .axi_b_data_count(NLW_U0_axi_b_data_count_UNCONNECTED[4:0]),
        .axi_b_dbiterr(NLW_U0_axi_b_dbiterr_UNCONNECTED),
        .axi_b_injectdbiterr(1'b0),
        .axi_b_injectsbiterr(1'b0),
        .axi_b_overflow(NLW_U0_axi_b_overflow_UNCONNECTED),
        .axi_b_prog_empty(NLW_U0_axi_b_prog_empty_UNCONNECTED),
        .axi_b_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_b_prog_full(NLW_U0_axi_b_prog_full_UNCONNECTED),
        .axi_b_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_b_rd_data_count(NLW_U0_axi_b_rd_data_count_UNCONNECTED[4:0]),
        .axi_b_sbiterr(NLW_U0_axi_b_sbiterr_UNCONNECTED),
        .axi_b_underflow(NLW_U0_axi_b_underflow_UNCONNECTED),
        .axi_b_wr_data_count(NLW_U0_axi_b_wr_data_count_UNCONNECTED[4:0]),
        .axi_r_data_count(NLW_U0_axi_r_data_count_UNCONNECTED[10:0]),
        .axi_r_dbiterr(NLW_U0_axi_r_dbiterr_UNCONNECTED),
        .axi_r_injectdbiterr(1'b0),
        .axi_r_injectsbiterr(1'b0),
        .axi_r_overflow(NLW_U0_axi_r_overflow_UNCONNECTED),
        .axi_r_prog_empty(NLW_U0_axi_r_prog_empty_UNCONNECTED),
        .axi_r_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_r_prog_full(NLW_U0_axi_r_prog_full_UNCONNECTED),
        .axi_r_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_r_rd_data_count(NLW_U0_axi_r_rd_data_count_UNCONNECTED[10:0]),
        .axi_r_sbiterr(NLW_U0_axi_r_sbiterr_UNCONNECTED),
        .axi_r_underflow(NLW_U0_axi_r_underflow_UNCONNECTED),
        .axi_r_wr_data_count(NLW_U0_axi_r_wr_data_count_UNCONNECTED[10:0]),
        .axi_w_data_count(NLW_U0_axi_w_data_count_UNCONNECTED[10:0]),
        .axi_w_dbiterr(NLW_U0_axi_w_dbiterr_UNCONNECTED),
        .axi_w_injectdbiterr(1'b0),
        .axi_w_injectsbiterr(1'b0),
        .axi_w_overflow(NLW_U0_axi_w_overflow_UNCONNECTED),
        .axi_w_prog_empty(NLW_U0_axi_w_prog_empty_UNCONNECTED),
        .axi_w_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_w_prog_full(NLW_U0_axi_w_prog_full_UNCONNECTED),
        .axi_w_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_w_rd_data_count(NLW_U0_axi_w_rd_data_count_UNCONNECTED[10:0]),
        .axi_w_sbiterr(NLW_U0_axi_w_sbiterr_UNCONNECTED),
        .axi_w_underflow(NLW_U0_axi_w_underflow_UNCONNECTED),
        .axi_w_wr_data_count(NLW_U0_axi_w_wr_data_count_UNCONNECTED[10:0]),
        .axis_data_count(NLW_U0_axis_data_count_UNCONNECTED[9:0]),
        .axis_dbiterr(NLW_U0_axis_dbiterr_UNCONNECTED),
        .axis_injectdbiterr(1'b0),
        .axis_injectsbiterr(1'b0),
        .axis_overflow(NLW_U0_axis_overflow_UNCONNECTED),
        .axis_prog_empty(NLW_U0_axis_prog_empty_UNCONNECTED),
        .axis_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axis_prog_full(NLW_U0_axis_prog_full_UNCONNECTED),
        .axis_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axis_rd_data_count(NLW_U0_axis_rd_data_count_UNCONNECTED[9:0]),
        .axis_sbiterr(NLW_U0_axis_sbiterr_UNCONNECTED),
        .axis_underflow(NLW_U0_axis_underflow_UNCONNECTED),
        .axis_wr_data_count(NLW_U0_axis_wr_data_count_UNCONNECTED[9:0]),
        .backup(1'b0),
        .backup_marker(1'b0),
        .clk(1'b0),
        .data_count(NLW_U0_data_count_UNCONNECTED[9:0]),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .din({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dout(NLW_U0_dout_UNCONNECTED[17:0]),
        .empty(NLW_U0_empty_UNCONNECTED),
        .full(NLW_U0_full_UNCONNECTED),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .int_clk(1'b0),
        .m_aclk(1'b0),
        .m_aclk_en(1'b0),
        .m_axi_araddr(NLW_U0_m_axi_araddr_UNCONNECTED[31:0]),
        .m_axi_arburst(NLW_U0_m_axi_arburst_UNCONNECTED[1:0]),
        .m_axi_arcache(NLW_U0_m_axi_arcache_UNCONNECTED[3:0]),
        .m_axi_arid(NLW_U0_m_axi_arid_UNCONNECTED[0]),
        .m_axi_arlen(NLW_U0_m_axi_arlen_UNCONNECTED[7:0]),
        .m_axi_arlock(NLW_U0_m_axi_arlock_UNCONNECTED[0]),
        .m_axi_arprot(NLW_U0_m_axi_arprot_UNCONNECTED[2:0]),
        .m_axi_arqos(NLW_U0_m_axi_arqos_UNCONNECTED[3:0]),
        .m_axi_arready(1'b0),
        .m_axi_arregion(NLW_U0_m_axi_arregion_UNCONNECTED[3:0]),
        .m_axi_arsize(NLW_U0_m_axi_arsize_UNCONNECTED[2:0]),
        .m_axi_aruser(NLW_U0_m_axi_aruser_UNCONNECTED[0]),
        .m_axi_arvalid(NLW_U0_m_axi_arvalid_UNCONNECTED),
        .m_axi_awaddr(NLW_U0_m_axi_awaddr_UNCONNECTED[31:0]),
        .m_axi_awburst(NLW_U0_m_axi_awburst_UNCONNECTED[1:0]),
        .m_axi_awcache(NLW_U0_m_axi_awcache_UNCONNECTED[3:0]),
        .m_axi_awid(NLW_U0_m_axi_awid_UNCONNECTED[0]),
        .m_axi_awlen(NLW_U0_m_axi_awlen_UNCONNECTED[7:0]),
        .m_axi_awlock(NLW_U0_m_axi_awlock_UNCONNECTED[0]),
        .m_axi_awprot(NLW_U0_m_axi_awprot_UNCONNECTED[2:0]),
        .m_axi_awqos(NLW_U0_m_axi_awqos_UNCONNECTED[3:0]),
        .m_axi_awready(1'b0),
        .m_axi_awregion(NLW_U0_m_axi_awregion_UNCONNECTED[3:0]),
        .m_axi_awsize(NLW_U0_m_axi_awsize_UNCONNECTED[2:0]),
        .m_axi_awuser(NLW_U0_m_axi_awuser_UNCONNECTED[0]),
        .m_axi_awvalid(NLW_U0_m_axi_awvalid_UNCONNECTED),
        .m_axi_bid(1'b0),
        .m_axi_bready(NLW_U0_m_axi_bready_UNCONNECTED),
        .m_axi_bresp({1'b0,1'b0}),
        .m_axi_buser(1'b0),
        .m_axi_bvalid(1'b0),
        .m_axi_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_axi_rid(1'b0),
        .m_axi_rlast(1'b0),
        .m_axi_rready(NLW_U0_m_axi_rready_UNCONNECTED),
        .m_axi_rresp({1'b0,1'b0}),
        .m_axi_ruser(1'b0),
        .m_axi_rvalid(1'b0),
        .m_axi_wdata(NLW_U0_m_axi_wdata_UNCONNECTED[63:0]),
        .m_axi_wid(NLW_U0_m_axi_wid_UNCONNECTED[0]),
        .m_axi_wlast(NLW_U0_m_axi_wlast_UNCONNECTED),
        .m_axi_wready(1'b0),
        .m_axi_wstrb(NLW_U0_m_axi_wstrb_UNCONNECTED[7:0]),
        .m_axi_wuser(NLW_U0_m_axi_wuser_UNCONNECTED[0]),
        .m_axi_wvalid(NLW_U0_m_axi_wvalid_UNCONNECTED),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tdest(NLW_U0_m_axis_tdest_UNCONNECTED[0]),
        .m_axis_tid(NLW_U0_m_axis_tid_UNCONNECTED[0]),
        .m_axis_tkeep(NLW_U0_m_axis_tkeep_UNCONNECTED[7:0]),
        .m_axis_tlast(NLW_U0_m_axis_tlast_UNCONNECTED),
        .m_axis_tready(m_axis_tready),
        .m_axis_tstrb(NLW_U0_m_axis_tstrb_UNCONNECTED[7:0]),
        .m_axis_tuser(NLW_U0_m_axis_tuser_UNCONNECTED[0]),
        .m_axis_tvalid(m_axis_tvalid),
        .overflow(NLW_U0_overflow_UNCONNECTED),
        .prog_empty(NLW_U0_prog_empty_UNCONNECTED),
        .prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full(NLW_U0_prog_full_UNCONNECTED),
        .prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .rd_clk(1'b0),
        .rd_data_count(NLW_U0_rd_data_count_UNCONNECTED[9:0]),
        .rd_en(1'b0),
        .rd_rst(1'b0),
        .rd_rst_busy(NLW_U0_rd_rst_busy_UNCONNECTED),
        .rst(1'b0),
        .s_aclk(s_aclk),
        .s_aclk_en(1'b0),
        .s_aresetn(s_aresetn),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arid(1'b0),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlock(1'b0),
        .s_axi_arprot({1'b0,1'b0,1'b0}),
        .s_axi_arqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_aruser(1'b0),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awid(1'b0),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlock(1'b0),
        .s_axi_awprot({1'b0,1'b0,1'b0}),
        .s_axi_awqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awuser(1'b0),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_buser(NLW_U0_s_axi_buser_UNCONNECTED[0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[63:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_ruser(NLW_U0_s_axi_ruser_UNCONNECTED[0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wid(1'b0),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wuser(1'b0),
        .s_axi_wvalid(1'b0),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tdest(1'b0),
        .s_axis_tid(1'b0),
        .s_axis_tkeep({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tlast(1'b0),
        .s_axis_tready(s_axis_tready),
        .s_axis_tstrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tuser(1'b0),
        .s_axis_tvalid(s_axis_tvalid),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .sleep(1'b0),
        .srst(1'b0),
        .underflow(NLW_U0_underflow_UNCONNECTED),
        .valid(NLW_U0_valid_UNCONNECTED),
        .wr_ack(NLW_U0_wr_ack_UNCONNECTED),
        .wr_clk(1'b0),
        .wr_data_count(NLW_U0_wr_data_count_UNCONNECTED[9:0]),
        .wr_en(1'b0),
        .wr_rst(1'b0),
        .wr_rst_busy(NLW_U0_wr_rst_busy_UNCONNECTED));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2024.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
VRufLWT3xuzTvQKo8VrgeA7TQuqzWEYy/B1VZF2gTA62OnYpyvfz/jYVlv8uQmDxe/ByRttr4gwP
tNck8lOlu04WorDYZXBY99Iv+CD1MRsK+y6klNIUbRWjkWmJ0jF7xfzo5v6+6GlaIHD1nYWB0BGS
XKOLLgkxdDTc9QzwJD4=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
uL+N2Y0N0Nss4UIbL4YgwYw1dJAEJxw9VgIJekBqgLF5Hu0OvgBycKBL3tx4bMFtXLoBUh2ZjpPa
Go57AlryR20NeXp3+hoQeboPP11E649UsEN94qUxaPWE5/ujAWzWT8PMJfk3CAspcIaP3XsDNcxF
vPCbKLRNyWvSzyiofwOXgxNNgLi38SzcrWZtPo/eMELIxeVE3bkV2B7I60W9KI1gXiOj3SjPTDnx
EMAbJCwmbwCkTXljtuzvIRTsGb9QIurgASMwg4IWmb9DS6EbeVgoWu9ePD+YKuN3LcW87KSgmC3y
Mirx3ScsFGRfcOAUOLlOQxU4qqE1ZAjtBAua1w==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
ngggZ4AaOolK7F7zeqf8LCxDCGfbvArfgDzbRvoxE+aIi2H2/ZgHbrcaf1Km1cW+38j2kTOpZ5BU
JUI2G5HZNfsoiLXjFbOMvQQqByNzlhCZjrS3N725Cznvy/nQpUy+kW4iA6DQZKnpdC2s18Suxi5p
XtgDcUzCh62ABICOpz8=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
FzAmLTVxyHRqX0WAddlPopAH/5r3ExgkeVujmhMcJXHbjZ+OKAHOMXTsnwDh03EpZ2Dn+0UPeR9J
JML3A+MQGMuUUzy/4d/lj5rriSnTu0eRK0uK6Gl8vjL08vO3UKb6wGj/w9CP45OWOkbMNgZzJkAl
ulPX0OUqymWYOn3WVAtIlaQ0dmpONV8p6Ixe9p5wlEtvy+7JjUPwaVnKlLjKSAaYD07OqMK+IOEP
5oYs2BscpZ3YKlKVJkoU493L7szHHn2LhSUrMld33nLuWIO6WPdo2u2pTnWXl/J1BzNaK1VaLx4R
H7VhIvgYcSlzCrtbQuNHKFtDPGhXjeA41TS29g==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Oad6Ezs+KRRjlYrAkExu4Kft2T1qNa0HGt8W7O1ByK1ecBs0TGWt/sS3pnt6d6jWuqvsWhrmcGsU
TD7Z+IY65xRZ4IJfgngZD8v540FOGMuFUS31UWxcC7CI6qOo20Q0Irtoxrqm01u5p3tI87ApsE8S
lc2lQ5dh54cGYlRfmo5mYTw6WSHyyVYmoh9npUliD4eNVIKUqnBo1kmYzicnKe8ewFKTEWpjdMeZ
/4YxF/NRZzHTA3GIsnjcgOHia68T/NJJ+zQmoNwxerZWWoacU1EU0IHxET3y4fS/u0Af8OJhkGQf
jI0jGobNLRYYufemCxL6333z0oAno0RiPZlavA==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2023_11", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
LVIUY1x0cEHel3aUfppGw9v6zvpZmh/zrCgsFGWLi8t0vWUC/ikETYOpuFw/0f9L2t8c6tQj/BSQ
wjvzq42gFgtW+CFBjgHAVUBDHhzlv/GKUM/2Vq36bMg9H5f44nJH+7mDDGVPf2PyYZRkAosFPUpA
wRqTC/g2mQ0mMY/gZGQRrs+/VY69Ze9sjoEiEXuwkb/+/VjXgHCxiCzG4cKf0ZiQ+rePhqJqB7FK
IJ+6LHriZD474qtFLq3fOZ9mrqOgN7iBQlc66dO9E0RmZZZsWtQQzZ4q1c2pzvsjDdJyWe0mTlwa
QGVmYElSvL9in5WwDxoKM+2J7vco8OIexLgbJg==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Qf9CPkJTDS6nRjzJ66HoyvpTqtDB4QY3Hy9peOp3xA39ggAvytqhHhiPv35dCRWSCdAyO1u2m+O7
/knms947I+MYTpHHfukyZsBbLho0jRq3cSXe9e6VE+4Dt40wryd91cmi93qmeUxg+vf0F91ug50P
gJ4oGYP71ANEq1UaGqGHgVK0ZsY6jTyc0x25eh+fnXg6vElSbqcptvyGMOBVT/g+gDKIheN40WzZ
Tday7b7o8j+UecVazn9OG8lGmgEQH+ilZfelpEFOBKoEc7YS6kKJ1yiX5nxRMJalTuojq5mhxebk
EsmPJe45gdIAuAmBpw3iLddcx52Arew1xpNY9w==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
H+d/6javaSRU2swARkzTIL8p3itaD4ohPxaTAeOjHpt7R9NIiNpHJvUFWkpZ02WVRAGHIw8Kujz3
6qQbQgKv8nhuS0lDhOHSDBVglvTONFSPjBj6pNY2XB24O4tlMghNicwCBXjxGXS6xET2pHNCj46f
01l0BHXfAtSn5SMPu3KYxDnod+2/TDKoWzzX29rrvh4wvf+eKFGbEVa3/RP2yg+Mp05W5p0KZ1Z3
JvOIxc57qFLARbLg1ToAzgZ8iZXLB5tX2Ez+rVDzW4i9ZvMW40QGIP5F6KCmuWunjVyqcasQ+9V7
oxcmw4sBdn0TYckrmrDvGtKxr+at316tB9uFJzLHWIwjnROKDoFwhcBbXzoqNoU/oBWqorM8JnDS
d/8tvN+7zx+k1OgCrpu5jgCA2E9LIMqL+HO19rub4MD4RjgOufHPDbN2wv6I9bj3Tko+kBZSFxxR
1SnGvhgPAaZJxQLEM+WE8SnVMzJI0RKNctcFv/jmWTYmAdTGIiTDAcmW

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
WXM4aFffz6byfeUnRWfxJR3Sbg31hpZIfhJu9O4aqVdZMRQzhrArOJ75qYkGOgZjI+35a4DA9Ohc
RMh3Tm8A5kh9XM67B45s3+7vF8pYIM5pFlzEQBSQ/OeeAi6GNLI2ACXQl1WutRpQKuwX9iboEsRb
Kc1SU6AOV6yaliF6tUt1LL4x+bC8mqlEHTk6SvN7aiA23tVDcik1QSH66CO3/+J5f88G53DHDqtY
T6w2k7pUziwTnLfirI+XpPgqYp9YYRQEv52Q7wTYJlYnVYrMyludNuTaIE27AkgPAneEkdJlrq9l
eVOgs6ZIO1DEusKG7VzkbM1sS0GnU5Zhuj1Eww==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
KJ2iLB3UgRnxezAEg3KJ/gREzXcLo8pOtacMRsDMsFCSD3vYAdGUKSARO8g71pIGFzJo6PBwogFR
MkJED/0TqwZaleoFaN2ULuSnzZGmf8vT0qKvutBGquDn8MH7T3k3wLxcNdZQLnkqisJCMj8u+71g
xMQRAkhtAQvA2cWb6TDQN6jmfByZuu/AH3X+YZ43XIDG/jymNkwyBWNNx0yzbZouJtOuzzYHhYoC
AAuKR+zfynO91P9hcrXFiExHtCmvb73DA4ICLGiOzEj+C1PMPBX9AHdhnWYy5BbQGsd727Y50yNo
xmTU1vBKL2ewwN4j/Ib2AK/Z7T+d/NunpRbCnA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
eYDP9MWXRUmO05etuHvoqbEMRNQHmR5nos71kLkRxpycXrdpHxalQmyEdCdbeVoM8lN9qwxKuN0l
yQn00dSYRi3P02ygaVsHqVAsRtz2yRpIRjyGMYD7zKpnNQw476DBmK+/sCD7EH6NxSfzUNnfoURL
uIFC0sHEYpwX6Qt2bT2GdCC0OFvaGwQNimyTFdfeey7cdpg9JmsQRgLEUfRwG1Dk0iu258zTUnT+
31O5RA9OwlgZJpC+LpCvL8XAmGZJ4CCeUf2hnpppoV4KphAV4mCBUkNtUYZSJdF0a5cdHFxnxR5n
nI0ed4USMMiNvLqvP0HQgecfCvYzYx9kk0bmtA==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 57040)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
