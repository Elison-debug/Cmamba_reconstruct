// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Thu Apr 16 01:11:01 2026
// Host        : 13600kf running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               e:/course/smamba_test/HW_reconstruct/project_mamba_all1/project_mamba_all1.gen/sources_1/ip/bias_ROM/bias_ROM_sim_netlist.v
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
