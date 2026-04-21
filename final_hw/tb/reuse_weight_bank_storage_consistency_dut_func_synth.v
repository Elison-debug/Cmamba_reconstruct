// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Mon Apr 13 23:52:50 2026
// Host        : 13600kf running 64-bit major release  (build 9200)
// Command     : write_verilog -mode funcsim -force
//               E:/course/smamba/HW_reconstruct/tb/reuse_weight_bank_storage_consistency_dut_func_synth.v
// Design      : reuse_weight_bank_storage_consistency_dut
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module reuse_weight_bank_rom
   (DOUTADOUT,
    DOUTBDOUT,
    clk_IBUF_BUFG,
    rom_en_a_IBUF,
    rom_en_b_IBUF,
    ADDRARDADDR,
    ADDRBWRADDR);
  output [3:0]DOUTADOUT;
  output [3:0]DOUTBDOUT;
  input clk_IBUF_BUFG;
  input rom_en_a_IBUF;
  input rom_en_b_IBUF;
  input [2:0]ADDRARDADDR;
  input [2:0]ADDRBWRADDR;

  wire [2:0]ADDRARDADDR;
  wire [2:0]ADDRBWRADDR;
  wire [3:0]DOUTADOUT;
  wire [3:0]DOUTBDOUT;
  wire clk_IBUF_BUFG;
  wire rom_en_a_IBUF;
  wire rom_en_b_IBUF;
  wire [15:0]NLW_dout_a_reg_CASDOUTA_UNCONNECTED;
  wire [15:0]NLW_dout_a_reg_CASDOUTB_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_CASDOUTPA_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_CASDOUTPB_UNCONNECTED;
  wire [15:4]NLW_dout_a_reg_DOUTADOUT_UNCONNECTED;
  wire [15:4]NLW_dout_a_reg_DOUTBDOUT_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_DOUTPADOUTP_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_DOUTPBDOUTP_UNCONNECTED;

  (* \MEM.PORTA.DATA_BIT_LAYOUT  = "p0_d4" *) 
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-6 {cell *THIS*}}" *) 
  (* OPT_MODIFIED = "MLO" *) 
  (* RDADDR_COLLISION_HWCONFIG = "PERFORMANCE" *) 
  (* RTL_RAM_BITS = "32" *) 
  (* RTL_RAM_NAME = "u_rom/dout_a_reg" *) 
  (* RTL_RAM_TYPE = "RAM_SP" *) 
  (* ram_addr_begin = "0" *) 
  (* ram_addr_end = "1023" *) 
  (* ram_offset = "0" *) 
  (* ram_slice_begin = "0" *) 
  (* ram_slice_end = "3" *) 
  RAMB18E2 #(
    .CASCADE_ORDER_A("NONE"),
    .CASCADE_ORDER_B("NONE"),
    .CLOCK_DOMAINS("COMMON"),
    .DOA_REG(0),
    .DOB_REG(0),
    .ENADDRENA("FALSE"),
    .ENADDRENB("FALSE"),
    .INITP_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_00(256'h0000000000000000000000000000000000070006000500040003000200010000),
    .INIT_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_10(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_11(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_12(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_13(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_14(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_15(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_16(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_17(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_18(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_19(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_20(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_21(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_22(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_23(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_24(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_25(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_26(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_27(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_28(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_29(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_30(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_31(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_32(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_33(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_34(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_35(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_36(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_37(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_38(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_39(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_A(18'h00000),
    .INIT_B(18'h00000),
    .INIT_FILE("NONE"),
    .RDADDRCHANGEA("FALSE"),
    .RDADDRCHANGEB("FALSE"),
    .READ_WIDTH_A(18),
    .READ_WIDTH_B(18),
    .RSTREG_PRIORITY_A("RSTREG"),
    .RSTREG_PRIORITY_B("RSTREG"),
    .SIM_COLLISION_CHECK("ALL"),
    .SLEEP_ASYNC("FALSE"),
    .SRVAL_A(18'h00000),
    .SRVAL_B(18'h00000),
    .WRITE_MODE_A("WRITE_FIRST"),
    .WRITE_MODE_B("WRITE_FIRST"),
    .WRITE_WIDTH_A(18),
    .WRITE_WIDTH_B(0)) 
    dout_a_reg
       (.ADDRARDADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,ADDRARDADDR,1'b0,1'b0,1'b0,1'b0}),
        .ADDRBWRADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,ADDRBWRADDR,1'b0,1'b0,1'b0,1'b0}),
        .ADDRENA(1'b1),
        .ADDRENB(1'b1),
        .CASDIMUXA(1'b0),
        .CASDIMUXB(1'b0),
        .CASDINA({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .CASDINB({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .CASDINPA({1'b0,1'b0}),
        .CASDINPB({1'b0,1'b0}),
        .CASDOMUXA(1'b0),
        .CASDOMUXB(1'b0),
        .CASDOMUXEN_A(1'b1),
        .CASDOMUXEN_B(1'b1),
        .CASDOUTA(NLW_dout_a_reg_CASDOUTA_UNCONNECTED[15:0]),
        .CASDOUTB(NLW_dout_a_reg_CASDOUTB_UNCONNECTED[15:0]),
        .CASDOUTPA(NLW_dout_a_reg_CASDOUTPA_UNCONNECTED[1:0]),
        .CASDOUTPB(NLW_dout_a_reg_CASDOUTPB_UNCONNECTED[1:0]),
        .CASOREGIMUXA(1'b0),
        .CASOREGIMUXB(1'b0),
        .CASOREGIMUXEN_A(1'b1),
        .CASOREGIMUXEN_B(1'b1),
        .CLKARDCLK(clk_IBUF_BUFG),
        .CLKBWRCLK(clk_IBUF_BUFG),
        .DINADIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b1,1'b1,1'b1}),
        .DINBDIN({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .DINPADINP({1'b0,1'b0}),
        .DINPBDINP({1'b1,1'b1}),
        .DOUTADOUT({NLW_dout_a_reg_DOUTADOUT_UNCONNECTED[15:4],DOUTADOUT}),
        .DOUTBDOUT({NLW_dout_a_reg_DOUTBDOUT_UNCONNECTED[15:4],DOUTBDOUT}),
        .DOUTPADOUTP(NLW_dout_a_reg_DOUTPADOUTP_UNCONNECTED[1:0]),
        .DOUTPBDOUTP(NLW_dout_a_reg_DOUTPBDOUTP_UNCONNECTED[1:0]),
        .ENARDEN(rom_en_a_IBUF),
        .ENBWREN(rom_en_b_IBUF),
        .REGCEAREGCE(1'b1),
        .REGCEB(1'b1),
        .RSTRAMARSTRAM(1'b0),
        .RSTRAMB(1'b0),
        .RSTREGARSTREG(1'b0),
        .RSTREGB(1'b0),
        .SLEEP(1'b0),
        .WEA({1'b0,1'b0}),
        .WEBWE({1'b0,1'b0,1'b0,1'b0}));
endmodule

(* ORIG_REF_NAME = "reuse_weight_bank_rom" *) 
module reuse_weight_bank_rom_0
   (DOUTADOUT,
    DOUTBDOUT,
    \slim_dout_sel[3]_OBUF ,
    \slim_dout_sel[2]_OBUF ,
    \slim_dout_sel[1]_OBUF ,
    \slim_dout_sel[0]_OBUF ,
    clk_IBUF_BUFG,
    D,
    slim_port_sel_IBUF,
    slim_en_sel_IBUF,
    dout_a_reg_0,
    dout_a_reg_1,
    dout_a_reg_2,
    dout_a_reg_3,
    dout_a_reg_4,
    dout_a_reg_5,
    dout_a_reg_6,
    dout_a_reg_7,
    dout_a_reg_8,
    dout_a_reg_9,
    dout_a_reg_10,
    dout_a_reg_11,
    dout_a_reg_12,
    dout_a_reg_13,
    dout_a_reg_14,
    Q,
    \slim_dout_sel[3][29] ,
    \slim_dout_sel[3][29]_0 ,
    \slim_dout_sel[3][29]_1 ,
    \slim_dout_sel[0][31]_INST_0_i_1_0 ,
    \slim_dout_sel[0][31]_INST_0_i_1_1 ,
    \slim_dout_sel[0][31]_INST_0_i_1_2 ,
    \slim_dout_sel[0][31]_INST_0_i_1_3 ,
    \slim_dout_sel[0][31]_INST_0_i_1_4 ,
    \slim_dout_sel[0][31]_INST_0_i_1_5 ,
    \slim_dout_sel[0][30]_INST_0_i_1_0 ,
    \slim_dout_sel[0][30]_INST_0_i_1_1 ,
    \slim_dout_sel[0][30]_INST_0_i_1_2 ,
    \slim_dout_sel[0][30]_INST_0_i_1_3 ,
    \slim_dout_sel[2][29] ,
    \slim_dout_sel[2][29]_0 ,
    \slim_dout_sel[1][29] ,
    \slim_dout_sel[1][29]_0 ,
    \slim_dout_sel[0][29] ,
    \slim_dout_sel[0][29]_0 );
  output [3:0]DOUTADOUT;
  output [3:0]DOUTBDOUT;
  output [2:0]\slim_dout_sel[3]_OBUF ;
  output [2:0]\slim_dout_sel[2]_OBUF ;
  output [2:0]\slim_dout_sel[1]_OBUF ;
  output [2:0]\slim_dout_sel[0]_OBUF ;
  input clk_IBUF_BUFG;
  input [2:0]D;
  input [3:0]slim_port_sel_IBUF;
  input [3:0]slim_en_sel_IBUF;
  input dout_a_reg_0;
  input dout_a_reg_1;
  input dout_a_reg_2;
  input dout_a_reg_3;
  input dout_a_reg_4;
  input dout_a_reg_5;
  input dout_a_reg_6;
  input dout_a_reg_7;
  input dout_a_reg_8;
  input dout_a_reg_9;
  input dout_a_reg_10;
  input dout_a_reg_11;
  input [2:0]dout_a_reg_12;
  input [2:0]dout_a_reg_13;
  input [2:0]dout_a_reg_14;
  input [3:0]Q;
  input \slim_dout_sel[3][29] ;
  input [2:0]\slim_dout_sel[3][29]_0 ;
  input [3:0]\slim_dout_sel[3][29]_1 ;
  input [0:0]\slim_dout_sel[0][31]_INST_0_i_1_0 ;
  input [1:0]\slim_dout_sel[0][31]_INST_0_i_1_1 ;
  input [1:0]\slim_dout_sel[0][31]_INST_0_i_1_2 ;
  input [0:0]\slim_dout_sel[0][31]_INST_0_i_1_3 ;
  input [1:0]\slim_dout_sel[0][31]_INST_0_i_1_4 ;
  input [1:0]\slim_dout_sel[0][31]_INST_0_i_1_5 ;
  input [0:0]\slim_dout_sel[0][30]_INST_0_i_1_0 ;
  input [0:0]\slim_dout_sel[0][30]_INST_0_i_1_1 ;
  input [0:0]\slim_dout_sel[0][30]_INST_0_i_1_2 ;
  input [0:0]\slim_dout_sel[0][30]_INST_0_i_1_3 ;
  input \slim_dout_sel[2][29] ;
  input [2:0]\slim_dout_sel[2][29]_0 ;
  input \slim_dout_sel[1][29] ;
  input [2:0]\slim_dout_sel[1][29]_0 ;
  input \slim_dout_sel[0][29] ;
  input [2:0]\slim_dout_sel[0][29]_0 ;

  wire [2:0]D;
  wire [3:0]DOUTADOUT;
  wire [3:0]DOUTBDOUT;
  wire [3:0]Q;
  wire [2:0]\addrA_bank[0]_4 ;
  wire [2:0]\addrB_bank[0]_15 ;
  wire clk_IBUF_BUFG;
  wire [30:30]doutA_bank__29;
  wire [30:30]doutB_bank__29;
  wire dout_a_reg_0;
  wire dout_a_reg_1;
  wire dout_a_reg_10;
  wire dout_a_reg_11;
  wire [2:0]dout_a_reg_12;
  wire [2:0]dout_a_reg_13;
  wire [2:0]dout_a_reg_14;
  wire dout_a_reg_2;
  wire dout_a_reg_3;
  wire dout_a_reg_4;
  wire dout_a_reg_5;
  wire dout_a_reg_6;
  wire dout_a_reg_7;
  wire dout_a_reg_8;
  wire dout_a_reg_9;
  wire dout_a_reg_i_10__1_n_0;
  wire dout_a_reg_i_11_n_0;
  wire dout_a_reg_i_12_n_0;
  wire dout_a_reg_i_13__4_n_0;
  wire dout_a_reg_i_14__3_n_0;
  wire dout_a_reg_i_15__3_n_0;
  wire dout_a_reg_i_16__4_n_0;
  wire dout_a_reg_i_19_n_0;
  wire dout_a_reg_i_22_n_0;
  wire dout_a_reg_i_25_n_0;
  wire dout_a_reg_i_26_n_0;
  wire dout_a_reg_i_27_n_0;
  wire dout_a_reg_i_28_n_0;
  wire dout_a_reg_i_9__4_n_0;
  wire [0:0]enA_bank;
  wire [0:0]enB_bank;
  wire \slim_dout_sel[0][29] ;
  wire [2:0]\slim_dout_sel[0][29]_0 ;
  wire \slim_dout_sel[0][29]_INST_0_i_2_n_0 ;
  wire \slim_dout_sel[0][29]_INST_0_i_3_n_0 ;
  wire [0:0]\slim_dout_sel[0][30]_INST_0_i_1_0 ;
  wire [0:0]\slim_dout_sel[0][30]_INST_0_i_1_1 ;
  wire [0:0]\slim_dout_sel[0][30]_INST_0_i_1_2 ;
  wire [0:0]\slim_dout_sel[0][30]_INST_0_i_1_3 ;
  wire \slim_dout_sel[0][30]_INST_0_i_2_n_0 ;
  wire \slim_dout_sel[0][30]_INST_0_i_3_n_0 ;
  wire [0:0]\slim_dout_sel[0][31]_INST_0_i_1_0 ;
  wire [1:0]\slim_dout_sel[0][31]_INST_0_i_1_1 ;
  wire [1:0]\slim_dout_sel[0][31]_INST_0_i_1_2 ;
  wire [0:0]\slim_dout_sel[0][31]_INST_0_i_1_3 ;
  wire [1:0]\slim_dout_sel[0][31]_INST_0_i_1_4 ;
  wire [1:0]\slim_dout_sel[0][31]_INST_0_i_1_5 ;
  wire \slim_dout_sel[0][31]_INST_0_i_3_n_0 ;
  wire \slim_dout_sel[0][31]_INST_0_i_4_n_0 ;
  wire [2:0]\slim_dout_sel[0]_OBUF ;
  wire \slim_dout_sel[1][29] ;
  wire [2:0]\slim_dout_sel[1][29]_0 ;
  wire \slim_dout_sel[1][29]_INST_0_i_2_n_0 ;
  wire \slim_dout_sel[1][29]_INST_0_i_3_n_0 ;
  wire \slim_dout_sel[1][30]_INST_0_i_2_n_0 ;
  wire \slim_dout_sel[1][30]_INST_0_i_3_n_0 ;
  wire \slim_dout_sel[1][31]_INST_0_i_3_n_0 ;
  wire \slim_dout_sel[1][31]_INST_0_i_4_n_0 ;
  wire [2:0]\slim_dout_sel[1]_OBUF ;
  wire \slim_dout_sel[2][29] ;
  wire [2:0]\slim_dout_sel[2][29]_0 ;
  wire \slim_dout_sel[2][29]_INST_0_i_2_n_0 ;
  wire \slim_dout_sel[2][29]_INST_0_i_3_n_0 ;
  wire \slim_dout_sel[2][30]_INST_0_i_2_n_0 ;
  wire \slim_dout_sel[2][30]_INST_0_i_3_n_0 ;
  wire \slim_dout_sel[2][31]_INST_0_i_3_n_0 ;
  wire \slim_dout_sel[2][31]_INST_0_i_4_n_0 ;
  wire [2:0]\slim_dout_sel[2]_OBUF ;
  wire \slim_dout_sel[3][29] ;
  wire [2:0]\slim_dout_sel[3][29]_0 ;
  wire [3:0]\slim_dout_sel[3][29]_1 ;
  wire \slim_dout_sel[3][29]_INST_0_i_2_n_0 ;
  wire \slim_dout_sel[3][29]_INST_0_i_3_n_0 ;
  wire \slim_dout_sel[3][31]_INST_0_i_3_n_0 ;
  wire \slim_dout_sel[3][31]_INST_0_i_4_n_0 ;
  wire [2:0]\slim_dout_sel[3]_OBUF ;
  wire [3:0]slim_en_sel_IBUF;
  wire [3:0]slim_port_sel_IBUF;
  wire [15:0]NLW_dout_a_reg_CASDOUTA_UNCONNECTED;
  wire [15:0]NLW_dout_a_reg_CASDOUTB_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_CASDOUTPA_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_CASDOUTPB_UNCONNECTED;
  wire [15:4]NLW_dout_a_reg_DOUTADOUT_UNCONNECTED;
  wire [15:4]NLW_dout_a_reg_DOUTBDOUT_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_DOUTPADOUTP_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_DOUTPBDOUTP_UNCONNECTED;

  (* \MEM.PORTA.DATA_BIT_LAYOUT  = "p0_d4" *) 
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-6 {cell *THIS*}}" *) 
  (* OPT_MODIFIED = "MLO" *) 
  (* RDADDR_COLLISION_HWCONFIG = "PERFORMANCE" *) 
  (* RTL_RAM_BITS = "32" *) 
  (* RTL_RAM_NAME = "u_wbuf/WBUF_BANK[0].g_bank0.u_bank/dout_a_reg" *) 
  (* RTL_RAM_TYPE = "RAM_SP" *) 
  (* ram_addr_begin = "0" *) 
  (* ram_addr_end = "1023" *) 
  (* ram_offset = "0" *) 
  (* ram_slice_begin = "0" *) 
  (* ram_slice_end = "3" *) 
  RAMB18E2 #(
    .CASCADE_ORDER_A("NONE"),
    .CASCADE_ORDER_B("NONE"),
    .CLOCK_DOMAINS("COMMON"),
    .DOA_REG(0),
    .DOB_REG(0),
    .ENADDRENA("FALSE"),
    .ENADDRENB("FALSE"),
    .INITP_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_00(256'h0000000000000000000000000000000000070006000500040003000200010000),
    .INIT_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_10(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_11(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_12(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_13(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_14(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_15(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_16(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_17(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_18(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_19(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_20(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_21(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_22(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_23(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_24(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_25(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_26(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_27(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_28(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_29(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_30(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_31(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_32(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_33(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_34(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_35(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_36(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_37(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_38(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_39(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_A(18'h00000),
    .INIT_B(18'h00000),
    .INIT_FILE("NONE"),
    .RDADDRCHANGEA("FALSE"),
    .RDADDRCHANGEB("FALSE"),
    .READ_WIDTH_A(18),
    .READ_WIDTH_B(18),
    .RSTREG_PRIORITY_A("RSTREG"),
    .RSTREG_PRIORITY_B("RSTREG"),
    .SIM_COLLISION_CHECK("ALL"),
    .SLEEP_ASYNC("FALSE"),
    .SRVAL_A(18'h00000),
    .SRVAL_B(18'h00000),
    .WRITE_MODE_A("WRITE_FIRST"),
    .WRITE_MODE_B("WRITE_FIRST"),
    .WRITE_WIDTH_A(18),
    .WRITE_WIDTH_B(0)) 
    dout_a_reg
       (.ADDRARDADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\addrA_bank[0]_4 ,1'b0,1'b0,1'b0,1'b0}),
        .ADDRBWRADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\addrB_bank[0]_15 ,1'b0,1'b0,1'b0,1'b0}),
        .ADDRENA(1'b1),
        .ADDRENB(1'b1),
        .CASDIMUXA(1'b0),
        .CASDIMUXB(1'b0),
        .CASDINA({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .CASDINB({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .CASDINPA({1'b0,1'b0}),
        .CASDINPB({1'b0,1'b0}),
        .CASDOMUXA(1'b0),
        .CASDOMUXB(1'b0),
        .CASDOMUXEN_A(1'b1),
        .CASDOMUXEN_B(1'b1),
        .CASDOUTA(NLW_dout_a_reg_CASDOUTA_UNCONNECTED[15:0]),
        .CASDOUTB(NLW_dout_a_reg_CASDOUTB_UNCONNECTED[15:0]),
        .CASDOUTPA(NLW_dout_a_reg_CASDOUTPA_UNCONNECTED[1:0]),
        .CASDOUTPB(NLW_dout_a_reg_CASDOUTPB_UNCONNECTED[1:0]),
        .CASOREGIMUXA(1'b0),
        .CASOREGIMUXB(1'b0),
        .CASOREGIMUXEN_A(1'b1),
        .CASOREGIMUXEN_B(1'b1),
        .CLKARDCLK(clk_IBUF_BUFG),
        .CLKBWRCLK(clk_IBUF_BUFG),
        .DINADIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b1,1'b1,1'b1}),
        .DINBDIN({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .DINPADINP({1'b0,1'b0}),
        .DINPBDINP({1'b1,1'b1}),
        .DOUTADOUT({NLW_dout_a_reg_DOUTADOUT_UNCONNECTED[15:4],DOUTADOUT}),
        .DOUTBDOUT({NLW_dout_a_reg_DOUTBDOUT_UNCONNECTED[15:4],DOUTBDOUT}),
        .DOUTPADOUTP(NLW_dout_a_reg_DOUTPADOUTP_UNCONNECTED[1:0]),
        .DOUTPBDOUTP(NLW_dout_a_reg_DOUTPBDOUTP_UNCONNECTED[1:0]),
        .ENARDEN(enA_bank),
        .ENBWREN(enB_bank),
        .REGCEAREGCE(1'b1),
        .REGCEB(1'b1),
        .RSTRAMARSTRAM(1'b0),
        .RSTRAMB(1'b0),
        .RSTREGARSTREG(1'b0),
        .RSTREGB(1'b0),
        .SLEEP(1'b0),
        .WEA({1'b0,1'b0}),
        .WEBWE({1'b0,1'b0,1'b0,1'b0}));
  LUT4 #(
    .INIT(16'hFF7F)) 
    dout_a_reg_i_1
       (.I0(dout_a_reg_i_9__4_n_0),
        .I1(dout_a_reg_i_10__1_n_0),
        .I2(dout_a_reg_i_11_n_0),
        .I3(dout_a_reg_i_12_n_0),
        .O(enA_bank));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'hFFFFFFFD)) 
    dout_a_reg_i_10__1
       (.I0(slim_en_sel_IBUF[0]),
        .I1(slim_port_sel_IBUF[0]),
        .I2(dout_a_reg_14[2]),
        .I3(dout_a_reg_14[1]),
        .I4(dout_a_reg_14[0]),
        .O(dout_a_reg_i_10__1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'hFFFFFFFD)) 
    dout_a_reg_i_11
       (.I0(slim_en_sel_IBUF[1]),
        .I1(slim_port_sel_IBUF[1]),
        .I2(dout_a_reg_12[2]),
        .I3(dout_a_reg_12[1]),
        .I4(dout_a_reg_12[0]),
        .O(dout_a_reg_i_11_n_0));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h00000004)) 
    dout_a_reg_i_12
       (.I0(slim_port_sel_IBUF[3]),
        .I1(slim_en_sel_IBUF[3]),
        .I2(dout_a_reg_13[2]),
        .I3(dout_a_reg_13[1]),
        .I4(dout_a_reg_13[0]),
        .O(dout_a_reg_i_12_n_0));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'hFEFFFFFF)) 
    dout_a_reg_i_13__4
       (.I0(D[2]),
        .I1(D[1]),
        .I2(D[0]),
        .I3(slim_en_sel_IBUF[2]),
        .I4(slim_port_sel_IBUF[2]),
        .O(dout_a_reg_i_13__4_n_0));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'hFEFFFFFF)) 
    dout_a_reg_i_14__3
       (.I0(dout_a_reg_14[2]),
        .I1(dout_a_reg_14[1]),
        .I2(dout_a_reg_14[0]),
        .I3(slim_port_sel_IBUF[0]),
        .I4(slim_en_sel_IBUF[0]),
        .O(dout_a_reg_i_14__3_n_0));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'hFEFFFFFF)) 
    dout_a_reg_i_15__3
       (.I0(dout_a_reg_12[2]),
        .I1(dout_a_reg_12[1]),
        .I2(dout_a_reg_12[0]),
        .I3(slim_en_sel_IBUF[1]),
        .I4(slim_port_sel_IBUF[1]),
        .O(dout_a_reg_i_15__3_n_0));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h01000000)) 
    dout_a_reg_i_16__4
       (.I0(dout_a_reg_13[2]),
        .I1(dout_a_reg_13[1]),
        .I2(dout_a_reg_13[0]),
        .I3(slim_en_sel_IBUF[3]),
        .I4(slim_port_sel_IBUF[3]),
        .O(dout_a_reg_i_16__4_n_0));
  LUT5 #(
    .INIT(32'h44F0FFFF)) 
    dout_a_reg_i_19
       (.I0(dout_a_reg_i_10__1_n_0),
        .I1(dout_a_reg_10),
        .I2(dout_a_reg_11),
        .I3(dout_a_reg_i_11_n_0),
        .I4(dout_a_reg_i_9__4_n_0),
        .O(dout_a_reg_i_19_n_0));
  LUT5 #(
    .INIT(32'h44F0FFFF)) 
    dout_a_reg_i_22
       (.I0(dout_a_reg_i_10__1_n_0),
        .I1(dout_a_reg_6),
        .I2(dout_a_reg_7),
        .I3(dout_a_reg_i_11_n_0),
        .I4(dout_a_reg_i_9__4_n_0),
        .O(dout_a_reg_i_22_n_0));
  LUT5 #(
    .INIT(32'h44F0FFFF)) 
    dout_a_reg_i_25
       (.I0(dout_a_reg_i_10__1_n_0),
        .I1(dout_a_reg_2),
        .I2(dout_a_reg_3),
        .I3(dout_a_reg_i_11_n_0),
        .I4(dout_a_reg_i_9__4_n_0),
        .O(dout_a_reg_i_25_n_0));
  LUT5 #(
    .INIT(32'h4F4FFF0F)) 
    dout_a_reg_i_26
       (.I0(dout_a_reg_i_14__3_n_0),
        .I1(dout_a_reg_10),
        .I2(dout_a_reg_i_13__4_n_0),
        .I3(dout_a_reg_11),
        .I4(dout_a_reg_i_15__3_n_0),
        .O(dout_a_reg_i_26_n_0));
  LUT5 #(
    .INIT(32'h4F4FFF0F)) 
    dout_a_reg_i_27
       (.I0(dout_a_reg_i_14__3_n_0),
        .I1(dout_a_reg_6),
        .I2(dout_a_reg_i_13__4_n_0),
        .I3(dout_a_reg_7),
        .I4(dout_a_reg_i_15__3_n_0),
        .O(dout_a_reg_i_27_n_0));
  LUT5 #(
    .INIT(32'h4F4FFF0F)) 
    dout_a_reg_i_28
       (.I0(dout_a_reg_i_14__3_n_0),
        .I1(dout_a_reg_2),
        .I2(dout_a_reg_i_13__4_n_0),
        .I3(dout_a_reg_3),
        .I4(dout_a_reg_i_15__3_n_0),
        .O(dout_a_reg_i_28_n_0));
  LUT4 #(
    .INIT(16'hFF7F)) 
    dout_a_reg_i_2__4
       (.I0(dout_a_reg_i_13__4_n_0),
        .I1(dout_a_reg_i_14__3_n_0),
        .I2(dout_a_reg_i_15__3_n_0),
        .I3(dout_a_reg_i_16__4_n_0),
        .O(enB_bank));
  LUT5 #(
    .INIT(32'hBBB88888)) 
    dout_a_reg_i_3
       (.I0(dout_a_reg_8),
        .I1(dout_a_reg_i_12_n_0),
        .I2(dout_a_reg_i_9__4_n_0),
        .I3(dout_a_reg_9),
        .I4(dout_a_reg_i_19_n_0),
        .O(\addrA_bank[0]_4 [2]));
  LUT5 #(
    .INIT(32'hBBB88888)) 
    dout_a_reg_i_4
       (.I0(dout_a_reg_4),
        .I1(dout_a_reg_i_12_n_0),
        .I2(dout_a_reg_i_9__4_n_0),
        .I3(dout_a_reg_5),
        .I4(dout_a_reg_i_22_n_0),
        .O(\addrA_bank[0]_4 [1]));
  LUT5 #(
    .INIT(32'hBBB88888)) 
    dout_a_reg_i_5
       (.I0(dout_a_reg_0),
        .I1(dout_a_reg_i_12_n_0),
        .I2(dout_a_reg_i_9__4_n_0),
        .I3(dout_a_reg_1),
        .I4(dout_a_reg_i_25_n_0),
        .O(\addrA_bank[0]_4 [0]));
  LUT5 #(
    .INIT(32'hBBB88888)) 
    dout_a_reg_i_6__4
       (.I0(dout_a_reg_8),
        .I1(dout_a_reg_i_16__4_n_0),
        .I2(dout_a_reg_i_13__4_n_0),
        .I3(dout_a_reg_9),
        .I4(dout_a_reg_i_26_n_0),
        .O(\addrB_bank[0]_15 [2]));
  LUT5 #(
    .INIT(32'hBBB88888)) 
    dout_a_reg_i_7__4
       (.I0(dout_a_reg_4),
        .I1(dout_a_reg_i_16__4_n_0),
        .I2(dout_a_reg_i_13__4_n_0),
        .I3(dout_a_reg_5),
        .I4(dout_a_reg_i_27_n_0),
        .O(\addrB_bank[0]_15 [1]));
  LUT5 #(
    .INIT(32'hBBB88888)) 
    dout_a_reg_i_8__4
       (.I0(dout_a_reg_0),
        .I1(dout_a_reg_i_16__4_n_0),
        .I2(dout_a_reg_i_13__4_n_0),
        .I3(dout_a_reg_1),
        .I4(dout_a_reg_i_28_n_0),
        .O(\addrB_bank[0]_15 [0]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'hFFFEFFFF)) 
    dout_a_reg_i_9__4
       (.I0(D[2]),
        .I1(D[1]),
        .I2(D[0]),
        .I3(slim_port_sel_IBUF[2]),
        .I4(slim_en_sel_IBUF[2]),
        .O(dout_a_reg_i_9__4_n_0));
  LUT6 #(
    .INIT(64'h8A808A808A8A8080)) 
    \slim_dout_sel[0][29]_INST_0_i_1 
       (.I0(Q[0]),
        .I1(\slim_dout_sel[0][29] ),
        .I2(\slim_dout_sel[0][29]_0 [2]),
        .I3(\slim_dout_sel[0][29]_INST_0_i_2_n_0 ),
        .I4(\slim_dout_sel[0][29]_INST_0_i_3_n_0 ),
        .I5(\slim_dout_sel[3][29]_1 [0]),
        .O(\slim_dout_sel[0]_OBUF [1]));
  LUT6 #(
    .INIT(64'hFF00CCCCF0F0AAAA)) 
    \slim_dout_sel[0][29]_INST_0_i_2 
       (.I0(DOUTBDOUT[3]),
        .I1(\slim_dout_sel[0][31]_INST_0_i_1_0 ),
        .I2(\slim_dout_sel[0][31]_INST_0_i_1_1 [0]),
        .I3(\slim_dout_sel[0][31]_INST_0_i_1_2 [0]),
        .I4(\slim_dout_sel[0][29]_0 [1]),
        .I5(\slim_dout_sel[0][29]_0 [0]),
        .O(\slim_dout_sel[0][29]_INST_0_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFF00CCCCF0F0AAAA)) 
    \slim_dout_sel[0][29]_INST_0_i_3 
       (.I0(DOUTADOUT[3]),
        .I1(\slim_dout_sel[0][31]_INST_0_i_1_3 ),
        .I2(\slim_dout_sel[0][31]_INST_0_i_1_4 [0]),
        .I3(\slim_dout_sel[0][31]_INST_0_i_1_5 [0]),
        .I4(\slim_dout_sel[0][29]_0 [1]),
        .I5(\slim_dout_sel[0][29]_0 [0]),
        .O(\slim_dout_sel[0][29]_INST_0_i_3_n_0 ));
  LUT4 #(
    .INIT(16'hA0C0)) 
    \slim_dout_sel[0][30]_INST_0_i_1 
       (.I0(\slim_dout_sel[0][30]_INST_0_i_2_n_0 ),
        .I1(\slim_dout_sel[0][30]_INST_0_i_3_n_0 ),
        .I2(Q[0]),
        .I3(\slim_dout_sel[3][29]_1 [0]),
        .O(\slim_dout_sel[0]_OBUF [2]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[0][30]_INST_0_i_2 
       (.I0(\slim_dout_sel[0][31]_INST_0_i_3_n_0 ),
        .I1(\slim_dout_sel[0][30]_INST_0_i_1_0 ),
        .I2(\slim_dout_sel[0][30]_INST_0_i_1_1 ),
        .I3(\slim_dout_sel[0][29]_0 [2]),
        .I4(\slim_dout_sel[0][29]_0 [0]),
        .O(\slim_dout_sel[0][30]_INST_0_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[0][30]_INST_0_i_3 
       (.I0(\slim_dout_sel[0][31]_INST_0_i_4_n_0 ),
        .I1(\slim_dout_sel[0][30]_INST_0_i_1_2 ),
        .I2(\slim_dout_sel[0][30]_INST_0_i_1_3 ),
        .I3(\slim_dout_sel[0][29]_0 [2]),
        .I4(\slim_dout_sel[0][29]_0 [0]),
        .O(\slim_dout_sel[0][30]_INST_0_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h8A808A808A8A8080)) 
    \slim_dout_sel[0][31]_INST_0_i_1 
       (.I0(Q[0]),
        .I1(\slim_dout_sel[0][29] ),
        .I2(\slim_dout_sel[0][29]_0 [2]),
        .I3(\slim_dout_sel[0][31]_INST_0_i_3_n_0 ),
        .I4(\slim_dout_sel[0][31]_INST_0_i_4_n_0 ),
        .I5(\slim_dout_sel[3][29]_1 [0]),
        .O(\slim_dout_sel[0]_OBUF [0]));
  LUT6 #(
    .INIT(64'hFF00CCCCF0F0AAAA)) 
    \slim_dout_sel[0][31]_INST_0_i_3 
       (.I0(DOUTBDOUT[3]),
        .I1(\slim_dout_sel[0][31]_INST_0_i_1_0 ),
        .I2(\slim_dout_sel[0][31]_INST_0_i_1_1 [1]),
        .I3(\slim_dout_sel[0][31]_INST_0_i_1_2 [1]),
        .I4(\slim_dout_sel[0][29]_0 [1]),
        .I5(\slim_dout_sel[0][29]_0 [0]),
        .O(\slim_dout_sel[0][31]_INST_0_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFF00CCCCF0F0AAAA)) 
    \slim_dout_sel[0][31]_INST_0_i_4 
       (.I0(DOUTADOUT[3]),
        .I1(\slim_dout_sel[0][31]_INST_0_i_1_3 ),
        .I2(\slim_dout_sel[0][31]_INST_0_i_1_4 [1]),
        .I3(\slim_dout_sel[0][31]_INST_0_i_1_5 [1]),
        .I4(\slim_dout_sel[0][29]_0 [1]),
        .I5(\slim_dout_sel[0][29]_0 [0]),
        .O(\slim_dout_sel[0][31]_INST_0_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h8A808A808A8A8080)) 
    \slim_dout_sel[1][29]_INST_0_i_1 
       (.I0(Q[1]),
        .I1(\slim_dout_sel[1][29] ),
        .I2(\slim_dout_sel[1][29]_0 [2]),
        .I3(\slim_dout_sel[1][29]_INST_0_i_2_n_0 ),
        .I4(\slim_dout_sel[1][29]_INST_0_i_3_n_0 ),
        .I5(\slim_dout_sel[3][29]_1 [1]),
        .O(\slim_dout_sel[1]_OBUF [1]));
  LUT6 #(
    .INIT(64'hFF00CCCCF0F0AAAA)) 
    \slim_dout_sel[1][29]_INST_0_i_2 
       (.I0(DOUTBDOUT[3]),
        .I1(\slim_dout_sel[0][31]_INST_0_i_1_0 ),
        .I2(\slim_dout_sel[0][31]_INST_0_i_1_1 [0]),
        .I3(\slim_dout_sel[0][31]_INST_0_i_1_2 [0]),
        .I4(\slim_dout_sel[1][29]_0 [1]),
        .I5(\slim_dout_sel[1][29]_0 [0]),
        .O(\slim_dout_sel[1][29]_INST_0_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFF00CCCCF0F0AAAA)) 
    \slim_dout_sel[1][29]_INST_0_i_3 
       (.I0(DOUTADOUT[3]),
        .I1(\slim_dout_sel[0][31]_INST_0_i_1_3 ),
        .I2(\slim_dout_sel[0][31]_INST_0_i_1_4 [0]),
        .I3(\slim_dout_sel[0][31]_INST_0_i_1_5 [0]),
        .I4(\slim_dout_sel[1][29]_0 [1]),
        .I5(\slim_dout_sel[1][29]_0 [0]),
        .O(\slim_dout_sel[1][29]_INST_0_i_3_n_0 ));
  LUT4 #(
    .INIT(16'hA0C0)) 
    \slim_dout_sel[1][30]_INST_0_i_1 
       (.I0(\slim_dout_sel[1][30]_INST_0_i_2_n_0 ),
        .I1(\slim_dout_sel[1][30]_INST_0_i_3_n_0 ),
        .I2(Q[1]),
        .I3(\slim_dout_sel[3][29]_1 [1]),
        .O(\slim_dout_sel[1]_OBUF [2]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[1][30]_INST_0_i_2 
       (.I0(\slim_dout_sel[1][31]_INST_0_i_3_n_0 ),
        .I1(\slim_dout_sel[0][30]_INST_0_i_1_0 ),
        .I2(\slim_dout_sel[0][30]_INST_0_i_1_1 ),
        .I3(\slim_dout_sel[1][29]_0 [2]),
        .I4(\slim_dout_sel[1][29]_0 [0]),
        .O(\slim_dout_sel[1][30]_INST_0_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[1][30]_INST_0_i_3 
       (.I0(\slim_dout_sel[1][31]_INST_0_i_4_n_0 ),
        .I1(\slim_dout_sel[0][30]_INST_0_i_1_2 ),
        .I2(\slim_dout_sel[0][30]_INST_0_i_1_3 ),
        .I3(\slim_dout_sel[1][29]_0 [2]),
        .I4(\slim_dout_sel[1][29]_0 [0]),
        .O(\slim_dout_sel[1][30]_INST_0_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h8A808A808A8A8080)) 
    \slim_dout_sel[1][31]_INST_0_i_1 
       (.I0(Q[1]),
        .I1(\slim_dout_sel[1][29] ),
        .I2(\slim_dout_sel[1][29]_0 [2]),
        .I3(\slim_dout_sel[1][31]_INST_0_i_3_n_0 ),
        .I4(\slim_dout_sel[1][31]_INST_0_i_4_n_0 ),
        .I5(\slim_dout_sel[3][29]_1 [1]),
        .O(\slim_dout_sel[1]_OBUF [0]));
  LUT6 #(
    .INIT(64'hFF00CCCCF0F0AAAA)) 
    \slim_dout_sel[1][31]_INST_0_i_3 
       (.I0(DOUTBDOUT[3]),
        .I1(\slim_dout_sel[0][31]_INST_0_i_1_0 ),
        .I2(\slim_dout_sel[0][31]_INST_0_i_1_1 [1]),
        .I3(\slim_dout_sel[0][31]_INST_0_i_1_2 [1]),
        .I4(\slim_dout_sel[1][29]_0 [1]),
        .I5(\slim_dout_sel[1][29]_0 [0]),
        .O(\slim_dout_sel[1][31]_INST_0_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFF00CCCCF0F0AAAA)) 
    \slim_dout_sel[1][31]_INST_0_i_4 
       (.I0(DOUTADOUT[3]),
        .I1(\slim_dout_sel[0][31]_INST_0_i_1_3 ),
        .I2(\slim_dout_sel[0][31]_INST_0_i_1_4 [1]),
        .I3(\slim_dout_sel[0][31]_INST_0_i_1_5 [1]),
        .I4(\slim_dout_sel[1][29]_0 [1]),
        .I5(\slim_dout_sel[1][29]_0 [0]),
        .O(\slim_dout_sel[1][31]_INST_0_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h8A808A808A8A8080)) 
    \slim_dout_sel[2][29]_INST_0_i_1 
       (.I0(Q[2]),
        .I1(\slim_dout_sel[2][29] ),
        .I2(\slim_dout_sel[2][29]_0 [2]),
        .I3(\slim_dout_sel[2][29]_INST_0_i_2_n_0 ),
        .I4(\slim_dout_sel[2][29]_INST_0_i_3_n_0 ),
        .I5(\slim_dout_sel[3][29]_1 [2]),
        .O(\slim_dout_sel[2]_OBUF [1]));
  LUT6 #(
    .INIT(64'hFF00CCCCF0F0AAAA)) 
    \slim_dout_sel[2][29]_INST_0_i_2 
       (.I0(DOUTBDOUT[3]),
        .I1(\slim_dout_sel[0][31]_INST_0_i_1_0 ),
        .I2(\slim_dout_sel[0][31]_INST_0_i_1_1 [0]),
        .I3(\slim_dout_sel[0][31]_INST_0_i_1_2 [0]),
        .I4(\slim_dout_sel[2][29]_0 [1]),
        .I5(\slim_dout_sel[2][29]_0 [0]),
        .O(\slim_dout_sel[2][29]_INST_0_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFF00CCCCF0F0AAAA)) 
    \slim_dout_sel[2][29]_INST_0_i_3 
       (.I0(DOUTADOUT[3]),
        .I1(\slim_dout_sel[0][31]_INST_0_i_1_3 ),
        .I2(\slim_dout_sel[0][31]_INST_0_i_1_4 [0]),
        .I3(\slim_dout_sel[0][31]_INST_0_i_1_5 [0]),
        .I4(\slim_dout_sel[2][29]_0 [1]),
        .I5(\slim_dout_sel[2][29]_0 [0]),
        .O(\slim_dout_sel[2][29]_INST_0_i_3_n_0 ));
  LUT4 #(
    .INIT(16'hA0C0)) 
    \slim_dout_sel[2][30]_INST_0_i_1 
       (.I0(\slim_dout_sel[2][30]_INST_0_i_2_n_0 ),
        .I1(\slim_dout_sel[2][30]_INST_0_i_3_n_0 ),
        .I2(Q[2]),
        .I3(\slim_dout_sel[3][29]_1 [2]),
        .O(\slim_dout_sel[2]_OBUF [2]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[2][30]_INST_0_i_2 
       (.I0(\slim_dout_sel[2][31]_INST_0_i_3_n_0 ),
        .I1(\slim_dout_sel[0][30]_INST_0_i_1_0 ),
        .I2(\slim_dout_sel[0][30]_INST_0_i_1_1 ),
        .I3(\slim_dout_sel[2][29]_0 [2]),
        .I4(\slim_dout_sel[2][29]_0 [0]),
        .O(\slim_dout_sel[2][30]_INST_0_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[2][30]_INST_0_i_3 
       (.I0(\slim_dout_sel[2][31]_INST_0_i_4_n_0 ),
        .I1(\slim_dout_sel[0][30]_INST_0_i_1_2 ),
        .I2(\slim_dout_sel[0][30]_INST_0_i_1_3 ),
        .I3(\slim_dout_sel[2][29]_0 [2]),
        .I4(\slim_dout_sel[2][29]_0 [0]),
        .O(\slim_dout_sel[2][30]_INST_0_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h8A808A808A8A8080)) 
    \slim_dout_sel[2][31]_INST_0_i_1 
       (.I0(Q[2]),
        .I1(\slim_dout_sel[2][29] ),
        .I2(\slim_dout_sel[2][29]_0 [2]),
        .I3(\slim_dout_sel[2][31]_INST_0_i_3_n_0 ),
        .I4(\slim_dout_sel[2][31]_INST_0_i_4_n_0 ),
        .I5(\slim_dout_sel[3][29]_1 [2]),
        .O(\slim_dout_sel[2]_OBUF [0]));
  LUT6 #(
    .INIT(64'hFF00CCCCF0F0AAAA)) 
    \slim_dout_sel[2][31]_INST_0_i_3 
       (.I0(DOUTBDOUT[3]),
        .I1(\slim_dout_sel[0][31]_INST_0_i_1_0 ),
        .I2(\slim_dout_sel[0][31]_INST_0_i_1_1 [1]),
        .I3(\slim_dout_sel[0][31]_INST_0_i_1_2 [1]),
        .I4(\slim_dout_sel[2][29]_0 [1]),
        .I5(\slim_dout_sel[2][29]_0 [0]),
        .O(\slim_dout_sel[2][31]_INST_0_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFF00CCCCF0F0AAAA)) 
    \slim_dout_sel[2][31]_INST_0_i_4 
       (.I0(DOUTADOUT[3]),
        .I1(\slim_dout_sel[0][31]_INST_0_i_1_3 ),
        .I2(\slim_dout_sel[0][31]_INST_0_i_1_4 [1]),
        .I3(\slim_dout_sel[0][31]_INST_0_i_1_5 [1]),
        .I4(\slim_dout_sel[2][29]_0 [1]),
        .I5(\slim_dout_sel[2][29]_0 [0]),
        .O(\slim_dout_sel[2][31]_INST_0_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h8A808A808A8A8080)) 
    \slim_dout_sel[3][29]_INST_0_i_1 
       (.I0(Q[3]),
        .I1(\slim_dout_sel[3][29] ),
        .I2(\slim_dout_sel[3][29]_0 [2]),
        .I3(\slim_dout_sel[3][29]_INST_0_i_2_n_0 ),
        .I4(\slim_dout_sel[3][29]_INST_0_i_3_n_0 ),
        .I5(\slim_dout_sel[3][29]_1 [3]),
        .O(\slim_dout_sel[3]_OBUF [1]));
  LUT6 #(
    .INIT(64'hFF00CCCCF0F0AAAA)) 
    \slim_dout_sel[3][29]_INST_0_i_2 
       (.I0(DOUTBDOUT[3]),
        .I1(\slim_dout_sel[0][31]_INST_0_i_1_0 ),
        .I2(\slim_dout_sel[0][31]_INST_0_i_1_1 [0]),
        .I3(\slim_dout_sel[0][31]_INST_0_i_1_2 [0]),
        .I4(\slim_dout_sel[3][29]_0 [1]),
        .I5(\slim_dout_sel[3][29]_0 [0]),
        .O(\slim_dout_sel[3][29]_INST_0_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFF00CCCCF0F0AAAA)) 
    \slim_dout_sel[3][29]_INST_0_i_3 
       (.I0(DOUTADOUT[3]),
        .I1(\slim_dout_sel[0][31]_INST_0_i_1_3 ),
        .I2(\slim_dout_sel[0][31]_INST_0_i_1_4 [0]),
        .I3(\slim_dout_sel[0][31]_INST_0_i_1_5 [0]),
        .I4(\slim_dout_sel[3][29]_0 [1]),
        .I5(\slim_dout_sel[3][29]_0 [0]),
        .O(\slim_dout_sel[3][29]_INST_0_i_3_n_0 ));
  LUT4 #(
    .INIT(16'hA0C0)) 
    \slim_dout_sel[3][30]_INST_0_i_1 
       (.I0(doutB_bank__29),
        .I1(doutA_bank__29),
        .I2(Q[3]),
        .I3(\slim_dout_sel[3][29]_1 [3]),
        .O(\slim_dout_sel[3]_OBUF [2]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[3][30]_INST_0_i_2 
       (.I0(\slim_dout_sel[3][31]_INST_0_i_3_n_0 ),
        .I1(\slim_dout_sel[0][30]_INST_0_i_1_0 ),
        .I2(\slim_dout_sel[0][30]_INST_0_i_1_1 ),
        .I3(\slim_dout_sel[3][29]_0 [2]),
        .I4(\slim_dout_sel[3][29]_0 [0]),
        .O(doutB_bank__29));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[3][30]_INST_0_i_3 
       (.I0(\slim_dout_sel[3][31]_INST_0_i_4_n_0 ),
        .I1(\slim_dout_sel[0][30]_INST_0_i_1_2 ),
        .I2(\slim_dout_sel[0][30]_INST_0_i_1_3 ),
        .I3(\slim_dout_sel[3][29]_0 [2]),
        .I4(\slim_dout_sel[3][29]_0 [0]),
        .O(doutA_bank__29));
  LUT6 #(
    .INIT(64'h8A808A808A8A8080)) 
    \slim_dout_sel[3][31]_INST_0_i_1 
       (.I0(Q[3]),
        .I1(\slim_dout_sel[3][29] ),
        .I2(\slim_dout_sel[3][29]_0 [2]),
        .I3(\slim_dout_sel[3][31]_INST_0_i_3_n_0 ),
        .I4(\slim_dout_sel[3][31]_INST_0_i_4_n_0 ),
        .I5(\slim_dout_sel[3][29]_1 [3]),
        .O(\slim_dout_sel[3]_OBUF [0]));
  LUT6 #(
    .INIT(64'hFF00CCCCF0F0AAAA)) 
    \slim_dout_sel[3][31]_INST_0_i_3 
       (.I0(DOUTBDOUT[3]),
        .I1(\slim_dout_sel[0][31]_INST_0_i_1_0 ),
        .I2(\slim_dout_sel[0][31]_INST_0_i_1_1 [1]),
        .I3(\slim_dout_sel[0][31]_INST_0_i_1_2 [1]),
        .I4(\slim_dout_sel[3][29]_0 [1]),
        .I5(\slim_dout_sel[3][29]_0 [0]),
        .O(\slim_dout_sel[3][31]_INST_0_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFF00CCCCF0F0AAAA)) 
    \slim_dout_sel[3][31]_INST_0_i_4 
       (.I0(DOUTADOUT[3]),
        .I1(\slim_dout_sel[0][31]_INST_0_i_1_3 ),
        .I2(\slim_dout_sel[0][31]_INST_0_i_1_4 [1]),
        .I3(\slim_dout_sel[0][31]_INST_0_i_1_5 [1]),
        .I4(\slim_dout_sel[3][29]_0 [1]),
        .I5(\slim_dout_sel[3][29]_0 [0]),
        .O(\slim_dout_sel[3][31]_INST_0_i_4_n_0 ));
endmodule

(* ORIG_REF_NAME = "reuse_weight_bank_rom" *) 
module reuse_weight_bank_rom__parameterized0
   (dout_a_reg_0,
    dout_a_reg_1,
    \slim_dout_sel[3]_OBUF ,
    \slim_dout_sel[2]_OBUF ,
    \slim_dout_sel[1]_OBUF ,
    \slim_dout_sel[0]_OBUF ,
    clk_IBUF_BUFG,
    D,
    slim_port_sel_IBUF,
    slim_en_sel_IBUF,
    dout_a_reg_2,
    dout_a_reg_3,
    dout_a_reg_4,
    dout_a_reg_5,
    dout_a_reg_6,
    dout_a_reg_7,
    dout_a_reg_8,
    dout_a_reg_9,
    dout_a_reg_10,
    dout_a_reg_11,
    dout_a_reg_12,
    dout_a_reg_13,
    dout_a_reg_14,
    dout_a_reg_15,
    dout_a_reg_16,
    Q,
    \slim_dout_sel[3][0] ,
    DOUTBDOUT,
    \slim_dout_sel[0][28]_INST_0_i_1_0 ,
    \slim_dout_sel[3][28]_INST_0_i_1_0 ,
    \slim_dout_sel[0][28]_INST_0_i_2_0 ,
    \slim_dout_sel[0][28]_INST_0_i_2_1 ,
    \slim_dout_sel[0][28]_INST_0_i_2_2 ,
    DOUTADOUT,
    \slim_dout_sel[0][28]_INST_0_i_1_1 ,
    \slim_dout_sel[0][28]_INST_0_i_3_0 ,
    \slim_dout_sel[0][28]_INST_0_i_3_1 ,
    \slim_dout_sel[0][28]_INST_0_i_3_2 ,
    \slim_dout_sel[2][28]_INST_0_i_1_0 ,
    \slim_dout_sel[1][28]_INST_0_i_1_0 ,
    \slim_dout_sel[0][28]_INST_0_i_1_2 );
  output [0:0]dout_a_reg_0;
  output [0:0]dout_a_reg_1;
  output [3:0]\slim_dout_sel[3]_OBUF ;
  output [3:0]\slim_dout_sel[2]_OBUF ;
  output [3:0]\slim_dout_sel[1]_OBUF ;
  output [3:0]\slim_dout_sel[0]_OBUF ;
  input clk_IBUF_BUFG;
  input [2:0]D;
  input [3:0]slim_port_sel_IBUF;
  input [3:0]slim_en_sel_IBUF;
  input dout_a_reg_2;
  input dout_a_reg_3;
  input dout_a_reg_4;
  input dout_a_reg_5;
  input dout_a_reg_6;
  input dout_a_reg_7;
  input dout_a_reg_8;
  input dout_a_reg_9;
  input dout_a_reg_10;
  input dout_a_reg_11;
  input dout_a_reg_12;
  input dout_a_reg_13;
  input [2:0]dout_a_reg_14;
  input [2:0]dout_a_reg_15;
  input [2:0]dout_a_reg_16;
  input [3:0]Q;
  input [3:0]\slim_dout_sel[3][0] ;
  input [3:0]DOUTBDOUT;
  input [3:0]\slim_dout_sel[0][28]_INST_0_i_1_0 ;
  input [2:0]\slim_dout_sel[3][28]_INST_0_i_1_0 ;
  input [3:0]\slim_dout_sel[0][28]_INST_0_i_2_0 ;
  input [3:0]\slim_dout_sel[0][28]_INST_0_i_2_1 ;
  input [3:0]\slim_dout_sel[0][28]_INST_0_i_2_2 ;
  input [3:0]DOUTADOUT;
  input [3:0]\slim_dout_sel[0][28]_INST_0_i_1_1 ;
  input [3:0]\slim_dout_sel[0][28]_INST_0_i_3_0 ;
  input [3:0]\slim_dout_sel[0][28]_INST_0_i_3_1 ;
  input [3:0]\slim_dout_sel[0][28]_INST_0_i_3_2 ;
  input [2:0]\slim_dout_sel[2][28]_INST_0_i_1_0 ;
  input [2:0]\slim_dout_sel[1][28]_INST_0_i_1_0 ;
  input [2:0]\slim_dout_sel[0][28]_INST_0_i_1_2 ;

  wire [2:0]D;
  wire [3:0]DOUTADOUT;
  wire [3:0]DOUTBDOUT;
  wire [3:0]Q;
  wire [2:0]\addrA_bank[1]_5 ;
  wire [2:0]\addrB_bank[1]_14 ;
  wire clk_IBUF_BUFG;
  wire [28:0]\doutA_bank[1]__0 ;
  wire [28:0]doutA_bank__29;
  wire [28:0]\doutB_bank[1]__0 ;
  wire [28:0]doutB_bank__29;
  wire [0:0]dout_a_reg_0;
  wire [0:0]dout_a_reg_1;
  wire dout_a_reg_10;
  wire dout_a_reg_11;
  wire dout_a_reg_12;
  wire dout_a_reg_13;
  wire [2:0]dout_a_reg_14;
  wire [2:0]dout_a_reg_15;
  wire [2:0]dout_a_reg_16;
  wire dout_a_reg_2;
  wire dout_a_reg_3;
  wire dout_a_reg_4;
  wire dout_a_reg_5;
  wire dout_a_reg_6;
  wire dout_a_reg_7;
  wire dout_a_reg_8;
  wire dout_a_reg_9;
  wire dout_a_reg_i_10__2_n_0;
  wire dout_a_reg_i_11__0_n_0;
  wire dout_a_reg_i_12__0_n_0;
  wire dout_a_reg_i_13__3_n_0;
  wire dout_a_reg_i_14__2_n_0;
  wire dout_a_reg_i_15__4_n_0;
  wire dout_a_reg_i_16__3_n_0;
  wire dout_a_reg_i_17_n_0;
  wire dout_a_reg_i_18_n_0;
  wire dout_a_reg_i_19__0_n_0;
  wire dout_a_reg_i_20__3_n_0;
  wire dout_a_reg_i_21__3_n_0;
  wire dout_a_reg_i_22__4_n_0;
  wire dout_a_reg_i_9__3_n_0;
  wire [1:1]enA_bank;
  wire [1:1]enB_bank;
  wire \slim_dout_sel[0][0]_INST_0_i_2_n_0 ;
  wire \slim_dout_sel[0][0]_INST_0_i_3_n_0 ;
  wire \slim_dout_sel[0][0]_INST_0_i_4_n_0 ;
  wire \slim_dout_sel[0][0]_INST_0_i_5_n_0 ;
  wire \slim_dout_sel[0][1]_INST_0_i_2_n_0 ;
  wire \slim_dout_sel[0][1]_INST_0_i_3_n_0 ;
  wire \slim_dout_sel[0][1]_INST_0_i_4_n_0 ;
  wire \slim_dout_sel[0][1]_INST_0_i_5_n_0 ;
  wire [3:0]\slim_dout_sel[0][28]_INST_0_i_1_0 ;
  wire [3:0]\slim_dout_sel[0][28]_INST_0_i_1_1 ;
  wire [2:0]\slim_dout_sel[0][28]_INST_0_i_1_2 ;
  wire [3:0]\slim_dout_sel[0][28]_INST_0_i_2_0 ;
  wire [3:0]\slim_dout_sel[0][28]_INST_0_i_2_1 ;
  wire [3:0]\slim_dout_sel[0][28]_INST_0_i_2_2 ;
  wire \slim_dout_sel[0][28]_INST_0_i_2_n_0 ;
  wire [3:0]\slim_dout_sel[0][28]_INST_0_i_3_0 ;
  wire [3:0]\slim_dout_sel[0][28]_INST_0_i_3_1 ;
  wire [3:0]\slim_dout_sel[0][28]_INST_0_i_3_2 ;
  wire \slim_dout_sel[0][28]_INST_0_i_3_n_0 ;
  wire \slim_dout_sel[0][28]_INST_0_i_4_n_0 ;
  wire \slim_dout_sel[0][28]_INST_0_i_5_n_0 ;
  wire \slim_dout_sel[0][2]_INST_0_i_2_n_0 ;
  wire \slim_dout_sel[0][2]_INST_0_i_3_n_0 ;
  wire \slim_dout_sel[0][2]_INST_0_i_4_n_0 ;
  wire \slim_dout_sel[0][2]_INST_0_i_5_n_0 ;
  wire [3:0]\slim_dout_sel[0]_OBUF ;
  wire \slim_dout_sel[1][0]_INST_0_i_2_n_0 ;
  wire \slim_dout_sel[1][0]_INST_0_i_3_n_0 ;
  wire \slim_dout_sel[1][0]_INST_0_i_4_n_0 ;
  wire \slim_dout_sel[1][0]_INST_0_i_5_n_0 ;
  wire \slim_dout_sel[1][1]_INST_0_i_2_n_0 ;
  wire \slim_dout_sel[1][1]_INST_0_i_3_n_0 ;
  wire \slim_dout_sel[1][1]_INST_0_i_4_n_0 ;
  wire \slim_dout_sel[1][1]_INST_0_i_5_n_0 ;
  wire [2:0]\slim_dout_sel[1][28]_INST_0_i_1_0 ;
  wire \slim_dout_sel[1][28]_INST_0_i_2_n_0 ;
  wire \slim_dout_sel[1][28]_INST_0_i_3_n_0 ;
  wire \slim_dout_sel[1][28]_INST_0_i_4_n_0 ;
  wire \slim_dout_sel[1][28]_INST_0_i_5_n_0 ;
  wire \slim_dout_sel[1][2]_INST_0_i_2_n_0 ;
  wire \slim_dout_sel[1][2]_INST_0_i_3_n_0 ;
  wire \slim_dout_sel[1][2]_INST_0_i_4_n_0 ;
  wire \slim_dout_sel[1][2]_INST_0_i_5_n_0 ;
  wire [3:0]\slim_dout_sel[1]_OBUF ;
  wire \slim_dout_sel[2][0]_INST_0_i_2_n_0 ;
  wire \slim_dout_sel[2][0]_INST_0_i_3_n_0 ;
  wire \slim_dout_sel[2][0]_INST_0_i_4_n_0 ;
  wire \slim_dout_sel[2][0]_INST_0_i_5_n_0 ;
  wire \slim_dout_sel[2][1]_INST_0_i_2_n_0 ;
  wire \slim_dout_sel[2][1]_INST_0_i_3_n_0 ;
  wire \slim_dout_sel[2][1]_INST_0_i_4_n_0 ;
  wire \slim_dout_sel[2][1]_INST_0_i_5_n_0 ;
  wire [2:0]\slim_dout_sel[2][28]_INST_0_i_1_0 ;
  wire \slim_dout_sel[2][28]_INST_0_i_2_n_0 ;
  wire \slim_dout_sel[2][28]_INST_0_i_3_n_0 ;
  wire \slim_dout_sel[2][28]_INST_0_i_4_n_0 ;
  wire \slim_dout_sel[2][28]_INST_0_i_5_n_0 ;
  wire \slim_dout_sel[2][2]_INST_0_i_2_n_0 ;
  wire \slim_dout_sel[2][2]_INST_0_i_3_n_0 ;
  wire \slim_dout_sel[2][2]_INST_0_i_4_n_0 ;
  wire \slim_dout_sel[2][2]_INST_0_i_5_n_0 ;
  wire [3:0]\slim_dout_sel[2]_OBUF ;
  wire [3:0]\slim_dout_sel[3][0] ;
  wire \slim_dout_sel[3][0]_INST_0_i_4_n_0 ;
  wire \slim_dout_sel[3][0]_INST_0_i_5_n_0 ;
  wire \slim_dout_sel[3][1]_INST_0_i_4_n_0 ;
  wire \slim_dout_sel[3][1]_INST_0_i_5_n_0 ;
  wire [2:0]\slim_dout_sel[3][28]_INST_0_i_1_0 ;
  wire \slim_dout_sel[3][28]_INST_0_i_4_n_0 ;
  wire \slim_dout_sel[3][28]_INST_0_i_5_n_0 ;
  wire \slim_dout_sel[3][2]_INST_0_i_4_n_0 ;
  wire \slim_dout_sel[3][2]_INST_0_i_5_n_0 ;
  wire [3:0]\slim_dout_sel[3]_OBUF ;
  wire [3:0]slim_en_sel_IBUF;
  wire [3:0]slim_port_sel_IBUF;
  wire [15:0]NLW_dout_a_reg_CASDOUTA_UNCONNECTED;
  wire [15:0]NLW_dout_a_reg_CASDOUTB_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_CASDOUTPA_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_CASDOUTPB_UNCONNECTED;
  wire [15:5]NLW_dout_a_reg_DOUTADOUT_UNCONNECTED;
  wire [15:5]NLW_dout_a_reg_DOUTBDOUT_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_DOUTPADOUTP_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_DOUTPBDOUTP_UNCONNECTED;

  (* \MEM.PORTA.DATA_BIT_LAYOUT  = "p0_d5" *) 
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-6 {cell *THIS*}}" *) 
  (* OPT_MODIFIED = "MLO" *) 
  (* RDADDR_COLLISION_HWCONFIG = "PERFORMANCE" *) 
  (* RTL_RAM_BITS = "40" *) 
  (* RTL_RAM_NAME = "u_wbuf/WBUF_BANK[1].g_bank1.u_bank/dout_a_reg" *) 
  (* RTL_RAM_TYPE = "RAM_SP" *) 
  (* ram_addr_begin = "0" *) 
  (* ram_addr_end = "1023" *) 
  (* ram_offset = "0" *) 
  (* ram_slice_begin = "0" *) 
  (* ram_slice_end = "4" *) 
  RAMB18E2 #(
    .CASCADE_ORDER_A("NONE"),
    .CASCADE_ORDER_B("NONE"),
    .CLOCK_DOMAINS("COMMON"),
    .DOA_REG(0),
    .DOB_REG(0),
    .ENADDRENA("FALSE"),
    .ENADDRENB("FALSE"),
    .INITP_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_00(256'h00000000000000000000000000000000000F000E000D000C000B000A00090008),
    .INIT_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_10(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_11(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_12(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_13(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_14(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_15(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_16(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_17(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_18(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_19(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_20(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_21(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_22(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_23(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_24(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_25(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_26(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_27(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_28(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_29(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_30(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_31(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_32(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_33(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_34(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_35(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_36(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_37(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_38(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_39(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_A(18'h00000),
    .INIT_B(18'h00000),
    .INIT_FILE("NONE"),
    .RDADDRCHANGEA("FALSE"),
    .RDADDRCHANGEB("FALSE"),
    .READ_WIDTH_A(18),
    .READ_WIDTH_B(18),
    .RSTREG_PRIORITY_A("RSTREG"),
    .RSTREG_PRIORITY_B("RSTREG"),
    .SIM_COLLISION_CHECK("ALL"),
    .SLEEP_ASYNC("FALSE"),
    .SRVAL_A(18'h00000),
    .SRVAL_B(18'h00000),
    .WRITE_MODE_A("WRITE_FIRST"),
    .WRITE_MODE_B("WRITE_FIRST"),
    .WRITE_WIDTH_A(18),
    .WRITE_WIDTH_B(0)) 
    dout_a_reg
       (.ADDRARDADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\addrA_bank[1]_5 ,1'b0,1'b0,1'b0,1'b0}),
        .ADDRBWRADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\addrB_bank[1]_14 ,1'b0,1'b0,1'b0,1'b0}),
        .ADDRENA(1'b1),
        .ADDRENB(1'b1),
        .CASDIMUXA(1'b0),
        .CASDIMUXB(1'b0),
        .CASDINA({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .CASDINB({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .CASDINPA({1'b0,1'b0}),
        .CASDINPB({1'b0,1'b0}),
        .CASDOMUXA(1'b0),
        .CASDOMUXB(1'b0),
        .CASDOMUXEN_A(1'b1),
        .CASDOMUXEN_B(1'b1),
        .CASDOUTA(NLW_dout_a_reg_CASDOUTA_UNCONNECTED[15:0]),
        .CASDOUTB(NLW_dout_a_reg_CASDOUTB_UNCONNECTED[15:0]),
        .CASDOUTPA(NLW_dout_a_reg_CASDOUTPA_UNCONNECTED[1:0]),
        .CASDOUTPB(NLW_dout_a_reg_CASDOUTPB_UNCONNECTED[1:0]),
        .CASOREGIMUXA(1'b0),
        .CASOREGIMUXB(1'b0),
        .CASOREGIMUXEN_A(1'b1),
        .CASOREGIMUXEN_B(1'b1),
        .CLKARDCLK(clk_IBUF_BUFG),
        .CLKBWRCLK(clk_IBUF_BUFG),
        .DINADIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .DINBDIN({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .DINPADINP({1'b0,1'b0}),
        .DINPBDINP({1'b1,1'b1}),
        .DOUTADOUT({NLW_dout_a_reg_DOUTADOUT_UNCONNECTED[15:5],dout_a_reg_0,\doutA_bank[1]__0 [28],\doutA_bank[1]__0 [2:0]}),
        .DOUTBDOUT({NLW_dout_a_reg_DOUTBDOUT_UNCONNECTED[15:5],dout_a_reg_1,\doutB_bank[1]__0 [28],\doutB_bank[1]__0 [2:0]}),
        .DOUTPADOUTP(NLW_dout_a_reg_DOUTPADOUTP_UNCONNECTED[1:0]),
        .DOUTPBDOUTP(NLW_dout_a_reg_DOUTPBDOUTP_UNCONNECTED[1:0]),
        .ENARDEN(enA_bank),
        .ENBWREN(enB_bank),
        .REGCEAREGCE(1'b1),
        .REGCEB(1'b1),
        .RSTRAMARSTRAM(1'b0),
        .RSTRAMB(1'b0),
        .RSTREGARSTREG(1'b0),
        .RSTREGB(1'b0),
        .SLEEP(1'b0),
        .WEA({1'b0,1'b0}),
        .WEBWE({1'b0,1'b0,1'b0,1'b0}));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT5 #(
    .INIT(32'hFFFFFFDF)) 
    dout_a_reg_i_10__2
       (.I0(slim_en_sel_IBUF[0]),
        .I1(slim_port_sel_IBUF[0]),
        .I2(dout_a_reg_16[0]),
        .I3(dout_a_reg_16[2]),
        .I4(dout_a_reg_16[1]),
        .O(dout_a_reg_i_10__2_n_0));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT5 #(
    .INIT(32'hFFFFFFDF)) 
    dout_a_reg_i_11__0
       (.I0(slim_en_sel_IBUF[1]),
        .I1(slim_port_sel_IBUF[1]),
        .I2(dout_a_reg_14[0]),
        .I3(dout_a_reg_14[2]),
        .I4(dout_a_reg_14[1]),
        .O(dout_a_reg_i_11__0_n_0));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT5 #(
    .INIT(32'h00000040)) 
    dout_a_reg_i_12__0
       (.I0(slim_port_sel_IBUF[3]),
        .I1(slim_en_sel_IBUF[3]),
        .I2(dout_a_reg_15[0]),
        .I3(dout_a_reg_15[2]),
        .I4(dout_a_reg_15[1]),
        .O(dout_a_reg_i_12__0_n_0));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT5 #(
    .INIT(32'hFDFFFFFF)) 
    dout_a_reg_i_13__3
       (.I0(dout_a_reg_14[0]),
        .I1(dout_a_reg_14[2]),
        .I2(dout_a_reg_14[1]),
        .I3(slim_en_sel_IBUF[1]),
        .I4(slim_port_sel_IBUF[1]),
        .O(dout_a_reg_i_13__3_n_0));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT5 #(
    .INIT(32'hFDFFFFFF)) 
    dout_a_reg_i_14__2
       (.I0(dout_a_reg_16[0]),
        .I1(dout_a_reg_16[2]),
        .I2(dout_a_reg_16[1]),
        .I3(slim_port_sel_IBUF[0]),
        .I4(slim_en_sel_IBUF[0]),
        .O(dout_a_reg_i_14__2_n_0));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT5 #(
    .INIT(32'h02000000)) 
    dout_a_reg_i_15__4
       (.I0(D[0]),
        .I1(D[2]),
        .I2(D[1]),
        .I3(slim_en_sel_IBUF[2]),
        .I4(slim_port_sel_IBUF[2]),
        .O(dout_a_reg_i_15__4_n_0));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT5 #(
    .INIT(32'h02000000)) 
    dout_a_reg_i_16__3
       (.I0(dout_a_reg_15[0]),
        .I1(dout_a_reg_15[2]),
        .I2(dout_a_reg_15[1]),
        .I3(slim_en_sel_IBUF[3]),
        .I4(slim_port_sel_IBUF[3]),
        .O(dout_a_reg_i_16__3_n_0));
  LUT5 #(
    .INIT(32'h44F0FFFF)) 
    dout_a_reg_i_17
       (.I0(dout_a_reg_i_10__2_n_0),
        .I1(dout_a_reg_12),
        .I2(dout_a_reg_13),
        .I3(dout_a_reg_i_11__0_n_0),
        .I4(dout_a_reg_i_9__3_n_0),
        .O(dout_a_reg_i_17_n_0));
  LUT5 #(
    .INIT(32'h44F0FFFF)) 
    dout_a_reg_i_18
       (.I0(dout_a_reg_i_10__2_n_0),
        .I1(dout_a_reg_8),
        .I2(dout_a_reg_9),
        .I3(dout_a_reg_i_11__0_n_0),
        .I4(dout_a_reg_i_9__3_n_0),
        .O(dout_a_reg_i_18_n_0));
  LUT5 #(
    .INIT(32'h44F0FFFF)) 
    dout_a_reg_i_19__0
       (.I0(dout_a_reg_i_10__2_n_0),
        .I1(dout_a_reg_4),
        .I2(dout_a_reg_5),
        .I3(dout_a_reg_i_11__0_n_0),
        .I4(dout_a_reg_i_9__3_n_0),
        .O(dout_a_reg_i_19__0_n_0));
  LUT4 #(
    .INIT(16'hFF7F)) 
    dout_a_reg_i_1__0
       (.I0(dout_a_reg_i_9__3_n_0),
        .I1(dout_a_reg_i_10__2_n_0),
        .I2(dout_a_reg_i_11__0_n_0),
        .I3(dout_a_reg_i_12__0_n_0),
        .O(enA_bank));
  LUT5 #(
    .INIT(32'hFFFF44F0)) 
    dout_a_reg_i_20__3
       (.I0(dout_a_reg_i_14__2_n_0),
        .I1(dout_a_reg_12),
        .I2(dout_a_reg_13),
        .I3(dout_a_reg_i_13__3_n_0),
        .I4(dout_a_reg_i_15__4_n_0),
        .O(dout_a_reg_i_20__3_n_0));
  LUT5 #(
    .INIT(32'hFFFF44F0)) 
    dout_a_reg_i_21__3
       (.I0(dout_a_reg_i_14__2_n_0),
        .I1(dout_a_reg_8),
        .I2(dout_a_reg_9),
        .I3(dout_a_reg_i_13__3_n_0),
        .I4(dout_a_reg_i_15__4_n_0),
        .O(dout_a_reg_i_21__3_n_0));
  LUT5 #(
    .INIT(32'hFFFF44F0)) 
    dout_a_reg_i_22__4
       (.I0(dout_a_reg_i_14__2_n_0),
        .I1(dout_a_reg_4),
        .I2(dout_a_reg_5),
        .I3(dout_a_reg_i_13__3_n_0),
        .I4(dout_a_reg_i_15__4_n_0),
        .O(dout_a_reg_i_22__4_n_0));
  LUT4 #(
    .INIT(16'hFFF7)) 
    dout_a_reg_i_2__3
       (.I0(dout_a_reg_i_13__3_n_0),
        .I1(dout_a_reg_i_14__2_n_0),
        .I2(dout_a_reg_i_15__4_n_0),
        .I3(dout_a_reg_i_16__3_n_0),
        .O(enB_bank));
  LUT5 #(
    .INIT(32'hBBB88888)) 
    dout_a_reg_i_3__0
       (.I0(dout_a_reg_10),
        .I1(dout_a_reg_i_12__0_n_0),
        .I2(dout_a_reg_i_9__3_n_0),
        .I3(dout_a_reg_11),
        .I4(dout_a_reg_i_17_n_0),
        .O(\addrA_bank[1]_5 [2]));
  LUT5 #(
    .INIT(32'hBBB88888)) 
    dout_a_reg_i_4__0
       (.I0(dout_a_reg_6),
        .I1(dout_a_reg_i_12__0_n_0),
        .I2(dout_a_reg_i_9__3_n_0),
        .I3(dout_a_reg_7),
        .I4(dout_a_reg_i_18_n_0),
        .O(\addrA_bank[1]_5 [1]));
  LUT5 #(
    .INIT(32'hBBB88888)) 
    dout_a_reg_i_5__0
       (.I0(dout_a_reg_2),
        .I1(dout_a_reg_i_12__0_n_0),
        .I2(dout_a_reg_i_9__3_n_0),
        .I3(dout_a_reg_3),
        .I4(dout_a_reg_i_19__0_n_0),
        .O(\addrA_bank[1]_5 [0]));
  LUT5 #(
    .INIT(32'hB8BB8888)) 
    dout_a_reg_i_6__3
       (.I0(dout_a_reg_10),
        .I1(dout_a_reg_i_16__3_n_0),
        .I2(dout_a_reg_11),
        .I3(dout_a_reg_i_15__4_n_0),
        .I4(dout_a_reg_i_20__3_n_0),
        .O(\addrB_bank[1]_14 [2]));
  LUT5 #(
    .INIT(32'hB8BB8888)) 
    dout_a_reg_i_7__3
       (.I0(dout_a_reg_6),
        .I1(dout_a_reg_i_16__3_n_0),
        .I2(dout_a_reg_7),
        .I3(dout_a_reg_i_15__4_n_0),
        .I4(dout_a_reg_i_21__3_n_0),
        .O(\addrB_bank[1]_14 [1]));
  LUT5 #(
    .INIT(32'hB8BB8888)) 
    dout_a_reg_i_8__3
       (.I0(dout_a_reg_2),
        .I1(dout_a_reg_i_16__3_n_0),
        .I2(dout_a_reg_3),
        .I3(dout_a_reg_i_15__4_n_0),
        .I4(dout_a_reg_i_22__4_n_0),
        .O(\addrB_bank[1]_14 [0]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT5 #(
    .INIT(32'hFFFDFFFF)) 
    dout_a_reg_i_9__3
       (.I0(D[0]),
        .I1(D[2]),
        .I2(D[1]),
        .I3(slim_port_sel_IBUF[2]),
        .I4(slim_en_sel_IBUF[2]),
        .O(dout_a_reg_i_9__3_n_0));
  LUT4 #(
    .INIT(16'hA0C0)) 
    \slim_dout_sel[0][0]_INST_0_i_1 
       (.I0(\slim_dout_sel[0][0]_INST_0_i_2_n_0 ),
        .I1(\slim_dout_sel[0][0]_INST_0_i_3_n_0 ),
        .I2(Q[0]),
        .I3(\slim_dout_sel[3][0] [0]),
        .O(\slim_dout_sel[0]_OBUF [0]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[0][0]_INST_0_i_2 
       (.I0(\slim_dout_sel[0][0]_INST_0_i_4_n_0 ),
        .I1(DOUTBDOUT[0]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[0][28]_INST_0_i_1_2 [2]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_1_2 [0]),
        .O(\slim_dout_sel[0][0]_INST_0_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[0][0]_INST_0_i_3 
       (.I0(\slim_dout_sel[0][0]_INST_0_i_5_n_0 ),
        .I1(DOUTADOUT[0]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_1 [0]),
        .I3(\slim_dout_sel[0][28]_INST_0_i_1_2 [2]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_1_2 [0]),
        .O(\slim_dout_sel[0][0]_INST_0_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[0][0]_INST_0_i_4 
       (.I0(\doutB_bank[1]__0 [0]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_2_0 [0]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_2 [0]),
        .I3(\slim_dout_sel[0][28]_INST_0_i_1_2 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_2_1 [0]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_2_2 [0]),
        .O(\slim_dout_sel[0][0]_INST_0_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[0][0]_INST_0_i_5 
       (.I0(\doutA_bank[1]__0 [0]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_3_0 [0]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_2 [0]),
        .I3(\slim_dout_sel[0][28]_INST_0_i_1_2 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_3_1 [0]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_3_2 [0]),
        .O(\slim_dout_sel[0][0]_INST_0_i_5_n_0 ));
  LUT4 #(
    .INIT(16'hA0C0)) 
    \slim_dout_sel[0][1]_INST_0_i_1 
       (.I0(\slim_dout_sel[0][1]_INST_0_i_2_n_0 ),
        .I1(\slim_dout_sel[0][1]_INST_0_i_3_n_0 ),
        .I2(Q[0]),
        .I3(\slim_dout_sel[3][0] [0]),
        .O(\slim_dout_sel[0]_OBUF [1]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[0][1]_INST_0_i_2 
       (.I0(\slim_dout_sel[0][1]_INST_0_i_4_n_0 ),
        .I1(DOUTBDOUT[1]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_0 [1]),
        .I3(\slim_dout_sel[0][28]_INST_0_i_1_2 [2]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_1_2 [0]),
        .O(\slim_dout_sel[0][1]_INST_0_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[0][1]_INST_0_i_3 
       (.I0(\slim_dout_sel[0][1]_INST_0_i_5_n_0 ),
        .I1(DOUTADOUT[1]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_1 [1]),
        .I3(\slim_dout_sel[0][28]_INST_0_i_1_2 [2]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_1_2 [0]),
        .O(\slim_dout_sel[0][1]_INST_0_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[0][1]_INST_0_i_4 
       (.I0(\doutB_bank[1]__0 [1]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_2_0 [1]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_2 [0]),
        .I3(\slim_dout_sel[0][28]_INST_0_i_1_2 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_2_1 [1]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_2_2 [1]),
        .O(\slim_dout_sel[0][1]_INST_0_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[0][1]_INST_0_i_5 
       (.I0(\doutA_bank[1]__0 [1]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_3_0 [1]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_2 [0]),
        .I3(\slim_dout_sel[0][28]_INST_0_i_1_2 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_3_1 [1]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_3_2 [1]),
        .O(\slim_dout_sel[0][1]_INST_0_i_5_n_0 ));
  LUT4 #(
    .INIT(16'hA0C0)) 
    \slim_dout_sel[0][28]_INST_0_i_1 
       (.I0(\slim_dout_sel[0][28]_INST_0_i_2_n_0 ),
        .I1(\slim_dout_sel[0][28]_INST_0_i_3_n_0 ),
        .I2(Q[0]),
        .I3(\slim_dout_sel[3][0] [0]),
        .O(\slim_dout_sel[0]_OBUF [3]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[0][28]_INST_0_i_2 
       (.I0(\slim_dout_sel[0][28]_INST_0_i_4_n_0 ),
        .I1(DOUTBDOUT[3]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_0 [3]),
        .I3(\slim_dout_sel[0][28]_INST_0_i_1_2 [2]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_1_2 [0]),
        .O(\slim_dout_sel[0][28]_INST_0_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[0][28]_INST_0_i_3 
       (.I0(\slim_dout_sel[0][28]_INST_0_i_5_n_0 ),
        .I1(DOUTADOUT[3]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_1 [3]),
        .I3(\slim_dout_sel[0][28]_INST_0_i_1_2 [2]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_1_2 [0]),
        .O(\slim_dout_sel[0][28]_INST_0_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[0][28]_INST_0_i_4 
       (.I0(\doutB_bank[1]__0 [28]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_2_0 [3]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_2 [0]),
        .I3(\slim_dout_sel[0][28]_INST_0_i_1_2 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_2_1 [3]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_2_2 [3]),
        .O(\slim_dout_sel[0][28]_INST_0_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[0][28]_INST_0_i_5 
       (.I0(\doutA_bank[1]__0 [28]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_3_0 [3]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_2 [0]),
        .I3(\slim_dout_sel[0][28]_INST_0_i_1_2 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_3_1 [3]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_3_2 [3]),
        .O(\slim_dout_sel[0][28]_INST_0_i_5_n_0 ));
  LUT4 #(
    .INIT(16'hA0C0)) 
    \slim_dout_sel[0][2]_INST_0_i_1 
       (.I0(\slim_dout_sel[0][2]_INST_0_i_2_n_0 ),
        .I1(\slim_dout_sel[0][2]_INST_0_i_3_n_0 ),
        .I2(Q[0]),
        .I3(\slim_dout_sel[3][0] [0]),
        .O(\slim_dout_sel[0]_OBUF [2]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[0][2]_INST_0_i_2 
       (.I0(\slim_dout_sel[0][2]_INST_0_i_4_n_0 ),
        .I1(DOUTBDOUT[2]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_0 [2]),
        .I3(\slim_dout_sel[0][28]_INST_0_i_1_2 [2]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_1_2 [0]),
        .O(\slim_dout_sel[0][2]_INST_0_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[0][2]_INST_0_i_3 
       (.I0(\slim_dout_sel[0][2]_INST_0_i_5_n_0 ),
        .I1(DOUTADOUT[2]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_1 [2]),
        .I3(\slim_dout_sel[0][28]_INST_0_i_1_2 [2]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_1_2 [0]),
        .O(\slim_dout_sel[0][2]_INST_0_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[0][2]_INST_0_i_4 
       (.I0(\doutB_bank[1]__0 [2]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_2_0 [2]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_2 [0]),
        .I3(\slim_dout_sel[0][28]_INST_0_i_1_2 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_2_1 [2]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_2_2 [2]),
        .O(\slim_dout_sel[0][2]_INST_0_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[0][2]_INST_0_i_5 
       (.I0(\doutA_bank[1]__0 [2]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_3_0 [2]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_2 [0]),
        .I3(\slim_dout_sel[0][28]_INST_0_i_1_2 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_3_1 [2]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_3_2 [2]),
        .O(\slim_dout_sel[0][2]_INST_0_i_5_n_0 ));
  LUT4 #(
    .INIT(16'hA0C0)) 
    \slim_dout_sel[1][0]_INST_0_i_1 
       (.I0(\slim_dout_sel[1][0]_INST_0_i_2_n_0 ),
        .I1(\slim_dout_sel[1][0]_INST_0_i_3_n_0 ),
        .I2(Q[1]),
        .I3(\slim_dout_sel[3][0] [1]),
        .O(\slim_dout_sel[1]_OBUF [0]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[1][0]_INST_0_i_2 
       (.I0(\slim_dout_sel[1][0]_INST_0_i_4_n_0 ),
        .I1(DOUTBDOUT[0]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[1][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[1][28]_INST_0_i_1_0 [0]),
        .O(\slim_dout_sel[1][0]_INST_0_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[1][0]_INST_0_i_3 
       (.I0(\slim_dout_sel[1][0]_INST_0_i_5_n_0 ),
        .I1(DOUTADOUT[0]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_1 [0]),
        .I3(\slim_dout_sel[1][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[1][28]_INST_0_i_1_0 [0]),
        .O(\slim_dout_sel[1][0]_INST_0_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[1][0]_INST_0_i_4 
       (.I0(\doutB_bank[1]__0 [0]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_2_0 [0]),
        .I2(\slim_dout_sel[1][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[1][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_2_1 [0]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_2_2 [0]),
        .O(\slim_dout_sel[1][0]_INST_0_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[1][0]_INST_0_i_5 
       (.I0(\doutA_bank[1]__0 [0]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_3_0 [0]),
        .I2(\slim_dout_sel[1][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[1][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_3_1 [0]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_3_2 [0]),
        .O(\slim_dout_sel[1][0]_INST_0_i_5_n_0 ));
  LUT4 #(
    .INIT(16'hA0C0)) 
    \slim_dout_sel[1][1]_INST_0_i_1 
       (.I0(\slim_dout_sel[1][1]_INST_0_i_2_n_0 ),
        .I1(\slim_dout_sel[1][1]_INST_0_i_3_n_0 ),
        .I2(Q[1]),
        .I3(\slim_dout_sel[3][0] [1]),
        .O(\slim_dout_sel[1]_OBUF [1]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[1][1]_INST_0_i_2 
       (.I0(\slim_dout_sel[1][1]_INST_0_i_4_n_0 ),
        .I1(DOUTBDOUT[1]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_0 [1]),
        .I3(\slim_dout_sel[1][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[1][28]_INST_0_i_1_0 [0]),
        .O(\slim_dout_sel[1][1]_INST_0_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[1][1]_INST_0_i_3 
       (.I0(\slim_dout_sel[1][1]_INST_0_i_5_n_0 ),
        .I1(DOUTADOUT[1]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_1 [1]),
        .I3(\slim_dout_sel[1][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[1][28]_INST_0_i_1_0 [0]),
        .O(\slim_dout_sel[1][1]_INST_0_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[1][1]_INST_0_i_4 
       (.I0(\doutB_bank[1]__0 [1]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_2_0 [1]),
        .I2(\slim_dout_sel[1][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[1][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_2_1 [1]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_2_2 [1]),
        .O(\slim_dout_sel[1][1]_INST_0_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[1][1]_INST_0_i_5 
       (.I0(\doutA_bank[1]__0 [1]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_3_0 [1]),
        .I2(\slim_dout_sel[1][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[1][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_3_1 [1]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_3_2 [1]),
        .O(\slim_dout_sel[1][1]_INST_0_i_5_n_0 ));
  LUT4 #(
    .INIT(16'hA0C0)) 
    \slim_dout_sel[1][28]_INST_0_i_1 
       (.I0(\slim_dout_sel[1][28]_INST_0_i_2_n_0 ),
        .I1(\slim_dout_sel[1][28]_INST_0_i_3_n_0 ),
        .I2(Q[1]),
        .I3(\slim_dout_sel[3][0] [1]),
        .O(\slim_dout_sel[1]_OBUF [3]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[1][28]_INST_0_i_2 
       (.I0(\slim_dout_sel[1][28]_INST_0_i_4_n_0 ),
        .I1(DOUTBDOUT[3]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_0 [3]),
        .I3(\slim_dout_sel[1][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[1][28]_INST_0_i_1_0 [0]),
        .O(\slim_dout_sel[1][28]_INST_0_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[1][28]_INST_0_i_3 
       (.I0(\slim_dout_sel[1][28]_INST_0_i_5_n_0 ),
        .I1(DOUTADOUT[3]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_1 [3]),
        .I3(\slim_dout_sel[1][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[1][28]_INST_0_i_1_0 [0]),
        .O(\slim_dout_sel[1][28]_INST_0_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[1][28]_INST_0_i_4 
       (.I0(\doutB_bank[1]__0 [28]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_2_0 [3]),
        .I2(\slim_dout_sel[1][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[1][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_2_1 [3]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_2_2 [3]),
        .O(\slim_dout_sel[1][28]_INST_0_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[1][28]_INST_0_i_5 
       (.I0(\doutA_bank[1]__0 [28]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_3_0 [3]),
        .I2(\slim_dout_sel[1][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[1][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_3_1 [3]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_3_2 [3]),
        .O(\slim_dout_sel[1][28]_INST_0_i_5_n_0 ));
  LUT4 #(
    .INIT(16'hA0C0)) 
    \slim_dout_sel[1][2]_INST_0_i_1 
       (.I0(\slim_dout_sel[1][2]_INST_0_i_2_n_0 ),
        .I1(\slim_dout_sel[1][2]_INST_0_i_3_n_0 ),
        .I2(Q[1]),
        .I3(\slim_dout_sel[3][0] [1]),
        .O(\slim_dout_sel[1]_OBUF [2]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[1][2]_INST_0_i_2 
       (.I0(\slim_dout_sel[1][2]_INST_0_i_4_n_0 ),
        .I1(DOUTBDOUT[2]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_0 [2]),
        .I3(\slim_dout_sel[1][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[1][28]_INST_0_i_1_0 [0]),
        .O(\slim_dout_sel[1][2]_INST_0_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[1][2]_INST_0_i_3 
       (.I0(\slim_dout_sel[1][2]_INST_0_i_5_n_0 ),
        .I1(DOUTADOUT[2]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_1 [2]),
        .I3(\slim_dout_sel[1][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[1][28]_INST_0_i_1_0 [0]),
        .O(\slim_dout_sel[1][2]_INST_0_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[1][2]_INST_0_i_4 
       (.I0(\doutB_bank[1]__0 [2]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_2_0 [2]),
        .I2(\slim_dout_sel[1][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[1][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_2_1 [2]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_2_2 [2]),
        .O(\slim_dout_sel[1][2]_INST_0_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[1][2]_INST_0_i_5 
       (.I0(\doutA_bank[1]__0 [2]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_3_0 [2]),
        .I2(\slim_dout_sel[1][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[1][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_3_1 [2]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_3_2 [2]),
        .O(\slim_dout_sel[1][2]_INST_0_i_5_n_0 ));
  LUT4 #(
    .INIT(16'hA0C0)) 
    \slim_dout_sel[2][0]_INST_0_i_1 
       (.I0(\slim_dout_sel[2][0]_INST_0_i_2_n_0 ),
        .I1(\slim_dout_sel[2][0]_INST_0_i_3_n_0 ),
        .I2(Q[2]),
        .I3(\slim_dout_sel[3][0] [2]),
        .O(\slim_dout_sel[2]_OBUF [0]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[2][0]_INST_0_i_2 
       (.I0(\slim_dout_sel[2][0]_INST_0_i_4_n_0 ),
        .I1(DOUTBDOUT[0]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[2][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[2][28]_INST_0_i_1_0 [0]),
        .O(\slim_dout_sel[2][0]_INST_0_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[2][0]_INST_0_i_3 
       (.I0(\slim_dout_sel[2][0]_INST_0_i_5_n_0 ),
        .I1(DOUTADOUT[0]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_1 [0]),
        .I3(\slim_dout_sel[2][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[2][28]_INST_0_i_1_0 [0]),
        .O(\slim_dout_sel[2][0]_INST_0_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[2][0]_INST_0_i_4 
       (.I0(\doutB_bank[1]__0 [0]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_2_0 [0]),
        .I2(\slim_dout_sel[2][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[2][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_2_1 [0]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_2_2 [0]),
        .O(\slim_dout_sel[2][0]_INST_0_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[2][0]_INST_0_i_5 
       (.I0(\doutA_bank[1]__0 [0]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_3_0 [0]),
        .I2(\slim_dout_sel[2][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[2][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_3_1 [0]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_3_2 [0]),
        .O(\slim_dout_sel[2][0]_INST_0_i_5_n_0 ));
  LUT4 #(
    .INIT(16'hA0C0)) 
    \slim_dout_sel[2][1]_INST_0_i_1 
       (.I0(\slim_dout_sel[2][1]_INST_0_i_2_n_0 ),
        .I1(\slim_dout_sel[2][1]_INST_0_i_3_n_0 ),
        .I2(Q[2]),
        .I3(\slim_dout_sel[3][0] [2]),
        .O(\slim_dout_sel[2]_OBUF [1]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[2][1]_INST_0_i_2 
       (.I0(\slim_dout_sel[2][1]_INST_0_i_4_n_0 ),
        .I1(DOUTBDOUT[1]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_0 [1]),
        .I3(\slim_dout_sel[2][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[2][28]_INST_0_i_1_0 [0]),
        .O(\slim_dout_sel[2][1]_INST_0_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[2][1]_INST_0_i_3 
       (.I0(\slim_dout_sel[2][1]_INST_0_i_5_n_0 ),
        .I1(DOUTADOUT[1]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_1 [1]),
        .I3(\slim_dout_sel[2][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[2][28]_INST_0_i_1_0 [0]),
        .O(\slim_dout_sel[2][1]_INST_0_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[2][1]_INST_0_i_4 
       (.I0(\doutB_bank[1]__0 [1]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_2_0 [1]),
        .I2(\slim_dout_sel[2][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[2][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_2_1 [1]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_2_2 [1]),
        .O(\slim_dout_sel[2][1]_INST_0_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[2][1]_INST_0_i_5 
       (.I0(\doutA_bank[1]__0 [1]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_3_0 [1]),
        .I2(\slim_dout_sel[2][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[2][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_3_1 [1]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_3_2 [1]),
        .O(\slim_dout_sel[2][1]_INST_0_i_5_n_0 ));
  LUT4 #(
    .INIT(16'hA0C0)) 
    \slim_dout_sel[2][28]_INST_0_i_1 
       (.I0(\slim_dout_sel[2][28]_INST_0_i_2_n_0 ),
        .I1(\slim_dout_sel[2][28]_INST_0_i_3_n_0 ),
        .I2(Q[2]),
        .I3(\slim_dout_sel[3][0] [2]),
        .O(\slim_dout_sel[2]_OBUF [3]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[2][28]_INST_0_i_2 
       (.I0(\slim_dout_sel[2][28]_INST_0_i_4_n_0 ),
        .I1(DOUTBDOUT[3]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_0 [3]),
        .I3(\slim_dout_sel[2][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[2][28]_INST_0_i_1_0 [0]),
        .O(\slim_dout_sel[2][28]_INST_0_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[2][28]_INST_0_i_3 
       (.I0(\slim_dout_sel[2][28]_INST_0_i_5_n_0 ),
        .I1(DOUTADOUT[3]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_1 [3]),
        .I3(\slim_dout_sel[2][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[2][28]_INST_0_i_1_0 [0]),
        .O(\slim_dout_sel[2][28]_INST_0_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[2][28]_INST_0_i_4 
       (.I0(\doutB_bank[1]__0 [28]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_2_0 [3]),
        .I2(\slim_dout_sel[2][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[2][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_2_1 [3]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_2_2 [3]),
        .O(\slim_dout_sel[2][28]_INST_0_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[2][28]_INST_0_i_5 
       (.I0(\doutA_bank[1]__0 [28]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_3_0 [3]),
        .I2(\slim_dout_sel[2][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[2][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_3_1 [3]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_3_2 [3]),
        .O(\slim_dout_sel[2][28]_INST_0_i_5_n_0 ));
  LUT4 #(
    .INIT(16'hA0C0)) 
    \slim_dout_sel[2][2]_INST_0_i_1 
       (.I0(\slim_dout_sel[2][2]_INST_0_i_2_n_0 ),
        .I1(\slim_dout_sel[2][2]_INST_0_i_3_n_0 ),
        .I2(Q[2]),
        .I3(\slim_dout_sel[3][0] [2]),
        .O(\slim_dout_sel[2]_OBUF [2]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[2][2]_INST_0_i_2 
       (.I0(\slim_dout_sel[2][2]_INST_0_i_4_n_0 ),
        .I1(DOUTBDOUT[2]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_0 [2]),
        .I3(\slim_dout_sel[2][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[2][28]_INST_0_i_1_0 [0]),
        .O(\slim_dout_sel[2][2]_INST_0_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[2][2]_INST_0_i_3 
       (.I0(\slim_dout_sel[2][2]_INST_0_i_5_n_0 ),
        .I1(DOUTADOUT[2]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_1 [2]),
        .I3(\slim_dout_sel[2][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[2][28]_INST_0_i_1_0 [0]),
        .O(\slim_dout_sel[2][2]_INST_0_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[2][2]_INST_0_i_4 
       (.I0(\doutB_bank[1]__0 [2]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_2_0 [2]),
        .I2(\slim_dout_sel[2][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[2][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_2_1 [2]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_2_2 [2]),
        .O(\slim_dout_sel[2][2]_INST_0_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[2][2]_INST_0_i_5 
       (.I0(\doutA_bank[1]__0 [2]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_3_0 [2]),
        .I2(\slim_dout_sel[2][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[2][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_3_1 [2]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_3_2 [2]),
        .O(\slim_dout_sel[2][2]_INST_0_i_5_n_0 ));
  LUT4 #(
    .INIT(16'hA0C0)) 
    \slim_dout_sel[3][0]_INST_0_i_1 
       (.I0(doutB_bank__29[0]),
        .I1(doutA_bank__29[0]),
        .I2(Q[3]),
        .I3(\slim_dout_sel[3][0] [3]),
        .O(\slim_dout_sel[3]_OBUF [0]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[3][0]_INST_0_i_2 
       (.I0(\slim_dout_sel[3][0]_INST_0_i_4_n_0 ),
        .I1(DOUTBDOUT[0]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[3][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[3][28]_INST_0_i_1_0 [0]),
        .O(doutB_bank__29[0]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[3][0]_INST_0_i_3 
       (.I0(\slim_dout_sel[3][0]_INST_0_i_5_n_0 ),
        .I1(DOUTADOUT[0]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_1 [0]),
        .I3(\slim_dout_sel[3][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[3][28]_INST_0_i_1_0 [0]),
        .O(doutA_bank__29[0]));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[3][0]_INST_0_i_4 
       (.I0(\doutB_bank[1]__0 [0]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_2_0 [0]),
        .I2(\slim_dout_sel[3][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[3][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_2_1 [0]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_2_2 [0]),
        .O(\slim_dout_sel[3][0]_INST_0_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[3][0]_INST_0_i_5 
       (.I0(\doutA_bank[1]__0 [0]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_3_0 [0]),
        .I2(\slim_dout_sel[3][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[3][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_3_1 [0]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_3_2 [0]),
        .O(\slim_dout_sel[3][0]_INST_0_i_5_n_0 ));
  LUT4 #(
    .INIT(16'hA0C0)) 
    \slim_dout_sel[3][1]_INST_0_i_1 
       (.I0(doutB_bank__29[1]),
        .I1(doutA_bank__29[1]),
        .I2(Q[3]),
        .I3(\slim_dout_sel[3][0] [3]),
        .O(\slim_dout_sel[3]_OBUF [1]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[3][1]_INST_0_i_2 
       (.I0(\slim_dout_sel[3][1]_INST_0_i_4_n_0 ),
        .I1(DOUTBDOUT[1]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_0 [1]),
        .I3(\slim_dout_sel[3][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[3][28]_INST_0_i_1_0 [0]),
        .O(doutB_bank__29[1]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[3][1]_INST_0_i_3 
       (.I0(\slim_dout_sel[3][1]_INST_0_i_5_n_0 ),
        .I1(DOUTADOUT[1]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_1 [1]),
        .I3(\slim_dout_sel[3][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[3][28]_INST_0_i_1_0 [0]),
        .O(doutA_bank__29[1]));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[3][1]_INST_0_i_4 
       (.I0(\doutB_bank[1]__0 [1]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_2_0 [1]),
        .I2(\slim_dout_sel[3][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[3][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_2_1 [1]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_2_2 [1]),
        .O(\slim_dout_sel[3][1]_INST_0_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[3][1]_INST_0_i_5 
       (.I0(\doutA_bank[1]__0 [1]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_3_0 [1]),
        .I2(\slim_dout_sel[3][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[3][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_3_1 [1]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_3_2 [1]),
        .O(\slim_dout_sel[3][1]_INST_0_i_5_n_0 ));
  LUT4 #(
    .INIT(16'hA0C0)) 
    \slim_dout_sel[3][28]_INST_0_i_1 
       (.I0(doutB_bank__29[28]),
        .I1(doutA_bank__29[28]),
        .I2(Q[3]),
        .I3(\slim_dout_sel[3][0] [3]),
        .O(\slim_dout_sel[3]_OBUF [3]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[3][28]_INST_0_i_2 
       (.I0(\slim_dout_sel[3][28]_INST_0_i_4_n_0 ),
        .I1(DOUTBDOUT[3]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_0 [3]),
        .I3(\slim_dout_sel[3][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[3][28]_INST_0_i_1_0 [0]),
        .O(doutB_bank__29[28]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[3][28]_INST_0_i_3 
       (.I0(\slim_dout_sel[3][28]_INST_0_i_5_n_0 ),
        .I1(DOUTADOUT[3]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_1 [3]),
        .I3(\slim_dout_sel[3][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[3][28]_INST_0_i_1_0 [0]),
        .O(doutA_bank__29[28]));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[3][28]_INST_0_i_4 
       (.I0(\doutB_bank[1]__0 [28]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_2_0 [3]),
        .I2(\slim_dout_sel[3][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[3][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_2_1 [3]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_2_2 [3]),
        .O(\slim_dout_sel[3][28]_INST_0_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[3][28]_INST_0_i_5 
       (.I0(\doutA_bank[1]__0 [28]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_3_0 [3]),
        .I2(\slim_dout_sel[3][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[3][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_3_1 [3]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_3_2 [3]),
        .O(\slim_dout_sel[3][28]_INST_0_i_5_n_0 ));
  LUT4 #(
    .INIT(16'hA0C0)) 
    \slim_dout_sel[3][2]_INST_0_i_1 
       (.I0(doutB_bank__29[2]),
        .I1(doutA_bank__29[2]),
        .I2(Q[3]),
        .I3(\slim_dout_sel[3][0] [3]),
        .O(\slim_dout_sel[3]_OBUF [2]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[3][2]_INST_0_i_2 
       (.I0(\slim_dout_sel[3][2]_INST_0_i_4_n_0 ),
        .I1(DOUTBDOUT[2]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_0 [2]),
        .I3(\slim_dout_sel[3][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[3][28]_INST_0_i_1_0 [0]),
        .O(doutB_bank__29[2]));
  LUT5 #(
    .INIT(32'hF0AACCAA)) 
    \slim_dout_sel[3][2]_INST_0_i_3 
       (.I0(\slim_dout_sel[3][2]_INST_0_i_5_n_0 ),
        .I1(DOUTADOUT[2]),
        .I2(\slim_dout_sel[0][28]_INST_0_i_1_1 [2]),
        .I3(\slim_dout_sel[3][28]_INST_0_i_1_0 [2]),
        .I4(\slim_dout_sel[3][28]_INST_0_i_1_0 [0]),
        .O(doutA_bank__29[2]));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[3][2]_INST_0_i_4 
       (.I0(\doutB_bank[1]__0 [2]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_2_0 [2]),
        .I2(\slim_dout_sel[3][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[3][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_2_1 [2]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_2_2 [2]),
        .O(\slim_dout_sel[3][2]_INST_0_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hCFAFCFA0C0AFC0A0)) 
    \slim_dout_sel[3][2]_INST_0_i_5 
       (.I0(\doutA_bank[1]__0 [2]),
        .I1(\slim_dout_sel[0][28]_INST_0_i_3_0 [2]),
        .I2(\slim_dout_sel[3][28]_INST_0_i_1_0 [0]),
        .I3(\slim_dout_sel[3][28]_INST_0_i_1_0 [1]),
        .I4(\slim_dout_sel[0][28]_INST_0_i_3_1 [2]),
        .I5(\slim_dout_sel[0][28]_INST_0_i_3_2 [2]),
        .O(\slim_dout_sel[3][2]_INST_0_i_5_n_0 ));
endmodule

(* ORIG_REF_NAME = "reuse_weight_bank_rom" *) 
module reuse_weight_bank_rom__parameterized1
   (DOUTADOUT,
    DOUTBDOUT,
    clk_IBUF_BUFG,
    D,
    slim_port_sel_IBUF,
    slim_en_sel_IBUF,
    dout_a_reg_0,
    dout_a_reg_1,
    dout_a_reg_2,
    dout_a_reg_3,
    dout_a_reg_4,
    dout_a_reg_5,
    dout_a_reg_6,
    dout_a_reg_7,
    dout_a_reg_8,
    dout_a_reg_9,
    dout_a_reg_10,
    dout_a_reg_11,
    dout_a_reg_12,
    dout_a_reg_13,
    dout_a_reg_14);
  output [4:0]DOUTADOUT;
  output [4:0]DOUTBDOUT;
  input clk_IBUF_BUFG;
  input [2:0]D;
  input [3:0]slim_port_sel_IBUF;
  input [3:0]slim_en_sel_IBUF;
  input dout_a_reg_0;
  input dout_a_reg_1;
  input dout_a_reg_2;
  input dout_a_reg_3;
  input dout_a_reg_4;
  input dout_a_reg_5;
  input dout_a_reg_6;
  input dout_a_reg_7;
  input dout_a_reg_8;
  input dout_a_reg_9;
  input dout_a_reg_10;
  input dout_a_reg_11;
  input [2:0]dout_a_reg_12;
  input [2:0]dout_a_reg_13;
  input [2:0]dout_a_reg_14;

  wire [2:0]D;
  wire [4:0]DOUTADOUT;
  wire [4:0]DOUTBDOUT;
  wire [2:0]\addrA_bank[2]_6 ;
  wire [2:0]\addrB_bank[2]_13 ;
  wire clk_IBUF_BUFG;
  wire dout_a_reg_0;
  wire dout_a_reg_1;
  wire dout_a_reg_10;
  wire dout_a_reg_11;
  wire [2:0]dout_a_reg_12;
  wire [2:0]dout_a_reg_13;
  wire [2:0]dout_a_reg_14;
  wire dout_a_reg_2;
  wire dout_a_reg_3;
  wire dout_a_reg_4;
  wire dout_a_reg_5;
  wire dout_a_reg_6;
  wire dout_a_reg_7;
  wire dout_a_reg_8;
  wire dout_a_reg_9;
  wire dout_a_reg_i_10__3_n_0;
  wire dout_a_reg_i_11__1_n_0;
  wire dout_a_reg_i_12__1_n_0;
  wire dout_a_reg_i_13__2_n_0;
  wire dout_a_reg_i_14__1_n_0;
  wire dout_a_reg_i_15__2_n_0;
  wire dout_a_reg_i_16__2_n_0;
  wire dout_a_reg_i_17__0_n_0;
  wire dout_a_reg_i_18__0_n_0;
  wire dout_a_reg_i_19__1_n_0;
  wire dout_a_reg_i_20__2_n_0;
  wire dout_a_reg_i_21__2_n_0;
  wire dout_a_reg_i_22__3_n_0;
  wire dout_a_reg_i_9__2_n_0;
  wire [2:2]enA_bank;
  wire [2:2]enB_bank;
  wire [3:0]slim_en_sel_IBUF;
  wire [3:0]slim_port_sel_IBUF;
  wire [15:0]NLW_dout_a_reg_CASDOUTA_UNCONNECTED;
  wire [15:0]NLW_dout_a_reg_CASDOUTB_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_CASDOUTPA_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_CASDOUTPB_UNCONNECTED;
  wire [15:5]NLW_dout_a_reg_DOUTADOUT_UNCONNECTED;
  wire [15:5]NLW_dout_a_reg_DOUTBDOUT_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_DOUTPADOUTP_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_DOUTPBDOUTP_UNCONNECTED;

  (* \MEM.PORTA.DATA_BIT_LAYOUT  = "p0_d5" *) 
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-6 {cell *THIS*}}" *) 
  (* OPT_MODIFIED = "MLO" *) 
  (* RDADDR_COLLISION_HWCONFIG = "PERFORMANCE" *) 
  (* RTL_RAM_BITS = "40" *) 
  (* RTL_RAM_NAME = "u_wbuf/WBUF_BANK[2].g_bank2.u_bank/dout_a_reg" *) 
  (* RTL_RAM_TYPE = "RAM_SP" *) 
  (* ram_addr_begin = "0" *) 
  (* ram_addr_end = "1023" *) 
  (* ram_offset = "0" *) 
  (* ram_slice_begin = "0" *) 
  (* ram_slice_end = "4" *) 
  RAMB18E2 #(
    .CASCADE_ORDER_A("NONE"),
    .CASCADE_ORDER_B("NONE"),
    .CLOCK_DOMAINS("COMMON"),
    .DOA_REG(0),
    .DOB_REG(0),
    .ENADDRENA("FALSE"),
    .ENADDRENB("FALSE"),
    .INITP_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_00(256'h00000000000000000000000000000000000F000E000D000C000B000A00090008),
    .INIT_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_10(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_11(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_12(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_13(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_14(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_15(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_16(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_17(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_18(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_19(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_20(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_21(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_22(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_23(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_24(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_25(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_26(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_27(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_28(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_29(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_30(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_31(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_32(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_33(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_34(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_35(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_36(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_37(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_38(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_39(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_A(18'h00000),
    .INIT_B(18'h00000),
    .INIT_FILE("NONE"),
    .RDADDRCHANGEA("FALSE"),
    .RDADDRCHANGEB("FALSE"),
    .READ_WIDTH_A(18),
    .READ_WIDTH_B(18),
    .RSTREG_PRIORITY_A("RSTREG"),
    .RSTREG_PRIORITY_B("RSTREG"),
    .SIM_COLLISION_CHECK("ALL"),
    .SLEEP_ASYNC("FALSE"),
    .SRVAL_A(18'h00000),
    .SRVAL_B(18'h00000),
    .WRITE_MODE_A("WRITE_FIRST"),
    .WRITE_MODE_B("WRITE_FIRST"),
    .WRITE_WIDTH_A(18),
    .WRITE_WIDTH_B(0)) 
    dout_a_reg
       (.ADDRARDADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\addrA_bank[2]_6 ,1'b0,1'b0,1'b0,1'b0}),
        .ADDRBWRADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\addrB_bank[2]_13 ,1'b0,1'b0,1'b0,1'b0}),
        .ADDRENA(1'b1),
        .ADDRENB(1'b1),
        .CASDIMUXA(1'b0),
        .CASDIMUXB(1'b0),
        .CASDINA({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .CASDINB({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .CASDINPA({1'b0,1'b0}),
        .CASDINPB({1'b0,1'b0}),
        .CASDOMUXA(1'b0),
        .CASDOMUXB(1'b0),
        .CASDOMUXEN_A(1'b1),
        .CASDOMUXEN_B(1'b1),
        .CASDOUTA(NLW_dout_a_reg_CASDOUTA_UNCONNECTED[15:0]),
        .CASDOUTB(NLW_dout_a_reg_CASDOUTB_UNCONNECTED[15:0]),
        .CASDOUTPA(NLW_dout_a_reg_CASDOUTPA_UNCONNECTED[1:0]),
        .CASDOUTPB(NLW_dout_a_reg_CASDOUTPB_UNCONNECTED[1:0]),
        .CASOREGIMUXA(1'b0),
        .CASOREGIMUXB(1'b0),
        .CASOREGIMUXEN_A(1'b1),
        .CASOREGIMUXEN_B(1'b1),
        .CLKARDCLK(clk_IBUF_BUFG),
        .CLKBWRCLK(clk_IBUF_BUFG),
        .DINADIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .DINBDIN({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .DINPADINP({1'b0,1'b0}),
        .DINPBDINP({1'b1,1'b1}),
        .DOUTADOUT({NLW_dout_a_reg_DOUTADOUT_UNCONNECTED[15:5],DOUTADOUT}),
        .DOUTBDOUT({NLW_dout_a_reg_DOUTBDOUT_UNCONNECTED[15:5],DOUTBDOUT}),
        .DOUTPADOUTP(NLW_dout_a_reg_DOUTPADOUTP_UNCONNECTED[1:0]),
        .DOUTPBDOUTP(NLW_dout_a_reg_DOUTPBDOUTP_UNCONNECTED[1:0]),
        .ENARDEN(enA_bank),
        .ENBWREN(enB_bank),
        .REGCEAREGCE(1'b1),
        .REGCEB(1'b1),
        .RSTRAMARSTRAM(1'b0),
        .RSTRAMB(1'b0),
        .RSTREGARSTREG(1'b0),
        .RSTREGB(1'b0),
        .SLEEP(1'b0),
        .WEA({1'b0,1'b0}),
        .WEBWE({1'b0,1'b0,1'b0,1'b0}));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT5 #(
    .INIT(32'hFFFFFDFF)) 
    dout_a_reg_i_10__3
       (.I0(slim_en_sel_IBUF[0]),
        .I1(slim_port_sel_IBUF[0]),
        .I2(dout_a_reg_14[2]),
        .I3(dout_a_reg_14[1]),
        .I4(dout_a_reg_14[0]),
        .O(dout_a_reg_i_10__3_n_0));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT5 #(
    .INIT(32'hFFFFFDFF)) 
    dout_a_reg_i_11__1
       (.I0(slim_en_sel_IBUF[1]),
        .I1(slim_port_sel_IBUF[1]),
        .I2(dout_a_reg_12[2]),
        .I3(dout_a_reg_12[1]),
        .I4(dout_a_reg_12[0]),
        .O(dout_a_reg_i_11__1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT5 #(
    .INIT(32'h00000400)) 
    dout_a_reg_i_12__1
       (.I0(slim_port_sel_IBUF[3]),
        .I1(slim_en_sel_IBUF[3]),
        .I2(dout_a_reg_13[2]),
        .I3(dout_a_reg_13[1]),
        .I4(dout_a_reg_13[0]),
        .O(dout_a_reg_i_12__1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT5 #(
    .INIT(32'hFBFFFFFF)) 
    dout_a_reg_i_13__2
       (.I0(dout_a_reg_12[2]),
        .I1(dout_a_reg_12[1]),
        .I2(dout_a_reg_12[0]),
        .I3(slim_en_sel_IBUF[1]),
        .I4(slim_port_sel_IBUF[1]),
        .O(dout_a_reg_i_13__2_n_0));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT5 #(
    .INIT(32'hFBFFFFFF)) 
    dout_a_reg_i_14__1
       (.I0(dout_a_reg_14[2]),
        .I1(dout_a_reg_14[1]),
        .I2(dout_a_reg_14[0]),
        .I3(slim_port_sel_IBUF[0]),
        .I4(slim_en_sel_IBUF[0]),
        .O(dout_a_reg_i_14__1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT5 #(
    .INIT(32'h04000000)) 
    dout_a_reg_i_15__2
       (.I0(D[2]),
        .I1(D[1]),
        .I2(D[0]),
        .I3(slim_en_sel_IBUF[2]),
        .I4(slim_port_sel_IBUF[2]),
        .O(dout_a_reg_i_15__2_n_0));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT5 #(
    .INIT(32'h04000000)) 
    dout_a_reg_i_16__2
       (.I0(dout_a_reg_13[2]),
        .I1(dout_a_reg_13[1]),
        .I2(dout_a_reg_13[0]),
        .I3(slim_en_sel_IBUF[3]),
        .I4(slim_port_sel_IBUF[3]),
        .O(dout_a_reg_i_16__2_n_0));
  LUT5 #(
    .INIT(32'h44F0FFFF)) 
    dout_a_reg_i_17__0
       (.I0(dout_a_reg_i_10__3_n_0),
        .I1(dout_a_reg_10),
        .I2(dout_a_reg_11),
        .I3(dout_a_reg_i_11__1_n_0),
        .I4(dout_a_reg_i_9__2_n_0),
        .O(dout_a_reg_i_17__0_n_0));
  LUT5 #(
    .INIT(32'h44F0FFFF)) 
    dout_a_reg_i_18__0
       (.I0(dout_a_reg_i_10__3_n_0),
        .I1(dout_a_reg_6),
        .I2(dout_a_reg_7),
        .I3(dout_a_reg_i_11__1_n_0),
        .I4(dout_a_reg_i_9__2_n_0),
        .O(dout_a_reg_i_18__0_n_0));
  LUT5 #(
    .INIT(32'h44F0FFFF)) 
    dout_a_reg_i_19__1
       (.I0(dout_a_reg_i_10__3_n_0),
        .I1(dout_a_reg_2),
        .I2(dout_a_reg_3),
        .I3(dout_a_reg_i_11__1_n_0),
        .I4(dout_a_reg_i_9__2_n_0),
        .O(dout_a_reg_i_19__1_n_0));
  LUT4 #(
    .INIT(16'hFF7F)) 
    dout_a_reg_i_1__1
       (.I0(dout_a_reg_i_9__2_n_0),
        .I1(dout_a_reg_i_10__3_n_0),
        .I2(dout_a_reg_i_11__1_n_0),
        .I3(dout_a_reg_i_12__1_n_0),
        .O(enA_bank));
  LUT5 #(
    .INIT(32'hFFFF44F0)) 
    dout_a_reg_i_20__2
       (.I0(dout_a_reg_i_14__1_n_0),
        .I1(dout_a_reg_10),
        .I2(dout_a_reg_11),
        .I3(dout_a_reg_i_13__2_n_0),
        .I4(dout_a_reg_i_15__2_n_0),
        .O(dout_a_reg_i_20__2_n_0));
  LUT5 #(
    .INIT(32'hFFFF44F0)) 
    dout_a_reg_i_21__2
       (.I0(dout_a_reg_i_14__1_n_0),
        .I1(dout_a_reg_6),
        .I2(dout_a_reg_7),
        .I3(dout_a_reg_i_13__2_n_0),
        .I4(dout_a_reg_i_15__2_n_0),
        .O(dout_a_reg_i_21__2_n_0));
  LUT5 #(
    .INIT(32'hFFFF44F0)) 
    dout_a_reg_i_22__3
       (.I0(dout_a_reg_i_14__1_n_0),
        .I1(dout_a_reg_2),
        .I2(dout_a_reg_3),
        .I3(dout_a_reg_i_13__2_n_0),
        .I4(dout_a_reg_i_15__2_n_0),
        .O(dout_a_reg_i_22__3_n_0));
  LUT4 #(
    .INIT(16'hFFF7)) 
    dout_a_reg_i_2__2
       (.I0(dout_a_reg_i_13__2_n_0),
        .I1(dout_a_reg_i_14__1_n_0),
        .I2(dout_a_reg_i_15__2_n_0),
        .I3(dout_a_reg_i_16__2_n_0),
        .O(enB_bank));
  LUT5 #(
    .INIT(32'hBBB88888)) 
    dout_a_reg_i_3__1
       (.I0(dout_a_reg_8),
        .I1(dout_a_reg_i_12__1_n_0),
        .I2(dout_a_reg_i_9__2_n_0),
        .I3(dout_a_reg_9),
        .I4(dout_a_reg_i_17__0_n_0),
        .O(\addrA_bank[2]_6 [2]));
  LUT5 #(
    .INIT(32'hBBB88888)) 
    dout_a_reg_i_4__1
       (.I0(dout_a_reg_4),
        .I1(dout_a_reg_i_12__1_n_0),
        .I2(dout_a_reg_i_9__2_n_0),
        .I3(dout_a_reg_5),
        .I4(dout_a_reg_i_18__0_n_0),
        .O(\addrA_bank[2]_6 [1]));
  LUT5 #(
    .INIT(32'hBBB88888)) 
    dout_a_reg_i_5__1
       (.I0(dout_a_reg_0),
        .I1(dout_a_reg_i_12__1_n_0),
        .I2(dout_a_reg_i_9__2_n_0),
        .I3(dout_a_reg_1),
        .I4(dout_a_reg_i_19__1_n_0),
        .O(\addrA_bank[2]_6 [0]));
  LUT5 #(
    .INIT(32'hB8BB8888)) 
    dout_a_reg_i_6__2
       (.I0(dout_a_reg_8),
        .I1(dout_a_reg_i_16__2_n_0),
        .I2(dout_a_reg_9),
        .I3(dout_a_reg_i_15__2_n_0),
        .I4(dout_a_reg_i_20__2_n_0),
        .O(\addrB_bank[2]_13 [2]));
  LUT5 #(
    .INIT(32'hB8BB8888)) 
    dout_a_reg_i_7__2
       (.I0(dout_a_reg_4),
        .I1(dout_a_reg_i_16__2_n_0),
        .I2(dout_a_reg_5),
        .I3(dout_a_reg_i_15__2_n_0),
        .I4(dout_a_reg_i_21__2_n_0),
        .O(\addrB_bank[2]_13 [1]));
  LUT5 #(
    .INIT(32'hB8BB8888)) 
    dout_a_reg_i_8__2
       (.I0(dout_a_reg_0),
        .I1(dout_a_reg_i_16__2_n_0),
        .I2(dout_a_reg_1),
        .I3(dout_a_reg_i_15__2_n_0),
        .I4(dout_a_reg_i_22__3_n_0),
        .O(\addrB_bank[2]_13 [0]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT5 #(
    .INIT(32'hFFFBFFFF)) 
    dout_a_reg_i_9__2
       (.I0(D[2]),
        .I1(D[1]),
        .I2(D[0]),
        .I3(slim_port_sel_IBUF[2]),
        .I4(slim_en_sel_IBUF[2]),
        .O(dout_a_reg_i_9__2_n_0));
endmodule

(* ORIG_REF_NAME = "reuse_weight_bank_rom" *) 
module reuse_weight_bank_rom__parameterized2
   (DOUTADOUT,
    DOUTBDOUT,
    clk_IBUF_BUFG,
    dout_a_reg_0,
    dout_a_reg_1,
    dout_a_reg_2,
    dout_a_reg_3,
    dout_a_reg_4,
    dout_a_reg_5,
    dout_a_reg_6,
    dout_a_reg_7,
    dout_a_reg_8,
    dout_a_reg_9,
    dout_a_reg_10,
    dout_a_reg_11,
    slim_en_sel_IBUF,
    slim_port_sel_IBUF,
    dout_a_reg_12,
    dout_a_reg_13,
    D,
    dout_a_reg_14);
  output [4:0]DOUTADOUT;
  output [4:0]DOUTBDOUT;
  input clk_IBUF_BUFG;
  input dout_a_reg_0;
  input dout_a_reg_1;
  input dout_a_reg_2;
  input dout_a_reg_3;
  input dout_a_reg_4;
  input dout_a_reg_5;
  input dout_a_reg_6;
  input dout_a_reg_7;
  input dout_a_reg_8;
  input dout_a_reg_9;
  input dout_a_reg_10;
  input dout_a_reg_11;
  input [3:0]slim_en_sel_IBUF;
  input [3:0]slim_port_sel_IBUF;
  input [2:0]dout_a_reg_12;
  input [2:0]dout_a_reg_13;
  input [2:0]D;
  input [2:0]dout_a_reg_14;

  wire [2:0]D;
  wire [4:0]DOUTADOUT;
  wire [4:0]DOUTBDOUT;
  wire [2:0]\addrA_bank[3]_7 ;
  wire [2:0]\addrB_bank[3]_12 ;
  wire clk_IBUF_BUFG;
  wire dout_a_reg_0;
  wire dout_a_reg_1;
  wire dout_a_reg_10;
  wire dout_a_reg_11;
  wire [2:0]dout_a_reg_12;
  wire [2:0]dout_a_reg_13;
  wire [2:0]dout_a_reg_14;
  wire dout_a_reg_2;
  wire dout_a_reg_3;
  wire dout_a_reg_4;
  wire dout_a_reg_5;
  wire dout_a_reg_6;
  wire dout_a_reg_7;
  wire dout_a_reg_8;
  wire dout_a_reg_9;
  wire dout_a_reg_i_10_n_0;
  wire dout_a_reg_i_11__3_n_0;
  wire dout_a_reg_i_12__2_n_0;
  wire dout_a_reg_i_13__1_n_0;
  wire dout_a_reg_i_14__0_n_0;
  wire dout_a_reg_i_15__1_n_0;
  wire dout_a_reg_i_16__1_n_0;
  wire dout_a_reg_i_17__1_n_0;
  wire dout_a_reg_i_18__1_n_0;
  wire dout_a_reg_i_19__2_n_0;
  wire dout_a_reg_i_20__1_n_0;
  wire dout_a_reg_i_21__1_n_0;
  wire dout_a_reg_i_22__2_n_0;
  wire dout_a_reg_i_9_n_0;
  wire [3:3]enA_bank;
  wire [3:3]enB_bank;
  wire [3:0]slim_en_sel_IBUF;
  wire [3:0]slim_port_sel_IBUF;
  wire [15:0]NLW_dout_a_reg_CASDOUTA_UNCONNECTED;
  wire [15:0]NLW_dout_a_reg_CASDOUTB_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_CASDOUTPA_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_CASDOUTPB_UNCONNECTED;
  wire [15:5]NLW_dout_a_reg_DOUTADOUT_UNCONNECTED;
  wire [15:5]NLW_dout_a_reg_DOUTBDOUT_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_DOUTPADOUTP_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_DOUTPBDOUTP_UNCONNECTED;

  (* \MEM.PORTA.DATA_BIT_LAYOUT  = "p0_d5" *) 
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-6 {cell *THIS*}}" *) 
  (* OPT_MODIFIED = "MLO" *) 
  (* RDADDR_COLLISION_HWCONFIG = "PERFORMANCE" *) 
  (* RTL_RAM_BITS = "40" *) 
  (* RTL_RAM_NAME = "u_wbuf/WBUF_BANK[3].g_bank3.u_bank/dout_a_reg" *) 
  (* RTL_RAM_TYPE = "RAM_SP" *) 
  (* ram_addr_begin = "0" *) 
  (* ram_addr_end = "1023" *) 
  (* ram_offset = "0" *) 
  (* ram_slice_begin = "0" *) 
  (* ram_slice_end = "4" *) 
  RAMB18E2 #(
    .CASCADE_ORDER_A("NONE"),
    .CASCADE_ORDER_B("NONE"),
    .CLOCK_DOMAINS("COMMON"),
    .DOA_REG(0),
    .DOB_REG(0),
    .ENADDRENA("FALSE"),
    .ENADDRENB("FALSE"),
    .INITP_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_00(256'h00000000000000000000000000000000000F000E000D000C000B000A00090008),
    .INIT_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_10(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_11(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_12(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_13(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_14(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_15(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_16(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_17(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_18(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_19(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_20(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_21(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_22(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_23(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_24(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_25(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_26(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_27(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_28(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_29(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_30(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_31(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_32(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_33(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_34(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_35(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_36(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_37(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_38(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_39(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_A(18'h00000),
    .INIT_B(18'h00000),
    .INIT_FILE("NONE"),
    .RDADDRCHANGEA("FALSE"),
    .RDADDRCHANGEB("FALSE"),
    .READ_WIDTH_A(18),
    .READ_WIDTH_B(18),
    .RSTREG_PRIORITY_A("RSTREG"),
    .RSTREG_PRIORITY_B("RSTREG"),
    .SIM_COLLISION_CHECK("ALL"),
    .SLEEP_ASYNC("FALSE"),
    .SRVAL_A(18'h00000),
    .SRVAL_B(18'h00000),
    .WRITE_MODE_A("WRITE_FIRST"),
    .WRITE_MODE_B("WRITE_FIRST"),
    .WRITE_WIDTH_A(18),
    .WRITE_WIDTH_B(0)) 
    dout_a_reg
       (.ADDRARDADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\addrA_bank[3]_7 ,1'b0,1'b0,1'b0,1'b0}),
        .ADDRBWRADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\addrB_bank[3]_12 ,1'b0,1'b0,1'b0,1'b0}),
        .ADDRENA(1'b1),
        .ADDRENB(1'b1),
        .CASDIMUXA(1'b0),
        .CASDIMUXB(1'b0),
        .CASDINA({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .CASDINB({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .CASDINPA({1'b0,1'b0}),
        .CASDINPB({1'b0,1'b0}),
        .CASDOMUXA(1'b0),
        .CASDOMUXB(1'b0),
        .CASDOMUXEN_A(1'b1),
        .CASDOMUXEN_B(1'b1),
        .CASDOUTA(NLW_dout_a_reg_CASDOUTA_UNCONNECTED[15:0]),
        .CASDOUTB(NLW_dout_a_reg_CASDOUTB_UNCONNECTED[15:0]),
        .CASDOUTPA(NLW_dout_a_reg_CASDOUTPA_UNCONNECTED[1:0]),
        .CASDOUTPB(NLW_dout_a_reg_CASDOUTPB_UNCONNECTED[1:0]),
        .CASOREGIMUXA(1'b0),
        .CASOREGIMUXB(1'b0),
        .CASOREGIMUXEN_A(1'b1),
        .CASOREGIMUXEN_B(1'b1),
        .CLKARDCLK(clk_IBUF_BUFG),
        .CLKBWRCLK(clk_IBUF_BUFG),
        .DINADIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .DINBDIN({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .DINPADINP({1'b0,1'b0}),
        .DINPBDINP({1'b1,1'b1}),
        .DOUTADOUT({NLW_dout_a_reg_DOUTADOUT_UNCONNECTED[15:5],DOUTADOUT}),
        .DOUTBDOUT({NLW_dout_a_reg_DOUTBDOUT_UNCONNECTED[15:5],DOUTBDOUT}),
        .DOUTPADOUTP(NLW_dout_a_reg_DOUTPADOUTP_UNCONNECTED[1:0]),
        .DOUTPBDOUTP(NLW_dout_a_reg_DOUTPBDOUTP_UNCONNECTED[1:0]),
        .ENARDEN(enA_bank),
        .ENBWREN(enB_bank),
        .REGCEAREGCE(1'b1),
        .REGCEB(1'b1),
        .RSTRAMARSTRAM(1'b0),
        .RSTRAMB(1'b0),
        .RSTREGARSTREG(1'b0),
        .RSTREGB(1'b0),
        .SLEEP(1'b0),
        .WEA({1'b0,1'b0}),
        .WEBWE({1'b0,1'b0,1'b0,1'b0}));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT5 #(
    .INIT(32'hFFDFFFFF)) 
    dout_a_reg_i_10
       (.I0(slim_en_sel_IBUF[1]),
        .I1(slim_port_sel_IBUF[1]),
        .I2(dout_a_reg_12[0]),
        .I3(dout_a_reg_12[2]),
        .I4(dout_a_reg_12[1]),
        .O(dout_a_reg_i_10_n_0));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT5 #(
    .INIT(32'h00400000)) 
    dout_a_reg_i_11__3
       (.I0(slim_port_sel_IBUF[3]),
        .I1(slim_en_sel_IBUF[3]),
        .I2(dout_a_reg_13[0]),
        .I3(dout_a_reg_13[2]),
        .I4(dout_a_reg_13[1]),
        .O(dout_a_reg_i_11__3_n_0));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT5 #(
    .INIT(32'h00400000)) 
    dout_a_reg_i_12__2
       (.I0(slim_port_sel_IBUF[2]),
        .I1(slim_en_sel_IBUF[2]),
        .I2(D[0]),
        .I3(D[2]),
        .I4(D[1]),
        .O(dout_a_reg_i_12__2_n_0));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT5 #(
    .INIT(32'hDFFFFFFF)) 
    dout_a_reg_i_13__1
       (.I0(dout_a_reg_12[0]),
        .I1(dout_a_reg_12[2]),
        .I2(dout_a_reg_12[1]),
        .I3(slim_en_sel_IBUF[1]),
        .I4(slim_port_sel_IBUF[1]),
        .O(dout_a_reg_i_13__1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT5 #(
    .INIT(32'hDFFFFFFF)) 
    dout_a_reg_i_14__0
       (.I0(dout_a_reg_14[0]),
        .I1(dout_a_reg_14[2]),
        .I2(dout_a_reg_14[1]),
        .I3(slim_port_sel_IBUF[0]),
        .I4(slim_en_sel_IBUF[0]),
        .O(dout_a_reg_i_14__0_n_0));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT5 #(
    .INIT(32'h20000000)) 
    dout_a_reg_i_15__1
       (.I0(D[0]),
        .I1(D[2]),
        .I2(D[1]),
        .I3(slim_en_sel_IBUF[2]),
        .I4(slim_port_sel_IBUF[2]),
        .O(dout_a_reg_i_15__1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT5 #(
    .INIT(32'h20000000)) 
    dout_a_reg_i_16__1
       (.I0(dout_a_reg_13[0]),
        .I1(dout_a_reg_13[2]),
        .I2(dout_a_reg_13[1]),
        .I3(slim_en_sel_IBUF[3]),
        .I4(slim_port_sel_IBUF[3]),
        .O(dout_a_reg_i_16__1_n_0));
  LUT5 #(
    .INIT(32'hFFFF44F0)) 
    dout_a_reg_i_17__1
       (.I0(dout_a_reg_i_9_n_0),
        .I1(dout_a_reg_10),
        .I2(dout_a_reg_11),
        .I3(dout_a_reg_i_10_n_0),
        .I4(dout_a_reg_i_12__2_n_0),
        .O(dout_a_reg_i_17__1_n_0));
  LUT5 #(
    .INIT(32'hFFFF44F0)) 
    dout_a_reg_i_18__1
       (.I0(dout_a_reg_i_9_n_0),
        .I1(dout_a_reg_6),
        .I2(dout_a_reg_7),
        .I3(dout_a_reg_i_10_n_0),
        .I4(dout_a_reg_i_12__2_n_0),
        .O(dout_a_reg_i_18__1_n_0));
  LUT5 #(
    .INIT(32'hFFFF44F0)) 
    dout_a_reg_i_19__2
       (.I0(dout_a_reg_i_9_n_0),
        .I1(dout_a_reg_2),
        .I2(dout_a_reg_3),
        .I3(dout_a_reg_i_10_n_0),
        .I4(dout_a_reg_i_12__2_n_0),
        .O(dout_a_reg_i_19__2_n_0));
  LUT4 #(
    .INIT(16'hFFF7)) 
    dout_a_reg_i_1__2
       (.I0(dout_a_reg_i_9_n_0),
        .I1(dout_a_reg_i_10_n_0),
        .I2(dout_a_reg_i_11__3_n_0),
        .I3(dout_a_reg_i_12__2_n_0),
        .O(enA_bank));
  LUT5 #(
    .INIT(32'hFFFF44F0)) 
    dout_a_reg_i_20__1
       (.I0(dout_a_reg_i_14__0_n_0),
        .I1(dout_a_reg_10),
        .I2(dout_a_reg_11),
        .I3(dout_a_reg_i_13__1_n_0),
        .I4(dout_a_reg_i_15__1_n_0),
        .O(dout_a_reg_i_20__1_n_0));
  LUT5 #(
    .INIT(32'hFFFF44F0)) 
    dout_a_reg_i_21__1
       (.I0(dout_a_reg_i_14__0_n_0),
        .I1(dout_a_reg_6),
        .I2(dout_a_reg_7),
        .I3(dout_a_reg_i_13__1_n_0),
        .I4(dout_a_reg_i_15__1_n_0),
        .O(dout_a_reg_i_21__1_n_0));
  LUT5 #(
    .INIT(32'hFFFF44F0)) 
    dout_a_reg_i_22__2
       (.I0(dout_a_reg_i_14__0_n_0),
        .I1(dout_a_reg_2),
        .I2(dout_a_reg_3),
        .I3(dout_a_reg_i_13__1_n_0),
        .I4(dout_a_reg_i_15__1_n_0),
        .O(dout_a_reg_i_22__2_n_0));
  LUT4 #(
    .INIT(16'hFFF7)) 
    dout_a_reg_i_2__1
       (.I0(dout_a_reg_i_13__1_n_0),
        .I1(dout_a_reg_i_14__0_n_0),
        .I2(dout_a_reg_i_15__1_n_0),
        .I3(dout_a_reg_i_16__1_n_0),
        .O(enB_bank));
  LUT5 #(
    .INIT(32'hBB8B8888)) 
    dout_a_reg_i_3__2
       (.I0(dout_a_reg_8),
        .I1(dout_a_reg_i_11__3_n_0),
        .I2(dout_a_reg_i_12__2_n_0),
        .I3(dout_a_reg_9),
        .I4(dout_a_reg_i_17__1_n_0),
        .O(\addrA_bank[3]_7 [2]));
  LUT5 #(
    .INIT(32'hBB8B8888)) 
    dout_a_reg_i_4__2
       (.I0(dout_a_reg_4),
        .I1(dout_a_reg_i_11__3_n_0),
        .I2(dout_a_reg_i_12__2_n_0),
        .I3(dout_a_reg_5),
        .I4(dout_a_reg_i_18__1_n_0),
        .O(\addrA_bank[3]_7 [1]));
  LUT5 #(
    .INIT(32'hBB8B8888)) 
    dout_a_reg_i_5__2
       (.I0(dout_a_reg_0),
        .I1(dout_a_reg_i_11__3_n_0),
        .I2(dout_a_reg_i_12__2_n_0),
        .I3(dout_a_reg_1),
        .I4(dout_a_reg_i_19__2_n_0),
        .O(\addrA_bank[3]_7 [0]));
  LUT5 #(
    .INIT(32'hB8BB8888)) 
    dout_a_reg_i_6__1
       (.I0(dout_a_reg_8),
        .I1(dout_a_reg_i_16__1_n_0),
        .I2(dout_a_reg_9),
        .I3(dout_a_reg_i_15__1_n_0),
        .I4(dout_a_reg_i_20__1_n_0),
        .O(\addrB_bank[3]_12 [2]));
  LUT5 #(
    .INIT(32'hB8BB8888)) 
    dout_a_reg_i_7__1
       (.I0(dout_a_reg_4),
        .I1(dout_a_reg_i_16__1_n_0),
        .I2(dout_a_reg_5),
        .I3(dout_a_reg_i_15__1_n_0),
        .I4(dout_a_reg_i_21__1_n_0),
        .O(\addrB_bank[3]_12 [1]));
  LUT5 #(
    .INIT(32'hB8BB8888)) 
    dout_a_reg_i_8__1
       (.I0(dout_a_reg_0),
        .I1(dout_a_reg_i_16__1_n_0),
        .I2(dout_a_reg_1),
        .I3(dout_a_reg_i_15__1_n_0),
        .I4(dout_a_reg_i_22__2_n_0),
        .O(\addrB_bank[3]_12 [0]));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT5 #(
    .INIT(32'hFFDFFFFF)) 
    dout_a_reg_i_9
       (.I0(slim_en_sel_IBUF[0]),
        .I1(slim_port_sel_IBUF[0]),
        .I2(dout_a_reg_14[0]),
        .I3(dout_a_reg_14[2]),
        .I4(dout_a_reg_14[1]),
        .O(dout_a_reg_i_9_n_0));
endmodule

(* ORIG_REF_NAME = "reuse_weight_bank_rom" *) 
module reuse_weight_bank_rom__parameterized3
   (DOUTADOUT,
    DOUTBDOUT,
    clk_IBUF_BUFG,
    dout_a_reg_0,
    dout_a_reg_1,
    dout_a_reg_2,
    dout_a_reg_3,
    dout_a_reg_4,
    dout_a_reg_5,
    dout_a_reg_6,
    dout_a_reg_7,
    dout_a_reg_8,
    dout_a_reg_9,
    dout_a_reg_10,
    dout_a_reg_11,
    dout_a_reg_12,
    slim_port_sel_IBUF,
    slim_en_sel_IBUF,
    dout_a_reg_13,
    dout_a_reg_14,
    D);
  output [4:0]DOUTADOUT;
  output [4:0]DOUTBDOUT;
  input clk_IBUF_BUFG;
  input dout_a_reg_0;
  input dout_a_reg_1;
  input dout_a_reg_2;
  input dout_a_reg_3;
  input dout_a_reg_4;
  input dout_a_reg_5;
  input dout_a_reg_6;
  input dout_a_reg_7;
  input dout_a_reg_8;
  input dout_a_reg_9;
  input dout_a_reg_10;
  input dout_a_reg_11;
  input [2:0]dout_a_reg_12;
  input [3:0]slim_port_sel_IBUF;
  input [3:0]slim_en_sel_IBUF;
  input [2:0]dout_a_reg_13;
  input [2:0]dout_a_reg_14;
  input [2:0]D;

  wire [2:0]D;
  wire [4:0]DOUTADOUT;
  wire [4:0]DOUTBDOUT;
  wire [2:0]\addrA_bank[4]_8 ;
  wire [2:0]\addrB_bank[4]_11 ;
  wire clk_IBUF_BUFG;
  wire dout_a_reg_0;
  wire dout_a_reg_1;
  wire dout_a_reg_10;
  wire dout_a_reg_11;
  wire [2:0]dout_a_reg_12;
  wire [2:0]dout_a_reg_13;
  wire [2:0]dout_a_reg_14;
  wire dout_a_reg_2;
  wire dout_a_reg_3;
  wire dout_a_reg_4;
  wire dout_a_reg_5;
  wire dout_a_reg_6;
  wire dout_a_reg_7;
  wire dout_a_reg_8;
  wire dout_a_reg_9;
  wire dout_a_reg_i_10__0_n_0;
  wire dout_a_reg_i_11__4_n_0;
  wire dout_a_reg_i_12__3_n_0;
  wire dout_a_reg_i_13_n_0;
  wire dout_a_reg_i_14__4_n_0;
  wire dout_a_reg_i_15_n_0;
  wire dout_a_reg_i_16_n_0;
  wire dout_a_reg_i_17__2_n_0;
  wire dout_a_reg_i_18__2_n_0;
  wire dout_a_reg_i_19__4_n_0;
  wire dout_a_reg_i_20_n_0;
  wire dout_a_reg_i_21__0_n_0;
  wire dout_a_reg_i_22__1_n_0;
  wire dout_a_reg_i_23_n_0;
  wire dout_a_reg_i_24_n_0;
  wire dout_a_reg_i_25__0_n_0;
  wire dout_a_reg_i_9__0_n_0;
  wire [4:4]enA_bank;
  wire [4:4]enB_bank;
  wire [3:0]slim_en_sel_IBUF;
  wire [3:0]slim_port_sel_IBUF;
  wire [15:0]NLW_dout_a_reg_CASDOUTA_UNCONNECTED;
  wire [15:0]NLW_dout_a_reg_CASDOUTB_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_CASDOUTPA_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_CASDOUTPB_UNCONNECTED;
  wire [15:5]NLW_dout_a_reg_DOUTADOUT_UNCONNECTED;
  wire [15:5]NLW_dout_a_reg_DOUTBDOUT_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_DOUTPADOUTP_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_DOUTPBDOUTP_UNCONNECTED;

  (* \MEM.PORTA.DATA_BIT_LAYOUT  = "p0_d5" *) 
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-6 {cell *THIS*}}" *) 
  (* OPT_MODIFIED = "MLO" *) 
  (* RDADDR_COLLISION_HWCONFIG = "PERFORMANCE" *) 
  (* RTL_RAM_BITS = "40" *) 
  (* RTL_RAM_NAME = "u_wbuf/WBUF_BANK[4].g_bank4.u_bank/dout_a_reg" *) 
  (* RTL_RAM_TYPE = "RAM_SP" *) 
  (* ram_addr_begin = "0" *) 
  (* ram_addr_end = "1023" *) 
  (* ram_offset = "0" *) 
  (* ram_slice_begin = "0" *) 
  (* ram_slice_end = "4" *) 
  RAMB18E2 #(
    .CASCADE_ORDER_A("NONE"),
    .CASCADE_ORDER_B("NONE"),
    .CLOCK_DOMAINS("COMMON"),
    .DOA_REG(0),
    .DOB_REG(0),
    .ENADDRENA("FALSE"),
    .ENADDRENB("FALSE"),
    .INITP_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_00(256'h00000000000000000000000000000000000F000E000D000C000B000A00090008),
    .INIT_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_10(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_11(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_12(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_13(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_14(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_15(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_16(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_17(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_18(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_19(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_20(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_21(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_22(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_23(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_24(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_25(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_26(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_27(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_28(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_29(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_30(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_31(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_32(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_33(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_34(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_35(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_36(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_37(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_38(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_39(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_A(18'h00000),
    .INIT_B(18'h00000),
    .INIT_FILE("NONE"),
    .RDADDRCHANGEA("FALSE"),
    .RDADDRCHANGEB("FALSE"),
    .READ_WIDTH_A(18),
    .READ_WIDTH_B(18),
    .RSTREG_PRIORITY_A("RSTREG"),
    .RSTREG_PRIORITY_B("RSTREG"),
    .SIM_COLLISION_CHECK("ALL"),
    .SLEEP_ASYNC("FALSE"),
    .SRVAL_A(18'h00000),
    .SRVAL_B(18'h00000),
    .WRITE_MODE_A("WRITE_FIRST"),
    .WRITE_MODE_B("WRITE_FIRST"),
    .WRITE_WIDTH_A(18),
    .WRITE_WIDTH_B(0)) 
    dout_a_reg
       (.ADDRARDADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\addrA_bank[4]_8 ,1'b0,1'b0,1'b0,1'b0}),
        .ADDRBWRADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\addrB_bank[4]_11 ,1'b0,1'b0,1'b0,1'b0}),
        .ADDRENA(1'b1),
        .ADDRENB(1'b1),
        .CASDIMUXA(1'b0),
        .CASDIMUXB(1'b0),
        .CASDINA({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .CASDINB({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .CASDINPA({1'b0,1'b0}),
        .CASDINPB({1'b0,1'b0}),
        .CASDOMUXA(1'b0),
        .CASDOMUXB(1'b0),
        .CASDOMUXEN_A(1'b1),
        .CASDOMUXEN_B(1'b1),
        .CASDOUTA(NLW_dout_a_reg_CASDOUTA_UNCONNECTED[15:0]),
        .CASDOUTB(NLW_dout_a_reg_CASDOUTB_UNCONNECTED[15:0]),
        .CASDOUTPA(NLW_dout_a_reg_CASDOUTPA_UNCONNECTED[1:0]),
        .CASDOUTPB(NLW_dout_a_reg_CASDOUTPB_UNCONNECTED[1:0]),
        .CASOREGIMUXA(1'b0),
        .CASOREGIMUXB(1'b0),
        .CASOREGIMUXEN_A(1'b1),
        .CASOREGIMUXEN_B(1'b1),
        .CLKARDCLK(clk_IBUF_BUFG),
        .CLKBWRCLK(clk_IBUF_BUFG),
        .DINADIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .DINBDIN({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .DINPADINP({1'b0,1'b0}),
        .DINPBDINP({1'b1,1'b1}),
        .DOUTADOUT({NLW_dout_a_reg_DOUTADOUT_UNCONNECTED[15:5],DOUTADOUT}),
        .DOUTBDOUT({NLW_dout_a_reg_DOUTBDOUT_UNCONNECTED[15:5],DOUTBDOUT}),
        .DOUTPADOUTP(NLW_dout_a_reg_DOUTPADOUTP_UNCONNECTED[1:0]),
        .DOUTPBDOUTP(NLW_dout_a_reg_DOUTPBDOUTP_UNCONNECTED[1:0]),
        .ENARDEN(enA_bank),
        .ENBWREN(enB_bank),
        .REGCEAREGCE(1'b1),
        .REGCEB(1'b1),
        .RSTRAMARSTRAM(1'b0),
        .RSTRAMB(1'b0),
        .RSTREGARSTREG(1'b0),
        .RSTREGB(1'b0),
        .SLEEP(1'b0),
        .WEA({1'b0,1'b0}),
        .WEBWE({1'b0,1'b0,1'b0,1'b0}));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT5 #(
    .INIT(32'hFFFFFDFF)) 
    dout_a_reg_i_10__0
       (.I0(slim_en_sel_IBUF[1]),
        .I1(slim_port_sel_IBUF[1]),
        .I2(dout_a_reg_13[1]),
        .I3(dout_a_reg_13[2]),
        .I4(dout_a_reg_13[0]),
        .O(dout_a_reg_i_10__0_n_0));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT5 #(
    .INIT(32'h00000400)) 
    dout_a_reg_i_11__4
       (.I0(slim_port_sel_IBUF[3]),
        .I1(slim_en_sel_IBUF[3]),
        .I2(dout_a_reg_14[1]),
        .I3(dout_a_reg_14[2]),
        .I4(dout_a_reg_14[0]),
        .O(dout_a_reg_i_11__4_n_0));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT5 #(
    .INIT(32'h00000400)) 
    dout_a_reg_i_12__3
       (.I0(slim_port_sel_IBUF[2]),
        .I1(slim_en_sel_IBUF[2]),
        .I2(D[1]),
        .I3(D[2]),
        .I4(D[0]),
        .O(dout_a_reg_i_12__3_n_0));
  LUT6 #(
    .INIT(64'hFFFFFFFF00000800)) 
    dout_a_reg_i_13
       (.I0(slim_port_sel_IBUF[1]),
        .I1(slim_en_sel_IBUF[1]),
        .I2(dout_a_reg_13[0]),
        .I3(dout_a_reg_13[2]),
        .I4(dout_a_reg_13[1]),
        .I5(dout_a_reg_i_19__4_n_0),
        .O(dout_a_reg_i_13_n_0));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT2 #(
    .INIT(4'h7)) 
    dout_a_reg_i_14__4
       (.I0(slim_en_sel_IBUF[0]),
        .I1(slim_port_sel_IBUF[0]),
        .O(dout_a_reg_i_14__4_n_0));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT5 #(
    .INIT(32'h04000000)) 
    dout_a_reg_i_15
       (.I0(dout_a_reg_14[1]),
        .I1(dout_a_reg_14[2]),
        .I2(dout_a_reg_14[0]),
        .I3(slim_en_sel_IBUF[3]),
        .I4(slim_port_sel_IBUF[3]),
        .O(dout_a_reg_i_15_n_0));
  LUT5 #(
    .INIT(32'hFFFF44F4)) 
    dout_a_reg_i_16
       (.I0(dout_a_reg_i_23_n_0),
        .I1(dout_a_reg_10),
        .I2(dout_a_reg_11),
        .I3(dout_a_reg_i_10__0_n_0),
        .I4(dout_a_reg_i_12__3_n_0),
        .O(dout_a_reg_i_16_n_0));
  LUT5 #(
    .INIT(32'hFFFF44F4)) 
    dout_a_reg_i_17__2
       (.I0(dout_a_reg_i_23_n_0),
        .I1(dout_a_reg_6),
        .I2(dout_a_reg_7),
        .I3(dout_a_reg_i_10__0_n_0),
        .I4(dout_a_reg_i_12__3_n_0),
        .O(dout_a_reg_i_17__2_n_0));
  LUT5 #(
    .INIT(32'hFFFF44F4)) 
    dout_a_reg_i_18__2
       (.I0(dout_a_reg_i_23_n_0),
        .I1(dout_a_reg_2),
        .I2(dout_a_reg_3),
        .I3(dout_a_reg_i_10__0_n_0),
        .I4(dout_a_reg_i_12__3_n_0),
        .O(dout_a_reg_i_18__2_n_0));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT5 #(
    .INIT(32'h04000000)) 
    dout_a_reg_i_19__4
       (.I0(D[1]),
        .I1(D[2]),
        .I2(D[0]),
        .I3(slim_en_sel_IBUF[2]),
        .I4(slim_port_sel_IBUF[2]),
        .O(dout_a_reg_i_19__4_n_0));
  LUT4 #(
    .INIT(16'hFFF7)) 
    dout_a_reg_i_1__3
       (.I0(dout_a_reg_i_9__0_n_0),
        .I1(dout_a_reg_i_10__0_n_0),
        .I2(dout_a_reg_i_11__4_n_0),
        .I3(dout_a_reg_i_12__3_n_0),
        .O(enA_bank));
  LUT5 #(
    .INIT(32'hFFFFF444)) 
    dout_a_reg_i_20
       (.I0(dout_a_reg_i_24_n_0),
        .I1(dout_a_reg_10),
        .I2(dout_a_reg_11),
        .I3(dout_a_reg_i_25__0_n_0),
        .I4(dout_a_reg_i_19__4_n_0),
        .O(dout_a_reg_i_20_n_0));
  LUT5 #(
    .INIT(32'hFFF4F4F4)) 
    dout_a_reg_i_21__0
       (.I0(dout_a_reg_i_24_n_0),
        .I1(dout_a_reg_6),
        .I2(dout_a_reg_i_19__4_n_0),
        .I3(dout_a_reg_7),
        .I4(dout_a_reg_i_25__0_n_0),
        .O(dout_a_reg_i_21__0_n_0));
  LUT5 #(
    .INIT(32'hFFFFF444)) 
    dout_a_reg_i_22__1
       (.I0(dout_a_reg_i_24_n_0),
        .I1(dout_a_reg_2),
        .I2(dout_a_reg_3),
        .I3(dout_a_reg_i_25__0_n_0),
        .I4(dout_a_reg_i_19__4_n_0),
        .O(dout_a_reg_i_22__1_n_0));
  LUT6 #(
    .INIT(64'hFFFBFFFFFFFFFFFF)) 
    dout_a_reg_i_23
       (.I0(dout_a_reg_12[0]),
        .I1(dout_a_reg_12[2]),
        .I2(dout_a_reg_12[1]),
        .I3(slim_port_sel_IBUF[0]),
        .I4(slim_en_sel_IBUF[0]),
        .I5(dout_a_reg_i_10__0_n_0),
        .O(dout_a_reg_i_23_n_0));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFBFFFFF)) 
    dout_a_reg_i_24
       (.I0(dout_a_reg_i_25__0_n_0),
        .I1(slim_en_sel_IBUF[0]),
        .I2(slim_port_sel_IBUF[0]),
        .I3(dout_a_reg_12[0]),
        .I4(dout_a_reg_12[2]),
        .I5(dout_a_reg_12[1]),
        .O(dout_a_reg_i_24_n_0));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT5 #(
    .INIT(32'h04000000)) 
    dout_a_reg_i_25__0
       (.I0(dout_a_reg_13[1]),
        .I1(dout_a_reg_13[2]),
        .I2(dout_a_reg_13[0]),
        .I3(slim_en_sel_IBUF[1]),
        .I4(slim_port_sel_IBUF[1]),
        .O(dout_a_reg_i_25__0_n_0));
  LUT6 #(
    .INIT(64'hFFFFFFFFAAAAAABA)) 
    dout_a_reg_i_2__0
       (.I0(dout_a_reg_i_13_n_0),
        .I1(dout_a_reg_12[1]),
        .I2(dout_a_reg_12[2]),
        .I3(dout_a_reg_12[0]),
        .I4(dout_a_reg_i_14__4_n_0),
        .I5(dout_a_reg_i_15_n_0),
        .O(enB_bank));
  LUT5 #(
    .INIT(32'hBB8B8888)) 
    dout_a_reg_i_3__3
       (.I0(dout_a_reg_8),
        .I1(dout_a_reg_i_11__4_n_0),
        .I2(dout_a_reg_i_12__3_n_0),
        .I3(dout_a_reg_9),
        .I4(dout_a_reg_i_16_n_0),
        .O(\addrA_bank[4]_8 [2]));
  LUT5 #(
    .INIT(32'hBB8B8888)) 
    dout_a_reg_i_4__3
       (.I0(dout_a_reg_4),
        .I1(dout_a_reg_i_11__4_n_0),
        .I2(dout_a_reg_i_12__3_n_0),
        .I3(dout_a_reg_5),
        .I4(dout_a_reg_i_17__2_n_0),
        .O(\addrA_bank[4]_8 [1]));
  LUT5 #(
    .INIT(32'hBB8B8888)) 
    dout_a_reg_i_5__3
       (.I0(dout_a_reg_0),
        .I1(dout_a_reg_i_11__4_n_0),
        .I2(dout_a_reg_i_12__3_n_0),
        .I3(dout_a_reg_1),
        .I4(dout_a_reg_i_18__2_n_0),
        .O(\addrA_bank[4]_8 [0]));
  LUT5 #(
    .INIT(32'hFFB000B0)) 
    dout_a_reg_i_6__0
       (.I0(dout_a_reg_9),
        .I1(dout_a_reg_i_19__4_n_0),
        .I2(dout_a_reg_i_20_n_0),
        .I3(dout_a_reg_i_15_n_0),
        .I4(dout_a_reg_8),
        .O(\addrB_bank[4]_11 [2]));
  LUT5 #(
    .INIT(32'hFFB000B0)) 
    dout_a_reg_i_7__0
       (.I0(dout_a_reg_5),
        .I1(dout_a_reg_i_19__4_n_0),
        .I2(dout_a_reg_i_21__0_n_0),
        .I3(dout_a_reg_i_15_n_0),
        .I4(dout_a_reg_4),
        .O(\addrB_bank[4]_11 [1]));
  LUT5 #(
    .INIT(32'hB8BB8888)) 
    dout_a_reg_i_8__0
       (.I0(dout_a_reg_0),
        .I1(dout_a_reg_i_15_n_0),
        .I2(dout_a_reg_1),
        .I3(dout_a_reg_i_19__4_n_0),
        .I4(dout_a_reg_i_22__1_n_0),
        .O(\addrB_bank[4]_11 [0]));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT5 #(
    .INIT(32'hFFFFFDFF)) 
    dout_a_reg_i_9__0
       (.I0(slim_en_sel_IBUF[0]),
        .I1(slim_port_sel_IBUF[0]),
        .I2(dout_a_reg_12[1]),
        .I3(dout_a_reg_12[2]),
        .I4(dout_a_reg_12[0]),
        .O(dout_a_reg_i_9__0_n_0));
endmodule

(* ORIG_REF_NAME = "reuse_weight_bank_rom" *) 
module reuse_weight_bank_rom__parameterized4
   (dout_a_reg_0,
    dout_a_reg_1,
    dout_a_reg_2,
    dout_a_reg_3,
    dout_a_reg_4,
    dout_a_reg_5,
    clk_IBUF_BUFG,
    dout_a_reg_6,
    slim_port_sel_IBUF,
    slim_en_sel_IBUF,
    D,
    dout_a_reg_7,
    dout_a_reg_8,
    dout_a_reg_9,
    dout_a_reg_10,
    dout_a_reg_11,
    dout_a_reg_12,
    dout_a_reg_13,
    dout_a_reg_14,
    dout_a_reg_15,
    dout_a_reg_16,
    dout_a_reg_17,
    dout_a_reg_18,
    dout_a_reg_19,
    dout_a_reg_20,
    DOUTBDOUT,
    Q,
    \slim_dout_sel[3][31]_INST_0_i_1 ,
    DOUTADOUT,
    \slim_dout_sel[2][31]_INST_0_i_1 ,
    \slim_dout_sel[1][31]_INST_0_i_1 ,
    \slim_dout_sel[0][31]_INST_0_i_1 );
  output [3:0]dout_a_reg_0;
  output [3:0]dout_a_reg_1;
  output dout_a_reg_2;
  output dout_a_reg_3;
  output dout_a_reg_4;
  output dout_a_reg_5;
  input clk_IBUF_BUFG;
  input [2:0]dout_a_reg_6;
  input [3:0]slim_port_sel_IBUF;
  input [3:0]slim_en_sel_IBUF;
  input [2:0]D;
  input dout_a_reg_7;
  input dout_a_reg_8;
  input dout_a_reg_9;
  input dout_a_reg_10;
  input dout_a_reg_11;
  input dout_a_reg_12;
  input dout_a_reg_13;
  input dout_a_reg_14;
  input dout_a_reg_15;
  input dout_a_reg_16;
  input dout_a_reg_17;
  input dout_a_reg_18;
  input [2:0]dout_a_reg_19;
  input [2:0]dout_a_reg_20;
  input [0:0]DOUTBDOUT;
  input [3:0]Q;
  input [0:0]\slim_dout_sel[3][31]_INST_0_i_1 ;
  input [0:0]DOUTADOUT;
  input [0:0]\slim_dout_sel[2][31]_INST_0_i_1 ;
  input [0:0]\slim_dout_sel[1][31]_INST_0_i_1 ;
  input [0:0]\slim_dout_sel[0][31]_INST_0_i_1 ;

  wire [2:0]D;
  wire [0:0]DOUTADOUT;
  wire [0:0]DOUTBDOUT;
  wire [3:0]Q;
  wire [2:0]\addrA_bank[5]_9 ;
  wire [2:0]\addrB_bank[5]_10 ;
  wire clk_IBUF_BUFG;
  wire [3:3]\doutA_bank[5]__0 ;
  wire [3:3]\doutB_bank[5]__0 ;
  wire [3:0]dout_a_reg_0;
  wire [3:0]dout_a_reg_1;
  wire dout_a_reg_10;
  wire dout_a_reg_11;
  wire dout_a_reg_12;
  wire dout_a_reg_13;
  wire dout_a_reg_14;
  wire dout_a_reg_15;
  wire dout_a_reg_16;
  wire dout_a_reg_17;
  wire dout_a_reg_18;
  wire [2:0]dout_a_reg_19;
  wire dout_a_reg_2;
  wire [2:0]dout_a_reg_20;
  wire dout_a_reg_3;
  wire dout_a_reg_4;
  wire dout_a_reg_5;
  wire [2:0]dout_a_reg_6;
  wire dout_a_reg_7;
  wire dout_a_reg_8;
  wire dout_a_reg_9;
  wire dout_a_reg_i_10__4_n_0;
  wire dout_a_reg_i_11__2_n_0;
  wire dout_a_reg_i_12__4_n_0;
  wire dout_a_reg_i_13__0_n_0;
  wire dout_a_reg_i_14_n_0;
  wire dout_a_reg_i_15__0_n_0;
  wire dout_a_reg_i_16__0_n_0;
  wire dout_a_reg_i_17__3_n_0;
  wire dout_a_reg_i_18__3_n_0;
  wire dout_a_reg_i_19__3_n_0;
  wire dout_a_reg_i_20__0_n_0;
  wire dout_a_reg_i_21_n_0;
  wire dout_a_reg_i_22__0_n_0;
  wire dout_a_reg_i_23__0_n_0;
  wire dout_a_reg_i_24__0_n_0;
  wire dout_a_reg_i_9__1_n_0;
  wire [5:5]enA_bank;
  wire [5:5]enB_bank;
  wire [0:0]\slim_dout_sel[0][31]_INST_0_i_1 ;
  wire [0:0]\slim_dout_sel[1][31]_INST_0_i_1 ;
  wire [0:0]\slim_dout_sel[2][31]_INST_0_i_1 ;
  wire [0:0]\slim_dout_sel[3][31]_INST_0_i_1 ;
  wire [3:0]slim_en_sel_IBUF;
  wire [3:0]slim_port_sel_IBUF;
  wire [15:0]NLW_dout_a_reg_CASDOUTA_UNCONNECTED;
  wire [15:0]NLW_dout_a_reg_CASDOUTB_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_CASDOUTPA_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_CASDOUTPB_UNCONNECTED;
  wire [15:5]NLW_dout_a_reg_DOUTADOUT_UNCONNECTED;
  wire [15:5]NLW_dout_a_reg_DOUTBDOUT_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_DOUTPADOUTP_UNCONNECTED;
  wire [1:0]NLW_dout_a_reg_DOUTPBDOUTP_UNCONNECTED;

  (* \MEM.PORTA.DATA_BIT_LAYOUT  = "p0_d5" *) 
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-6 {cell *THIS*}}" *) 
  (* OPT_MODIFIED = "MLO" *) 
  (* RDADDR_COLLISION_HWCONFIG = "PERFORMANCE" *) 
  (* RTL_RAM_BITS = "40" *) 
  (* RTL_RAM_NAME = "u_wbuf/WBUF_BANK[5].g_bank5.u_bank/dout_a_reg" *) 
  (* RTL_RAM_TYPE = "RAM_SP" *) 
  (* ram_addr_begin = "0" *) 
  (* ram_addr_end = "1023" *) 
  (* ram_offset = "0" *) 
  (* ram_slice_begin = "0" *) 
  (* ram_slice_end = "4" *) 
  RAMB18E2 #(
    .CASCADE_ORDER_A("NONE"),
    .CASCADE_ORDER_B("NONE"),
    .CLOCK_DOMAINS("COMMON"),
    .DOA_REG(0),
    .DOB_REG(0),
    .ENADDRENA("FALSE"),
    .ENADDRENB("FALSE"),
    .INITP_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INITP_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_00(256'h00000000000000000000000000000000000F000E000D000C000B000A00090008),
    .INIT_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_10(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_11(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_12(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_13(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_14(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_15(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_16(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_17(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_18(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_19(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_20(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_21(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_22(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_23(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_24(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_25(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_26(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_27(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_28(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_29(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_30(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_31(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_32(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_33(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_34(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_35(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_36(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_37(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_38(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_39(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3A(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3B(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3C(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3D(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3E(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3F(256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_A(18'h00000),
    .INIT_B(18'h00000),
    .INIT_FILE("NONE"),
    .RDADDRCHANGEA("FALSE"),
    .RDADDRCHANGEB("FALSE"),
    .READ_WIDTH_A(18),
    .READ_WIDTH_B(18),
    .RSTREG_PRIORITY_A("RSTREG"),
    .RSTREG_PRIORITY_B("RSTREG"),
    .SIM_COLLISION_CHECK("ALL"),
    .SLEEP_ASYNC("FALSE"),
    .SRVAL_A(18'h00000),
    .SRVAL_B(18'h00000),
    .WRITE_MODE_A("WRITE_FIRST"),
    .WRITE_MODE_B("WRITE_FIRST"),
    .WRITE_WIDTH_A(18),
    .WRITE_WIDTH_B(0)) 
    dout_a_reg
       (.ADDRARDADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\addrA_bank[5]_9 ,1'b0,1'b0,1'b0,1'b0}),
        .ADDRBWRADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\addrB_bank[5]_10 ,1'b0,1'b0,1'b0,1'b0}),
        .ADDRENA(1'b1),
        .ADDRENB(1'b1),
        .CASDIMUXA(1'b0),
        .CASDIMUXB(1'b0),
        .CASDINA({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .CASDINB({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .CASDINPA({1'b0,1'b0}),
        .CASDINPB({1'b0,1'b0}),
        .CASDOMUXA(1'b0),
        .CASDOMUXB(1'b0),
        .CASDOMUXEN_A(1'b1),
        .CASDOMUXEN_B(1'b1),
        .CASDOUTA(NLW_dout_a_reg_CASDOUTA_UNCONNECTED[15:0]),
        .CASDOUTB(NLW_dout_a_reg_CASDOUTB_UNCONNECTED[15:0]),
        .CASDOUTPA(NLW_dout_a_reg_CASDOUTPA_UNCONNECTED[1:0]),
        .CASDOUTPB(NLW_dout_a_reg_CASDOUTPB_UNCONNECTED[1:0]),
        .CASOREGIMUXA(1'b0),
        .CASOREGIMUXB(1'b0),
        .CASOREGIMUXEN_A(1'b1),
        .CASOREGIMUXEN_B(1'b1),
        .CLKARDCLK(clk_IBUF_BUFG),
        .CLKBWRCLK(clk_IBUF_BUFG),
        .DINADIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .DINBDIN({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .DINPADINP({1'b0,1'b0}),
        .DINPBDINP({1'b1,1'b1}),
        .DOUTADOUT({NLW_dout_a_reg_DOUTADOUT_UNCONNECTED[15:5],\doutA_bank[5]__0 ,dout_a_reg_0}),
        .DOUTBDOUT({NLW_dout_a_reg_DOUTBDOUT_UNCONNECTED[15:5],\doutB_bank[5]__0 ,dout_a_reg_1}),
        .DOUTPADOUTP(NLW_dout_a_reg_DOUTPADOUTP_UNCONNECTED[1:0]),
        .DOUTPBDOUTP(NLW_dout_a_reg_DOUTPBDOUTP_UNCONNECTED[1:0]),
        .ENARDEN(enA_bank),
        .ENBWREN(enB_bank),
        .REGCEAREGCE(1'b1),
        .REGCEB(1'b1),
        .RSTRAMARSTRAM(1'b0),
        .RSTRAMB(1'b0),
        .RSTREGARSTREG(1'b0),
        .RSTREGB(1'b0),
        .SLEEP(1'b0),
        .WEA({1'b0,1'b0}),
        .WEBWE({1'b0,1'b0,1'b0,1'b0}));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT5 #(
    .INIT(32'hFFFFDFFF)) 
    dout_a_reg_i_10__4
       (.I0(dout_a_reg_20[0]),
        .I1(dout_a_reg_20[1]),
        .I2(dout_a_reg_20[2]),
        .I3(slim_en_sel_IBUF[0]),
        .I4(slim_port_sel_IBUF[0]),
        .O(dout_a_reg_i_10__4_n_0));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT5 #(
    .INIT(32'hFFFFDFFF)) 
    dout_a_reg_i_11__2
       (.I0(dout_a_reg_19[0]),
        .I1(dout_a_reg_19[1]),
        .I2(dout_a_reg_19[2]),
        .I3(slim_en_sel_IBUF[1]),
        .I4(slim_port_sel_IBUF[1]),
        .O(dout_a_reg_i_11__2_n_0));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT5 #(
    .INIT(32'h00400000)) 
    dout_a_reg_i_12__4
       (.I0(dout_a_reg_6[1]),
        .I1(dout_a_reg_6[2]),
        .I2(dout_a_reg_6[0]),
        .I3(slim_port_sel_IBUF[3]),
        .I4(slim_en_sel_IBUF[3]),
        .O(dout_a_reg_i_12__4_n_0));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT5 #(
    .INIT(32'hDFFFFFFF)) 
    dout_a_reg_i_13__0
       (.I0(dout_a_reg_20[0]),
        .I1(dout_a_reg_20[1]),
        .I2(dout_a_reg_20[2]),
        .I3(slim_port_sel_IBUF[0]),
        .I4(slim_en_sel_IBUF[0]),
        .O(dout_a_reg_i_13__0_n_0));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT5 #(
    .INIT(32'hDFFFFFFF)) 
    dout_a_reg_i_14
       (.I0(dout_a_reg_19[0]),
        .I1(dout_a_reg_19[1]),
        .I2(dout_a_reg_19[2]),
        .I3(slim_en_sel_IBUF[1]),
        .I4(slim_port_sel_IBUF[1]),
        .O(dout_a_reg_i_14_n_0));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT5 #(
    .INIT(32'h40000000)) 
    dout_a_reg_i_15__0
       (.I0(dout_a_reg_6[1]),
        .I1(dout_a_reg_6[2]),
        .I2(dout_a_reg_6[0]),
        .I3(slim_en_sel_IBUF[3]),
        .I4(slim_port_sel_IBUF[3]),
        .O(dout_a_reg_i_15__0_n_0));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT5 #(
    .INIT(32'h20000000)) 
    dout_a_reg_i_16__0
       (.I0(D[2]),
        .I1(D[1]),
        .I2(D[0]),
        .I3(slim_en_sel_IBUF[2]),
        .I4(slim_port_sel_IBUF[2]),
        .O(dout_a_reg_i_16__0_n_0));
  LUT5 #(
    .INIT(32'hFFFF44F0)) 
    dout_a_reg_i_17__3
       (.I0(dout_a_reg_i_10__4_n_0),
        .I1(dout_a_reg_17),
        .I2(dout_a_reg_18),
        .I3(dout_a_reg_i_11__2_n_0),
        .I4(dout_a_reg_i_24__0_n_0),
        .O(dout_a_reg_i_17__3_n_0));
  LUT5 #(
    .INIT(32'hFFFF44F0)) 
    dout_a_reg_i_18__3
       (.I0(dout_a_reg_i_10__4_n_0),
        .I1(dout_a_reg_13),
        .I2(dout_a_reg_14),
        .I3(dout_a_reg_i_11__2_n_0),
        .I4(dout_a_reg_i_24__0_n_0),
        .O(dout_a_reg_i_18__3_n_0));
  LUT5 #(
    .INIT(32'hFFFF44F0)) 
    dout_a_reg_i_19__3
       (.I0(dout_a_reg_i_10__4_n_0),
        .I1(dout_a_reg_9),
        .I2(dout_a_reg_10),
        .I3(dout_a_reg_i_11__2_n_0),
        .I4(dout_a_reg_i_24__0_n_0),
        .O(dout_a_reg_i_19__3_n_0));
  LUT4 #(
    .INIT(16'hFF7F)) 
    dout_a_reg_i_1__4
       (.I0(dout_a_reg_i_9__1_n_0),
        .I1(dout_a_reg_i_10__4_n_0),
        .I2(dout_a_reg_i_11__2_n_0),
        .I3(dout_a_reg_i_12__4_n_0),
        .O(enA_bank));
  LUT4 #(
    .INIT(16'hFFF7)) 
    dout_a_reg_i_2
       (.I0(dout_a_reg_i_13__0_n_0),
        .I1(dout_a_reg_i_14_n_0),
        .I2(dout_a_reg_i_15__0_n_0),
        .I3(dout_a_reg_i_16__0_n_0),
        .O(enB_bank));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT5 #(
    .INIT(32'hDFFFFFFF)) 
    dout_a_reg_i_20__0
       (.I0(D[0]),
        .I1(D[1]),
        .I2(D[2]),
        .I3(slim_en_sel_IBUF[2]),
        .I4(slim_port_sel_IBUF[2]),
        .O(dout_a_reg_i_20__0_n_0));
  LUT5 #(
    .INIT(32'hFFFF44F0)) 
    dout_a_reg_i_21
       (.I0(dout_a_reg_i_13__0_n_0),
        .I1(dout_a_reg_17),
        .I2(dout_a_reg_18),
        .I3(dout_a_reg_i_14_n_0),
        .I4(dout_a_reg_i_16__0_n_0),
        .O(dout_a_reg_i_21_n_0));
  LUT5 #(
    .INIT(32'hFFFF44F0)) 
    dout_a_reg_i_22__0
       (.I0(dout_a_reg_i_13__0_n_0),
        .I1(dout_a_reg_13),
        .I2(dout_a_reg_14),
        .I3(dout_a_reg_i_14_n_0),
        .I4(dout_a_reg_i_16__0_n_0),
        .O(dout_a_reg_i_22__0_n_0));
  LUT5 #(
    .INIT(32'hFFFF44F0)) 
    dout_a_reg_i_23__0
       (.I0(dout_a_reg_i_13__0_n_0),
        .I1(dout_a_reg_9),
        .I2(dout_a_reg_10),
        .I3(dout_a_reg_i_14_n_0),
        .I4(dout_a_reg_i_16__0_n_0),
        .O(dout_a_reg_i_23__0_n_0));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT5 #(
    .INIT(32'h00200000)) 
    dout_a_reg_i_24__0
       (.I0(D[2]),
        .I1(D[1]),
        .I2(D[0]),
        .I3(slim_port_sel_IBUF[2]),
        .I4(slim_en_sel_IBUF[2]),
        .O(dout_a_reg_i_24__0_n_0));
  LUT5 #(
    .INIT(32'hBBB88888)) 
    dout_a_reg_i_3__4
       (.I0(dout_a_reg_15),
        .I1(dout_a_reg_i_12__4_n_0),
        .I2(dout_a_reg_i_9__1_n_0),
        .I3(dout_a_reg_16),
        .I4(dout_a_reg_i_17__3_n_0),
        .O(\addrA_bank[5]_9 [2]));
  LUT5 #(
    .INIT(32'hBBB88888)) 
    dout_a_reg_i_4__4
       (.I0(dout_a_reg_11),
        .I1(dout_a_reg_i_12__4_n_0),
        .I2(dout_a_reg_i_9__1_n_0),
        .I3(dout_a_reg_12),
        .I4(dout_a_reg_i_18__3_n_0),
        .O(\addrA_bank[5]_9 [1]));
  LUT5 #(
    .INIT(32'hBBB88888)) 
    dout_a_reg_i_5__4
       (.I0(dout_a_reg_7),
        .I1(dout_a_reg_i_12__4_n_0),
        .I2(dout_a_reg_i_9__1_n_0),
        .I3(dout_a_reg_8),
        .I4(dout_a_reg_i_19__3_n_0),
        .O(\addrA_bank[5]_9 [0]));
  LUT5 #(
    .INIT(32'hBBB88888)) 
    dout_a_reg_i_6
       (.I0(dout_a_reg_15),
        .I1(dout_a_reg_i_15__0_n_0),
        .I2(dout_a_reg_i_20__0_n_0),
        .I3(dout_a_reg_16),
        .I4(dout_a_reg_i_21_n_0),
        .O(\addrB_bank[5]_10 [2]));
  LUT5 #(
    .INIT(32'hBBB88888)) 
    dout_a_reg_i_7
       (.I0(dout_a_reg_11),
        .I1(dout_a_reg_i_15__0_n_0),
        .I2(dout_a_reg_i_20__0_n_0),
        .I3(dout_a_reg_12),
        .I4(dout_a_reg_i_22__0_n_0),
        .O(\addrB_bank[5]_10 [1]));
  LUT5 #(
    .INIT(32'hBBB88888)) 
    dout_a_reg_i_8
       (.I0(dout_a_reg_7),
        .I1(dout_a_reg_i_15__0_n_0),
        .I2(dout_a_reg_i_20__0_n_0),
        .I3(dout_a_reg_8),
        .I4(dout_a_reg_i_23__0_n_0),
        .O(\addrB_bank[5]_10 [0]));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT5 #(
    .INIT(32'hFFDFFFFF)) 
    dout_a_reg_i_9__1
       (.I0(D[0]),
        .I1(D[1]),
        .I2(D[2]),
        .I3(slim_port_sel_IBUF[2]),
        .I4(slim_en_sel_IBUF[2]),
        .O(dout_a_reg_i_9__1_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \slim_dout_sel[0][31]_INST_0_i_2 
       (.I0(\doutB_bank[5]__0 ),
        .I1(DOUTBDOUT),
        .I2(Q[0]),
        .I3(\doutA_bank[5]__0 ),
        .I4(\slim_dout_sel[0][31]_INST_0_i_1 ),
        .I5(DOUTADOUT),
        .O(dout_a_reg_5));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \slim_dout_sel[1][31]_INST_0_i_2 
       (.I0(\doutB_bank[5]__0 ),
        .I1(DOUTBDOUT),
        .I2(Q[1]),
        .I3(\doutA_bank[5]__0 ),
        .I4(\slim_dout_sel[1][31]_INST_0_i_1 ),
        .I5(DOUTADOUT),
        .O(dout_a_reg_4));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \slim_dout_sel[2][31]_INST_0_i_2 
       (.I0(\doutB_bank[5]__0 ),
        .I1(DOUTBDOUT),
        .I2(Q[2]),
        .I3(\doutA_bank[5]__0 ),
        .I4(\slim_dout_sel[2][31]_INST_0_i_1 ),
        .I5(DOUTADOUT),
        .O(dout_a_reg_3));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \slim_dout_sel[3][31]_INST_0_i_2 
       (.I0(\doutB_bank[5]__0 ),
        .I1(DOUTBDOUT),
        .I2(Q[3]),
        .I3(\doutA_bank[5]__0 ),
        .I4(\slim_dout_sel[3][31]_INST_0_i_1 ),
        .I5(DOUTADOUT),
        .O(dout_a_reg_2));
endmodule

(* BANK0_INIT_FILE = "E:/course/smamba/HW_reconstruct/tb/weight_bank_mem/bank0.mem" *) (* BANK1_INIT_FILE = "E:/course/smamba/HW_reconstruct/tb/weight_bank_mem/bank1.mem" *) (* BANK2_INIT_FILE = "E:/course/smamba/HW_reconstruct/tb/weight_bank_mem/bank2.mem" *) 
(* BANK3_INIT_FILE = "E:/course/smamba/HW_reconstruct/tb/weight_bank_mem/bank3.mem" *) (* BANK4_INIT_FILE = "E:/course/smamba/HW_reconstruct/tb/weight_bank_mem/bank4.mem" *) (* BANK5_INIT_FILE = "E:/course/smamba/HW_reconstruct/tb/weight_bank_mem/bank5.mem" *) 
(* N_BANK = "6" *) (* ROM_ADDR_W = "3" *) (* ROM_DATA_W = "32" *) 
(* ROM_DEPTH = "8" *) (* ROM_INIT_FILE = "E:/course/smamba/HW_reconstruct/tb/weight_bank_mem/bank0.mem" *) (* WBUF_ADDR_W = "3" *) 
(* WBUF_DATA_W = "32" *) (* WBUF_DEPTH = "8" *) 
(* NotValidForBitStream *)
module reuse_weight_bank_storage_consistency_dut
   (clk,
    rst_n,
    rom_en_a,
    rom_addr_a,
    rom_dout_a,
    rom_en_b,
    rom_addr_b,
    rom_dout_b,
    \slim_bank_sel[3] ,
    \slim_bank_sel[2] ,
    \slim_bank_sel[1] ,
    \slim_bank_sel[0] ,
    \slim_addr_sel[3] ,
    \slim_addr_sel[2] ,
    \slim_addr_sel[1] ,
    \slim_addr_sel[0] ,
    slim_en_sel,
    slim_port_sel,
    \slim_dout_sel[3] ,
    \slim_dout_sel[2] ,
    \slim_dout_sel[1] ,
    \slim_dout_sel[0] );
  input clk;
  input rst_n;
  input rom_en_a;
  input [2:0]rom_addr_a;
  output [31:0]rom_dout_a;
  input rom_en_b;
  input [2:0]rom_addr_b;
  output [31:0]rom_dout_b;
  input [2:0]\slim_bank_sel[3] ;
  input [2:0]\slim_bank_sel[2] ;
  input [2:0]\slim_bank_sel[1] ;
  input [2:0]\slim_bank_sel[0] ;
  input [2:0]\slim_addr_sel[3] ;
  input [2:0]\slim_addr_sel[2] ;
  input [2:0]\slim_addr_sel[1] ;
  input [2:0]\slim_addr_sel[0] ;
  input [3:0]slim_en_sel;
  input [3:0]slim_port_sel;
  output [31:0]\slim_dout_sel[3] ;
  output [31:0]\slim_dout_sel[2] ;
  output [31:0]\slim_dout_sel[1] ;
  output [31:0]\slim_dout_sel[0] ;

  wire \bank_sel_q_reg[0][0]_i_1_n_0 ;
  wire \bank_sel_q_reg[0][1]_i_1_n_0 ;
  wire \bank_sel_q_reg[0][2]_i_1_n_0 ;
  wire \bank_sel_q_reg[1][0]_i_1_n_0 ;
  wire \bank_sel_q_reg[1][1]_i_1_n_0 ;
  wire \bank_sel_q_reg[1][2]_i_1_n_0 ;
  wire \bank_sel_q_reg[2][0]_i_1_n_0 ;
  wire \bank_sel_q_reg[2][1]_i_1_n_0 ;
  wire \bank_sel_q_reg[2][2]_i_1_n_0 ;
  wire \bank_sel_q_reg[3][0]_i_1_n_0 ;
  wire \bank_sel_q_reg[3][1]_i_1_n_0 ;
  wire \bank_sel_q_reg[3][2]_i_1_n_0 ;
  wire clk;
  wire clk_IBUF;
  wire clk_IBUF_BUFG;
  wire dout_a_reg_i_17__4_n_0;
  wire dout_a_reg_i_18__4_n_0;
  wire dout_a_reg_i_20__4_n_0;
  wire dout_a_reg_i_21__4_n_0;
  wire dout_a_reg_i_23__1_n_0;
  wire dout_a_reg_i_24__1_n_0;
  wire dout_a_reg_i_29_n_0;
  wire dout_a_reg_i_30_n_0;
  wire dout_a_reg_i_31_n_0;
  wire dout_a_reg_i_32_n_0;
  wire dout_a_reg_i_33_n_0;
  wire dout_a_reg_i_34_n_0;
  wire [2:0]rom_addr_a;
  wire [2:0]rom_addr_a_IBUF;
  wire [2:0]rom_addr_b;
  wire [2:0]rom_addr_b_IBUF;
  wire [31:0]rom_dout_a;
  wire [3:0]rom_dout_a_OBUF;
  wire [31:0]rom_dout_b;
  wire [3:0]rom_dout_b_OBUF;
  wire rom_en_a;
  wire rom_en_a_IBUF;
  wire rom_en_b;
  wire rom_en_b_IBUF;
  wire rst_n;
  wire rst_n_IBUF;
  wire [2:0]\slim_addr_sel[0] ;
  wire [2:0]\slim_addr_sel[1] ;
  wire [2:0]\slim_addr_sel[2] ;
  wire [2:0]\slim_addr_sel[3] ;
  wire [2:0]\slim_bank_sel[0] ;
  wire [2:0]\slim_bank_sel[1] ;
  wire [2:0]\slim_bank_sel[2] ;
  wire [2:0]\slim_bank_sel[3] ;
  wire [31:0]\slim_dout_sel[0] ;
  wire [30:0]\slim_dout_sel[0]_OBUF ;
  wire [31:0]\slim_dout_sel[1] ;
  wire [30:0]\slim_dout_sel[1]_OBUF ;
  wire [31:0]\slim_dout_sel[2] ;
  wire [30:0]\slim_dout_sel[2]_OBUF ;
  wire [31:0]\slim_dout_sel[3] ;
  wire [30:0]\slim_dout_sel[3]_OBUF ;
  wire [3:0]slim_en_sel;
  wire [3:0]slim_en_sel_IBUF;
  wire [3:0]slim_port_sel;
  wire [3:0]slim_port_sel_IBUF;

  IBUF \bank_sel_q_reg[0][0]_i_1 
       (.I(\slim_bank_sel[0] [0]),
        .O(\bank_sel_q_reg[0][0]_i_1_n_0 ));
  IBUF \bank_sel_q_reg[0][1]_i_1 
       (.I(\slim_bank_sel[0] [1]),
        .O(\bank_sel_q_reg[0][1]_i_1_n_0 ));
  IBUF \bank_sel_q_reg[0][2]_i_1 
       (.I(\slim_bank_sel[0] [2]),
        .O(\bank_sel_q_reg[0][2]_i_1_n_0 ));
  IBUF \bank_sel_q_reg[1][0]_i_1 
       (.I(\slim_bank_sel[1] [0]),
        .O(\bank_sel_q_reg[1][0]_i_1_n_0 ));
  IBUF \bank_sel_q_reg[1][1]_i_1 
       (.I(\slim_bank_sel[1] [1]),
        .O(\bank_sel_q_reg[1][1]_i_1_n_0 ));
  IBUF \bank_sel_q_reg[1][2]_i_1 
       (.I(\slim_bank_sel[1] [2]),
        .O(\bank_sel_q_reg[1][2]_i_1_n_0 ));
  IBUF \bank_sel_q_reg[2][0]_i_1 
       (.I(\slim_bank_sel[2] [0]),
        .O(\bank_sel_q_reg[2][0]_i_1_n_0 ));
  IBUF \bank_sel_q_reg[2][1]_i_1 
       (.I(\slim_bank_sel[2] [1]),
        .O(\bank_sel_q_reg[2][1]_i_1_n_0 ));
  IBUF \bank_sel_q_reg[2][2]_i_1 
       (.I(\slim_bank_sel[2] [2]),
        .O(\bank_sel_q_reg[2][2]_i_1_n_0 ));
  IBUF \bank_sel_q_reg[3][0]_i_1 
       (.I(\slim_bank_sel[3] [0]),
        .O(\bank_sel_q_reg[3][0]_i_1_n_0 ));
  IBUF \bank_sel_q_reg[3][1]_i_1 
       (.I(\slim_bank_sel[3] [1]),
        .O(\bank_sel_q_reg[3][1]_i_1_n_0 ));
  IBUF \bank_sel_q_reg[3][2]_i_1 
       (.I(\slim_bank_sel[3] [2]),
        .O(\bank_sel_q_reg[3][2]_i_1_n_0 ));
  (* XILINX_LEGACY_PRIM = "BUFG" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:CE" *) 
  BUFGCE #(
    .CE_TYPE("ASYNC"),
    .SIM_DEVICE("ULTRASCALE_PLUS")) 
    clk_IBUF_BUFG_inst
       (.CE(1'b1),
        .I(clk_IBUF),
        .O(clk_IBUF_BUFG));
  IBUF clk_IBUF_inst
       (.I(clk),
        .O(clk_IBUF));
  IBUF dout_a_reg_i_17__4
       (.I(\slim_addr_sel[3] [2]),
        .O(dout_a_reg_i_17__4_n_0));
  IBUF dout_a_reg_i_18__4
       (.I(\slim_addr_sel[2] [2]),
        .O(dout_a_reg_i_18__4_n_0));
  IBUF dout_a_reg_i_20__4
       (.I(\slim_addr_sel[3] [1]),
        .O(dout_a_reg_i_20__4_n_0));
  IBUF dout_a_reg_i_21__4
       (.I(\slim_addr_sel[2] [1]),
        .O(dout_a_reg_i_21__4_n_0));
  IBUF dout_a_reg_i_23__1
       (.I(\slim_addr_sel[3] [0]),
        .O(dout_a_reg_i_23__1_n_0));
  IBUF dout_a_reg_i_24__1
       (.I(\slim_addr_sel[2] [0]),
        .O(dout_a_reg_i_24__1_n_0));
  IBUF dout_a_reg_i_29
       (.I(\slim_addr_sel[0] [2]),
        .O(dout_a_reg_i_29_n_0));
  IBUF dout_a_reg_i_30
       (.I(\slim_addr_sel[1] [2]),
        .O(dout_a_reg_i_30_n_0));
  IBUF dout_a_reg_i_31
       (.I(\slim_addr_sel[0] [1]),
        .O(dout_a_reg_i_31_n_0));
  IBUF dout_a_reg_i_32
       (.I(\slim_addr_sel[1] [1]),
        .O(dout_a_reg_i_32_n_0));
  IBUF dout_a_reg_i_33
       (.I(\slim_addr_sel[0] [0]),
        .O(dout_a_reg_i_33_n_0));
  IBUF dout_a_reg_i_34
       (.I(\slim_addr_sel[1] [0]),
        .O(dout_a_reg_i_34_n_0));
  IBUF \rom_addr_a_IBUF[0]_inst 
       (.I(rom_addr_a[0]),
        .O(rom_addr_a_IBUF[0]));
  IBUF \rom_addr_a_IBUF[1]_inst 
       (.I(rom_addr_a[1]),
        .O(rom_addr_a_IBUF[1]));
  IBUF \rom_addr_a_IBUF[2]_inst 
       (.I(rom_addr_a[2]),
        .O(rom_addr_a_IBUF[2]));
  IBUF \rom_addr_b_IBUF[0]_inst 
       (.I(rom_addr_b[0]),
        .O(rom_addr_b_IBUF[0]));
  IBUF \rom_addr_b_IBUF[1]_inst 
       (.I(rom_addr_b[1]),
        .O(rom_addr_b_IBUF[1]));
  IBUF \rom_addr_b_IBUF[2]_inst 
       (.I(rom_addr_b[2]),
        .O(rom_addr_b_IBUF[2]));
  OBUF \rom_dout_a_OBUF[0]_inst 
       (.I(rom_dout_a_OBUF[0]),
        .O(rom_dout_a[0]));
  OBUF \rom_dout_a_OBUF[10]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[10]));
  OBUF \rom_dout_a_OBUF[11]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[11]));
  OBUF \rom_dout_a_OBUF[12]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[12]));
  OBUF \rom_dout_a_OBUF[13]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[13]));
  OBUF \rom_dout_a_OBUF[14]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[14]));
  OBUF \rom_dout_a_OBUF[15]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[15]));
  OBUF \rom_dout_a_OBUF[16]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[16]));
  OBUF \rom_dout_a_OBUF[17]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[17]));
  OBUF \rom_dout_a_OBUF[18]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[18]));
  OBUF \rom_dout_a_OBUF[19]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[19]));
  OBUF \rom_dout_a_OBUF[1]_inst 
       (.I(rom_dout_a_OBUF[1]),
        .O(rom_dout_a[1]));
  OBUF \rom_dout_a_OBUF[20]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[20]));
  OBUF \rom_dout_a_OBUF[21]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[21]));
  OBUF \rom_dout_a_OBUF[22]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[22]));
  OBUF \rom_dout_a_OBUF[23]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[23]));
  OBUF \rom_dout_a_OBUF[24]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[24]));
  OBUF \rom_dout_a_OBUF[25]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[25]));
  OBUF \rom_dout_a_OBUF[26]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[26]));
  OBUF \rom_dout_a_OBUF[27]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[27]));
  OBUF \rom_dout_a_OBUF[28]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[28]));
  OBUF \rom_dout_a_OBUF[29]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[29]));
  OBUF \rom_dout_a_OBUF[2]_inst 
       (.I(rom_dout_a_OBUF[2]),
        .O(rom_dout_a[2]));
  OBUF \rom_dout_a_OBUF[30]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[30]));
  OBUF \rom_dout_a_OBUF[31]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[31]));
  OBUF \rom_dout_a_OBUF[3]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[3]));
  OBUF \rom_dout_a_OBUF[4]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[4]));
  OBUF \rom_dout_a_OBUF[5]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[5]));
  OBUF \rom_dout_a_OBUF[6]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[6]));
  OBUF \rom_dout_a_OBUF[7]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[7]));
  OBUF \rom_dout_a_OBUF[8]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[8]));
  OBUF \rom_dout_a_OBUF[9]_inst 
       (.I(rom_dout_a_OBUF[3]),
        .O(rom_dout_a[9]));
  OBUF \rom_dout_b_OBUF[0]_inst 
       (.I(rom_dout_b_OBUF[0]),
        .O(rom_dout_b[0]));
  OBUF \rom_dout_b_OBUF[10]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[10]));
  OBUF \rom_dout_b_OBUF[11]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[11]));
  OBUF \rom_dout_b_OBUF[12]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[12]));
  OBUF \rom_dout_b_OBUF[13]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[13]));
  OBUF \rom_dout_b_OBUF[14]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[14]));
  OBUF \rom_dout_b_OBUF[15]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[15]));
  OBUF \rom_dout_b_OBUF[16]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[16]));
  OBUF \rom_dout_b_OBUF[17]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[17]));
  OBUF \rom_dout_b_OBUF[18]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[18]));
  OBUF \rom_dout_b_OBUF[19]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[19]));
  OBUF \rom_dout_b_OBUF[1]_inst 
       (.I(rom_dout_b_OBUF[1]),
        .O(rom_dout_b[1]));
  OBUF \rom_dout_b_OBUF[20]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[20]));
  OBUF \rom_dout_b_OBUF[21]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[21]));
  OBUF \rom_dout_b_OBUF[22]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[22]));
  OBUF \rom_dout_b_OBUF[23]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[23]));
  OBUF \rom_dout_b_OBUF[24]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[24]));
  OBUF \rom_dout_b_OBUF[25]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[25]));
  OBUF \rom_dout_b_OBUF[26]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[26]));
  OBUF \rom_dout_b_OBUF[27]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[27]));
  OBUF \rom_dout_b_OBUF[28]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[28]));
  OBUF \rom_dout_b_OBUF[29]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[29]));
  OBUF \rom_dout_b_OBUF[2]_inst 
       (.I(rom_dout_b_OBUF[2]),
        .O(rom_dout_b[2]));
  OBUF \rom_dout_b_OBUF[30]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[30]));
  OBUF \rom_dout_b_OBUF[31]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[31]));
  OBUF \rom_dout_b_OBUF[3]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[3]));
  OBUF \rom_dout_b_OBUF[4]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[4]));
  OBUF \rom_dout_b_OBUF[5]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[5]));
  OBUF \rom_dout_b_OBUF[6]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[6]));
  OBUF \rom_dout_b_OBUF[7]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[7]));
  OBUF \rom_dout_b_OBUF[8]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[8]));
  OBUF \rom_dout_b_OBUF[9]_inst 
       (.I(rom_dout_b_OBUF[3]),
        .O(rom_dout_b[9]));
  IBUF rom_en_a_IBUF_inst
       (.I(rom_en_a),
        .O(rom_en_a_IBUF));
  IBUF rom_en_b_IBUF_inst
       (.I(rom_en_b),
        .O(rom_en_b_IBUF));
  IBUF rst_n_IBUF_inst
       (.I(rst_n),
        .O(rst_n_IBUF));
  OBUF \slim_dout_sel[0][0]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [0]),
        .O(\slim_dout_sel[0] [0]));
  OBUF \slim_dout_sel[0][10]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [10]));
  OBUF \slim_dout_sel[0][11]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [11]));
  OBUF \slim_dout_sel[0][12]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [12]));
  OBUF \slim_dout_sel[0][13]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [13]));
  OBUF \slim_dout_sel[0][14]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [14]));
  OBUF \slim_dout_sel[0][15]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [15]));
  OBUF \slim_dout_sel[0][16]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [16]));
  OBUF \slim_dout_sel[0][17]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [17]));
  OBUF \slim_dout_sel[0][18]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [18]));
  OBUF \slim_dout_sel[0][19]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [19]));
  OBUF \slim_dout_sel[0][1]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [1]),
        .O(\slim_dout_sel[0] [1]));
  OBUF \slim_dout_sel[0][20]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [20]));
  OBUF \slim_dout_sel[0][21]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [21]));
  OBUF \slim_dout_sel[0][22]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [22]));
  OBUF \slim_dout_sel[0][23]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [23]));
  OBUF \slim_dout_sel[0][24]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [24]));
  OBUF \slim_dout_sel[0][25]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [25]));
  OBUF \slim_dout_sel[0][26]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [26]));
  OBUF \slim_dout_sel[0][27]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [27]));
  OBUF \slim_dout_sel[0][28]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [28]),
        .O(\slim_dout_sel[0] [28]));
  OBUF \slim_dout_sel[0][29]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [29]),
        .O(\slim_dout_sel[0] [29]));
  OBUF \slim_dout_sel[0][2]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [2]),
        .O(\slim_dout_sel[0] [2]));
  OBUF \slim_dout_sel[0][30]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [30]),
        .O(\slim_dout_sel[0] [30]));
  OBUF \slim_dout_sel[0][31]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [31]));
  OBUF \slim_dout_sel[0][3]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [3]));
  OBUF \slim_dout_sel[0][4]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [4]));
  OBUF \slim_dout_sel[0][5]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [5]));
  OBUF \slim_dout_sel[0][6]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [6]));
  OBUF \slim_dout_sel[0][7]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [7]));
  OBUF \slim_dout_sel[0][8]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [8]));
  OBUF \slim_dout_sel[0][9]_INST_0 
       (.I(\slim_dout_sel[0]_OBUF [3]),
        .O(\slim_dout_sel[0] [9]));
  OBUF \slim_dout_sel[1][0]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [0]),
        .O(\slim_dout_sel[1] [0]));
  OBUF \slim_dout_sel[1][10]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [10]));
  OBUF \slim_dout_sel[1][11]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [11]));
  OBUF \slim_dout_sel[1][12]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [12]));
  OBUF \slim_dout_sel[1][13]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [13]));
  OBUF \slim_dout_sel[1][14]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [14]));
  OBUF \slim_dout_sel[1][15]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [15]));
  OBUF \slim_dout_sel[1][16]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [16]));
  OBUF \slim_dout_sel[1][17]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [17]));
  OBUF \slim_dout_sel[1][18]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [18]));
  OBUF \slim_dout_sel[1][19]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [19]));
  OBUF \slim_dout_sel[1][1]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [1]),
        .O(\slim_dout_sel[1] [1]));
  OBUF \slim_dout_sel[1][20]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [20]));
  OBUF \slim_dout_sel[1][21]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [21]));
  OBUF \slim_dout_sel[1][22]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [22]));
  OBUF \slim_dout_sel[1][23]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [23]));
  OBUF \slim_dout_sel[1][24]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [24]));
  OBUF \slim_dout_sel[1][25]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [25]));
  OBUF \slim_dout_sel[1][26]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [26]));
  OBUF \slim_dout_sel[1][27]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [27]));
  OBUF \slim_dout_sel[1][28]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [28]),
        .O(\slim_dout_sel[1] [28]));
  OBUF \slim_dout_sel[1][29]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [29]),
        .O(\slim_dout_sel[1] [29]));
  OBUF \slim_dout_sel[1][2]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [2]),
        .O(\slim_dout_sel[1] [2]));
  OBUF \slim_dout_sel[1][30]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [30]),
        .O(\slim_dout_sel[1] [30]));
  OBUF \slim_dout_sel[1][31]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [31]));
  OBUF \slim_dout_sel[1][3]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [3]));
  OBUF \slim_dout_sel[1][4]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [4]));
  OBUF \slim_dout_sel[1][5]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [5]));
  OBUF \slim_dout_sel[1][6]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [6]));
  OBUF \slim_dout_sel[1][7]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [7]));
  OBUF \slim_dout_sel[1][8]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [8]));
  OBUF \slim_dout_sel[1][9]_INST_0 
       (.I(\slim_dout_sel[1]_OBUF [3]),
        .O(\slim_dout_sel[1] [9]));
  OBUF \slim_dout_sel[2][0]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [0]),
        .O(\slim_dout_sel[2] [0]));
  OBUF \slim_dout_sel[2][10]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [10]));
  OBUF \slim_dout_sel[2][11]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [11]));
  OBUF \slim_dout_sel[2][12]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [12]));
  OBUF \slim_dout_sel[2][13]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [13]));
  OBUF \slim_dout_sel[2][14]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [14]));
  OBUF \slim_dout_sel[2][15]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [15]));
  OBUF \slim_dout_sel[2][16]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [16]));
  OBUF \slim_dout_sel[2][17]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [17]));
  OBUF \slim_dout_sel[2][18]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [18]));
  OBUF \slim_dout_sel[2][19]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [19]));
  OBUF \slim_dout_sel[2][1]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [1]),
        .O(\slim_dout_sel[2] [1]));
  OBUF \slim_dout_sel[2][20]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [20]));
  OBUF \slim_dout_sel[2][21]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [21]));
  OBUF \slim_dout_sel[2][22]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [22]));
  OBUF \slim_dout_sel[2][23]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [23]));
  OBUF \slim_dout_sel[2][24]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [24]));
  OBUF \slim_dout_sel[2][25]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [25]));
  OBUF \slim_dout_sel[2][26]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [26]));
  OBUF \slim_dout_sel[2][27]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [27]));
  OBUF \slim_dout_sel[2][28]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [28]),
        .O(\slim_dout_sel[2] [28]));
  OBUF \slim_dout_sel[2][29]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [29]),
        .O(\slim_dout_sel[2] [29]));
  OBUF \slim_dout_sel[2][2]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [2]),
        .O(\slim_dout_sel[2] [2]));
  OBUF \slim_dout_sel[2][30]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [30]),
        .O(\slim_dout_sel[2] [30]));
  OBUF \slim_dout_sel[2][31]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [31]));
  OBUF \slim_dout_sel[2][3]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [3]));
  OBUF \slim_dout_sel[2][4]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [4]));
  OBUF \slim_dout_sel[2][5]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [5]));
  OBUF \slim_dout_sel[2][6]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [6]));
  OBUF \slim_dout_sel[2][7]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [7]));
  OBUF \slim_dout_sel[2][8]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [8]));
  OBUF \slim_dout_sel[2][9]_INST_0 
       (.I(\slim_dout_sel[2]_OBUF [3]),
        .O(\slim_dout_sel[2] [9]));
  OBUF \slim_dout_sel[3][0]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [0]),
        .O(\slim_dout_sel[3] [0]));
  OBUF \slim_dout_sel[3][10]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [10]));
  OBUF \slim_dout_sel[3][11]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [11]));
  OBUF \slim_dout_sel[3][12]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [12]));
  OBUF \slim_dout_sel[3][13]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [13]));
  OBUF \slim_dout_sel[3][14]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [14]));
  OBUF \slim_dout_sel[3][15]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [15]));
  OBUF \slim_dout_sel[3][16]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [16]));
  OBUF \slim_dout_sel[3][17]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [17]));
  OBUF \slim_dout_sel[3][18]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [18]));
  OBUF \slim_dout_sel[3][19]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [19]));
  OBUF \slim_dout_sel[3][1]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [1]),
        .O(\slim_dout_sel[3] [1]));
  OBUF \slim_dout_sel[3][20]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [20]));
  OBUF \slim_dout_sel[3][21]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [21]));
  OBUF \slim_dout_sel[3][22]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [22]));
  OBUF \slim_dout_sel[3][23]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [23]));
  OBUF \slim_dout_sel[3][24]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [24]));
  OBUF \slim_dout_sel[3][25]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [25]));
  OBUF \slim_dout_sel[3][26]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [26]));
  OBUF \slim_dout_sel[3][27]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [27]));
  OBUF \slim_dout_sel[3][28]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [28]),
        .O(\slim_dout_sel[3] [28]));
  OBUF \slim_dout_sel[3][29]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [29]),
        .O(\slim_dout_sel[3] [29]));
  OBUF \slim_dout_sel[3][2]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [2]),
        .O(\slim_dout_sel[3] [2]));
  OBUF \slim_dout_sel[3][30]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [30]),
        .O(\slim_dout_sel[3] [30]));
  OBUF \slim_dout_sel[3][31]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [31]));
  OBUF \slim_dout_sel[3][3]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [3]));
  OBUF \slim_dout_sel[3][4]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [4]));
  OBUF \slim_dout_sel[3][5]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [5]));
  OBUF \slim_dout_sel[3][6]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [6]));
  OBUF \slim_dout_sel[3][7]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [7]));
  OBUF \slim_dout_sel[3][8]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [8]));
  OBUF \slim_dout_sel[3][9]_INST_0 
       (.I(\slim_dout_sel[3]_OBUF [3]),
        .O(\slim_dout_sel[3] [9]));
  IBUF \slim_en_sel_IBUF[0]_inst 
       (.I(slim_en_sel[0]),
        .O(slim_en_sel_IBUF[0]));
  IBUF \slim_en_sel_IBUF[1]_inst 
       (.I(slim_en_sel[1]),
        .O(slim_en_sel_IBUF[1]));
  IBUF \slim_en_sel_IBUF[2]_inst 
       (.I(slim_en_sel[2]),
        .O(slim_en_sel_IBUF[2]));
  IBUF \slim_en_sel_IBUF[3]_inst 
       (.I(slim_en_sel[3]),
        .O(slim_en_sel_IBUF[3]));
  IBUF \slim_port_sel_IBUF[0]_inst 
       (.I(slim_port_sel[0]),
        .O(slim_port_sel_IBUF[0]));
  IBUF \slim_port_sel_IBUF[1]_inst 
       (.I(slim_port_sel[1]),
        .O(slim_port_sel_IBUF[1]));
  IBUF \slim_port_sel_IBUF[2]_inst 
       (.I(slim_port_sel[2]),
        .O(slim_port_sel_IBUF[2]));
  IBUF \slim_port_sel_IBUF[3]_inst 
       (.I(slim_port_sel[3]),
        .O(slim_port_sel_IBUF[3]));
  reuse_weight_bank_rom u_rom
       (.ADDRARDADDR(rom_addr_a_IBUF),
        .ADDRBWRADDR(rom_addr_b_IBUF),
        .DOUTADOUT(rom_dout_a_OBUF),
        .DOUTBDOUT(rom_dout_b_OBUF),
        .clk_IBUF_BUFG(clk_IBUF_BUFG),
        .rom_en_a_IBUF(rom_en_a_IBUF),
        .rom_en_b_IBUF(rom_en_b_IBUF));
  slim_multi_bank_wbuf_dp u_wbuf
       (.\bank_sel_q_reg[0][0]_0 (\bank_sel_q_reg[0][0]_i_1_n_0 ),
        .\bank_sel_q_reg[0][1]_0 (\bank_sel_q_reg[0][1]_i_1_n_0 ),
        .\bank_sel_q_reg[0][2]_0 (\bank_sel_q_reg[0][2]_i_1_n_0 ),
        .\bank_sel_q_reg[1][0]_0 (\bank_sel_q_reg[1][0]_i_1_n_0 ),
        .\bank_sel_q_reg[1][1]_0 (\bank_sel_q_reg[1][1]_i_1_n_0 ),
        .\bank_sel_q_reg[1][2]_0 (\bank_sel_q_reg[1][2]_i_1_n_0 ),
        .\bank_sel_q_reg[2][0]_0 (\bank_sel_q_reg[2][0]_i_1_n_0 ),
        .\bank_sel_q_reg[2][1]_0 (\bank_sel_q_reg[2][1]_i_1_n_0 ),
        .\bank_sel_q_reg[2][2]_0 (\bank_sel_q_reg[2][2]_i_1_n_0 ),
        .\bank_sel_q_reg[3][0]_0 (\bank_sel_q_reg[3][0]_i_1_n_0 ),
        .\bank_sel_q_reg[3][1]_0 (\bank_sel_q_reg[3][1]_i_1_n_0 ),
        .\bank_sel_q_reg[3][2]_0 (\bank_sel_q_reg[3][2]_i_1_n_0 ),
        .clk_IBUF_BUFG(clk_IBUF_BUFG),
        .dout_a_reg(dout_a_reg_i_23__1_n_0),
        .dout_a_reg_0(dout_a_reg_i_24__1_n_0),
        .dout_a_reg_1(dout_a_reg_i_33_n_0),
        .dout_a_reg_10(dout_a_reg_i_30_n_0),
        .dout_a_reg_2(dout_a_reg_i_34_n_0),
        .dout_a_reg_3(dout_a_reg_i_20__4_n_0),
        .dout_a_reg_4(dout_a_reg_i_21__4_n_0),
        .dout_a_reg_5(dout_a_reg_i_31_n_0),
        .dout_a_reg_6(dout_a_reg_i_32_n_0),
        .dout_a_reg_7(dout_a_reg_i_17__4_n_0),
        .dout_a_reg_8(dout_a_reg_i_18__4_n_0),
        .dout_a_reg_9(dout_a_reg_i_29_n_0),
        .rst_n_IBUF(rst_n_IBUF),
        .\slim_dout_sel[0]_OBUF ({\slim_dout_sel[0]_OBUF [30:28],\slim_dout_sel[0]_OBUF [3:0]}),
        .\slim_dout_sel[1]_OBUF ({\slim_dout_sel[1]_OBUF [30:28],\slim_dout_sel[1]_OBUF [3:0]}),
        .\slim_dout_sel[2]_OBUF ({\slim_dout_sel[2]_OBUF [30:28],\slim_dout_sel[2]_OBUF [3:0]}),
        .\slim_dout_sel[3]_OBUF ({\slim_dout_sel[3]_OBUF [30:28],\slim_dout_sel[3]_OBUF [3:0]}),
        .slim_en_sel_IBUF(slim_en_sel_IBUF),
        .slim_port_sel_IBUF(slim_port_sel_IBUF));
endmodule

module slim_multi_bank_wbuf_dp
   (\slim_dout_sel[3]_OBUF ,
    \slim_dout_sel[2]_OBUF ,
    \slim_dout_sel[1]_OBUF ,
    \slim_dout_sel[0]_OBUF ,
    \bank_sel_q_reg[3][1]_0 ,
    \bank_sel_q_reg[3][2]_0 ,
    \bank_sel_q_reg[3][0]_0 ,
    slim_port_sel_IBUF,
    slim_en_sel_IBUF,
    \bank_sel_q_reg[2][0]_0 ,
    \bank_sel_q_reg[2][1]_0 ,
    \bank_sel_q_reg[2][2]_0 ,
    clk_IBUF_BUFG,
    \bank_sel_q_reg[1][2]_0 ,
    \bank_sel_q_reg[1][1]_0 ,
    \bank_sel_q_reg[1][0]_0 ,
    \bank_sel_q_reg[0][2]_0 ,
    \bank_sel_q_reg[0][1]_0 ,
    \bank_sel_q_reg[0][0]_0 ,
    dout_a_reg,
    dout_a_reg_0,
    dout_a_reg_1,
    dout_a_reg_2,
    dout_a_reg_3,
    dout_a_reg_4,
    dout_a_reg_5,
    dout_a_reg_6,
    dout_a_reg_7,
    dout_a_reg_8,
    dout_a_reg_9,
    dout_a_reg_10,
    rst_n_IBUF);
  output [6:0]\slim_dout_sel[3]_OBUF ;
  output [6:0]\slim_dout_sel[2]_OBUF ;
  output [6:0]\slim_dout_sel[1]_OBUF ;
  output [6:0]\slim_dout_sel[0]_OBUF ;
  input \bank_sel_q_reg[3][1]_0 ;
  input \bank_sel_q_reg[3][2]_0 ;
  input \bank_sel_q_reg[3][0]_0 ;
  input [3:0]slim_port_sel_IBUF;
  input [3:0]slim_en_sel_IBUF;
  input \bank_sel_q_reg[2][0]_0 ;
  input \bank_sel_q_reg[2][1]_0 ;
  input \bank_sel_q_reg[2][2]_0 ;
  input clk_IBUF_BUFG;
  input \bank_sel_q_reg[1][2]_0 ;
  input \bank_sel_q_reg[1][1]_0 ;
  input \bank_sel_q_reg[1][0]_0 ;
  input \bank_sel_q_reg[0][2]_0 ;
  input \bank_sel_q_reg[0][1]_0 ;
  input \bank_sel_q_reg[0][0]_0 ;
  input dout_a_reg;
  input dout_a_reg_0;
  input dout_a_reg_1;
  input dout_a_reg_2;
  input dout_a_reg_3;
  input dout_a_reg_4;
  input dout_a_reg_5;
  input dout_a_reg_6;
  input dout_a_reg_7;
  input dout_a_reg_8;
  input dout_a_reg_9;
  input dout_a_reg_10;
  input rst_n_IBUF;

  wire \WBUF_BANK[5].g_bank5.u_bank_n_10 ;
  wire \WBUF_BANK[5].g_bank5.u_bank_n_11 ;
  wire \WBUF_BANK[5].g_bank5.u_bank_n_8 ;
  wire \WBUF_BANK[5].g_bank5.u_bank_n_9 ;
  wire \bank_sel_q_reg[0][0]_0 ;
  wire \bank_sel_q_reg[0][1]_0 ;
  wire \bank_sel_q_reg[0][2]_0 ;
  wire [2:0]\bank_sel_q_reg[0]_3 ;
  wire \bank_sel_q_reg[1][0]_0 ;
  wire \bank_sel_q_reg[1][1]_0 ;
  wire \bank_sel_q_reg[1][2]_0 ;
  wire [2:0]\bank_sel_q_reg[1]_2 ;
  wire \bank_sel_q_reg[2][0]_0 ;
  wire \bank_sel_q_reg[2][1]_0 ;
  wire \bank_sel_q_reg[2][2]_0 ;
  wire [2:0]\bank_sel_q_reg[2]_1 ;
  wire \bank_sel_q_reg[3][0]_0 ;
  wire \bank_sel_q_reg[3][1]_0 ;
  wire \bank_sel_q_reg[3][2]_0 ;
  wire [2:0]\bank_sel_q_reg[3]_0 ;
  wire clk_IBUF_BUFG;
  wire [3:0]\doutA_bank[0]__0 ;
  wire [3:3]\doutA_bank[1]__0 ;
  wire [29:0]\doutA_bank[2]__0 ;
  wire [28:0]\doutA_bank[3]__0 ;
  wire [30:0]\doutA_bank[4]__0 ;
  wire [28:0]\doutA_bank[5]__0 ;
  wire [3:0]\doutB_bank[0]__0 ;
  wire [3:3]\doutB_bank[1]__0 ;
  wire [29:0]\doutB_bank[2]__0 ;
  wire [28:0]\doutB_bank[3]__0 ;
  wire [30:0]\doutB_bank[4]__0 ;
  wire [28:0]\doutB_bank[5]__0 ;
  wire dout_a_reg;
  wire dout_a_reg_0;
  wire dout_a_reg_1;
  wire dout_a_reg_10;
  wire dout_a_reg_2;
  wire dout_a_reg_3;
  wire dout_a_reg_4;
  wire dout_a_reg_5;
  wire dout_a_reg_6;
  wire dout_a_reg_7;
  wire dout_a_reg_8;
  wire dout_a_reg_9;
  wire \en_sel_q_reg_n_0_[0] ;
  wire \en_sel_q_reg_n_0_[1] ;
  wire \en_sel_q_reg_n_0_[2] ;
  wire \en_sel_q_reg_n_0_[3] ;
  wire \port_sel_q[3]_i_1_n_0 ;
  wire \port_sel_q_reg_n_0_[0] ;
  wire \port_sel_q_reg_n_0_[1] ;
  wire \port_sel_q_reg_n_0_[2] ;
  wire \port_sel_q_reg_n_0_[3] ;
  wire rst_n_IBUF;
  wire [6:0]\slim_dout_sel[0]_OBUF ;
  wire [6:0]\slim_dout_sel[1]_OBUF ;
  wire [6:0]\slim_dout_sel[2]_OBUF ;
  wire [6:0]\slim_dout_sel[3]_OBUF ;
  wire [3:0]slim_en_sel_IBUF;
  wire [3:0]slim_port_sel_IBUF;

  reuse_weight_bank_rom_0 \WBUF_BANK[0].g_bank0.u_bank 
       (.D({\bank_sel_q_reg[2][2]_0 ,\bank_sel_q_reg[2][1]_0 ,\bank_sel_q_reg[2][0]_0 }),
        .DOUTADOUT(\doutA_bank[0]__0 ),
        .DOUTBDOUT(\doutB_bank[0]__0 ),
        .Q({\en_sel_q_reg_n_0_[3] ,\en_sel_q_reg_n_0_[2] ,\en_sel_q_reg_n_0_[1] ,\en_sel_q_reg_n_0_[0] }),
        .clk_IBUF_BUFG(clk_IBUF_BUFG),
        .dout_a_reg_0(dout_a_reg),
        .dout_a_reg_1(dout_a_reg_0),
        .dout_a_reg_10(dout_a_reg_9),
        .dout_a_reg_11(dout_a_reg_10),
        .dout_a_reg_12({\bank_sel_q_reg[1][2]_0 ,\bank_sel_q_reg[1][1]_0 ,\bank_sel_q_reg[1][0]_0 }),
        .dout_a_reg_13({\bank_sel_q_reg[3][2]_0 ,\bank_sel_q_reg[3][1]_0 ,\bank_sel_q_reg[3][0]_0 }),
        .dout_a_reg_14({\bank_sel_q_reg[0][2]_0 ,\bank_sel_q_reg[0][1]_0 ,\bank_sel_q_reg[0][0]_0 }),
        .dout_a_reg_2(dout_a_reg_1),
        .dout_a_reg_3(dout_a_reg_2),
        .dout_a_reg_4(dout_a_reg_3),
        .dout_a_reg_5(dout_a_reg_4),
        .dout_a_reg_6(dout_a_reg_5),
        .dout_a_reg_7(dout_a_reg_6),
        .dout_a_reg_8(dout_a_reg_7),
        .dout_a_reg_9(dout_a_reg_8),
        .\slim_dout_sel[0][29] (\WBUF_BANK[5].g_bank5.u_bank_n_11 ),
        .\slim_dout_sel[0][29]_0 (\bank_sel_q_reg[0]_3 ),
        .\slim_dout_sel[0][30]_INST_0_i_1_0 (\doutB_bank[4]__0 [30]),
        .\slim_dout_sel[0][30]_INST_0_i_1_1 (\doutB_bank[5]__0 [28]),
        .\slim_dout_sel[0][30]_INST_0_i_1_2 (\doutA_bank[4]__0 [30]),
        .\slim_dout_sel[0][30]_INST_0_i_1_3 (\doutA_bank[5]__0 [28]),
        .\slim_dout_sel[0][31]_INST_0_i_1_0 (\doutB_bank[1]__0 ),
        .\slim_dout_sel[0][31]_INST_0_i_1_1 ({\doutB_bank[2]__0 [3],\doutB_bank[2]__0 [29]}),
        .\slim_dout_sel[0][31]_INST_0_i_1_2 ({\doutB_bank[3]__0 [3],\doutB_bank[3]__0 [28]}),
        .\slim_dout_sel[0][31]_INST_0_i_1_3 (\doutA_bank[1]__0 ),
        .\slim_dout_sel[0][31]_INST_0_i_1_4 ({\doutA_bank[2]__0 [3],\doutA_bank[2]__0 [29]}),
        .\slim_dout_sel[0][31]_INST_0_i_1_5 ({\doutA_bank[3]__0 [3],\doutA_bank[3]__0 [28]}),
        .\slim_dout_sel[0]_OBUF ({\slim_dout_sel[0]_OBUF [6:5],\slim_dout_sel[0]_OBUF [3]}),
        .\slim_dout_sel[1][29] (\WBUF_BANK[5].g_bank5.u_bank_n_10 ),
        .\slim_dout_sel[1][29]_0 (\bank_sel_q_reg[1]_2 ),
        .\slim_dout_sel[1]_OBUF ({\slim_dout_sel[1]_OBUF [6:5],\slim_dout_sel[1]_OBUF [3]}),
        .\slim_dout_sel[2][29] (\WBUF_BANK[5].g_bank5.u_bank_n_9 ),
        .\slim_dout_sel[2][29]_0 (\bank_sel_q_reg[2]_1 ),
        .\slim_dout_sel[2]_OBUF ({\slim_dout_sel[2]_OBUF [6:5],\slim_dout_sel[2]_OBUF [3]}),
        .\slim_dout_sel[3][29] (\WBUF_BANK[5].g_bank5.u_bank_n_8 ),
        .\slim_dout_sel[3][29]_0 (\bank_sel_q_reg[3]_0 ),
        .\slim_dout_sel[3][29]_1 ({\port_sel_q_reg_n_0_[3] ,\port_sel_q_reg_n_0_[2] ,\port_sel_q_reg_n_0_[1] ,\port_sel_q_reg_n_0_[0] }),
        .\slim_dout_sel[3]_OBUF ({\slim_dout_sel[3]_OBUF [6:5],\slim_dout_sel[3]_OBUF [3]}),
        .slim_en_sel_IBUF(slim_en_sel_IBUF),
        .slim_port_sel_IBUF(slim_port_sel_IBUF));
  reuse_weight_bank_rom__parameterized0 \WBUF_BANK[1].g_bank1.u_bank 
       (.D({\bank_sel_q_reg[2][2]_0 ,\bank_sel_q_reg[2][1]_0 ,\bank_sel_q_reg[2][0]_0 }),
        .DOUTADOUT(\doutA_bank[4]__0 [3:0]),
        .DOUTBDOUT(\doutB_bank[4]__0 [3:0]),
        .Q({\en_sel_q_reg_n_0_[3] ,\en_sel_q_reg_n_0_[2] ,\en_sel_q_reg_n_0_[1] ,\en_sel_q_reg_n_0_[0] }),
        .clk_IBUF_BUFG(clk_IBUF_BUFG),
        .dout_a_reg_0(\doutA_bank[1]__0 ),
        .dout_a_reg_1(\doutB_bank[1]__0 ),
        .dout_a_reg_10(dout_a_reg_7),
        .dout_a_reg_11(dout_a_reg_8),
        .dout_a_reg_12(dout_a_reg_9),
        .dout_a_reg_13(dout_a_reg_10),
        .dout_a_reg_14({\bank_sel_q_reg[1][2]_0 ,\bank_sel_q_reg[1][1]_0 ,\bank_sel_q_reg[1][0]_0 }),
        .dout_a_reg_15({\bank_sel_q_reg[3][2]_0 ,\bank_sel_q_reg[3][1]_0 ,\bank_sel_q_reg[3][0]_0 }),
        .dout_a_reg_16({\bank_sel_q_reg[0][2]_0 ,\bank_sel_q_reg[0][1]_0 ,\bank_sel_q_reg[0][0]_0 }),
        .dout_a_reg_2(dout_a_reg),
        .dout_a_reg_3(dout_a_reg_0),
        .dout_a_reg_4(dout_a_reg_1),
        .dout_a_reg_5(dout_a_reg_2),
        .dout_a_reg_6(dout_a_reg_3),
        .dout_a_reg_7(dout_a_reg_4),
        .dout_a_reg_8(dout_a_reg_5),
        .dout_a_reg_9(dout_a_reg_6),
        .\slim_dout_sel[0][28]_INST_0_i_1_0 ({\doutB_bank[5]__0 [28],\doutB_bank[5]__0 [2:0]}),
        .\slim_dout_sel[0][28]_INST_0_i_1_1 ({\doutA_bank[5]__0 [28],\doutA_bank[5]__0 [2:0]}),
        .\slim_dout_sel[0][28]_INST_0_i_1_2 (\bank_sel_q_reg[0]_3 ),
        .\slim_dout_sel[0][28]_INST_0_i_2_0 ({\doutB_bank[3]__0 [28],\doutB_bank[3]__0 [2:0]}),
        .\slim_dout_sel[0][28]_INST_0_i_2_1 (\doutB_bank[0]__0 ),
        .\slim_dout_sel[0][28]_INST_0_i_2_2 (\doutB_bank[2]__0 [3:0]),
        .\slim_dout_sel[0][28]_INST_0_i_3_0 ({\doutA_bank[3]__0 [28],\doutA_bank[3]__0 [2:0]}),
        .\slim_dout_sel[0][28]_INST_0_i_3_1 (\doutA_bank[0]__0 ),
        .\slim_dout_sel[0][28]_INST_0_i_3_2 (\doutA_bank[2]__0 [3:0]),
        .\slim_dout_sel[0]_OBUF ({\slim_dout_sel[0]_OBUF [4],\slim_dout_sel[0]_OBUF [2:0]}),
        .\slim_dout_sel[1][28]_INST_0_i_1_0 (\bank_sel_q_reg[1]_2 ),
        .\slim_dout_sel[1]_OBUF ({\slim_dout_sel[1]_OBUF [4],\slim_dout_sel[1]_OBUF [2:0]}),
        .\slim_dout_sel[2][28]_INST_0_i_1_0 (\bank_sel_q_reg[2]_1 ),
        .\slim_dout_sel[2]_OBUF ({\slim_dout_sel[2]_OBUF [4],\slim_dout_sel[2]_OBUF [2:0]}),
        .\slim_dout_sel[3][0] ({\port_sel_q_reg_n_0_[3] ,\port_sel_q_reg_n_0_[2] ,\port_sel_q_reg_n_0_[1] ,\port_sel_q_reg_n_0_[0] }),
        .\slim_dout_sel[3][28]_INST_0_i_1_0 (\bank_sel_q_reg[3]_0 ),
        .\slim_dout_sel[3]_OBUF ({\slim_dout_sel[3]_OBUF [4],\slim_dout_sel[3]_OBUF [2:0]}),
        .slim_en_sel_IBUF(slim_en_sel_IBUF),
        .slim_port_sel_IBUF(slim_port_sel_IBUF));
  reuse_weight_bank_rom__parameterized1 \WBUF_BANK[2].g_bank2.u_bank 
       (.D({\bank_sel_q_reg[2][2]_0 ,\bank_sel_q_reg[2][1]_0 ,\bank_sel_q_reg[2][0]_0 }),
        .DOUTADOUT({\doutA_bank[2]__0 [3],\doutA_bank[2]__0 [29],\doutA_bank[2]__0 [2:0]}),
        .DOUTBDOUT({\doutB_bank[2]__0 [3],\doutB_bank[2]__0 [29],\doutB_bank[2]__0 [2:0]}),
        .clk_IBUF_BUFG(clk_IBUF_BUFG),
        .dout_a_reg_0(dout_a_reg),
        .dout_a_reg_1(dout_a_reg_0),
        .dout_a_reg_10(dout_a_reg_9),
        .dout_a_reg_11(dout_a_reg_10),
        .dout_a_reg_12({\bank_sel_q_reg[1][2]_0 ,\bank_sel_q_reg[1][1]_0 ,\bank_sel_q_reg[1][0]_0 }),
        .dout_a_reg_13({\bank_sel_q_reg[3][2]_0 ,\bank_sel_q_reg[3][1]_0 ,\bank_sel_q_reg[3][0]_0 }),
        .dout_a_reg_14({\bank_sel_q_reg[0][2]_0 ,\bank_sel_q_reg[0][1]_0 ,\bank_sel_q_reg[0][0]_0 }),
        .dout_a_reg_2(dout_a_reg_1),
        .dout_a_reg_3(dout_a_reg_2),
        .dout_a_reg_4(dout_a_reg_3),
        .dout_a_reg_5(dout_a_reg_4),
        .dout_a_reg_6(dout_a_reg_5),
        .dout_a_reg_7(dout_a_reg_6),
        .dout_a_reg_8(dout_a_reg_7),
        .dout_a_reg_9(dout_a_reg_8),
        .slim_en_sel_IBUF(slim_en_sel_IBUF),
        .slim_port_sel_IBUF(slim_port_sel_IBUF));
  reuse_weight_bank_rom__parameterized2 \WBUF_BANK[3].g_bank3.u_bank 
       (.D({\bank_sel_q_reg[2][2]_0 ,\bank_sel_q_reg[2][1]_0 ,\bank_sel_q_reg[2][0]_0 }),
        .DOUTADOUT({\doutA_bank[3]__0 [3],\doutA_bank[3]__0 [28],\doutA_bank[3]__0 [2:0]}),
        .DOUTBDOUT({\doutB_bank[3]__0 [3],\doutB_bank[3]__0 [28],\doutB_bank[3]__0 [2:0]}),
        .clk_IBUF_BUFG(clk_IBUF_BUFG),
        .dout_a_reg_0(dout_a_reg),
        .dout_a_reg_1(dout_a_reg_0),
        .dout_a_reg_10(dout_a_reg_9),
        .dout_a_reg_11(dout_a_reg_10),
        .dout_a_reg_12({\bank_sel_q_reg[1][2]_0 ,\bank_sel_q_reg[1][1]_0 ,\bank_sel_q_reg[1][0]_0 }),
        .dout_a_reg_13({\bank_sel_q_reg[3][2]_0 ,\bank_sel_q_reg[3][1]_0 ,\bank_sel_q_reg[3][0]_0 }),
        .dout_a_reg_14({\bank_sel_q_reg[0][2]_0 ,\bank_sel_q_reg[0][1]_0 ,\bank_sel_q_reg[0][0]_0 }),
        .dout_a_reg_2(dout_a_reg_1),
        .dout_a_reg_3(dout_a_reg_2),
        .dout_a_reg_4(dout_a_reg_3),
        .dout_a_reg_5(dout_a_reg_4),
        .dout_a_reg_6(dout_a_reg_5),
        .dout_a_reg_7(dout_a_reg_6),
        .dout_a_reg_8(dout_a_reg_7),
        .dout_a_reg_9(dout_a_reg_8),
        .slim_en_sel_IBUF(slim_en_sel_IBUF),
        .slim_port_sel_IBUF(slim_port_sel_IBUF));
  reuse_weight_bank_rom__parameterized3 \WBUF_BANK[4].g_bank4.u_bank 
       (.D({\bank_sel_q_reg[2][2]_0 ,\bank_sel_q_reg[2][1]_0 ,\bank_sel_q_reg[2][0]_0 }),
        .DOUTADOUT({\doutA_bank[4]__0 [3],\doutA_bank[4]__0 [30],\doutA_bank[4]__0 [2:0]}),
        .DOUTBDOUT({\doutB_bank[4]__0 [3],\doutB_bank[4]__0 [30],\doutB_bank[4]__0 [2:0]}),
        .clk_IBUF_BUFG(clk_IBUF_BUFG),
        .dout_a_reg_0(dout_a_reg),
        .dout_a_reg_1(dout_a_reg_0),
        .dout_a_reg_10(dout_a_reg_9),
        .dout_a_reg_11(dout_a_reg_10),
        .dout_a_reg_12({\bank_sel_q_reg[0][2]_0 ,\bank_sel_q_reg[0][1]_0 ,\bank_sel_q_reg[0][0]_0 }),
        .dout_a_reg_13({\bank_sel_q_reg[1][2]_0 ,\bank_sel_q_reg[1][1]_0 ,\bank_sel_q_reg[1][0]_0 }),
        .dout_a_reg_14({\bank_sel_q_reg[3][2]_0 ,\bank_sel_q_reg[3][1]_0 ,\bank_sel_q_reg[3][0]_0 }),
        .dout_a_reg_2(dout_a_reg_1),
        .dout_a_reg_3(dout_a_reg_2),
        .dout_a_reg_4(dout_a_reg_3),
        .dout_a_reg_5(dout_a_reg_4),
        .dout_a_reg_6(dout_a_reg_5),
        .dout_a_reg_7(dout_a_reg_6),
        .dout_a_reg_8(dout_a_reg_7),
        .dout_a_reg_9(dout_a_reg_8),
        .slim_en_sel_IBUF(slim_en_sel_IBUF),
        .slim_port_sel_IBUF(slim_port_sel_IBUF));
  reuse_weight_bank_rom__parameterized4 \WBUF_BANK[5].g_bank5.u_bank 
       (.D({\bank_sel_q_reg[2][2]_0 ,\bank_sel_q_reg[2][1]_0 ,\bank_sel_q_reg[2][0]_0 }),
        .DOUTADOUT(\doutA_bank[4]__0 [3]),
        .DOUTBDOUT(\doutB_bank[4]__0 [3]),
        .Q({\port_sel_q_reg_n_0_[3] ,\port_sel_q_reg_n_0_[2] ,\port_sel_q_reg_n_0_[1] ,\port_sel_q_reg_n_0_[0] }),
        .clk_IBUF_BUFG(clk_IBUF_BUFG),
        .dout_a_reg_0({\doutA_bank[5]__0 [28],\doutA_bank[5]__0 [2:0]}),
        .dout_a_reg_1({\doutB_bank[5]__0 [28],\doutB_bank[5]__0 [2:0]}),
        .dout_a_reg_10(dout_a_reg_2),
        .dout_a_reg_11(dout_a_reg_3),
        .dout_a_reg_12(dout_a_reg_4),
        .dout_a_reg_13(dout_a_reg_5),
        .dout_a_reg_14(dout_a_reg_6),
        .dout_a_reg_15(dout_a_reg_7),
        .dout_a_reg_16(dout_a_reg_8),
        .dout_a_reg_17(dout_a_reg_9),
        .dout_a_reg_18(dout_a_reg_10),
        .dout_a_reg_19({\bank_sel_q_reg[1][2]_0 ,\bank_sel_q_reg[1][1]_0 ,\bank_sel_q_reg[1][0]_0 }),
        .dout_a_reg_2(\WBUF_BANK[5].g_bank5.u_bank_n_8 ),
        .dout_a_reg_20({\bank_sel_q_reg[0][2]_0 ,\bank_sel_q_reg[0][1]_0 ,\bank_sel_q_reg[0][0]_0 }),
        .dout_a_reg_3(\WBUF_BANK[5].g_bank5.u_bank_n_9 ),
        .dout_a_reg_4(\WBUF_BANK[5].g_bank5.u_bank_n_10 ),
        .dout_a_reg_5(\WBUF_BANK[5].g_bank5.u_bank_n_11 ),
        .dout_a_reg_6({\bank_sel_q_reg[3][2]_0 ,\bank_sel_q_reg[3][1]_0 ,\bank_sel_q_reg[3][0]_0 }),
        .dout_a_reg_7(dout_a_reg),
        .dout_a_reg_8(dout_a_reg_0),
        .dout_a_reg_9(dout_a_reg_1),
        .\slim_dout_sel[0][31]_INST_0_i_1 (\bank_sel_q_reg[0]_3 [0]),
        .\slim_dout_sel[1][31]_INST_0_i_1 (\bank_sel_q_reg[1]_2 [0]),
        .\slim_dout_sel[2][31]_INST_0_i_1 (\bank_sel_q_reg[2]_1 [0]),
        .\slim_dout_sel[3][31]_INST_0_i_1 (\bank_sel_q_reg[3]_0 [0]),
        .slim_en_sel_IBUF(slim_en_sel_IBUF),
        .slim_port_sel_IBUF(slim_port_sel_IBUF));
  FDRE \bank_sel_q_reg[0][0] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(\bank_sel_q_reg[0][0]_0 ),
        .Q(\bank_sel_q_reg[0]_3 [0]),
        .R(\port_sel_q[3]_i_1_n_0 ));
  FDRE \bank_sel_q_reg[0][1] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(\bank_sel_q_reg[0][1]_0 ),
        .Q(\bank_sel_q_reg[0]_3 [1]),
        .R(\port_sel_q[3]_i_1_n_0 ));
  FDRE \bank_sel_q_reg[0][2] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(\bank_sel_q_reg[0][2]_0 ),
        .Q(\bank_sel_q_reg[0]_3 [2]),
        .R(\port_sel_q[3]_i_1_n_0 ));
  FDRE \bank_sel_q_reg[1][0] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(\bank_sel_q_reg[1][0]_0 ),
        .Q(\bank_sel_q_reg[1]_2 [0]),
        .R(\port_sel_q[3]_i_1_n_0 ));
  FDRE \bank_sel_q_reg[1][1] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(\bank_sel_q_reg[1][1]_0 ),
        .Q(\bank_sel_q_reg[1]_2 [1]),
        .R(\port_sel_q[3]_i_1_n_0 ));
  FDRE \bank_sel_q_reg[1][2] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(\bank_sel_q_reg[1][2]_0 ),
        .Q(\bank_sel_q_reg[1]_2 [2]),
        .R(\port_sel_q[3]_i_1_n_0 ));
  FDRE \bank_sel_q_reg[2][0] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(\bank_sel_q_reg[2][0]_0 ),
        .Q(\bank_sel_q_reg[2]_1 [0]),
        .R(\port_sel_q[3]_i_1_n_0 ));
  FDRE \bank_sel_q_reg[2][1] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(\bank_sel_q_reg[2][1]_0 ),
        .Q(\bank_sel_q_reg[2]_1 [1]),
        .R(\port_sel_q[3]_i_1_n_0 ));
  FDRE \bank_sel_q_reg[2][2] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(\bank_sel_q_reg[2][2]_0 ),
        .Q(\bank_sel_q_reg[2]_1 [2]),
        .R(\port_sel_q[3]_i_1_n_0 ));
  FDRE \bank_sel_q_reg[3][0] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(\bank_sel_q_reg[3][0]_0 ),
        .Q(\bank_sel_q_reg[3]_0 [0]),
        .R(\port_sel_q[3]_i_1_n_0 ));
  FDRE \bank_sel_q_reg[3][1] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(\bank_sel_q_reg[3][1]_0 ),
        .Q(\bank_sel_q_reg[3]_0 [1]),
        .R(\port_sel_q[3]_i_1_n_0 ));
  FDRE \bank_sel_q_reg[3][2] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(\bank_sel_q_reg[3][2]_0 ),
        .Q(\bank_sel_q_reg[3]_0 [2]),
        .R(\port_sel_q[3]_i_1_n_0 ));
  FDRE \en_sel_q_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(slim_en_sel_IBUF[0]),
        .Q(\en_sel_q_reg_n_0_[0] ),
        .R(\port_sel_q[3]_i_1_n_0 ));
  FDRE \en_sel_q_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(slim_en_sel_IBUF[1]),
        .Q(\en_sel_q_reg_n_0_[1] ),
        .R(\port_sel_q[3]_i_1_n_0 ));
  FDRE \en_sel_q_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(slim_en_sel_IBUF[2]),
        .Q(\en_sel_q_reg_n_0_[2] ),
        .R(\port_sel_q[3]_i_1_n_0 ));
  FDRE \en_sel_q_reg[3] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(slim_en_sel_IBUF[3]),
        .Q(\en_sel_q_reg_n_0_[3] ),
        .R(\port_sel_q[3]_i_1_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \port_sel_q[3]_i_1 
       (.I0(rst_n_IBUF),
        .O(\port_sel_q[3]_i_1_n_0 ));
  FDRE \port_sel_q_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(slim_port_sel_IBUF[0]),
        .Q(\port_sel_q_reg_n_0_[0] ),
        .R(\port_sel_q[3]_i_1_n_0 ));
  FDRE \port_sel_q_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(slim_port_sel_IBUF[1]),
        .Q(\port_sel_q_reg_n_0_[1] ),
        .R(\port_sel_q[3]_i_1_n_0 ));
  FDRE \port_sel_q_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(slim_port_sel_IBUF[2]),
        .Q(\port_sel_q_reg_n_0_[2] ),
        .R(\port_sel_q[3]_i_1_n_0 ));
  FDRE \port_sel_q_reg[3] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(slim_port_sel_IBUF[3]),
        .Q(\port_sel_q_reg_n_0_[3] ),
        .R(\port_sel_q[3]_i_1_n_0 ));
endmodule
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
