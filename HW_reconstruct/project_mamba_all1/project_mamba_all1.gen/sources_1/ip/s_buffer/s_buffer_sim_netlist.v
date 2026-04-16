// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Thu Apr 16 06:14:01 2026
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 51872)
`pragma protect data_block
em1J3Lgpa+Ip2Aeqz/ZlGAkke2FZiuK0Gy5+GVK9HeEOHhFE9af6q2Y8cAiTjiAlB3ossUg4Nzeu
y31cvSAEpjyMvH9bsKmBmFNw/Rr0/KawXcbMXT40s9t0oAD+T5Y5AJvfimL4n+P1ErBWKPBs6sjA
wmvzG+u8bU58RL9lpx5TV9FaQFGeS2plGuHegxXjE1hSuF2g4SSGGIG3wkuA+sWODx+tRmv0k8vY
CV2rSq7tkpHoKw/OH0PetF+f0CYE9hWqOUgmilCRBDBvcTJBc3LiiIqaUAWFH+pz4PJTPvCVgdER
XVTnmZyXA+kN3vXgvKXxVAwgwY5sbuniXT+nXUvA1IfpIBUAm8hz8mNxlJSsmoQc5+hAXxl2PLr/
0MYkU7mz5xwTCgcW64JUfqSp8gdQTL5xBuozZna9D6u8TGMLTi2WfDmY2ny4F/FQNuWtsePqFgBD
m6TWbpznSnll+/koLsBdHwYOIacSC0a8qeb2x/nVJLuy4mA7iqasuAeB/pT79v6dv1/edenJANX0
m9YX1BzfrCZmEq4BzUEl/V5vJxTxgxNx/T+WZY86aSfRImzSTPSuNE4JIJCBgSAuqe3rOpnjFvDC
PCgB9kLZqaFF1DoE+BiLtzZxfEpJBL2rPZzp8jRWvJa83XUgFb/LCfBL2EtJoCIb3wZfwuuY1Raf
3OICJpHvax64l+yDblz1Alvpp7YZDdUryZ+xMKQNs5ORKiWAlJW8TdmioioE2g7gipYdOsBJTUBl
CMN3pVbsM68f2kuapOJ9izzCb+OJmx+Fi1HjQXw2XSccC0kP92lc8MYUNHjk/9chocOSqq7d8BIx
kmUz96LeK3ZiNqD9kRMDp0+UfxR+zYMvurwPN9i03cVP4dKhvJkjA7OcZqHNZ55gk+DmVyWVQQg/
FuXC1rfqvZF3Mc1yTdWS7+BJ5O1XvJv4QLo3LcC8vt98if7hFuprXhrgLedkV2ei754ye3XJD9Ih
O02UnPJN+b5KerDmOugHsTkmRrdzSMx7yFeHFbDm9z8VkbCauNzUS5cPm1ZC14/6wK07dESu/2V3
dzBzrQrQoproRwQip5Yn6UYfmyXmRWuWc35UBV/KFurqoJPmMZxdI2UhU9f5oWWqbNeapIaK9Zc0
tX/8tftKCZREovpTbj1Fj/gRuSEkiz7w6qufKkAkMTFoxnN/dzVlkAlJ0lb9tVWkpbGXvn4coA2f
+tFqWKCs3V82mWBX2y4szgNJQ5GWr3BFOellNwuGAvoo9HhwRIBTM+Q5d9dDwcsbz2oU1CTf7Jbs
+/FOKTPkfg8u2JHe5MhzEEyNO1K4/d0KQIV3Qot/GylSBA/fXkEs3xSnrzhrbyXP/HBzEmJfHqxw
as3HnlBCs+1Mu53Zb5x/su6YIA+fUhEs7FjXFHdQhjGc7/bJFzXzoQ23+4f3keMUN3yBqXTI8eiK
m1D8TQsd9b9C1vBKXB3uoQ9cuLhG7n085sYdSDSv5whRvkcbJs3MElhWpNH4O16Mv8WKOHcCdcaI
AbsTs3Jrxf1wNUoEDXA0je12H0TKk+b1ZXkIQWRmP20x9ad1mGvtZLpeSS15WFheOSSbc/dPmUyG
Bigx9fSbg4qzGPh7Q1h+YXGf3aKjkgAMv6djGdOni/o7SkQ7SZiaSBcly1DOBM8ad91a9NzvkrU+
Gc1G5ya8Wp4Bslg1saOwc3JI5AdlzJ0aCFzuipHo91EDU8i3eXtbzyN/jk7aRHcj1t72/Zz+hAA9
AlV8sfUIErC347SK69YqI23JwtbsnB5R6knncMpG+p544SWcizZqxyhnOhe5Rt5jqtpVc+TBqev3
AfUpcO48Ze5WRVMpnYNkksBRtn0weRYxiLjBpx9dErO8RHv/7tjdB7IqegCWlJfxa8hev6WkxWI7
EetcVyRmAaPxzjzSCRuXkWbPXz61H1Q7Gc6wSm1EX6VpVO5rO77IzBu3FCoT1pg0BhbtGRpCpHki
g9lWF3HN2tuhU8MewNuO0Ni8TsK+LuCb+TwuCrKnWB8qV4K6Aw1gYSor32ufdC61TeOF2Va4Pzx4
0Hz9xd0QcXqkl0w9NGmpU2ZeFybBswvZOVEWPcWiOwFhQLMyLQBZrgu2zLlg7+BsVcL6yupJHXPv
XUJ/2a5j43zYi6WDEwy6WAOg5UNoF9xDCjXFeGxUc2hb/rCsDQEIGG+jl5eKYJAWm+luWwdsdKaW
HYw6+JQXlYSJjD3EjqRBikdx05kyKMPlctSftJlazYhJPrtZcNXDwwmcI3hiy3il8oEwzegHYB2h
NC602httUXvWX0755iw4QCTNGwv6NqlLuBx6sFgzz3cIp4js7IcgmYqT9cpAxNGKthbylqw3n1Xn
LYn9YBFdJGqUOyzdp9vHO4JavddfajCE4eAZFLGOrqsFVZEFf9z2/7HViKYmTus2gVvipZRpUr+L
gtaiEwDhhreqy1LGioOd6hbWb42QsMw13iU+7OP4GIhK6Qa/wVAojvZ7wRBytdiMqhVMHOueO2xb
nb1ydI5P21tZ7FrYuDqtpeRTDFtgukr4DkkNWi0WSVGT/xDFor6PUkmyZ3mXLoygPf598rELTObd
LVPLH9n/TXo522ulRXmFWMtVePAbs1FnsiMbhouBXzPScnU9/SaiQTR73/OnmSbM0JtQ0yRMaNrC
Qpq7VPSnXr8GgdI2n0UslR9K/LD2kr3kDYaHZV+f/oNDzuO+Ed6xPf7yRnzevApidYsqk4PFyniY
7709XszPpLW1XIIjyhIbDqNfryAxcEwC3075IiTkhcxw/3Eni4e4qY6GFKu2/s9W86ATg6ZqeuAz
/rnQsMA3YHPwJJH5PoGsmZagKuy05ChuVdBARxyCaWJRHXtywxJy1J+n3Sqpwno8db//WkHu1XyQ
rD0nwSdBQz3d4Q8t6tdbQYibxk4LUzcTOS3sWBju5/ighfnLqb5LbaNt+MwNlYAfJzGwbsPLU6sU
AcAAyisi2yg+s2Y+Flet9dVFYByUBXbfmPH1Ic2kwZlbE89cHZdpY1mJUrs5YTHaEOwPFLjlfonj
tpEBBbn5EnMz+g/KzaDBNO5FVp8g8RlPmp+m+GpjIz8K59NUTa71mF43L6W3ncV0TQ+Ncb2rVTTT
lWr/JnecehuwWV2gIUVFQ8LImKSNsxybTgzEuEJZbd29Bwa3G1QrE64N7l2xfW4sBPg8WNzSmw98
rn9btoeD4sZKxBd8R1nb/CpNDQoazQIXlAWBmhTJJabowRmQcm/MhKVOin4e4qtGnfacXKjgUUgx
8Qwmw5HWmbD+iYGILKcTjCOkELAZeDixuy3md/RuyXhd2hMMOPnTayls/QsZm2tmoAz9m+/jthev
j8S0idW44+ZMcCvlSZVr9znquI2jvVIn5ocC2d/0T4cznPrXGAyZnoBEQaNFgWLa92vVuhFR8hiO
qMyOUIa/oTQQOCtaWS7qqGBFIfGA1cx7S2MZIqujCbcktf+5QrDYwNKgFyxk0YPwwF/xCd2l0K1v
HgLNCUKBPrOxmKuCWRLFnJtqmxV/kTlWd2gkQG0fMyIUg2e6TuNj6umSdNOwHgig1Pt7qmKwwQnh
VUxencvvN5Y2GnBREAr5/R2kNCUKB9WaAqXqa+K4b9JjKCCFVXjZnOzZYS5Mclv0CzSsw6SqMW5H
MF/HW4qK9iG6T2qGT6c69r4Q+m5KxFaiUh7b/ozezigovXVOM8donILiZZbiXb1iPDtaaclnZMy1
Eclmc7oOqkec0dLiqjCVazMlL72qi18sjkZaWnN/m7eV4GT66mk+Vb+juylAUEwcoo4ktP/oklHY
4dtQuUy7HRHPrnOvwygrPHLJ0au6lwFjkpQcaaQWUvS5jTrIMlWCYbLGkzRKKMMFjQR+jmbHjjQN
8RErGnEmPk2T+QbXxE8Ah5j8kIGs1SookfaeAVno0TmI56GU6rK7zov3g8Ilijp1xS7fAVxIRokF
XFoFgqtD1pLSg5nadCJFzYSuGWlpg+PIy1xKVwChEFgdWUMl8TaLER18alxCyBE6diJu/rLnlZin
TPA2jPKm4exzL5Ux6DKNVFMoJEKdSUUrVmF6Rb5KDogAlZnmvEI4ZEUq8L5PjsYIPZyc7Z5xmr1+
aSfHEcuMrhC588a4OoVZyKIYH/NDDV62wLgTXHdRZ+Ow4H+yWv60Qu5ImgqV8YXloOwqTaCuz3VH
k+sePceI+WEI2nhrwhMUBiJXF9t9v+1+Tb+J08nq52NA3WoNlQEsI9CifBaYEwQjxdLmsW1Fts3Y
L6Iwyavhc9WhFtUcgiBmTRwecdSzFrMJdhieWA6zRWnEVutLiDWTauCXSsbB6jXZZ79lip/EwRHU
I0HE7GTaxPnltDN7zcdyQkX7D8YSPjxOIVC+Pk5tlgAIpOxQXz/aBxNop3AUj/Q9tg0CzSnX2ttB
SxTXFSlkPIVES2+Hfq6BIY4xWlNtgV7xGzTN/6+4r21MzUu76Syl2CH7auOkTOhOGZT6nHt7P2s7
w4+dkPT65EJhgi048EXg21EcRXXxBYY/xBPdgbkYMUzlACDZT1WtgBhfUGw0AEV7BVAJA2AU1/D6
i6tkv9J+4bllDNIxh2bD7MUdGixZFbsnA6Dk5SJ+WcVo2U6q5igEoervSspp7gMvPRB3u4i+OgTt
V26bc3bwO14EzlFvZesCWXmBp2CUt4JryWDeExw1aX0esUAwItK+BBaKk09EnI6yJnF04ALxZD5Y
3bf5DRRJ2kd8EO9tawlVbqcGoHRhkf7lgjfUn1gEwT5+IQcet/agzZUj9A4u+I9naPqI8kG++y1b
g8nZXJoux/tESGQGlLC1wFtrsith7ERSrH1kW00Mz1UDvmWjRaFfJZKgfqosL67734S9zT68S5Aa
9gXKR9jWAo+ZMewlVem8ZjOvupjWx3gI0EuzvhdhNWKWLgCYvdidT4ZmK5VoAlrpPg95t+p+mN6A
trW/L8bxA8oOUyQIYzimD6P0/IlJs9tglIRGinGP1V6B7Fno1CWGS8naCDVKoJ5VMWurTKvkBkRd
inj5Hy/Mi9r4wr9vWlyGrGU7GLG8c6sDAXfSf8lg/rorJcTFdpLwOmj5Sx4xIGSlXGKHrcGdYYr0
UtRRzMODxcR6ulGU7x3XS04P/Uri0fCBZLEBRrUWH2YFeWIoR1w/bLa1AEJIYMPpMEoYTuse+ZUZ
EyieWmkx3OzLGUxPSMrMWQY01SJNGBBMcoI1Pqo4i8nrgTkK5Mg6i7BEzX3LFoX6vTX/GAb6mp5j
sfBEovsK3La/hwmmWI4vBVskNHFWTcUc45taBzg6IsnH/VVtIYt5VBu/fCysV22ibO5ucCHjSfYV
LKT/vojN1/P1FP0on4U1NUW9VzXphZ7RWyHR4ILkXrNZxhyOOevJy1SrSaG75JWIEVpMdxVkDaIQ
d8ZiE8UcMPppTQC3d2ca+Y/yrFgsqu1OXAcfwW3FyvNJYYqSDIc5E17sryCKcbZ8ZtYfY61spskW
nv8ZNpZX+B2zbRUFegiLnSz2PpVxa1Rrc8Oz1cpIhGzrWbjmBsDlvrvqEZdkpReCU6aV53/7YfSi
Nn1Sb3Iq+GZHA35C2/oAfCAs3JJStzfHeB6TYh8Lgul/iu9wjcu3uflAeIgf2mFDi4p8MZFwU42u
XxX9lmGvl8ED60C9RN+cLvpEuGGXFcIb1kELidSXW971LjvQU3e0eILIIlSTvErKF87HAceiIz2D
j9i7BV287Ho589yFMNtdXayqjYSF2791KJIYJJqZ5Vh+pczWdru66/SvEO5uT0tOOyfSp9PewQnJ
YZxcjFUczLgdqiETGUq9hOD991Sw7Z7dEsb5IuXc9yNntkoEK7d5cykblDcwjbHdXAlD9pCSmyI6
1yxWEoMkaQHF4HsnzKQfTj/6Pr9KlpBhX7AnG5XXNS/cXzJmNBfp3KHy1r+ybc287jZ7POSbrkI4
L0MyAkAH09fvhKauxRVLWiHKHcvqtOnhn0PMXlQLJc7hn/NcKuufLdqM9K2dEgOpyHyBQhrKTkze
ec8jPzqDt7/IsrPioPEE7pMvVR/SPs9ibGZH7ahy/Ad7MEoe/UsTpbjwNNjVbrgcCu1ZrFXdYnlU
B7muGEgiSGfpqyuwBmCknx3JmkAwn+sdNfs9bXwsquL1luRNmBvQ+j7UwSJYZhPm/bMHp944J5OK
ZeFEZ8bqJ4Sz53BP0G6bu1gHgK/kUQO7BAsBsuFbXn+smZ2Na7u4SLVoM57BJE16qlNjaSuzBmnF
2tRDj/HIYHhsFwioNZxZgBKsOI8Twb03bceD4pEYWfjwfwz3h15KcRlmodKhotDm7OlG9EvkPu5B
hC1fyyNRhx+NqIrxzKExbFtajZSgvuusn3Rlfev0Aasa3A9eGSTR8fJWrCUDsgkhl6niGYxC/YZ5
BGcxxcGnJ5Qi8pB9je9Ygljll+LOKaDzdhzbwAXY/hdd+yT2KKcgffvGOSUPgQcvph92/4O6I/F/
axn5/uoIQAqBCns6WOPSOy58YERpcy5dgYkjWxM3DbB1OPEhMMiuExVMJunwwfVE7XdLWgnO52e4
lKgpy1p4axcTogjoH06qZAsLAWbEys8phT9C7edKYCzygAZLuGuKskJ3NC8QPtvUwJNNyi6RC3Ar
W5ENB2FjymuL7el6PrYaU/PmI+lopKhlm+D+7ylcjXExbfUrLshXNPHGbrmh26PF/OUlAZE1nTYS
2eF5u+4AM1otu8Ium7wRlVVJp8ODsFFbALFYlsZW7RoIbhBv1IJGLn0kzU2AfUA11aUel3KA8+Wm
YxmlACNQzp6qoS7ETPwA7KX2gMR7+jujQQ/Xw5pDX2dTty6o88azZcoTMFaJRxuUfYVjDzNcExjb
p5GCkPPhUtEwxlkGRJbjbRJ6vgOxBn+2bN97DzYoEP+PUvbmu3+sLPHta5YH+SHWdiGAdD9+0tJe
xLaaQMpK/pgqN1D2+WaCAvwZ0/rfkTpAAtaa6+ssdGlccMdLjimb2kohEbBz4UVaP1FXBhhDTV8s
MCXWLyRIrsseYCpmKeR7NzqCtGwkGY9DJGkcsx1Lyirj5ioJ+T2LDyEhXkGGRGVBCAhcKRLmjV3P
Lsn0+BWrL8mMvXj8EVFIDhvVxl2pf3NOZx4MZKaM1Z6fb/QJmSb8cEyt+PpA1MHWTewfjKEJMnv0
Ptb3e8JBlnhy+WuJgXmZGjljRAFukWTbBbFXbvp5w5HDevCLPoXMdgs41maSWTErEt7fKOxWi/0S
Cj7tX37ev1SkcEw2x+eFXDqJtM5h/h4tCdtayhNVIg9j0JuFclubJr81xBLDJpv/ZNsvAmdztQ8Q
KVGZUTwUu9DDZOA+6z7gTkYiudkB4s/UVY2I9QPxIeMBwaK8IVj6bddZPZZ8YWSCbx/apLGlbY4F
XjjMtNYLvYecPmZvvV7mt1D7gA6Z9JKBJxupJEASJ0PSHOLxEZN4KzVJ/vH5OaXNNx7oaRq8D9nQ
phr/ORvUWtjc21Ab2g03AFX3N8uj0EOXy07zGhYPRAVHCupP1ddM/0miM+rCCsCkmjKpWSgJcXjD
aHhoWtKBZ1UPgO2pnosvnZSTEWwd76eGluXsBuSOf6NL4QJmLUeYOjHS/m9F1UPfqpTIvKej/lHB
LafRTg4XnsYZkr4ZYWTAs+c9L4PtLgQi+hDsUaU+0Q1qgkyqwrO+gG3SK1p095SpVen5/6/WC1rm
2cVRs5fRgaTRsk5ztE2EXWgHcFmohLo8DKyfTF9rA5gZajQBWS+fxzUcAh2+4M2xBnurEqYUbDmu
iImA3eAlVctrtpx+d8S8RwVppjxzDi6RRf7scmcN3DpzO9ootAEkB8kxPuCAfjpr2YKTXklUxP22
+W5YGh/LbJlPVDgYJU4B618AHJ1Rj8Sw2aACwu7XVn/qEhUwzfqaYgCIF9QSiooWkSodcVe5So5K
RG5ynEhqIblfnUh4VNTELqYuZ0GY0akXJqy5J/NjfOa41+wR4s2Hd/yMSjEJq1TabjsbX+OUq4Vg
thA1qEKrDXOfN6B8mwLohHb0QChRPG0Cx25Sz1aUd+7Tj3kNtnCZHLPmDcVEcNVY1pFn1gudIT7M
ko5pifNh5s9ioNA6qy65yxPNGCiRGgVC9uPmsHs/+AR8/iUz+iyETrdrlUyylfA08JnEWTw9/KOG
3bRlu0ZlZ96lvMxD6shnkw4dvpTXQjic0bT1HWbTKUU9bpnN03w4Lyoo4AS1ZvhDoE3VKQCWQSlb
m3Fvi6eq7fp3JRWtA9jRiF+Wn6I4i4gbrOlhhG21qRe/XXSFh+aCAnvidp2PRce4Dus+1xJ/qC7b
R1ffGZivOuPCyxeEm06i1m2wJi/kPsbV4OaYnMlZaSFdCruKTzWKuZ8/FS1N8643qcDi5DDUAMdN
7bH4J0luRmF4VmG7riij4luM+lpF00CfrJ6EDRh80QAnp42MfIClJyIt7O2woB9kJlyMs3pUGx2j
PY7b4lP16LidACSrsDoMcTPDqvGKZF6Kv7naWvW/7m0dIytca/A1/K9EOmtVNHPxmjZEd+zwXMMk
tvtEJmbmKQ2tVKkBcPzgSoTJtB7r4dQ/avQ+jPfQ45GjuzZJBWW1uhlDrMa95nN01rTWzXSOoPqL
Wxq5SrlwZbuAlPkk9OKW2GYGEyhx7HQdYllEQO/Sv98mpCQwVu/xyxyB4ACMnmJnxK3UMvDppEpy
6MmJbn2MgPSgHDM+b4NoD2Zwx0aJ0qOAheiLubp+ceWveHbLP9spAGajP98DoT4Moy+/FcDvEbg/
KiZ9qIbA6bmcWpfK+KGvN3YifP4uMlLe2wi1MPcVxUYnFUGPPbIfbn5GG9kDjR7RRYnwDbixFruI
Ac5bkamN0OTcwO5ZaqMH5VOKGSKkUuZ4TA4uDeDyzbhLdrphWyEbc+EaDmcW8ENPUd+Syvly/Ir2
Hjwonpcq031EjIEtueYyL4XqujGoebkBph7FxP8tXdvc44QaYMlCi1AIUIGvcC3Z8SLKB9NzYNMu
YYSECfpfMl7Y46tWeQ+cecQ0JzOeQMQAPlpeC8vKfKnlwOCVBnyAgCsyfLGRo7DrpPypg6PzA7xY
rvY8o77Ba65jXa+VNjsXneW6VEVrTFsgfZ6L5IaOQVfTdQsBx487rgBNkoRufj9U1rAB18MTaJqk
4N21/Jmwat4kTroNCbKDx1bJz2fwsfjFtJ311j3pEThykBbGuqWc6hj8DqymUEzf+cHR4QC1K8dx
8L9iqlV7pbOxg+PAa/ZoDDabTHqj6/sq1a2a46rwyB1TX81CxKfO8Oe522/JeYm2+Jt2MAGUtIgu
b404CdM+F4KYF8Cddm0JtpU1S72LsW7UXhjVyBdG19jLxWeTERe6fdhUJumYwbQkSHZhMVqYK9v1
fgEhelsz1OyvaofWf5wi9w1xj/lf9cnYMUwDO/KfYoM/ZNJ2ffyKAMWwDb0ZXJt8Q9I6+atzBtqz
j5ND0ohm/hHDJfODMRBHarw6HhnL5jPdWwmAEhIbYB8HH7Cgm6CNTuQ5g96GR9KwOq0PKrT28jXQ
E1TWwdzyu8urdPuCsOiS/hl25DldaAvPV1XarIlSU/Eb4FkC60WL0HtjPOfSw2USUMYkzUC4I+Xs
gpl56fLTyle5kix52XxB5ljjwPYqoi1FwuVXaSYMw17ViFhev3WPMpZYrJhX0KageGXc8dRlR6bc
chzgHi8mVc0GpMF8LtBUxxjc8wB55G1XuHyQP7LJ9ti3+uTFQ+tUpINhd8fUdQdZ7Yr8SBpbTPtP
5CwYGxR97i3iv6PgxPCfarxstoAPzVGKEWu/c8zQjW0GWC1ZL57hwGZ2eMU6tvZkoiC0V8T1VRiw
nXiwChZ0A+94Jnf8qL2Lg/I15b2yIslm7XmRc9lRoZgHDw47A2g4rfvvpeK8Ls4ZO46yxtD/e+h4
wMe8y/xyFgbF0P4Fll2AUKXLHO+bKIWsLTbcRzO7m9gFT5wvWxjk7nVaHeY+iQ5PAR6vzuI+oNvM
4IkGL2oBDwzNGORPFY6Q1Stnc/cSk6Qi5R1aWELpZ4l+9VRsK8LHe12yTEuFRmQpoUx2j7A5O7wI
ENpznyNY/ZeT3qTwKQUhfX/vmIjx3qEvFmZSALM5nKASaIlMvHRPBSu99gS987C05Ubk0nqd4TLy
uFFial3kKGbYyJCC72NMl5vyozHkTTHJoOUBIjJmbgP5RHmsr+LDG7i5v0QW2voiNX3KQfZClN5t
ELwS5A2JIx4JBp8ka+5EikfgvvenHTmlWbGLAne6KtSR59ZeSvGA3uz5hjUyL2fQikMLDbxEaKNS
bSgjtpRHe0TBl3UXWrUDx+QYv7V4gzqrFQbQqMxw5pM/mlzFayMbhacHzgszoXPtlGSZzQzFJBQq
QPhvETCyhKS7DojlKgp8FP+JR7+aeHKGB3l71ts8bU2ySM7Zm8QcCeIe+L+wPTz53HYJwteIpmXJ
cPbhjLHam2nnwiEwpMDh/nUC7sFJ9vzYb2cNFMzTH4wYc6KvyXpV2nGMWC3I9cX3vAvQMA9klwy7
omY+Qd7MoajcViIHvga09fU8tRzSQ24w8VVhHp56t1ZwwbM3c/gPO8qvbvfjdBG/VNSuOmJZt5+B
BbDzA6xUgWx+D+oJBxygunIRhy7uvYdGpNC8BScD2tnzgy6mfzSHOoQGW/qHFgjP6dKbGJMph8AD
/pymQmf0S90d9LlGznLr47aWT3kczz5IhcCv5hYhsXG2zBuVg0NIcTSVd8Py+e/biI7gZShZrg/T
CaGzYT2rgr4vrOEb/Zizdjw3vw5TIzJHbiepJttMlHImHxR4qcWwOKcsEYdjKi12m5kQKd/B1Dzt
O3FG38muNGod8B7uCjdWBF4ukwS9bJX5meYPp/rnCSSOC35Hl5O0vtnPb0t5Vvf7XsXjVXzKC8kI
PDfsESOjIL+MJKZmoQfgVJP7PDNLyWthtym30n65lQmXYdXioPQS2RVYeXO68M/yy0Tsj6Nji66h
Thap/wXOog041rrE/MlzAz5e5CP4QXI0bs1FEfvAVSLy7jUkNa1bvxqbHFMiutDJRN/kA1HsVXZ2
ca+dkQTCFUhu4la+V7ty1dLYiZYGQBLlT8cc/M44CL6/pfeAimjV04N8h8hsoutoMUs+iOH8bN3C
/tlzGy9njdj5ACW98IxDeE96s+WYBgozflS4CkustR3iFiuPEQ/OhNwp+aBlPeRZVEspAr7MSLAA
9EPS1gY01MEkeo/WBDUphko/acW+pqmJXmAPAznZdu+SZD89RBIZAIWQya56yW6wX0I3xPrjo9A8
o/Je5R2LN7BlBEyNQzyaEEqL4YIPP0C6/iQ7zoUfNcMA3whfC7lHEv8xS2U7zrA6oEwUitZrfom1
Zj4hn+tl+IjMiv1JSqaTB4fxkvg77iILDM6RPabmxNg5mcA+jgzVUOE0MqxNF5f5OyoP9LIwZb43
LzA3iqY1dk9shiHrFlvRo7okMgGTOkk/OkCb1bCHZHBsQMtCMx9ugi5XdZXDUVMiaiAGWUzVrReD
2ubZdfOJVMyGMHOXjm/ks0jIOcBvZZCP/u4a+318t9GBd+mzcLt4mYa3FF1DaR/corAOYvG3r1fq
bLeVoWCvwpwPEwozVndJdtDD0BuyXOCRhzq8XRpDWiVbu0YqCmAHy5+JAsR2/daCqz3kkiCcEFdN
eZmCXjoHOeKNSqzysuFx3Tdlp5dTjIUCPqpxZZ0x0vIpMld3R3ygaFmdSV8u7nCfW32sLGP09JfB
XL4KTq3jJaFpdRB6+4JH2Fp+7CyJZjcqjMKNyfWrnj1Glexpdrfq8SqJ5RQ1+ZqYCwGrhaT1E1lB
6LAFZzlz1yCi+TRK8i3yuOP2w+DyyCZh/tInom0pOnIBxdslgQFqe/Ji9GayR3G/5uuq2uFkt3WT
lpsCmbWl0Ne5Ht1LjvdZRkh3XpINuZgSwj4PPp1+hUPKtOv1LEKQ9sjZwFhxp4dHjoo8uIavMsaj
LpXS112/aaubr8pPAWxkdhAqlBvaAoDc1Lu3c26IgJpGrrxu9kTBMiCsNgFw2vuNUcI++IYZMi5A
Ai2eSWXa/5SAWmoBaWfsFPRvgQfKS5fEtvZmvL5W+QiTyUbpgyblpvCG68IF1C+7bHYGviauvt5A
sChGhgde4CEUXudW60bekGF4kbgPuwdTmjS8+6eHsSYCoUdDGHSutvrAskpGLHEJ89T3AwRSifIY
5AOU10569kJEq7PjroEMLE19dw9MW/+TUj48TTx88TlKHuCW4DVGjyle8TESQoqfNkEib0zb14cI
H0+bmcZuHK9WnpXAWx8GuwPwrTCv2rLAUeEe7o04kz66sou0DGepfRmxDtVb0zS8aM+g9ot/ghlD
w+/NFzilPqxy6JebnNz4pwBsiqErelyd+7BE+o+budHkyfxn0nKJleEJmOU52v5Kd2GMlV03aC1z
xUxPRU21ZBDVBcTK8ZLSPQmx/lzhyyoBL3/RsXDKfuM618xF2arWd2CrBwYPtE3m6nN/osWquLlV
RK5Rq58OqiDwfq3mnfCyjtWEQponVp3GUSWAvczWMDuDOSLe3p5VOfqwcONrN1rSvkaFVcm9oT15
M+D27qhJvFoaChvsOa7yKzg/sGMoKdWv3/YKYOI7VOp4qNEOB6NilLBewjf5v6k4IIRDwTYr8v0v
udS3OIWAkUoS99PyheugMAcUl1Vr2n7JYOUtsUdzUpzbxnuzs+NLsmVsSYUF6N+y+rT4aOsP6V6C
PjLyiPgam9kuj41d1/iko/8HFvZCFOrHGjfIQf8R5r5T1Y/rzpi+0rdUNM9WBOUtqhNFA3e6zGiJ
/IOqeg/E5zF3mqgpZuW4i9B8NDHc9UaVy7BqtFlSoHvBQDnSCYgxaNO1oHrETDa359WP7iOsPOnO
xcI5yquZDoghs3WUDxY1QTUxa+rdZag2YYZYU1M8P2D4a7sN9Gdv02yC1a2gz05Dk3p77NEEk898
sk2421ihwjhcLGOfRLplnxMH+PTiCOjvx6G32xs80paaEJoD8g/0Oz5oNL44jePfY0JkEbyoqeIG
wAS8GFUc7E7s6LxJYd3bVNlmsNb3uSbgk7ahwRK5H2g8RaavoIkvtap6pxfyRqBtxMksGBNEafXL
7sNP42KVhyZnh9Zf9oSYA+DCFlMq4BXbV1G2Ljhw6iNK3xgWWOCm/3lawO6tDdAYk2RR60F9+7s3
K5b7Uve0ocJSK/sB087GitEhcmtaaaGvZgnG+HVMypYmzQiJ5cCKthG/jTHPFm6mFFbApDXBjC6j
7XfoCyBJDRdtAVnTJDe3mA8hmYABp+uALlv1F8sFKoNz3GevFIxcW4SC9cvilSGLxEW5cKgDrM0M
gRrqI3toHaCAU6MeGiKeaD0sZtBkfuHJcWcjEJ68e2JQg225V6gQtuW3idjdUDZLKCGifMSXEURj
Oj/MnmwVHrCB/6528RGVraAI89/7jeUzP/5Hu4nI/FtCNPEeWz1VoC9FIXwt1NsaecHa1Ky8fpTE
aed3o8oJ/5oGu3D3nADfqVxQSLoBud5spM61hAxaZ+5XnFb/G3G5tITp99S3HsEFIGmCwll2NwSb
8nQypHojYajNoSWrXETG2s2B2Q2yAqVtKXg6rzMvH/NxUMmY1X9p8ODyGRyitbxd90OMydb6yemn
Sc34ClgBUTIMwxR17v7QDcbBvLdQiKjBGrRBvhMgZeNp8oDuq1CjKrYgHHdiutyTqR0W0mvAUMwu
lQHywxhhogYsn0DW37KZPhDPXNWxPqiZXnTN6doTU+Oz1l9Ezm51tO+9233EH2YLgGN8kxiKLsin
CfP8PEn/j95KLJiB+6fdDX6irLgB4yoQkzGP4heAFtXfqQUJZ3wE7cJ97jb1Alac12SZzSwmExno
VrZux+GO9xRan9QZRdpteltLuFr3B3HeQB5Q44l0Gq9Yq/VVdSfNJMrqBJ/l8ZDUsPyS05jLwYOb
dPwwBzW56PrzFLnL1TZDkTdOT1JvQLQkDn8gJtIauQM+AHHz0P00eoqXx9Gx+GtVQK8iIhOWVG/H
9zqD17tIRjnNRLztzj+rsJ2TYj/pEV5wVau6AnehEdS18Te+TChSGU94duF86S9hOsBf3cG2JWAB
DKUDkCkfO/mdmMvJFA4xb/sc7s1vkGVq7bPeJCLHaV7axXE31UTkV5TMuR7bl8D6QxyNFO80If16
wc3TXqwROUtkI24TSTdN6L75XQ6eREo/lrXomIqptA2CN6zOteS0KHMSTZZMwaJi7j6tPWhBZFGP
l5ytVtxpcSCMyK3ah70mI87fdFFcxHV+hRDa7yGX7devuseANGJ0Rwf40qIOtfbT5Il2/eHKaWOc
kcIrgYx/qw8P6mITtgivcTj7Uagey4yMbkT0rp99pvS5P1NFXTPPA+nue2gPZxZjJP8O3lt+Rz3E
yWVVjqj5CNuosn2/NWuZfQLy/9EfWKL50k70rA+mQLlCicuIpKqCZGOiLVbV1Uet8UVu/i/a4qbz
ITMxGuLxPelorFfT83pePWF25PQhcctf7EFqJZeyYsN5yOEu1mCckeDH7GgQzx6uAO6Hlf2PmGWl
MZdn02sAn9jFXKlXLitn1NzubhAB7Xx+e8MPmqmv2gxcfxNBoIEEAamIPUaSfYADyIvFXX/e5G9H
4T3385wwsV2tA2zAvTzK2SWakfL+XRz9cphgSlxyHFjyrFW87PpA7eQzikBhuvDnNKj48NFniZZh
sIjfk23HGKdx3zWI9oRg9VLTSgDKRVRz9UoYdEQF43dXnkq1tYfLblce5ER6Vk5sZGlUgxuX21vb
5bACyjA6QbOGOErrHGMrKrVNyG9U2Z66OZKpGmg7ETmBMMSioIYCjCLolFQj2F3OqPHdpx3fyx3O
85+OsBTPoZJ+bKMbRT+IUjzPDYgPb5rdjO8212SMdZwfTJlZiksvjguko6IIKNqBzlJJuzGhT84K
BaPew2pct+Os/7LZp7XOBzIaPf0KHiHi6ylVynmyCVkGdgakAj6hJMZuCtVlT/ThiSTPo+0QGcm1
yvarfgTkhA+4U14YtOAGY9d43MJpKTG/1hTRKUEojfPlbG+IQBsk167mmtvCoyDY3XNp82DdIln4
7IVTmoxgxJaaqPjtIZMH62O1v5AdvNs8DWtq8sjqAKbeGTyK4s9IlWaTHyjiNIKKnNb7p2AqUNIu
U1hUh5WYjW51J8namcadr7gGPdm1XRp02KIZ4qFDtr0c0fzy54d2ovlc1I6b4jOB2BF+RoPyZwaI
1ezxHKkNrYamFhFz1SvW83Bb8dqg++TvvjyCOyy94XwKH27200M0BFcuHxv2pjfmI0AMf6q3c6I0
NyU0aHuuhtkpt+pdfa2e8/g+9RrWymYv80XBri+LH2eGbbxVoOuwJHS+ztZVWM/LLcB917Hf/J5/
F3nNwCz0e8aA16B11stSAnoNQm3M2JoSKxEjnpKtP69du6v8TitdkHVis+T6EUS/WNBO7xRjgtE/
P5dldJYPVUxEBd1MKikPipQnANenrYofTf68lcLYLMnSd0Y2Fvwi7RNDHswPguNHNzRRcD9EtA6+
8QSh4HsMDr23wbVnnsSN/GO4SrQ5aaGJO7LQg4cbTtCQQDmjR2s19BwH1MswVRUHgxEKrqnHFOKA
6/OqJm7vutebjf6WT+yDaOAniKH2pQOcafFqcTPNQ11X3k4Mgt4GxNC6fqn558w1fCnY0/FClImH
c1RQUt6HiP8YfG4cl9/fQNWGqj/GiKE3hb4Q6iElUqcvWgno94az2kCkGK3sQU8EnKZH6ewbRNc2
SIH9Cy9bDyk9uw+aSdUpc79BcYpAP6xUGX71jXwi/OWtA47AdAMlQNcNqfJ5UNeqWw+ib+5gGATN
GmC2VhV7kYkRGjUN1E9rttjHVxNKJx/079WOCrdwEEtC0+GJdQfRaQZn1KAsH3cLVp/zMeTs3Jgo
//MAOoteKLiq+8MKu7O8eKl5PgriV0Z02EU4TDU3dQr8F6C0PR7z6PGAUWQUQMY8t0itOo+VWTyv
fBIo1JMCvb2gLDGEuu+ZGQRJxTFnEev2g3MBdud1+8F2Y8btmvdTtGsXtS0U0+u1T5ZUM1fp37/D
j1LhpryG6NWjJVp+fwGe9Vj+NQJSDN+dyVqthgXQYGQvGc2QOrkiH1q5URZ+1lNFbazRMBAoK+5B
VUPAZ6eWyGOqRHNq5dMP+o3Uh1NfYff9Hs27ySjqoItRwNSMmoygfIoZCBLl4lwBjG+Vt2Isi6C4
Peu+5MFDgxs4gAxEnSozCm8iM5kQZFX1Ibv1nRxGodLvFFsOvr1ruMfLNQxFjoiPDmbXIKVAfJgD
oNes8NDoVskOt47VZvz5bkLa/tUywIMKE/eu0+5UcYo3pKQJzk32AdvzvZUbgFXjjOK4RpAoZL+f
R3xPc2IppsyxAq8ZbKEQZjl3JLHinOSkHz2TM0g9tu/SemLWo14LcrnD8XIap9s7DkdeqHss4m7E
InF3+Kbf6oIHOvg/Vvb0/K4IEyy1RcKALVfnm5ZNkJ+yzGHAsUjfrKrJKmXe1sUZumlzd+Y6uAbN
H3LnXFlqiTJaBHnkmkZADu8t8AJKbMgEdb8CAV/2IGgaaqPw50UZO3Hl4CjNegiBuduXGhwP+coI
Zs3PAlCC738n5sLYbSvNUNH3glcDJeAXQ/4WwZmB7PVfXiRs01vfcx1RSouTfbLVnCvSeFD4zO1/
lZt2qv/P8YP8nczBSgjS61oF7HaJG/JYkgBdDY7mNoBXcWvbavxZXifooRrJtaIxRWf4cYH8f1Fs
hKhEGxWTJoeHzG++mZgAR+S1Lyg4xpH4tMJRXlA/ANkc0Kc3c8LmSalJy8UJSdx30JFQYSo1BgDl
iSy/y7/w5iLa1bTytPQUtNR3TAJ69+MkV6hRpeW7rUqu6HLdRdrjisHS7sBIMV/soAGTciGcu00O
1qaO6gsW71sOe+ts1tpMRGHTQFsWgUurUw+2/RItwfQzB60v8V0rnevrcli4UptIDMvy2GzF9sb2
Jf0ZO1ZOjsmOVg8/sG0MzemJ8ebqAZEJeBHkLcURZ91VHJFKAtvuV1K8QKHLdouiVx6VCouwo+6l
KJjjrr1m5TaLvo/LyPQn9JqYlnoiVKJG0cfk+TvxSAlnXX0deBPwMMKIFQ1imrgu3uehnK3ngei6
Is17KaKqV6CUVemFN0lP2Jsyc77AMlnABrvZ53BRTit3l+BHeCNYWudLJg1XyNlhUF/rPIIuceEU
c6W4AO8Ptvz0gSfjKieXk1eDIkyK4maPz65Nxx6GrhFeQHRLCY1a7i5Z8Ba+QoGaPGu+T8voaCem
e8Uufmkg2y9fwoJTVKqThtqzvN7pjhcUH/nD2ywg3Rg9EXIq7gbOboKcCxRTY0UXX/ZNivyD6l8q
sZhgOsEP45Sv4fq9CrHwmVO1BSUF8RCyYWj7d39L3X7nj5hdd5LoAU95/b/yDJE9j4GZZXgZAEq+
mKWBRQaIuXZ14no5tc5lG8vGEiDSbNQyF3k4FFV1MOS9o0pD+a2LQpcZFuA0hI7c/nsFm5x0p+GQ
AMHUF9fdgRsjVFStP6Wo0UwENQZQzfAGWzyDCo2bf5UFYcAAisfWDAevuPpoDotTcFp5D+5pViBV
ZwuOtbcbUqIzKDCmqUXl7UKQdIha8z/Fd9m0uDirEXzuSTfOZ/FxSCpIQ7EipZWxLJnHkX8t162t
9moyhNHxz4S1ColYn6sH3e61VD2E0UJll60QYsWcIm7RZymISYgza/69wHAdf4iTHFhh+guDd0ZX
4NikaQseNFd4LHooqm8pGZmkYjFHtlbxkT6YnCTi8g3Pq5ligfToLtD+0m429BptRg6XNW4Y2iYA
e0TOas3AWyOAwFbtc2wEdRiFVF/N68Jd1XmCFyFibC/eGNfcf0LvUB4PAKXosD7B0gieLdqIP9hM
DDpKX9u5JzMsl0JpVsDhwuSobVpOv3akJS7l2LNVpseZaUZl6k3BXHJ8ZAHoqdU53hkyH2wVbgI4
+kfxUoUDNJUl5f59EnTldSMao0EhFgaxvARzEFukrMR9OVVvm2Bq01SbfJDEslyAR0OYkteqh3SU
yDcGJFM+eY/n0OVibGTQDSDhlhlRwyZJL4b48ni2kOmUdkesVLDw8Dvc9qxFmE2gASQeCxtn2vAI
GtudoRi9n4ou4IL8Vd1mThRgbFTeaOP0mQrdszyA6wEdFNr/MKlkNt/r+zKRjelVXeaGcYyuGVdf
2iu6N3cpe5Z3tVwvJYOQBrf+ps1bn9np7MIzjYPFcuM4BQIpV64z3q99KWJNhMzjlYBptDIAuJVt
3Rmgicx+BIsfm8AIogP4B1+0WeaCEKaMCBr1gl1AHEiGNsRM8kxaGo6RX2rmAz8uT8XkgFsYq5f4
TLTB8uCFWkI9SUIYktZgqbMiaF1vMP53HJ3UP4uDD2AjUtZ7glVV0inoP10zMPSReJ8bKamC/5MX
k5E9uy9B3Pk046j2oZqQGJEQY1/O70Em98m+wv7KXwoIjax4/i//qlrcHAzOMMiO9/erDWwG6Ho8
U91A1BakE6Ddux590FMwlfh8oxi3ruulHhTMweEPTeLbFxHJ/o7NtYMb5hGzGq4VWLI4gFcP99LD
aEVODnOvB7/QkWyB/eiKu1EpDVgVveleGpt96J+7Srn7GmmjDDPhJputgk6FzoIE50SBzsjvRB1Z
50/MvhIYFRT4a8rdqdwOURZr9IV+2RPtKNLxRYagXGWNE0m85c9c/vkVfGvswErlGQvTQCDNorn6
M/ghPJMK1m0jzoo62xDjd2jH6CgBhftbpyI6rAdjUnT6gvT0bnkGw0U85aqzA3OVYBU19M9FAdYD
/+SBiRZK6mANAmmdv6YJ5w+1wKuWWyvfNjP/5GdGzY8VQomh/labwBhVmI2gUVYdDPZ/6bpl/UII
qDmWrYmdg08efT3VQ79xu/X0cIPfXIMqmCcU0zMjv+xmmCc/rVLIxwNAOgnHdn6LAknkj3XaNcAq
YdtMYdahz3rqxkk3WZ+Cg2zkAf0yi3T13y2BTTuS42ODS//ywSkH6BG61gO7UV6hDocxI0sylXNt
yC4jk3ZPwh7XiOBXi7OWI6FkJ42pPHcOfP8HqPXxaHEuMQGcTiPywjykq4+3BrWPWiUF65wXNH1O
2PZx80+EDcRIQjUF+XHzgyV6V+HQr5hmzhMWWo22YkZCBKojOumUGAXwa1WR99gEgFWOKJGtEj61
W02gV9aM73931yJmYXDbylgNy/TcUGKWSX0zjMQyvYd+0z/fU2Gb85IDjC/yThFVD/jE2WKuWm8Z
ZK01MH7MtxYKG0MsvYaO8k8Zz8+9hW3koosAfq40vqRSlIy4GPh5DHjx2xOI0pwH/CBp3atSRJgq
zGyFa8/anHqzsrQjcXRBqDoVY3HwF9rn/hJYQd/FFP1/WPzy88pkRb2dn0wMjR+1oY/afbH3oDRV
6APKgsdk7Y6uNdnFCknZHipo2XCpyBgYx+M4Y+SADEQbTAdVuBxpFSReas0RbYefZdeU+3uUufLB
nsTFWiRZPTBvC8dbfJqfnIIPA+A3X8axfNP0zEpU/dZIMk+ESHhUiIkQJwG70UWoCiz5nZg0QuD4
p5g7oTRqu13yC4MmjndFs29LnwCQ8aAUyUNWScbh1iC0pEkU2Hu+uMiClqaX14svMswu/PzhHMrb
Asb85JoBrfrE6CIswSPIZZuOD1s5k0WwGRFEZUJnNx82n+5x+zSv4RPiJmWJQZyBVSTMg623bcCM
unsHsHmh5HCiPpvYtu6EeYVoSdyqzBvqDOtYHUDPGmAPM17lrsa5PMLfHdryAnV5WTf6XZGojCcI
5RCj8jLjKc2uerN4iQOdzsE6ePIAMzUfN1UDzZR6GlUyyouQWcgL7+CyAtpFSPiBfRd5KkuPGkQy
f0rQQ9GnGPvaNSM10MRLSBh1/cwRNdolWeLsG8WjLNMT2qxVQQs/mOELBX8YlTnABdTXcE7/GAAg
x4U9QIWYZcpGTTyq0//Y4y0dlLGfW772NtcsmDxFromLVqJqw2/Yy+XLu+xS9BfKMhURzPr7rjcr
Uf/K0MCPkAXt+MXgsLnw+6WuTCsqHb9q9vcIZhoy7JqMi73PpGHeAkKXf7W7xuy9YtBJ3qbnu6uF
+UOHHsI7mFx2+2gPAlmPPWumJyTEOSdDj/gEnmqHD/em5Nm26kythW24wTA3h8uSPkuLVbTytrj/
NIwboZVAgB3AgIHpvSESsAh0s+kFqWvLVrV78F90sfMwDyuk7xKX5YxRgVwYKrpKCwrM9B7h1h8e
c++XKj1UyXUGR2+jmCHrjnDaJLa0RE6KbKCr58hCK12A6+LidqZyjFX9SpHTHIPqX5cdrPIls4xn
JC1ZrRk4ffddODX3O1cEbOUXbt1h6FGkvEGVuriZeEmE2Wku99vRjqkUrpyhAFKaysYIxSp3JAe8
3DrbimEtwunnkpaMplN/E6pd0ABUsBo2SAMM5REWMnLxp87qdrxZXCy1ZOIOb7WEH5aMvYXvFZ4J
xUhRhUA6ySBLv8uf7ivJruey8OrtA0eRJQL8sYl33bp/OPiY+fykGfW/TFuFg4Ts4mQlXRQkqlzt
Dh4k9DIZY5pQt9YkwQ6pKT9Msu8cNuXHrSeM4UZPwy3vFr0ifvN94ozXkFo/8qwij5A1MUKz3Pxm
QBH0/GbUno0dlAZFsUsocgq37acoaBaZTQ8BIN61x8xKQT8Vj9ItBi7PcuDa8+3GYpu2PqgapCBb
FeKrE/0fiKG2RdFPWHBJ05rsdzq3GjBOPBjiWQCtT4aqegkIdrofU0Fl76degRJ0hy55JQALef2w
C0WEk7TmATG8Ud17InHBm1pcJGfoayLjZhoubyAlW87374s8TMR73UAvvcxsIqBUWdhAzdrYkp9h
tDFlPKtyuRUK61BJI44zGC4X3LUePxD/5LEQKVrqoPZ165mlkytel31oDXAyPJlp4wPAHIDVRaQN
eJwIVqYDYKbd0gOzzLkADe36s4W/0Q3BLQ5/hnq5Z/WaQQi8MT64T+vWKe3tAdLamniIS4k7IazH
/j0IUj3aQZYZyGU8mdN4/UIAxIhHCAQo8j4sfwZYDirgFRE9lLjF5SvvnsnFU5DEvw2IeYQB1pT7
bCksP9ZPQIuwzrmUTmV/VOcXdgM0FFmtSvC76C6zt0C5d/EQyBSQUhsdPFURbHnLyvKkZvR01Lw7
3c9+NeWulqBhTsYoH6chh18lZXfmPwu0MhWPO2mtgFXiGMKmkXQQWou/r8/JWe5R+Btnzr6BFrc5
ou8KXvBrPFjWh6Bg6C8U6UzSEnm8pEaDQEgBLfS5VWD9TBmIMWkICYGFeneCwi9Arcr6vzE6s26W
wvtXYp4YmucoP/bYb3sikxCfPuipbgR26IGhhp4bj23VVNwYuqCbHWnvdi0xweZG9JWmo7G6W/z0
4+POULoeXdGdjp+1KGtZnCRFgY8/lJLyTVxUJdpzW33jRh4JS4MhdYkXQXi+mQ3Mw5iUpg4QCAxG
ExoT7Lex2Fpu3PNGef9BFlAxZ/Z2xnesGOaVkEe0zo3pINPCTJs8Zewzur5dwlXqHOon4O80aX9I
LL8szj7+3CeB1jAsi1LdmOxIF+y9+Y1RowLwUO/+PDaEOKqfGcacc+s2W8uTqY7o/FGPYfnb3e6D
0Cdw4qFLnzi0lnDLJ3MGK6UXtgdjjhiVW1WBQlrVuBsm1umupKa61uof98gj3B336gfVEUW35wlD
TKNQ4xsgveaIUu9Sr8BQMqkrscMqiTzswAbTAkGmOflRhXugKh0UX9UTWKPtEzwyKwjqyW/P8bGS
tN3xTBT6Yk11lL/CgvJM5dsSVXA53MgYZ1VVIh7TrmeaIyhAWYZnUSaV1CzqUZWcnsY+IOCQV96q
W1MdI3F4zKTKQCvujvCRjXhKEm1Eqe2BY+K8x/Ap/Oj6pnCR7/zQGGpE9ytVzgvOVGJUtb2yYNTI
FKlLc42Awe/RWSXBDuT6NJ8FDhBO0xZSH1q+HNSOwNTH5YzZXH0jROm6IvheXuoYkh9bStA274qL
qZl4na6AQhliARSUb0oxrvUbSaH6BdC3eC90ZII5rWEIBO66TfPqgZpFC0PUKebbhB6VNKS7PfCe
ITCyrmVQfO62WwsPMm7zbOCCKXt0FMMd6+Z7p4QXZF0TC9XuAu4sYXbaLCkBtyeIzmfNgrtbqnXQ
sh+/CtfzBLd1rjEhT3f5Hk+ObPxVtDu/1MdBvyx+M3kTF9Ybd60Qmj3+ZuvOaHPChOAMlXg6m6Gh
nYAySzcJcMM7cbyXbAFNuFKIv2u8R2q7PLyuJTaddC/iRm+SKb6/RAHHSvt0kZcMyq24V/IUKTg9
DXhsCZY5lpqcerLFxDClP4aw9DVJhtD9NxrL98fmihX3DALjf3f6A14KF7TAhRdXD/XlabzGOlI1
9SKoVHUSC+b295VCkJd8bWIVBl0lCePvR5E72mCfucY2U5tGrK7tWhGADItjvObWP4FC0VGB2adt
kZ9QHJ1QBC9JzjXLjblHFnYLAT72SsxeLUfM/aOv0NEevlI7gpckWP+J64Er0Gkunnn/vesrfK1U
2JfVuEmBb2pBqOw7ace7Pnqmi13Vuz11Zq6ATJFDWbTnRoLXGIXu09AvpJXlrcv3ZLul+ADipUfW
+hbxtQb45a8j8Isl++Eaiqt4p1HhNNTVAUswWXDomQc+4rz9ndrKBJIkHp23qYjhAM8KnIBti6VM
HydMqvOI1ObZ0A/ODMfLA2kYD5oDz+xK5/1sX+GkVSko8/Ztc067EWkRAw3or5utLt0oy5IP6UhQ
Nobwebe4l3JNfXHtObwihxKbMYlxhl7WrS40owgDDWoFz8DgCW0zdYgdfffG3sVaVARSGQmQcApR
fLkvwm8xCI1iQdYRyD/0ClT7SHq3WONIoHLeesAnhfFes/DRQKPrPSZbjqdSJxwWL8xZpAZ45sS8
8YTr9l9sDEtGoNMp6jAZeDQuvbA4+MNZ4zdcgtHvg4amUkGHm+2sIgb/X5GAZvxtM0XscQTDc8BR
HunF6Zt5oPwJO3QGOtnHbNzgZ+EAksc0+OFiku4s9TNvWjBUEeH6FN7UXQFmhx5iuNAnp+j+GglF
DuGfO+GK2fKsH8WTLnwQIJd4HDOC4acuGgxu5omvehs9T28QwmSm/3Z+x/6yd9rLGFMf2CaHaxQD
Fk+UaxWbSGv75xS+Djuai40OKx2/QryytSwHe1Uqx7yAc8goY1tGGRa/q+eNyKBUCSZ/0lNXpWQo
DtJEtqEqq551+fAJ08M9pdCgfbu+hrCbCuv7PGu2/Wntj5v8QXvn5Tze86TcCxoRNB4LBle1Vybd
LY8/4i+mfU82y1CoZsCJbIUq/bs8D4sehXLgGLPDl4hmnH4gvnHVAkAeUXQLZULz6d2DpQz4vDx0
joUt/EAj0URxjYOMwDeyqX4wT6iAELhSzSw6QlbmHxxu/RqO4UoxRQeDDHdlbn+oPuEXqpo11dXD
v3mb5d1veHI3UVDkw9S60phaj+I/2VHJ310LlFWzFBdtUHmTO+gbOlhGEyD7kCL/1X6Y8gjCjryN
/jqv+qhhT0TRGERUJrPLfyA5qEwGm3Ag+o25FtF9nGVGdWXIZghaed2hGZsuSeoLMKW78sFwVhEl
xIJIE7eRqqaAnystMayC+idbGcu5rtyMMKOyVX2VChVv9t0kfiHcz02Zs8T6Gc5DtmOY05/eM6qr
arV+0GVa9U8BuUcswV7xtAos8J+X4U37FkdCp7Xdra/ARvI3x1bZDvUXi8op+xLL3eG6K2rci6uA
Gv0oPyGzLuuWrCsAhotiH1KS+he/3GhljVJ/Fp/ItvmSIojX1L84QiFTpIDTyD1eQM6mcqNBUOJV
F1N9zvHiqO0EEHsrmTqOO0YCfW+uWZ7///WOWb4P4KtgV0a49f0XpCCTAXkiZs9AgjaP7mOscZz4
8/N0Ahdr1Xa90ieGvUpHTOEVdWWTj/2ZrYo/0EDHZg3lcKJi2cgbVUm7qBTiQ6nVM+dGHgg2BJwd
/YsxSZOmPLcEki4Io6TQQg+x/d4psQOUxHxRR2YgkTk/OYTR2Fh6hmMJXJRbdUJK5ANj34r3iin7
blbHoqJIf3qnC73+IAnEfHaH4yt9aZQY+CPeyaaVfXxK5coSA5mo8Ai2DWqayd52L48Kpy/52lD7
x9QHAlBsIUC4U7TcpNfXPicI2z3keIDITAnsaVFqVZ4yuCiwbSR0kyq6p7/Fnj8uMCvVje3iRmx0
+YLRjYp7RgdD7nmn+oNFLww08ELTPnVVpmCI2X62ytUWHAFrrZU4qGgm5KfEKf3WmaZCeNXJRRtX
RRqpLiOE5KT40qdlEBYBrsdYs2e0a6D9YcHrOZuASseanjm/mcYohGHA/ozSiWLJv9EOjGza1o4T
4QCSltY43CoBMH6lH/rAHzNy+xnndJHmTQpPl5fVpokqd8s8Ttga0HS5Mv++mEFE2g2Qeq/BecNY
uUKm6G5QWAQE2i4VTEyfeumCWTxggl7hZuJhgwM+k3GEbK/Vnup4x0vpKzlFK1Y134TdEFXmSwli
Pcm86UPI+isuukenP58HZaiytmQ3XLqdCegaVh0dBx7PgInPLuSBR3RbF6/zkaPfUhRoKVp54nRP
y+NoFgbRkcNBMtNB9/dVfcbhxWyir+ufnb80mcRDrGAJcdRGV1aqGcj+c+fogrlKC3qBS/Y8O7rD
hOaBDcBFAmtEgRQuyh0nz8/NC18kthMfhCfoZelXbnhgs9L87qCANYo0aq7J2ipRx7Mrz6dH77yP
9MiY9dqE/oWeJVYsyOOINrgghvgqZq++4mhctOTazpGeNHuYFW2LMek2dA6Zv15BwHxxq28qczeR
0YjnYDj2tZl+2FB9jZ9YQxEPhVqAc45fPw6KLLeSQ5rFb85iNjBKfkUPfyY7Shc7Rtxixjj9h0A/
FHtF/u3KTznYWxDr/Ca7rZDKgV146pZhSqkhjhvfX4t7//lu2E3DSJOpEfS/8IWENiiM/gZLIxK5
vqbNK8T309cXpGq/00SPX0V7M9sAP+riFbskrmnuAdZUU3JxXJrSej+8fj1hqpUE/yXpa24KL3oM
qMv5zZ4RnVhMhnn4cxeoFXSLbFtJg49YeSCcWIwtoJoODU9gzelF0rRhuu0tCy7aXh3v9Os3oJd9
e4bHHdg8MMKzkjDWA+w6ZGaZIx92F9n282KUf0nbfqvQ8wMTNWa5k002YnOFviVw61h8+aU/+z+1
OXRKQe0VCSR/f1pgxSYyTBHmUoM5u64MWPvQgiGV2bPTgGd8cW5zrlZAu4OKMsjUv4wKU6kYhRrC
xvmXLyvzuQG8+gTncDQpmk35N+qMj2HDDKLQxcXeFm+Tb2Relr2vUMMv/rIRajNhvw9bwwFNyJRO
u0k0DNGVRD7aiLp2b3EkT34WlFqPtRGbA1JFQMPQ3nRnLbVqSBdpuALcLIlfGYKIsogNh0Ocfyx3
x9UzGcqynWuhorwdNKt6vvdP8qoiIKm3oMfWzkDGh3mjBPf9iDAgMECbKYiFAXI+1xCc9jZlCmoh
IJZkJdBxR9E5J/G3hRVTk8lNdmpESaGNeLkw+KNd/xpN8CxoDb29v0tvhZKf9LJyAelFUy4T8WW3
/4a4aeMjlmn5H9bwol+UnoMiwOiiXaGA8Bs3DKUUHhC4USNzVmUufpfENLSiMzUiFTzjJoK1wO0F
Z6kdh4nu8i2bSe+jv3NqUcSh1YEQb+HxamQ2V+Jxzf1FY8bCNKyZsrSHy5AAFG3Cx038lPaER9ok
mJjwv6NdQj7SSLLH4BDPydmjyojrFYMbfQaS/bLyZjfToouGAEV3/CIzqKT/pAVHFVMt5kUepOYc
m92o2ZO9nLHhactVSifx6aRC2u0q/R6ivjmI8f9GOsCjki6vV1sSJmJH6dM4J6JFzpQoUu75V9Ht
9A1WMsUZJGMNyOEQFpmPEyyjxSyDsQw4vh5cnhXyoXZ0aRBbwyNDA+uVX+1DzEY0tuQ/8B4Z+82R
aAlWcj5dteO0j6s1HvMMLpFhKXsODON03WByFfHPjQiw7ybMgif2D05kr15VM/fpCfygH0EV5YTs
pHLVJlCRQcJ3sFGmYsuQqyFtBQEBaKUpUDiI0E3zg8LPr67ALWPWGMijggQ2L2gD7ydVx/qpxs5C
0wDG1R6ru2MRhN5yHsTJSO9i1EZDoM7P+CHx9WQn26ZVn4mq4q2S943dtfUMdriuZRyGDEdYEMba
/+di85qch6QsIZmaXsJ5zWlOZ8FxcCV9y6JCfObCMhHfN0Q7qE1rag1dIc9FawSv+5UTs8RBmPLo
QHlpx7qPi89rDFLAfRGy0ELVjfPRflTTcsXwysxbKnvvRMM2Ejx58sT2HqWWpdXbcNNyoFU7FWpC
RvSfEjSm+4bEJDZc6evkuFT+PzgUjMKgFMOtGQYFyQTFQDmhrzeRdHj/oS/ePYe0ZjBSEaTxX+/Q
0OlkjbXK+bNMvEJkeXlIJHhncOwuLwOIeBQ8CRayUt/BkwSBUk9m3zxNWitd9XqIvmNP7Mlsb2uS
HEMkFW0nbC74cmsDdK9JQsQD8uk4CNmxiySIDGeLLsDE3GYKr57HqY0y6BtdXx2mfbHlReFO4hbl
jjlMvNNyT82NMZsfdeV6BC2JfSTMBpWEW2NQwcnWKVo4ZpUz3riX4zg7bKtceQWYXpEjJnXi3Z8k
OiP6+pPOLNy+sKv4MuD/NYGaZWAPcR98KIYlpipLnapuaEmhcIT2n7+y+m+JA/qqUrsxNUGqJJid
KWungk3uQFKiLPBA7VZdfzXW5lr93pCAZlwkKMy5rNpnT++wgQ62esU5R4bVQDBRiqBJwwXgUy2Y
CQr3RpiIVzczcdnRQNJGYvq+RBMxJVliIqU+4ZMabXgnYozTXrP7BSfzCErtPnx0Ve4utW6tml13
HbzoPGXs1+U74PhXqEJ5VBeDPcABLWo/t0uA+/99DcgSDDs9ZaSEFqzEc556DuwOum06Dgsduy0H
zdH2aDETAJXpqHHPmyr5ooxfNJB2X4NcJxHdeGD8jRrwj//5Hu+55aQd116/Bek0BTWPe3GipaYx
2Bg5UHcQy55tH8h7jFxMAa0sUEf9UrdJZYUxFb49yi5sgyfjp7wMKFfHeTT5SMo78sziad5MztJU
wN8JGr2kjmGTtbNDjnjQ/zhcDMa81RrGNZ0xsdjJp+FKRQ4fTK2vSqhWWrRkyhNnL+YXtLa9Hj1i
JMKQKfBbXrXP4xLwhtREYvfwhSdAGj/Hlc2nnnevVpRBQC24QO+054CnnjznddQvWERZcM4HqJN3
V8dETt+kML4va3n2GanPcnJJtr+r7w7QYH2XOP/BZwcv+n5ew/B5GrhVxciOgqDCLVAdVbOcJXO0
fCIgxoHjM1P5b2Mij8qEk+6P3pF1wdMnjXUZ9clgVSR9mH9ltyCnTOc1mGhZZ/Z3cviRjq3UalQ8
RZHu7iLTc5RHYKGFJHZhaDwZCrU5f7qB3NzqCIXUo5mRaIavpZkvZpeuiWY4DdjFbB8/sqBY+zmX
bVffZ8KKqYrCLOVTvpn1KMtorprwjQ6DYtbVOCorkmJs7DpmeMPk9uG2nEeux696PaudMRE/Wby5
eQFSxW8sUpPkknnAMH2Vv1VKh6AH5VErMFC1BLS/dpWr0Q776pT0k6inRA2WByVDrC9m5vHz+wID
C46rjZC1FHlRv98/lBztCK5s8Dqk4u90fMoKAn/Fy79leVTYXsbJupLICXhV4st0FkVhMKxxm29l
4NikY/WcST43S5GbsGtYZtQ6Bx32jkqVc9Yd2gGVHdCNKRLviNAeCCzmUYelmrwp55De6JGACcnX
9bEljPaSQ8BdqFcWRkElnHBH7uYH1ONusHKayNIKQw3N6SoSibMafIz8mJ4tAiyiidVwOhtzTSU7
hpk0OyTeICbYlkXXoMVagdGBl44lbEXUAztdbaYsXzT05U3DTkLbHuz0JVDuAwSggr3rK3mIee+4
3HXa0SK+gvMR1DsDEJTNsClSNN7Aw636UY3NOFMEp+E7Y4ef9rfDa0x2NTClSJKqNYK4i2vT5Cix
7yxnswT0cvJ5z7L9yu/GuCxhzZWPz4N4xlFSroy/ieMaigUmb63Q+ESql1lQ8A/BrHnrtcu1YETp
mXBaWrnYmdXWStEOBvO9pP1vcwBfeFFcGa+flmIQ0Sn+bF9J3wOMCqYF/qEZwhOqXbdd8nuxgyw4
XnBQ9kV6CX8H6yWTMVx9H0wrBXtP/j1Q2exOhtpMwwShdavfud4tfwEl8PycDyPaveA/80TZGCRU
aXQPtYwehwjwIH+N5/Xm7iPhZtXdQWjjHv+CPTSq9WR1wyJmaRYq3ULm5zuhqPqptEq6rGpjL3TD
BxIVZRqH0TZ9KSMWyugNflWGK+rjqjxxL710hjxj8EUcxv/N0EIfjkeH1rHwqJr9kreVuE1aH8xt
ocM+1y7DNik8H31Wtiw5RuPmS7oj0ZZON7M93XTOgAJUXJuwl1LZqvi/GQrVbg0OldA3nmOlTqSX
Wp/PdmfiE4pEL+WQNUmjzb9LF0rtUB3mVY1dUSjXERXaTz6DnGhb1INveaewxow7sG2tUd1r6+vN
V9vyyBtvVRgsn7rYsWhBTiV1Rru+hfNus4uVC8j2Lc+5iEwICRfChBkHCpE8bfkHh5OEVOF0mQaY
jEt++z9htUMbNDOmeVczFE6SV9ycZ0Uq2E0cbmhDAz9H1RAqZRgflVVsP5+sYAoaUKbrpS/FSKxt
6w4v25CoVWskDzAm9ODDyKvUSFFRFQMq34CNEt6DysWwtBJ+CckBVt5SThkTZGc9hhDhNpqd/ayo
YGscqTAjKGrD4mG2QEMD7cm6TjHvhaFzxSFCPT4Q84fPl0g3cT4ajs5yxAUdPkcoo++kDN+sH+zd
y6G9zGacxwK4c76EI1xubQ3HvoxRYARcJbk1EYBnsy6cyneD7s6NMT5yDTIxcExVq5lK6yu18Kj0
VRk/zNfilnKlvhl/ZojpBYOxQdE4gIfUT6qnDL62VrABzVs+7ArWN1B6j3JcrIajINQ36GYiTikF
sOO8mxDdFpk6t5dSB8qDW2pjmco1bAFpN9b6luLkGm800uSt+/l5CYH9+HbwWgpy1B63j9Ky9zh/
giKJLDTvRTaJ4Pasel2WjUX7VKF571U9gpwpjPnIkGRVcxmTJ1JQKzJgO4LU3iZQ7EZgQq1Ou+xQ
jO14L8sLlL9KM2Y5HphZXoLBcbMTbSDRyfjnyvCYn9dUjIyKiQcgZGBznFpXiAdaLvd/96lJg+du
M34h1XzYlfuOkcTFJ2c9QbESmwYBbtJntHZplbKE/sMqmvOzRfTV51WK0hiXIlK+MepQEr3KEPr5
uFoS3vdqx6v3y3oDsEdTRkXmW5T0yfLF4/ttv2T/9MMpxWSgeqvNJsJyKwbiZZTm1Mm+2lXu7guK
/O8mEFVI4869+tw6Xr4IuwA8FTD+nILqc/anmwTa2h0l7X7npejKb5fMWIkqaVc6kXrgrsT9s+LX
Kxk39k9Ed4KBF3cu1pWNdBjbz2SCAsYzqEOrf0wnI/SYEE5MlI2QZxRVfa/aI7MdnW1AfXOCv1u2
rznaa7U+lATL6ptYwCHWMc6ZXyTTViUiViKUBNEgro9iUGfZyfmjs0WeNeqrPCWRuxlQPMoRs78v
Y11R9A2OwRt49tKXIWHlMuW+qEKRebkEXSjnRjX5IZuBlSycjYPMAOgcYdWRPIvJe+UtZTwuAdW+
d7nuvBMThltQwv66dj4aXGsGS20GmaEAHbhvxY0O/cqKc58VrFrKXUB5DRwrAnFkl3Rejfrr936p
3SdQ2z5tSt7WT42mI2x17O/tMA4onff66uKjkS9bpaP+6BL1uWuwvPpXtI2mHWb1bkHPoDQx57r9
a670/6KtBuVA7Kk3cM+M0VHPlZKmtOSZs/pbG/A81Vqi8A+rvvrboFuM+SQi51ekD173wnnK99k8
bPP4JFQxzRnLtGeaFy+Q3CCAmHFflwHAU/8JaVQoIRFnTSUvcWXYIgTG7JMzvHD4NzSpk6unkUdd
DPYG89dQjJskUqMpAJqcBFVlQ/l4516JTIo9R7ah+FeJn/fc0IbHVEQC/6Hq7SUPaGpfjoU9V7s5
I6eyH0rP6LYFMOgX27CjqcwS+5VeKjr/kTPGJU8nynwygOvUMbj3HwfLvbSEw5cegYhk2/fhBLQT
uFSQDar2yPbbT0Z+ScqwDwcapOiy9ErqzO9yVVUEos9MehoI6ik+sDdGZFsMZQy5wIqZLF3pdsxh
SlYYb2VIWf3E9YTM1qzmoG14qoAI8+mmSvi8zqQKMNTtR8c44Nvn0SlPpMw0qq+NX15t6cpxtbDl
ETVlNm3VfXuazZcJqG3hiDrE5keUlQjn/JFL/Gcg6boq31uySaphB58w6bGzLQZ3W2eI3wW6W2R5
3pGEYDn1ImLojmBSXoDvDu4t2nVRJBb3mtDDaWP9w3LvX3ZsLJ1rsytqtMF3+zhehnScWf5JRN8l
tmUC0rJYy/ynSvzW5r4YtvR8FTENqe8ad6qU0Mh+TOF6pSwJza9Hv0wrM+8xG0a50YDPUThL9Lmb
yHU9WfHXibn3nMr2M3DVNRHZgBZf9SG87m+0Fpka9BOtZKAGViF1rJ8RG1nb7Yy1nxAvi5ijJbYE
7I9cyO3EDIsHuv1HjMiHMkX+tpQZxK9KaxH3zLANhVCH8k6bXzO5XczDa5i7i7FfOScvw6TxCa7G
/viypCp5BOW3eCJneyXNdZfjglTedwcXOyYfiUuNARVLmJdaAUkTRpfWm8KgthcoP4LC8EB9bo37
TCrb+TFeS096CuBJyAxVWkhetdEBYLBQCLGwTol+gSvntdQ8F7SngDY53H0AF9WbXokJz863MyLy
UdB6FpKIyiGW1BDhpepKa9Az3vhIFkFlnRGLpOU5oZn57HmyRK1MQ1+koecnyoxg35QEIv02lkeg
VXgdwnU5VTZsYVKZGsQz1ld5SSEINZkp49wzE5uue0iqiOaZ6b3CmlpOQC6OQQDpF1e0gD4bXOlQ
I6ytkKxOrZ7PLaBu2ZLyvvtT4T57RbpbOfFHVz3BZCI6UU1eXBIPCDK3ny8/tRJfKBItNvqMZ1a3
hkwzarqXlyuAaWvLjRlhTXs6X2ToYhDv51rFlRcjToBbCqI4uvpU0+bY/6PV96Ga8CYGZLAgklnJ
vStspnyXNFmDK+d8ANOPYTfe7VCfjyQiQy4RNovLoWwAmBBA8akuUSTw02/h9IDDlixNWiFHAS0N
+TNHxiyMuY02QPUKtyGwP78rjSL9ch1X8+OZ4a4DwCyZyMeI4JZ5zhCuL7Mrew50O20b8EuMAX8F
E+cxntCzj+K1BUB3GZgE2krF2RZqqXiYZYhafBon8Z+1k3j/YoqhMYamv3FTN4XRk6lmktxPktz1
3nzBFLrKFYAI1ptDbmUTiQPN/3SLd9aydA1vXh3CKH7YNMvhGcfcbrGV6u7b53Lro4tqU2OAfKYL
nyGaUBCQh8vrZNLqGFav8/rF2Oo9rWvGk5DtLyJqG+UKPkgQfx8GnRgLprYoC8VIYwFfkMD/AJQR
don2W4xouRJSTfYUtAoz6n3o1z9e6hq6paAFJ2B8m046X5tY9RYWxewEksq4mX+xN8Akk75iuNBu
EnOwWrXqiCW9kyw+u9+mkcrbmRMi7clxnhoS8ekXmsX2RpRlRhXARwlDPO0aDNiihOIybRnpgixj
m3fcLR5f+sicgU/hCJ0ZVpHPeKW3WiAiyq1iwTaye8QlwoE5H89LocuNmpT3JRuKYrVRZ9ddC6w/
ZtiQ+RfIp+sEvXf8QTPNaZlAOuT6J3zLt6u4sDdNtqjg3fQvFLblMa2eXyKSA5PgNI1a4D3i+kVC
kj6hJC/WLMgLxHCpI6y0umWHPWtbtqz2JQ56iNYoRU3SPCj9gkIGUmNJy2N1E5n7Z2962iPfzma6
TDSnfTVE3DDgMAZr8NJ4HueLdRCmEiKyPcFJwelyoKt6q50+BOgmlGvk+wnV/fw3OVV6ykRUpcQO
j4CGVmSNCvczcVjCjpMoy346Dde87cv8mb2cOwxTdwT2uRGMgDdkOnWHJMXwtZ41H6dc95xk8id2
U9oL6tDNYVGGs2m2N3A/PSsxZMtflH866Dq3ufYXA5NefcaHG+3/a2StKa3VPUXywCE757jOcLh1
WrKiRaF3DabMZjZO6GqNMWku4zlYDb8ZM0gOtJa26x8anfwLsfcoNzztrWsbZ/iZX0ckn+AT4vuh
/yJi+hciEYxMF7picaQk3R/A/+OUSkVD/Uq8umDSN4LBGJCzEE5Q5IyQlcvi+cEUW6EQC7RDvC3K
6cK8WEKWHJM0uaXfCgaUqFiqikreat+QKXXzkBXmsPfuYM5fHJdz54mLJCbF4KkwN+KYecXkGge/
R0GKrL+GiQ5hhCBZm/6lrRy0NcQuX6Slw7QZjoK3U2ek8bwJC09DZENbhgFLi6CnEidtyirvjiiF
cbO2J2yx/Ca/0TX771Vv9Gto8WJTNhaJSAJCLYwZlFCecCiZUH3YqYTKz/yYLudIJIi14i3vpEh9
vnXko37wXv4Pr9aN6qaCU030T5C/bSJykNyNvpzG7TOCgEvZCntZ/Wmm+4fTt6bce96o9nZdBxyD
Pm8cuCbDUoer6VZiKDzh2/gCKai+LVGsW6Ge5dVIFf6iSxrtf2bIpM6QL/m4F84C7FRyjZzFNffG
vKb7e/McuE8LTPIZkLsOI9raYt0q3Og+D7cPXKqAPdaPj3Zf3MjsWeX4PIBtQASFM7w/Hh8KqTfc
Ay27t0nr3SebywibMoIi78MlJ6kScGeJKd5wpO2DQmdbviJBKoepgFMjRPKNU4fZTZ3cKdWVmiS8
lTwwTLRxwa1od2L8zov6TMnXxlyLpLaB0+tddP/QOvkB7+h0iTdGyIOXQC2vS1n6x0j9bEMLaayL
s/Tmpo9vSqPD1nk//itvzz8sZrkXfaD9KPsBBOR362i7TUGb68SQ2jWOA/h/9TKYLQ2WlOUQcV8k
yPV7NP2XXQtNxlOQnQ1qCVMy95AZlUUANcZ0CgjTMIuvsL7sqFpTMiDLSypvR7SF0ITuGvwgO8mS
BSUUszRiIU55Gr/e1w8C6X+L+8sAINxgw1pDXdXSjDkHwbCNCFXMSz8hXzhvZCcZIeoJqVxRZgAP
J54rnM4sJ3RNba5BbgRUvkLsZH2afe60Hh2EPSQ/y7LSVVlzvjabcaXhgA/kDak1tNjg2SIV+hh6
nXr5Xx1Z4KK1tlbnBixfDZzn3XydfDqVmlqvQ8vmKNP/tASHDoamQBJ3pnWrzZ/yFHCyJWt4ewyb
8qH4Z1uAVaTPNdnfC+0fVneRWjryBjH+/rzZ0zX9KdV0/Cc9BxH5VWzNflDyV9x3G16rVLwg1oL3
v576aQQ74P8A/wboBgCGmg9RYnV9hhx1QRV1YqSUJxyQ2v7n6VlV2SKeM2Qfzk67bMtVruHgWzSv
BAYH7+YaGcYZmrsIg9cW/OH/LRbfjlqd0tfpJlaHoDvqXOmwVKSjSGnPFD5FbuLeP10gVGPPwsoO
ly+frmk9uMi+OpBSEggHbOQF0taesEmVGRMOl7l4d0O/nu++ZP+3PSXZdiJO6g6WcwkOyjjb4AdN
a4PL6BL3rQi/b0SMdoRj3IU5YpyD29QAd8Y/AzzUiQrrau46BTQcvZQfvHKGj1KmLVczTZrjP0AT
cVW40IBCUkkK3exl+H49nB5bYC/JlnQshL4F7yc1ecqAGRPH+XRkHGFlfmqI+Coc6MUo4NC6HGs5
WlNN1/tiHp1/YdyCYB7QgvSZcweXnJ0cU60O9UKVniFkkS42VZOlRzl3wDCxOEwAAxEs8co8+wP8
01YPgtg5/GkUASRc1GZr1mof7i/xk+81g/9DxlJMtUuJ2c5LtGKxCrirI/jgwQPTgbvBSVMDXNkS
HND9qWqqQLGS3rTxJ8p76PUcbFvUxinLpuGBKjFW/dtYBItOq3gwW0HpboHm7oyidMMZ+LD3MVZX
xXm6UjGZ36BwtWJGfBZdVfkry4zYO9uG934oi+Qw34hf8/9PbCnp5v5DMPXIJHX46dV2niWjH2rT
TZ19PD1GOyXfSQV9cYkr4Drp/u6DPp0AAcHmUwiGsWAP4hSrc8hT34Uzkn/fCrYuu5x/KyEdpgUi
CM+QjFKPHYNDMlsFZ+OZsp8Y+XV93E14jK3gj137coyBhUSjSXgosSV7btt4BJzpq7lpA3VVFsc4
G4jvr6u7BEaZiHnBXe3Nz2cp2Zjpc0B5KhnAPZESClyyZgrECKnVF0dNLZmfmwESSNZ6qjByRaHs
K5ujYsCdxGVo9s8X37kst0rEzDAv8e8aFXi073fAYct+jElWxzOIf8JViRz2wizZRBkdVImNbcOg
FOmLfy5c6k6ZWsAZKa6G+0+6AViGUDaVaTbfX2HBhuK0AfGoGK2A2Mq/du8I8s2dtO5gn+Rf0DRp
QP+IumTFDccTzCfp48Air321XwhH0Oci4ZismFARpM9JJUPf+8MG3xg6i/AZjS2dgrRaLNQDy0WM
APPugvcZmoUm93QS6RgPiByD2rvteoea2zHrS9WcQKf8B4qiFkjhtlRkiXHflKE5LMwQ/6UoR/pe
BaIUKRmWr6eEAZx1zZd1LGmQUj3Kzm8AaF1iWj9QN2zOJGlQEn2DdQiV3N/vz/nF5Z5eliFZ+xwJ
/1R6ozFnKikFUhFXRunIRxz8SAuJrYxgMMxH7UHSAmeUsy8Pk0zglQ7ZDeNX6bTlwLZJCVD3vbiD
F4cRqw9ykNQJeSAAkNYx86BMnnmepqKLPZVS7hbJcPaXogknY4j4ch0fJFQqUe27JvZ+6yufLC04
arlb1oD0zy8e7ICHH4HbxhDxihgK1Nfmz7MKCZCI+GkTlM07BGH/F7XpwkcFM70V/FHR2F5MyHg/
k6n+EftZQzpv7gd7N+q7+3n0+EIhSDYATHJ2Zk+kpf2950vpCidPI+1BxIKqq3Pkz0YK7UFUu954
oG/T5p7pIpKS9gguIqUGV1e4bK4/gLk8oAVSJsLHPUPR4mGzq8g+Et11BSZoAkgGWVNkdyiC0fMT
6kUSIOb4Mvq8Y88Xxl4DajrtUHbMX1gHZ57DU9MM6Rk7xYjlh8FSw6ezo7E5hSN2IutXz2+z3mkg
lnHhEM9bFzfQpjqBlt4o4w5AJWq3NBTuf6FjOkLk/C6LmlWtq4w46m3g9NXilZRWUuYJadzQKeHa
Y1eePXzwjMoeSKahe5G9wA0NbKn79/lEefFs5MBi/518Q/0wiEyU/dZ6dopdRu8/FDembnt+dMwO
mp3MMGm7QAebyU/xBfgeBNm5R0EWyRq71XimEQEGXOdZOyTg8kTWtNX0pC5Nk9pEdRn5Zxy2FCKp
mxoyPFMXdbTXod3eWe03zF/wUTGFr0ec2JBYRh839fy3lhXhtjhcp6PSabHE5yFc/lVEDW2XsNkZ
9jvFfHSOS6hcXrPIGQKiZ1NYjFFGpVPSUXfFFzjtFCxKHQsMyaKQw6uK7eZJ4YnxgcK7WJzrUQWO
an/oWhOhy0FxV03D3L+xhckbm/hFe+ehdxJLrXVh34L1MMNesWM7yrGDshaTY+eXNxuP8Ks4mBDv
h5z0Au0YjlXUVNLvpTv0FS/7j3oKTNE2g+9jHXMvovGfcbfmWkIFkL2BxYng7WY+z4t1dMMNO0x9
hc2rywEkrKpB1YfycGMPkHYT0NyhIv2EyNSDsciEqsaA4gM7svOaAgHO3JoAASFRP5BtZn1HNz3D
16FrnctEcR4n1PxH5h4vaXWUc82t8TaEdW4JgJ7F+UKF2ZgZyfwmbl4eJ/TWQGPztxZJuOtxBQHO
AP9Go3sGFFGewGdzfDAiNh6CTGrZaPIqB91MOap5L8d+myfacy4e/p2PFH7u0jWyT4v5AQsgSjj4
7fkuBW+fb9/kZT06sPrN/sigfmtv6IwoFyT6xtKW3WN/iykTA/yIOHezaEiOy+0vqNOMvzsIPPD7
cmr2iR6JQf3yZ7xqyil1cT/8/JbxxdAn2eH+l3discGpO/PnW9GV6u0WJU+3qG+mjWOBbwEaCqZF
YyF+495GLr8+okp6e9KbgVrsd+FlzHLrBMUUFNk22Ka7hAXXXgvszM+JY2YbWGqRrTwMa+SwkisJ
Ph86c0nJYnOQ/Jvr7+EUoj47TchvebVoJahg86jkr931Hl8CbNywZ2w8QjrLArzPJXoNkY3+3xM0
5u5fRUvfQ9T8HRzK8Hvs3wCYtvEY2gGUCmK4IWk33n/urDHm2goOS1XDQW1m7p0/GYTtC/tSW8kY
QB2pP6Ql9NE3VvsvlKtqG0Mxd0bQ9KQHZHVbLR6pNmvCQCdMfJjoyrr80JSsaiPiRr4Cl9fnIFMH
xjRoEl1gVmF2JVJBjF/NM9fEz4eOdbsv4R8WhobsC+yMm+/Ee80D1ksMR9vJYC0abPrntMdEZvY1
Rm64ONiUu9KbEkphSy07r+RsqWHczKG4WWkJOctINj6qZxpe5H1ZJGQn+ct6I2Q3nHjT+xKVrSMN
ma3/Fh6mJH23nZOhJ6hVzRFCgLVBtkPTfPgTui1r61kwLrythZDwfvMz94pG++O2IR2aQcSk1+eB
Vao0Yw7sm5Th19TIZ6gxE0lNKl7juxnxJkavZqMTNfsyQN1adY0KXoTj3kDjP9qB7/B20ZpEWFpT
PePHx4F0qhe7jSZqu2wfP4Fe9ZKOx0SNfHKRFhA37dsa6sznOZFd/9aq0KHknTOpFiMxl58VqA07
N6qV5IBlU7lTWy3TJUUyX4H2ecp95dj3U1SjKuJ76ChDplCN5e8KXy9rI3+gOrg6zqXe/Ki1IAzW
qUjBWqN6dpyhnF+iRp1pPAnGFAJ2qJhNy8rER9fifoIdkONqqlLFhXRmhDD8hOlp1LMM+d6Oe4ju
Cg1W1LWRJekgkoh7eTOXnnsvTxl4gYM5I6NR8kLUw/yu24G7WuAvJa9be4SMN6oLiHTK9lVALu8O
x/1yi/c3GZdBUc+4MKRDen7MteykbEwCr4yZDSjYctCN/ANHSuBx6uY100czwP1qS0xqa8iXitq1
lyUX+aWKGQe00lheZpQuxaVelyWk4zfOFnSdWUQxg1l/a+4H4B2+Q9PhSDfL6tYqKD0WZOl1cegJ
fewTdLDmCWxjk7cQRqYNn3hfBerb1tKbZCVmHarKWEr2mW2m5+fphEzbExzaUsN/5SAlm1RpaqXd
hi8Zz9+Z1jlXVbbkjthiOMqIWExQGkHbSE+tPc+nUWqji0vB+b8SUZN5HE347FnQXdq19u+GZLp9
NmhwxonfBbenEPbLYkZyYqSq6fqBcyRBAppFrU/N0GV4JxxW+0SHQymbbKnCELAI7RQr6rm6ZQqj
R1lOYAtbbKHMBNRSqStZpgu/RpaBBiihl5QBfzUh/Gqu99sxDVW8lb6MClJ2JD6B/f+YZsM2jNBN
bCwd2/k3xvtl3nyt/vhf+lUUU5jf4pl+QANdYL2lCIKxoXgKzsd2wJcfw3UbbZfamH+s6PwmtUpA
Hq4r+zYBDFLZZ1z/S4PISzvON2B0JkSWmWtbMmLg5HW1cCZgamdJUZj+nZx6uOIwaRqQXDfV+wyb
O8WU4AW5bymt3nqTiEeEo8wc1ierGgBmSLU2ORRvwo/Q4YRz/+CoDt1ek2CcgkGIWlc7m99wKwyM
kUKp0npBr5adr6REFAIyEYNfiA5j+CntRuZY9/rtHEijUSMGE2y95KPBc3KvZKwr+LPJVMMA7fcU
KOoFBJ0ujXtALZnIXHSMaEFOBlgdtPbWNM7vlpqWVADjnkCajxsQAnYAGYBwgYkd94/T4bpEhSXK
cBfY5Cocej8jFzOEYIwOMgMZLXwxY+aBdE6z0e+A6qjESu9EDgeMnF5LbIxgmVsPqMYtqRbl5yPj
RmxJicOCRe2FQ5ZsVQrfxGkMbRo5/3zS3xiyS4fd3IVGpLHsHkH/MKBtYazLX+Y3E72tap4k97rx
Z5yO52bxCub4onli84vX1wuFcVaVEzx5e77Rcpr/CsjeAwqjqEB/Jnc9QPi7elfO6w+KxxAvZDsg
za4svW1dHOYCDm5P4kWpx58vEJnzL/I4TNtHTIm08GX/8Vm0nGJFLuSrvg/JyUSy2KHa7LHWHtZB
L+FXkkgADm+ghbsX4Ucadfe0y3oJKIPUc5idyBF9178MPQqnQuZHtJp2WJ4jp2FC+8R9F2g2UMmE
9zBvW4y2vo1uIOTXb8giqN4GihNu5h8woVVKKxqhohl6QO+YtIn2c9AEQWSk0uCzqfGC2bx60Qo+
LMcY6tcrSMC0mdpYHaZAb9mCF1t9MLye/BtSkMl2oTbOMTB/mlVCsBLt+WZ//R68uuTCHlHmMt/K
G9sAsP2lcXuqyDUHYvZmIr8qlgtQoAfHn+wQUAjuaPYjMxq2MUME5nA2Y4s4iDllibUogQ4mSkfK
c7sxIedYke5SXYKHeqliSISni1ZNHOxn5VYCljD6VUToQIYbTG+CepnC3IC/9v3q1kK73td0h9hx
SNAwr6jfjmR2vsQeDajfXHY0CSjSewdJfS18rqvRhmUIA41mEhS3OA20Y96bcPg9qqzjr9uRbuXE
0/ML5Vqw7URac0HR2JiXQbDgDjqEfgOZW8cS5nsOsjRUWkOQiEHdNwuhXTEr+WcUO0j2Qeqh+u57
1M0X3qIs2xfs1cI1RsF9mAL9gWD/Fo/rCXz/0dLoXIDMwXehwfx0mQidCwqwactpE8BJ/4xMkkaS
vD2WK3BhEQts7/jvVb55cB/Lemfa/jW4XCU5n7chXNU4qOhcsL8PAs3GLl3aCKwWnxO4VhdBn/Ig
17omI6Wp7L7PIsQ63s3tmCjwez56DusvhjfhKD9PMdupSVKiM2ckQLOJJU8s+AA849WZXo7JRMSM
4jIBxknLHuW6AjnaNm4zlxcc+7mnitVVTsy7JpDO6JtkKj1KWAJfDUR+uWLWA/V05FxPOCUoNrP3
H2zuwtFfWULlg/yeeu4omrPP6ljpK03Y7FMo6wQu+RKrp0A3hbl/AbtA27xFq8Dki89Mo3x74d1N
A9244YEMEdWgf9HkBBLAfnn68i+5RdkWpqs2zWJfK4xCeL0CankfnF1uJLX8Ze4fd++opmsg+UyV
aUak5WbyHInMWZKw0qWBEvKGWCBK2EluBVljvtaPJmcuvNf7sqwFzbZ2R4DCvTVIbbtyfuo44NRB
5gSjW1PC7kO80KyDhsE2Vu7e9MxpNDSTjHE6P8sNQjWf1jKPl+MBQ2i9X2ejMM4Hg1TCP2x2/Ruo
7T680N9HVp3TwwEuI6yt7Z2QREiTQ6J66MRqPmus7wx3xXuEjTIyEIOWBb431zNWdmNEY/YO/3K8
Ebf8AegPxYn5kuW1nY0Cl3id4mU9R+DNKIdt3qMf0ITui6k0mjFs/4JBGGkk6vQzpoT3V2d+qTVH
GGb47JBUbkoUNcJ4kw+yBhsIkxEezGkb2AvzMflRXtsFMdqcbbbhrtbv9pA94Wi31tiE5P5tBeJU
9GPYVcmex/FuaR1hrMhrG1l18LE4aMDSg5ytjX6q7EDnpxrcAHUaok8tNok9pQ700QND6LdMrDeB
tLmQRHpbfz0jmk7cj5O1ICo+k/IDyY1p/y3LWKDv606q8F26BsMFgcJ+NUhl9Z9I1BbHE9elw+GW
c0gc+MOWH8eK2fCehf50xuPHnN8+depJf3eG0THubYUqKEZav1SWF7hYujEQ7YO9UkMLEq0GCVBL
QE6a5Os7V1zHTbof/LpqMZFFJNYPv3+5qRN6GGof65leqrzxyQCFXebNGcP50Hu1zdIhaBRpNO2X
pFKSXvRSc8DfRK2t9hTtwBcOdbc+1Dgliuf2BKNgKc6b9J+tnkgD1RzdZgHM0cdC630Aa0LlZkO+
Qua3haNt3YBjDAJURz2bg0bOQ2ewu2caHEwuykwNleOixQNTMHBpbMdkaXN6UiPpfz3JuBb9IvJX
p+KP1zsKgvAbfvY5uNZlmocdmNbcJrAb5kW+ru9i12ye4jszlfLAevaWkbxM9jAaXrh/qGAi1Saa
AQY37PqFTKmCYERrfkeyuEdXk+bj5F+HWUQiTX31tNwebH8SkQpMnhllB9j5UkTa9Jg2Uf4QXQL4
OiGvb6gZS3l7/y7FJArHaf6DrG9kBLeStsQWoVTvx38RwtN9zgPZ7R99RG1MjyXumU4phogXN4fF
beD5R/xd4b8ALI0FpdRmT8wdKW2MYzo7w2acQ7v5rwEOkBqYmNMcsl8lfJGr+kyDzspIDzabDaNG
zGi2LVC2AlSc/Wqia58lEFMwa69zA/glRJDo8AjCpryUz8WEqrxr+HW8dHR8I30ZZN5BNSNx6FHa
7i9ocJlKc/GqGEnUnkcnjZWvsBBG9jyIXyG9rmIHN+XdHWIqhvpJOPQANnXscAcqcIV/Z1YblaT/
ZvIPwhRpRooSTbE9qq8XIjyqTPLBP+sEw8VzGRN5Kj0eGmCrjpAzfJFyiE0xOle8gIUrC32qFEhh
kfVMyX+LB6IXqQv+8qVzIx/TI9UIEIv0fmX4WiZV1BIz7FrGyfi+DskbWHNKbJbFO5Vu6bZaUoib
HGHAIuMwU6N9h9gDGIMk0mE49R1c0AMIt2MhlMQO0ZhL5T+84cGOa768OanZwfI9iUFvj7RTiESu
GM1kY/sdvOhAbk+tv/SP/dzZNkbAHti0skDULAnfNXxwfk5zLJEAC5KxtTAQQDpHJH5SGQlIHpEl
Glu32ImU5BP7BXPnASpV/+1avNqfsWuoik7FNjDib6ozcjxwRAYoRkgVbkBHAiihQpfKBitWVTlt
zngl/G1Qk/RZlczP9YtXYrf2ytvk2AbLwGRGL5XCfpxWGEyz4OdLFwEkSkCa+NozHQSY+wzmprHn
FzXlxe46po3VOk9LQ6DWDfv+n3pl/cC88sQOFK55WGQaeV1vAPuKDMxnjZsYrAQVCkQ6mfp/aGUV
64VmXEX4xVXVvaxZW8NNouw030URJq+gh151pscvC11jXNHnQafpCHC6kGbvBcQ9ZCdEq2xVNGhx
T02qlFHl0bPBmjXlmKhRpHspENOJNwfqgLGh+TxmldeflZIZ+YZPaPQ8kPD8hT+dHAQ3bj/PGldA
49ogPU1DPXSzXkDAopixE9onbVkno7Pt15QcC8FkXemK+ddcpT/j6uVElhebUzsyWSLhRb6qf+4+
MdVnxvmaicah4NzXIf3aTEzdyB3TULAgHUcvCP5FDxs89+YoAXr7NtinwNJYIt+5TjvQQ6wxnsIQ
w1JUPUTgK6gV6wN3dGK9gJ1jUb3r5u/TPSIUbp6GeKnebk5SXusuvJjDuMdc3k2M/6Ym+gB8mjfZ
OFsQMKnKFKinpL1awukkeHER7mtUjLTk4qDeP5yDXoK5ZS2jK6Yyyi3vANryz+eiVxm8Gabf5jcp
4cRRebhBQefjKIM/sRs5PY2JkeX5L87X3NI/JtaXVcAKsCsT9ibU0+xOd05aaBLJQtPq5jfCqcLp
JHaRM2/S3KyIksyjIhYxLjS5SOofzAlUgTw7WafsCdruOSk7t/LAe/i1fT142TSdUwYPQ5HdOdVu
6FhINnv4kkoFPj211fiDNTk2M+A2AT2plbuOD5NsPiJcicbx7/NaKikIuw7hzvl6Vc5qr7kLX7sy
w3/c8XX7ZmcxRFQojdfHXGC+in9cxNzdgHsoBNGR3b64re770cVdU6Pqii76nUuScN3ByupIRqmV
pHKdxvF95OlXAscK3LDIXb9eSLXkBbcNZuMUpLXIsrOR+MqiYu3FWiUrlnfGnQPra8U1x+3lTStZ
13JiNogfg/A7J6cOuc+Cq9YResVZafSwU1DtaTvgAR783MdaIgciNjNY4WTY1A01tFFym0FPz2SI
idfTxUbj70NNIhs3DEl5ktGr8lG3JJikPR0QugyZAf+rXayVrkb0WwSalWYZu7kAe6kLxD4xQhqP
EZtBkihMYwTGNBT9sysvb5sGT0eJwTEl8dCVpb+2aNtZL74Og5TWy+pt8ToUXtrk/2U3VRrIKerM
tAhiSZyMOufZrNYhr/YaQp46ItC0HKCeLfs8Acc1NMxrFx7dHAhtI+QAsop7qlluBWeOhawxvKUH
ZGEffjcVrebo7Lpnq50AVy+b0xTiTczA781JYhNs+OdHU1vAH415yH4cOtWD9IGcpZPMs+ss289+
DOAHoDMdikyTILCVrouF36C722bdCi2emSqrYwVdzZQOHOnpQcsQa9PlTEO6onx6fBSOSC9SddP1
h6qnc8os3IlVp+W417fXzsbj+xLsprI21AywBYMshOvvaTdVVY2nhjJ+AGLSoVNwrvceWFfm4rZA
rlCsCqlysqD8isPrwaaXA2KULslIDC0FKLin0DHn2pF4Dij2FvNXzZzxYiuyq4jMkXrKqI2EmAHM
IMYiOzGsQCJrhVQlx0dRNUA09d2hKfbVcc1Ox1DTEjfBxWnIBd+WTToBBOs13oke3SYRmjKoNZpn
imlSeiTIdx85idHEZoC/IbsjjXp/HadLtTZbse2Ix0j55/a8oO42ukveYAAwx8vIhawZOJCgj2vC
mQVhhpwaPmh34NbHHAmZ65ltmcmxKSD/6PWu+mVtW9jK8HXEJAwzRUKDou9yOA3L0jDldEuhpXtD
v68Td2brzRFUPBs2eVL8YXvihr0u+2LFNz+QNOCpiveWUSKTQwAaLBwhZ8HnwtgqbUdYB/eGxsOf
uzY3EomlMLkau+UF3LldOyRoSjRG6OVcZCdlX1eO+g7MZWm1tNvfRJy5gKiY3jRCy4mIziIXvZbH
dBbR5fO/+lQnhMxussTwSzF4SWYLf77L71fBJpxdBhYcL+3Khv7YUdhCnm320idiE1IdD++UMxvf
LdZ1bJiFoS5J4GahL/HlOY87dt7Dg0Lixxo49p8Q8CbqER3KjYhgSd/kQ3kI/GtAKWLii4+adiVk
yaZRj+8rguC/4uYdZwB/wjzKXWzkjaSVDCdM1UlH2gaO8EPVrJ4spgq1yHd9NFUjkEprN6aUAz3f
pWAJkRFB6yTgJSIWw4WZ+1QbQIxlNspamO6dfeod6qtpOS1fVbbiFZkWAt0LVr0GuuCbwCrUUF8D
+zFKbIkxvuzwPPgfKUtb2z2Y9YO1ThKzel0gO//iz7E/wFfOabpID9dFNkOPgo4G77tBOllfYe6R
/X/ytvTB1AbdWO8Tma59fWiy2tR5YQ8vzurgjF5dRCQb3E07JrzKv4lIuNI1nX8ZJtnY1DlvZJfr
6t/yWPf46h/oZ8ZBQ2k7iB6NqBULTBG+nr65AijHPekPoryUqaqpU6ot5BVxaHNhkjlA2XoPiJ8N
0LJMV7ZcFd3QKtOero7T0EdZg7fxGbu1gNm6MM94hckRG6n8kxeiB170S02T2mzJsslpBoAUTFow
PtA9U/3hzRTWTR8VN1JzMzyRM2q9MieeNoloMNxomupfHy/Ore2eVYmcOc317garAwcUwQx7PKVm
UFlbH4VGnBv1px3IS/8OyFSVjlSPh3XDVXsQYYdhkEieLLHpCYhy1ZXuDzGbD4bHn4gFGtWYIPye
Se6DgaeYL2Hms0TeV0SnehjSnyNeYtYHqL2fNlp4+1Et1BGwshhB+8xME318FIFBJ0QbU0sS5WEb
GH4LB3ed7UHJ9SUXjTq5oADNduZPWcM/qzBbnjtg8lpB3k75a930jLadikvUUnkHvaqTp6tWL3Q2
YhVfKegO91c5PZC2JEFexlYHYrc3PER6B2Y4StXeNi1GlHBQBuCifYYot8db5Szti1mmsj08ES7t
KczxuNbUjxwTaI61xFtTCnE+abMth3Ti/ooffogIXkkumCeg0dFiiCVlSrqRj8hnifCyPnWVMSpD
yGLgiCvnp/j0VoB6JQhuvh48ssZBRpiWiVOFszmr2j69yKnXTOQHuULmAMw5NxDLu2E7Cgu8hznq
x0Bfbxi4Gm5fJp9W8hzO+yBpAU19v6q5tQob3vsblI8RSApsXD3rtY7NUy2022QnzSfZB5KEqff/
Gg8rSNLamozMk7acHOIto4GZ9x2qtz2BkHPiZBHFOftAe0ga5+3YD1hf4+cr4UOGI5HdHlZ2+MUN
LQGbH16lcW/G32LxrNM4R/tEcuC7+isgOE2to5MC6LxMQhXCrhAbeopfrreZkCa6V8RaAejgBWYW
O51dsgEHauZHlWypNatd4a9e8esiPBQNNdINFWtpJKRV2fxKYrdPhLOWD/7QfIEtgrB4sqWUm0ul
odYF3keMqaU7RhF0CXzgiu0F4sSBdXPg3ZzedN935et2tdWd2sLv9/Gc4LVQm1IrUL97G3Ws81ad
7WnAGk/jCyLNCwdECKa88rY/TRcpNZJrW4PS0w/PYkhyF7vvV2HOcZXIcWddWoYlICNLB1BRaoBN
lU+G4/Hs4wZskevNQbKcTbyYXhvga+ND0R/Az3Fkcx2TfWFQA+HWCRXg88S83FLnsrTBQRymfgNd
i/5wiKtNwgY/QdpUT8xLuKrYGD6GREHTteYLqsly26Jd4bRbVQSOEDnPlBCh2CCysGfcpRaVAZI8
edHYSM5DPPxC8yKYOh/5oKvZqfYVWivY0VDzPFFGz3wAY4QtRHCDwppucXw9CIT94WRDgLGQFmCb
Bh9aG652JvnfgP1Y7NHd5MimbHi3jqcxEw6kZewWcUennCeDdR48EWv5k1xYIHLONr+EbGXfyaRq
5Ye4qS9CybYjkwn2sPeib778pXPWqQEbpmWV4furVlOycZf6c1bwiK8Yw6fyqsE5271R8DNwxSzv
KoGGng2N/mW9sc8XHA6JXOswhF7YCMGEmDcd+RtYM4eZz0o75T1NbKi8VthX7YjQztW5kvfHTOjt
kD9+gq1lHFVaewGYNLTPbzjPAm/FKlYmJ9oOKrq6blSasXFHQuks8p2CTFCEQymDiSRjSBiuFoF6
o41rzDARY90UlTSlC0TcwsGNSgMIlr7dRxanjTiZB52rAzj3UlzuSAoZgQuognMmZdyx/ev7+SrC
XTY+M4iwujBPioJzwrEu4BJsuDgUYwrFMHQjxWZF/zh2K4GcR65Ud1NFsrfs2mjqPWEgJvRUuHok
s5u5+CBV8KSzY2mW3PAXek5zTCXbIH8gxk2+AeAtZaWRp8w7PKF6Zc5V2k6Nc627g5v0+7s8RWAF
leuFqEoVwm8I3LnJIlsOeZyzUn+M7ZBmgg0BtkEI0XHnIdF8YkRYsTDAzcSXKXpW8o1P7HBg6E85
EyV+LaOoNzF04IMVnc410Bn5BY2hpBW2SVGBRUxJQ8LqnbKt3Vd9YItgRv5psqoBGcCIEf1KQCck
i2AmUlRYE1UzhzMnxxNcYzykqSvGt0gy3ql+wayRuKICGIii1Cq3Q60RFzOvLJ2Rmfm863/TSRWx
toeQvky+ZT+9aZrSNImA1i+MoMftXe0lVja2PL2EUHxrWmMvubKvIPr/5CIbV9nA0Vba8qvQVEMt
CrrDSOBAd4hMK8hGReA9rnkLJr7tr4kcHCwAq87oUQeC+C9exYc8ezlZ6umIXSBNiAZrXEiiXFyK
krjDUsT0k3IP10EMEVs3e1L9SuiT9PRKelw8P7UlzM0ipfTW7Au1u5ZNpSdl/+D4saw52+Z31h8F
0He2ckygiQso+++brKKK1QXKbcawZTG67QSiXLHwwOzxX8x1kgerS3Hyze+rxKVrSobOsdySuxtR
4fv9Bme+NlBZ+XJ/l7btqIlPQjKfUzvmlpPWmtFdE5WuAhMrtnh+FQSE1dIBgo4EFPfLq4DH6q2x
/MDr9w7oXwT6EsubkbbZlLYkfhFbJS2zGIvAI+MngX/wc6eC+UEMQaOc7XFTBUcIyslI6kux4iaD
2D5GYDM+IU3JBr/UkQu2T+9XyFlELI+bnoZaodt10iEc09/f6NXWiWvRlq/Tpcsti9oU7c9gWuAM
MXVWlYuJTxlz1NY66QJ9p7YD/QRPDCzrHiQnEwt9gvBukX364rOuDca2DIskQr5Ul7E/2BkprHL7
9dw7U8Qs97E9yAyHP59P7hCNkS3Y2Ofq7SuLJYubZLorG2mPqmFhdV90qHMX+pDJtUbCaKvufYXf
HlD8D2Jgt6FS7e4uzg6mHpYcRliHypdrS3x0VdvbdV9nBp4tTxgcwp0hG1DBFrWdSGX/69MGOPk/
S1WKm+DppxuC0DoeZ7xfPKGyvJdX5TUyWrKvtYCOPl5pMdBcvE9UyBSN+CmNKCJFIYvUCNz8N80S
3kwKHShXr0An/TBexpEEyDRZpX71y66hzjtI+Jf4ZaQygtbvGkTEftperbZChJmjaEi/jyDMdJZz
MDlXo28Oc14zjqImJaZNChAlHbZDYgwoSq8B0MzEu/SsQ73RJqOGRFqPei17zROVhmnZuPGt4Cqf
oYI0QaZNgJZH6QKyjJr70clvr4IGWNYJ1vM4qtzoNC6bg4w2xAYtdM8ANKo8mTBU+wLmhyZdG2CY
Kb5wHove/39KxbaDBhxmJdbXwVkEPG/7w3Lk3Qrny8tN6L0VbHGTuW5RKqIBn1a7yDcItnNwQY1m
FnAFxz5rWvYSeuS4LRp/FSgcohm84gLURnwwwI99HTLdKdAHFUuAuoqGYx8UpdFFSPlIsceips1t
ZLc/bYtFchJPI1SHf3g/inl6B+Kh6SU2nZGMDNRO2tTrq9Z5RJX1zDlIIhaem9mi26egk/PzRagA
Ow1sGfDpzzo/rkxHnuTvtAj6nfkdJdhk23VdX1up9sFMJ9lw+bkInQi/IWZaY45EOzjW7BBosunj
BfwTvgc4wdPf/vsRjjhxcUvOAP/aiWxDYL3QucJWpa/4NoZ7ik5epce87A0Y1u0l/LcZu/qqtXM8
eY5os9hYuGjhC8f64Jqax8G7BCFzPMTsvU5fe0C99d2ZfiK7erUdvNGGiOmx3XPW8gNp5HCRiYzo
NZsmtgAfLsPVFaOBKcsAzZt2QFgvJ2gYmlT6aBsNJ5YIVvQKQGYwD75vxevDN5X1tWhMnY2y1qRR
5BWh//L1EBJs73sb7oTZPosP4g0Qah47R5bpMRfoOJ5lLmczv7h+rwGu9KnWZ7x3u7lFtySwT2aR
vV2mIl6zFECfwdgJMySxfD/CGgIPpt0O+eslslpjZr9pxcGK6aPmQF8LRSfjHK9MeE6865KZVbKc
/bSzohJVv3F8MI8Nk8GqdCIkNHX+EgWpos2aFLbah5Srb7SWG3WXoYTRArFA/p/Y4IziwtgfQeC8
MUu4Y2byRzCneGQrl4jiD40i3oN8FQRRPixhg9PAbe/8vnUX4uN/K/DpKNkUMfQiavxmAD8+xkpT
AQH7jdBds28udt+uQWR3Y6y+FhwmHZdSotTooXHYMDtzFKOTa8ED7soF29KgYfEfWg4t+lpN8yMe
Ox8laCv/TxzvF1Lv/qZ26Z7JjyVPhyU8aP7guHXPncelXdrFEzkgj6gocN7CkRyEaZnUP2eqd63r
D0NY0YVgG7ZXfDAExt8QXNWdjziIyzTQr9pmU8i9tXJo0yybHsJv3zMLeWH0hDbD/c62VKl5LJzT
th2UeXcfr8gvwSTk6UEJoN3AgI5p3M25mLzwI1o6RjObeIJezsKyKyWQ8MLJV5aRGYIavqqgNqDP
3808K/098ei0V5P/b5tDXkt2Fgz3SzbFRCRSEFQ+jZ8GlPQ7S1SW7fAFSz4Gc0VnWHliQ8UDld03
f1qEL4RwpUWgUN7B4eI0L3TxObl/PYC6S1wFWRXisWndl3CRsIMZO67m4RMXaTjp/ZJ7tnQlXncU
+2pxYEYQOL8/0pYCxDCkY5Jxwc8oWfTQfOCWMJY1dskYOAzQh4TpBDBYgyZzzZkEmV9B6l0Wkb/F
2j/D9s85GAC9XhGQwsIpHB+/NebZLyY/VXuyRSiel1JVYJTGDB8XuO8zqBQX1gOAL8d1XNWNmjx3
6bINERLr81mCTSxl0goJVDwU6pPT6kd4jxruEPkS3JaXq3EOjutlIacpT7jD5aIC7JbRnLwJ4QsO
BrOOZX1AefAhAlLaUcutjctJaXpPaBbLVs5BvpHN8IPZ+a/MoTY1gmRxYj6c5POAb3qFPwg9qcLa
6hI8Hm7MtZ/rXfpx4w7FY5daevaUBMgwEPvOj8lQV/sAIJiLGjV20XEHaxHBS6Zg+W6Loa+4Klca
ZGzSaG3hO3LMSku9mypo4sg5piilcxDbH0Yxa28xoZMLDDqpNykq1Pn+3SrdTtjwexieoQqiQzUb
f7exL+DQoMl8DMFSr2QiGFcfREsg+++6nNDNtpvrDBGmglFfBN+/q69KSbYxLb3VQxAwPCXnq1bg
2Nl6RXvK0XkLk9q7wSvkLTHMedIsbJLaA4fwTCt8xBw84hVQeWrdH/r1+bd+E7mB3GYfzOyva+9V
F60dO+M1bWtzqZ9roIoOnBhwkauwHNRkzPqCkPkIzQESM8a1P85V90x1rGOGAu8fYtISOMr6AsiQ
5R8HaKliAfSJOCSPFn9zZ01evhO7eBA6SFvtgu3wNsEB/3YXUpefl+VJDwe/JK/q5kyeAN2x/4KM
5Z5RyfoD7nil2xEPkhWz8U9VmjdjWinMXh96TGpS4wgLkvDpRTSe6mgCbrY0EPjc0IwL/iMqCeJy
K3PJ1yIJVtceQzL1Hob1i8/peUl2ZSsRJOCCPdIZFvxlS7TKfe3lxZDPJ13+SugjBY1ZuSbE3Fwn
2zNx1k62zesJGSlNIQl4cz/ySJDWNxlYdykAa7+k5vu2NfhPk3CdMCSMrX63pbD6usQ2f0Xb2slJ
/6KQzQSfSRVGoJVJ7GHrWKJAlOUQoWpHZPASgjy2RZDqGdMrndIFbTDvL6PlxDeC+XuFH9toC6Eo
gdwG62sewpOQiAHb0sMUrOU1skuWy89h4+e5OegV/Ep89rFdWICJ12GirrH0RMOb+Zm5a64U+ue8
Zkxoyi8+Dwc57cj1RzwJgRw7Y9WLteY5quqTBabkw5wix4Js8FT+khHTggIbYBbtRPiIPEV5FF4o
TsD3sNw7VFwzBzi8vFiC018kMe/ckpc/49rC9+sWWHGGlZof3CIKAhhePOLhZuWonWxk552mPRvm
3eGICARSUf5A7TEgnkFfhytRCoubSMgM+eXyYL6i0YwSsR0g1O/kkj2saoKMqgd1H+Nr4uyGUzF+
MabScyuZHDKr00hYbK9wS/LJ/a5JqRYffVAM0nmKjNUjaj0yA6qCzurCDPHWiNIwTlhRHRuXyXUB
NwhhQJ9G5hHfVjtT+j2m9YnhEXLE516Xv9IWHwjddxzKQr1+eiwJzOCEZBhpzdTrO1TIFW9c7s1N
PbEr/mPVK4FPNwzoldYSqygyrAKv2rldGzOsAoAESn7ZLu6BBfTnhbzHD8qX3i0TAJBBNaW57US8
a8XHBQoX/MYlWSAGu+QYU3DwRZ41Mau4CbUeXoZwG5bdTdVYvtFFhq+T6R4Gb14UwspzBpi/W+ww
esRBgwvjqfdlA14Pm4dm5y0EwUOf5KE/RwGXhCwQ3zLjypKM5DkxDN2P/gb7l4WJUjQLmlOjVkwc
PXIfAlWHQpNneeYwvNEhLDFuYb6ArrjnltYBrC+U0mkWb+tfriW+ftzYh5KpaddI84BwG7ez8CVO
LCzUT19F38SStWMZmg8yOymVnkD+NxM/x8Wn/e+TDUsmoxjO+hphTlzxeCx/dPXq7vISdNWbEgy+
TZe9JZNFqrpjK/MvX6s2zz6+Yb6eLsL7vAKYRgbMLOy0iNQY9kToewq0I+p/qnoHxCqr/Bv/HvZp
oOlj6YviD7qZSTm5uOwcoIwEzwLVVGNcQ6RGYujttN7hrpZAYChJYOrazkmVRgXKgxyukSaRQ8bi
yno/QzajjPcEYNt2XnbsyJTdld3Tr8xzWnyvP7W7AxFk1z0b5qrNywmcAW54HNqIhHAdpJNYcjZB
z7F8mrODEtE6Pe0qJF4JP+0yAtmsZoABDDEzPJCOkJhAWf+POgGYDtshK39ghYCq3CPef5cdqYV2
jf8TbOiefPZpvArsdKyzrRbejCu0bXfviL5wswWfp1f6ZjTeUcnf8xQEbcTiSuxavXcudN4XGOtD
uMYvfxwL9HI9LNYOpiXGa2jqBpwp0eCqbVguSylwDWqFRKjr5mJBwA78wDZMGws/AN5PFwvQV5Ik
RzHYwOFLZhgBsSHBVRqPsVlYBzPBvNH8YNZXwZJYC2IEIK6JWLnUYoSBl+lBCm3FlhJQbLm9nts3
GBO3fLpCGFIn4/ZfAjc4RohSoXyr8GMzKYYJvZSd2+82kTJto/uZDlt8NvzpT/5xZuAGtXFzmkEj
CGamagt8kLkFmAjy6oyUsWqjtC7Er/yJKVHd4kzhyT1NMh8Tg5M3ERrX3qyQ1g0NIw8sXQu3Evmb
oFSJzGFxxGxOXbTDqdvecnScI69CIJsoIHsS66GdTp1LyA9bA3sEfFPEwQEPk19oR/dU8+WNCONg
Xx6bEqigU4+CarKs2BAmPCTG5LHVfPqKQXYAVrft5CYN+SBs2SiWBiuocTCeG4iaIMtLytPIR6xJ
kZ5Ua2GcHsoiYT6ldZZ69wJDsXKaHHlOrT02uhfPRMSIV9jwAcRONUkIVMaZfPelCoy29ATMLQxP
y6ywf1cz1zzO8P0vsBjKKMfwhHaSyJZcTsTv1RFIhwrwROQq1rmQieF+EjdPwSoWxjJf25u+PFPu
blXS8h+eQB48jSHvXv9yOM7eh+AGpgMnH1s/juP1+W8Jmy75C6dad6H3zOWeDg65nv/usWugcNpF
m6gJI3jXODcIAAV4gDA9Ju81k2HwjQ9SIA1hUoq8XghDNkYQteqxeU6dgKzoZ/RJonvtq6u5cIgF
DGxeMjhthz7DXQ8pyznWnEzU0bCvrZM+OYPsOfHW8bEbhBxKcIl4+rN+Z5uzv2drKaKnLWOQVHPw
auGZtQsfFf5gPdan4G9PzWjLXDyPxdUp4mqfNr3SSO7hN2+f1vOAVRc0FM1HPGVEQ5DqajXo2KN9
A+oH5BQpSHDnKY+ZCgNfb15facaR7ibSbrrIs2/0erW3PTFMRDUPgyHZ7mhktodgawGlsuX9b/WP
BG7ZQYuoBZICZP6dRRhWAznu3ksoNGWjHZ6SZlVBAVSl0KEIiv8z2iCh11YSp9KqecqwLsN1pvPE
UFGJrNzDNpquYggrA3aheq7C8tvSX1/r/7nds4T8cdo/WJrR2uodgIcnBfByHuG74LGymwKOPqLt
13f1maAPUlaAK+YjXBNqIRRw31z+wh2fSkJN4/EyMXd5L83jQAVBRzpVo8hWr7G1eOvXoI3j08zW
1XmwvPxF9szdedo0F1He31HQ1vPXJcWlVu918z9uL/9z7PWF6GGiAqiZsX3xwj8PCMLvooEOmEG0
V4SxQqQFQbEwjhhg85v9N/CKHhJRnDzWUiF1o0MsireT1AawKPlBVr4P+/s90FV6Jyg3qq8+ErFq
U67KTJwf+HtO0MG1wcyGE9Bi+c4QPy2SgBBZMq7LExY9j5Z46pionWI7vo2oO6D5wjFb1oYcN/e6
8+DT0U9D8mIuL8QSP/Cx+hQHvokwr3xXInvgtiEBrKirzNEhRjR8HJYinsTY4bADE9VBtQuszSxj
qWkKF3DxxnWYcYrhA6NQajZAsm8/V0TFM6b2s44NH/ahx/p70U64VygZLX+6wbfsyXZA/30R3zJy
zzx7p5MdQ07SPOA4wDJNpS2hStWsq+NgPnuGb4jPbOZWAsIn8ZPI3w7sSRVp4hyaPwqrWTUklOPl
fU5w8a1TZNNJ+KurICPTqGGfnWASKdDD9IqgomhMIbPYXnofZMkYrr77w2112XIwjZt08Kuy0Yax
MZUvo4slgrodMNW+jehd/W9B9+LIlTeB5oav+uZcWn/N4ohRrA0DjhQaNBoSfVLj0E2vVWMB+h4F
nOZjmZOVRU50JnxPNUpkjpKUtE4LFwil3XocAtmDixrdgoeGlFcz34Bmf9McLbRtjWOFkoK0yyus
QaxeaGLVjggc9eGIaMOZMJP6FAB1CSiohwEMR0gKAnr0ETRn46fng9R7Jw0Yd7tjQFKU0O2KVNUx
4wxRF1y9VYQ9n8zVYgcjOq0Ksyd8wBq8vcaPEyHdEDlYT12fiEuHe7wh8yZErNZ3lIJHZUpmwdnX
R6YEYYGa2KBR+hms2hfn/OSs5WQxjDVwRgUccTNA8ItUi5bqWIUhtv7wS8WBOrQ0VQ6sp+I2Vpmr
1jZ88Bg74NH34tEdR7HvdNvhU/tFpvezc2EQ8nTeGBPWRBu6dClMNia+EHBxJbuKA52pcihhi3pu
o2eadJLe4oFM6FrefPo21N7qvwTWPWRSro0apn8i0R8aOnEbUBpmmIqDuw1A9ml/P2zPalrxIMtM
PJwUl5LPr9kFHffNvHHjZPgJgtFmiBvn37uIXuUiDlSN1/dj+Gxf+VPwEwuVV8bcHygdF+CE3HJh
7LOneJrEA4jP2G3bRNRxKE5UvFPq3b3jl2IWQjyk5KC+14esbFfZUlnCdXJKsB1p/UHHUFuI8oi1
l/Dqq5RrWUuP0y51hQtQmcjTpxjbDgzvTs7PSlgiNzqepx1XCgYvcRza+KX8WNbx1cOBK98935zq
dcLrl4+TmSXwgfnRP2M+JkAFrOQlYmTFgMW2c+fhHVxxLxd8IiwvARXYsVkPXZdrCIv161XPqQKk
GffcBQPhpo5P8+1cGHtjRsxAW6pLNjKeJymOKs+lvW+ODe3cZi0q6tTMhLjCRrVK9g+Wg9jWXVft
2Tski15p/WjzEtv1vN3c5cN94AGRYJpm9IhrkANcZimD8sKxYfTytfoFOPuiSIUR04cQ+PZnclYq
kcg50vyl3dsvJHg2M/hNCgESRWKMCc6TDwCYskJbNAQzv9yC4fIIv6brM3TEPoAhC8sOI/rQWSPn
K68O+DXuf+05djlcE6zjPmtye5bKxBWtvvLTNYloL+WZyPl7+h27rhNR5OtcQMxZqYXZHEkVqula
GzPsdLa2apCb//C2xA7HVXkA8J33TLdsFC9fJqbB9cbrFo13BmtnVd2Nj9hD1Aypy/a8AZLMcOYj
ibcMSs7vmr8S1awUk2xA5MjAYJhzJtoavEAhy35RdUSGNaF0GS7+Fyz6oXMTxCP56XfpdpQ/wLxl
9s4SMMEiKxNFClre2Td+DaE701kIltWDKyuOSvdUpOlAiTR8NlWkf8LOyRYbRo+DH5JAz0O5Xl9l
e8mFVuhQWOZt/Xkm5P2d2Mxehl1MWYtNFfFVZG96OXOYOgoROUjqB6AptmMcAcXMm3hKWSP7fUAA
8CZnyCS12Fet+2WIGN3O4VKu5+437lhrovnLtoqgVByAoiVm5RQJ8uqQSOK8l9Cck61yH3DhlPnh
IhO1o5ZHEJZ7Y2ZSAOI/DiibzaZsdIXfmuvPsqjYjBvQ3Ch2dqg8J5xKRzuTbXjnqDZgF39PfTwm
fjZwWeRR4cuf4dlN+OaO7hzsOfiTXe5MhOVWLKAk1ChHUDkZdcbs5jn/d8S5UPT5R3wyPsDHJZLd
tiyqE8CYlo3AtiV6Fqs2zCPNkOYdbjMMzwZWw4mjeLO2aJttrcOX52KW/xKZpX5icEnsV1S4txY1
ICoP5paWuT2b933uFAHB2h4czUcymMW9wCaYAJDYtBLEGBealuQXl8vL6sRfSFEY/wTlPHd5PjnX
sQzc17Hkk0uf7slR+Yw7ocRzA+o7UgwLZogWe8K9Pv0irkaU1Adb4b5miz4phJZ5DiLbA16jedvT
MGFPa34atJlEIAoqUjLcn1vAhN5eRjPw7YZA/tAghNsu389o592JBVudbbP1qbF8eBic2yjscNxb
cYw99A0uWxA9EO+NlW1b5qkrqLO9I5ioC1PTizO3OD0FGRZkD1jfRg8JqByNpFbNpToqe1QxYcOh
Kt5v/QhpISEThNcweGGiGAzj9Sz2lxs+HUVw6JVFaXeBtlBEgJTLYu6Gq4SuCaLkuyVvJDgbr+Oe
npswP9p4sjrnfhta/QUx7RAA2ZCK+VpozEJre6CAEvGI8OvtyE2Xfyfj9pE8iSBYzo8qF1MGA5+g
xALFqvuQamXy0dSY3hls3VzUL/8sGLwEU1baHO47VrKXxCFvR/VrIv8YSpfB90+q8jfzKM8vYQDJ
jCO9jJkrulcgCFX6CKuaHK+k8Y11ROYZBhW/hVxfLYcGwikWKSLyLUFXATGSpYklug0KTMKRvbgy
Cl4dUk1GHR4swSUsswtShwKXnlzOxF8e2iEBbtTWZ5V7YhMETSmnMd9Mo+D0zkiDi1txoiNpLKll
SfDVThuuLdv144K4AyUt4rgCP5WD/R/B+bSqkII+FTvtvH+3FPgBOmRqJKi0XSibWzGUGL5hmN7h
LhEGNMLFoxKn7coEBJOYL5KKtyMMdJfhlJHRP0MDZGeFiR9EHtULmmV8gHKEm2hwEE6JqLNPq4xf
9xSUNoP+ERtwXG1cuJAnT6ylJJ56jCFNPSqF2gR3KH3siU3LjpmvYN11+ESfP0EHuP/9gqYUKJVH
xs0Jcgy5HZ8gE1ZHl1y/UymthS/Ps4QDXH0tF4G9D3Svw0kG4semfz7kEGBBsPfsqxY0NOsMQi4T
/TMfkue/qbrFWPVQYa56fcylKGNsU89xtld2Oppq8NwjTXIy4Ue7pcW/wvF2AGx0vxChQvN33PUU
pOkKgeS1fDPV8/LDbwB9muNBrY/RVjLKk5LC7bZAvUOsFHy6O6JOYb8hmXIC4d9AXopC+2Q5LisL
2htGp/Lgx/iXgegLNuxkEzp9s3wmE27I6SrADwjDOVGK8PXBz7L6adCGi4mW7PdubfbUpPxwPliE
qbAGSwqvqcSaKoFYPLffb2vYbrFEYaO9c1YGxGqGQDQjeyACx+eci9Yj8uGg0RJrVPgXFNUUhyHx
iWBf233Ja7pXJZbPR8huFy9L2ksHo63viE5rLpLSR/BQmhLIDM7ZSIU+S4M+RiZ4hbpT/eorU8BF
a2zplaDFgfNyMX0QyfbY1HuDJclX4dJ5P1ILnnlABm4d6MMZKO3qRrovRWNPOcN/aTvy8chTxpQn
dpGPQyZyUJ8K1xM3d+cKfGa+kQe1G5AbK3coY69S7HszBD0gMJazgC7slIWGbQDmqPhxTXOEDvpc
F9kEesTAG8BtPAqwvtS+mCE7mpzzVvxxx7dvT/hlggKCX6VXaOqQOLNgKKIA4/erzRimsTuyOpXK
QLgL5cUmqUrphmcOvpZmkY8n5ztgRP8ADG6HumpDWgP6BLVGiGvQyylUGQXj9vwj5ynupBLPdxZC
2vXo2V5UrQNAwNQlQRe5MnVK0h+TeSP/uEdUIs2vtfjY9QR+3omgVh4kF3Ufjo17TLk9TQQEcJRj
wJZWqrs9JK9JNTUpvBwaPlDGPFqVKHIxagPIc/544ZZ0owYLKGdfPPfqiv6Z4jbTb/7VM1ogQwqm
z3B9oTne5IcH68SVjXp/AKPU//Pq7VIbg4ymOOAr7Y+s4MdTeQhbIBpz6lz3RtgvNXWpU50PIRnm
/pKTW2o/fvUDunweJfB2xo6jOUjvfruEG7FMbX96NY2lNNfpcL79bhs3iKDXw5cXVDDpfjfQIxzf
sbHeguJYAqgx3AmqlGlTrAbEVVpDyLSuFzVKpkPQV1odVpGAy9mggB5vCsOamuTR5Vzx//4eN6Pb
9jF7Ks6aOi7Jxk9xI5qZcy+x+3hXIgGvtKD/DWu5jSZd0zZfF6KkqUQpKe430yKMw5AGe3iMm+Gx
XYNOsXXmX3xcHEHFdnCRSxDK1UigpZQi69FFLaHU6mrlA6uAoKSyAL3gkYqoNGCr4KxGS0yreirj
MkoTGgIQvRTthcViO1VWLvrUXtgLtDFfYTnxgpLRgpCPSPdVB+3KgNEsi7UV+SZcAeJfaMvhJf3a
jNdagBD205XjV8GfU9/VqRUkdVYoRx3PVGL0uiKiCZlTXCQd2katIlWjgifC2on2iXRTyo2oamnI
s7yekrJhMh7AMbjbZIeiteaiDVouYLy2nCTziqgPw2C5gv1cNnlAA0JuxRIlrd+WUfa71o3KlPVX
7kfZW7KGxtvrmtk58wvRGWuOlmPHGk3z+kcYTkFE7Og9uYy7g1/Fcl25pc+JpdFNkknOKk9QDV8x
IqWNXfv+/t34Yzs1hHwVAWmStRp+7O66zkFa1IVqgc6b2OkH5kW8Ur60Fz8TVlTLZayO3Rf0ytb9
VBiQ6GB90WIuQMt/tXxZWAV+6CvIU55UHc4xx50O+GqjJjTr99ltDSJQMH1wevZGK+dAA4HOb9Oc
aOB4jcQEODobW4i4ZeZ40XfUroawcfEIN2WGHcjCndmzSltAQyyDdC1j739s0s6ugsPCKAdFIfEq
Gq44NauzGHpMucvLF/Trtl63xoL02TXEBTcxMm3vq2GsW5BIdbh9MahSANVpWpREZGbx7Kbfh31H
2lTMzn8+NzovncfDn0wqPCfdV3M0yJnSWB9PIrESRSyazuJaXsj8NNpE8twzi5jaae0yf+w3nmZi
j9KPt1c7b692oMok2BkY40V4LxkrGFaSiztamKwSANwwbAs6rUHO/ZEfMrFP/nc3W5R+jQAN1leo
gqJHO+UVn/fQFk+pvMWeb14xsBFKVIDztisWhxfamqS8+VDSAJmoRDsHR87RiVGiwoxKig5+uuZo
elho4JSKWoTT/jyYelffkVcIfa/5+e7R3UA/EKGFQbsaU/TO4CmZ5tD79GtBbBHkeTF3Hs6klWIF
Flk1hzPBhECbgxO2o5rpCgGL6owj7wCP+79Bk1yVL+MtVIXqYFwOJzefpHy9U3ydz5OZM5v0e3rT
XN9tDwT6+2q5oNJIBPkGNzE8lJKOU8MvEKd+GDuyygdb15FTMHebSzDzUhezYr4ow9qZjRTzOlo8
kLowl0IoVHNnLO0XirBbXHuG5N1LsNk5ZHqM3wTg34xwgeJjthcChoGmivzNPbCF+jAq23U69Rsf
w7P7zCPupnJRSPgb/DOiLqLElLd6nj6NU4RED2vIfKjMOErk5KgrIUUK505UB7KydXP81tdGPQb2
pxMHmouLmlBDldlC82qE4KTvPGg7ID+HPVk+I/sziXRP78LyEUofADeVASB8QobdQ0eS/wE6rv5L
TSOglUYyESn+wQbdIU3oaB/Cozavf8/UsKPLxSMlsrxH/mxYFwds7mEB295EagZf/5IdBlwGMxOX
MrGozbonTCQNhRZmlodpGLtq1fCOR6rVUIoK8wbh3JHLF9wBczVw3INsZ5w7Yg70DXjBG5zyVwgo
2fbi1/3kVHEUsmIDGva7Rbp064qLhXc8+dpQNFPcJXTEfYpWlQycgBwswu6GjLx7vMasf5hzczUd
Ld18WGRuVZaJtqS4RVkjdjwJF6b7Fh8j1V8bB6G5TEWlgroo+JfYUzrWZufAKAng9RtBMHyPhhPJ
SmyzqXsJiCi2Bqms3Dx2Jx0hZPW7IXAMs6QfHC3qJa/aM+9yG7x//6IGnuqIIO9ZsnBk+DWVmRtd
Ar5/1Ne+/GNLXhPRn0JhRXX8xto8q9gls53xu+/0TWYAxm9x1BG5NK5eHlclUDu80NIBf8hh0JLG
ZMVfaJo57EAKdSKsML0m31uhRqe6N3QBR60VHCgieVNJSUHS53RaA+pybwKnSa8lnSzdpTna70dq
+HF+UzQj95gDwrnJdrjGbhS4awcDMqjvl3dzpCPLSjkqu246nwM+FL9OV2W5co7PHhEGzemJoE1I
46TW6UFR6DJD/Ny6d4/aUWIvwQ/GKA+2EJ+sTC7vMArkHQCiI84v8t8WqDokcI3qo4YP+oJyjsBk
gchFsdfBN8b7tjKhCt2Oi7EKX0vdFFt83YGQbQrCirA/QRs7GOTBNNL8rVjeCkBfdnGacjyCZeGM
iHxD+WpKHBUrzRWzPzsVA5ko2t5tkH9XreZ4ZX4Kc4v3vS64Miv5iIwvggezs3WNeu70R/om61ue
7h+TYBXGYMs0km4QfRswPNAKjH289o8jE4w0en3Lh2jvs7XmVWoYz0iOyVEQOSst0wmLe1bOSzlQ
tP2dLamNI1n30b8F12Dj4nrjKGq+MT0yiFe0lNvaqxonoEr2PaV65IKrigHWWtS+MSlwcbnsZWJ8
GcHlZe16Mumnm/oBFzgieD3fFY8J3e+Kz06Q0lcHHeLL+QZHBRCawAlInPUCeyb6KoMn45l0U8Co
LIgilg2dCfqQMJSsWNgXYQAxCXO6x92ZLuumecG34lmN1RnmeZr4HaduPPBGAchXhWDLS/4h8QI0
HReLK50gsRZVdaEgBKwqoVj31XBhWC+37fMcNUnGQzbBc6c4p8TMxfG0sAeD/eCizLVOKw64Ia1i
5sr/p8QwXL1ZTm99y7aB6X+9gNgScuehVY3diuSEHkXqq88pfgbxTEomx5OuPlWucU0QGdoGTU5b
ZUtObhil7TSjicNW81y52WBi11JJXmR9BvgVtZ7uBOxfWuDEzCpPh/fCY+9zodO/zRDkk0Pb/6j2
XnYFDLbceuG7d5op6Oo9VOZbOhgoFjnSgYVWRD5TTp9r79KU7Gmrq/oEJwJSG8kVcg+jbA2oNl7N
GIasGO87pTqa4qcg2hl6plNbcMxK4u0MMRRQjXEDlEWC2uAZrkElnupUj7QexPcip7CUo9PKBXqC
MBJV97aEVfs/r6sd3aE0XAq9cHloOWP1E7yhLY9w0KAkplG8U1kHskCL2bmgJ2TgPc8eWCuAJE/E
RyE9VruL/W/QAYGOoSZFBGCz8rdMMK3d04Vi9sfCp5BWEvan1av2DyYltzmQCFZl/Hj6eSpCS7bS
Yhco8WODAysG7dUyRQQIhwBOHzybyQJ/3mDRKsKklgzZPHYxNuIF0bkwYB0YV35VKGT3t9wV+Eum
P+aJ3dXfMrNT0GeSCPEOElGymNpJeBUK/2pEE1+AU9EAXqzoALeBYRqAO1MtOm+2N21cFkbi3SOi
pxj0gbWCAURGn4NBwDExMsLYhwAROEP/kziu4LO27HBxPneIG8j0SbXEfmBmMCQacyUhxCd2BMUc
ktq4UsPn90HDs4i8yrlZ4Wx+pT7xuzyyZZe3ylZN+LKfzh1PHrAirpxU6LErUGAbjVxaRoCPqIXt
0q0oEYiDgNU5OMO0Y/uxff4TQ40J7qTMHK2Exle8Fu01pClSXwu3JgZTBylDevIHPqinlKL85sNp
pVAEcRdxr9HDbNmu5yZfPbmk8H9Q7fwJqefre7erXIwOsRcx6ekOpezhd285phZdGihNB/DNa4Ny
xN0t2vs9ZEazrLc9F4pX5jQveOZTtt2Hc9kK1ykloIAUBN0yoCEBNV3EWyLDUi5Oy94CtQxcelrc
zTdrQLN++z/kKrPx0KPtrucm32Twyk1aTLJy8NzxaE1QwF12vOnSEg4Vlj3AUcfaa+D1ey4M7h+z
lp+5aIeSgTkPfOYVUtqcMuZ78N5TFVWOOgLYimZKvXggjqIh0uI324UXUs+cReq5hvhfftdQoPR/
GtgQdR1L+w1FWhFHUZKSnFcau2aIEuOn8VdfOfgAInv4B3r+ayUGXV1y3mMhBFYKMTQXw50F4syC
dhKkcbYggtB7vIxAxwMXjVLboiJQJL2Mq4bYwLfRw5uG5EMw2s/zpo/0L7fANyqdKhgfAkFRVypL
5kCqkRDuCWN3hkmtvZ0GGRYDtM3tROKSXyBxXTldh/JMOUYhyRCDCMjdHIfCzKl3MrgkxUUvhEFb
sE/YSznXTIEndPJtymhZABvhJA9T+zEUfhOIMEvRGp1gjLUCcSmg1haCQcDCI1Qts1OnwphGJdBu
rbAYlyVpvTFu0bwx1gjW+tN2HU1sDUFADUmSuYujJ4c8OvbENwUa+LBdV3gytf0vMkpCBVdjrWYs
X+QtkIFpIhkpTwV0Hxbl10t2YxOY/UHvXVlrGC8orGK4XJWR+ZUNmBGHiTtiz2xKaPPxH9JTPn9s
L+wd8/iZXmb8LUFhPQGdUkpYag9UXjCaoEoM2BNQeyd+eMeMSfDZPWBrU2g9xr+6cG51w4OHsBxI
/s9uTYaZquTuMOqf5Mj14+G8nk3mXooMTySkNbF2Nf42YHA0VK/efjJLoNEZdsw/2vglkolAu4iK
uPalaKjC2qG7MJdD2CAfc4MEG9ywUOPEixTnhGyi4QusZR0S7E9vIZOshiegb6L83ieiWnGz9OES
NrfdPmuaLnGSt7uJiSdLRx4ZomQAf+7b0BHYSd/ngOabcDLWgekJjgKuJsfFAJHsW42hPvlpL//a
Wky7IysTYvSkBtkuDPCfKWpToQF4K1y9FYIoDN0vKR9iQW7yUwqxAIk9hVrJy4eYCxpdu+tJGD3H
hRl+fyDV2U9dp/IPKNTF9ndknqq1yVgtiABzFz0XEjTkG2DYtqrar7sq+PUqPgF7nIcMKo7lyL+g
AfR9GSu/WeiIbjG500Uevc7dQZLoXOXoLKQLzrL/HX3L/odJ8iXkcDiWidUv3S/8JxxdU2EXzJvx
R5E4YLCMXGD7udth6VMT42oCfDZhCZvZSnjcqfGi5GNCiXxepuAEGW7WFqMMmb7M2bAaPLxcDxS8
0vai/926rkx458BedInh0RPIYw16DSB4A7sciVxLdI0ulCP9Z6uWs7qLyLjdt57BcZij6g69D2o1
oMy5vw+MBOCZ54+J+w5JTiJLPAez3QItR/o3qSyhB5DpswBPeY/lELNpYxBEzZ6ARiFdkOr6N53y
2OHDVep1SMXAhQPT5cQ633Y8MlZm3TFEKxYhkvhf3l2Q9dcWCiNDUvQD56TGKPs5Sw08j7WIP+Br
SCR7BEYDbCrj02O93BCsnfDujmtvm6spipdjay+HEvBrc1FIawX4qiKlIU4A8UiCZmQJcdY6FXTj
9912pgEKkV3OwOb89vs0pTAFUWvgx5/EXuTqT2nVMnIheg0FsSnHhy6Dx7s2euuaAVDq4OyyZlMU
fR+HVENP3rG4MuGPZUKcB61ykV3VmUYmWvtp9YH+Zf1Gc0G7q34MtogaKL6t6VMXD1VdFIRhc7tD
3lFmFb8x5br4ZNrb17UJ5ebuWoI9yM/PnVMolxh1RXOug0iYm0eutptgPWdZDPiPv2lhG/BI/wty
h8XsoZ8rY/l9dapHM2dJfrreVkiXqWb7nKDsc6K0jyaytmRBfewiYMWDOfUTwElSOXH5jDKBKvEK
xEUN80OjvdViB82b7Uq2f3kw93vy4AaAHxO6tiYW95udmJem1FJldQ1yybxP3JC3Wa+XoLTy5GTJ
YIQdPbz7MjemXdDn6iXprDW3ez8ZuFO73auH4Mqxg/MYdxiTrm0Kr7xXEdbvNtaxcZtI5WBG599j
gMcMFHLEMJ24A+o6o9HEQqbe24Yt1eVWzbUi3zN5OR/VTkV2MwO31/fnKuK36wPqFcuklwljD0sz
qwrNQvShFFrwOMNQY0fC5n75cq1DW59X0tn7YTIHM7v5bu5Nvta8cE4eYe8NistxW7c0DP0yl0Er
nGdz8n5SVWNTXaa9mQjuxuzzeItNsE+g8A4F/+1EwgKwBhty6iu+D3W+3/UEe/jADI+Irv+nMnHP
rbssMVVBR0NwhLMv25oJTga2XypKrPdgmYmNpqXgyUNnANRq00oEeKCNa9EHFdL8R3P6p+q2GzxC
aTFbdI119g3UD5UDjwNGC1S2yzwbJoiEtUAmnjp1ffrpWkJRFjk1bMDLyZuy2ToGc/VUwBm0hngq
rbp4pN8JPvyheM3E6mu5HPi1xuPABmdeYilwTSgxPpruvTYLF9DjFJNzKof0amjcMUMEpTHPQ5Pn
NkX1wYAxEOBIpaV094HmEfAjJjvwHpKCbrj1uVw4NALf3bRZAT+bezVCEb3TDjMXo7ZiEEVv8cwE
nyffdU1gS7k5+eVG429iURW+hg2BNvXnX5tj6/yH0c388SGUzdXKjyY9hVuozZlD7SP1i/IUnF0Z
gcsmJVM1zDszATMcuoXJUK8E20qFqBlE+/08LWifO+2SDGfGhe2ccZbHXam56Gy0NL+I4lusn4e4
3/2sAKf74eSlJAWrd2RDr49LHRaoClexWIXDpGF69y1Mg/6fjCzcjP7ANQ87ywLOQSaNo4wLefRp
9KamV/yEtsLtlo27Qi9ctKNjxBQbwvs4vc3YuwooKRDDda037ovWe73A2HxMhSvU1vu7hgqrAcO4
DT7vbZcbVbvPJkbdCg8u8Ns8Hh2nWUD9PxU98vbC8t6y+w2V/H8Oz5UiO3/dPGwlbmUpztRLG378
mE5ICRWHQwmgjHno2uIc0HxJBSqjiKEdyQSeLfa15WIOuNr1fV+P7cq1FDkjZvJsML7oJJ1m++Nn
wVi4lVVxepLj7TmiF2T3AILVP+pN+HHhHvh8zNc51+X958oIoRB2tAj9CHhZ3dXRMlWZ3kBw7ffX
jkiT5tLqU4hm1i9IAnJ7CN0RhKtZissR2QEURl2tk5Az+Q3mYaz4Vlm2j6SIAcTbmlWbD8sOB9+s
CqwyCKKeTjGNHnm7w7yrrOBDLPFj0FgWkG8DtCkX8V75EPLPfVYj0+VIM9EW91VK4lXpqrbj/dEv
LZDdPxEB+qTPYnB1PRueeRHH//e+u15zYJ80OGK62V19gW6p4f65gJAB3YhsM+X1Be+w4Navk4hE
yunk3Q8y3EXhsmwdMk5jDcBmdK7GUqriMMgvSobyX+zaWXPFGa0tTI87oEktysFjQjX+h5wCNhAx
wLHoYP0SZ66fbeYwv2HytPOIv/SZOqJeFnrVVy5aS2rJOV93laYLu4si5I/2f3M0gmg9rjbRIJK4
NjjnkNlCQbmVHW+XIbrIwYaXS5yFCOsly9O3tRxvLdSw0bfzwAFG9QZqJYGjIB+rr2WvlPrJDDDC
3CQ6kdI7k+yon7v6+WuT8U0ZM2HqA6DMob6C7p/F/osRJRoUm6VuYrJTY/1tRfkIjuoG9w9bgkx7
ParUw5Lap2eZFoCGifmdrSQC9MzyhG2UCLFMYeYV2+wxHsKPEODa00d5dZf8LcUm2uU0pYMHCYI/
3H2Xl4opEMjskSkVMhz+pyC5mdZLcO2ZsNojzRgSQp86QNGQtrJIrVVp94V2rkl1N4z9t57N0+wk
FU5FIyzI7OK/x/QDgifvpHNRENdxY1nnHAS1reXylSHnS3cuVLVlvikrKCDgOi1HnaffMpmlkgHM
Y2AFxcAH0wTYsFN+yMczC6maTudAVH0IZ+eaKuJwua/6GFgZqw5cEsA8k95h5Rdp9WGnqwjcfwg6
aWgI8RJ8LKCRlf0GU2UHmAx0CG8138dcoJEQbBn3gItuuFGoZvr7ZdPQEhVb2EDiaHIQvo9NXuLT
v93YQcWjoeKOrFtJPeSiRNi2EM/UgEUGQVvEzv8/m/cntIV0bjijVFKwPMr/kbig7+lq5Ey6BwXV
wUQ2qxESP50JT9vthe2MaZ1uCFj+rhkyfjEdsNhgnbrQJKskWBKjHBluZl5xWNwE8Fgs2HaEDPhH
m+c/RA61sLUKjClhiAqmxKl+MIcj4wf1sSdYQb1MPQbfq3kGZJ3+PSS521B6gMgg6bjA+aqjWcxN
80d2yX6k4gY/4TtFblsA58wrAqHeTn5AvDeyZXyvw21sB9ePrPl11YlDmXc/ba4HnQZ6cSfoH3Wn
+wYyz4IS+lQj0XcCFny1rWaFdNglhknrmHdtobri7oz/0hV+d7sfxmo2exTmiS+04oOhg+PgwDNo
veZehiyeoniw3ZAtxRxrHJfoZQYjojTM/JOqTj5m8wxsiUDlPORMAGkPh3dmbE8L22mwg6vnbaDM
ciWP/XncsRlCpC0fxbH8K/txi9n4HYPKLFrcJUAPXOlSaguP5m+zC+U3PDIhkqEW7tZG0/JfxAVF
lX94oOmaR7PqBEsFRJ9AkxO4H3Kl6F0FW8/vytjM45TLFMlEu62jfAXSxaA4KteKJPqz79iSNELx
2JZGK3GTCmxjXZZp6Vs9973KA4JGTJM1mtGcdxBJGdYyugwHAGuMWEM/2q6Fj1jsw7Viknwoib/u
soFAPho25QgEYKsTwtmbf4jhKJ1WRwA6iDeVuOnL42laP0JyJSDB7ih4Ytmr0PXLos+0iMLZqdv/
cMhIktuAYSLO2FAR6W43zhGX5xaCSAPCWrns7owB8OMETLGewHMdPzpDG0j/KJPycjEqa71knFHp
T5m9Y7cjwOocK4ofBf9Kff8bsnkSHOSs8ezD2Goo3isCl2vBisLfrNhYFkwYNf1gFUNaFG5cpWJT
uet5MHYJrFV5A4fxcBDuztC2rIAGL3KOf5XuXhYw2j3fBcUYpnbSfGVjyFEV/cJ1tNqYzbGoq+fv
BLW5KTxCPX6zS31Xb4o3E+43c27Bq7ett0VlmhLtyxUw5orne0yIf3yw6jfGfL+dYLqKxGbV7UA5
QujTfAkQeqdo5xVkZYHM9a9OkQ5sCmfeI3SRSbiDnnBu+mpwJwXADyQ5dosAg4nL4O5CtM1Zturf
kNbMYK1ZCMSD3DCBqRnxBCtXlWvVs22+2qx/rBf0+XjXRi74eFfSM0pBFOS3TAPhqRUnjZnAqp7h
WKfUjQeJ69ZxF2INjqw9C6XEQxoupxiJDBW+D2C1+72rCKiUSGUyn9y8xvx/4J+OAC3T7NnoAKKM
cdgMu2Xy8qdhF8pt1m60SdP+JP0XQobEtqLDf2gbrq0idEU1xeNyVO1ozwL/RpX5IFJ5VwGrH/i1
Gq8mQYzwRPkNu6A7115cLEMiSz42oMQNIJ+8lg0gW5eDETZrZdvRtq5gJ0mDCmsZJsJp9440HeO6
MrnHxYxbxrezGJzbUX/DhlxPLczqfsy9xhkIrcx02Ka6dNQSobRA06IsQE2Gztg/Ff5/hj8i8URk
gD9yc22s79kN9lYc/Q4y+A3FrVkMRu4myQYkbRcazMd7YRg3i7gf6YImLcaBvqepiTzlwNngTj1R
WaquTwsXQDAm2BVZ9mDpFuH6au6j+6ZSx4jpqo+ZrPri+szEE7U2/x0xrnYt0rWYwVD+nBjR8W7V
eHz/qpqvj+tq1fX75pY2cEbPm73Z0d0bE55fCY0AUuYEFCEL31rLJ0ESG/NDRVc/KNYop7FWo53K
zYS4YFVM5xbizufyHtRY0SzFiWke88ZNjhaUCDe0cuI+I40TaUvcoBObsN5DJ3jmzvsH0eWi92ml
QRHeYjqrLG7szSqSWo7PzSI5KpQ/VBFVQgLbjkI0tbYa4N7Wk5FKfu6wrCHH+mYUCYntL5v0iyAa
isPt2A2Nd7EngWRmHq5lztNSjU9ExSRPeQRgIUC7I0BAuVKAjvM3hlKM0AJG8ePqiiXSD8LmD0VR
LSmabCud2ByM/tv6qQPSKm+X18proA8k1I8BBwKloQeCuWUZBbu7tBv0CZl/6MXNCVG9xrQlWfz9
Fo5+a1y/QSxI0n6RuJ4fWdySEUMJdQRP/DN+aDmWb+sqa0zv7mW8iqsdRFBPVqeTcjnJKz7Ib909
QftUuRVw1viqftfhYjNFwZxJUfZJqh89YdaUamXjQJRm7tudhKRGyuKAjD1VNCMx1oaUla5wGs9z
9Z8HYloOVpLvtZ7RIRwD0oGZgGH06x7AMdXgJZlgBLIq8Z2cB4eEESXYiAwdDFLUDfZ6AoXa3Yln
5x1cHxFEYauE6f0ICXhD9th3fY/0mgmCImwaWZ+dju4f758WV9/8bqg+nwaCTVPtwtBq2h8X7gpA
HNsusKq3Pb/nDYuW7tVYKyuumo0tepWjWZe99RFZRTdDGnOHDRLWcPWmgn4jh8PTP1AtJZvb8QQY
1+qzSzHfqCA5MDFcTlJvcEDIjZ645dTdIp6m58gZaDqJDNM+WZpPGKKadKi0uQOQlMHknDjEZPad
fpMqHkwiPxAbPPERTdZwTNM0HDQKNmjEmUC11lejaFmHCKY4Lm1dBKfHmOKK/N1t5274r5kCyYPv
8AKuaQhbwjHkqaua2OW+VecVovR4nx99Jc1AFLEOZfbyDrywOkK8Y9WzZFFxxAZeNOeCpQqJNFEG
CVgeokxga/enI22MOn6PRPiNByVC3axtz7id3f6t9mUkUHGQzyj9nMcRtKmwdGrNwutkh1t+8eQT
Z2BDvrgl2hF0to+cUs/HOgBF1bUR0Ab4+VAVNYeEbULcETiI450PuLGbrTjptBM2j+K3Eha5riRu
H6cJ2vtMDH+4Q1GYsBsnNYDEO/euiuTA17BHR0dSGAEGQqSQEbvTJl8TPWc6vqcz9aHzBeZslyJH
9xMjupBqlqnyKO93p9L4aupBw3ytunpVWKxClGy+ZxS8sPOLEOMmIKq+Xn75tcq0Mi/GfIYfeFIE
tFHNn2m6LRb8fE+u1sVzIspMJH8TBMRNUaqo/7sUP64pq2pWfPza96wb/+2CR5duCjOLYjZO0aQ6
chK3LtkHGWMoITvmEHHFZFA7z/ZLpWxCqCFd6mELPMNAy2uiQL5xa+PT1oDuhneDqVqfHLP9OWz6
Sdx8LMJbSZOBsF8VO8dcf9D30RW5rRgtJgP3pVj8wUWCeZjc/36bpDNEKh13zxGPbYHS53PXZni1
nhoIvB7tbfOwlOLBPimEgVy2pRPF7qIvnY2+avkCbrEo3So9BQtBkmQj6KsDbUXLQrb8MntlLbG0
yf96jiqaAbFAHKI8xmLTsiQ9EPy/8RpbHnq+JI4F8Ao/SJhJoRpRQMs0KQdFEVX3WCKlg5Ay29mk
HTpAkn50gx5gnrBfWgfrG8tnyymsnLC2rx2aWAg0QRzCgCPlWgszIsuAGF1UW+Tpg9Tw/LK5UpTt
ndXcgJtV8V1OA2r5LWXSaTWV+IRbQTEJrKDSnJiBLJSoYQr8rnav3O2pj5H3Dw2AnNsvCNOrp9rr
HYldh3FCrbKaWIXXNKkkoNMhGUDnsSoaSD0cs8RYxRQz5uULEamQGZ9Nd/nfYbiVs542QStLETyc
Xw179T/FMkf+ub5pCqVMLf1lb12gQsSABGdWwvTrpzVMU81MyifQ9ODIbmEJtuIJl95UYhzy4vel
2v9upViCwFAHru/dt4vHt/hMcBPLTlDzuJFyAkh4Rg3DmUYNNtfnpwrIKhAMdjIU9axE3ld90aTZ
kcqwPGjw9iMN5OvDy9bhAO1SfG53P8RFSlUvZu8WF4qoMT+bouL8bozH7TfLGXMKGtaNfEOgSvjb
/lIuAK802cx6Coc+oLP7yHROZnpzqN6Yp7irLV6PB4jOyR+IAyYE8NWpJmJZ+L3jvLBhFGT4k4/v
4HMKn4AhwPp0YldS+HoNRQJM/teMhfZBe67xXkyZjeK6iYbmc3YtWpMWB+jKbCfjkrqfEMFKvFFU
nAUnQiKiAFirM7Ktyc4NhuoV8Y8YO3aDDJ4QrelkWW1lma2/15Gyf1RL4oduLNwzwe9HUeTk0AQ1
Gmaa68ytZ6MTmw7g6rVh0a/YFgBfUcD4uqKWu4CqRei0l6TRWY6UnALI4BfiRjDN23FlALSSI3ZV
hN46UBauE5Fc2at8eRIAL6JMZIWXQ6NaXO6NaZ++ZwnaT2zFg9hon5gGhfXWzDT06aJ9r5nZx1a+
B6XVypqL0/aElBvfe26lr601YsCLwVu+/La9mTNH88fsImcABiKe7bTkP9vukyTcKg9XRiD6H6B4
dlpF/vy+NrW4DykrweLyvQAplVgPGaluCyj0kX8qHh9avBj7b/Be/zh9+CE5mJv3x2UraZ1eDI1f
94ea0PthmHe/cwAhM/dbfr4NdMNBSEA4/Lnf5r+UffB2sNgTW7C+MOyfb7FSmAALKF38PibIb6GQ
ZGNCGIjyAcXwccaY70rhywIg3op8lSk9rhkjQKeo/JNR/lHYH0eFHYnK6o/20pIAinweIfv7uZot
EfObiIZfbPpytBYzHNLGL4JhJ/eM4Kdxfx3MoYh+PEmpKCypDWbdSg9SItTCfT+zxc5+6qCPUyPQ
8Sca9VInmnPrIUe6rNA0prqG5eebxLH4adHm0H2O0l8TV3CXYqeuzAKzAfP3Ss4hDjHOtLYjER3h
ceKosffxd8nnrXTxBkelOxY9etR12D1wNTKDLnZKFDgk8tdVOVdS9FPC+h+By/R5NwkX+LPkz4GG
1z3zAgANy9qRJjjH4acUGvVTghI8JqFi9k61r2faPs/7ZZPz4IRJHnHcLkvJB1QO2uV/KBPRw4hA
CJvcTd3Ekt6h81NPYV2NcXf/NSzmIKi6nAFqgpaKbFAm2+BE99k6muLPB3mRcZbo00eoKM6o4Z9p
06M3fe0VZB2NDnq8qx/JayLXhcItjJa8qHQbezvypNNISOeyeNAy+h6p9owbcWuwoQABg/No5tZc
p4fj/9ducdMV/3nccjwN6QlgckH8vD1CqFwHWjx7bI8t+eajMmqcdWMF0cFjqeunUxb1+UMr9khz
bGGvYLHzeN38zxHCvt6D5hOaZDZ8Ds9DGfzQMb8EHe9JFnlaAYBy4xy5Zz+pYbLmU1/LoMwCBCM0
jFuGuZdY60S4dwQrxHcuD6IdNCFRFbHQjvy25HHnwhTOwqPOLgREeJ5dWHQzzq1NKSe0VIW2ZFo5
GmYq9KcixvtH60WGOBB27+xI0VKkRXBqktIRd2ps70qjYRzUo139JdCn9lCpMbrzDsrel5regZGv
W2dA/xGAy0qjg//A9OxdHJn1WUSmKj9mn3RcwXVqwKuxpVzxx/UeALK3HpkVsawj97Ye4FYcVORg
1HBLZQxyM+VxOxf01TC7QRxJxyLkf4KWEN9iyrRLHhmrq1K6zjef87fgBnsW5gYL6lrezjBozKEI
oYmScpzKRc81dzf+BqSG9N1CQwETICXKU3vVA8iwXL+TyZ0eONJ5pXFGjSuh4+yGrIBqds1OeTHI
5ZgVe1DvxmY1olkFch5QURO3+bIhJzcAnL25pP4uXdZVz70Nix6XUUAiA2ftIpH3x/ysoF6eXcJw
9aRyKasdJLVIALicauzjJbvkBhUMzpchdGTeaTUsvAn4PBTPf4L9b6wYu5QjjXVPQt9XxATBmxwi
lkiE5OwMPwXcMmtGyw3ZyA8fXjuSkHKBGkh2IQvvqQOvY/dZkwxq0EELTMmH/U74CLnirc5wvKNt
hLayzxQ5qHq2vQ8zd4P/1v1G/pW5DqL8Wz0ZyzEy2v87w/eN09wAzZst6Rpr9JSs/tPOM6ISqSg6
SgTuQF6bjj2hDKaicfxwWz7UI13gLUy86p4EYCHsMBBtEGpGTe8d3YDtjTZdl9h32X8CSkecpm4T
FgLdpHY566GKY06LOTdiOfiuF/7w9yfCbJL80FHlUnpJlYgiMh+1RZ0jaOXBWOFdAzkWmyYtexel
yQ+rslOzsOyRr8USI1hahXnMJXNcX4Hzzp+n8mb+AsjeRRwxtXy2DgVXWFwznS5voBaK3471k6Xc
u4vCdC4EiceD3ILx5/EUmUw1H9CR2P6gOkonlxhdrqA0X8Qb1Wmc5L4IOBZe1H+cKJNuGxSMuySW
nmm7OECPWzyvE2vp4EKoGae9Rrq5d2IFc3aYkweNcl3HCIaZdO++eB8jwHzUjHLGF+L2C1ApslWy
rcU=
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
