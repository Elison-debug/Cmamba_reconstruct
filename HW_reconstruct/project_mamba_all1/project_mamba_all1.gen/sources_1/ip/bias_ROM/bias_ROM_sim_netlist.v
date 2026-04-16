// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Thu Apr 16 06:38:21 2026
// Host        : 13600kf running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               e:/course/smamba/HW_reconstruct/project_mamba_all1/project_mamba_all1.gen/sources_1/ip/bias_ROM/bias_ROM_sim_netlist.v
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
