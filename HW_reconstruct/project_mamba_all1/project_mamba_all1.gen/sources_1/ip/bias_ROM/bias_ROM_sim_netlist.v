// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Tue Apr 14 02:31:27 2026
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
