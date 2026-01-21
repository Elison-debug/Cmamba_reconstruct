// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Wed Dec 24 15:57:03 2025
// Host        : DESKTOP-JL9PPGK running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/Mamba/project_reconstruct/project_reconstruct.gen/sources_1/ip/bias_ROM/bias_ROM_sim_netlist.v
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
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
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
  (* C_USE_DEFAULT_DATA = "0" *) 
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 31168)
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
