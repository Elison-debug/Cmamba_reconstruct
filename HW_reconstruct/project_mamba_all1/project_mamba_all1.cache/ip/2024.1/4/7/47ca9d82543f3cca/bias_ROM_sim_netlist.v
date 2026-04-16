// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Thu Apr 16 01:11:00 2026
// Host        : 13600kf running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ bias_ROM_sim_netlist.v
// Design      : bias_ROM
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bias_ROM,blk_mem_gen_v8_4_8,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_8 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 31248)
`pragma protect data_block
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
bULYE9QLT375Qj6X
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
