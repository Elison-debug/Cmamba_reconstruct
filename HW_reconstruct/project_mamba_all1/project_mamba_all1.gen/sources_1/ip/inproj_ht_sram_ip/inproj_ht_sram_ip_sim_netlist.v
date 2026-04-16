// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Wed Apr  8 02:26:51 2026
// Host        : 13600kf running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               e:/course/master/mamba/Cmamba_reconstruct/HW_reconstruct/project_mamba_all1/project_mamba_all1.gen/sources_1/ip/inproj_ht_sram_ip/inproj_ht_sram_ip_sim_netlist.v
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 52400)
`pragma protect data_block
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
qOCeO3WJhmaQN+Fs5x3tg1Y=
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
