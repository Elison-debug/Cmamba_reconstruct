// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Thu Apr 16 06:38:20 2026
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
vt8hz9Pl731E74m6
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
