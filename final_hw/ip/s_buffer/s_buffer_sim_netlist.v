// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Thu Apr 16 06:14:01 2026
// Host        : 13600kf running 64-bit major release  (build 9200)
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
  s_buffer_blk_mem_gen_v8_4_8 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 51600)
`pragma protect data_block
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
zWw2t4xmlKQ0s6zZGftK
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
