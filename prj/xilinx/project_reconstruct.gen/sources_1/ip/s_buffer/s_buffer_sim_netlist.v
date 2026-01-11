// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Sun Jan  4 07:49:59 2026
// Host        : DESKTOP-JL9PPGK running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top s_buffer -prefix
//               s_buffer_ s_buffer_sim_netlist.v
// Design      : s_buffer
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "s_buffer,blk_mem_gen_v8_4_8,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module s_buffer
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
  wire clkb;
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
  (* C_COMMON_CLK = "0" *) 
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
  s_buffer_blk_mem_gen_v8_4_8 U0
       (.addra(addra),
        .addrb(addrb),
        .clka(clka),
        .clkb(clkb),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 52016)
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
