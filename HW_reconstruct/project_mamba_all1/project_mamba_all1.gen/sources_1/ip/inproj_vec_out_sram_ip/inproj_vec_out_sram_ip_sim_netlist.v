// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Thu Apr 16 06:38:27 2026
// Host        : 13600kf running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               e:/course/smamba/HW_reconstruct/project_mamba_all1/project_mamba_all1.gen/sources_1/ip/inproj_vec_out_sram_ip/inproj_vec_out_sram_ip_sim_netlist.v
// Design      : inproj_vec_out_sram_ip
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "inproj_vec_out_sram_ip,blk_mem_gen_v8_4_8,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module inproj_vec_out_sram_ip
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
  (* C_INIT_FILE = "inproj_vec_out_sram_ip.mem" *) 
  (* C_INIT_FILE_NAME = "inproj_vec_out_sram_ip.mif" *) 
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
  inproj_vec_out_sram_ip_blk_mem_gen_v8_4_8 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 52144)
`pragma protect data_block
T1TulI8DO+ZvQKDUF1qzik6eH3fyh/PSeOxi5oAkGSW0tDeoi1Y7Z4pG7l5vidIN3XhBnTgNGLc6
foei6KaJjOsMRv2Yz8EKKPL/AdHMUiY4lm25nPZBjn20H3bRaY+DHJCHidjhBjLcmI5EwLm4VsuB
5t5/YgfxlgbKCA8oPHfkMCQ4WAW+ko+OZs/FLsCqL1NemgRqmUEXn3ijSyYEZWelxVGxkSOgI/Do
AWOmeBUOVh1gT/c+U4HdNUGBUEnQYY78ERDfhxXtka9qO2b+ljUeIf/Dcxh14fM/p9v/tmLTBsJX
KAx84lUT+v46tpz6Kg2paTiW/oQ0R85nkZE1Hvi/hIR7GEHbgEumo2tCvyesnTvsbntRf8Gx5i61
d9u2MzfSXBuKlIFRjmxobJKURvuoCEnB5LdMCTZRYsvn2Eo0ApjTS+1Ci57Ig8TdZwx3hNad4E2H
k9cS8i15o9sQ/UMAvtcna3RBVZ3WEi+DDmEKN0b8eebb1Zq/AKw9wwyvIA1I4OSbmKlpoSc/YHx1
Jes16teobXrbMQ6cFPPpkLr05TKmTY8vCQ9apvD+RW5ybmoBkekAxMtDsILvmBzavLjfIfBUbjwT
JdlPM6ZloUsvsQDeBTR0T9XrcHb73ig8C4iM/XSuThYwPYFlU/PmRAkVyXyf/2R1jJ2nlvBdeEaj
p/O4+fq1DPQqE2hKUqkPWou1auwBv1YYFvKzLiKoPsL6kKCgPuU/OzykK6tNLOHikwaEjZ+Wp2Ae
afLOwa09gMeJD+h6vb30JTlY6y7Jor8mp1n/fQeLayPf92PGLDoZHH9dej7D9zb3q0QG3965WMiL
Hxpw6HEfxA/JzIFvI7hiLCSotecn7JCJz1tCoRFzi0QF/eB3t79K9zxkACyZPMMv2GpugUVXkD8q
SSSPONP7WdTcvhldsaZ6Qj/jE75PZpCfYSJ/lv2BChivX5IHKe+vQxJsOLQELSjYOAqXPPU1Elf4
ARRxxtp/plZ/spOoR1kmxAuW/M17hvi1U+livXnywO9VuuIeaToPfdU78lmTkgD0+f1ymiek0tGI
cqvexcDRycQdHpSpAGDnjvHshRRgA5vE+03V/0MyEPlX1rwWdEijdJ8X/B1JwPZILuMYHQeatZR0
YRogMIqQjhV5Vm6cKajExO0oUE5FXfIu69xZniYZyJoaY2l1AdwewRmdrKkOF1xBTGIyzzvJcmD/
23G2tDHNmmvb4Su5ta14zY1FaJm9Rg3yNZfA67pfcJRohEigQf8dGCHqzD5xLV09tBkDkiqPPT86
SqqzWYFMFXKS8nQOJ/3FmBDX3mnN9w5CP7UCMaPK3+qY7OL60p3GN+oQjSxz4Q6BY9UTWFtJ8rFi
xrydXHB775mhk5Uu3+J8y2o+WzuF3L2m+Y3RgzlTwPv5OiskhQ8rcuBIyjUZPSWCRNRMcb+DL3H7
xQVV68WUIhWcrSKsRwjcYaojLnK7t0YxQ4gtkYAutoH6EGcpAkyNgrljhlnKe/vMhQpHGpHx+VmC
GZKRdhpG9FI9eYzEp/Erdy6uOQz/KECrlokc+ANRrAw23BLXaQ8nKC4XmYaHN0LST0mCqUamA9gs
PqyFPuIhVh1izBn26GtAmFSalAI9g1KAHZF5S/7kF7LdSZt2cAxlB5EsXug+JnmisE6T/DUsPWIk
0YN/V13q9qdcVotan2ughD6Ky4SwqA6SxEm9Kn5vGqJIoTm0Il0G2u+2L9BuRSyP+mZM5rqr9mWm
WEO9dWBjKGnro6TR607/h37bfHadU7uFfkkVrWJWpRcoRnV+c5nPBIxT1CxwJsgT55rqEhPCuH6K
3OwPcnObq0fmktxAwSXVtQm4bBAk4xoA0tdfoEm4B7vdyfuP0+8eUa7SmnGVCm/DqHv7SM3D5VqD
67d9iNL/EZ2q8Zgv5WYYEZBllH9CkhCb3azUpzgMpNMlacoVHAIWIf3yEcPGP2alKR2xwc+jRjdE
MvI04xkMiwN2SVJXnlXqUTwVymdlg9VJeX/n927nhpsSeq+N9bK/5jltcW4AtkTNLN/1VbycZ+5v
L8BQKk8+Zm+XZgQUe1+R10IuTYDRkOSRerEsolyoEOOiZvXaN75Y4DoN74AwY6o1sN9KySNIHj8p
fVroxQAfpxzi7LA1jyJch2hhRsd726kMsjIejSbm2TZ1SLcBQI38MZF8AtKU5yzctpua0d7r28gO
7HKo8VNJa8e3RhpkRu+vAjtygBS5H69JIjisP8kll+ZyRpT3T9IrYRzLdk7ndJyXH0jXbCE9l5oL
XaV/687DszdnhU7tHhR7FVVCsHQsD/Xzw+BWobdM5zG0TJ8cHqrOZAWOPu0KzAUP7X8tqFKzlaZw
suOKtVnp4UosXHEvzoZ5Y3ZX5IUPANcFmKgQj5PKRhljLjpMXNjK3oL7BQgbJ9lBa3fGmO8onWVs
rBmztfT8iYCvY5f25Hr57NK9ygNvlUGbclRYiDVxWNeOLbiZ9ai52Wprb72VDODIWFdIR64a3rO4
AOSQ2ZqDgADEkuLA21hhP1Fl5EW5d68xw4eKZU6utH3KYUsB6LIhQc6uPjpj+Pcrre78dOvwi1gP
TJN8cJqfPSr3y21YHCA24hbQKgxm3sdpX3CoO0QUB/cx+k4Ei9CAMuQVLOt9lDHjB5T/giduKGDK
2OvsHyH0jH9DQzqv1N5yRkmPHV+vMvqwdIu1S9yzxi3ogX4j5DgSTFKr2iyP6MyvrcpLMPKq4wRI
tcW0TwY1vKGZy68yW4FGPOhepzjO5b4BJ4n1+esb0RfH0Db5gD7H27h/0Rw8bfUWjerNI/NCqFsF
o2I8wxccWhuTXlhHr9q6PhXeECOJgYCv68aaH70C4Tj8crBycaKVDb9jBqQl0z1N77hf0UZsl469
QxHmdRY7AfLt5v3DgBME7z/qxajo87VXdQs4KNWvBJ3H/u0EQITf799iIe9zyF5Ysu/OTYRx1OBv
uuwwRhuRyXIaNDzuuWfQNFpXRzSbrfV7Wr/ua1By+2armbnnzCoptUKzwtPQjRpNe1bhxjJuqcTd
HvgSvRhoHzLkTOsKd/wCi9C0GPpp3jI6fNGwiKgj1yRRW6JMf+J5xNPHtpQwOZic9JO+IL9opIeQ
5LMIDOsOzZPbiwFjOKGXkF4Oyu3d0WbdPi6V1fDai39tBuhytw9zglwvm+ImQAjFg4ePAcMRFfwg
oIJoRLa76ledwYZ7nITPEnOc7k6lAr9Oalx7UKz1cin044pe4V+2DWhJmsrxkPh5heLn1FAQfFId
kr1Bj9peoUZjf8rxab0HQL7QwJSUXL6LGbSYj0ICOSdLLgI8W20u8goV/EPYTmr4KNnsPd+VGXdu
kCwOm3O96N0B6jab2bNtyWZglNMDdPLohsxt4h24+VZuwwcXJPAWki63W7cVBAJMgsQM81m1w57p
DjmQczfo88toYvN23B5iIttQbzdGWPMmZ4QzVGOAoH/+z8ynQALphhwGaMOnF+IVl7jMZNAG/bW6
6HogcWz8or4bc8BzZsItkSit5D4VNLQ3Vh/HuRfU/efwlBruYhrpB1kHLZDU/9l33GgbINfl0GG+
4H4VUFMzO+OAuoHEZoee5QqA7P25EiMRjlp9bEVsojwJIuhmWaTStkZ9tzye1tpXMjFGJNyWXhag
GykpX0dO13JAaIAoWvLjlJMZj0CUL5AY0ndvg9qDRGPkyxjxU1y5E2ZnG2bKc4WsQs9RsDWxnxJC
M1iYaordfqf9PNlqtumJ4J793Y4X5ljuX1XDdDuKy7fD4lI6/KW++fPN8/iqzG/rUtuk37f3c+uJ
abaaL17XcH2/lIebYY74FqBls35JsGdZ8Ie5xlFjrpEE3r4Q6jT/Y0T3UqIbsuB/oGAbAooYpvll
TqN4M4dMbquTbPu3kkTfk7YL4XWibBG2tya9oWfCoMl0srn03xFgZXmeMUAzTRBRapzaPZBu73pq
VIk3UkziCbiIxH00ZBbnY6RTFeoFZ7CDMk4LWGULqwrIhsFFEPMB13cAGvsw0zpLIMSvEuCixwSK
iQEfEkYXC13SOT/LYCf4Tff/caIW9+wW9jcxuWdru1L0fbniWcsZ3+xje2mP/O4mdzsBkCuIY5PA
QdmCnHYKAC4Jj7ekU1U26ArtiB79H9qvbq3sIuXVFOeHZQ0wPSM+UqHe9XsSNK8Hzg7PcIM0S+S3
ZLsNnB7kILF8iD7ZTRXNzGH+HHLX5qNqN5hX/qOZeqSAObUyURw03pAVrqwmT6rB3hDTk92XPUzQ
3Y/V7GBxFcz8tGEOJpbSEWsJsz/tAxmv8aDTny/2wdVcPDJNrvvLee90Bx8Ux5JcmB//S02pZbG5
m76lW3koBsxu3o5SrJ1Hzo96dlks0mw8vgVYv9KM68sJ190VnVsmtuCAZlCKj6d5j9m5MDzkjiBb
QlwspAAih+VcGyh29USBhZb+UrBz8dqK03Az7r70nhSWNHYnlqLVyOSU7P+pH/h7hLosUZ/Ifm4m
NHOzbz6ecVMOOcKljLcxi/Bqk0R1s2mFv3suXToM6fqgTHc3tkSjfLs2uL8gb/4zUvYYmW52ffVp
Bo6sTnW7H7J3yz3L8CArKoCthsJd20Sdf3j/pdzjWaF/dkS2KKKLz3sr/APIcYhzBqRRhLqjwYVg
m84NT9j00nXVwKeVsx6+6RuWh3NUDp5qcBfCqCeBJ6pFALadCklJ3cD/GeTk1i/nPOPNx8Y2/M2A
b9ILq8RUReVGTGzse9WMGYddzQz5PCMehl69c7anqtyG9CYDyPX1465hn+U9fRD6ZH7o5cnnT0SG
Wukg8xsn/WtZlG+KYXLXBZ28iHfRiGvCe/gy7IfICUkNGR+C7aCBQEco1nMLZpJzLtvdvY64PF95
ijb8KvlWJWBrlFa9nX4k6vLMFAKFDw1w3r89eb+Kzop841XGmNJetP/CnaN9NzRQ49tGzbpY7WZE
hxStXdgLKCvggKYtI5vvtvp4myarXaGhCje48W3MZc5E2HayJQMqDUSUodvp6Vz7B9yzrOSkByIM
vgTLFLGKgf8EfS8mxZt21srpiiRG3PD5FYEYFvLy5AWeJUAS18c4Q22r/pH5kfMmeEBExTxsNG6r
46N23/UP5IK1ZZEjhrcoZdXGtnfkSluXQxqaNKadEXnD7R+70kLT/Grq26hOoQEKmK+9EniuvKad
jufU0rie6AnAa59ZgBRpAdcHdmWQXU6ctGSjv7POvNq0ur0kwG096bHrYkuCFyli7fBxenQHTfxF
QwERDjMwbKvsQABgRYPPMg42aybZrMTZcAAtyTBEVI0VQQJ9vZyYzDCB0wDWxk+YBCArUrXASIAc
P5ANNdCCl44hKKvIOBm8Rglv6EECodr8fvEImvJMlPcPSrK0N+ZBsS4L/uXO9cT5YbDlGgyV9PX7
fnjhGkGaUbCiuQKfhqONDB4FWRTDk4tiplUb2AmSnHNUSft5HfBWL4H1LiZuW/ppJI4Ilug6wFOL
hX0NBzoQw8ISEzeJ9UZWNpMiBt2MMPQpoKDls11rRyTINqopWKCEyUkkUPULKRYaLSGCqPiwZw2w
E0n0zN6XqtOqUT0zGIrq4CNmMVtNI6QywWVXWebzwdRM6mfFVuaJUIgTsDJGkxIe60j98KiEXM3c
csHKg/3kHdaC9MYYNl+IdfgR1vkJoLk4RJMfv7kc5s/t1cmjqPDTdxVNTePWXKG5QR1ISvkvbvsz
boCQABwmI+XpxNKij6v4ZHC8R5zduUtlLir3dlU1bFZlQFp+ULpqKHOWNz5LECOGMXN8JzZWfaqh
vO2RWB8xjWcZ8XrSNImUyBdfj5bg1Ob76Tck4mwmnNdAMH7TAvOt1cU31hkqecery5YH+LXwu94c
eZr0RVhKf0Weq4Gj31xe+OBj8Dr6zQ26tPuydyVT7HH9Dp7+Nw3WWNHYn2+umZ3UBZ+WUrAxdntt
2TgKhdhyip9vRG+SA1gAc1y02qIEfnWypTKxmmwk1d5oIYsct2CByEwTdCSH3NMpqS2lX4819QmW
O88efka6T8OSJTVi1UYnMktWPNdaXc1LAGiVdsqO/fp7fX6r2GB5crI6vNV4aaWf5H9czz5KOjjY
ywrxSI1th20od7OUTS870TR0Y5xtUL9BWO6Rbd8mWz1sJkENSky4txfHvJL9LVgeF3wYTz0P2O3z
1XBtNNmEcAIu1glGxg0X/uQfQHkL1z4zO3yitPK1c0lmBzLzWjo88vLb/dorZLrj9bfeS4hroyrd
B5QtnDFaT+p1gflBKtFa0SjQ0pXL7MDMWC/x2D4ubj+NI/yLUZHqQ8m4ikw+3CIoalYYiX2Ii+7S
0nXg4luUV9pWI91RkDgyzSpzUkvUhxCFME4fm7cu5vhoTOA9/txfmuxFhgCjSqG67niWDNLfyTyu
krr5/Oe3g+To4MIZbRpg7f3CvikljrdVF2z5Ylo7n67eENnHGx3m/rfsaZ2ijo8gm3DY3CDVpOAQ
MGYNsvojhSmTMmolhwE3xYmGT1LAMhXEe2BM0+NwUwr1hU8UP55xYG9CxGzJnPrPM8Ne7H2ptGYo
r9YSJnvSiScA6XOaQ1Slv2MMgozB3FQFxktdQR7kk55ZYmyHnFZ1wn+JfN98Tu7oUgH9YQ4vhKbj
bcMWbRHS2LyJnaqaxF1qZllEINRps1DRfQ8fR7pGaEP0gt2BjMDh0uyE8v7eAfmOZopfPLBr5osd
914/Iyoo0h/NSmd+Hqjfsx6F5eydpEIMko6auqzDy5xQ+kjE1JraaFrniZx8qlqYem19AkX3BN4b
hvmw+jCsESgg2Xi9w95JB7KdBEA0nB7NQSIM2MYFkcOcptOOD08X/QWtWXCwAGfHnuWpdi687xO0
itf1Myu6uY9mUpi7s7OllyoP11N/j/HaApUC6exDDw1nwlmEeIZdBz7UrevBJ87cihdlu0i/pOnb
owlFYAhvalLvih5eCtTci23qP81AUeqrQ8eR8Doqc4lZsu/B8FZ21Yc3J0XXBoavY2ZRNcaojIJG
lgDVFKbGNUAcVNKtRvVHCS0qoAdPVqdIHx4kBNAyJvEEeJBRmi8NpmUdXQm0kf+BVJiKre92WqL3
zjM7fGzYosLef2XtSJJFJDqHbIbffmPVlv4+cErlPfL3XYZSPODmobdRy9nGSfMHX8BBjHm0a0L1
19JaxqryD5nZ4AgDbkpUCdSZKzwdtNB0LubaX3Rn2TIWi8TArfH9O9lj4FyFm+wICiTHe+QlaRM7
takjtLyQF5KC51nArBduxYlnf03k7AA6BmFf7FEcN6+1767iGOQg1/PVQJ5YFX/ADTDqZ0PfVTba
gjBJsGkgQUHR8vsD/ikRWouNdBjNOAxY2tadnXQVfqgQs7NLdWClhpQmKIqyCj1LldaIHY3+O10N
iTbT07RV7XwTWaYMIYnvVFrb/TEI1JngpXi8XkAC8DfN13oAqtGIPesaLvG3MuLpjyn7rJqx92J2
G6pd+LbMhcp4fA3OWrbQCiPol+GAkJBgtu6pQB0TpD71w+7mgxnr+iLtnUNHw8c1MzqhuYONFm9k
tcWnzAvMVV+wRA6Y9kfYLYgVJLntIUUAjtdiklUNulWOp8mjXugsEnEecsX4QPYdDkGIfAG7nh+N
GvvxpkIpKi36+dWCz+5EE4AYyxBzW9FbpRy9atK0C05mlVR6JxzfdV54MFDM15t8I/I2f/O/DOzq
shQWwVHO/x7cZTVFCOv08FEjj3sva3SO0C4UdPi+0TFj57A3kcPgXRk0vQfKXHt1rMc5ckDDdy3A
6LrAQERQlWP6ek0vam/yRWIRPAGRshThGFnq8+ukjAMaS7efVfsmAJG/2kbuWuSzOVtSpEp0pxPm
t2qS8VhTW8DTT0GDT6voDNgy25GGNDuxluEnZ90rSW2I5JW0jAw7bMENvkfWTU0w9LFolgRayGJp
VXbtUoEXuNLNfzCOdE67gFmUqMNIj6++cWnwP4+ZJrhicCH0FFpJCX3f7OANk/WCwAMr8CmeyAQ7
WWkc4njU2XWwtbtSbKsBFpKZHYNlxidylTYuFVRVt+0I0viKjl44oixj4+kNLb9TTtV6f82ai93L
QpHDPrI8TqyUwyvFhzE9V3Sm9ZrE5+EkFpGE/147nLtUP1323nAWXJHu0vuP06fRf1Ji5rAPf0gR
spe80OduRy6rsuzCxXGSBpN79D+YSPeE9QkhUvezwJTBgyZ1yFTzmekPc99Hhrgk5dh2XijYC5P+
hqzshd5s3PHmmQOXESXb413B7HRap5L9dHmSZs6Bg2wvaWhwRGRx8gVVdBMRacBkrZIG11eBTSXi
LJdppGzRV71oUZhsDkgTjOyaInKkU8piiavr5YQfa+B27aBMoRXbvAvKgo0UMVZqrerEf2WRcLvz
IIX+swaufx24hCm+t/I6A3YNC+7LJtC/3Him6jfKKiW2jo+xSbYQvOy+OHrbIZZLBjwS0U/FCzJv
YsjY+NjK3Cn5KkjqgauTSa3B6hN7EQl1fZR0yylJ4woEdMXB80CStZgq1EnYKaIJwlHAypuWdF49
5v9tZWOqRxqSRjSQzYppGasjjG8LVqmSuwd+g5yA6m6IhalDkYalqZ5HrfzOjz5HDV4oi3IgFk67
c54nnSZ5T/qg+8h3JLuw/1MbozNYgBllj5tYsKltKIUr3ZBYJATsXp6JGOzAhZ4qSoJH5xPCNfOB
/2vNUyIO8Espie/BLrgeEJ6txAN4PqWvqU75J1fQai6cV04SrFRM0l1nbjql+FwWNLuSKXHqIkaE
eXO/X0X105OgNF+iX342ZJhJPhOnKuH421JT/InjFTv6yxwGE1S1W73Vh/AE1gFKct1wS4DADBXm
nYdJbudXcGc10ZxZh6ydyhmja96fFmp56nbtFaQgjPi85BkKzK+GuTSZdG8rGaxNjOYdyeKSVt9B
XhCbOO3blv/c7wo/gL9stsSJUHOwnZ2zleIEsZRGRb4f9kmTqJk29uUjBsFgvVY8M4//AZuR8TQZ
UHyu83k6cIlH9umc1StWnIdwsFlOaynZB2x/DSziFiZ1lyIcBrgi/XJmlRFikI8PUG0S7vIXL1LD
weHfWJC0whuHuYpiZwnswDTcFoto18jlWD20TYfQirTtTRT3tgkn2tBLvs97rHv6DunIWhjd1Rau
LgEVZi1i6Y0DkrPsno0ltnu2NibaO/KtyAS//d9oFliy3gGPBJjitatgvUFnfYML8ccB9uY/sDEY
OlgfY3yVLcd7nIeSwB5FL6fmzm5H24atjVjnkydP4luupUof5XTSdsaqS30WTd1Yu1w4AtkV2KvC
fFjYmvxgBmdKx78Sd4nSdib0icaZviZKYblgi1ECWCGAptTLdCjtn2GrEf2RG94CAwy+oMMmGhKu
BA6qlwuCnf64QDbRmZWCWaBwI+F8kGohiGbLbjTIbIs43XGst+D2bc3Goh3CP03qJ89Vhs0OMUZs
TEgmWJeur4ExdbdxalW1QXtwKPCr3Co9Sp9DF5IM3XsuEjJgJ3E6IvaCt01SqnDoLclPJY0JlZYR
OhGJCY+qOrvyKb+XLi2R4gifyrSo8HjxPzXBc45Hby3droj6pJyhsYFk73wURD2nhru2tJZY/BfQ
G1SP06ZYppv97+m35CnbsDZJeTefzwiky95cAANcoPT0NoTHo4C1a44dl9Er2l/InZMa63vzPPwL
j/DeFa47K5ZhkDJT8ZQWo1R0joJOk/xLhx7YZN8iLrjpN8NVIDNfwk2A+C1N64rtvvz4/JdrL9Ff
LGMDYPUzaAWbkruQLaATq5xVZAppmPf/xjcD8vhRu4m8ZdGyKfyW86BOqWKHhxOgMrg3u2h1Si91
RxoV/JaUyQip9reADj7DAMSHk2OUMU5g+uSOemMHbGTsEV0+k2Y37oRZblFUFwrf6O0nevGzhHyb
kqTCS6NNIsIKDd4XcYINjzalPfokYIKSbHqfkqq91jDEXtf5ESTGZPag5s0s2VmOxBhUowOHVABo
ld5lOoFEbpCLI2ExwZQEvuw5wHd9x5T5ugy/T3eIo0469RLSdXSkQATGHV8jA5qfHD3HRdSqqlzk
TA1YhxvgYGak4T/5NY9N30iIrh79WRJ2AgSXDtMXRCOMMz+fSeWXqWa9eo+lxn//dFoCnK9sny5m
LmJ5DlzphFOafXblruED43PbEqQcF1lKfYQ8456AgU6fRYRLKOxh0bwmRRJEjhv58+zaIfJi6Ycd
ZM/UCmDaeyWXFjfz3DqtWzjB/+/08vMXDxpWuPTwsvnMTjHwqCNSMQZWnFSV+e5s/ylI5Vn7PNp9
Pz0QYo1j8LRCbBu+kLRKcWhe59Ol7qQ8cKjmd089AW/nGjzFFhGEOOOD4OYEnPdgCS6tVPaXOYWt
0IL4yrUm7CGI2UIWVufiK+ZR/japaCnXHgGH1gin0NwYsoSUqn5dwrYZIGdEFVHR3UDQYU3Ynpm2
cpp7qZzuUmr127GAOe8vYUYGzyuToaAAoy4KFGryH9IELCAy4x4jiVq+m8GEtE2D1T/13NWpttn3
AXjwjKDWxs7d6s7Q6L66YBrNJ+59ca2kxMr4+Cn0sBYSTiYa1TrdMlXJDdlUrRt9B1Tx70XhkYy5
V3APf80QVtR0pNKpR01e5BfXMYXQjtc5cYaG0kZrlaqYvW1Y4+1y6W/XrC8a7Z0qnrAuESyaQP2k
SJOQ4IhlLU+ZM6MpVF//QTt26x2PF9vsFRYu4h8KL23fKKXzOV2hHSusyoQj1YdYXfR1h9Ki8FyO
auCl2LJp8xET1Gxv9OOjeRFtbdN8B6Lh5hgud2f+SaAMFRRchCzt46OWYV0VagZgvqUWZBtQu/P1
6QZKlggYwgV5JDMrjlU5Tus6mHEXIoyH320RXwDFpe8GKuO3bCGqUU/b0tIRYYrUh8j5sLjTEvcx
SyK+G52ZqFoZih/natb0OA+DEHf9FLSPi5pGqPg811uHAgoIhRAFe2Bn8cWOsKuZjYSfKBr7vaMh
xKXxjoUYjULg2CZB1Guh6MCAMmO2EOOALhZYIhGwoKLoMpBZhgnloMxDIYGcrL2a0P9nWMVepl9H
LuMKYdfR917ilyILkNkatYP7w8lWLtvncsg/l0BdIrwEaPZ1BM40jkR8LEmUTFNUqh/0lM/ZOqfH
RQaduA1kJt0ZxupSV1J1QPo1v0sFD8eKUkYmayotPnB+rfyjhhu1GWK/SepqN3jfBjBzXZueIUXr
2yXIg86hMSEIK6oSg98xdddvg0EXOdI+VHIh7Q+2qmCkn6f5DeDtriWamyt8UBB/5WnnhRkZvexW
wcNw0yDtawjsy2StQwH2QnrGwTSt4kBDLO1ToJ9jJ4C2rtyO/PJaZuuVMORWcYbxzBriK1BIdhIB
8/fX4HodjoHbF5Ejd4jSSb1//UfKkNALS9cquFcy8zSt2ru5+CrUcM5eQVyHYny+XBDAyK37Dbmh
IpbUbCP3lUCVErCFmuxm62FgglHuqWQHARFuF4sLhFTMFkGg88XVsbDk5290Nlv/UQ1w0L7cqTAr
21REtnOFR1J8bmP+ZJTRtJTfyt6ZK6rl2OWBURUCFVDvrhGUOGPl/EIAU08FPFy+DZypBhRSBLSy
cUfkdMOxXixUwnfxfkCnlIBtRmq4sx/0D81bqYWzT1OSPefiiFl4Q6Np7/SMqKTDfQfUivguEBGs
Gh7gqkeDv15GMQgjzBmvwL8vqLNk+dCddoiIWC508zsFvoYt7u2V+CkkV6JLuv2Z1F/lrnn1B9Kk
0GRT6mHlOHtN8LxqlzArWc2/3DPlN7bK6CKlNmTt1QAP/uyVMhqRU/noAmtURFPCrHbAa3IIC9YR
/ceqLLyNVSMUnlKRb1WFPSuPjmBlk0ZBiHzcFT4TBXqu9EmIEe1GTo/hoPFLjQBqZev8ngGGoRFt
D1yu2SIlptgW0SchvduSKuyQB5z3TfsJ71OTpfwr28RWtRH/v20bg/jputrEfJRx9LCfCyEkvozF
JaiU1R4FT8rWGDVfalx2BX7qHTo0Ex7D2UKncVPsLF0gCSYB4RyBSCOlv+P71S1FDb+SU8Qn5EXs
m6/5y1Pnqfso/dwN5uTMHTblkzeZXZrbboPhDmY/tHgmD6wF1QVvCq6XKAbWPUKJZSO6dQMuC7UN
MA7UTToCvjGnuRCaDrNPqprEWU0qgfQzaynGwgpm6oTcUOGosNhmwX9GdhldYaI9DiEJe5helzTK
LQth0ZbSf68nVd9GANwQDuIS6icZYIaqXs4YVB+Yd3aGDmd3GdeU1mhJhxTgaMOfKVyjojS7fOKd
Bus9vSyhP+Q+XEjqGAoZO4WgwEEreqOcdqBVglCq1+0cWA12IM8qcM1O8oFbLHy45T9b6to1G42u
UxgaeMEBBp4GA0r2E3x3PcwN1B7YieKKgmwsrgGoVkGBa0f6TCj/AZ3NDIqqELiagcUyLl6p3pYK
RprjiCPXiXbzv/eHrzzZEFIC5VxaL9Or9UpQzjcuZBkqKzu8x9vkV+AC4YlcutgwKCPNYquaFD5o
LsIrukfzRtEePGNx55nTnCOKJUwNCwzBX0+aVCA68+d1+BaA7Cfj9OqN/9S108WnDdIYVA1TC6Fm
gXuOMWH+Ruj2xqHoaKiv81642XUDWQIZy9IrL5cW4lyjcZyMmKW20/nUYE6qnnK+UUzyAvtARVGH
Oh/qH7tOaxc7JFn4KPRZgcrKnn+E4xTpPHmW0npYJhq3FTQrz/j7fsVn6zdfwkbccR5S47I2Nb6A
yWLmSVI9InoX2f0XMnOfr1KbZd/pmu0Y80kiJNzfh+D0EVtuGGu3oXTbwB67hv1HOBE7fChD3Wnp
95+Y6LfW/0TEP84qRvV6oLMsMFgxOlmRM0TPk6/6m6ukxoFQ4IQNPfIMi44HuSj8QBXfQCAybb/g
e6FuQIFkiIPSzdLRTaMXq4shPp49vP+TNiXZoodtQQYgFZVCsERh9beNldkA5v4keV+407hqfGyz
jYxu4RGuwCfi7JOQSAxnnngwnFODiFEpGQ8AkIj4XxngbZdGT0RH7/mMxWB3Dwf5YahRRBTyqN7T
IeqV2xX0oWUOi8jUWsOndGGPtrz+ksZTGsZem+FbiU5a45O9aDVK0U3dFr8dbcV5yxJC0BlaN24t
PiKqhzUNHQ+eKVkIrOXsgtZSzKd8Z4Wa+c1490DFv89zBFkdgQ9OSAj5b6zWyUTSkVZ8Ppz4rMyC
UQYT/+u+0bwrWcvKC9E5GuPenSSVLkbTtwgwOvebPpI+fiKWNuY6YKBjlcg8noPZifo4LC3Y7lJY
zSKKT9ZERTaWANl+Qmq/M62bd9W9Q9P5SPJkn51hQa2Pzn/+Bhi8GVOXoZa0sRyF+K1Zw/sIzzXn
ZG1AGX/ZrQe87FalMfQdcYz3HSSXiGdD4xnZaQgMqTBMSbBUs3V+q6fojN5KjNcXlKCE620yTWNp
Ji2WhjO4yiOjj/yNBn6S8Q9K6+5ilyfK5lqxn9AjmbsEkLkwOUXvPPnXQ7O/ypEBW1fTgmkdNyne
LKIIKs4YjGyKD1h4tPj49Yn5B0uSsIFQbXtEWWsKdv8UroJtEp8aqdeUc+owfUBgMzmDG7nsUk0t
i34Qt93Vwv1eoVpDhQsd7SZ9ibQ2yDjV9r9k6oETELyQrxqrnzxCRsHILmm+IIk9gfmFKuysjvTK
rHTdIQq0XPAvcONkjAjPOg3WElOt0XWoGcInRpmsPn/KfprBsTo052Nq/NCo13AYbkeBexJROF26
3yEVqVy+mk2+OLPFcXYgq4/34ZlZkAmUQ6xJ3xoCkBlCqiWjEyNj8D6NyblrdmeOxQ59URz/dEiH
dpyeOSMijHvFiC/J/9CDvfVddAcXx06nOu+PO3dgCUR5eZhHIJWEKIATFk02/vwp57nXRuFDkZd7
9SxU44iwHOQXuTs5hIzXxAVhxmJ/yYHJ3Ks5y0v9vA3m2xLfvNgoiDg+asQU0sTEUb5sc/98da7h
ZfoVLIfvxbzoOwUQluR3TwmAyLtNOH6MJDDLMR0gQVeDMNMT/eAdd0eJ+e0SthzRBKsB4VwwZ29u
w2LqZdXNeR3KJFaeyq9VuNqd8g7Su4WjFcRUT8FjwZgXrWpO9DP6FMHDurlG/StdMnOXIPiiniN9
TdJLGVkRj/XFav2Vqp8GpZTeDT/Xvt3y/DuAe8sgmJkbo8hieO/BrzHtDTLitJ6u5pO8+7ZTAQdj
qsaCyENZhetOY4sqUxYebEm1s0OJtnffKOkY4G4eekNo4DCNfaOYTEpYLpWIbCPCkTTvieADuIHy
Gcdqwr/oYDvWdBt12TU6IlC9JhphcOxYRJL2TtunbbiBL9GCE7c9X1O6kzXQoO6F9J21P+pncr3s
Bn6byUJ4EE/GuPy2RYdUw6tkNlfF3PcfW5k/98JCnitZJ23IgdJ3gOU531XaOjnK+TziMARZ0CXH
5JLuGcB94wnEjJQSTTYqpfo0EsYIvDgivolkVFBSPiaT6d/bYiityVSSMvvsWjEvZ2MfrSlyfHzu
3bwpcMzQdVEHAXa5hkizqMV6upBuvaO2pvc+pFL977Cw1oKtTMACLfRAKEBnl+nvScatosNop1vf
cckj/FQ1LVP42wYXB13jMITpezo6Co+XnWbu5Ux7rsjY6C85P8Bt/nEdxJsxa/TFjKint5/ST8nQ
Mth85FXAL5X0PYAF52ZKD1evOVgyu05sIPULKAwAZVGPUKA2SAAhU4ZQ6/n1EA4EfnGQgOCPP1p7
2iOx1dUECvff4sr9bFZFzbE8oG6xztD5UoO1p7oQStarzGmwd/2LoofaGcRthHOOEJY4yfQpQrrx
BRhrgWJl+92nz/0Gw9qAu7LxMss944jlNcn/r1IkcLOxV47RDxWc95Aj1np5GhbkUJdd2Ib87NCD
9rU0OIgk9hauFEvRXBv66a6aZ50V1dtk/YiqKe/n7GFrv0HH7wE229ArxhCkEoJPGZl1SczzH86g
sTlR2BIMlgRq4tDstcwkuQ3SM9lE5Q4qyien3jR4FLTO4bRZyuFUSBuzG6D6HRrFzIetRbE2jtSF
5ZlAXQ5ICQS4b3IHgDnhfToQtC9PXeOCzir/I2oYq5nuXXtjOeJCLntJokN56yMI9h4QJDxKI1Of
wBNnHU1uboFLr4vrOWad8YOEXycjwTBeGn6pkqne7H6iIP5rEkwt+52zq1sPnD1k+hldQVLSk7ec
9hT7wwTw61JkFpswobUPU2MO+4qYzkXZV65DjiAjk2CXApE7fHVM1uZvTQKvtbN6No6v8JYC4g+D
DMSuYaNZ6ZwIUr6zyG3YNzby6hHK6ZtAGm/P0ULSA3ApvFpxuxsd9ot1YM6JwxwU9jVQ6UyTcFP8
Z7i1HJik+HwAB6Y6VPgYJGX7jwueNoHkvqLogPWC1heRK2mXddOikb0BYNa5xuQ/BvAeHbyuwsCu
WpSTrlxwZRoM0GmDZCdBOMVw0137NyKwpQ/ohDT3R+k0optp/Ap8zrrm2PsXKqCu9AC1bSJSjZG9
8Sh0/y+MAqE38+ZHEK2p3w5u93Ee2d4rM6+omEEdEXGhNyBPqmcy5ikCJoGS6SCbwiIPKw0udkhj
Ae5Foh+nEemqJah/j5vhNAFp724ATILkVtoNTTZT3Pi39VJuMEreBpowl6XwT2NTM1g0ApMD1AaY
pABtIylm7rE+tiM1gXH1FeY+cxySKGibdLFwI3cjKXT2K2PZ5TFww5KKsAEoNozWxRG5zSa/aEuf
bRbChhY0QHnPMtH9ZSTnCWMgyr8enRBwVCyiXRYhkoKAbGO29c9Q0HKSx1JjXku2Bi7+RXirSJoY
vgn/Bd5Tvi/rexJtm7pqv/o7AzMOf0qSgkbaktAjSzXvMzOiPe32JhxVZ9JSX35Bmml2XJWsNYQb
lz4yEdFIJzDr2s86eJ15H4u+7tahTj5NME1ZGEM9Bb0PQuXIphl+zAyVE5/k4r66xTlVPRDtog7p
28O1UiFX/BX8/e9zScKNYgTGvYddEGrYkbVJaulihAwqLDQ9ZJDgQArc2s8ZUJsMUoe97sDGb/DE
cj8NS2N+MbIEvYFCwyArYGDmhVqJ0tJF1fddPzsAz0cf0n8i9SrB6LY3SHzzgrRfB4kET44/weMT
AIFLjP/z3Dt8KwzFabSC5fk6WRKTLGbhwDnbvl/2+d8PTSJJPhbaXWLi1MPVs8vCK3giJAKcWG64
TtvUcd/3lcv7Dv8LmsfYVLRtv0bneHuNU2A5IcLVEM0ZXuDPhb/F46fkpaoWinZ7YpsNKpXKSpW0
gZO/jAB9ZGrENTUukkF4fY1slBVIAW+ieOLEUs+xWGIQFg7ZwTROtg2Bb/PtuwQmcWmylZAttRUk
rRNh/49MJYCjF6ec30ek7rHd1Zmh6QTU67r7ibn4I4UYzgVV59xaiOlWU7gGDbHnQa2jyThXQ82d
Pfd+3i7LzcS38ZaF8lF5YqbmNu2YbOH6ZRVzaz/6NU1tA/DRVyOAiOUjf/jdpjcIvtrscYu0Gjgi
HLsA05p3j8Y7Qco7ZKsxOht3TuhGaorv9vhUyrLt4MI3QobIY4TGRLQTfQzWLebpps4d+iVG4j06
KUXAIPmIu3Dm9Nmjz1dmIhazyjumqjKt7PDOARCpnB+bJCQ+KK2rgz8N6nGVC4vD8VixiWRd8b0o
XbP1j7AWMmfhMOh2g5j2TrkpWYMH05tYYlUaxA+NKz5aWLVIVnbCOW06Ko21AThsbjr9R8nchxaw
jFE3+qQwemPL/wNcJXB7qtiR354E/2pw7sDFnHPQq8I/S6uRkyYlDrZutil6xyO/ITvRIdjsowz/
5k7xWnNbZxAlmFKTtH6o5w0JG+cIM5m4w1q2B6lgml8RfYXJBXuLcpxv/CnunRvUzkQj1GdGpR2i
FUhgLFefuNZ6bN5qMaSS1zNG8uIVJmPNaGwcN/EW0f1TOmPZpZZOR1jjiM/daCptBrjC10PYYwIW
hGlbLU5vPnY65/yIJp7IiBP1xfKLQdvyMP/PFWtN38TLBeFQ5XP+9FbLUAdZiATuJPDnlkSBQ098
Mk9Y4vyp1ArfDbWTq3StUclcteH5eypwY9kMvJmSWq/SAdypS4LMQ3/1QMwcWGswkKp4tDs+CRc9
isB41mpdWaFHH39ZFg1uNO+aLmd9MHcsP7jLKS4H527K5SEbeeTDPl41XLX2X64l3WpaaVVsOTv2
K1QSH1I8zGhcLpNQcM0CePxCdFF4CCbR9eL/9zRW0lcx/6wOqtwgSeHx+oq8K2fJeczTdyKfqydf
8ky9qUyfx/iFhhBlW7v1nFcMKNGBCKk8iel6KuiYxwCwD0CkhSnvFqfYzjrHC2Vi41UM2JiJ6vbZ
Exglvzak6uOQwjwxBKw8yT1XKqYQiXGTSgkHPKwCzNaKEqGO0UDweJJgXS3Pl4LeuTjVRIFx3vwT
uWZJ8YKNPUA5RQ+QpU/mTvZhKB8X6mcL5IbKHt7lm1+bcpEc55V3SrjMS1tnXxBPswU3Tp9ajq0S
wWdH/4LxCcIeFngHlucZ/UcKr0M8le42dfTLvLumX3Wf09EBXxsCEBuNGuWu3mG+jm5eYr9OB+Kp
IUXp6rU71MRbGZKD+rpSGq+rZYsZR2TbsU8iCqJFjCfZXwclfLE4IWa8kllIUQF1ZRNXq+VI5U40
0VenN7Cv9W1b956k5PJNkRUdfWYXYJMkprxG6tGEPK2fxcrRJnVvSCiz2A1mbewTWtLgSBkVoU0A
B3nyKFXMStL4a2FCHNImxsf+32cfyAFiCF7zdhE/o5Gh6Z25+D7/xpAPTJwdgU7TSUEJkQj+ys4i
6LFrrcKQjvvQrY/QJtKERB5hZt7UbmClVq3I5l6eYu8jath9AG4c8VpTQ5fmSr64qzMebUQCY5Ye
S322Fxkv49vZKjspS+eBUkU1OYrEPfP3QwamWfMxnt2LBnT3EvjpNehxM4AESIBAC0uL71CPBOPO
8B4w+2Veds4e1JeW2XSdrsJQ1zE6UkQD2JcA6L7J4CuW3hE5jSrdsJJWC7P0stioac24Nwkrm84O
2ScoEZN2fBkyVIaAXFB7yPMwQIKryssnKAwz/apS+WdTSN7OTkI+Kd8BUtbVUMa94fapomkBQ4Bd
OhGffIwMnRuYbcrA3xplILNbGhhRCRxOS6G681lRQMptlDAtRi2FPt8VMk9b1ySJeFQtL6/bvB4V
Gb1o/O6CUAOQQDRzY+FlavxjbUfvM2YWlQ6x3TdPM/WfDBIbYxF8nGSTNcdARFlEVuly1bMU8udI
ZRxZ50K5ShkHnJUjk67A1/jg5PM54vc8rmIOLTVN5OtPJ0gnK1QbIzj3wMUR4Z51iR1hhZJlZUb4
1gr9m7JmwZ6wEM6nmSx9V8RXW9V3zAqNbwgIECFFDBfvpNPPOiYkX8s6vykim5cYItic7bWUKNuo
xAUHqjL47LqoxSXaKtjhQ9mXyoEd48S41KqwNNSbcsWMJGpNt1g8JndLDK+73QPsI2AYb9VlBTbZ
jHifBi+DBpuAmQLz5X4K6p+BS4cPdQzMB/5hbHLaAQawIHtsyBjYsmrSN8I6MpC7m/l3iEEz+XDb
/1uXVuYJvFaqJO52Pnvl9qUfxwEAr2NbbPZA7j7ehVI3mXlBS/Jo3ewceUgvELpwJMKxXXDsYOjt
uD+N7XZxseQpFGHTOqnbQR+11jO2vWtUfoDHyWvhGfqdCu/FjotwMcTGAU8icys8acMSxrYFjPKv
T9D8D11KxXM3yMU8qeg3sUlFWopuUsrGkS7qYJgMGXaZQy2+GUAibCWwG2Rrc7FeKf9XFjExHPfr
2LAUkRB647wNh4rNEvLZckbyN7Ro2ymfvxtNtrYVjavPTSaPImlJWRDK8EvvokUQLm0sk2f8ahWD
SC6A4cAKvcsGiyjBNhddQX/fL7/6Ouli+uLHh7bOwEutnymKifKHvkh0U06hgfBn+asO4HUhEt2q
nzL6cSbtflFjlsZ4pcDYJdfU7sQ6Mo+jQPuF1PjzL+QCgOCHNZN5axxFdRI68OdmFJegiVZ2Gt6H
q/a1NQqmgqdrdPmh4bZpU4OgE6kNRzbEVERUGs2VI6KQf/DJ05okg+HFCTqIEuOgpPirSVxOuWU4
39cJo8enZBJwFZEXISWpah9uBAnUEyesG6xc8hAQpSEPj4i+GLlAeugX41Id3av5fostEp2oThio
Br5BgkesybGhr97jETLiGbe961JcV90iAiS4MbDaiuHAjPbR85xSjP2b3CHunqguF3re9bvph5rx
HHjLYWyB7CM+EM5jozlazTgudkThTgXiL+IlLitopqGFQ5Y5aOo3t4pBje1WHTGXGCUweIcqMbag
uCIboVyYwh1S7HwkWkVuGeBvVKhBCfGOEywX81d2yzwhA2m1kFP93068WkcZeXK1gZJZ6krB39h5
TOmLPgwQxjgX7v1ptO7JvfrirpeRNtvcTkbyyNE2kx4vMLHwRQNZtgOpDzWgDkA17afyS7w33Hwd
Bb8aekFmwvuqxoAqR0VkeCGyHnAByj0baBuJc2AklNvujRCLyYd/7hlqJ8Isr3Sn95nR8VjA8iar
1pRQmLhgca6U27XmJUGUu59N5Mi509qr2F0+h+m0jk2fgrh8vt0tDv+2tGhxDGg45O/R96KvlXSJ
YCvjz02T9uxmvkSuuZkF6+LIkIFSf+xAHIbqIisaRzop+sCUelQ8dI+/Rd7DZqcLs99CQr13gkqv
GOZQvFl6gTxtBfTVkmUKe9vRYTeYp01ohsZm2Tr9lJqcqFoDbMjt+6KJyKMjDKBg/46oIPHvxitR
MihhoYb+65wF98l2iVxyhq7MsHDAYLYdhoLiuaJ36yRH2DBV6YoycGGuY3H/Pt0tU11Tfu70MtS+
svmLTC8DzcobNjBwNnuIIS0TuS4RD9duow7gd5IRZLePyiku1/J72/PqAfNUqAI+dh3a7gCc/Ogs
5m8eY35RZKOVI/yUG24geQdwkd0vfOPNquRSZwLedHW+MqPz2VnMaJy1ZZCNCZG6xvGyTpyj3PJu
OWdXfLfQT5ptNbir7jPrW2qxNi94e6sGyWdfSuY2WKKPsNvX+rDup7+42yt8+MlLQQ6EyqhQ03Z1
bPKqCTkk2bprJP8C/SJ5pBOlc4tsds4qqj1qBrWVHPUcmnL8BEmmIOeIDKhal4rbX82hIF/IFyBA
9fp+9ZMg/qkvZpXQuA55iu+He83GqOn5mvc2NX7jApuVzwn0GCOJj26BiZsBNy0PODVfFVBWreUQ
vctAhcjnz9XEHq44iwth6SolVNnAnk+PtmGXKiqqTeGiw/OeqCn7cE7+PxYLyhJhhtG1rG+AxB7s
HlLsNTJHGGidUieZu6X56d54uPT6Kuejc0P/U0jK2e410AhlLV5eDBUH87hhVyZnjkJ7D8MrOkjw
ryC1RNAWB0VwBECeEqYHeNEu6m3hrZe/AqRC5BC1mOfXMjz8n1uCUNbMEUxoegBb/U+/U1gFAI4B
RnjYhXSLIzkNtPuyXf3bHX/iYbybJvD1EGUTqdY3tTp1FwAQa0+FJzR7GdvZiqDeqDxslt79LNhV
u/a8oAOcZ2vxDRV8Xc9LCQK4rbNKmesbtTcKfwRCAUfLxNpe2JlLneeFU/z1DLsg/0nWVNhTFwVR
twrCnSp2nJJIQ7vXVfkmIb43CdN9NKrnWXSuLaL5td/EL5ryMWBzwbzEcL3ElUWf+c9EwE5cCvRF
IaFj1iRS5F98dMBdKGWvzF7eo7MSDehi3EBiGOXuz5fl3FPM5hXXl8uAHPKiBxNJcDwF8kyp8/GG
vHvD7Clletzc5Up5OeTBpAlGbIyHHGEqClBJvNAF9J2t9lWA5FH9oX8XZTSJySGIIGdfqUtQ1FvO
N/pPFCKOYrAEUlV9g9Atss08cLJgxWVwO57lsQDjVrcLqHpSkAUNw9xO9t8CpZBAeXmdkMsQ35Ib
xrkGtj6ugxG3zAuuaG7KA2Q1dn5OofpmAb+kaj0PJXOEKeX3ebNbR/YloKx0skx4Ja2Kt97Mk4uy
YGbyl/SsbSpzXxTmu3p38x1bydKDIx9pQs8EuH2c3ytiQaRC9Q1IfKyFArkvKIpdffPyupEEq3BT
c6YsRvK4nTCdKLmDzlPjVBQmNoO30RfARREZ1MDgUjf+aCzjUancntTwAlU20GUuQUPBpNH7njEi
1FyBmfmCLRkiYvGWy6kIywj98BF6FvQllpuiiQ/oEhtKrBEP+8C2Ww3hXG8WEuN8iROWTK35X7g0
yCIBPIr+1OvJwyf7IM08vaSuLZJojs0KpmeMyztniAgbnWKC/AXi/kGddjWoHD/4vth5FEsUWnEP
bBeYaN+MqKiD1ZVMO9i7Dum0ZkkmzJaO0AuDlOIHI8GX2emBxbKa8RGW6TjXlTDrq+BNdfGy2g0k
+Ixzz8evOuKLfEYgcM/i2LNVycptnFAq1kzJUWyNXFas6RnhHcmopzBN5sOf+9XoxPZAREgC3bxk
7lspJ3qMDGpuO78E2pBxJZDk+VvhqepOb1pqFpY6uIWQ/jJk/evcxQ3Utt+mRFeT8zMiqsF/KVa8
wu+WHisqsX+sfiJrb+Hw8T6JhUo2CILcVqbAzurulAm1GKHUZkvXFJZah8yqW6juOUjAkB1TXhNk
yTseFytX7YFQ47wmHMyipz4MlDgyzg7Rglda9VV9k4/w27oNHnuzvEwHlUsxYudib+9uC9VLzM0x
7dEK5gpuXjWS+JfebZvmLQ/y3JY2ylLRJFTqR2D/urj65xOaqKBALeevTBK6tE3EvIF3pu1oY8QO
Ds7PqOL7mh1g2IA66Q9zUZAFdXhfq6QGkwE6nOn3DBv6DEw+5NDXncO8esMENkyyPbh4yDVZgCSW
J1noyYLDooe15AOp+3Lzs2lwghcdXLW+pgSEXxRHA56X6pLlykCV7MnoADThrjbls7pMs4ayeT7k
Tm2wGLEGZfUSOaZ6/vFnhEzi1KpVvXlQi6PYG3Dk2TPX5ciB48FZHBHvgaOaf//XTJAEwr3WCkSl
KI1c1zEJngzgtPe2lrEEAkEl+kW9KKRtGkpEsHVNB4Wd1Tba4geK88H3naIlGL9TQHXrTVKGn6DA
k/JXZLj0iIyJZagolh6FiGhzC+TcbpXg4jaqv/PbPPf1lVGeUDsu1NmHfc69Lg/IBbpOOzTX8yFk
qQ5RjepcRXTbCgbIQFcD5tN1YYSkC7UEUsPpDtYe0s+bDDgHACQxmYORvnJmeFTtT34xsU1PCoqI
8VDAkadUeW6P0f8Sjpamf9azAtTm4uew8e7V0CxZ/BGQfz5HZAsoWwZdE6TaUwjccxct6yWbF30O
xm9rPmaectFwxYmNBB5m5xx/PKObrTO0n8RtBwZMxQw2AKgWms7HMJpiZUrZuJWn2tmLzDIottZi
J5qobMRfUslXfuKNqrTN97//g7pz1fKwzBzEXSvTfWxpVsYN0glTl5nxXvd4x4LmZ0LN0gwQYzLI
3nMm1lgFl08iIfTOS8tLGLgL0FxJ3snW2HXwVAlrsJrLcQ0DCeYonhLASI+TYllii3MGPyVeg5Q1
6vB8MhbLJCI7mz78ida6m1Ay94UDTzxvl2N5L/b7ZCRdhn0jiAAB0WdL6nAmks5Vbk+SsYr10Igc
GOQCjuIGyoLulKJSnWv/EOStN9cv5/MyQQsJpT/R3Feptib1cUQOizvdmXSDauzbgpAm6Fk8PhxO
Rl+3/VXG+WOvzQIvzavLWSoIxAQbqFugA/s5rmSpQNxiUqo3tOlnIwzk5Q4+dXNR3slgfA6VgJEt
YxZhIW9o7bTFESTu0MtE0rgpu5EUn0QI4+GvQXCDnr/L1yrP8DBRUJZurkdRMxjl85LDaQh74f0n
X27EIPnAwmg+unEOglACximXU6hV8W+FMph302GFPPB9uZvfpIY4QY49Glpr2zn7Zn50XAP9D9eX
hlsToLIGRF3tY/sG5pIvbMqNVveaFrUzd03FNG4U4GP03aK8d7hH6Zop1Br3As2KFpSRRh2UVfN7
Ae1xdKT6qvdQoa+bwsuDIVRRwmUd+UkhOjF7TCERzN/7vv2ddrH/f3DHWC9dt5CnLIh2MFirtzGO
lTPbwlsUQ1bBJ43bFDoQhRqGY0VURxkkvou/MXugo1ao7w6vgdIe/FuPAWe8bYo0XcAGt7BnD4V0
5aPHvdhpW5UM/H/mxxXcE9pcFn0X0O2eZMiVfzYG6ui+givodTS6GIiTQP1wRMFy2vIMcsqm4ZHV
80j4nUoXgTgfzDtop2RQgqNhWf3YVTu0DdftF4rLTf1g8FliDO3QO+Sebioz7tvoLIRQWdo/RLLN
UqF4Ho5RTCsiTb0HaGGVNSFY481nmErrgKj9BfN/1MtJAInEW4Isj1YkrpHyD5a5nYxYTWFczYRQ
WZIZfiw1BsTI8ezb9N84HCdtYer7CS6k4KwjB7TRRu+JHLTY0CDnS6WuIt6d5B9lULtVy0K4zsfH
eKeABNSFi3fqVXzGgeWaZEstpRkL/x16mP0J7OvA8hmiOJqW8qhbr+Of8R3LaJ9+WOiqozlYpB0X
SHvlA9WsBr93xUkaIvM0NTfyJOQiYQUnncEOIQwdN48ltrDfYsPCn6kl1vshBaYOvgHaToUHORwk
hzuHdlQ2pTnIyUvpsv1jl5kfLBy/H5g/5LYuph/hbsF36UlB8zmVleyvIblkq0SOCk2XVoaRlgz7
pMEnxjnlnjKpAyujXX1pdgEfIT7jxcuf6VqB2EyvwKT0sIz4wdFZg1VhCBGFCtc0VmQQNfRRVWM8
q9yBCA15e//HMS3mh6HdS1E5cMO/OhSF5LbnWpY6NgxLw+9lpWWq2fEYaEPF6H5dXkFT0QnLD+7a
f8YfRhpNzlAK9PKB8bNF/VTvTp6U303GwT/XEWb2WE0yL6Ij5yIc7+qmoBpzGSbiYIMQCdt1EtMV
AYhTpHGoiZXRy5xbnMUit3zsHSxk+nigX3h4+YdpQsClU6IhAGBTJbo1Wl7KALSYFN0sib8oTOUb
5rQQjbhErGF3TTHrTRZjb5Zx+yEBwbAQ3DihDx/ckq1WdPtlpD2Ct2I24V9HRciTFgMgbfrIeGUH
eP4EaLStgkM7lkZEtYS1Ww7LeYgIMSthwj7vI2QDM6t9b9SPCemwsMD2/uHkH+6Yg7dOcGib4ioq
oEi4wFMwmO2/rVTHAoeg3F/UuTg73oYKhkqF9XVXGR+jTIRiqLQtwDy60tH8c0BUalZ/7IEFOi6K
c0JGEXR/XeElK6G7rRjo91ve4pRxWtIoCVORWZH4Y8YLyL2TnebRul0GgjIyvbUMWn5rSObVWSNb
4fLfYK1vbj14mAR6qs4LXkSI8qrGgRiHtp39JU5YFNo6n8hPopAMF9i7n6Dr9aXvWcoNid+0P+Fz
RZfderilBzMFsLCjvMZ8nLsaCjt8hX4sOYaasz0VgwQF0tww/zLvxfYAUeEeBIQt7hGPgpZCNW1h
X6XXTkmIHydCgAlSuZXYWzsgstsPVWwd21/Wa73YtU//zB/BjDQtC6MPhn/OatC/HTnHwA48Bz6l
4PEtup8Ng/OyG5/3VTh2pT4D2K5TbsE8cjW0MzsSFJVvptWvXuDiE73XWFIy6nSvHMHqymD0KvAU
D5RSFiX8SgK6DJ3e6g049gUfWmTkLUQ1qp+mzq23wBtOyHqpeLLyY3jfjeNZ3PPbkk2yc0BMpwt6
MjZUmvsTLDoWxnlTc8ibpDaPjxkqu08rZMXRPBrWVnlXtNqal/iMVy5xi9fad/w9SSQ11swPfQcq
z5JfntSpkdAzIJTrpgLJfSdNcDaEM6O1N6P1bgEqUP41ahUB+tysd8Ag0qCom6b5iUotj/u0F0Kj
vApXeGXmR9TKLjZCQDgAIk57S68qoz2GU5NzAP42LCDlS/x04Oaf3mp5wiGOOfLwayMXDYlPBKtl
Pg+ZRa7AFx8xOhTTM+LgJGEkOpSY/hid1kB9/mPco9tvAZMFdx06g91vBqF8p/aGVMLD306FVhuI
IG+ZdICw/l3/hvj8lj8hePhBbGqB0b5Xm+spzL8NLDrWZApkPUzOdGS5NzBvk0gGxj67YUkMOsKk
Y9u9lSjYUMBI6EGbWnELnsSVYnKeyDhR/UyjrOlABhObMp84WtsATnHCIFGOrHc8YKf8mBVqc9hs
GRfLFN9yswk8hldsyKC4fmH+0C9TLsGYmZpqBvdsglUKB5RKRB3to6ZvltcpKaZm2o1z6F9VOUPZ
Tm2z8UCBGizi4ZqazyaY6V9Cqt7t4N5YrmYUY/xaKyme6eN1sRemBsG3a1dV8U6lr4Hs3rq36cSW
X3BXRhp+CdxlpASpkhyTlRtzS4zr+Bpsv9obSuNGIy+iZs0NtVEYRxmGoI8I5wJrGgHuICR+FQjN
GfU2Hyly4D7GlTWN5FBuOLnb5JdxmrUv13eqSx5pIeSarRJ0tkl5mIq0LoLYa2iffZyIx9OPSKbJ
qCATjTh74UBasI4jV8U1WzacvEsn/+1xLSU1SO46XF8MUqMxvTZWLYn95f+sPDGDyITtZTtt8Zuq
pV85CiAx9fLwNX+FPDEV9x+pfVfmzu6rYOzlcBzhhDoqXtWZY1Ep4+nCle3jG+3ouIGl/ij3nlHc
9XfTKaHU9KIupjn+fh+3BIl76TSqUmVG5wHQI2xMMcU2zhvZVD85KKUzhOvxL3b9JK1Z1Sl7dLJI
dSC7YWR/3MIVOXlakakY3SkpurNoGgggp2OTXKribw/NQP5ljKAuTzuLW2KY+9QmXHl+v+lpv3+P
TcgH9xypc1sPdkFkyA3Xl1YQ/eM1r19Jf38Ox3MU94nEOCf2lRGnuBdYFx1GprMM8yfBj3kTm2E0
smS7bgikLxS5GZGGu9nvBG1y4ZAR/rAxH6ab+1d+nn9y8GfVlrasQvXEfnU+2WjAQCcCE4+vxgR3
2egdy3zK6rxztxAyC1bTGPR57iqvwHXutMemyj4kiCofntObB65DkyzWeoh8PyrQA9HetsWMwsCv
LIYGJSNvSPgPgxK+dLpsAPVPF7ffiXlsEqvjqhiptEITGPTvHG1bhAorCaMbwlSiaWfozrFs249l
WkCTlDWNkAKToWLnERgJ54G5rrkW6gvjagbCDbKn1kjddAevRREZInenY48OBihZoOrrPDdv4/GP
LzGdz8B9bFEDTWfRXm0a5t6vhDqyXSviAChCYM5E3VjaADE1uwv3faKoGDCZqTyTEO2F64M2CeEg
tR4EZ6XOoFAodArlhpJ3wl4Uu4UyqoxD+qL7aiPxMO8O73BufZAkdkjpsR74pGieUwXsU3hu9IHU
806ihoLTf6WSIZ5befZR/u9S/9gX+KVv0vTbBynKolsYhn1RPYSHP6w5eu6mnNfS5TsuIC888I2N
eZsKpN0ia84g8+J25NeTU8r7E7VkAcu8idFoXwPmXG9V1D9FP67GUNhWV3d2r8kJummsOyLDgJAV
MhkCZCsKKJkjk1B+zX5XDAQtY+3fj9o2Lm0ExgBM5rqt/PDxxvW6mP5X9vd68wVJ5Znt8eToEteG
8TBEDR/b3rBiw/fIGW2HmCTp0Gl43hIwxvT/gf+9LEZUYV9yLkOXWQe+eWfaHW5aEnBVdwJMvQB+
qd2MpWEV8q4f+itp+DH67sc4VBvZVz5ke0kgrnDT/EBjZkJxHWx+jKVRjdZR4QSdBLCcSg86NyWN
RlH9chBPFPstt2zX0HbI/bLBUE8K0cLfldnlC/knvkmO594pPeV3/lE0gNbjY90tuBCp+8pjk4dA
zrfSzhyQYS/Zr5U+d5YOlh3FelBD1iuRIuDYuLz6olQ+O6lxgtgKN9wxuQoC/L3pNxGbEAqzIJmk
aLebVlAkqkZMCiQcUcfoPreDTvMMuQncJ4AgLhlTtCl8NttV1FNvsSJBGgft34P9+CuunasR2lfP
xHudFBfUTB8CjvIqH/e+ANl6K/4C9rmILqGRBX+Shak2ovy7yBP9F3bFDomFqNGmqfWvuuoOsuBa
ts96jtvOKJuaTo2C+ZVgfx8rehNQMlO5Hj33yOpMtB3o1qFfwriHzNJNxlCFta5qGWWMxA/ZMPDG
NERmUeYjtCMFW8wUezE4mlEBPcEyCgWP0btsQu+HDVAIHNUxfN5CIOAPbZXmWkcIDB48WnA70/IA
7TGVMnG82l2Z6oB2i8zWIoUUCu0icXqexb5mQBzMOyQcgKIsd3e6eulHnkWwVnfcr8OZGXzEoEyr
8jBnaHpYoQa10p2rWBX7UBuZ6nmRroHbnbN2jb9GQiMEz+1a+pyV+HlzOr0I1vdLHL3iJaWhqBlr
Xn8OSN8Lnc0fiUtKWPP8ZtprY2vS+SDdBIXsbiMJRM+QM7KEZtoOmoTLEak5Xib34I3Rms/nIzVj
xLZm8K3VBGthv4pYxr7YIkpZV5WX4JQ8nI4TZADq9L2mM76pKhWhFPyEhXentyVu6mRTwiMkppFB
0u++ZsqDP+Hw/RcWkFym/1A46oUYHui0PfHoWgPOhqRr7NeckMBC7lzUU4n+bjf2Gpa+YB8C7BJf
HDTrA/mNStKiwPLtFWGTSYeJ6/V0t9kzw8ZEMLKCweHpGZxOhZ4iLqXyd/B3C8NGHe/NlR7K5Nfy
/y+VuFJcrBasSRQe/nrc20dMKSIzpXhsM/kL8Ub7hF5navRho/WA/fenfuUHvHcBN28wjiTzH2gR
ZmSBkm1Sl0bvAwnDtig3JLC0SpIEvTix6Xrp8DpFzECEAFTf0FOMRmBjyS66ARV2fxznFJXb9LX2
bSD11jqVvarQIRbqp+O2NEIFmTZOkJL25xmxxArazoNssGfIhtkg2zUZMekBE/A26WS07702DJ9p
c6Xxaotxjjn91pGAUlHSCxt3+rlgyCgw2elbfZGQQbfAWB6bzrkL1+hY0mIgWSBEpOwXVHDTutgQ
i4WTUqBCMOqaaRVCQAijxX1J2pAXss3DXM9CG4bMNrwy9dcJsKLbonVX6aeDBAG7LJJUHmPQnRgI
pLu995PEH9QXR4MztiWHdKehxAttv2nNsuJp8WycPdmgA/3ZCp72GQilc+oAoJrrantxArxO10pd
Q41L2p/nKAXYnON4U+EbY5IplH7fNPbNYB7411Wn6QLqiNV3UWp1tNHvuuuMtiQj27hwm6baAV2G
8u0yYQBcD44t7bfvrWVm1KzV3GXS7FF7RJ/U9gCaqT3/2Khtkw8l14YP5yUaH9numt9baSK0N0ql
QbUZqWyy+RAf4BF60XKXUEun/41vLu1vpUysHKFvDpMgMbDOTZxmRg/HPmEoShMS9xy6L+H7nn6W
XXSSpCQFrxhdPUeBn2hKnbJQl4Ls64wy/a7FZ9tad8Ok8XSiF+V6j4C2Q2+LDNZ+SHNFNeFc84HS
721A6ELf8HO80MXq1R+CjB2tRU7CboLLF2wJCCwi/MOw1sHQSGaw/P5XBb0FobSQiapWn+BLsH6B
2lI5dZyJvTWelkP8eOj4WZ+Xrq3w72CW/6VvOQfpwEPPajbDFqO3OlE/Vy8GDmJKCHhdiDNQG4Qm
3mLufoBRzLfT6M7UtBzrrRYHyhf/gleUrSeo4fuWRKM8WLdmtOrFcZYEN5GwIaCslXAVXAXttkHW
LEnTO6gbJMcrhL9EkKLIip71yEd7EBlx9irU/n582jQOjk/NfZPdn4QiGmFbuGZhYBh2CTMyrPtR
D20Rc4p2IrZvPBJCKC+uVQN9Welj2I0aeEAuDnnCCJppfFFvfP4zRSBqHT6RmfGPvFdK6lhjNiCS
HApJVYsZPmnXdlgxQFg/5p1aML75xGtY6qggfqR0t+OllpPp7lAezN84wCpuoEY4rAX0e7JVdAub
MiGKQ1MOVkUSiRRKPBpfmfOnk9PoPnteQswZSufDMVPMe1gGhwtz7o03emK+QYEDfNJ2l2G0s42Q
zuWeYu4hHvRVbsgNbnxRVGYeb5h7Ax6wJmZtZjeqtEv6j+jQf8PThEuRVhwze4UCAGIR9N+ScmhZ
SMOx3P+L0EhfHsBEZa1NLCVhlJpCWMfAhuWWbbQ7lxdgMFI5knXBdQqhW4zsr+/LSW/mr1BKbVPL
7cCaLuQy3U343pdAB/cXOQl0E0YNTZkJQcLdieAZsJ+hFR2XE2QNtQM+h5shxQ7XCRmGJ/MSbfrA
rlQQTelw8t2xOG+kzv99XRO7lIGgc1mIsOaYorZlPWFMKumAEDZYTXcMJA0/ybNDH8m6cDKuogOB
BESPQSVWJJSiPU8IXHFIW67IT8wXbJsiAEv2CcvHB4EHFEjuM4Yk20rqLKlNyZ2vBCpc6XmAjvsv
5s94cHoP1crEzLrV2s5yssnRH4EGNiuBABK0vykJxGtFXegdXloBzT4QfbbHbTzNKJX5A0mXDjGF
46N9/VkKQyAsGeAfW3huUDzk81mCYJC2cwI6g/4/HPrk1WszQVgTv45W39P7wpA1mttIElBddTH+
94L+9bvyipPMRLjjGXJRipUV2OEtfWiWZOS51E33JrWhj36RKgNMCxtmPxnp9vWvFoZNNRnY0QH8
LxDMyWB5cBtbk4mD6c2CTaQa6hynB5Tw1qcCnOw+GMhWpKJQAQUIaEiGX+NoHxX+J/uMdfVMu0zj
FbQogS4wxjeC9EYhJPSyRtlmVMwgsHH7aRidpaKQJ4Bu42Y0fF82EMeHNWK19zH18Ci/YPglzQ+j
oe5jbZzoxvAakb0pQKpPoCGJn9MHFjIQKD4KVbDxPdtpw8sAVdRnHigX0hqyn2HBEuEahtYLtRdr
vYmpePKgKD3o+pemPWsJ9HIAq3Bj14v5eM9S1EZC/buf/JVYoUjT0dfy1sPIhLCWNjEuqVVCyOy7
MVEra/rUZPzvGB6nhSExBdwtFIZZhnaZC2febOfE8JsJSaYig1Mry38hVc/8ZsYBgQDGHCbrq/Xy
MYFAgmC6h24bBsB9bDI/aMW1dUxagf2QnFi3L6M097kAMmDxvtHK9yNS0opPMRrPGUV5Z/+zu+eU
FIQpqu+fSuuHXKKqUbhEYYVDPAOWyeip90dYY48P83yLlLmb4M/WuvhH3JZ0bS6npBRBSN1voOpk
2vo1dNsEyBP7ZgolkWiU/EpXeV69m68arHBfDl63rZlZkhjWBQ7he0zIdBMgRiweZ6kszxNArgNK
VVty9TzBbvPWy+jyHrpYCCL4N9RD/1Zt9aRzzpANyqi/gLUaBEum9NcnZvbML0E5xR/C5S7aOFTR
ZfoD4gXSWnHGetQRBY1X+KNltfZBFAcdIjIMVJ2bN1S+VAjxBFh0ihdVbPz/ckHtK9ehwRNHp3oB
BQ2qX4k3sxqJpL3PtBZg73YOMm2oaekqFqmyyI/MTl9jv1of8BmRzb+llDxKwf9MBZhugQ1eM72P
z3VfQZHS389tR3+VgfaAjLj2SqHyD0V2U2hfg7HlxHLV0VWQIWam5dNIwm/ETakNU8Ror3kbdZaW
CvsH6s/Wpm8dfDHhBQXm3k5xcPVh9KXV5ny1YTX4LRVKS6NZLjywaqERRdkblkEy0z/Rpfr937ul
C8/4H6zXq8okpW1bJcBt1hV3aiTL+CGJRyqsqjI+UktyslMYQMExzW0Z0Exsw7VNdw8+hfTra0Dj
64bwKkKgSl91IXXJh0BhcFLocDeXHKHCSOAYe8sAcAleeoib29hKSXmzsDVjENOC0nOxJWhBHZWQ
cY2s16TZ/0pGdl64yaeRLVxAlCcCoq7AWC/XPXI4uH4fAaJnGCLJIyDAIp1fC021bqpsUGaKitmt
81I2zjZl9WAlwmHfLr0DsF49jocX/OKbxxqiYInTFB1ieum3pYyhf1YszQEfDw7LM+VjqXkcZ+W2
V6wBq+C1h9hMc6g3EjUr6ElkyNxocBYAN7ETHRl85pWyOJ9Ym1QeVf/ZAxMzFPTlIIrCrV+nNZbt
FnLliLcvIFfsd2J+LQAaP3IXG0l2ITDyFDx9WERfFcHluPKVdzMSAskAZ9PZ/RY6DV//xZT8HoM2
IoOGR+8w4zcdLXO76HbNxxowNJux+G9F2Vb6sx3lLsrRdgZCwzcvFW8aJu9OCqRObneurC8pS+es
PoWRKIIyeOcx/VHFET4gco2TMZW3AqT1FdWzG8GIEz+pHxoF1E+2rEXvZhmvDoptq5mYb7UKpxCC
CIxv0Z6QPZ1lyIGF7OmqhAD8LMiMAAJPJvLWi4krBGmi0oVYW3HPzACvNfOAhZUbAs1n4cmJz+hv
V/7XQEnyBzyxU+/k5Fjgz7yY2ukRWjm/iF9ha8+UDJ6ti6uApy93Ahpkk7aufSqlGixwdj8cHwKw
aApr3l3u9XnG5+4Xj22SdS62/yo0q133DavFt54KpSDdPgcGGq9+/v5taN3SjfuiO7tFbtneD7Ik
QoGL0YyHb/p+HiXrbkFKffZxj0mnu16jsX941DnabQTglVhOFJAYC9eOTRa283frXCNbF4JWv9Z4
vv+h+Ea1AGLpnh4HqEH/i16qBb2JYjmAFv/tWFMA3R2ioxAKE7t82Yu2hGEnPYzr26/w/VPSO+tC
MI+ykVnrN6IfCaNtX6DJumOfrI6dl44YFwWkNU3Es57S5+GwdvcBe1frzztjWfmpZM2S8e+6XREU
H4kbKD7Lw4slq5Wjqn32PmfzUD2RnSOl+RXA0IEUlu5KHbMeteV9qKFvm+brqgGQLavE5TVuumz7
HQwQtPXnJVMgiq4fPkNXID+qbCT6ZDQuv+GMtsGe/C4hIfnscyQois/LfBJft2Hjwa2tkBH4z529
OH/cOOHnR1Xtd0BgWCFBAoMivVNmfdZn7HNCKK99CzHRD4tbExuIrwOsweY0QmHiGW2SAd3gueCi
uNkm+FnvM2fPbLNymFf8rd/NjCef9F7v8JOdYEnmz62XHoYzX6fHUJ9LpV7OF3uLa7hxOOrpvlm2
x49+uKn1DzUv2nqN7g6Bk7d3wF1qZCPjE/AtM747CvTFyc9yeWdi9+Trg4MwPhnZEHMyFQHm9Pb/
sCxioxaH/PAikUsSMBdvYspPcWZktTwPen1kHqPtxTV885cMwqc+mvxdwlvFUlMAkXYtGMbBYljR
9zPZL0zApqgZLRUo0roVB7DIINGoTqUwZFIPqLIpoPNbbu5LPOuGBfYWv4cyuL8aR+GgkFxpjWeB
5JOt30cI17GqUEP1bqfzZokrAyTStoUKXynbAbVC3NCthlP5ZoqEfxbXHWge5pUfQtprmbKH2dHi
GOe1SN5ZGJgUpb84n8iWDHiDS0hKz51xuhRoU5PQe22aacVLBV96lZD4cBvkvRHD6bpc0JSCkjvD
Qg7O9IgMP3pJ9+lFUEtrGR9Em+2n+uduI2au3jeRHwqHBJsj8c6frCtO/1DsPkZZiBBi8ciYrgdF
tZWLNHD91T7MUcZxalGJUpuhW1EmL0BRtfvlTAVcSrLBJCeHjV06vFSN+FlvLupjxVGdNwTE6/GT
pcwT696v1X8tKn7XfgIyU2s0gLaegMBM7+FmzoQH3tkvK5CvoDxgsxn4aVt1XGktkredUMN3jp/t
XbW23SO25lB+MVHfep+WqrmxVwgPXI0/Zx1uluNAU7pE02jXp61zHWAU9pL+JcLoPAOf0NzNZLAh
IY/6mBgo2IzhAya75E/qSSZdZoq5aj7VNjXPO+b1HFPmUQda3iLD48tbm7eXhXbouVe/8RYjneCW
BVG+HnqA8r2xg0Wi2cLjDUvwwg2QyxVjirMmEiIi4PGAI2ln3Q9EqZHbtEMDmQKlA90UjwP1dzt7
GKVqLtQTNuV5X6+ltolBY4vFkW3Lik/Qfaa6I4cFPM0nG2FLpRrJSB/azleucgkDp6YvjdJXPinq
LLuP+tLI86sr4yAS+hkMrnAMhJze7hTZShP3tW2PLfL27LMz6K6/6CB5kP0HmyX0leg/zyANx5tZ
psO/64n3wO6F4VB/BZDVbE0yKbFhSYHTnFrxX2qYddbYEpVePl608m37beTzoGnTTuk81DNUzMn5
b7BiTZP6ym89c+9NGehGuVx+WjO8CmM1rs8OaQXn5HWNhQM9Bad4a7214Y3wNNIdfuyItgpIkX6c
csS9fAmKY7Ru/ZTRJ+tdpakzW4ncd180KzZG1hZ1zvBAqU0R9hsS9kk6Z54GymT3wC8Lh0H8EOBm
8ZiAtgHlxvNXQEfLcrlWyOtAVP30DUV7mrnwX4EyPUj9HGKwZndMO4EDRLocyLc1cwx0Dm6ik9E5
TkZZLPa4g7l3P9Op5jp8L0+2nhEWcxRCGk8ookn0PiYbCzF+E79wM/k9IrxfWsRIlgq6lwM3AfxH
3mmoGda9tWUSXvL1GhuoiCU+amlmjYOkVX7rTddzNT4z0E2SnTy1PlwM5mcB2mDk8UXKfWuBqfVx
K7N3TmZlO1TZzGxCG4O66xkyv/hTtHzZ52JEhpFbvWGtR/IQIA7xw8tKMZLF4Hos9fyGOuD86HOA
8YhTGkkS9uiywt6jc5mywGg15xMez89OiCKBL4srZd5OYBg7xm15hgl5KdsOB0G3Umi+IF4NkQT2
AUK//K+h8AJ46UWnsaYx+dOh+ZxTV4eJSM6M6jxanytujq1oaLIFA9yggs/cMmOT/HATCcokuQnu
k8nheCWv6tcBpZpTbvuCscbz3cuOvVPnowCWS0aOU/uMGFMboOBkqm2oM6dZtogedorc1qRKb9VN
/6fRt4sEOuscUgAoJ+AFpLhxsvbdHcHYaF/RP2ACv1UqFGalh3HZvUt5EQbImVBPUyCtc682gtde
JNXRrkL4LiYUNWJKwii2qHNd5Jyp88zRzgIziRBq4fz74efgiLr9R/pJcj6ACYvpA5CAXO9u+Au2
7pduYRgBCUdrm1wEHD0d6zt5aqt+Wx7JfQ6B4Wh8UOQoCeabw+DyTnrTBIcAinqVgog211fPa3Nr
jtc+54za3lBsq0m8IkzhAGODB1wxULGlBFHbDamw+2yJnWzbvqreZl0Qn4NgI2bl49aypQGmA94L
UrH7nZKG29YFXtRv8nqhxul/m6t6spvCtJx6ONdtiV6sfDoyv1d4ZYvnUGGntUAMUcYbklV0UW2f
2bP0Z2Uo0DOWZfNL+Dx2G2iZznXEFJw9TA5Kk4bEFLGYf3G+QcANxSnisHTjsyUhw+ldPz/qkDAz
bs5DticKz1yBp609fpbn+iZ1UjbhU6pd55IhP5fWVlbKuztz6wo1dBEsZBmnYOS31xyV9bGH0F4O
XWCL6X+LYAOvpSQ1qwyByz/gcWdpf5vn9/vIxKEhYqvunip+LSd1kb+AcnEuORGJMsM8G2qnZ4eM
f506qSVUtba/rpgrx0p5E6jYmYygKs3h4gUYFMAhDFiH0bRP2CzYwoNuI3o440hAiecsi2E3hAbJ
r3C/TOn4HmomiKFT/YoncKvwRyeGIMG3zu+bzehuw08t2Ybsc/mXf29fBc5UUYAaNJhGW166svMP
+spB/H/V8hYScrqkCS+L318d3FOCn6KGCHxcD9b92SZoa2F6Tjb+dqU0cvuWnM8OfcTDOF854bbi
mGZFiyRGrZqi3sbhYQNsKoWwLBf8ZYh1RJVV5Vo6wfs8JvXvPUXG9SGsrI7A7GU0fehfsfTJASh5
WEQJJoLxOlBJoPi2dJ2BPTwFz3qQnvltRGbI4pXgjkP2ridGHgMasgx9mI0NiQzLtFpiYMfduBsE
yngpD//Q8pOC2wzJ2+O7Ed0WVp0ST7fi4g4e9pduQr/8g3aq7WwJRSA9V5v2IDVNjCxf4rdDVoEK
x5NGl/KavFXh6D0akKoTwlNvoZFHyUdQzoXdQbUPpBysx6L5hudKvDc1LdC7FiUs5bX8/Di/xGHN
MkuWf40IUKIqi/+PxSz9IPXLzKb6Ul5qNs65XWnI9E0Rg0WhJLIP/dhfaXvxeqPV5yskQuq8e+hC
QAOS5eOw3U7a24TWAVRWcZtY9HMAM1NgSFkyYuGVaZrtTDZBw8Md0otfrU/2C9e0gR3iSFAM2gXJ
b5qBd5B2ZhQ+EvgouEIl4cFyCHG3u3uIJ65Iz0bNFueflzIQXQrlizlJcMg05TYZ2TM7HNGIyBBs
rYez0KIfRh9xN/g6tIN/a+ItNLU1cvPx1vHp3rcvUNoYEt4Jo93W6nYknKbdn7Vn62QQGUzte4Si
TeqD9THr/2i42kBMyQVZ38YFJMPa10qW8KGwixztPE1+bla9oe5SHNlhO8U8dbD7r+U/N1ktGfwo
Rg3L0gAlobqf8xp6AiIhABBllAgk1XvEwt1bEzxSbJlDIzgkO/zYNInM7lMDaTlv3x/iWH86y7iX
yf4YFYNnM5wqPHhKlK+Fs6fnG4QwALIzHk6AzJrrgmEezaJwZvH9wpQZR7h0d4tVptiGN6j4Zar7
5pM0CZXK6P0hjJd+fIBIkMbCW3OixkVu4ktYIh52kYLpfzeSyZsC2juB7Lc14se6/l1gRWzHZUX4
Kzwo9cMue6m1g8yYMjdlgp3hNVgoZlZj2SXcyZRn0Lmlo8lXxwolk+Ocdxx+bsb0i+byzLLVTD9e
Zmgk0xATdAYNz7PltAIBMO2BF8vGI1mbRQp75QNrkYAKo3dhLhGPODPR6Cc2IEEKKXNN8cTccccp
4b5B4aGgTeKUaVjikMj+kPizxVfDpq0cdB6P5Iiu5LH03k7FwNt/5BVr1oOIUaG1M0byDX6CV9Nu
HCnyQ5CoQeDbSbCdfq3k2OhSy7n1aY5JUa3fAbgv8FBTApGXrqMRWQwRjdhhX+c9F992Q8hR970G
mAWuLKWpSEa6PQaebv5rniSt92Mr0utk2DxS8tzg3FE0FZ+ZaJI87gHVTg08powmQxraw1qvRxk6
11TWmRhCd9Y74raT9cp1VpLovza5Nu3v8XtJx/fnmKYJyruT1CVfjBi07KVjuidb+a3pHF/9IgX0
tabuAEFojfcahsR2rhKHBqtxfjlZl0gH1I4QWhJQp5dUxNJFpIPzetEgEQG94mRv0szmuVlwxCWD
ZNim9y3ddpvuLnVoHKtc36SHNVV0pfb5g6UFLGlXguweZWo1fYPSwi4iHdvtJiO/5tB+wxuHunVJ
jqOtYd/v59lVQOqqIlmbaRGAsviAKW0y2Zaj/IZYeTE6heYXxaQ2y8gZXf+Xh41Jy39tBmFKYBn1
U60WhzR2gIC6kLPbx+SsVXwM0/YHB1QgvbeJ0MOYl9AZGHWyGSZprYe8331L2nThWmTkPUVVRME2
w47IAU2rYLPHqFPirKv9GEZ6rNiEt03zr/Hklqikm03ijdCn8iUQ9lof3+HMH1vJcJsxM5oqmQir
eK6Y7+rTRpVJWczeFczGkItFxXZy3TrmABYHJxbWGY3JTU2CMH2cB1iMaE6wzFaEdT1BQPJU1kz+
R6O4IgFL6HvRHbJTUV3pf9MUzszlVHImqPKMobDhpa//pfvUr8/spGGWkrlLDDZ2Gdjyfqv3eZP+
BEyXchCNKQvctRjb8dtBNGOLuhW74pfRKVQLCfRG/whO2Nu0mUQYI3qUpjHT17YisPNXJlk4YkZF
2j2KlCVCP8N/sql6zqOEK0TEW0ZTo/1SAtUoR0VPr68B3g37DZt3lRMLcBAjBvkMl9p5UmXsqpXj
El8DQdZRq81O2YHnX3ztPqzMlMt073rwy4Xv+h98yxtYpGlQWiPJFC5PD5ulhMX/+mqpxbpOOQyS
TpB11w8epWS8sBRzPSaPTHraCMieWsBjz8SaV/PqBUWvvoqNZyUIcW7TP4YB5fGhQND7B6Y/84Qa
Kf50zEa1lwp+VLiGRVptF7IxZDSFdYES3cDC1q6moetzhx2qmDmvv6eKC9U+rKCc1nOWj0lXH71R
UeCKqYdn3Xf1Qk+CtQQrNNkAHOlGU8nxFpIAzPsYqg/AQL27v+oHDC4Yt2FipXUCuiTzv3PLxLTi
mSnU6M02tBWWCcG6t/tMSnxpyjt7CT+U8i6jwBiAXFTTnoP4HhCj8bmlk4A+lfDrzx22TMSTdDlw
oz6ALxyxyPHEi1qnvSB33rvLdpwrpNsBtJP8w+LtacGqEvFmCH3V3q/bbOJdEBRA+c4Ziep0rrqj
GEUGzxS4VWsVEZ8NjtXDaL1Sg9Hz/btWcHRXkt2txBRCSIFrb0Fu4bm/tNnTkh/ttg/IkYhNUErt
rdtpnFVQOs/ItjYr1tClIM7C/eKblJWtsozUwQ1EtccdUXPS2gbBqgOtDAmOHRrkUEH7uGmD1ESH
CjCWtOBZVz5lkr6foViDFcQ2CM6iIPwbIUtMIzUoWSB1xRF/c0P2ws9DYZEA+LGqvv2i/PFQpW3l
He95Ywquacs4YIjp0TFbUp/nc3E13Ip2osmgWr4Uo63JkqMJ6LjYnIe2cIgC9IoggTGNOVogmol2
RWLLbYAoGttyByy6qz5q5uiel3eL/jzgwS+RO6wqj/CU6SLqkpg7GW25pBAJ0EVRZgKgSIo+SB2y
PkR07nZ1syDVQcLGIDaQzB6w6/h78t8jCW/LMCnQA24SqmWqrSRCZzVxkkNJgENBI2DNEeF2i+Lv
/ffvhHdsyPgo9Pr1QKvE0oCkaGdOrLQRUhS98g60zLomqqDoLQe9t0Ww6oiKx1CkHrBC6DKWlKnd
3JcOp9ZIB7g4R5pQAW8n2U0caaYeswb+RnjpeRWJu1dS5uzeGtBFTVzJA9/UYtBnSCoyYbfkdJAJ
459dEcFpFxDM0BoaDjfYyVPm9D+CitrVVK9pfTEX400vdX2A4FxOqXj/hNrczCOBx3nOUVFiF0gE
ePbVRvDZYu5soccIDwHNsiMmYzwbyQzb6rObo7kmZoNibPCV9COOGR2afTmz12sUMn7bIzNCZpI6
nfqGdnQEjyBNLy7NXig5/0neWC9uFZJEREUW+zdRnHR9T7SV3Ll6C5XNpFJ8LWNzhgPqYYGY2q+a
J26u2pDjCaUzx4JkP+XLlIvHb0Q0HfQeuD/Mb4UpqOqiB/wZJc9AZTN1kez6D8spd7I8f7XelcZU
fKG3hKAHdeusoDzCXtxm01B1GeqmBAiDETa7CCcRoKzbmjSvjhnzQMC2abzD7D/TmeM8rEik7HQ5
oVZKxKlA9nBVdjOPqHkxus3phsgP9m+gm1lR16Aywuyzp3yM4uinWKsUeziDoR2teF19PC29Vizt
B9y51zP34tBihlucXPjd4jY3f5NLjU9N18gdyceIgqCZU78LM4BoZLLBe9zv8j+QZBLgnxtnTZGq
4JxC04jaeHGZx7McbHEv70ZREc6UkmZWndDU1V6cp7JRpezSJWzCNfIPzq+ognw40UNIjIudr4yM
kgG1Ekymdv5dFGlgyg01YB6Z8tg5r4XHLws5PsmaW09+5APj6R1P5fCV2nF1om/9AHA3m0Nlzvdx
g/KtTcvlhGAR163RVRz7/HQGzIU9MRZrwdxopBQRaf7FNzM2YfqpG0xsNBVuHQMrBObkL1FDyHmt
27gHZ67meobyQ7bujipjp1/lY8dyHki8/S6ZufR0k0StoSTYxVuHwgDoEIHQdhb01BVpMHKHpYxM
3c+JISS77Gc/U5FBLrd/FDM30kjqdNA1lT10znC4TycDlz4NeTinkmQKWunBZAq4cHdo9PMyFY1P
RMgbaGLDW/tJrzSWM2O0RBG/xHAtmcH6SrpI2l2yGbvIjkQabbLMEy1uwoG4CEbk1vH5kkZCL/QR
yDT/g0p6VXQAO7CnQG7HAEc8lqv+ZzQ4cS8VfBOz3sV8PeGndtxb29InXZ+pd7RQl2eYEU1OQX8D
GMFgad6bNIuskWo3i2O8id+z1YH2q2TWpOp1r2H8cvy3/0/fpZpXW5XC/DtNYeQjPOT+XHVL8TYo
8KtIV7UFndNkFl663aBq/hgW0XpvbxRXgUsk5NfHFqZ9fBs15wpcWGJ/2GurTA0Et3XgD8YY9Jeg
S45T1t6lhrCcWjPtMeYhcKCGDoYpCPwNwLZCJXxnfL7KGK0eCOrzrXtftll0IxwY3a99WqSS/SJq
HyWQwNhN0ScCD9Mg8TaX2cDJMCebWqVtBUowBkOmYx8Txpycj9xY/DcaOLEePL8OS7yQZS0wXjfi
7M9mzlGLSAcAbtaf1v9T0SQjuA3RZqpbIGa0+14FvHeiJFa3ASc6og0Vdb1nI3cGC5OCX0NiK8UQ
O+4Pnyl91ODK6ZQ+DHprmj4NQvfPEXT1vwCht3X/N4Qzuu/CXkL1ZYfIlnq7kpNzY8ITNvziEQiW
+amJzx6Jbmr0jVw+jK0IVkH9j8PK/x1C33/0cbV/Z4yc7i0wqxBzyawCBf1Z+2KkGR3scqqVj/t/
+OLADGnW70mIDBJdqt34cZnrXFE5ScU2HSKs7UMHxxuI1z46orZ4vw1M6bWnZlnznJPGNsBhuM0/
VbBr2eZehzfewVSf62mgktUDZbyh7j49BZnrdht0eVolIKjGKoWEGNBl6O6OCQCzPyzMHyiH9lcB
9VtgFAGq103TWQPB9/qTAiTWIFCDEF/nXghnecLdNv1qXZJe4ktiikB25vsUSfN8Zmlm1GAUVjrB
dl+sMJdyCgWt0lid4UOQ6GskOAMaz+27jxEY//DQjNf2+s8mvROYPiVclU/1tvAusKHdfM0x3ILw
HiaNl1qwzgYPs80er9MjDM+S9Cvmu5Q7Pk+WuJWjZNg8NL/xnnKfr7rwIJDl/9diOIPR4acqVAtX
VFOugXlLLtAwD0N7zzo061xXR+AIR68r1xH/upYKxM9E8vpieXXBoI5KyX1USeVo+ExU6zume4LB
/9w4/FdUrnIHOETC01DrmvqptNQExJeTr4PsgA2CxHCXbKRnJAB77nrmOADifr7IWoB/oaQ3vqYv
0L9Gclm5tWG/TlqtU0A00rjHZQlvozisQB3ERhSfd3fMvJZxH6TnJdmY8fyHT4Sfb2RF6Zpj3tRz
/GitRJy2SSB+zOLfDw95CSOW1hNaLD4UiZivqDZEO+yo1NXKUHzUdlfh1HwVTqcqTwByBjX06Tjw
dtgYelO0eWgsyaFCeOKw6OXaZFmGJNQRGoXcVN6QcPklGl+aRBHTjm4wnkXsIf7IXcB8HHO9eBmO
XePA7Tipi4CCBXL/Vpfos5Xgxw0qWYIvzu96jxRIW/f1AQ+OKc3c4HFL1CyngvyMiuBS2cwTria8
bOm2yHri7ydzhUGzoBlKqbkedo4nBn/pkGfccjNd0J+KNBKojKZACm+RNvj14cDtNjWBTV8u9KCY
R5/peZea9rqK1sa0SH7fp+68qAE/s8NLkqC8EI0Qv5yi730bhTkWd43D7N2uYkzcBsv/F4MDtF79
/ogWBiooQtj7hljSznlRTALaue8eqF1mPDI7O7XG5A3S9zhhD1TZpbT5I3UI/ZFXBw1PYeQCDuIr
X7OFE8lEhm8CoLC+Qkw3l+H4fMDgzsHowJnzbX+PQNrIqjfxZ0LrE45V8X4/ijLHp065ymtP2flW
oU45sqfkfKRe5ZXrwZsET0UXhsfqVr9Cce3popz+ofTfPrMlRLp1qrKfJVNHlCMpYxo7r851OH1P
olMldZ8n+Lr7bcbGsnrZyZWyaNVTtZVpxlDoeVwJVj1Im6NU0XvXLCiEX3XXkHMRaFctZ9GfJlFb
0usk/FQV9DV089SZSmb8di/rLbPJgda6zxXOi/5Mp9Y3MRu8ePfUBNFRwKD8hLHjSpGs/mjZXak1
D9zN/GQYjXkLUThPDKw7T9RLDOjHouV/8JcKaBxFySlHke6kqQI3yk7tdj5/gHE1JD8w8gM5nVQ0
KY3i9Np5/Sw08JyWtSvcLbZi5Tb/MwamyeU6qN+l8ocZWB2Dyt3LRQahR12VRCIGUtkaG7FmLGI8
dszvNglR/uzVppmqhF764C8x6Tvwp9qYJRdK38lG98rKougr4RrbaZQAk6bAxmfAzp+xnn4ydy8c
RSzojCt3W9ulD8GKEmIsSfhaLqaXdn/cVC0LSMWBPY2HnbaMfyIs530yUHOWmcIxGB8EZ873y7IX
UdE+svVWHXPwCKYVjbTU++BJewe9IGVXqjDHTNoqjg0C5VGQCGCvJXxvLLRaY8kPk9Bh1NEvIghm
0KUOox8Hj3UpGFXa1ffSMIZiBV1UVNXYDymV9Cn7OyLK2qxFKKw93qmHpMLSiDmTEWjTwHqHmH0B
WEDJfOsARB31/y8KlkgTr3KInxl7fxUBU3E08ez6qwE+jiwvk4ngIOG0LJxuhJ1z4C3F1Lci6AkJ
Nw5WosKrz4rv+I603KvNkfOJnGQyP7qQb55aJgEwFl0wXUlcDsDws8JlK3nPHkz+BmG09TQSsRbh
UyzEYFcshRe5iaZxwmEEprq3mSMuil9l/d66sw/wjTJbpYrTAcBVwTjiHj9L2S7zFhvv3SbpHQDD
VH87Q5HAlN8nHQ+OR9PzPkpnABuVOdg7ZFXRCU0lKLXT2KqWJTtz243qV6Qsx0w7OozysZw+NIg/
68fnEBcjqfKWGOxw+3JdJG3hKFknWtZFzd611g9eWGsTKJvYszbQ7tFFms2kmA/gIrDoLFhjFuwv
dz0km2VBqHC5ayojGlZp9t5dNkvE7hNrQn4VGYY0fSSwNFM2hvDgC949x1WuuLcmhnjFlMbbREdw
3xDHHrxrW0OYMJ3s9GAZcdysgRIOGhM4oKCo3W03mZZbDMVXeyZXTMLfdOizloNJD49KCbsi07H9
JIBfH5YysyApluKPjH4r/TjQqoZQ0MVkkgVVB6bDDXOzIo2AJYylE0BqjptOuTfAp5dA2XfJOmOc
QG4lL0CP1rmTRRTr3HP/KDDF5tFAcDaX0noDIid72clZkhJfsNLF/psDzo5oPEeY2QtjxiDGx7US
TxiFbmJL3OTzfLyb60klKDobILbforW6ckZQe8ax/ljRw7ZGgNMf5VHOWxPvdRg1N1MwJFeEE3oL
9x86ACZeAXDMoFujPgF/N5mY6tlagdox9BTmdaFQXhQN91uF/W6isIiIW4arKnFDk7yuKLGkkyZw
oTqFf5nPDRhRSS/O7z93D6lf6h30tsxVJxqmfUl/W5oaKQDIOXxQ3vsl8PCtflQzTMRAz2qHJw9R
5YyWcudChyncFjDrBTjhg89ikiVgBgnzroK714vJiLSl6er06Pl0AhY4fdUi5XD8zzD7kUPKLBDW
IRBJqoIhtjMJVunbrQ5BQIM7OBbtsEPDDTK+8dex0gOjZxCFugWZAS//dLQEyjytZMlJXh28hZJy
KyU3sV5BXm5GlOUffn9nVKDYFK7S6JLqTdcW1LM86mdN3Tj5TgCDOGs0s4H+PP3i82Ct62mH+bBk
1KphvNw4bqOu5s2jgk600H/uJxVZAwquztY34kRScJRR8GNtPXuPDn2aaLHKHxyBoLYc1CoeU4WQ
OGumO9ns8mFHpp7fNelZcZHvjxEwglaEPwcBnoj7OYtXEDikuXUUoiFu+vvFA4s+S4aHxLgwZvXg
Rw1HCaOs3XjL+eJVEY2NvZWIlQRhRR1It7Wtmg3dnipv8AsDkT9JHVaiDuaWtB59di9eYp9RTugP
i6n86HZ1Qas8M4ghxEH6jfINYvVh0njelMpoPYnOIEDYd/AskjaKXbec2VOnTLJawUmGL8ROZe7k
QReqwqsKymFHbJGJt+64L0o8tkutmby+WsS4Iy907waANmS+6GJDKg5IhI/GR9r0TS15Z+cXkTZX
9ALmtaNNfRqcdbsXJLT2XXXTae0yNwf3k4TXjxbNgDhquUKRyvzOYQJmEOJmAoUnNE6+9oGLq9m+
AN4cqLHkMCV0y8tcqFm166oaKNG1MxEua9l7UJpCMunVTSriet585uQCpJaAYAsAm3xfR55XcBTw
xemtQaR/Fi8z9Qx8nylYzCwwNuH/AQvNIqvPs8oEm6WfY+ExrVoLGF5OpCKcNxyp2akBOQHSeY4f
KAC6Ka9/Be+ppNh+d0TDnOO3uNWtuCcyyXWAzvHYWCQ+nfunouTi1NajxWN8iLCMutWqscvysCvh
QWaW/65Hc/jj1sHmbxcnkp4ntDoEtkpHMJHMLVkP0ctepZFCSs0MQRLZMujx1flBVPe/4Qg8UM63
WbarFENjSuJPRMYt4hqyP5OuiIz0JG02xtHHuWu6/VX6tWQ4vBuClnHq8tb04fEzoVj6Upal2xVy
1ck3mDNJnF+VEPX9ZlTAexkefbhTfh28FMdNDGuUho69eRzduBxBqWkFtSkknk80xa7JWYiEnZ9c
IKrIqp0CRTA+sa8aaPtjSrBP2a+bIdQYMpMBiUfhmOz2BxBOCOojm19H4dKYXV5+m2M3nvbAHwSF
YXDpy0k5ieTnhVH0iAgT8nNx/KKvWPWXmQTlh+hhbmPA0KhL8sXjqkkUAV4ePtEQsAR5zLiTig5m
To+TpgKhWYwGgFf25JCLBmYcSUNSImxww3GqQ8y6SR9RvLa5DcxH7J7vdDtsuOYS09r3uoxoyGl/
OPd7ytCgyqJEuedl2BicKvazEnmVMXHfJKOGjceFLbw+h6yd9E6GdVKc5l7I/tLCHsIGip8yUwZH
CiQ3fvSoVRa3Uf13Fs1BFb+Czjl2mhp7f+xBJswZUexFqBrBvpkkuXAfFmbNM14311ArohuEummu
Li9whlxPeQVcgQQkvU312fL5qRE4dB83jqDJL400VDTki/Thi62q5IXwXWJViFCkBpzlanTXnJjw
hHxmJOF4iJttseQKB/pRealdwCJjCxb2+yLYlC4c6Z5S0D4Re80WWdouaM1ly6wNIQJxcFMvsEnR
c5bB5VqWoU3YpPRMZzp7mNmVZ5vrNcvpqX7TukihR5Hx7uXTkmEe1U+/TpFa/QSAUSCp4YUD2HDt
h+PjFaBAGzwBTterbH+nuDQyo2xPzZrEVgNGlbtcM/Omucutx7/GPaTGkgXNEisuy+rCjZhW8VmU
hBzg68sPzUARbp2CSnurvkEYztIqsO2AM7wIZbwB2raGtuqMddBmlVKlpHoScTHUEIBn8nS+090h
tstTKnTcfkSqiNpBndRRE+n8sZw0Ml6h2QtpY+HJDV+iL6/wm0+bNi1LhcBgx2fnNW42wic/wTcR
BDvCdkdA6EwHjMvmesrINOTWHslDpD7HMq0BHgMhVSrhEo1cJUAC0axmJHWWwIhyMbqepwcvQ7jk
/yXpHaOTWRaw7MrVE4swaG+iLJDpzmbmVhfXI3KQA63wl8W0K6iDA/nzvGJis6L5aaUnKDGaKZDg
23M/rdZLG54rwVWx6DtwKsps8FNu7c//QhmK1EIAZArgrR8eBn1Mz3+hZogwmMDtfOA6p68hRwt/
IaDUih77AcN3LbWe0nkyuJYTtl8/fvJQ+wwku9JQvLIcfMpYI0X2AAcm35f2nCMQycnZSucwH5tO
mRx+/GArc6aQhqQ2+moNNQd2w5ZKVn0FC4OCEln0rWkbT/r8Eh2rHv7cAFgTJptH3Ot3U4J2Kvr/
nqV5Wr+9OGHgVIIXzUiG0vMVleL8oK1ezzKROfEQFOE2YJrbLsLlpHTGubEqrfiVfVom9wCgoJ9T
hJwue0IT0L4XGOyizplkfXNr2tmo4dvz5mwjrz+BNEdIMt++4F9rut7A8nfY8juhhpAQypc9x2Q3
lnJGN7KfnqflN4vwWfKgxSnnKGSv91gPqzYGMx60mgUowH0DgZNIPmDGeQXiiG+XJZN3CuOzq34C
zzTTyquK9bp4fU8y3fTWQDV3+5871rB93RV7hDPPAGcNlxjC1G90ia5iue+TsGRK0wocD588xslv
irEoaFQummANrGPk7jjVwFalfr9PfrJHbAILZZlidrVJWrJ0jZ3VzoqRBbST4AtyyS53NabSOqZL
d3nKyQsnihi4snxLoKE2lzE/TUji2s21f4r9wT0i2gh26aOZUCnvw4O6NxrjwUmE86EzA9im8SMc
67MOZY37hnLXu5ufe+pldA67Id3RiXxd3bjl2nq4rx7wnGUFmpkaCLdzoLEoXfQwLuEb6EAzddkw
tbhghcGlLXyGR3e3itGWi2kJ+LVrL6jUkH+SihCAoB0H2pPE6PK0lWoxv1S8fw+EeYXv0Xu+VgSa
SoOrP6VODeoSRBP3uRcNVynb7CNkN+O0AkBWkRD6HtsiT48KKJjKqnbd/VmvurQfIQQINwsz7mxt
sZx3y2IHnVI/Ti9KhoL7QbNswFgZSrHK9zbx8nELEZMN8OOSnNKvDNXH841K7wFAotLBbqJVpw03
xyIJbQyfDa5nM7vN30utRBkqKPZH+P6qSeA++HqxkhgqyHiqL5U8wD/wIP+apZID7EE/jpJN2TEm
Zu3qAzDMnMlEpB0gnbBhNePD1R8BXfPYetobFy3Qi1qZARXEH1V4xECGl9xptYHPqQURBi/JO4Kb
DywPl0QTG0JARapi4yuJ6mA4GZ6CbLevEV403YdLbNR+zwR2rjPRRBw7ZRInfbsgrIifRxlWu+43
ZC83jJs/5OxknNWH6PjClbqZw6cW8NOSx3wdmz3rIk5zct77PC2K6E1fp/7vPRGWfAOYfuQ7Zi6L
mz+2VW5ogprVFjTCEWaZ7ifzcmZOh0TXMqHeImuTqZ54if0lH3fyMyb7otguevlNimTCk6MK4zty
klXU5CWkoZhqU8yAV3c/yUTC0cRdZXpMZvpjY9RvzR3zfASV9dENLI4hcGJcfTSVY5mljBTgi60R
5wjqYwl1g5b7DJzJxLPT5OrPv5iryCUmBcFhHh98eXaf0CjdEx9LF/NZbE+5uQgv3/R1dE1pWIj4
R+GiS1rWlWXOggXSvKI9FtqUdBARq5QqUfE2dzKATcHrB6PIm1T4oMBN3KzkVs19m38TowPHvLIf
yR7LOMHZzZ6d+a0plDdQff4/kklPeBPGon4KoYNdQQquUJfFuWUcyn8kgMfHshQE00iwR2zwOpwf
ms/jcJ6E3FDhplPz34zL0Q95YFBpKzcXjO9A0YWpJH9wz1n5odKoCAwDawN+iiUM9wYO1gqK/wI8
EITvdNVx2RP9mpPHPHeRMKryAeGi2npLkXrY1MlzVdtzphquyLWQz7plNDo55lyuY9wiqak7wm2A
++uJJj20J5aLikppIbnKFbd2OTucwE3dKXdzlPSvkPu51aAMhQpzWa0g87zz5Xbg4vZftvp9+mjs
P8No5yMGhZxjtKlvPhqZzi9Qey8vY+vR9EP6N2+rm7WwLqKPI967B/ERa/BqlqLZf/YIvMOFmcx9
HVOrHdUoe3xyOAwuR0jqZLnQiw7HbXKkJ9q2NF8Fq+XatKn8KLMPqVsTNh7nj7yc703VhxFOE7OD
Mndqr9dOzPQAO+BrwtStf2PiwqMeuWRFV2p3FHD7sxyf+FFeE4CZxXWPJvRfe8rD7IgsA9+8+o5g
vaiHj8dqAkRHe7npYONBjKPhrABBItbpbIGhLH3z7noGIZWfNjZBlh8E23mUiSfc41LAEEBntbpU
9G2O0KWMsLb8YaIqMYEqe4WefQ9JJqAjcQLqeAY4/y+D31HC7JRDYYe91xQWI05H7Y2KbWKvTkkQ
wD1T6dsFbWSzT8++RvNTpKguMr6RVXC2rwdpJiXD/aUF4vvwa1cBAWRoNOMaUP9T5zD+TryYHC9b
hTK4I34yRH3iRvX+6Sw+s/ii+1v6LsBnLCUGkxBdc+h7ugMib2WfsiJtzNwnnK/6Iz0tbBvdzbjB
RqI/bBIbNX8ancjPjjTgRwsGAISB92pWIrzSSWJfBbRFHWKvZ6AYx8SBz388W59gP3GCuHYObDMm
HINIWsqqWU7xteEVDmolY+OZgJoyhXD1x3+X1avQ5UIpEQxK0u9S9KoxPlUb3gL2Dp0Rt126FeYv
vAIYfYszup5QASo0OGiW/eYE4v/QPZSVJqzXqLtIyfg+WQ4ydRRocdevANXLmZsy7UfBSHri94nA
O6fntNl4CTNxbzcbFbWS6iFRP2odkhXLioBJ83XQ+s0s/vK8QkjNNvwX6X7NKgVA074b0G6am874
JpkFUiqIKCQOwgg1mN+VuLOERrXqhpszb16F/nupFK93iViBLqzUAGpfTe+FVXQPphLKYWX7KOHl
WqsJq/CSDZC30e/ZxYWCyGmtkrB/y2S6t+VZjG5tyJIJOR1bvLkprGuQTF+GsIzqldZLHH/RRoPF
almi9dPKOGMC5uLmwQuX/yku84cVRJn9NSyb3nRX9yfBJym2PiTzFycCsvjshLNsA4c5VrN0SHp6
MVaUYgZydkbanvU/qkAHRCKBJE27fqNaXhnCXBgwNXsoz/BlFB/5tgChOAYoJGqi78ThLgjtnDPw
+E2+HWeAUGg5Rj+r2hp3HJksCU2s2fxAyGEKbedXGnAzmSKlbJa9Cdw6zA9iF2c+Ily/yQi+xc5K
DsqddDiplK8qrY6p0VD2ixY/X52hzq52uen67j8P14dGZ4dmF1lHyeu8TlMUJS9eUllCfKeoxtf0
tURpDifD4JcwFbucKQH8r0hvJp6imB6+qQiS0m/a78qA922QT0occNpNtkoO3L0uqlDVzmoHNdV9
vulNZD4+hOi9N3B6nZ+SViV8ayNBfbUngC1WEw9vOcVGj2CxCIFkl+NKhRde0oFE6eRW032eforB
IOKN4CzVutcMaLrskq7KDUSo93W6sGOYDNWCBEmCAVfMsB8SuDY/wy8NNb/Ch0IdB7NArM4r6PSZ
UKR0UkASJzQrfCw4m41O1QIEPoCEnXeAXvPRlXMqS427OS7c84550DTuh2b19Z4iIbPr20vXclA2
5MusAiIr6jZx+z4/7wsEIFii/RjjBkDJZNlAC4S/NNAA2A2JP9Zs3Q9dKRb5M/M/kzXhLO2CXeTD
wtgOzPbBYWZPJhJo77HjSiDlZ9lhyJXWPFjQMbt5vCAtgtB+A2EtaLd9JgoXwGbiAXvsMtwzc/jD
7/YGV0TVVIfDvsnXxnvC2OKIbTWT3l921He/yTinoIdiogvcI5tm3ga+I3DtIR7/ShRtlksGx77e
LlzUQ1VGf6TCe/+W62osh5tvGgHi7D1HyfAGgTwcChAS1fJfpxTmB184NT2Uh0OU3odd5hB0da+f
DSHkG+OmAaupGWJV0T4kZygVsshMvuLhllY2KYMJykthcE2V+yQ27Oq4ZzrUdVfipRKlFSRITXv4
h91w5zSOLBEt0IJeKT+7gMeQs+Lk3nCVVlkjuHOHcpcZR44qnGSBE/5UviM54zsl+hOS+iSDDEGn
IhSYOWsHs16nSuYHKWspiV80/DG0n0s7pteymHVMGC+wVfypPjKfT/bMGG1g5SbiTBMQlwGERpjK
TunU6dfnkA8nkB3t1kQnti8TaPfKoYkAvGwERN4a4rnw6ECcUKg5kDIB/zEpUyf75DUAQNFYz70Q
jNGv4QkTaywjkQp2/QXhEeJ8sRe6Thv+yTg/Kr3HbDFMKONLe8Q5iJ2qfgbInnTMxX5DJaK/6J4P
hqDeN6zxMbt+p4+PiFZuoTFxJGWUaNlsp3SIyPxolQoLqhvaIuy/ayB+86gICd7Bl0TKhoz3pifF
dCcwH3DcAhQM5wgojwTkLj+AOZmo29VmihtcVKpNzoAEXwUIx/UJkko1TzJGiBo7BiGN8J+n1LG9
bn7NMbXeVxyDLJqeEqBaCySQw7dKHb06FRxbIYvkYdjivjpdrHn5D4MN4RRJ+zQW0C7VIlPwssfY
oCuTJy+M3m+/fwLtCc7JyTIib4MA1eNawDz8bBLI5XoGb/63EAp1NR17caCKaNuHM1nwBiavs4Hq
2uXrnrdKaOirVikTeHQPak+pTF4sWtsv6/7gaeQkApw1+p6lC/Xz0YT9eFp1W/YrDElXdYbKRma1
vByJynHAE/gySEoBiBg7sywTx54DtHryRbkJ5YkItDWzSKX4WtFg9hPaAa/jcWwJcpYh4TQ2E4ZH
8ORKWe5sLKfs4jzeSlkAF57wxfxqVpr8G8ILVZS0nNeo9B+QDkP7kTLaqzjhSVO1n/Hvr+mViD8Q
ggz81maYcns6KirRL9QozV2ilPxrGZKwqNMOEoIdN6WyPLadUf1ddogzFghvcQtJDP0IYf3BdCJw
56ZmTQhSxLskrBMsxJio6ddtqMH6nZVMJk6CkjYxCGfqpE4kylJRaCkWtM/W1YTvzF8cxkPReMIz
0GgLD3Q6LIFgOXiKWd9QanD7/VMzLjDQWdCLlQBvoWFH5q3JIHMMEGMF0CsomFBur2J6BiGTQXXh
Nvke+amMGYmBYaqBv2/T+RVb5kFibMEtUQ0SQi/L4lge/myZSJQzDaDCNhHT2JNc8lIQhV9CJR7B
sUZnyaQVGj1GUOb4F0DR5pBzXjdayB9f2aSyFlKKyTqEqN02yXos5FAp+eEGHt4alJ43OkcWkU7b
qhcwaBkGLo8WC0lwJ1W/3C0Zr5Sl+v9UuEo353Ykh3sjqdGm1YJE/AafPM4er3v7X/xK7uXhUbng
OjiUzP4pSHmIeq6ms7b8KQttJurtHnIX9yCs+AbEGrdbV1u7Ed2mNpOCzQJVd969fzqjH9gLS+OR
asJTwXEu3tKGMmLslfRY+sArYeZ1vQwKanVBhQYQe+kzX91U57mblUwmAKV1VpD2zm3hCFNZxM0b
KdLvOO1+FiV3j4x/qP7HDi3ImL63a1AuqCEQjM3gXiQ8wP/jedE/APMlTXK99UIMg01IM5LaoiVE
p6MKT8W6+X5EI6bhS3ia7jMht+paU1d/IKhJgES5EIhInU3ynEldW7WZstGgCskZFijWOr7w/WUY
FwXzCFlv///y5LA+XG2po74gzLJ3Kj9XdOvSxalgj4gpDneMIgI8rhRPt8nqqx1ScO/6O9+8YFED
gXS3e92yJYH+ikTqkltAij6+j/I2kHlXulz5gyEmpa0X1ZnbQtL6X6mpTkmB54QVAG3uu/bykC2/
xykgeRVRb1jfXQRFwHRymqorsWVL2mpKBaQbpTwUcg1bzOj8SVsWqbhDXE+8LxAI4PIh/yMsii2s
olvQZYe2SkvurjuUsm/B91NA0SnTeII6Xobeg5bssR9Swg9LwlPIWtZ6qjutNe2e7W6KjGCBpqVq
xDefnLfOg+pmJ90eJrmHH2LBOTeXTDQoU0kXznBWIPf+TlqYkMiwJSsVZCbfXoRQ2/MlwOe7LebR
dMR1iNPOYTZdnmJrWes5zdATkRfNQOiIweoEKO0U8CRWI4if2fCj6/l8B4zXpxrdnkhll/UZvg7U
VufwajJbvy+qw5rsveIcl/ftELCzPTX1Pc2Dw9+UsVYfxdKEZKvnyu3s1BOULj/K+IwkoNOYcWcn
6win71nEQMASYSZXd+HG8Xvv9AOE9cfnkRRuPgbdOKlViutGups7HDqsPsxqqr7SWCK9H/+Xnsls
9kxD9gxrJpFLwl55a7RNcpgb7Er8qn3ZQzorzTzVtn6ayy52xJjPuQFQN4uU37F9Jf5gYIs+VcYf
jlumrbGUntccg6BG6BMueeWeqdUT0hFj2d16Kv/4syrphkTZwO54i0kJXRLE8VfHVYNFIC3WbAGj
9GNOwNnlMEMEJGmmVQY3ohXfFhqDsrESKIu0qSRhYHjfHHLTdH0kUTdViLhDCo9GgWegsnS7d/Pp
U49y6h6J4yxukJowNXmZluR58LMsgSZ6XFV0y5jSUyUE+GCdMERSx4zPCJL/8sWRqU6q6Jm7gtTJ
9FAS7BLAGx79CZ17SbUKl6vXok53TZQ8IcYmC7r4S6D89smrT6SMSwmu4k2BRS23xLjRbjsThbyT
mgdWMhW7GTSE0mR62qxGXCTQHcG9u6YcveprILhKwGCPy2QVWLBG29YlxAYpprV1Mcf4jCkJJY28
A94ot6I2CbP3I/QVxZqCc0mpZ3OxWosPJjeNjafM21u9LFZsmTuyHyaiNvCKLXz+DVGajDCwvVTg
mHFuzl0ONMTzkjh2v5GgRvvCZqUdavyfMS9pzbxWO3WB8u61gQYp8iN4IUQc8NPSoGOmkTI7E1s3
wNVDu41Yr5e+XQFtyJjiq23icwZc1Ai1nLwrjCBV/WK9RWlhUjLhAD9FA9ukjbkretVlUXn8vlMv
oZ932I4jZrOjwFR7NxOgWpjVE06mOdDAJ/FGCgYbG/ZKQOAAmZ5vfoGRKa5/fu+gWHZCn07bi1lS
CfajpaZ8I9DCWh43ChOtuC7vbUmoG+7WyTpDaUzm1DlxRNMx8YEMNdo6BFwNSqjWdBon5a89YNpS
yx+GA4JM9Gtftsbqsx7GiEOJ8RuYwZXYE7cHDeOK3U8O8CQoK3KqbgaCypoFiTMnyt2MczHKQLNI
vrqwbTvAHMzu3AL0UPIHjkVDkqUzXGCHydnWrgrGhGIPpbQaeez93Vg/H0C9B4nuK91HEPjyE+O0
bDnhcFkV+BdYSLYFLK5HVYF8UJok/Cx1WL1ZNbF6G2kT7ZKsyvxFcbmTVMO++2pG8AxflDhmOKXL
kNlDIPWoTZtSWfnKgXPLOTdnc2xqB9eSzo0XRP36qxB8fQoAoRGmOXR8rfP0zcaipu3bul3fDoHV
zcV/C4VmaF00/FudQJoKidQpB27fPHjc5OaFi5a8pIklARMf2fFU7TPA8H9rRzaGWG8RUKDGgiqd
o4V4hM81sDcldJpXfnmfNaVAJPWBfi1UpP8TH+IXwg2Q1Yy0Wet35es76T06sh1RqM6SG16laNQO
J8OmEWlo/b06qjbgkII6xEd4rcOiI0zdrCMVuLIqivgykz46iD0AIXVrIW6YXw1QCmo2H7r+uRYA
xoGTuqgjMMERmpmT1yg9oT8J1LALBwSnyf/Nz0nGBoo7otpMdI6F4zzdAMwANVP/Nj3cfEMmlCBu
5ePPD8KwofzcpI5iPA3FmjqQySCTNE4yh7iHnYKFjDdU3nb0QYsYSg2G6tXF7DfeQvFe5TeKXTu/
O8WQLXKEauLL5hsSrHHY6rugdgYaYzEEj2+5Ye5yX/kCLR2ZHF8SbVYEhsUEDss6YUe2e0AalZrp
56GeYbfcazjWWavvLLwLOApf7Nk45+fKyrLdJTw4zg5aigOdsjF3+OnTCAXhZLfUqScPvxyxNA/d
rbVit1QeypNgpEGPyq0aHZN7jMAQFFohCtWrM6BM3HmzwXc/KQx5ijLdVia6rmB+R/JxgMbXShQk
X0hLhWCqnqJaRCWQ6R6N1KE3O6905fknfHUw7lSk1cfxS/o9Ys2dqKnkDOYikCG7UC9aKrNJyPHr
rQ9705LZdOuq4XuQNTU9U6BdYgToyp/nN9eyUyvUMXj5yiNe3+4TL5UmfKd2qmLrRaR6Qi3aAeXd
LjZf+goTAM7mgVjk3lrhyJT6r7fmomc91hEYtIbgZbiIuxe2jQGYaY58NbwqT25YBtuttlsnawWQ
imRk/svldAsH2eWeYnBEi8RDrueaPEKfoQ4KH49RLdkPJMY97p5ql+td7U9uychxZAzKANmNfgQq
IPyq5uMW9cqBTygoSUzkpZN4pG7N/VXvPcOEU9Nhm56WGzz7/Zc6YgjrgygdMz+DZJg9vJtDIPHN
b0EbauMXPwOsWoZ5K3ktKx+k82KM3Zos8Q8gx6AVbcUP1qraZqc1bnqI+plB16z2eDQ+lr5Fymhi
Ja7IuwiqlKWgPypRUViqn8HhZLJ+35PiGQ8XWewj2rEetbwtYGtUbrOwcVpfE5+/T0FDs3e/VhIk
P8eAetw3QH3/J6DyV38y9hzjJAdm459aUJx00Ea8AS97WjWyWiMXiRsmYinHP0pol9hoXmdwTJEa
Dm25JI5k2pFguJPCvCn09U9OnvJM311E914vkCmbXpOdSyg32cumLrYJtvFu7gInYe02R2rgPOdq
I38qX42YbEqUBXl+EGhrP8tXWTf+bT/52Qg0rLvx/x04Tfl34NJl67Wy+nJziQLq2rV8U9GSy7tF
OLai+0hstfJ7Zc+BmnIaVac/kG0gbNMY2ZcGXaN8x7nU9rM6V5p/W3goIS3AA0c8r/NqXFQgqkRZ
jTihA3i8fzFTPp3Jc6M0/DuL9EZqM643W4jVv7UWQdG4A6fey5X/gNhJo7425kQrY22PeuHQ4SrT
dbFD9VeLtnaRXKY78WujTpJSjAYbqefhtBZdRzJ6fdFPFW7if5IeCmGo4uyiNqlUtEJWEAI97v84
wifhLeMJsuFkBA1NTjhqSYA8nKX+DqKII8C9NBdgGHvk9sA/aGlm+wAG+IeYEfUvUtX1AhHQdlm0
2WTPkFzOIrX6XiAfjXC8WpAObVhxoH7BJ+2Aq75VZ2nmp8YiA5I9f/rgd7+rijCBbaaudKdZOvK9
l95m92DJ6gcULwGYWdpRGPcICXeVWU43c5jGcMR2EAXft8CbO9veeHEphV7Xm5G2a8QD0ux9oA4I
I1R3yBdgE3PX48fUu1Dq0qQlHnRa9HNxk4CYczMft76/ngAeGKAUYYuVi5PjADaictibJvdb7yBC
shUPbBKt0jhRnl3MaXkAPFJ5iRyXT9xQjj90YBeuiqnEF4EFwagv81C2wWBs2dERHqwg6qV2JPtX
8nI1r6+4NF4ahOaTxc5cGczv90gzkh9zYMtCgKN7ZFWvLo++lEFiB1V9s56B+ImvUG0sU5Pc22bJ
/ANTCBNIKX7Ua5lBH9AowdP91OqsLYNT7CH8OATFYy7SxOg3yeOntoXEiOXUYQu98JC+UEb8crEr
vELMKObAidAk9z+OOk+V31M5TFIpCX12oD5+mit61/BL3IjmlKUs/+Dq/s06HUvQnvgux+dnMxCR
XV3uFQ1XQGn0YXDgIY8bfT8vQEJB64wIrzm51Gx4Y3VGos4wmUk0UgQV5+6+srBhsJ2WeJ6aLSEM
5Bx9zL6iWZV+3ogT7TAwV6uKkH9nGzGFA4pYNAZzyLJR36VEeHB4+V5z8RYqVe6oj81izzmbm05L
Jk3aw1wriMgmWamMn27pS7cbGYuHEKQPzsEaylpMCH/gCfiLBeYdT/UI7VXwczPcCIEt8hhBEWfW
E9Vns/+TuE5FTzBQLGYadkgxOAEIzsinOwozbcpBkcuWc7YU0E+aQ/cHgiNeSKy2RGcBelu0OVUL
isFa4yJ+QzqZu7rotqBwZt+wTjBsea7sYTsBqFynHkB3fZBKiU+Guuazueasv+iDJxh1K3ipMtSd
X0Aa/aKoI1l0fmgvmvriV+CyU4L6uRnrXrB+Nkc1Krn8VHT5tGsqWuDvm+3tGsFXZV/MSA6XjiYY
EzRhXbXJWMfvs9Qts81FL0VWiW+82AoBtR1qgkRWlY+tC9E432bKLoK8bP3p2hQ75DA7o2zSUF07
2E9BqCOe/k6F+n8BuxpHHOEKa1uzn7Zc+l5UYMHq9HTJwZuXlFbE7CPM78l03SCbswPlFwbhOQ0u
IiD4rj500z7U34ErBTY3sAi6O+9ki9Xy6tZ9UvMJ/YFlxhdllgrU5jKluobwOjM/1TXyhPbzdjaJ
qIMxhNETQL9Yx2rtRT1+sJDeuyUSWCXqLBtJ6f9LP6jqGQgjWiJ6dSa2RGTsbXkfgEPE6IE5GBkf
DA+E789WzgSiazML1qMMWPx0V67xJ7I06Na3TghvaBg2Dr+wi7XgdIaJ0ghhX3E7O2ukGwPHyWnH
14dKr8DEcsFZdi9BFQWtAVopE9GKSYFFTHokvD8y2HCbuq9z4YvPVXeOnIhiDLwhy91CSq4spqPP
VTByZQ0ie7txVdw2i3v+0e0Gdvw1KxJz2hC+ZREjviQRq1GVIY9egLbx6CgfldLBrXKRMeNPyllG
E+eVfSkA4TrHiHqLBnR8EH542OAR+75ZDyyl3CahM1ZN4dGk7SeLP1KYwYemt31Qy2fbWzhFbCCo
973S9o6HTOJzrmaSxvpFGNqzWYE1TMGBJGQ0bmUKOMxX4cSulPbqLy+VwiPrGkzSDr8DgT6dODma
iCa181bEHfPAG/yIxN4pKCLaZ3TYF4kk+M8UELN/sSLSmlHH5J4VIkQ8BLPMkimxEhN7Q266ahbi
j934ubZIFnl7qyPl+UtKJEc+w0UwZasPpr2K8mpmP0NM5IcabC6JvqFZd0ygnVE25YqVN3dyy/EN
8ikzlM1fK7gSimIgWplv6uAg/ZENfEhPAfvH5zBuLS1tMtZfXhPVF4vWBrGAFyGVEDWl4jisSzGK
nTy4EDECxiCmAGzsFLQkz9WsjeLNYXLO+I/aOXvlWMAk/pcU8GVl9Gzr595TanKQ2m85EeQcp7Qd
+ho9Xyb1YU1bBtSj4m8MFUlwLNal6s0zbIx3I4ui57ET8zuHMKPN/isCXruiNvYP72mefuIFfc/A
vwogsXxy6vAQnXzqTCFnV3to1kZF9XdTjBftJKt539x0E314O1l0KyNYewX1LLzAKQdPYBWVjVI2
Vc8qmH/a8rckCv6g12FHHQJUyF8zMByET46pWP35uB6Oa+86MrCay0m1vv+U1/ak8g8LaV9pvu1V
KkCSTIW0M8Altj8pgPyrL9PM6gWasOOOVPin3zZXK73kPiQe/o73Fh8q8fPhJ5YoONj4yB321sMY
GlTnSPvMUKtGVUgYfjqG008/y4H8ZODcpQTOnio/1Buc6B5rhF0W5EdU7jTSig1dPpITJJ99pgPO
Bhm7KTdrnlibDk5cd0MryxT96frTEG4lHiy7on2PiiYoqoLpaWPVVyrAKyKQ6MXF7srlxSYtu910
ZfGTo6c6qYzUyQ69X9+QyrNgfT8zMTViPI6Xyamv9bN2bbeYKU+sF4BbriM47ks/BiSVKFFlQ2xw
b1zneBvVpyuGrINifa0juywNxnNxuK50G9A26BJ+9uMmy06Cwj2Skaiy1iJuRAddgY967H8MQbLo
z+drHSEluavUR/CsM792cWKg9F/VObJvD2spSZZqQRyyHnzhwFn0szFT6RjOi21VlUCryWdmkfi2
gobEW+/Q6NMzlpLAWkySDkEW0ZpKqSRf6cs32YaTD2HdAyzEC5ybCKH0Why9w49PfAIpPsZOIi2s
VRXcc84nN/8Wdt6eSg41wsW97Unswh+kV0fNuS6kwNGIwnSjHy3V1pmK2/xL7J8EJAz9mvFr3/9P
ZS1LV6f3QpBNb8iCVhwwSA6DtG92QvmMbv7CWOQ5jIjoK4YBQxqx9SeUvopsJ8SzQR8LM02pVscg
bvYF4wYPQ78C1imJ5CwKSKt6ZEQHt8LkeqRmmkKfiYd16a2QyHxtdmC6svgmUMCLZYKzMcRWiq8O
2cdkxPMXqQdxaqaFYBVD+MjjT4YLNjmEh9HUcqH+z8lQmWGP6GiVTDCo9D+lARPwbm9RHqql9tN+
9HTa0Z4mvAIZi/Ra8WHbsLCGzD42kKvbA1JI9E7w+ahjioybYN1fiVQwJXlKZ5woJtgkHks7jkeQ
UnEPX5dEQn79Tn2H8LG/aOg9lidn82mZekmILfzvcBPYZb5CLnZl4qYtkuJYxsi9Id0VzSdOC/qA
/EBamQxcIos8bx56E/0ZmD8jCgz57NDD/OKmXTsUcGcaS2aA2f7lvSehasu9iZDN6kmtAyzmvdty
96an0W+8xhW5rOgND/5+ccAxCW8NA/tCXFLRboo/rZhAclhMqIV71l6wttq9MAkx3oUc0RCfnLk/
Fkv05uX4vXS3wkOde2jQ0iEcD2whQLW4VEVDrte5fs0hD/aeRIOYntaIZstghVyfTDiEk2zZX7R3
Ze6a5c/piQuklPn2/840Snn2Bvhn97UlWQ+oYfPkBOQwVK3vlY6bCUlTdllPEsjJSpaLTwxNgtzB
c4q3/LU8yrSM/geJkOMA3+J5ccUBQLMmKZDL845Uy6FmnoXFWEZu7XRcLwK2qtZVKS3mXmbT6v99
5jhohSez4oaNcqwJPA6FB38f4BZukD3apwEHdlnzVvE4dHi4EEI+b7DZnF6nkeHHcwv8GOG6i0CV
IOe1epYT3giGS6pzh0Hj0WUMHrXtU3g0CbwEeW9z3djbG/7JI6klu6/FylMKuuQVFh2WZ/yyfVo2
AI2yQZ62nqazMg8Wc1kbzywIM6GyLFvYGzpWVvETHG/DwY2d6oQh/TGATkevm0zi7vtwPjoE04M1
aTbOsTojrAyKrd5uX1fpNoEQskUXfzUpTifmZZklA8lirS0bHn5hp/bGqR09wFE+CzP4UCA72rrH
PAs0HUkZxv5cvK0OM25zNpaolka0sr0EnfjLa/A+VNOdGph4+r4qpii1sArRSuzlQR6Yi5XLblII
wWOPAvs/F6ksS+iTXpEBGPEidA4ZmVUqKKBR24PRskxQMt92SOxKD5VTlJeqhQC0dIFcTEi4RzC6
QoCb/b25XrjABHmnyFgZSJhTJIKu/pYf00d28FPrZrqdY5KRclXA2AnmHIWGopkoQ2VzZYDFX/uw
UV2XEZx++71Yyd0h3DwFDlCz2BE+KopBxU6WZcvWB51vrt1RpwhptV/8LN/ZLOlxQm45QrK/ZNEl
VvhEaxU2sgwZHenjE34ysoeSQXBiZ9ASEKS7FqW0WDshJv4R3Whk+oqP4AaUt68Bg20GG3c7L7ff
B3ebjUnGmDmu+4PftkBHswRl+dBTNC9yZuffhlzAhNX+ADVGtvnW+yCuJ2licNxynAtBrAxjtqTq
lMXTh62zwX1CxI4sc1lOrElXzIPxh9KAHN4D6Qj66XgqHIuUgHUbdBaGWZtuasdFFeQidCu2DS8N
9tTAOBNuEhXc4L5SPBJhoz4JN3qp+7dNw6QMKjDacO+sUjuq+0tWbxeIRO5mUn7afeNcxAo/cBPO
hH+ZvE1z2aKvmAXpcm+fqXaR5Ezp9zfd17AJZ9/jHl8S5kT7kZc8znTsDLo5MeNrIb00JUz0gyfc
8lLk7KMRjqAdGDR7B/8X+gYapfa/JqhHQdmdHe3CiXpk1iTWYnT/mzcopJoONT57geMrWGawz/xi
uYFeLRvpeEK/S/ihix/f7rjwBg+IUChVaDiYuKXdsBtcCUC9jD/Csx348owvxfyG6hAiiU5YrmVy
EmqQPzlj3AyrZlhdhaevXVZEmUc8NOCJV2Ia5Z4StFRI+EM6FAtSy12rBYwHqgGv4B79nuxVcPpo
r+L0Dl8TMVpUmB3He4WnvL8ahXEwtoiAnrr8RXC1QLdWkzXrLDimpXbTxd3h/DyAHBJ2ctEHCU+E
lzLPbtbgMf4uT2tAG5dhF++gFBvQsM+/jdvL/f9Lmg1NoA5KVdzOgqVIQn/qxfxJXeWk9zMWX61k
woWcOpyRZEA3NmqW0S6Eh8gSF7+Yx1HSZYGKxGi4s7Ml98qd+sQC2v0tlidXJzBOi8XJsgV8i/zE
siy18NlH4hszg58A51vfF4+YDhOet+E/HAMgMs+ZP0OXwQCvQ8gLZlrWwFyEmQU90utxVpKFt8bq
OE2rqkxAmEF9FH8XHRVN35dFSEGyPo3Tvi0CrXs9eJV8wWSKdpgLMVKkAKPcRjd3rNfsG58duFAY
R2K7Q1TDVlJ/liv4uH/H7vD7eVgQKBWh9uD0/cs71QhryFCbG+zDiSbaVQMeq6eFCc6dOKMOTppY
cN8iwSrWXnDK0PceJ2JIrcGwQiFcTNDKL8e0E0QzQz2dmno0jQKJ4YjTIqcwp8Ri6Z0NJqOEEig8
UZoTvbfvKsrk28CIhCW3j20/lGllUm7d0vaRGUZyncPzQEU9Itwhu3JdRckcrPqeZyKndi1jUxUR
8dLYQfs5VsXXy8Cqy//eHJ/2sscUDQiUsBSjHSE/azLg6psoKbv5WgD4Sd/FYf2FzuzFodjGshOf
ibTH8q0R2nqva0kTsYuMUzdDlL2UuhVupYA6bO7Sdenm7l65kpqVJ7hlW67g8eyxCHNrAKmR1pIj
1ft+2evsXL/FJCHks80g/Lm8cwmwQMRLgaAo7f3zFHJNHtLZx5KRyif3FbfIgKgi3GB+zGgsiAtD
VatWOsS6mKU60BOJLIcK7ApSk1mMfJuozvJ1lmjUtorNYdbUYNrj9KUhLGDlMnjWJiE6HoVgbJU2
y+VLTw1LuCZs9Uo+2s+A1d8KPlXXzkfzbe8vqdGk3ujhnN8GNYdG00zZQ6mcPDZ2Z1ZM6Vy7OST7
XaNbOTRqFPbBpMtWNEO8FFU/Y99rEDZt/8/8MQDV2YYSI/IMYYpXwf5uHZlo27qjRqvQKdPi8VKW
3DLfBmlZrd5SPKVLRC3coi1WTf2a4e0HAYEEidaLIFn4VX58Wq2B2rr73GVhyeZ2J4UvsoZPs9dY
P2R1Ci/jQ6w4K8mW9QaygJ5yCrQEhvCj0ixKUQweXC0Rm0ptumILwC2XfNUHBl834Q4wQJJgHv5T
5W9HT8cKFYYiatxMLXx/7eT1SBkYvb59yedKSvvQ5kZut/7n1PBoe+TaIwmAghTEcst4mnj4tSM+
Lm1OLRcKwrAbT21ktf3DfEspoe/XrwpOz5+I5jQpIfqMs+01zg5xjHf7SsrXMO/8IMTzFHOSVg0B
Xml8lD00PmF42WyFjlCElnPrG7HFBR0uPrDQAiO91kQVQyxDFA5miA6xN6dhxcnlZdpSarnK7UbM
wuIvxpy4xJsRPFiOyYpz/FCTc6aM+OnNegJIiDJQx6v2DFYoD0jhkLEP8iCNTzOPgl8WJuOQ+69G
BXBWRMUOxq2g350Rso458ugRrwwo6nd4X7HzEwI/E44FRgdQwRubOBdNvf9yyM1w39G+Hpcbh3HF
3hGXBtbgoKtUEZKiv00pKZjrnhQM4vP6umB2qId0yJ0YqFDqFj1o/lsdNp21H0O1u9WWZxYNtp6B
PqJXV5C3pGx6p0CKjXIjQF6TGsubo3dXRa42KkLQEH6igec3MT9hFvQZ/Xf/QbtsIGdvjFDxE8FJ
JXjyn7wPycrei+6WhkgB3ZiuxXMg9CTw+YK8ipD3kGn0ppIywyjokZ5amR9hlqD6HDjrlslYkwf4
HJb9Ve108Qd2lEZurYXWScgdPuej2Nz/QJ9eff+ZM0HUizZFJOXvNGZNcxnEL41GVtTPT5oBm0hz
WF3OXRHDXobTshpYQx8E9uAlPviOnwSzuf6IQNuePRhck6L09yrNQu4W+AkqXAQr+emyW3yxLAiU
yl5NpagWYBCw+RWSaSZq3+APaOVAFyWdS67YxzCY3ow/DViGhwbx3TG5sZoJ4oT5vfXRbS7IkB8R
Rro17yn97f5qnRRPALsfLB0LjmvWcmhDOUtLTYMm2M9YiGWf0qDDXR97KGg14xsgCgfEH7wCZ30i
Hf9jVMdWX0U8ZrmRStyvbHaYjR+veaiHc+IxIWkhsOI17nCMVphtz1Rn2BELA26KVmZ2vcHak2Xy
jTjLgJv8xDBn50YRuCpiJwEC6LHRpJQjkPEmlT+vL1I+bnX/anXL2bZriwn2t06wftrCgchLammn
+5WX+IaeuiHkXAlrPWgSyWigoDNFO3UVUtr1aQYyBTb9yos8AtEtMuwyahJ/Hca0viKyQaG5A1jK
MQxduIITxfEaHb6BaRuG/csbMLRiljmlEH4ngda4CKejnvMW18317STcgJEH0t8GhDVen5tqOKK2
54s9FLI74S+Nn5nFl4EhiuGEiLzThcvsoVSgd2D2l1CxZ2OM0UnDHZJIXl61NHg1jgR8Vdee4oFL
i1WJIDU0ns7/TuWHRoNcJkYTYSoRmoPrH8x9USF9xUKSyVB7+Wg5lPUfVmlEU2R4497j3p4+UNGB
57LrPO0eu1Ics+7QzdAD4Y1mtbO1LnqwTb37mfNk3NoT9cpqBsNrg1Lkx+6/14KVTEqDS3J5iRP7
NOnDu7g7oaXJGxqRacZFku0CaZWoQMsWxB9YCu+zLEYCXn7A1KoHBlAJIHu1ram+hNJaaw3Tqsuy
xoSCltv7KBpOvvizshZoSr6PpYtmyY7wmsmPKZjnL14kSvN1g4LtRwdc2gAi4AySisqEnwYGZcRo
+rbPwP2WKcCkVGzpH2yLAawq63iRPH2Esh68GchAsKmRi0akYIyDXLWSk4eKIOq0L2+VYFEjQnYW
qOK7Zg1e0Cu0/7FnHr3yk/OisBn/6A3hsAMtHd1UepNtA0LoLKIsyVt/out37sgAo1wZFaYDIIIO
AJsvxsaFuJkreWJ7VdXuRZwfV3RPhCq1jZgkwA7q3loffuPs+SlC8nr45cOSffWkbIfwgdcIl3x6
SVdlV89Y7KBTQA1Ld3y7YSkAhWHJORU277+it0Fq0yCgYv26pPqfqioTY8usLuJU4gJOYVvd+/fh
bJBJ88R5DsgSU/dzyLjvFpUuqYOaLz8VHIHGLeJWQoZtxi+SVpjco2j6yC4xU3HzJc8TRX3Ar4JJ
UygVhXAJg6ZcztWqn6cul8Mkk551lA3SCnUcVr+JArbnuXFMxlElgVOI1IQPBubqMdDdEeTIXg9q
n/Q7HxMdi3Id7UJ5mTjQ0wiEga1n2gTLXrdSYZ0b4pf4xBozVa9qU0vU8n+8YMrrFgMtPny2ow0X
7DcZ/mAMsavtl4MR2gT5d/MxkBwRnbmoPtWsxXeAagR01F8bkJkXG+HqFFXpRlvlT/n2fsJ93jiJ
b/yQfd0KoGuCcBEaGBqrX7JxsaueTpxSYBkxt9BGeBIuvcaeHhJkop7nj3+v+wK5/lq008zQarRR
2HgJz5FUrwGN/wX3uExsCZwCW/LLD/CFbMjufjwwzBtJ6pOvLkTw9FXfcxakbsjWf+pMBuZ6FNsU
hBluOsjm7bYzM0119QEqfW7R9UKepTRRuKxlEQ/u1I0Ve6p2SSkQ8VgrBLugK3OMoVxAmMDWSwin
tE5OwoDw++4tjOh7HYCNOnzUOSYgTk1Jlj6M6EsDr6P4AaxQsL9q7QqMgfVDEQ+nBllJ9+7TRjkG
aQ7yj6SDADZ9DCPMfNjl13zHzjfbmqkTQeQ8qSQe6jYfNgETX2xs+d7ndL2+Vgu4K8xyeaSh8WdD
FRVhmes58tZAmU4PiFK9cIQoYaI0Z0OE0ZCllrgqTRlcEPgytUEHvPJPi32rMNwKyVhKCJwDykyM
3opMfmK48TUQsZDt7InsHNAb++8FDCJ2HFTOPgM1EcT1Wru3Fo415EVcmGBaXB7k3MmVqEAq9YvV
qu53D89mRFCN83joyO8CrG25sW634DDDdwVuIwXyTqT0QzrGUh/f+pZRNKF7Ce4wQthulzmnb5n5
8q6+kIajICVmkpq7kQa7+pyuZ+tRGLlx1K4sqZmriBSrIKVu1KPescW8+vfX9csz3h4RKgv6ToFX
7U5/QU3Dd54hCwU3ofytqxtDtOKwcsG6Hr65rlv9HwyX9K5btnyzIGqgxWZ3nsy70243gqJus0Df
lPYOXQbqRCa+JucOlo3GB8op3zycEf0nTvb1T0sb9J275GQUsqvlNTTAAeU9q5EsDpGyOOH9bd/E
jM4irZ+d/9NZJX7BMIBvKvkTBW+vzyuaUjB78rgclrUnbIYWnHrQW4zzpwJU0fKE4jcMrWI5RU+n
FosMgSXdTMF2LxpkbYUItKEJqHC0vIBSVaZkVsT5wh6aHacfEVF8hU7Icq7BKf8STYKYzlGgvCwF
MiKyBY7e5tIG+w3VGvpV7bODd0C6TbTX+MSW8d4w/v68PcR+1hireW6oT1vIHzU1BDAD8DWSUuSK
wsX+FDSh1DZL989tUEXjsQWdWuusStYvdb3MDD5P7nda6xANx0umPbnMxKPTGLVvzx4i+FGnMjmQ
1m8ORlEM0bwmB/z7aihzvWzcag4/BHQk0imynH+ohgymAtMrUPlDEbX8QvRvtbdvTkh5EAGMhhlc
lacy3PcNdBch0BeJYoqPxLoTs57PzMW3Z8FqNowQp9X/Jl7hvfqtiLxvar9TOPgHSkIrF0kXitW+
Z9xm5dCa7TOw+wejiyzQnexL/bdq+5VupCMlB4u0Ya/w3NJYgvjkdyPkUr9QNUn5Mcg/Nuaif/ne
sG+KzoeCHPKQKaLBD4YMX6xPz8qtCi535T3K1H8tg19KLzxpjQlxaRq9wpqqoCetr8oLT9obP45I
s/iR6S440GAGPs2fEsiZ0QP4eF86c2Mq2yTpxdBpEDzSPDUUBku0m7GYuqBuVW77PoOyZgvRRCAs
aOANvzuPEzIU0lWb3H4za+T8TuQHm4ObLEgD6UNnWbtuNKCt8nLUqb+f4o9EhO9r3Nwfr3lAj3PV
djpuCyo9ODai9Hk79G/TBz9fyAxQbL8R83VWdJe8iB8epnBpt8e86byYPHW01lYmHukA6clDpkEc
EYfRunAEKJtuT/LHbdzc4Ka5GtNoURb3xn8l7YdweWFHAzEGKe6y5pNidN71ovTwixpqitoyII1T
SwDe22d15ncWDzev7CUTORIWTQgBo3hT0xAO2+txG0edTmJaV8UpCRbOK6+jOqGgT7vw5OfhYPWd
BKKp11z8CZ0IGheK6IXKcN5nZLy4Z0ZPEhsJZuVtk2cPt+27kn7FGqAdpbLFvjtXm+Ts+ht7UnFo
CFp2qPzb6B6TWQOMa5upBkFiMYqJ8KOgP2UUWWZxBHmcZWmyN0UG/jMFUBAcUnSycqTmMjAQ3dOF
uULr5LttjvGUQxsuz8a1e4tYRjXsz4Y6e8RCPwR5jClSbTrk2n7TpaU8EIH6FzjJj9eFBFEmqXdH
MFLaHcpaPyKlih36cSAt9SythGIcatRKKj81jpASPFGyyhj2jUQlWjMbbs6J4IRkTsajkdW81N2m
wcuaYp9rqny3OxBa5p9Lnxos7tXtBcY7+HveNVz07a3UnEGFi4dJS096w52HwN5VFSF6/cKJeyXw
456y1aOxa+l1PG/6zajmVeE0H/fCqMgWuVNcR+Z1G0FVBoH5jviTOoQmFY5d1yhAJIr4lw779s8M
5KCJcnGxaJrC0cm7PS9tGlJ/KHJpdV/A2GWDRPQpDYFHystXPVQSDXq4fzO/vTaloBi2HviL6fH4
qoeaLojdCBJDV1ExMpT/g5LtY9u95BVNIFjGbx8RY7L3p+uXJ3gGFq/usESEd+OFsMndkm3sbOIn
L4R5M+QtjB+WrJTWxRxSyxx9fHmQOZctXJSetYXf827VP39OPO6VDYgvk0TYWsdQM/Y9opz/dfeg
omgo7BnnLNRzEWAl3ZsQKwkKiWxR8GCb68SQPXhzcSJDnB9dDT+vnS7znDZqOXlrVDk6SiaxTb35
lgVq+xeh8kdq21oneqO5vGwfYQBVuCP17j7jO98jG7H0pPO10yW29XHU8S6HDgOZpiZAZF87RUgO
rCIvZURd1EiYjMWGP8D2l/oh/g5BWrusKvLBkRmFHoTmhPnQnjUpvbun1cd2Puy3T80UyCvfWlGH
U2GqYn8/KcxTmQ7lPd22n62DAbroH6y+jWm8I76KI5z7VietGAo7x7nCtx3BL75tgmoCvdoJKpgR
bd4nnLqTzgL1Sty2fQgYD0/dlqwwFHdXfX8zOVZ+9qQhCw3qIiqoUkIvroW1VUdpYXcPa4m1gx53
3BWYn8fRd/t2G65CrDetcNWO0EFbc0/glCO4UZzPgnELgzxTo0yyC8xjkLhjGZ+0aZxJwUbyNhJt
WXX847+9KgjysHpg4OCVArjYA5mCHySfBtg3GFOEccbQgGrZYB2dI13HrQXY8ZTH/647MqMbYEqo
gPt9RuBQ0CvKItSU/e0rbIA30DLXHMu+YewwK09GyJGZF8p/CS33ypqih6OaVTxDvvnczGz5VMhT
J4BNlvKCcQn2QtrnnN9hMG+PW57z7hLgItSMyYlsqhzOdHJ2It2SuGq+aFVWhpTC+JgFI/nyqgvh
U5sUUfBsFmUTAjaQ4LmcF9csmMYAm5wfSrnBTHVXlxAmP8lJJ1mS6bqVKv4Ukgr9ySRwlhUwnpz9
GLPqYpAwPrzRAGETlMUgWmEiLEXDx2Mrgv5dEFmGeYY3p/y0zPIVTTX4W6rqqi0JtBOLrsYgu3MM
HsaRzuIllvD+TJImRX+B7eKcC5ol7PB3C/I+ezgEscx8U09+nSSYqxvWyLJBfjA3oPlXfMrgcZsu
ugXsBLUwOSkPZOJRtvVQ39e8PKqG/fhSYoGuy2gZ9mJMYDDO2xLetBkCHTmL9OkJl9t0mbVRNvcM
SDKXtWq06sS5oPTPbxPacisMHNZ4YkVhDdLBSmkWrlWckO6ygAZmzT3T89NMlEKUqxmRUZoF1dm6
KDQDvysSAXzSn9oPKfSJHECFtCQRtCJ5ZS+c7SiNFKH5pOFbn4U8tr0/wPl9OBR+7x2Nv3+BLB4c
fAaymInT4KdbYI6pZqqKfKrMtLcuUOn/gPWwQKkoSIWlpiatWDDDbZfCx8VXCkpCdDLpM8h13JxS
xt1uFMFvjVx2i6rJ6xz6DCfm2q9HtVtC+1Z5ygYa8fkmkaOpr7XDP+NTyRJqPGJpHoXw3otDj42d
89HinKTpm+2Q0vToQfglnEs1ng87S2stoXsroe1pKISxV0brIM92HDvnHEJB9zs+gkiwMMLmeplR
vt5UBiQKCEv8qSAsOFgT68rNlstfPsTlhUpJY1uleWYYgz2JDvDqmXyfB2HqWCIRqKSo3DDDTDIP
TN2EWObxuJ453i15J6ME8zPegrpMWY+kCZvwGnZXXFVLuFCs4TkXocXqUhYdKCY+dOvWH9M0OON3
Bcgha0T9K9qktK6HMH0j4DYvG7fgAJzTDUNjwzBRO+ldppYc61aazQZiR0Xo+x2n4E3w/kNZoXAv
EV/LL+QisLPm0mDH7UNhv/P8+z9lmvYuyJJbzrIgl461CAaBifoEhTh2NoEbqijF1w8r83tSriLf
PFuH/bxLsRdszfF8aRPzpuOhwVBoSzldSq9xGLuzpuO5DF60o8lBiweV6juG2pqxnZ4614up3k7T
ufKbQubgFpoTraxjhmdiQieLc9TXB0CQCRF9a56H4JYiUSveHVjBbCs0Jo3npPh4Pcj6MsmVLIjC
9uZ6M1aVH/iUTcfcV1g6aprUBLCxokQCYIZQ18pvVhg9Lip0spvAPMpzbe1xCdMFcrT/sY3ZG7F4
Hu8eEvC8SFRp1UlLFFz3GAYC5WpZDYVTQjEz9XAmvvLvCHrBTgftSTmRnecuzV2eaL9Y3JDpmSLF
j9U8/EM4z0Ww8dB+IA2aX6bkUyNKqk0P/7b0CGJ3EH07ZZbD8vyXX5gibHCsV8ZIa8SSzMseYKF7
tPjsNmku0vTfqB2hMTGDG+0hyXnD2tLEEOe83fAmmykfp5ukseJED+MLsh3BS3lOdOQj3nC0JhQH
DABFd7EZ/yhVIWFNHkIqv6EwzuYm1pgvz3/pDHXXrfyF0OpLcXikAv65L2oYfK5ct+ETRrqLHqTj
okTqgh8gKQp2fF6+sBTjwRsW9X+o1+1NRDcoOlgX9k4F/eq6UWS4IOG8+yssE37jJLAcKWr1Elgn
IA3YdteIKQyy7WkImkNmH86xp+2y3CyC86B6zrOnXj4NR/sHEVgNG2wDQYmk/VLG5sTRXKKfSq0h
Wdnq0EiWOtx2uvFxfDvPvGLiNwzbKvlU9Xn+Syl7gE08MQAcznbz9WoukmZylkH+xV2j2zvOay/U
ElHUWKSOWGvuCDLjJ9FvJNfam+aW3U9R4Bmbvh9DYQB6pq8pqHBwYPaFi1qL3thCQtIe3RC1alCe
YDKWydw+4uzlk2O0CpdqM93xUcbrlN3790uOkP558KvAKpl6Ck5pH/wsSbef7x69VpcQyvuJGW11
ejUmDoprtg8deal9E8yFvedYNhKwCuD01tm+4qsg/OGmN6pgrTo7Otvb8mgD0HdIOu7qxS8etvs2
UQ/ZIz6qmoskQxOGd1gmiNjKGL7b+NVHge24/wC1leVLRON5+wIHoibkQyNv+IIiIdvJ7YkNNzrT
RHrzS6/fhKz0iOQ6H0Ad7JzLD0nkEkdd/46VdNu+YpQKdi5nylbwK7XYd7JlUU2GbXEoiiX/HPDR
gbwqr+zcVQ5X6fnQqr02FUTdPGA4GVFgcdVmuUXaZKLpxxVBY56hc/WB9X7W00dmWhnNxYbGkkpg
gjrqfSYoL1bEYYt3vv2wXsIbtm4M0rFb0vZV+j6sDlPqe2uFA5U6QniYNvkOVh2q0iGxa+33oiZ8
qKKpJWx90ntjMqZ74ELIvKymJ2Wq0/di1ILBgBtiafJfB66bRl/ChZ3KK3p/Sx9mXwmPtNkqRNfH
TyIV1TtJejqYYS8AZHvV84z77MWCkAr01jgR4GOAldrBGmq32fDQRXwjwT8IIuZXicA0hnjiBSt2
n3UCoUfxMhZuTlUrZjJ+smKnnmYnqp9qRQ6Pa1EEzKfe4wdFB1UQILEJoBbgdYup0d/c5EfDFt4O
0WC8GcoPo3PwbBPqsVBdY5HV79BHGr2JM72RcHN+iF99sRicxFTftaek0MXjbzijZQNVDFdLvRHc
6KlUpQE+zsbdUEBiFUyZ39ymldMklRgt6ZQMEHeBnHZquLisL62g8kFPz1WiuxxeO4YL7BPWfpka
HN0B/mkQuSi6QsUMDF8FRKDb+N4RlOw4ZnKxDfTTI7jBoAcHJu+tXtZDcDAWqgP4f9JV8Cduf5uV
V23GdslbPlDKWiWWnG5AJS0ot9wmJDK986p4nceB2xxwh5OIcH+AQovykDWdVKvK0qLjQnUBBzJ/
hx+YKLeQyU9McZDMOkDgI+R8/X/+cI9wH8uA2Xf6GqkmWAif7r+lF5P/HCKGN9NJVJ+BtG70h4v0
snjSd03bNKYC/F9eKER5f1iTjoSeXsg0vKMroro9EBsD5b7T63jTF/MRoRfoUfNI3JWgPzwkES6S
EBwZi3X8af6iSHhDnKwmXfLOCQjx7VdZeAXSAA152lGrzwnM6giPd42cuGLTaWtTT4C4cqwzDnD2
XrVHaP7b9gAgxA10XFMxoSQCtN/R7J0MV7x0xfZf3z7Br3JUujbLV2iTZoHscCEDrpihWiJ3Gr2m
mdHk+FNGRKumqPX0bNc+x6Gb1huZAaIGN9ZpAKHQrJOu1pM+7B9jJm5u/ttbgZyfHfB/IEQbDZyI
1rDlFoEFkza5gkGXkKDftZHm75m0jzYvO6SkF380cPz/dVuvyNMI3ILnDn0/6p2Micoq5j4IXZBf
PIGyZWa/IYWskJr2+xh8WFxuvRV5d6Uq9HsmfcHItJc8fLoou8TJnCaZcUho0tCNensHsy4RWuIa
x91UxpMCYZRgHD1L5BH0DTIjkdJlVVI3EpwYWaC2xdlvydJxLcObBYq0iJa/yNo2GoEwWc0uH5EW
UsZyAKMGFwSGlV+5t6afmRpKLhDq9PNcsP5+EGhWYPSgVq8fjBVJwirMdUGIl0xh2Uug3ImN15wU
yfmWjL64Bqe/C0TaPbVM0EnGxFkXGAcXQraI85miftkSnIfFzJod9zcoVCDGrgPO0FlSdgzeHIte
boVUi7PTBTOW0Y59Rs0mtmyR99/IWrvNklFY040MWSl08V/cBGZFQfnF2a7lPnF05Rn4XgdVY3Gb
tX6ypi6V6/9AhS3/UfU2n3zJSwOJb3E+Ufk83fYO24zfHCnJ/bhCxJDI5g7zvue3kPJh88zZBCzA
XUApZc2XcVwtZsq2KPBNCvBMPa1nWmw2WfTQCN/yBFypjU8Ctt4Hu7tKT0ghoCCm/eT9QD92UNhm
Pn1FUpahfHkrZ+/s+1MG56yPXfmbe/tNSl8N/Up69ErrVesUMs5VW2QWJLLcziD1u2jnOq5xmcHH
X1Hq7EzDGV8T8XDMNCCYLo2f3viAo+Up0SJaOdA+DY0jFlu23mTHKOjaTVo28dJWzr1R7YnF4vQo
i32ejKw968homoIuLDyY60sRFEoj7+Qmv3iWHgPeLpbyRUW4Lj+rXre00vP3SJBNNnlo8p2q0TX0
NPS+WKMcWldt70GlEAaLUwpBv0bT6tFXNtuYxgXLy1EdLVCnV7gYLvbHiS6DVB5hJV5N59cORe+l
b/C4Qjv6CTdDtuFN1kLb+vYlgS70xlUvLFojxNUgq8w9GA3+AqPgNSbYHPeUx7N/4ywC9TFta6wG
CeAYyvhOuSihdT2Q4fsUQYDZvZ5X7p9LZCR4VyDn/S+QqjRl9ecYHob0iHUWZ6+m4oPPepS6SUOo
2ubzv9SLSmDJWJ7q1DjMQoaHuKRosTKCWY+jHrMfBuYMgJDEyiQ9QDbDRfgeAWK09nflgvTLT/Ag
PZ3Q8x6Dh/zPjz2LaIpPchUw6Ppnv3lTuCRhhaLkW0cni8pTvOGm1BfkR9JzwVLpxw4PwnI+MNvd
d6ANkhBcQif4nj/eKrAnt8QAz6NKrcTgAfg5uU6efcI2HHdul3A/s3zfPZ3PrYuG96hT0/CZZkVk
rq2dFVIjEzukEGHEZEr9cOPynqJjLvnyTapIwkk+WM8l+YL2alr7oydIRVZ5NCPVoLHaXaIxotJi
IuiIdA1y8OFlahC9b/LKjiaFUldvV12CzZNBFEvOjO4fC1lBP+kMR6OvAgZMeW/kK/Drnj0axNgC
XQ8GD9QQ7iFbmrt2UnQwV8CG8B0ABZj5eOpJNjZJuqEhoYxPuaE0RAyUKgA7968FaaQg2dr6p9Rq
cHY6mfTHFAVqSZ9kueyEAwh/blVCjl8ZuZe26qMyeUk4/6Sh+1434XmIRdm5rMopOgUBpnm8pvBW
8cR0T71R4Humb7ECJBJ1ANlEeDTjv0heX7CH9lNYcRRKfmCjn23JKJL130qsJFwqvFLlmoIKCPVp
gg3GLLy1IR0tU9NSUbEmk3+LVR/l+ON2xzJAVyZlQbwDv9lkH/YUhUpOJf1Fr+cbt+2EqH2l+bB/
kJL0o17ilsz7i5RELI4Mo4H+LCRgq45tgQ8vXWTumcdqrVWxmEZIohOaI+ap3ZYLI0mZMTZN0dXu
TFL9w07AC+gQGSiXWg++9sU3yKvTBTlOUQWu9xULlKKLzRGyHg28ikTY2033xRg598JWYWZ53Tjm
flPw/fuVK72pjQyxUtRcNs2Wv6fVaoD+F6XqKDxezXKERc5Agfuhd4GjbQ4UHc4J/5t7Wyo8qizV
dplrsPwT8085X7eQGYjLiZbbVnJ+XtjkQ+GwPFMRkg6++Jfijldd++FE8efG4F//ZvE0Sa0xenXg
M2uOspizGQobpHF+o+/2rliZR6ZCEK6t/RQUomGsgYa3wP5r4V9njyRoykuVuBi2yIC42v328Tfi
9AfDflhS8qe17xo/yZWk7fbMxvtaiMcli4Qup9TneSeFwlqbncm4Ah/bUgbzYw==
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
