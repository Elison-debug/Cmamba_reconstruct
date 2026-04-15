// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Tue Apr 14 02:32:05 2026
// Host        : 13600kf running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ s_buffer_sim_netlist.v
// Design      : s_buffer
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "s_buffer,blk_mem_gen_v8_4_8,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clka,
    ena,
    wea,
    addra,
    dina,
    douta,
    clkb,
    enb,
    web,
    addrb,
    dinb,
    doutb);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [5:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [63:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [63:0]douta;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB WE" *) input [0:0]web;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [5:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DIN" *) input [63:0]dinb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [63:0]doutb;

  wire [5:0]addra;
  wire [5:0]addrb;
  wire clka;
  wire [63:0]dina;
  wire [63:0]dinb;
  wire [63:0]douta;
  wire [63:0]doutb;
  wire ena;
  wire enb;
  wire [0:0]wea;
  wire [0:0]web;
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
  (* C_COMMON_CLK = "1" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "2" *) 
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     8.930215 mW" *) 
  (* C_FAMILY = "zynquplus" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "1" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "1" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "1" *) 
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
  (* C_INIT_FILE = "s_buffer.mem" *) 
  (* C_INIT_FILE_NAME = "s_buffer.mif" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "1" *) 
  (* C_MEM_TYPE = "2" *) 
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
  (* C_WRITE_MODE_A = "READ_FIRST" *) 
  (* C_WRITE_MODE_B = "READ_FIRST" *) 
  (* C_WRITE_WIDTH_A = "64" *) 
  (* C_WRITE_WIDTH_B = "64" *) 
  (* C_XDEVICEFAMILY = "zynquplus" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_8 U0
       (.addra(addra),
        .addrb(addrb),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb(dinb),
        .douta(douta),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(enb),
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
        .wea(wea),
        .web(web));
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 52096)
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
