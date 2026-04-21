// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Tue Apr 21 03:39:00 2026
// Host        : 13600kf running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top bias_ROM -prefix
//               bias_ROM_ bias_ROM_sim_netlist.v
// Design      : bias_ROM
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bias_ROM,blk_mem_gen_v8_4_8,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module bias_ROM
   (clka,
    ena,
    addra,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [5:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [63:0]douta;

  wire [5:0]addra;
  wire clka;
  wire [63:0]douta;
  wire ena;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [63:0]NLW_U0_doutb_UNCONNECTED;
  wire [5:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [5:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [63:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "6" *) 
  (* C_ADDRB_WIDTH = "6" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "1" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     5.831765 mW" *) 
  (* C_FAMILY = "zynquplus" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "1" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "bias_ROM.mem" *) 
  (* C_INIT_FILE_NAME = "bias_ROM.mif" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "1" *) 
  (* C_MEM_TYPE = "3" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "64" *) 
  (* C_READ_DEPTH_B = "64" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "64" *) 
  (* C_READ_WIDTH_B = "64" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "1" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "64" *) 
  (* C_WRITE_DEPTH_B = "64" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "64" *) 
  (* C_WRITE_WIDTH_B = "64" *) 
  (* C_XDEVICEFAMILY = "zynquplus" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  bias_ROM_blk_mem_gen_v8_4_8 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[63:0]),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(1'b0),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[5:0]),
        .regcea(1'b1),
        .regceb(1'b1),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[5:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[63:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(1'b0),
        .web(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2024.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
RSqbsRZSIb+QlYJMfFv1T7uHQ7PiCEXQkl687MHGm2LgPB15GIYcPmqKUSXgtkLsIFes91PTAyyB
9H9cyY4ZUxedcRg/9ZOB5pm3zPqAbcvGPmg1ivMhr/MlS19t5lYKM2tQo+0Yd+arJXlVZu2BMnvn
+I3G9t9tJuWUIWKjI+I=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
VRSQ05ZaB6bIhFIQ823mTvlJaG9+5iW5C3+KxGjq0sq9ziCshKOLpOGPDMmOWDqA4uBaxC5IKISr
w8+A8mqbYjXo5m1g8sGjNaETS0HKJsK+l5Y++tN4IEUs+DwxgrPR/+LWtChuOzVkfC7BG3LVUEMj
zM3GAyGcXGJ3sdBItZAfsevyiy7kr4Fw+nk2hWytGteu1NZk3VzPE7KQHLkOlHBPXf6P0j8LpKcr
2oNDgQ/WaEmg6OOvFeJuaWDaee8Sn6wKP/caMyoGdSeczsPtRrJeoSRlbNHlxhCv7zg+Cn2AgwrR
PTqGsMrkhv9U0sq+waS0CmwChsk4WB7RspGYUg==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
tNziOjCznlvIl4dadmB9r23Duf+HQHWOuHmupEU3PJxrazHVtZdNKspG9sRXhF9mjbpnSiKYCdFK
Jr9W/dxUid36faFIPKQazVTuOiE0hkzVQAGpYxXjT/ITB/9EFBvgvP5L3EAhHv32x6MA1vkFSI7x
HrZ09YNFEF6T7DPTZE4=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
QCYfxgkUHlX1cre1q9aS3sVDIOX36YBK4ZwJXAVUwA6f1OQ77XibjpWJHt5FK9F0PcYp/j21pqzO
BRdkDcFLVAjxER4J5t5iMVhoeMk+3fpiKfYrm4WFl1ygsJsfFJP0jqO1OkjC8iFBtm3n6b7CTl1o
cjBbcBp8UgW6E8rf5inXA0dRqybnyxKJSnMFYLinvpVU6QEc4OKO7mi/i/s9p/efiP+CdQf0yDRU
Fw7o7x0D7tjBv943g5L+4wGZ2JYU+ISqn4Ajxy/bWTTJDe6T/15evhngS61MC8Xjamzc4YLZBP8o
ShfSLoeZeO+Hk5n3xzJRghM0DQ6Sj7NqXFY68w==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Uy8FDDy3dZQGAnMQV0HBesEs+/oZdaq35Kj1PGhy9J/+EBZm0nhhQgYtku8tWABW2jKAC1GtNTvo
uReQyr1hteMxTbD5OIuqv86eb1hXZVENlZ7ichG8auUjkeHAkaSYNbHOuDLIhSqHEL67XbcZ9zPG
1JOY3+VONSww0KYPcQbGSo/2DaC5C0Y+mZODRfJ4+b0WXjce6UaJetilBc3VtqqmodIM2d3HDawF
R0xVJfHj86rXmUkY+SNUw60zsV6raCY6G3k/rXpei1d6zn8tCThkKG5fwiWY8zA7kRdTFIlVKP9h
fb6kfzRBRT/BgVQ8d4RgEcEVV8m3u/Mf4KIlTw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2023_11", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Pk1GeRlkUK9lt6DVXYVdtOABlzDEWQDcBsP/p+Wo5HaglDLG5b8gk08xTP3IcJ1RKcfuARPMGO2s
/VqFbnVADV90T1rhjIuWMcBnzYQK/ALUvwv11Uju9Gn0fvPIz52l3QBnpjHI1nlsFB7WeqkzVfHZ
tg9gO9bPHjHLjVd9BzH6McrEWY5RkZ0UBy0Fmh/SownJX1b0YGE7LdwKydEMEpyvb28bwTOwfEv/
4RtsfYtEvTjo6e1ZBm66D9IQmKUu32wzTfn5bFZHdyjZg6+HcTzvHMtQX2+AggXfP6FsO2/83qkb
0bfj226fnLhr32dJxtsaJS5OR63GYtzDJ05ITA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
LCfWqKmUoUSVOTKNAl5p8n1hfz7SMU2kDOUMBjsDncgSFqiu2zUy1I6GSDrVnF/2umJG5/mWcpvi
rQaFJOlrJ8DNctSuavdlopRAwTMsVi6dAlNGrAawSiDIxtI3tN3MDVdMiH5H+pJMqMt59yXneyCf
2RRSRz2sUQK/aj0lXlqKjVJzVbk8HaBQ8akBJF4iWSMK4foIzJ6iO1EupYovuW6uEiO7jQRWezlW
pbbDenOHHWbfinuX5cbkjpTKHGsEKct65q+ZXJp60m3sconSK3Y2eLQxusuJ1FHDJ4GGKO8mEzCv
3cfGdXX3pVL81OfGO/JD1aMs9H98CO5ssbHqlw==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
A4S1e3DHcTeWzaDVuWDRb3Yf1BjiEsR1RtAeL0BJ7J/oPWMNj96MeGsUiHtZoiYqteTZxqax2cyZ
PV0cMLoBK4Ya8CyM+BTnkFA2ablsGt5Es4TgG/nFS9VEhmeKxu8boAsqW5697aiqOATJf/LucQh5
GOnPXHAuPrDj0A/fu8N2QduqGyysWUSc1KsoJ0/0noJYvLJ2yOhFi4uIUYQfG5LOuOrca5P43pqA
iwUKW/RrFXal2acJdFeXIKffZpKanSV97urdzKyBvf9EPV/M8g9uPFJJ1z6aS+FbknhVPs0pt6eD
+J/qib4gVp/HGnRo4YlxauUMv6Yv9wxiaObY6ttDfYf5p3uzWZMlf3i7YOzZwcd4aS/6+vkD28LG
L9piBIpLx2dvQy74RdvCVdvaP1LC6RMju9RfuXJhuX4ZAmDxRi0zQyRda838ikzwYeOCSKLIvRPb
nuJ8Zx2ot8EFqSeGaaRFaEMU6Zf5SptCUuVMHvSkinBewcwrLB5uiJTJ

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
gj+uMxV+tK4Di7pgSOE82FOBeWmUB1A7OKFOSMUW3qrmQ4/YhryfHMlWPxfAq8avQL7tnBTnRFEg
czbErdIcNzYjrM7Qq00QC/mTqmeQX4/apbqGvN+rwK4RR5oj22wfTib/UQNEQX6fbpi6PtmAeUR9
eShsfq+YWcf7z2Zw4Q+o4+E6m4/3CzU68vglNpzNsJ8S9/8XpdIrvAA/WRAX6OEOC4wlNIKDZsq/
+zMbFgSzN1rP844I/CDmxYM0NIzBWWhYBkPfJyQyigmUoXb84lDip0/Dmnq4EHvu7D/tZNnDl5st
JpftRfEpT6S8e/5MBeKUuhbfg6etHo/oFZvPKQ==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
aWTy3xv6SqKsldtLS2gY4KrTS8U+KtFNRHS314f6EYZy1MHE9t7oICJ8eNB8up8A+odoE23N3fJb
1alhaadeRWU2GjlIiK1LjZ5PQw+jb1u1GWtRiY+TcTlD75XUlqwykVBrCDfm565DmgZjZle9T3/t
WEfLo+m/8GfBe8trVnoftsk/XI00BMFXRzw8doPGDhNECS1NUrLebryb9iO5Hf4A/40dtslTARsR
nicN0KoIIyiQ+QzliqyXU/8VjS45inON8R0Kv9Qx46EXUp7bds5uQ7QycRhpLG0IPnMIweudU67w
eQmpHJzvZKBCZks/R0OafZx44H6Jib2+QazBCw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
UGdPiChIPj1lSozqzCQx17Bi+8FWSuMUMzXUkDLH5zcP1t8tZLzh4CU4WAR8lmJxn8gH763fLp5c
RYU6zA0yxHzl2ksc5YRU1XEfQQT9ha8fQnz+18wVKcsa5UIOfMbGDwnS9yfX59ntG8CB0uF8bJKE
y1CS6U/1Stfs1w2mF94iDxI2n2GJlb1UPtWpmxMBI88hY0GktTPXP2Y7JKl8zRl/Lq0wIF8pHwXk
B4nOgKm6hfzPj0xZ6E/TuER/JE3fy8RSm24IlL/CUgpReEslEOYjQ4EKKZRG9/fxg26utQWW9p+G
fWVU53qrFGzBhKQ96Paj1ROkv6hDHyUb6n7uSw==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 30880)
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
