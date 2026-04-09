-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
-- Date        : Wed Apr  8 19:38:32 2026
-- Host        : 13600kf running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               e:/course/master/mamba/Cmamba_reconstruct/HW_reconstruct/project_mamba_all1/project_mamba_all1.gen/sources_1/bd/design_1/ip/design_1_reuse_mamba_board_sh_0_1/design_1_reuse_mamba_board_sh_0_1_stub.vhdl
-- Design      : design_1_reuse_mamba_board_sh_0_1
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xczu9eg-ffvb1156-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_1_reuse_mamba_board_sh_0_1 is
  Port ( 
    sys_clk : in STD_LOGIC;
    ext_reset_n : in STD_LOGIC;
    irq : out STD_LOGIC;
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 11 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_wvalid : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_araddr : in STD_LOGIC_VECTOR ( 11 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rvalid : out STD_LOGIC;
    s_axi_rready : in STD_LOGIC;
    s_axis_h_tvalid : in STD_LOGIC;
    s_axis_h_tready : out STD_LOGIC;
    s_axis_h_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    s_axis_h_tlast : in STD_LOGIC;
    s_axis_g_tvalid : in STD_LOGIC;
    s_axis_g_tready : out STD_LOGIC;
    s_axis_g_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    s_axis_g_tlast : in STD_LOGIC;
    m_axis_y_tvalid : out STD_LOGIC;
    m_axis_y_tready : in STD_LOGIC;
    m_axis_y_tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axis_y_tlast : out STD_LOGIC
  );

end design_1_reuse_mamba_board_sh_0_1;

architecture stub of design_1_reuse_mamba_board_sh_0_1 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "sys_clk,ext_reset_n,irq,s_axi_awaddr[11:0],s_axi_awvalid,s_axi_awready,s_axi_wdata[31:0],s_axi_wstrb[3:0],s_axi_wvalid,s_axi_wready,s_axi_bresp[1:0],s_axi_bvalid,s_axi_bready,s_axi_araddr[11:0],s_axi_arvalid,s_axi_arready,s_axi_rdata[31:0],s_axi_rresp[1:0],s_axi_rvalid,s_axi_rready,s_axis_h_tvalid,s_axis_h_tready,s_axis_h_tdata[63:0],s_axis_h_tlast,s_axis_g_tvalid,s_axis_g_tready,s_axis_g_tdata[63:0],s_axis_g_tlast,m_axis_y_tvalid,m_axis_y_tready,m_axis_y_tdata[63:0],m_axis_y_tlast";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "reuse_mamba_board_shell,Vivado 2024.1";
begin
end;
