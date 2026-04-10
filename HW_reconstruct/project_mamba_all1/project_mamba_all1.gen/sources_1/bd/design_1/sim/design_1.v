//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
//Date        : Fri Apr 10 15:19:34 2026
//Host        : 13600kf running 64-bit major release  (build 9200)
//Command     : generate_target design_1.bd
//Design      : design_1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=7,numReposBlks=7,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=1,numPkgbdBlks=0,bdsource=USER,da_axi4_cnt=17,da_board_cnt=1,da_clkrst_cnt=4,da_zynq_ultra_ps_e_cnt=1,synth_mode=Hierarchical}" *) (* HW_HANDOFF = "design_1.hwdef" *) 
module design_1
   ();

  wire [63:0]axi_dma_GY_M_AXIS_MM2S_TDATA;
  wire axi_dma_GY_M_AXIS_MM2S_TLAST;
  wire axi_dma_GY_M_AXIS_MM2S_TREADY;
  wire axi_dma_GY_M_AXIS_MM2S_TVALID;
  wire [31:0]axi_dma_GY_M_AXI_MM2S_ARADDR;
  wire [1:0]axi_dma_GY_M_AXI_MM2S_ARBURST;
  wire [3:0]axi_dma_GY_M_AXI_MM2S_ARCACHE;
  wire [7:0]axi_dma_GY_M_AXI_MM2S_ARLEN;
  wire [2:0]axi_dma_GY_M_AXI_MM2S_ARPROT;
  wire axi_dma_GY_M_AXI_MM2S_ARREADY;
  wire [2:0]axi_dma_GY_M_AXI_MM2S_ARSIZE;
  wire axi_dma_GY_M_AXI_MM2S_ARVALID;
  wire [63:0]axi_dma_GY_M_AXI_MM2S_RDATA;
  wire axi_dma_GY_M_AXI_MM2S_RLAST;
  wire axi_dma_GY_M_AXI_MM2S_RREADY;
  wire [1:0]axi_dma_GY_M_AXI_MM2S_RRESP;
  wire axi_dma_GY_M_AXI_MM2S_RVALID;
  wire [31:0]axi_dma_GY_M_AXI_S2MM_AWADDR;
  wire [1:0]axi_dma_GY_M_AXI_S2MM_AWBURST;
  wire [3:0]axi_dma_GY_M_AXI_S2MM_AWCACHE;
  wire [7:0]axi_dma_GY_M_AXI_S2MM_AWLEN;
  wire [2:0]axi_dma_GY_M_AXI_S2MM_AWPROT;
  wire axi_dma_GY_M_AXI_S2MM_AWREADY;
  wire [2:0]axi_dma_GY_M_AXI_S2MM_AWSIZE;
  wire axi_dma_GY_M_AXI_S2MM_AWVALID;
  wire axi_dma_GY_M_AXI_S2MM_BREADY;
  wire [1:0]axi_dma_GY_M_AXI_S2MM_BRESP;
  wire axi_dma_GY_M_AXI_S2MM_BVALID;
  wire [63:0]axi_dma_GY_M_AXI_S2MM_WDATA;
  wire axi_dma_GY_M_AXI_S2MM_WLAST;
  wire axi_dma_GY_M_AXI_S2MM_WREADY;
  wire [7:0]axi_dma_GY_M_AXI_S2MM_WSTRB;
  wire axi_dma_GY_M_AXI_S2MM_WVALID;
  wire axi_dma_GY_s2mm_introut;
  wire [63:0]axi_dma_h_M_AXIS_MM2S_TDATA;
  wire axi_dma_h_M_AXIS_MM2S_TLAST;
  wire axi_dma_h_M_AXIS_MM2S_TREADY;
  wire axi_dma_h_M_AXIS_MM2S_TVALID;
  wire [31:0]axi_dma_h_M_AXI_MM2S_ARADDR;
  wire [1:0]axi_dma_h_M_AXI_MM2S_ARBURST;
  wire [3:0]axi_dma_h_M_AXI_MM2S_ARCACHE;
  wire [7:0]axi_dma_h_M_AXI_MM2S_ARLEN;
  wire [2:0]axi_dma_h_M_AXI_MM2S_ARPROT;
  wire axi_dma_h_M_AXI_MM2S_ARREADY;
  wire [2:0]axi_dma_h_M_AXI_MM2S_ARSIZE;
  wire axi_dma_h_M_AXI_MM2S_ARVALID;
  wire [63:0]axi_dma_h_M_AXI_MM2S_RDATA;
  wire axi_dma_h_M_AXI_MM2S_RLAST;
  wire axi_dma_h_M_AXI_MM2S_RREADY;
  wire [1:0]axi_dma_h_M_AXI_MM2S_RRESP;
  wire axi_dma_h_M_AXI_MM2S_RVALID;
  wire [0:0]proc_sys_reset_0_peripheral_aresetn;
  wire [63:0]reuse_mamba_board_sh_0_m_axis_y_TDATA;
  wire reuse_mamba_board_sh_0_m_axis_y_TLAST;
  wire reuse_mamba_board_sh_0_m_axis_y_TREADY;
  wire reuse_mamba_board_sh_0_m_axis_y_TVALID;
  wire [11:0]smartconnect_ctrl_M00_AXI_ARADDR;
  wire smartconnect_ctrl_M00_AXI_ARREADY;
  wire smartconnect_ctrl_M00_AXI_ARVALID;
  wire [11:0]smartconnect_ctrl_M00_AXI_AWADDR;
  wire smartconnect_ctrl_M00_AXI_AWREADY;
  wire smartconnect_ctrl_M00_AXI_AWVALID;
  wire smartconnect_ctrl_M00_AXI_BREADY;
  wire [1:0]smartconnect_ctrl_M00_AXI_BRESP;
  wire smartconnect_ctrl_M00_AXI_BVALID;
  wire [31:0]smartconnect_ctrl_M00_AXI_RDATA;
  wire smartconnect_ctrl_M00_AXI_RREADY;
  wire [1:0]smartconnect_ctrl_M00_AXI_RRESP;
  wire smartconnect_ctrl_M00_AXI_RVALID;
  wire [31:0]smartconnect_ctrl_M00_AXI_WDATA;
  wire smartconnect_ctrl_M00_AXI_WREADY;
  wire [3:0]smartconnect_ctrl_M00_AXI_WSTRB;
  wire smartconnect_ctrl_M00_AXI_WVALID;
  wire [9:0]smartconnect_ctrl_M01_AXI_ARADDR;
  wire smartconnect_ctrl_M01_AXI_ARREADY;
  wire smartconnect_ctrl_M01_AXI_ARVALID;
  wire [9:0]smartconnect_ctrl_M01_AXI_AWADDR;
  wire smartconnect_ctrl_M01_AXI_AWREADY;
  wire smartconnect_ctrl_M01_AXI_AWVALID;
  wire smartconnect_ctrl_M01_AXI_BREADY;
  wire [1:0]smartconnect_ctrl_M01_AXI_BRESP;
  wire smartconnect_ctrl_M01_AXI_BVALID;
  wire [31:0]smartconnect_ctrl_M01_AXI_RDATA;
  wire smartconnect_ctrl_M01_AXI_RREADY;
  wire [1:0]smartconnect_ctrl_M01_AXI_RRESP;
  wire smartconnect_ctrl_M01_AXI_RVALID;
  wire [31:0]smartconnect_ctrl_M01_AXI_WDATA;
  wire smartconnect_ctrl_M01_AXI_WREADY;
  wire smartconnect_ctrl_M01_AXI_WVALID;
  wire [9:0]smartconnect_ctrl_M02_AXI_ARADDR;
  wire smartconnect_ctrl_M02_AXI_ARREADY;
  wire smartconnect_ctrl_M02_AXI_ARVALID;
  wire [9:0]smartconnect_ctrl_M02_AXI_AWADDR;
  wire smartconnect_ctrl_M02_AXI_AWREADY;
  wire smartconnect_ctrl_M02_AXI_AWVALID;
  wire smartconnect_ctrl_M02_AXI_BREADY;
  wire [1:0]smartconnect_ctrl_M02_AXI_BRESP;
  wire smartconnect_ctrl_M02_AXI_BVALID;
  wire [31:0]smartconnect_ctrl_M02_AXI_RDATA;
  wire smartconnect_ctrl_M02_AXI_RREADY;
  wire [1:0]smartconnect_ctrl_M02_AXI_RRESP;
  wire smartconnect_ctrl_M02_AXI_RVALID;
  wire [31:0]smartconnect_ctrl_M02_AXI_WDATA;
  wire smartconnect_ctrl_M02_AXI_WREADY;
  wire smartconnect_ctrl_M02_AXI_WVALID;
  wire [48:0]smartconnect_mem_M00_AXI_ARADDR;
  wire [1:0]smartconnect_mem_M00_AXI_ARBURST;
  wire [3:0]smartconnect_mem_M00_AXI_ARCACHE;
  wire [7:0]smartconnect_mem_M00_AXI_ARLEN;
  wire [0:0]smartconnect_mem_M00_AXI_ARLOCK;
  wire [2:0]smartconnect_mem_M00_AXI_ARPROT;
  wire [3:0]smartconnect_mem_M00_AXI_ARQOS;
  wire smartconnect_mem_M00_AXI_ARREADY;
  wire [2:0]smartconnect_mem_M00_AXI_ARSIZE;
  wire smartconnect_mem_M00_AXI_ARVALID;
  wire [48:0]smartconnect_mem_M00_AXI_AWADDR;
  wire [1:0]smartconnect_mem_M00_AXI_AWBURST;
  wire [3:0]smartconnect_mem_M00_AXI_AWCACHE;
  wire [7:0]smartconnect_mem_M00_AXI_AWLEN;
  wire [0:0]smartconnect_mem_M00_AXI_AWLOCK;
  wire [2:0]smartconnect_mem_M00_AXI_AWPROT;
  wire [3:0]smartconnect_mem_M00_AXI_AWQOS;
  wire smartconnect_mem_M00_AXI_AWREADY;
  wire [2:0]smartconnect_mem_M00_AXI_AWSIZE;
  wire smartconnect_mem_M00_AXI_AWVALID;
  wire smartconnect_mem_M00_AXI_BREADY;
  wire [1:0]smartconnect_mem_M00_AXI_BRESP;
  wire smartconnect_mem_M00_AXI_BVALID;
  wire [127:0]smartconnect_mem_M00_AXI_RDATA;
  wire smartconnect_mem_M00_AXI_RLAST;
  wire smartconnect_mem_M00_AXI_RREADY;
  wire [1:0]smartconnect_mem_M00_AXI_RRESP;
  wire smartconnect_mem_M00_AXI_RVALID;
  wire [127:0]smartconnect_mem_M00_AXI_WDATA;
  wire smartconnect_mem_M00_AXI_WLAST;
  wire smartconnect_mem_M00_AXI_WREADY;
  wire [15:0]smartconnect_mem_M00_AXI_WSTRB;
  wire smartconnect_mem_M00_AXI_WVALID;
  wire [39:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARADDR;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARBURST;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARCACHE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARID;
  wire [7:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLEN;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLOCK;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARPROT;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARQOS;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARREADY;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARSIZE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARUSER;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARVALID;
  wire [39:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWADDR;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWBURST;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWCACHE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWID;
  wire [7:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLEN;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLOCK;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWPROT;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWQOS;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWREADY;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWSIZE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWUSER;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWVALID;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BID;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BREADY;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BRESP;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BVALID;
  wire [127:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RDATA;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RID;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RLAST;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RREADY;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RRESP;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RVALID;
  wire [127:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WDATA;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WLAST;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WREADY;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WSTRB;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WVALID;
  wire zynq_ultra_ps_e_0_pl_clk0;
  wire zynq_ultra_ps_e_0_pl_resetn0;

  design_1_axi_dma_0_1 axi_dma_GY
       (.axi_resetn(proc_sys_reset_0_peripheral_aresetn),
        .m_axi_mm2s_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .m_axi_mm2s_araddr(axi_dma_GY_M_AXI_MM2S_ARADDR),
        .m_axi_mm2s_arburst(axi_dma_GY_M_AXI_MM2S_ARBURST),
        .m_axi_mm2s_arcache(axi_dma_GY_M_AXI_MM2S_ARCACHE),
        .m_axi_mm2s_arlen(axi_dma_GY_M_AXI_MM2S_ARLEN),
        .m_axi_mm2s_arprot(axi_dma_GY_M_AXI_MM2S_ARPROT),
        .m_axi_mm2s_arready(axi_dma_GY_M_AXI_MM2S_ARREADY),
        .m_axi_mm2s_arsize(axi_dma_GY_M_AXI_MM2S_ARSIZE),
        .m_axi_mm2s_arvalid(axi_dma_GY_M_AXI_MM2S_ARVALID),
        .m_axi_mm2s_rdata(axi_dma_GY_M_AXI_MM2S_RDATA),
        .m_axi_mm2s_rlast(axi_dma_GY_M_AXI_MM2S_RLAST),
        .m_axi_mm2s_rready(axi_dma_GY_M_AXI_MM2S_RREADY),
        .m_axi_mm2s_rresp(axi_dma_GY_M_AXI_MM2S_RRESP),
        .m_axi_mm2s_rvalid(axi_dma_GY_M_AXI_MM2S_RVALID),
        .m_axi_s2mm_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .m_axi_s2mm_awaddr(axi_dma_GY_M_AXI_S2MM_AWADDR),
        .m_axi_s2mm_awburst(axi_dma_GY_M_AXI_S2MM_AWBURST),
        .m_axi_s2mm_awcache(axi_dma_GY_M_AXI_S2MM_AWCACHE),
        .m_axi_s2mm_awlen(axi_dma_GY_M_AXI_S2MM_AWLEN),
        .m_axi_s2mm_awprot(axi_dma_GY_M_AXI_S2MM_AWPROT),
        .m_axi_s2mm_awready(axi_dma_GY_M_AXI_S2MM_AWREADY),
        .m_axi_s2mm_awsize(axi_dma_GY_M_AXI_S2MM_AWSIZE),
        .m_axi_s2mm_awvalid(axi_dma_GY_M_AXI_S2MM_AWVALID),
        .m_axi_s2mm_bready(axi_dma_GY_M_AXI_S2MM_BREADY),
        .m_axi_s2mm_bresp(axi_dma_GY_M_AXI_S2MM_BRESP),
        .m_axi_s2mm_bvalid(axi_dma_GY_M_AXI_S2MM_BVALID),
        .m_axi_s2mm_wdata(axi_dma_GY_M_AXI_S2MM_WDATA),
        .m_axi_s2mm_wlast(axi_dma_GY_M_AXI_S2MM_WLAST),
        .m_axi_s2mm_wready(axi_dma_GY_M_AXI_S2MM_WREADY),
        .m_axi_s2mm_wstrb(axi_dma_GY_M_AXI_S2MM_WSTRB),
        .m_axi_s2mm_wvalid(axi_dma_GY_M_AXI_S2MM_WVALID),
        .m_axis_mm2s_tdata(axi_dma_GY_M_AXIS_MM2S_TDATA),
        .m_axis_mm2s_tlast(axi_dma_GY_M_AXIS_MM2S_TLAST),
        .m_axis_mm2s_tready(axi_dma_GY_M_AXIS_MM2S_TREADY),
        .m_axis_mm2s_tvalid(axi_dma_GY_M_AXIS_MM2S_TVALID),
        .s2mm_introut(axi_dma_GY_s2mm_introut),
        .s_axi_lite_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .s_axi_lite_araddr(smartconnect_ctrl_M02_AXI_ARADDR),
        .s_axi_lite_arready(smartconnect_ctrl_M02_AXI_ARREADY),
        .s_axi_lite_arvalid(smartconnect_ctrl_M02_AXI_ARVALID),
        .s_axi_lite_awaddr(smartconnect_ctrl_M02_AXI_AWADDR),
        .s_axi_lite_awready(smartconnect_ctrl_M02_AXI_AWREADY),
        .s_axi_lite_awvalid(smartconnect_ctrl_M02_AXI_AWVALID),
        .s_axi_lite_bready(smartconnect_ctrl_M02_AXI_BREADY),
        .s_axi_lite_bresp(smartconnect_ctrl_M02_AXI_BRESP),
        .s_axi_lite_bvalid(smartconnect_ctrl_M02_AXI_BVALID),
        .s_axi_lite_rdata(smartconnect_ctrl_M02_AXI_RDATA),
        .s_axi_lite_rready(smartconnect_ctrl_M02_AXI_RREADY),
        .s_axi_lite_rresp(smartconnect_ctrl_M02_AXI_RRESP),
        .s_axi_lite_rvalid(smartconnect_ctrl_M02_AXI_RVALID),
        .s_axi_lite_wdata(smartconnect_ctrl_M02_AXI_WDATA),
        .s_axi_lite_wready(smartconnect_ctrl_M02_AXI_WREADY),
        .s_axi_lite_wvalid(smartconnect_ctrl_M02_AXI_WVALID),
        .s_axis_s2mm_tdata(reuse_mamba_board_sh_0_m_axis_y_TDATA),
        .s_axis_s2mm_tkeep({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .s_axis_s2mm_tlast(reuse_mamba_board_sh_0_m_axis_y_TLAST),
        .s_axis_s2mm_tready(reuse_mamba_board_sh_0_m_axis_y_TREADY),
        .s_axis_s2mm_tvalid(reuse_mamba_board_sh_0_m_axis_y_TVALID));
  design_1_axi_dma_0_0 axi_dma_h
       (.axi_resetn(proc_sys_reset_0_peripheral_aresetn),
        .m_axi_mm2s_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .m_axi_mm2s_araddr(axi_dma_h_M_AXI_MM2S_ARADDR),
        .m_axi_mm2s_arburst(axi_dma_h_M_AXI_MM2S_ARBURST),
        .m_axi_mm2s_arcache(axi_dma_h_M_AXI_MM2S_ARCACHE),
        .m_axi_mm2s_arlen(axi_dma_h_M_AXI_MM2S_ARLEN),
        .m_axi_mm2s_arprot(axi_dma_h_M_AXI_MM2S_ARPROT),
        .m_axi_mm2s_arready(axi_dma_h_M_AXI_MM2S_ARREADY),
        .m_axi_mm2s_arsize(axi_dma_h_M_AXI_MM2S_ARSIZE),
        .m_axi_mm2s_arvalid(axi_dma_h_M_AXI_MM2S_ARVALID),
        .m_axi_mm2s_rdata(axi_dma_h_M_AXI_MM2S_RDATA),
        .m_axi_mm2s_rlast(axi_dma_h_M_AXI_MM2S_RLAST),
        .m_axi_mm2s_rready(axi_dma_h_M_AXI_MM2S_RREADY),
        .m_axi_mm2s_rresp(axi_dma_h_M_AXI_MM2S_RRESP),
        .m_axi_mm2s_rvalid(axi_dma_h_M_AXI_MM2S_RVALID),
        .m_axis_mm2s_tdata(axi_dma_h_M_AXIS_MM2S_TDATA),
        .m_axis_mm2s_tlast(axi_dma_h_M_AXIS_MM2S_TLAST),
        .m_axis_mm2s_tready(axi_dma_h_M_AXIS_MM2S_TREADY),
        .m_axis_mm2s_tvalid(axi_dma_h_M_AXIS_MM2S_TVALID),
        .s_axi_lite_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .s_axi_lite_araddr(smartconnect_ctrl_M01_AXI_ARADDR),
        .s_axi_lite_arready(smartconnect_ctrl_M01_AXI_ARREADY),
        .s_axi_lite_arvalid(smartconnect_ctrl_M01_AXI_ARVALID),
        .s_axi_lite_awaddr(smartconnect_ctrl_M01_AXI_AWADDR),
        .s_axi_lite_awready(smartconnect_ctrl_M01_AXI_AWREADY),
        .s_axi_lite_awvalid(smartconnect_ctrl_M01_AXI_AWVALID),
        .s_axi_lite_bready(smartconnect_ctrl_M01_AXI_BREADY),
        .s_axi_lite_bresp(smartconnect_ctrl_M01_AXI_BRESP),
        .s_axi_lite_bvalid(smartconnect_ctrl_M01_AXI_BVALID),
        .s_axi_lite_rdata(smartconnect_ctrl_M01_AXI_RDATA),
        .s_axi_lite_rready(smartconnect_ctrl_M01_AXI_RREADY),
        .s_axi_lite_rresp(smartconnect_ctrl_M01_AXI_RRESP),
        .s_axi_lite_rvalid(smartconnect_ctrl_M01_AXI_RVALID),
        .s_axi_lite_wdata(smartconnect_ctrl_M01_AXI_WDATA),
        .s_axi_lite_wready(smartconnect_ctrl_M01_AXI_WREADY),
        .s_axi_lite_wvalid(smartconnect_ctrl_M01_AXI_WVALID));
  design_1_proc_sys_reset_0_0 proc_sys_reset_0
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(zynq_ultra_ps_e_0_pl_resetn0),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(proc_sys_reset_0_peripheral_aresetn),
        .slowest_sync_clk(zynq_ultra_ps_e_0_pl_clk0));
  design_1_reuse_mamba_board_sh_0_1 reuse_mamba_board_sh_0
       (.ext_reset_n(proc_sys_reset_0_peripheral_aresetn),
        .m_axis_y_tdata(reuse_mamba_board_sh_0_m_axis_y_TDATA),
        .m_axis_y_tlast(reuse_mamba_board_sh_0_m_axis_y_TLAST),
        .m_axis_y_tready(reuse_mamba_board_sh_0_m_axis_y_TREADY),
        .m_axis_y_tvalid(reuse_mamba_board_sh_0_m_axis_y_TVALID),
        .s_axi_araddr(smartconnect_ctrl_M00_AXI_ARADDR),
        .s_axi_arready(smartconnect_ctrl_M00_AXI_ARREADY),
        .s_axi_arvalid(smartconnect_ctrl_M00_AXI_ARVALID),
        .s_axi_awaddr(smartconnect_ctrl_M00_AXI_AWADDR),
        .s_axi_awready(smartconnect_ctrl_M00_AXI_AWREADY),
        .s_axi_awvalid(smartconnect_ctrl_M00_AXI_AWVALID),
        .s_axi_bready(smartconnect_ctrl_M00_AXI_BREADY),
        .s_axi_bresp(smartconnect_ctrl_M00_AXI_BRESP),
        .s_axi_bvalid(smartconnect_ctrl_M00_AXI_BVALID),
        .s_axi_rdata(smartconnect_ctrl_M00_AXI_RDATA),
        .s_axi_rready(smartconnect_ctrl_M00_AXI_RREADY),
        .s_axi_rresp(smartconnect_ctrl_M00_AXI_RRESP),
        .s_axi_rvalid(smartconnect_ctrl_M00_AXI_RVALID),
        .s_axi_wdata(smartconnect_ctrl_M00_AXI_WDATA),
        .s_axi_wready(smartconnect_ctrl_M00_AXI_WREADY),
        .s_axi_wstrb(smartconnect_ctrl_M00_AXI_WSTRB),
        .s_axi_wvalid(smartconnect_ctrl_M00_AXI_WVALID),
        .s_axis_g_tdata(axi_dma_GY_M_AXIS_MM2S_TDATA),
        .s_axis_g_tlast(axi_dma_GY_M_AXIS_MM2S_TLAST),
        .s_axis_g_tready(axi_dma_GY_M_AXIS_MM2S_TREADY),
        .s_axis_g_tvalid(axi_dma_GY_M_AXIS_MM2S_TVALID),
        .s_axis_h_tdata(axi_dma_h_M_AXIS_MM2S_TDATA),
        .s_axis_h_tlast(axi_dma_h_M_AXIS_MM2S_TLAST),
        .s_axis_h_tready(axi_dma_h_M_AXIS_MM2S_TREADY),
        .s_axis_h_tvalid(axi_dma_h_M_AXIS_MM2S_TVALID),
        .sys_clk(zynq_ultra_ps_e_0_pl_clk0));
  design_1_smartconnect_0_0 smartconnect_ctrl
       (.M00_AXI_araddr(smartconnect_ctrl_M00_AXI_ARADDR),
        .M00_AXI_arready(smartconnect_ctrl_M00_AXI_ARREADY),
        .M00_AXI_arvalid(smartconnect_ctrl_M00_AXI_ARVALID),
        .M00_AXI_awaddr(smartconnect_ctrl_M00_AXI_AWADDR),
        .M00_AXI_awready(smartconnect_ctrl_M00_AXI_AWREADY),
        .M00_AXI_awvalid(smartconnect_ctrl_M00_AXI_AWVALID),
        .M00_AXI_bready(smartconnect_ctrl_M00_AXI_BREADY),
        .M00_AXI_bresp(smartconnect_ctrl_M00_AXI_BRESP),
        .M00_AXI_bvalid(smartconnect_ctrl_M00_AXI_BVALID),
        .M00_AXI_rdata(smartconnect_ctrl_M00_AXI_RDATA),
        .M00_AXI_rready(smartconnect_ctrl_M00_AXI_RREADY),
        .M00_AXI_rresp(smartconnect_ctrl_M00_AXI_RRESP),
        .M00_AXI_rvalid(smartconnect_ctrl_M00_AXI_RVALID),
        .M00_AXI_wdata(smartconnect_ctrl_M00_AXI_WDATA),
        .M00_AXI_wready(smartconnect_ctrl_M00_AXI_WREADY),
        .M00_AXI_wstrb(smartconnect_ctrl_M00_AXI_WSTRB),
        .M00_AXI_wvalid(smartconnect_ctrl_M00_AXI_WVALID),
        .M01_AXI_araddr(smartconnect_ctrl_M01_AXI_ARADDR),
        .M01_AXI_arready(smartconnect_ctrl_M01_AXI_ARREADY),
        .M01_AXI_arvalid(smartconnect_ctrl_M01_AXI_ARVALID),
        .M01_AXI_awaddr(smartconnect_ctrl_M01_AXI_AWADDR),
        .M01_AXI_awready(smartconnect_ctrl_M01_AXI_AWREADY),
        .M01_AXI_awvalid(smartconnect_ctrl_M01_AXI_AWVALID),
        .M01_AXI_bready(smartconnect_ctrl_M01_AXI_BREADY),
        .M01_AXI_bresp(smartconnect_ctrl_M01_AXI_BRESP),
        .M01_AXI_bvalid(smartconnect_ctrl_M01_AXI_BVALID),
        .M01_AXI_rdata(smartconnect_ctrl_M01_AXI_RDATA),
        .M01_AXI_rready(smartconnect_ctrl_M01_AXI_RREADY),
        .M01_AXI_rresp(smartconnect_ctrl_M01_AXI_RRESP),
        .M01_AXI_rvalid(smartconnect_ctrl_M01_AXI_RVALID),
        .M01_AXI_wdata(smartconnect_ctrl_M01_AXI_WDATA),
        .M01_AXI_wready(smartconnect_ctrl_M01_AXI_WREADY),
        .M01_AXI_wvalid(smartconnect_ctrl_M01_AXI_WVALID),
        .M02_AXI_araddr(smartconnect_ctrl_M02_AXI_ARADDR),
        .M02_AXI_arready(smartconnect_ctrl_M02_AXI_ARREADY),
        .M02_AXI_arvalid(smartconnect_ctrl_M02_AXI_ARVALID),
        .M02_AXI_awaddr(smartconnect_ctrl_M02_AXI_AWADDR),
        .M02_AXI_awready(smartconnect_ctrl_M02_AXI_AWREADY),
        .M02_AXI_awvalid(smartconnect_ctrl_M02_AXI_AWVALID),
        .M02_AXI_bready(smartconnect_ctrl_M02_AXI_BREADY),
        .M02_AXI_bresp(smartconnect_ctrl_M02_AXI_BRESP),
        .M02_AXI_bvalid(smartconnect_ctrl_M02_AXI_BVALID),
        .M02_AXI_rdata(smartconnect_ctrl_M02_AXI_RDATA),
        .M02_AXI_rready(smartconnect_ctrl_M02_AXI_RREADY),
        .M02_AXI_rresp(smartconnect_ctrl_M02_AXI_RRESP),
        .M02_AXI_rvalid(smartconnect_ctrl_M02_AXI_RVALID),
        .M02_AXI_wdata(smartconnect_ctrl_M02_AXI_WDATA),
        .M02_AXI_wready(smartconnect_ctrl_M02_AXI_WREADY),
        .M02_AXI_wvalid(smartconnect_ctrl_M02_AXI_WVALID),
        .S00_AXI_araddr(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARADDR),
        .S00_AXI_arburst(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARBURST),
        .S00_AXI_arcache(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARCACHE),
        .S00_AXI_arid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARID),
        .S00_AXI_arlen(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLEN),
        .S00_AXI_arlock(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLOCK),
        .S00_AXI_arprot(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARPROT),
        .S00_AXI_arqos(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARQOS),
        .S00_AXI_arready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARREADY),
        .S00_AXI_arsize(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARSIZE),
        .S00_AXI_aruser(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARUSER),
        .S00_AXI_arvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARVALID),
        .S00_AXI_awaddr(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWADDR),
        .S00_AXI_awburst(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWBURST),
        .S00_AXI_awcache(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWCACHE),
        .S00_AXI_awid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWID),
        .S00_AXI_awlen(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLEN),
        .S00_AXI_awlock(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLOCK),
        .S00_AXI_awprot(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWPROT),
        .S00_AXI_awqos(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWQOS),
        .S00_AXI_awready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWREADY),
        .S00_AXI_awsize(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWSIZE),
        .S00_AXI_awuser(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWUSER),
        .S00_AXI_awvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWVALID),
        .S00_AXI_bid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BID),
        .S00_AXI_bready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BREADY),
        .S00_AXI_bresp(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BRESP),
        .S00_AXI_bvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BVALID),
        .S00_AXI_rdata(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RDATA),
        .S00_AXI_rid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RID),
        .S00_AXI_rlast(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RLAST),
        .S00_AXI_rready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RREADY),
        .S00_AXI_rresp(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RRESP),
        .S00_AXI_rvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RVALID),
        .S00_AXI_wdata(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WDATA),
        .S00_AXI_wlast(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WLAST),
        .S00_AXI_wready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WREADY),
        .S00_AXI_wstrb(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WSTRB),
        .S00_AXI_wvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WVALID),
        .aclk(zynq_ultra_ps_e_0_pl_clk0),
        .aresetn(proc_sys_reset_0_peripheral_aresetn));
  design_1_smartconnect_0_1 smartconnect_mem
       (.M00_AXI_araddr(smartconnect_mem_M00_AXI_ARADDR),
        .M00_AXI_arburst(smartconnect_mem_M00_AXI_ARBURST),
        .M00_AXI_arcache(smartconnect_mem_M00_AXI_ARCACHE),
        .M00_AXI_arlen(smartconnect_mem_M00_AXI_ARLEN),
        .M00_AXI_arlock(smartconnect_mem_M00_AXI_ARLOCK),
        .M00_AXI_arprot(smartconnect_mem_M00_AXI_ARPROT),
        .M00_AXI_arqos(smartconnect_mem_M00_AXI_ARQOS),
        .M00_AXI_arready(smartconnect_mem_M00_AXI_ARREADY),
        .M00_AXI_arsize(smartconnect_mem_M00_AXI_ARSIZE),
        .M00_AXI_arvalid(smartconnect_mem_M00_AXI_ARVALID),
        .M00_AXI_awaddr(smartconnect_mem_M00_AXI_AWADDR),
        .M00_AXI_awburst(smartconnect_mem_M00_AXI_AWBURST),
        .M00_AXI_awcache(smartconnect_mem_M00_AXI_AWCACHE),
        .M00_AXI_awlen(smartconnect_mem_M00_AXI_AWLEN),
        .M00_AXI_awlock(smartconnect_mem_M00_AXI_AWLOCK),
        .M00_AXI_awprot(smartconnect_mem_M00_AXI_AWPROT),
        .M00_AXI_awqos(smartconnect_mem_M00_AXI_AWQOS),
        .M00_AXI_awready(smartconnect_mem_M00_AXI_AWREADY),
        .M00_AXI_awsize(smartconnect_mem_M00_AXI_AWSIZE),
        .M00_AXI_awvalid(smartconnect_mem_M00_AXI_AWVALID),
        .M00_AXI_bready(smartconnect_mem_M00_AXI_BREADY),
        .M00_AXI_bresp(smartconnect_mem_M00_AXI_BRESP),
        .M00_AXI_bvalid(smartconnect_mem_M00_AXI_BVALID),
        .M00_AXI_rdata(smartconnect_mem_M00_AXI_RDATA),
        .M00_AXI_rlast(smartconnect_mem_M00_AXI_RLAST),
        .M00_AXI_rready(smartconnect_mem_M00_AXI_RREADY),
        .M00_AXI_rresp(smartconnect_mem_M00_AXI_RRESP),
        .M00_AXI_rvalid(smartconnect_mem_M00_AXI_RVALID),
        .M00_AXI_wdata(smartconnect_mem_M00_AXI_WDATA),
        .M00_AXI_wlast(smartconnect_mem_M00_AXI_WLAST),
        .M00_AXI_wready(smartconnect_mem_M00_AXI_WREADY),
        .M00_AXI_wstrb(smartconnect_mem_M00_AXI_WSTRB),
        .M00_AXI_wvalid(smartconnect_mem_M00_AXI_WVALID),
        .S00_AXI_araddr(axi_dma_h_M_AXI_MM2S_ARADDR),
        .S00_AXI_arburst(axi_dma_h_M_AXI_MM2S_ARBURST),
        .S00_AXI_arcache(axi_dma_h_M_AXI_MM2S_ARCACHE),
        .S00_AXI_arlen(axi_dma_h_M_AXI_MM2S_ARLEN),
        .S00_AXI_arlock(1'b0),
        .S00_AXI_arprot(axi_dma_h_M_AXI_MM2S_ARPROT),
        .S00_AXI_arqos({1'b0,1'b0,1'b0,1'b0}),
        .S00_AXI_arready(axi_dma_h_M_AXI_MM2S_ARREADY),
        .S00_AXI_arsize(axi_dma_h_M_AXI_MM2S_ARSIZE),
        .S00_AXI_arvalid(axi_dma_h_M_AXI_MM2S_ARVALID),
        .S00_AXI_rdata(axi_dma_h_M_AXI_MM2S_RDATA),
        .S00_AXI_rlast(axi_dma_h_M_AXI_MM2S_RLAST),
        .S00_AXI_rready(axi_dma_h_M_AXI_MM2S_RREADY),
        .S00_AXI_rresp(axi_dma_h_M_AXI_MM2S_RRESP),
        .S00_AXI_rvalid(axi_dma_h_M_AXI_MM2S_RVALID),
        .S01_AXI_araddr(axi_dma_GY_M_AXI_MM2S_ARADDR),
        .S01_AXI_arburst(axi_dma_GY_M_AXI_MM2S_ARBURST),
        .S01_AXI_arcache(axi_dma_GY_M_AXI_MM2S_ARCACHE),
        .S01_AXI_arlen(axi_dma_GY_M_AXI_MM2S_ARLEN),
        .S01_AXI_arlock(1'b0),
        .S01_AXI_arprot(axi_dma_GY_M_AXI_MM2S_ARPROT),
        .S01_AXI_arqos({1'b0,1'b0,1'b0,1'b0}),
        .S01_AXI_arready(axi_dma_GY_M_AXI_MM2S_ARREADY),
        .S01_AXI_arsize(axi_dma_GY_M_AXI_MM2S_ARSIZE),
        .S01_AXI_arvalid(axi_dma_GY_M_AXI_MM2S_ARVALID),
        .S01_AXI_rdata(axi_dma_GY_M_AXI_MM2S_RDATA),
        .S01_AXI_rlast(axi_dma_GY_M_AXI_MM2S_RLAST),
        .S01_AXI_rready(axi_dma_GY_M_AXI_MM2S_RREADY),
        .S01_AXI_rresp(axi_dma_GY_M_AXI_MM2S_RRESP),
        .S01_AXI_rvalid(axi_dma_GY_M_AXI_MM2S_RVALID),
        .S02_AXI_awaddr(axi_dma_GY_M_AXI_S2MM_AWADDR),
        .S02_AXI_awburst(axi_dma_GY_M_AXI_S2MM_AWBURST),
        .S02_AXI_awcache(axi_dma_GY_M_AXI_S2MM_AWCACHE),
        .S02_AXI_awlen(axi_dma_GY_M_AXI_S2MM_AWLEN),
        .S02_AXI_awlock(1'b0),
        .S02_AXI_awprot(axi_dma_GY_M_AXI_S2MM_AWPROT),
        .S02_AXI_awqos({1'b0,1'b0,1'b0,1'b0}),
        .S02_AXI_awready(axi_dma_GY_M_AXI_S2MM_AWREADY),
        .S02_AXI_awsize(axi_dma_GY_M_AXI_S2MM_AWSIZE),
        .S02_AXI_awvalid(axi_dma_GY_M_AXI_S2MM_AWVALID),
        .S02_AXI_bready(axi_dma_GY_M_AXI_S2MM_BREADY),
        .S02_AXI_bresp(axi_dma_GY_M_AXI_S2MM_BRESP),
        .S02_AXI_bvalid(axi_dma_GY_M_AXI_S2MM_BVALID),
        .S02_AXI_wdata(axi_dma_GY_M_AXI_S2MM_WDATA),
        .S02_AXI_wlast(axi_dma_GY_M_AXI_S2MM_WLAST),
        .S02_AXI_wready(axi_dma_GY_M_AXI_S2MM_WREADY),
        .S02_AXI_wstrb(axi_dma_GY_M_AXI_S2MM_WSTRB),
        .S02_AXI_wvalid(axi_dma_GY_M_AXI_S2MM_WVALID),
        .aclk(zynq_ultra_ps_e_0_pl_clk0),
        .aresetn(proc_sys_reset_0_peripheral_aresetn));
  design_1_zynq_ultra_ps_e_0_0 zynq_ultra_ps_e_0
       (.maxigp0_araddr(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARADDR),
        .maxigp0_arburst(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARBURST),
        .maxigp0_arcache(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARCACHE),
        .maxigp0_arid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARID),
        .maxigp0_arlen(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLEN),
        .maxigp0_arlock(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLOCK),
        .maxigp0_arprot(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARPROT),
        .maxigp0_arqos(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARQOS),
        .maxigp0_arready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARREADY),
        .maxigp0_arsize(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARSIZE),
        .maxigp0_aruser(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARUSER),
        .maxigp0_arvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARVALID),
        .maxigp0_awaddr(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWADDR),
        .maxigp0_awburst(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWBURST),
        .maxigp0_awcache(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWCACHE),
        .maxigp0_awid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWID),
        .maxigp0_awlen(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLEN),
        .maxigp0_awlock(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLOCK),
        .maxigp0_awprot(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWPROT),
        .maxigp0_awqos(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWQOS),
        .maxigp0_awready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWREADY),
        .maxigp0_awsize(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWSIZE),
        .maxigp0_awuser(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWUSER),
        .maxigp0_awvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWVALID),
        .maxigp0_bid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BID),
        .maxigp0_bready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BREADY),
        .maxigp0_bresp(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BRESP),
        .maxigp0_bvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BVALID),
        .maxigp0_rdata(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RDATA),
        .maxigp0_rid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RID),
        .maxigp0_rlast(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RLAST),
        .maxigp0_rready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RREADY),
        .maxigp0_rresp(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RRESP),
        .maxigp0_rvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RVALID),
        .maxigp0_wdata(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WDATA),
        .maxigp0_wlast(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WLAST),
        .maxigp0_wready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WREADY),
        .maxigp0_wstrb(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WSTRB),
        .maxigp0_wvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WVALID),
        .maxihpm0_fpd_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .pl_clk0(zynq_ultra_ps_e_0_pl_clk0),
        .pl_ps_irq0(axi_dma_GY_s2mm_introut),
        .pl_resetn0(zynq_ultra_ps_e_0_pl_resetn0),
        .saxigp2_araddr(smartconnect_mem_M00_AXI_ARADDR),
        .saxigp2_arburst(smartconnect_mem_M00_AXI_ARBURST),
        .saxigp2_arcache(smartconnect_mem_M00_AXI_ARCACHE),
        .saxigp2_arid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp2_arlen(smartconnect_mem_M00_AXI_ARLEN),
        .saxigp2_arlock(smartconnect_mem_M00_AXI_ARLOCK),
        .saxigp2_arprot(smartconnect_mem_M00_AXI_ARPROT),
        .saxigp2_arqos(smartconnect_mem_M00_AXI_ARQOS),
        .saxigp2_arready(smartconnect_mem_M00_AXI_ARREADY),
        .saxigp2_arsize(smartconnect_mem_M00_AXI_ARSIZE),
        .saxigp2_aruser(1'b0),
        .saxigp2_arvalid(smartconnect_mem_M00_AXI_ARVALID),
        .saxigp2_awaddr(smartconnect_mem_M00_AXI_AWADDR),
        .saxigp2_awburst(smartconnect_mem_M00_AXI_AWBURST),
        .saxigp2_awcache(smartconnect_mem_M00_AXI_AWCACHE),
        .saxigp2_awid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp2_awlen(smartconnect_mem_M00_AXI_AWLEN),
        .saxigp2_awlock(smartconnect_mem_M00_AXI_AWLOCK),
        .saxigp2_awprot(smartconnect_mem_M00_AXI_AWPROT),
        .saxigp2_awqos(smartconnect_mem_M00_AXI_AWQOS),
        .saxigp2_awready(smartconnect_mem_M00_AXI_AWREADY),
        .saxigp2_awsize(smartconnect_mem_M00_AXI_AWSIZE),
        .saxigp2_awuser(1'b0),
        .saxigp2_awvalid(smartconnect_mem_M00_AXI_AWVALID),
        .saxigp2_bready(smartconnect_mem_M00_AXI_BREADY),
        .saxigp2_bresp(smartconnect_mem_M00_AXI_BRESP),
        .saxigp2_bvalid(smartconnect_mem_M00_AXI_BVALID),
        .saxigp2_rdata(smartconnect_mem_M00_AXI_RDATA),
        .saxigp2_rlast(smartconnect_mem_M00_AXI_RLAST),
        .saxigp2_rready(smartconnect_mem_M00_AXI_RREADY),
        .saxigp2_rresp(smartconnect_mem_M00_AXI_RRESP),
        .saxigp2_rvalid(smartconnect_mem_M00_AXI_RVALID),
        .saxigp2_wdata(smartconnect_mem_M00_AXI_WDATA),
        .saxigp2_wlast(smartconnect_mem_M00_AXI_WLAST),
        .saxigp2_wready(smartconnect_mem_M00_AXI_WREADY),
        .saxigp2_wstrb(smartconnect_mem_M00_AXI_WSTRB),
        .saxigp2_wvalid(smartconnect_mem_M00_AXI_WVALID),
        .saxihp0_fpd_aclk(zynq_ultra_ps_e_0_pl_clk0));
endmodule
