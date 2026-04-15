// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Tue Apr 14 02:32:22 2026
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
  (* C_USE_DEFAULT_DATA = "1" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "64" *) 
  (* C_WRITE_DEPTH_B = "64" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
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
