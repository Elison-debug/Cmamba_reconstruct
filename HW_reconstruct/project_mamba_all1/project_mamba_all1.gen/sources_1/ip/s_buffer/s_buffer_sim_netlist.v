// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Tue Apr 14 02:32:06 2026
// Host        : 13600kf running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               e:/course/smamba/HW_reconstruct/project_mamba_all1/project_mamba_all1.gen/sources_1/ip/s_buffer/s_buffer_sim_netlist.v
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 51904)
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
