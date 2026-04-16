// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Thu Apr 16 06:14:01 2026
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
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
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
  (* C_USE_DEFAULT_DATA = "0" *) 
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
