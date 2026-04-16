// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Thu Apr 16 07:38:00 2026
// Host        : 13600kf running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ inproj_ht_sram_ip_sim_netlist.v
// Design      : inproj_ht_sram_ip
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "inproj_ht_sram_ip,blk_mem_gen_v8_4_8,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_8 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 52064)
`pragma protect data_block
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
in8odrTjgJ759SHHEMC77K6TMXuNtEI=
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
