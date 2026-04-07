// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Fri Apr  3 02:22:19 2026
// Host        : 13600kf running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               e:/course/master/mamba/Cmamba_reconstruct/HW_reconstruct/project_mamba_all1/project_mamba_all1.gen/sources_1/ip/inproj_ht_sram_ip_1/inproj_ht_sram_ip_sim_netlist.v
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
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 51968)
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
