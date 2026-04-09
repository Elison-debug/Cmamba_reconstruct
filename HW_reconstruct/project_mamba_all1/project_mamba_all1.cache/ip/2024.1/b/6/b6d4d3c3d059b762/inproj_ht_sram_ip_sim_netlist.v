// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Wed Apr  8 02:26:51 2026
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 52464)
`pragma protect data_block
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
F22DC69NWb+zf9xr6EN9fwPwjFJFTXwJ
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
