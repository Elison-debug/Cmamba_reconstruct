// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Thu Apr 16 07:38:01 2026
// Host        : 13600kf running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               e:/course/smamba/HW_reconstruct/project_mamba_all1/project_mamba_all1.gen/sources_1/ip/inproj_ht_sram_ip/inproj_ht_sram_ip_sim_netlist.v
// Design      : inproj_ht_sram_ip
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "inproj_ht_sram_ip,blk_mem_gen_v8_4_8,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module inproj_ht_sram_ip
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
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [4:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [63:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [63:0]douta;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB WE" *) input [0:0]web;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [4:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DIN" *) input [63:0]dinb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [63:0]doutb;

  wire [4:0]addra;
  wire [4:0]addrb;
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
  wire [4:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [4:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [63:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "5" *) 
  (* C_ADDRB_WIDTH = "5" *) 
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
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
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
  (* C_INIT_FILE = "inproj_ht_sram_ip.mem" *) 
  (* C_INIT_FILE_NAME = "inproj_ht_sram_ip.mif" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "1" *) 
  (* C_MEM_TYPE = "2" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "32" *) 
  (* C_READ_DEPTH_B = "32" *) 
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
  (* C_WRITE_DEPTH_A = "32" *) 
  (* C_WRITE_DEPTH_B = "32" *) 
  (* C_WRITE_MODE_A = "READ_FIRST" *) 
  (* C_WRITE_MODE_B = "READ_FIRST" *) 
  (* C_WRITE_WIDTH_A = "64" *) 
  (* C_WRITE_WIDTH_B = "64" *) 
  (* C_XDEVICEFAMILY = "zynquplus" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  inproj_ht_sram_ip_blk_mem_gen_v8_4_8 U0
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
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[4:0]),
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
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[4:0]),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 52000)
`pragma protect data_block
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
GwudP8U06iWYR7hlKmQjyw==
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
