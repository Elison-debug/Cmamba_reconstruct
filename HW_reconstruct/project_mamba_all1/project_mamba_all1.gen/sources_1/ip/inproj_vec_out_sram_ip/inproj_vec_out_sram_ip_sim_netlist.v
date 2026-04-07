// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Fri Apr  3 02:55:22 2026
// Host        : 13600kf running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               e:/course/master/mamba/Cmamba_reconstruct/HW_reconstruct/project_mamba_all1/project_mamba_all1.gen/sources_1/ip/inproj_vec_out_sram_ip/inproj_vec_out_sram_ip_sim_netlist.v
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 52096)
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
