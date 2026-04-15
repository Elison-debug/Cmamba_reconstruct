// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Tue Apr 14 02:32:38 2026
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     8.703259 mW" *) 
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
  (* C_USE_DEFAULT_DATA = "1" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "32" *) 
  (* C_WRITE_DEPTH_B = "32" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 52416)
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
