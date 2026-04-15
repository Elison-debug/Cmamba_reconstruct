// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Tue Apr 14 02:31:27 2026
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
bj+BVNThkvmCSVbO
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
