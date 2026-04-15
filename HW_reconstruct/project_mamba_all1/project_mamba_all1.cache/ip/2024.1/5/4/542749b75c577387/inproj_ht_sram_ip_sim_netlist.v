// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Tue Apr 14 02:32:38 2026
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_8 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 52496)
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
