// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Wed Dec 24 15:57:02 2025
// Host        : DESKTOP-JL9PPGK running 64-bit major release  (build 9200)
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
LBxSWK8suc1NpTk3
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
