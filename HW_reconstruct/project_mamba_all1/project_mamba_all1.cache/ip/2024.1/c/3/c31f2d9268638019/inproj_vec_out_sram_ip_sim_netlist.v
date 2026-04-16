// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Thu Apr 16 06:38:26 2026
// Host        : 13600kf running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ inproj_vec_out_sram_ip_sim_netlist.v
// Design      : inproj_vec_out_sram_ip
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "inproj_vec_out_sram_ip,blk_mem_gen_v8_4_8,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *) 
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 52128)
`pragma protect data_block
zcFTaqNft2xqdh0mn6jlwWSCR62QNzus9W/HTJsG2o2LdWVceP86tozMNeejmyfrF4F/fXEZ/1T/
kqOr3Lag7gfrTWNLNpTW6mR6k/v3VD4iSGKjuzCELKfpccEMeI7AdnMhTI1Q6cJjnm+9QL1Q7Gtv
AHCWFJAUtB2Ig7GXsliSKjMPnpazQbpxVMsknrD4pqXu7pSaw5FoLa0CeWLtLSXJ+fVkB+5BBGv0
0iBt022CPIThUFyAHAJt4uItQV+F85VH4OjR1INkDMw4Y63DV5rnGEwlUvH1NfjgF4/52YFPAdKx
oj+A0hF4YMl2qpkoFq4ZD0v3qUoqkutW9D0NTprTels7Ics5Yp13IPLW9dSBhT8VqsvRJUczmtcw
jY/qIYcYD/oXca6Fc3WNxzHlaAXBipoJC63voPwPAnrEGvVsRctMPn8RieJsU83uFudocLeBJPYh
Zn4/zfiVgOgxdELgFZ/09bFnPFFD6iNlziLDnnD+iBLtE8kEMKRS22X34yCJg12Ili+L8oiDPJrT
bLXEH4KV0MRFlmnojQ6CeCMmIFb0Ooj5iuz3ZIUmItrQPDHWvmfvcLsAj7M1XMzuia++dueK0ch4
AnpvswKweV6fubRVHZLIwkeWDVfGPCd5DoWpWVAwiYlC2xykS7+noi7ESLpqDF1pzYrjt08n1vbm
B8BbndFc0QpIUwmidIQF0yDpjDGsgyvo4PSycJvRd7xiuVF6dR1D+7jD5UOOuyAL8BoAlC5IVQso
++4YAuxp4Oj92BpPLNYvHo9BfV/w8Q0Ne8pUuVC3MvNS0PhcSqyuj39CKpqnq1D9PVYGGRYI1l0I
HEVqCyXQjxpk45Hdzx/LzDBoPn5aRqWt94Vec5rYk6wesLIwkoY7tI2Px1det+y8EcBZncsTFjjr
1XDtAGcSCHN/DH8u9IDMwe7H7F7BAwA4BEZBfsjG+bFmHX0sqCCH0tUwnBeCCvIWsaUY4kUiA7Ow
bSknFwI8NCNjQCwl75Oxw4OCCTMC3qNWqwrbH3BSAn38IS8kQrkJtFTOjfZlcZuVHn5ehwVVN71R
IwpYOb0jf0k9OwvD2rfUI9O1mNNccfJyrrsxu+/RUjTO1FDpG4fZTxyQ8ogmRrnlxu1Zv2+pSruW
yqoU+pYrbMOV3MLchO7+VgzJUoTRtUHU8JV8tHQNXxmSXGmHsWuVP3U5+heP2Y4iOM3fm8WLEvwG
T7KAqhkVlVIiMmti892NYWKSS5EiHFPeB4KV0lvQpH6dS5mhNxxF0s0ZnkiheGjTj1NnnLDxhJX2
Kjsm3sCJFt7+Nb2z48R3euxrGvtCXEGKEH7bokRMNBVQoyGTo7JiFTQ1VXCVM/ZLYOP63UsC8Tif
AoI/3HrYYIa73xChshB4pRTIMUfRtdpe7xrLE8DQT+YQvpsbs6Ang8eLO4DfTZz04b6GdZI2i1Pj
SVeujK2VFeT5dc2vIPb0pfR+UM/SGb5Lv6mM50LQrssatfldjpmXzMCUfVnIxZzTMjBl2R3rHwfq
azICN9VIysTeFxM/0bbGSp3yvyLqauzTY+oEUBYhgJFW7631Jsrn1tXG45GDiNdm432LOIraXmqz
MAEmG6bz6J1VyfvyKGu1slx8t4OA+IqfP8rupMa55aiEwDml73U9tW5aJxEwjrW3T55mK69KiYFr
rl2Uyh0ZWb2Wq1LE+0supLO66c4r+u4d2NbHiXoIbpdTgLFz4ZSxItH4yjBp8dZoV9cGRdQ+RKJ5
JjEZVTairI0qJqwa+IMF9YsODOcsR6Tdxv/AkY6toJvHi5J6vSeGSTARytfJeDxgJwFdg+mAH47m
FMi2M+OqaPiLV36jKZVVM210nnmsfz7hM3wg+3Msx9Pd714D0Wbq4vODucTPSt1/z0lEW3AZzmNg
d6FUtuMtop6lHV7hgfZxCEszyy5u0aPIWvLxJhkfYQ5L+M29ZBTAbMfedDKQk9LoF1VlA6vvCXPy
Oi3jiVv1F94fgqhQtNOEPN5I7jjglKH+5vCE/e+dlUBZF3lfQSsw/yvGAMwVHpBGxZRbLAeojNsE
vjAwtk4Tvy5qCos3IkUM50dGY0T3M9RrXr5E32LjoNLXlo5oWc5O3uj/qRxG8bHkXFWMy8Efz3Xo
wXW+ro4YOJNPdFvZmCmh34ajBwX27JO+6bKFaA4G4LrYpB5urRxyhbeEEwKl64gryDVoFKLKXdrM
tkXGJjMBtkWPIdbmjuJz//rnhEdJKvZGlXK9zRmtNXm3x0OFab7+3WXuSqURH3hHKlZO7V4vF02N
Q3jqVL4O+M5+XzlynhnzVIRMyKfXfpxFUpYRoVA5xbzQgR2cB/dRG94v3cPLD2JZ8kwLbouAGLkN
4Km2d2q9wfPCfVH20mBFTGkKOhlPugyxf5hbeSplJ7ZT3lvoi7oh56ibIVIRAc+8O/h8lfLx/qcQ
hXZ9VtnAza4+9Obm3sDdVSBpljezXpX+sB+ZCdxI2Xg9VHp+K2pDx23OTYjT9bgYVSdWJyIDdSXW
1+HxQOZ7eFGaJsDb+0jaEmMw7YtDMPAfn5X+XyghTL8eMkbxVQsh1naETSYmwjy0Ikh2PiLzV1je
7OjrsUqQU6fIZlRLtIA1eh1Uyd9BUM//ph+fC0T7OUiGHTj1GMhIlqU33XuDwrDDnpZYOeAidCl5
UITPdn1NLxJMpfcZ49WBurUE+nx5cBBnraKYonhY4Y29Ra3mfNK+bs712ji3jddpsVurWQAitumh
3ZjefVUxCtswG2m4uiqy/MMCFG0K1hzSKSACZmA+nJvUvQ4ERHkG4rMaqQGts8k75/6rebeP/yLT
OLec6qNHf6higK7Ud262IjEx+TLiZgJrqVBboWiWQw37fyBOGD/Z3QV8B61rmpwSkMutUXJ+m6Fz
B8YwuV6YiARTB/BrGE1aOfKbmBP2LA9WXYDpu8guvQ+JhM83RR0Mqfk05u9BR13Fl9lXFubgGxXl
2OR+vtBtJkvTcjFLiENu0NHfvs0go51KZdIjanDF5i0N5JOd70T1604FCd3idVCyMj+R+KSEys35
NdxAQ2CNM/bcHZlX3kfXotIGrnPDAM8yRSGJFDauItPA+JkETWmI//WGX/VoqykEj2lr/nlU3oXc
H01zNDXq17cUWa9xPvpA2L7GCW+htHzLyeiZ10nl6JKpfHjI5oBE0dq9KXxtzKCtXCAwGPEoD1/0
VJ6MaDuHKuyEcOzK19PDBBUsoHexIo5jY3TiTc8Bvrb5deaP2o2VBzpG6hzj4rBYLZ7KHEir9YMH
gGVPV3Qb8xObZitUNSH/J9jj0jMZchlztepVs5mv9QSKL19Qti2fdWQg5YycE1GeS66Rgmns34Pp
3NxXP0uXoNGjHyygZ0s3WK5R386womlk6HgmvUSNNxzx7fKgPHYV3PkdEkxYyod97VzONl4Y8dnt
aSOAcpEp4xmGan72nfnZVvCk1BZQpxehM9799kKcThZ/CR01l4glW2aP7QhbCmR2ziiVeLeUBTNQ
DFOOr1l49AX+/qVcslZ29ONBPfBjqUcqzNdEHgSgzTSM7zgJpgZ+pgUPEmib9TIW5W8hmW4tyuWl
a5JZPbW81PK7Ky0lyltKWs1jh5L8hOPbgq8RhlFpmyGMQcZJYA288CVw5aBiLC/orOgCcMiq1n2i
BRC3Wt9ZubPGsTpYlP7O2m6BW+OazRZoY9KjxAuRLxRl1Ms50zmkXY7MtsI+1YeJ1nUj304WU7eI
B2jUNBZP3lrq4e7QGen0z5lHu7ihBFg8unjYwhi+ENtozvzDPNom/cU4EjBCwiWCpP4dswDg5pwU
J/OBJIWbpMgePNAJoyFltv56+Jk5q5tsTTddYXPZvCD7ZXZOrWWHdZCNoXJaQdypllJT/Z0eOqjy
NdqbJMWQe7+jQQDovWySF0C9+ikKHfoszDmAcSN/vJYCerXyiZcUvmretm6UlMRP99Mc0pbXSbMO
xIhXn+kDPKeVN+pEwS+JtQHvYnU3rCHoAm+SGX1hTK7Mco7SZlwEcGABvJrXRzsbigw2z+aq+Fze
TxAgBq88Jxzh7dUAQ9g9La8HXN0QBCqigxW/NhnEUPi7eK2M9rHPJSF4lNZ0cyudRBxFT5SmwOXN
uDeaOLH7OVX/BgLM+Pn6zePQpwXLOrY6wAHtxheQOVTmPmZjxl3u5xgzOMxDep0Njqj7eO/yhNyM
ZVLWu+1Z4VymHsrNp8enUp2XsuxiyTKkfV2NSkmtuHyIvCtkH2gGREJoNK2qvt/XfBMqqfd7WJEc
LUpIJzk1kDaQodC3dZuZ4mCC+xBgqGfiZpkTDVgSm4Arl2FCa7Z7rxaJtF5JJLPcb4AH/4+C0yDw
QgqkoCdoW3B860A0Vk4llv5vTet3fSNiM1+ShSFbuLQzCr0tghpTy9TTh1bEnWEWaEtIUIs5Ex8M
zu3dQMZ++PFvdHQ4PHyFAity2qRNGwrBUhQ9lM0J333+MGLYpDureKT0w5pCddkLKqP7r+UmZIZ1
V0tob8DwHlmvDMSQ+wFgigCvHHvAwDxlsK5wS/JnqAhmQA8NZ2QcWtJ+V/sFZrZGKTzXRPmWQOt0
r244JbQcEYajTB2OH9yP2/PlPjQ+xiqjWPB6eY2rjyX3rIzldy+o7XyLV3m/U/8ydgUuJLpeVmta
zU3/8fpPj19v0IoKKdpRTTCZgl9Z2NAPuLijELQ7zfQAuLGYLbuLUVn92mBJwOUA+fuzGIVig+X3
FA0iMKYNrf2hBxa7NZA+AvaTpIy25josM6jPOG2gH2FGk9npiWpstKdQ70nrLNvsKS/4h11JxaKH
HH/9XvKlLzjYp6g7a4KRWIvQURb3x0p0lWObtIGX/7ixdqXSWK5ZUK/ivaEpizQcXwieEbOZY/G0
NmU/uE278QbZkIpZwK3kPfF8OFH+SEGy9FT4UsJuS7F9u4boh/X9vumhIoSEm/YQg62MTAIuzRp5
A7k4vXWP3qowqKVFwDovg3BRdMclJWb9fZq9T5EIMPe2xPBniStGe4p+Dw69L8hS2Pm1yR45xJnW
RKfdW5cB8Sa9z3GDK+fZ6mKXj/BEqTihcL+lrXbIVefVBf9dO0EsHm2q++2Y3mL4asnr+oPqqzYX
fGXz1HGhC7Nbkk9SA54QM11ZlTQdbpD16Labfjl1cOCwgCy5QJ+OpyQTpXIoksorJVGsdzuc+H3e
nzC3EkBMoUsEzyydXBDGcIiCHwAnZMgyFR/ZcBLyxKqBQENPQI73ZmmfxuS41bci2hbKQlGAtWED
7bAIlHQZWpMc/9ZQbug26AQFLe2ejJfg9QdLL1yDLtz6icBPuFU+tJf6b3DlAoaBUYmEBod93JPR
34nIQOLV5b9tZj9A/nnSFYOj2EEFCeBhdDIzHvxaWqU2fEMutgbqAYQ1CnobdFNeokqQsXBQ1QHZ
3xWApFBxBgoG+CWLyynYd/5Q+eIbxeMJENElf4EUjBBig6ZcIm5l4ByUtkuumY5litozQ3oCUOv1
QQYo0+2x49pNyn5dRHS8w2487mQXeL6G66IoWFvtQYeBxPCiMhBfhbXnkENE+pxTBwfAZWcQ0+Hr
WoGzeQTLU7dHR7uWDEItFxDIm5EX2FpmoG20O8qegLl/ZjPk7a1hKTACAzzFBdYHd26Q2c1KrMxR
vBvTOqSOaXvM5h4qdvULUl+7KYtWfnUXgbvlIYbdmuwyI1ypgkwFDbtcXB0H0MjlkFeQFBlpZ8DR
7Z8Ts7QYK8Y1+QfNHsg00Sj/PoMz50R9SwKQQQNbxgpxMbqBTbW4QX3WorcDXvwtGsUNGcsoBNAH
3PCghVBVbD4jYXiyIZWBC0QVYtJOdan62+KGYjdcBwvZTknIcV+s61oBu4L+XsaWSVVuZlpzbtfg
/z+xC46x4Jo2ZYslZ5v62cfEa/82qLexd0Ow2J/OBFzPp2q3XNhAdoUNiPV7dRBbLffd8RA5U/r2
v+OPzgo0SV4MYdsuhn8+SOaDnyLLmU5ikxlSyBNiHtbxYFK+hsMBBLSFB7u69RikaDIJacG41XJX
mvjvLDp7+CRowsOd9fbMVbc0j4XbdMYNB1WA6g7ViImo+cKai5RWrUxOIiMay8iV7TBwBV6sFGhS
QRTODTwiYnIfxSQteqR2urOobiZNDn0cW58uMMDyRwep+kFXwL9XTVUM/eq1B+GaeeR1dAs2BV+E
LLOM8VdomCWtddxWT8OevSRccH4dF3DH9zwoXS5ybNg2spMun/kUe1NNPIRhOb+/D6ZPoZjOpL2k
TCkEQNjCII6G8aLKadk4NnDEuTUPl/D1JSctRHdKClIbAE7RoVrjr66LXWUfkMocK/rT63oF8hba
0trbSY7snyRI7oW6WpZEvczl4zQabb3EZiVjONiLsSm/7x3BeQ+Z3PsDIhkXf9WjD14B7EBaUBe5
xfav8jZnLPQ6IH3KnH750UAvNd7oW7gxytQUXj2a2NWjD39ZrwElWr+IKy9Thi0IclEH+DTRdm+c
kFXX+CSITPkBzDyP/jaTD2bVXUvkFj1Xw2xvLLZPFwUytElCI4SItsxucQ9BnhRsZOA4QuhBQ4Cm
et18h4G9YZ7D+a8WpREUIN4a9vV3Mf2BtljWhfoGakF15F5CBmJfIk2j+wBzBX9Q4CXRPMK+1DrF
U/KcwWK2VDg5oNrGktE8sufkeuk79hkvZ1tLKdjUMN6DiYwJVEGTriHrmbuqj9NlF0oFo7sLAV0N
V9uX02yyTCSlZ7WVjMQRp2/SfIptEiv1YQaRsm+lfYyogF41OOnGWfSQedgSAvp49ibHlk/xt85S
eR+/IN+Go28bJkRfX42oyND1Iy3fcRhgorpXaNrRAG7ZdBP/QlJmRY5h0rM6LBEF0Kug0u2MCbB3
eM4FxJ9/gm53hKMnyv7tCjyznRx366h+tCitrSKjUt+8VO6avpzP7n/yYIGSIA3h+wTpUGGLvtap
s1pe0dQjufW9BPGs8tt21QqJgGOYwtOR7rLQbPjfbm80fJs7SCbNELj/ODXLenTgFlVvNpp/tg9k
DUJ8e2Rj+LNrI4S6zOAO217eDTwp/xeFPR15wR0/VpHl2wgvwQ497NsV2pB+mI7XqqSQRv6r3oHU
66OahVZUQ8rRaK7/LcJD7jkq3UFtGAlWDrarcsVq1C2pEEjEyxdtDxqF2BWogLyvxfbLjBBc/FVN
FdWFAslIUEstSY7FtvK47FRatXM3YdTbVJcdR2a0NI7+aRNBB7+1MDqXqHVAOdgI8cnqQvR8ShKO
jZU0510DY4hdLttMBwkhh6/omyGPQOU/4UR2Z87gTzdfh7Z8kYW+coyxum97kauWFRhDmvKux//0
TXL6bWodHQ/tZMwoNBisg47IP43BN82zBhf3F0vQPPsqTg0f6l7BF6gh92ATiXvV6qZqvCMxNCHq
M6Qvw4HmLPGw9+QyDLChLhJVZklusoTxo217GA9q/97c6DVVJy/e2RuT2KHZ6nVTQFCnvwJMU1bE
KmKb4ZnYF9wSjZEPQCqJJlzXlofJNeqUJhspAC96IwsU3vycSvVyqvRs7DIpSWWqxjSqSzuYCtGj
4K8Xk0dHg+VBpO6/SX8Dpj/Cf2RviGHKuNUGvF9YXMt6pdX+Vt8RvrCZHeMOHASzRNPWBivWSqV9
8PegiIiSg9KK2+D6oCAYP96zDG0AkDRIdcoKJ6+etvaBcekGiZyuNVTo6QRo9QkE0AEHYWhws6dZ
OxvKCDOoCwBB+N6T6T8yi2e//+cFdK08LkZiUUeBGbk81GMqbDsGkH273XUUEiIdGvXCq54tfLRz
2PnIA0N8LnNpqsn51ICPLviGw5xQ7QCISIbHDgoIlX0bWS6vAJ/KOHMn3TcBH2KNzshL6IvD9qjP
E0NCLZyFAU4T/cdBpixPdu4UDv3OkBnj8KqClAJhYCu9zP+nqmI3za5XGjdRfmybt/YRp5k4Vn47
6MNO8wfZDbPWrwIATThl1V0fwM6ZXvpNWhJHKFhKqU12hhBbCm0xLo1tXm3vXdMej1fCPEv3V0lH
nT87NPOVTsW5Q5IBS8KDOrpuLhIpfau5N2jrghyWmCPSQ6UiTznLY6RALdFIZE8k1kO9IkCW9Tpi
gEMrFCHsJwsKgme2ROUdHjAhH0sYWE1haWpW0C0BCgHh19hmr25ELgEuy04jtyCZr1Pvryoc82jY
cGJ7bHoZgZnb604q61ciPTqAgvPx4nl37bXPijj5ReNDaUF+cQSt5Lbarv1uOwO62Cu8RnqFS7b5
kIviRzBZUT2vgbLkqSr4nXg5FPMKDv3SKmB2IfqkP3k7ZMA4BH1PrPwo4/zViM2pDJbK3gAd82L/
ZDs8rOh1aWY/2EMAW01sfhkSi2gIyXgkEhZKwyJBnvJLb1OBz399uAVaGitVIDEFIGOW0VltKWnG
n3GnjWRD/gOhzuXeQVdHJHFbJ7PUb3KRfyanl3PCINEuTI/4dAmOCff5zIm6T3H5frSa4yVnfHs5
ZRhQMtH39DJd9iIPnyBrF44UnO7n5KqK2QVBf5IgIvES4Mn82GCuX5ZTtVjkZIE42vmDrX04C2zS
TsymOWUjvnIrHB1eSOoulRsOB4BYu/yxFC3y/6Hn9xUbK4UFKYu0OYL7t6cnJNJVxE5pjgOOVzOg
taveG3+l+MXGzkT8GTcFmkLaXr/Qv/h9i1z9AOGwBRlUvnxm878lUmqgNSewx7UM2SgXjWWSJc97
79FhfUfz1f2BU9JgoAFqzOSXYJDVY+AoRSS7V+z8+W4ABM2HEsxk46PQnfvsfBEQmsDuyX5LrtqG
NhKAAhO6ALsNjUSCRlQkc0ATnGLKooUS7ZESH/S9kPsUqcg0p02qVZS6QJVNdS78bNz/7XE/pgJV
30zfhYSDDfglthJpvQJMTvjyT9EWzhp2l0lOIhN+Fd24O+oLue75GM050zxdet1RrFbh3sLjc7eM
d+LWFF94e3piEPucofutPa3++is7yc3On1H2Egynz/KSolng/pKIK3jqYgnJj3FIWPGcmSRYMCz8
DGHAfYildRduMEc7b66avWxhGARdIAN3Tc7EVO8yUFduPib4BC0bLxkLsI816RRD9vVi8FvE9PQh
Z8RyGzJ/m3vSikxZuNDgTJ9nXLVWA3qyihRGUZTvTsZNX+QlguBm2QWckSTdpDT97WgiKo7caBZC
f/GsHGrTIcYQjubTdPDTJtYyMA/AN8/+N3y+UcvS+c5SMhAjVE7zYSrByKL2872jRLVDFsKQHDGK
Cf3mtuK0xpCDZjHdZ5fF6FZVvaGRiuVfN9xs04AjGUxlVN0eiTTnosjiXbdUunKx8nhvGFrqjuHT
znETOGkxgQxMddBMAb9YH9fJmVC/y2I6BEe6/RqhSHak2rN8hkIfGCyfnauWSQgkA+8sZz928zd8
nJpmieefQ5uHVoDCGxlz/+jCTXuftuvFbrDhk+yHNr5hjAzYKd6+r/7MJdOvML6k5fvlVlVjLOt3
7JWbrS+JICokpWHbOM1AqhXKVdkN06ZZx9q1miBg+7HxZfXM00V6Se6ksTOpaP8bPBUK26/F3ZT4
Njfi/vvUZ+6wzIbnObhWl6fgmDASWk+EhMH3PPu0KYFr6GkPGKIuGXZKOPmjVF3CgseZVBIasaiY
1MaxiqtkXuLKaEn5J0+nZNRzvF9pznikb/LQ5U4xS/yuNE9bjRLfQZdfAee3CP4bBSP2RLaNaJv1
186MDkwhWswKCN8AXJt9FlNiBH5KXxBWBO9Z7qAYd6DJ3c+kdov2d1pTqpksk29vlQHvDOO7VVQ9
zwpGc+hTR+/lA+QVpffHlPe1xBp2r9GZFXfCzJZTBSFkf0WJgxsYzk9yqWmmkY0jsI01gKQLwQdG
EssBL+0AfQI36AoUuCW8XC4MJjZpS/J6kH/8Rp25kouLpNDR+T8PENuI4GM47Saa6tv+cj8jebzg
G7CUY2cDAvEP16GjYmLwLDF3ZwxvUbqJagMqKkJ4JfE/IFR3jcgKisZwjNPDId/Dg5fsfyuv6/jp
pHJvHrdNk7/UoVkV0HXPMTPh/qq43Soex9JMUyOx8NQk8weNWLlg0+2HZToNj+xlxiFzB13MVurF
eaaLRtxDYYcCuwfZ920EPJq2PF6jG8SJpYMqMAavYrxFsveHGI734ZaHYVss59jacBPl0HGbCpqy
u/g+8KHaLP/M8L7Abh07cZuh0R7VbVzrFSemkYgnLEpJZxGDmgeD1Ap2Dt/OP5KVgPwFXlqVwzsu
V3u+3JDnaHVIANsj+VG7wKW3ug05YjRh8liRWyDeGQ86b4aOaqc2UaK/yh8ktx8hA05g7I7hhDSA
2F5inzoFTKs61hzwfuKqUVrS72CFm+4rSw00Zw2QRQ95T4PKq7KdbzIuuj90+KpDsuOnEWFEIQjj
GRuL0+yLP9UrHg6m576zfTdKAc/q8Oms6+DPZ5CzHUEpwaPUsMYPwumtS3QITVcxuYNL0lIdSvtY
+oCOhUDhqIbZJYWCL5CPlHhRl2E7ils+GPLbgt8R/nkfgQpiZSvisFz23HrWITw9wQaIZczfP6f5
j62O7XUhEnbWNbli8oVGoCQSKEwg0bbpYZVopQZUeZKeWQyFGco2jzlWvDO2fJAZPzmFxSX1cJy3
huvL+mu9SFaYKV3J38o21OcUSq0/ZVLB1uukXNZgx6mf+bXIJ5689J9k0kqF9uRRL+SXK1JUyTvN
uTPybzREqg3BdLQNpKxaiALTBhYyOEoP2oKx3cuebGuwRZMWpQg7vRKNFmVHoE8s3vPTfelwK4vg
hjED0LGKvHeGfJv4xpd1/AtLt7STeMduGLd8V2sE70gKnDIUrgD5o7KneWpgC+TRj2oaIrCy0hLb
jbim0HcXSoRYgrASFb2H4L/oFw1o5sHFvsRtPoy0jIy1LxAgH0eo5hymZJ2mNmmwWTnVXPIQ1sGr
MaAypIqt98TPUeu9udMGM29adjlWxZgtZM+rmZTBBEyD/BGicRW4b/sX73pY/WxMeseNtSxCMlkH
UID9PVkLZFeyUBS0CBT2+agrFBsy8wRlR6VsKjzg30KOaiF5f4Vfj4rYI/M2rnuYOUhAbLn7AUdc
SaDw/R2r/vidQPmXgtURji0l+1NhZr/Wj4umIywqrEompaLS3Br9cWNd2o3U63uDBDZUv5CWO/Z5
l1/AV1E5P0RhCuHtQsGIU/YodNBkk31bhyIgJU1hcye+FQcKj6ZrIq7mM0X70rSfGkJfjhgOC602
qXvOLD1yX3hR6lizFT8iF+CqS7xRPvhliCVb2CJRa354FUuOpHb8QNqsUV0eiCgE9wlKHugZ2hbf
oR0JmBhSMGi8kEWtsPeM9JcpIY4qBFyRTUNBv+Y8CTKpdMJxt4MKm5h/xKBbQhc6OW5tmKEo66E5
PBkaqLAzxDny1EHsZHBKW8acTwC8oyxpwQXfsv8KaUsZnif46BfAJNgAw2ASj0tF/r89Nib6w0Sh
2eGqYqgs+OHkLefPd3gdPu2huKPr7ObYWJPo65eKMXZAJ/Aq94fDvqhwitcbTcGIm6OsHRZUqPqo
cl+5N0jemuVLGjIis3jkWrmxkI5QSB90pufzLrQaA0yr1+h694kb2Zy7I75aypFl8Jk3EUOBu0DE
qE0L5lza+ifd7gNcCa0aJCm3k8c30dpxEJ7cAi7e9pgPLpHCp+q1n7mu0iTLpW6doHwX6RyG1pgc
yv31mnmZwEnarVi67W74qNKzxR3IRPo0maVMUKBlvyPOU59/JEr7V2tt6dz2c6+2twHpttQxE7kB
t/tglaxkJ+wg1DzxWr5nnrNE+0i/9haz3ygM4bhXIQ1E+FQ36wAbMFnM4lhIULjWalRIfOnJ42u2
1dsjo8fLX5ofepFoWFvDDdimH+fbIlqUNanC0nr6KcNtgaAILbjf4KuW0QWr4LSYl478ZRsLFMw/
5iz5i0Ack+hDp0p0mShx7KFlrm5Da2Cs/C0IDiXrASSkSQ8wf58Cxy7txybE8H2vZl6BqERoqoJA
ld/zZmcqTHfY08fZYwlSvwp6jrg/z8J5A+v8I8VVmoJY/OzQIx7Tw2CeXbVSAUeM8HykW6HAEzsq
GjIg8MEYCEcK9iNeXmimc7UhTV6X0A9fq11GkXGQukY38x5e48XkDTCgnvPSrvK+Ugjf7YhIWmJi
QJIGWM/eY+dgp8byJdt9puU7EQA4Tftlzv6/OgjHhsQ0pehM6xhFnvaVoDvinZD5QaHsbgzjGZt2
vs+wt09vmS6GyVmH5bKYjitzk4jsu2ZdFLkvqHZs9tQY7gx2lYHb2NzHAqE25Ou3HPlRmDv5yNHa
josAr1YOwYHuemURRjUmpUKklkl6TprtylR4Olc3CGPgF3Kd5Si8LXtgNm7gDFlYDdscU2CUM44l
txeTybVcsIcA0EUQnaiAa10hen9e6pQYFyWbYMU6AuWZFKq5J44Y2/wm2dsW3dRYFdnln/ziOn7K
37eKGfS6JAQc13iB33f3eT2J7geS/NV9SPHQg1/WEWO/YipBruOqV5gSD5b9mxVzpMfaHz5pYleK
QrfUtT33cBxKMnN6LlMH1envP38n1TAVjdov1Edr7ZgD4yQDSXQdfBLsLhHc6XQJyLs30xHLnQlJ
ws5ylXx5Lmq+1n/IAsc/cClaUfCk8TvILfLcO1sIMCnqbdw7716A0fB7T2pj9BUVbbF5vMb30Kxc
HhuEtqtwiA8r50RGA/YXdD0o1rywF3loLZ+Qomn8YXwUnWbAvURZhWHWSLB0pAyzFwmqWfWKz2PI
Q53UidcrIrFbw1wWVZ7/6Jzj2xKyZjAktpN42RHi2myF2Gur8uEEBqfGi8sz5un046daoY8bY0Du
Y4MsA9IG5cny6VMQ8fhK5ZyDmhDNB9QD072JevT+lOg97nfQz0ngZ00R42u7x492EPVE0brjihui
z7bm4fpYlxmoEhIf72A2QdamzP7sELJy7GLnpfoGFLojwremo7J0jZMJV4caWvG2NPgt8azLRZTM
SL+rl6jmN+KfdQn1odFQECqOM0GUHhsbhBfREPSytb0v1KhjnOwTk1Pz29wXGkxZDRSSnaaBMnGV
d9379mZHCC1j4u6+IN2VHnvC0defc7xO9GTryblwaM0LTs9m3aKLxu30T5wkIytjjOwgv8fNj6ub
Nd8BOIHQCk5U3FoXWpdUqyWv6iiz6MgNnCusiuRId+gXueGLlRnC1w9lWJID0WongQPoIU0rl4Ac
6i7YCqkRp/QQaPsi+UU81bpCSKdchqN0QcPPDJww9Lvf5X8I1jbCSesnquPvK4QCz5hoNE7EwciM
GzfF3yy3bxmzxMcLUejTiuNSSxDeKRpoi77h9AYnX0319SJWqKFWbM62kfpN1rbZTgJ652eijg59
q3yByxUqby9yPUhci6sNg0qYSVp6lJh+bgSPmXbwuHt1n9pnoG3De5lw6cxcuYOaFIS4elgcrgnu
aoSFc3EBg5OodxeT9qtYcnzYg9vXWPt08QgCgHo11D1IftUKu1aGxbSvCcnhL+TQwICHXnC2G/8d
8rpSG6+2V/M29x5TUzOev1AcvrnEwHyM/h8/w/4e0GjXXWh3sUUk7bLy9wx4jqKf/JlvJ2sRhnv8
us76sTEMh0x3jfMbh+GsuqsEr/Dkntye76xYT+O7vlVnvSzTZShgEpW01uQO4DlzYcfKsMq7RBTH
+kHEPBkd+1m8rlUdA9QTs4Yc5eOgqI7KjBy44UswWL8dyRKlsLN8XR0bBN9LAwdCrXtfbMeCKi4h
BWxsgL16ygpo2rDaA7R7UTSiC46QRrCy1UkIeNz/8S3cc0uvOBgW/6JfwZfZ1WVuJXoyxMRJ3fRW
NpyXcNqDzGUi66AWklnoTwjWLNBcZwT8i5ykSt51R9sUl219Md9eyJ7+eIrVKGlRHf31M5AdvG8Y
7S0Eis+ToF1zFJ75vpYDvBa69+K9Tf96Xv7JA2cuEGwqj8c+MISVHdIm4IBnzSFarQqLPoUOe08B
Lff72XGZULR1ZRnilULXu1BTamYhWItIZdfEuxmeNtNAFFLFjdsPk+q2oDjykNZwqRP3kNW1FWqG
2pwHavsYhGTSJGm5AxIstY7dlY7JF28v9Z3OrxI3SP2/MAQzrMChDsHi2o9Jm2qmgS/zKl+9f6tN
l6XqPYWvnOn8MX1o0uFTBm2I6EPPwPqGZsExoAX2IjJuiO0u2vbBFlzLBBu3YN+lR2Gd64ZyAo1e
eFyWqN2YPnI6A7sEakBZtVcKpdjqwutmT4yvjIFgxD7v0isdwEhFMYllzY+KA+DufIheWKQ16hIm
DliDDBktMfkeIV+xbbuhJrNGAwSUmzvOEcv7WCkPZEQny5CGew80PK+zqrqyMVStrErQAno6H8ug
WCGDdymZAppiJg9qgkg1wHYpQXcWQO+TutFCiyxgIInU5h4s5gPj7y8zvr9prP+QngAQTknnZ/ls
+mMbXPOrkAOUNXr/MLnqiZA/plyRY9UyDj8+llFespSJ893JLCBZoEvBtjl3/0VZ1e/KQfukePnD
0YgbsIdBrrdzDPqF45zCyb3HnoBUiQHH+lRjAfvFD+RGjShCg+PsrzZgD7kso1L30bxxw9oq5Uhl
qS9BOILECafBZMQtARht1/u1MdNL6t2XijJ4CeuRsVmIyozfSNEMB4bxm9wXVzkNciIZMtkBJc1S
qHRSPPARjH/ojSUUcdvljHNreho5gOx/32h3dwTSar3tx2Am3BV1k5Nl9TpDrC+atYrVMBWISsC0
HLKhyN1D7q8iCxp17th3tqdYW6YTM8hftkjwZ8kfhHiQFglSFeUrNEWtX0Kl2LMzS7chNQTE3S6b
0sSXXXlDkhh0SS5wQ5A7smJnJ2vZCJD9Jqxo0nKz9dXQhyEze1uT1sg/JrD9dLDES8iA6qflV6nz
bS4zRLX/gS49FLZptCsmF2+b4b69h0HU84HFKihLYKmiPCy5/TxWeyBqJYC/soxElNnCVFyjdOui
arsdTRGzvOjp26afxHORqT3kqFAu3FqItqvpQ0X6yyBAiBCxIx1TUIYbAWi+3OpsVf/X9XRpjBqh
HCFx8m8CEnMw8IT005O/d6DE60Sgeskvy96MESLLm6kRTRz5qsScb5KYnh361yOJCNURPD9tSvjE
axjfudiCg+Ug/Mozh0gdoSk2tcJUexGUH5/BE+dFxCOlUuJGi/Sya3FRZoZ+qIVhKHhQz5OOZqxD
BJhweF31vipPK41qq55FxXKUFLLANfW1f6N1pTTuFG9c4gzYdPxt3KxEb1O2IeR5uFru78EH7u3h
cI+6ImsWD90Z0bTJ9yzstESNXRBqFO0PRC7VRuQEToQq0/bioHf55ORt9JIxRnL3SF7sbPxBtACU
WfGrB7pD6xN9hItOgPtJPNH3lh6rqCdnM0x7dsn2yz8pDuVgunIhDJVtJYf2Jf3pU6ZGpkvRczJY
pgtBPD6Gv64eEcP0x3hw99jC47q7CJ1MS7sOzwExIdZCSXYfyeHuSjsfZfpgSSZBHzeJk6yfietz
pm+wTzNZSh4xnA9VJPWD8UEiad2Fc30RsynCUUuydkh0JYkY/jxY0NgLubGWUfvRuGntmngpTmjb
sg0oIxct1uwepZvw2xGmFdNZV7CCqtmM/FTfIpYSKEVHx3JM9BxNlM3FB57Z5TqQ+HbK6fTKKMMg
LX6b0OHHo4Tz4hqGq2GBFlPHRh6+aXGk0KVlQ95VWosTwc/P4s7Uuys/hd4ovI4MNLKyIW619KZz
HcYAc6uB0dQd7nm7rRCCTY09OM0a+0XG8eEd2kfvCCjh88Q1cVXsf09MbhIDzDwDLOsHinvbPDD7
rDvAKsV0wImLvsF6BepZnYX1NhwTGQzT7LHUyt+yu1ko/gW+p0UhHDRLEbhS/Llr4bdQfFujQpm8
lrbYkQAWrZ5d37xRFMHwo+V89c2FLHTxLg7T4Kb4FZFckyWj1y2cDFhxSd/QAhClGru0BwZF7fWR
qtInWFtRFEDzJ6rC9sBg2O7j/N66gAtd42BArGr3Ymu/+eUiQcVSMlliN3ShYc74q2n3vXCaBLvt
SKZZsfSpQXsU67QKRolB7ulsMdH9uorqE1s7l7LOPC7KYYm9ViIbh/Fccdj1/5/QVb3ZSTnBaiqk
eSgvm5cZ8U9q+yIRmXn1SOPVDfnM5S/m30DgGCKz3Gwu3B9ka3wTGqq2ENHlzZqfD+CFTDRtViuu
MkuHNxN+KznVqffOLoG/11u0VTaU/3dCvMsT7fzmBLxvQtEkpZ9a1fmiwbY/Cu11STQYmoD/7aoe
B8uTHuin3/InZjdVlMGfKlDO2j7+64zoBWDcaJmocXT9Oql5a2TIT8SLAOsveoBuTxSISZztvYC8
jzzGyIbM5VzvUbHDkVQQLZWl5Bhf0zmXZC5eGVB+/O/h9kigcALOZtVBE/OE+JMBu3y6Wfou/TI+
1NOOOuNFPi/nwMkjjy5HpBtTILY4z7iHRs7zCrbBtGQrw/bV+Qp7FiA/pHOyumtqY7s3IGpReK1j
+RGAtAIOz/6X97qv99A/E0t5eGlHJBk+/vOTCb2fpxOc2biA/89XqSIbqj1bvek/nmt1XDP7P1HO
hMb6Dn6s1WmJ/wLOrBcnLbgw5m6GZzeyTRF2EDfK9ndgB79/udd8Z+k0AOWb2MaNuEFdLSWdyf7U
E5scS/mtKu8Ok8ZJr4gQnbc3AtJZy3cJwYviwwhn72kpIio0JRVDL/mED2Sju0Cg+j09AE3pVhJJ
Jm5fEoMf0v2yznA0ZyXWdjl9h07sLXst2WACTNVglAZPJzoLgzHTzYtOYxhfawDVcu7LZFzXY8+t
LpxwlSxS4Jev2bG3lhGDi09aVd8UXwdgCkRX53QuDLsxxuE0ZKvLYDgct9+Vd4B9Ta+Ht+H4PSQb
mq54s7O+aHB8I6SVu8wS5/FaO/ft2um2J2/V/t7XRbdMY7lUOfxio+lkVHYQgME+F7iRWv0vHhA6
kagLUWyRUWPHQ3awyPpJlF7mgcmBqL7zjcMf08+DjXFP2wiaqPv3dN+GoDbgjl153wRaAKfWb6hk
ESeLcSY395wRi1GWMMrCCvhUOZtsSBvC4IK7gSPQpym5ZQQYo+H4DE7dluUyXBo9gB2c5jMjqmnc
yQm22lHo6wROI3OaAlWLi1EQ60L2LCMw64Tr4br/MVdOv8DceJcNvF8OZO3E7L3LHpVDKG19fDsF
lrU3+EHdryO+KWs0BILz9vWiAnEyqEWn3mLzshXnqCfqnJ2i2egOU8QPm9GkuvKJaaomJC9TUOVt
yJjiSVPiVw+xdztA76CynH8ams6z8eace9k6eb+Kd9AcBjro/8eN23Qlm1+8EXTixGHltyGwiLZJ
ANWE3Wcd34wPiC7aECauCHGAiDn2hu+2qzrWhwtqRMlS+mQgnbYT47MvvBBWF1DohHogR/7oI68+
SyQsUdGNb+OU7ySqtiE0yX763PIayZ2I8cR4V2wmNdp5uiudCxYYnVc4NEAzrMk3eBow0YMIrMj+
WIzSYgChd5fKO7nJDoSaABmTT55uyuXT/Rtm7yWttj/0lpDyT/L+lzJHCeTg9NoanC/0TO9HH2/y
6LsGSQo6DpygFEU+4fA7geYH5R6cmYzq7TXxi3HRakKX+QkGU0klgNjQtsw0JQWdV2Zv1pp7wpFm
MJwiA8UeryBmMQllevnV3lhDe5+ppW989UpZroP8qH47aVdrpUh/B5d0zPnJpdiHSm/Uwuh1bSRY
brMh7CkJgDjNfWIJTgVeVB3EViSdvdPv626Akwp/OanKSfpcM3MCiD6aaxTUX/FgWxOxIKhzb1et
0cq3eQpUJm9K9M8/pex3kHohJKY8zV4X88taNp+JlyQkMApa/mt2ZcBWReE2iU1T8phEgDCZjXHL
Z0XCIMo3vE16gSYYawQu3nP2dxQIRUwGY+eKlC/BB0HAU5nKnrQCuhqY6Evox+qMaWM56+Astgjp
ISIlDJdF3/LIPb7AKByGGuOqGENRXVWXbofBV+pW9sE0o42Gc4gcr9qpKIa7guIYnVbbRX9RqQAl
Wa3tQ3iLfCNz2T626C36Cr38DhSb4EuuNd1pDDcypJmn9hKk9A2cLnPJIG9ueWz0eJtVvJuREziW
SZn5d2/AE4CsAe4Y/xGzyZuVKVB7M56SD+42WtXfHaki/V0BeqX2uhH5iv5+1b1/fQoX20TEc5NM
zNocq0livomUhUwXWDfKzUc3BOI8oMzfr7Xk6yuVKbRsMFjotT0M51CX3/h3gcrYA7rNPqf2LTmR
vgxh8ehJaMG9QvRNMrMGGn50cMWR7HMoGDdmhrk1jdadwl0QIfWiAYx9yg+2YTFlXDeZ6/Ll7umY
GZdSeydX6TIxZqNeSg1sXnNcVdssc6dl8V1XEyA/kp2o9U77R92GoGDTXtEIiK2jvq9JwxmSA2Jr
bx3aFCMch8Jez4JNY7nt+Im2a15iIJivTexEwzEle30z/MrHzqP6auXvNH+KeV6gk/KoVsDqLbmG
VE94lRyQSr8dAZOepFLWKYNcyGWDgrentOOekFUpl+Itzr1IvUaUASqWtartlRVQkeowXPn9ZyIZ
4ohj6MR6iTD0KL/hxJq0TrGv3Tm7b8WcdUPDlVVVfmA/fq7AaWg5Q6gxtpImkuixziaCIq7mT1Ti
HPAsAym3bg8u2Cro3w0Ik3HOY+fB6zao0it5YfoQ41Mm+GYfJdzw3t2GG7jkIk9Dpz19XN/FpaDx
b1cSDNxaFGvLdFOhGR+XJwc3l6/2oXcSU0P00PsOZNByjkXQZcNO3F9GSBne5kPvoFb9cdNNPbUe
CM8b9mY4Z5ilW6i0xlMP9sQ8bT0iihDIT2egE0r4377TQV39sTzqCPBQVofFYoCoOZen3ni/nSjm
Nk9nkN0WriuxUXumNV5EJeGPx1wco4J7TKGdjpmoK12xzc9McDhSE+Lo7AQQMNa/LVmug+gjcj3y
2+Q1cqN1nutNOYa2qUdU8rzPfcTS8liT991GEMSNo9vXySohRleFAOVdD76So4r9JdWHzgDx4b0W
NrBrFJcO8r8jv54TZvingPHGHQ5SlERMQuIUHmNwR0kkdbwfLpYQwei7XGA4HBYSUSQOkVPEvyJ8
ifnGLrrLAgGYHwh8J+WCUvcYS3U0+9oz3lhGnORsgRv3SRxOl43M4yKR9xjqq/IwcZy74YHRum9+
f/sZaybnk8vXSWTUY1ZElngdN9aZh0xISobWE7+531NkJL69yTuWmhQFNrF4aalXJ2OjFcl9TgTQ
a0b2MH3iq1DbwUdBntwuYK0fXDC40Io77SMgAYZGnNZUa5zBbzO01dC60AJhA50djg2I6LmE/4Jl
BZ+OHGFPANGv2RdyBLvteuFX9qJPgNtcB4D9bkUj1NsfX5ArEhHpUv59PGyl1p3s6XMb46Zi19Zf
p2vyqztumncYBksu23l8EnjxbsomxDntytxZgDC8nNjnUV1f4BwA9IgqrP/vz8r/P/bRIfvU2y7X
8rnDPsc7XxUSg4V6tbG+zxYUSmEHRzgg1x/UpJ8tRgY20bMSJID5JF6SViwfeH0KnH0NSj2VUmjs
TqHj5iJMHgYpRDT3BkovuffJrM7QvAKOlcsMAAmZr2G5daZkf2xRPFXKs2efBI33a2QaNyO8sqqw
z78vTdUB8jZ9MCBGeDzha/WmV8nuRXlpLjJ8xumDCGMNpcK8futnCvouVgqAWkOHwxdpMeVVm5DV
NwmZLCSrUN00vvYxvHfux0ggfNoEgcbnUFqHt5npyEyJk8pPLidDY6MetXKROgkpjOlbEdxfK7U4
/I6NBJ0Td9wtyR/cfJR7BNVKGDFpC27lBQwKmxcvWwz/ozEWyJ+3bVi/elfDELdNm6e4bRjbCLa/
vrtyQDIwfJLfivNZRVn4T/0VZ4SA9tguBCWPZGODsNIV6TYvVMMo8d8zQyizrZ/GMgnQh4K2HZ8M
eT322KoUZyUU3ZQr/VdAfm9V189G9ljRGyv/WtnMzpwFCvic5iMxQmvM/0BrnVK1tjJ2Z5L3cTr8
vINpehnsZTZ6xCQmuMH2C4VX4TtFIVS4vFSvGwdwImCo8rtdOTkfQ9/ySCAtCMOek0XJARmn9kQT
bWcDukZ3DgqePnwJVgyhgXkUItPR9pElvfDF8lh5P46E1MMqBdfQx6sbb1c+G5otzbiw5eztgZLh
vDRgUXr2LKtP0mRhKUlTmHOl2t0bf+go9evB85KtuJ9SVQAFi/Ie7N2EB16+YKF8XTzU6agNLIu5
SrcH6VERTd/WQuyyZ4tQlvkz8M6wksNhLJTfitujiRSxi/8KYUL9BmDk6f2JmxWlWeMzC9FHqjpY
C6tpzszvKPC7lwVf+7QQjG0059hfMCr7WZFjCod7hYeKjUldYQv3Hfdf31F9X91f08XF5RLVmbsB
p/oJtFeUL7FqiJr1IlZ1pkI+oJTeVuz8LgThvzKZY1KOrORo9/9SiPgX1LCjrjX1Src2whz7ykug
mmfBq9WB0mAsJX6YhKEdNcvu7bjp3HDNQMDRNtlrMdhLN9WPiGEUjV+QM1kHXV6g6Mb9Mgf7EVCW
e9qWPcUKBx2qUAL1suWEet0b3z+jicXqWJ2V7hhfqi64Vz0AqbT1zrqtx0GJcq4DnTf7A+mcJ5kI
lroWB5DEhLZpMUoHVdpDwkpguwh4e+EHiZujMmT3bq7M486T0/MgiAISFyqyDJF3RbZGkyNmZu9A
d6FTxJjhvZ6mo6wyTq+A/yFAhJkWT25G2dMvjjJLiRjiPln54Fr9NYe9nS42hj9gJ5uab3IWjgrm
OkrooSCI5KvfJ9olIH2aEfeszODXYeUQgC3oNEXgfBYmiFtyDsoQazDwiqcbrsVnnBASdH5E6uMR
M7JumV1J8Uf5aGQ6X4ZNhxH9Is25H50uVXsTvq3K/4krDa8IgiJnGem/eM7QP/NYHJMdAew7YRjT
vyvYynUDdoQgfYsZ8zHCtMQjdVdc4QZZGLXi4VfR0lJ8eUiJM9NkFSCK15lbNdfx/Dh1DN0Ryax0
UQFXhIHE3bX12nWuzaDifX2+vEEJGsUHgRydcM+Pi2TrWC2fTBef574hLAIbVSnD7fc5sY6QwCqg
5g/Y9M3QEy6HYDSu0IY9GalL5j52KdWQFd71KljKSLnQf3XFBkkXWuFLw22Pztnj2hhSY8bBbD33
93exAdYQVL7+XPbt+WFKaOMZmiWovL9X8ep8wDhvi0EqPWyHjZwiZrxJFZ1nryLdt8R/IXw2Obf+
BpaUJzXNhElcSiUtTBWf+c82HXhbALaZpMPncJUqg6zKlNZqaBcje19OSkMx040Oj0rrKCVpC4bU
Lf7goD/cKIwrM1xuiqxJcCRGHnsnvDozE0hS+T/z6EtJ9SM3QJV7gSMcsj+eSr4SRntNQfowT1iU
YNIQA5+YH/I+SdUNRhuVoWqW5CzdQQ6KtYlXnmGxkgGQB9l6m42i4xTWL5oh7i5yMxq11R7nydXA
6VvoIyiTQMcMmyYo1uxCp5pfc3rCVyJbkp+9Vw7R9nhUJqQ8fg8Lr5uRYqCzyyBRfLx7VlVhxcmp
S7Uewo5jEJfcQZIuYu/YnVLkjneGW0U6c2xVYxpgZc6gMKaIlcodJJoarjXLWNFTClfJKPLY7vWj
3+U0vjRaFLMumUr0BnWosCjGqNs1k3g1bpiqHZfBsyIdNf33O6qgc46kJwKIB+kmI5/ZceC+Q9+v
n5k49acnS7GHF7exPH5k69qjrRTaDRZ3Aa9VvVy+O7gFu7im2IEwoYHjpH5Wp5IWDSKKM9di3dnb
vuF1/cGf3hsEu+MGvjuKR/IqBuJcreaUHpzavVyTHd8/3l/UwTmLXkatJG6lnp7OZWxU0kXMPAL0
64ch5DFOby+lCNwk1rSlEIU9Z3iX+s4UfuI7/ZUo7K4xUNzwtuOYL2RSYyksSr+nCULsEclInhiu
DaZhNGuJwrYskOAsznnvCKdxXiVL+DxdKqevwid1VUfDaSDO7UsstF4+ppY4mmuA3WR/eQwUUZkS
l8FLmZLGrO+eZYBprpZamOi3rht7rYbgx5Jn3bwp6QcuOi8SJ4ao5eLvRccNIgN4XGp6A5S+A9oo
G1ZL2bHNXuV/dvSQr0DZNN3vmp5BsiDeDcXt4ySl44cSExFA/ZKma+V1funqVvNCWvEnOOBCt/uo
MnSTHKF44hOTypipJxsAi63xfHvZfExoxsiBB1jJ5szDML3u1Ehfq/gQI/j/Us+sT7YUsI2ohKF2
g7fOBfndUWP8jfSmZpv6GLfUIgqV4JqKolFj1gkErP+IfxobZr+QesDKlBTbTlpu/qZfamEQrVAg
MrcuaQLhwDuAoObxC2H6wv80ldzjGRD2xXR7WOJV+VFSmELPZiElD5LreSJWZWLET+0PHTXDQkyc
FvIaIV44tMMX2LxuMFKlnEOi4cc+NZkFtl8+RVcAZBffx0TfTgUXQAKHTU1qb8o56iwhvlzsM8pJ
AYD6XSoBQOX4I3CwsF3TL50kuEHEifD4hg3CC3gC9Yl3yNuIsmD3oXHKSouEAUAMbCwniHrVAKZe
0DOJ2KU5ncrp+M43WGKLOf9y1qkqpUUpnapGbxOAP8a0SwQtSGEh3xCEMZe8S0QDO1VVaYWsMFT9
Qday9TGeRvHGDDMJhbXO59R5mR+Gj76yRfklBqoza4uiJXUQb9bgxLPLnVqUhrSV99a36VDah7BK
3o0HfwdCoR3yBT3bU6ZE6jNEoWp4dTKl9dQDdjHtWD0cenREGUqYhRMtz15N0TCjJHPhYgWCHKS/
ZpbSdkijQ1tSBDs1dOZw0cQYioVd/lOCklIN0dyyRS08KMwoFxP6BH3yM3Zrqgx8XvjZUdctqJHw
Lx11QN04X5GGwiHeN8qoz3Wn51pvBgWGWmlrz9p6Ab+oL4VzEkYvaq/LxjzHda64jiqU60Rx9ZVL
P7wdSxHAmypuuAunSIz8OZtX25duejd3tajMxYrT7XjOjE770UEEcdpH+mR0nBVxkb8OwPQx26++
cjKi+XiWFmKxUssKVfV3DS7GrNcMCoJ/rPBSEIgIOdG/KmpGzRTWje8WPQwnIDCBbtB89VcLoCYW
Eb1CF1u2aetxnTY5wEt8U/LoWI7aY1pi3yX5K9fpkptBEg5bV+r2MAVda0dqUzcbgZ1JON1yLd7n
kdgMKdenfVztZtbn83PE8H60g9IBkB4PeYRsctUyZFbLqN17nws1HpSvAL6bFq23wTRBjl3us7l7
ZZ77O5KhAg/1MwWlY5OYrfvO4jZAgjB2QCN5rtuiGPD9q75xzi4eHeGlaHnFTZo3jgqT2szsuoO0
uAA6ucP7uQEhO06Rdn4YGs4hgeCPngTv+PEj64C24cD+BBUoNYvaJLcf0TLGtlrvebY6bhh66xct
sgxeUwMt9sFSLAVJoCih61pI27O3RcxW49u2n3MUVvyX2k9GYVBm9Wx/5BxGA2G7xkQzUEfwV9Bn
223h8xO8uiVcUiBR1lc6JWXgN3KnfQvXfki7oRZ0hN3Ax6PV33rGc0MuvPB6ijbRcmeThGvuHEoS
kIuXUy9Wa10KqIpALJPRk3qD6vprvq0QAw8oLY7FD+vqlUQRir5XC08zBXC1vzY68rCKyp2bm1nF
kmxcDiI8fTqR+1/7D0WPubValdY1PuRIRUg5/1tISGotXix/EisuoIFup4cEs3D7AsCnrg78QGx/
VswqwSYSszIwhdvQxlTXpIZOV4YyX147jDAHW/6N7hlokVcYyI4xAySlrVMsabxESJtgNXfZqSUn
WlYtJIHr6CqShYz00cVc0z5Gu0/RsUniyP6Ao4vZ+Y0/vjSHxcD7rJpyMOMNAMFrd3ZwYUh+f50Z
rkOK4g4R+ZwxZdhK5uRwJrcmMx96snYu8FW57+RAFUSzpYAZgNQu2mVMyeaANAr5gqO5AYOPyCht
9m1E4VNXEoeg4DIWPzEsO9VKkTKe400ndqA7Sp6bXwEJ9OmccZRWgJNRhMgwzBn/dJlzaEAI3Zn6
dQ4artXgGr27sZBAhrO7dORqsTOAEBA0QwiL+jKyI2STtyX83JAInwLA8aJ5kgT3alAXHYek6gHC
gBetUk83esdphOzOIKD21gB6znte7BvS4slrn6Xjhu4hsI2HisVyEenKi4jVPG/SJbVWBQD9Vsx4
7nFQZ8VPXwYYuAqzkdVADQYtkSr69ENw/emoCaxgvWMI9pjP9LyJgFa3pJHEt7DekS6c5a7UthL7
BpX3TpsP4gusXopn3jZRvJDM756Kci5+XaNiXTAYEBrdYfRPpU+X1fFjpyP6GOOae2TSFEJ5qwSJ
/XJ3iJscM2NowkxysgNsFyIr47vHcbVmIpXukCc3ex4gMdPew905eKYt6kSgsuMPfXsO0tqjeAuc
VzXWPRE2das9bSwsarTzr3unytaie9WQnoUefTpUhQ8fZo3D+lTiEMx52FUF9CPKoGYPEpWTFewY
X0ltOi4APibcgOCc46MtMpvo8XELqshEuJKCCcZsubD+DkfSz1LKrxGP9+XhvhfFxPMc4goYYSod
Jfk7AEYysFNw06VCSVI5IhUdi1hfy9KeeEj5IlxL7MRMUKJIFVJp2tzNqI84ufkhWzN5Ir0Vjjdr
Sigp7JvQWROIJOr6tZJRovF93FFpDOPeAV4labBwVm031i/gPauplxWk09beSkwZ1ga8oxscCh0F
eA5mYN7lJagofOQpAYCso85jqGjshOlxmABuPLUlpEfk/FOrFLfR0W8ZG9UYuYDyrqmIBMJvq5p1
8OQwzTcUX3R8ZA0gBl0x2FDSQz0BcOCv6TI8JPiU4r0DHSMI1uiZqhCz3JaLoAPD+pl3vtZFhuWY
2bYUPrOW/46IAw5qQ5kzxOFJ4Ef3B8ngyJFlijYpAKV1YsuW1wpzLxsICO9HedfrWmAeINrOYjzS
/jgLpes9Xdsg1VXEtYm6CNNOk0g5ttgZEivnihVONJE+nMk1h7D6XTzOfkf0Zzuc6SnF8SKEeP+N
l/UVsKXP5gUK1O4+xdy2VxJV6KLikZknVKOcxf/RuM7pPguBSc5LdrRo9c4DDmQxizfv06/VAOjN
glGf+lHEp/T/WlAQvuG8ntNiwrgW3AOKS6KDhixN1MIW5Pxwbjv1v5olDYXfcxVUi20pssMQSly+
dZXMyfFrfsxHtz8D0wLmb5mB1eAHHIpAmD+wqUGfUpxqX/EqSA7M8f5HnQOfeNAVrMViAV+1Lf5r
xIZgGtP9Ib8W+su2WN8Dqr6cUQF/WrKVgT54q5Hzx4L5ljy2Xy51ZTgEAfJJXoGeWT1r7o06Fr/4
xejDwGjMC325DjMvLEIcm7zc2THIY0UAD0XdGoh0RcKwY3LkOKm475Wf33GtqF7gbVoo04zZ7Dlt
8LRRkitaFs9LUigqgD5g4lCfJ9bXnH2Ulev7Zf/+UD/28lfR1PgqR9hAhZyJ83kR4fQdKdAFe4nE
FJn5OBIsq2lOM3C2Flh7BqH+LDE3/NReRQ3SZy6KiCM1L3T4Alt9+ssTClWBakfmvfgd3FGovfoN
0SpHb3gqyDG1h8W1VdGfGCa4lL4ysB3COJbCIBo4z41d3D2JmS9r0RIOLhcEPjEanQWCugdMdDz5
VDZ/b+pTSeRne044oqoAHk5M5MjcdS5qHWSzxWAL8CqNSkbU0xJV5KpGkz4FDf5K1uso8TTS84Qr
q2KnZtah3Wbyv+MLbPVOsimHPlAxUAOcoeZqmlH2xb+cGDbQZqe7884K+2uHXEiqTreGe3aRQHpo
5Cqu//zdviLAJPAdKRi5OtwUOWVRaIp0QFjmrIiqs2tV6Q9K3P+SDMKnxZa3t72m7OxvHpndEh7b
6bWgjV0NH7/i9VK7w/Kd767pXL59usZzFAfgSuIgK7WrwJ9XzLCvqY8i1PaGz0n7Pi1HhtqZ924u
NTybJchjUhICTX4eEsVH9ZNZ8NiTeYKib1hhEzX0HMluT+C50FWEkUG9IGpp6QBkcPDhhL195yI+
H3+rbeNUKr1sQ4kwdA5ZUuvNOWqe7tECo3mu5pgq6JH64VO9Pz8uoFsX2htbQAbMtQsiU/RFBxBg
fvbXPpYtjcodM2TjLo5kFJzUxppV5ALTWQR+NctJ87Ori98S4XYlYPlOqXUwuFRTfrBH1a/ihlRy
WD3LsQMuw9PxMnvGM7THgP0oNQ1jiTVGL1UYhlFc4dNVW1dneW6GsanmSVPZ3/FTdFI5pkV8IJoj
/8tWMJpB2lmyGwSV02/QjiXMs0wzWmGOC1hUrR1Nrmh8ND0HeGSTJZ50FNvpohxRE2rC+4S6/3kn
PvD3za48ZdPoFcEOvLaZJQ8Qs6NA9RhA7OCmsCuOGfhJkH1ZZYhzaZg36uf7mBkm1zyzAArPZ/FT
/dedO5lsVzYxQn5Ev1S37b2PrgwJotZj7M3w0OJPeZmit+gVwNTZahudybBsDXc1S/t647qqAcvG
y2oi7X3Zvy1YPVtVS9qJ5BTS/5U6Tuewo5ERC9q9OLeKl+T0ZzHu3zCHeqwCrjcgzkqQQpG4XA0Q
B/TJi2Dof7qSDz1q1JLTQl+/L5KQv0h35JcTKJ7WDcXz8GXZKl7ggm6g19Q/Yde4C9U8//HohAXu
vyTlQa8QwZX10gzE97wN9ZugUVagzEQ0A8dbJb4dNpBw1snO64abQEnVoHL6ppK0Z5JDCFz4O0A1
mWUPz06uKYt13+TrqhzYLDg2km0gM+rwwvT363iY3A9L1SkVQ3g9R/DjWT9DYh7hCAacVc0giWv/
fCcKrp05Rs5oE0S+GvE2zK8VSZ/1AI9cUaM/xQqgEDu3VClfrk+Oy/Nqztoeuok+B2Hu2nsQcc9p
H4Og1hrrob0fGDIqTGUb3HFfItd5vVnunF/+hUTD8vPAaitnzcpUnSx6ZcYug+k89ee4hC1zavI3
eLSmO/FGm+mTOVk1WVDVCNrkXPq0HIOdpFM0SFKCw0cLQdsz2U5opD+u2SAbrQ2bP8fpcWLZMoEs
Gif90uRogX/2fUzn7iuekOqPWGQitxXdSuwrS5QwUeVkiMxeFPqO+pJUUkh63tsuz+qvCUz8UUnN
3H5SvazYiXAgeJqU/vd63vAwNnOnWEgehaF0AMyhiRjS9z4o7sC2mpo5OHi/XPIFnl55jxUvAckQ
+gb1p+jz0SUgvksEzQx0O8xScaE9rufIZ9/I1b2g4pdP95lp9/UJPqJu3yypuv/vpyT/0TeQmx68
JN4IzY5sQqmG3ZQ1fK4kILanzLs7Og7g/jo0XK/O6pKDaRx9XKLMEYpfC8yR6zLHy9oFYIs0eyYz
1Ob8zp3wRVbWu3G0IKcTll+4ZX1F2QBQz1FbziSQnu+g8001zLjaL8jesmhqqSd0Ub/3XwdInVAn
8ddkE5RUOFkHA+UoJtuJn3aHtny7mF8N0SSo+IHX3DaoApJTLDQDcnqirndHzKuqY+50jEWWVYkw
aakGVVwUrqcNZGnrGdijVlvgaAWPnRsSjzMgAi4rdSlMVMzKaDVi3nAV46Sbpipxn2bX9bL6HXES
ox0IxOWyJIOmUiOKa1daWjZKZuOw3s5y7OLXUPJUm9XzDaEyrI3gzRGkt/1oe9oPdx2cZlfHr1ke
HSGU0vTiuibnIb/8UwSQVIc0HhN04Gyz5+PiaxP1UdfOP2bxwTdX/RbhSyOd7cSRnGXsZBzDRStA
g3bd9UHjsUisB/PPB6wKa4dCCInbnr01LbrjAbDyzelLVvU8kEEdPXqAj9QNXVlhTxTWlH4hOflr
ACL9sdJjR2Pzm/uiaR6AeZIV7v1xtszt3RMWdNbQtumeUQl37/JlQ6AFSbVT474t+3sW1LFgiKPG
xIHs9ZKkk6HB90Cq2Sox3hw9t2b/Jr0vhStKBPxPfWZTqoJJg4ji5eseLjWlEjo81w5h/Klt/bqw
J6FPtqKZWsmIKQwwhuIzPQmPaxxF0CdV4hSBgNsCYfA2X7xfLtJ8g0/HfcdTxiu1cWG+H6pCfIpA
7N1UmMnrhc/DOlGJLEZxb8M1I7C1QAzUauCoOwtHBIss1IE22C1iMJ7sm/R3uVxGi363tjO65G3+
xA/8Td/B/tRdz8S8jwZmGokjC6HjT9i+rLI+lSGaqIAGsbcRL+Uy91tLC08ECvn+V/ykMdUYoUXE
NaH1YCCyR2oEtXc5t2hsswQZuBjLNOtn0LwlaZJf+Gv+7u6h398zg2ZYgpc/klOZhzMVoZGxz8oD
IIp75tBSge1fyLVmlBrr+9/5LuaytYWbUeadt/Q62aD9YmTES1ywdSXX3myxqs1PR31QG7TKuGTE
G9pbtFDnWN2AyFcWEUYXzLaUWqdtO+18YkBU45gjE852TaWZxU5et7uLlKUVKAtnpPsnLQ2Ii6xP
0py7cQoCjT5Y8RNHPFAFob76p5nCKc1W89tA750QuaGDuKV5hyOCOHkEWome3XL68UUTkP/zW9RY
rcg1TGNPrLKyblBfxuy/iRoxU4Et1Px6TRRaBSq+xg2aaGbOAS0qZtRU8EpL8hRJFx7snsUR4HHR
JVYXY9Ua0PL9iE4Ds/+vKYOjCDpjSDIdxiLfpQscq4brySXsKpBVsyhA2OzEYIpSx0NuEl7rqs9l
zu1n2f9s93In4UxMtob01l75wZ/Nv6sswQcWCmVDKLcHZHOMhqyKAue9fNnEyigIWaLhNV58PDNT
DIlcH7H0/53DDdhzhU/UYZYINEhm7XR5gljBAKMFTV3EWbuH8TZKjexSFYJOLXEuvIC895wp481M
AXgAo5u/65G6YEJMqLUYtNRmBuTsq79s03OMA9548VE760sLRem9+DHArMVubLMsNyiokC42vFvz
4k5SfGmJSfMIngaXPaqGk5bSt7ZkXsGultB4DRMu/7+x9baYzjsB3eLwBlIXk8gBcgUCGIZpPD4M
GLtc8f/Q+9EHGqTwz/mkKtgoohnZTyQ6ACE+E2XDRW3QM6sJ5/VlbXK2hAz/oCVagkjqr6ZJQdFf
Gq9r0h9O3bB7rlgMNQwnkeERun68tH0yLrcE37Euyfaa8ny3x97eRrLOJkg7cVXZ5Z7JCwpwIC72
IjcqhasoSbsbYiVLN6qU7+Q6ms1/j1RbAYi0MNfDtNQZZEeGXdoS6bFbQ7E12UjoVPY+h784/fIm
mme+ClUWslBbbfnF01O6kx6/QQKXIpWS97y8vNTHE6WH6HOjz97F5TcE48JZf/xOdvebhL7k3088
fDNLrB1R3GSY3AsvOTOnuodScZOWVv6ijbWBC2i/Tba9Lvi69up+P0sTgaycHIjDRAd21a0+DF/Q
bKHb1oaKetIo2O1oY7DdCUBRVslBGDjbV25xuXjdu7dIBKx/E4w66sK6WvdNopMXu5Ckt3b+dHSJ
LSNRWPP977535S/5wWnhcBc8fSFke8N937Z6UVg1Qh8kCVMQvbNmqsj/b81u3yBKeKEFSvYwFY3c
+3Fcbf3t253brFjB6fjUsZOcEXmXT5+h7xi8u7TXrmfblxsO1yrM5j9hkCmsWcYmRjkfyn2Phb+9
zaus4SHrO4/GO2phtOhggPQ4Km7xoPpVa3D1WH505ndRFBGJLUbQyzQNIaPmsVTMfESw3NpaRZzJ
omymKDET4AZEoTD1ibQPQDSN8JqCfZ6YthyIzT34cwXxGCVG1gDZloK6VX3ZdCQbecrP6I5NFo3e
mzuj3+QSC/5Fo8M7xOC8hMyaSvPJ/X4M/ek1K00j0xe1Id+tm2hxhBxItdjLjVYqlKS/9jTvrqJO
kY3+nL2pXhLprD9Htv/NtNQGNDoBa14zXJPrnLOcWsgo6DXErpJ3CT+r+NLxdKbaPgtimROAGgM+
TSf3I9WKPCPQZ+3raWG0RwlNFkqJapxWi5K3BPT1RR8cYC8FXNpC7vwD1kYGTfZrvuSIWHgs44gV
kEdyZ01190Mtn2Hz1soca3v/VYclK4SFmJ/uXcoQeVdr9/+HCV1QZM6nX5NcYL2KnL2FdypjLdM2
1fR0Z5xL+eo1MULPCWYAY21Nw52g9cSFmPKR0gn3UKM4XniH4GLYE9vUugmgP48G1aVvP2TPz0+8
OYkqdYbYG2BJX5QlScj7LAZNNNzsYBzxNm7wfLPOw1W5TIe6ucqjmBN089MqFlXtcqNJCtB7XDn5
I8oOBj9V9p2NUJB04YehOY2ts6wRPIqHNwoSda/oRI7Wss7CWDoDk6xuF40ej2L/itbtrOVdEdMF
eelOkDFPy7BIJPkQJhllH1AQ2dSWklX0FbmvQZLBQiUcciDlpnB/w+EKCu38iLimUM+1e8LLNW4a
HXLMMwu6itnRpqT0fHSmik2UcABDlYL4GZ1AmEvUsvUjL+SqRht1bZYmgy9KuqSLouK39nnBYoNi
hegGhotxRAKu6skDOY8eTY401DWxIU4+ksW1Eg/+Q+qaQ0mTAVIeXSbDp2lOze4YUrJoXgc/jskI
X4BhlONr13G8yX+k85vdfJqM5bcZ42a6w5bZ2+CDYFgfYdUIl/AIA3O5/qyDzyL52TZHZA3mPTXu
U0gAEpwEOydnGntjINuPoeFOnoVhDEkvxESsD2rdCVGZTEMibOauWruKT6qRIXdqWkCVjFZxzcqF
ZxDUPMaEXXKQWjONtGEb/CnOIPTxXFxUlMcqoPmhnqmetUGmIkG0PRmJlCma45v2KkbFHy5p8EH4
PGrrUtzQo8OFd40l4YXcwFYgp/DVOSt09rIdJ3N+2/lCB3eTaNfFVf+z3pzscmq2YpFpW1NEqJ9j
lQ4lIOW3ytfmSQsDEXpgXaVdJFV/0MkGN28zaBHb7F8+19w6cl/dYwvjO0Bv2ZY5ZVFJRF/vnuR9
KMNG58oAjB5mnxM1i2RZCpHAF/Pq8q/pHyR1mZwcAIfgTbU4nZx4JfP2QCPqAHF0IcHHIhToSLHS
BKby5JJIXShr9DSBXN9W+1798SpQNL+cAe6/TEQthvSAjdwJfhNfMThzuhsuuEL9u6FE/J6dNh5o
JZk4lI98oH0yG76aky675WCELtQ8kklWIeQAWgoK6O55L1E3dWygsM08KbgAcdyuZ1Wt8N3s3b8t
vARvs6/Bq6PA+ej1a1kbzvdP4TPIRlc7kZY10jKiOwNDQ8EYqc7mpLlExE/GY5ptcqe5Iw3jZCi2
gEetBxYjnFGJBYrv4MA+RDB4NYidFP0kPklBRuEHvLu+3gthrKKpDRfB/24lRi4oYmNklRrBTB8Z
5bpp3HhBIK9qK2vm6cxY6L7g/y3mBTZj74f6rf7RUM6Fn/sFGEVt8VFJYVvXyU8Wg0Vtsu3qY5EB
F7Gl0rnFhSY/bFYeR3bXe7nrBmwg3aDliiL+NorJI52lvMlrXmINVbkpxVYgHz52SuuGIs/Z3M4W
EJGw7EMz2Z3d2QjifT2PWF6g7UoupnW0b7WAYoi7YdpxADuTkdFJpR7fgm/4HH0ONFAxDNYDxfpd
2NuQNmjsiF49dDbHcOhthvJosDg3tCdRG4AGcy969JOPt92LY7VDY+XFXWeQfUS+9AYz80LMFOV8
CaFFySv7my2H6u/Z40GZ+rGsmAhQqb3Xa5FDFLU96PuBhasImMS+j24nSIDY1Z6O82NBkuujLCDR
wKQHVLvzrxiPsx+vEaYrkyjdPeui6wwsNEawpkBQAHP7aMrymIMm9Tdp5IAEVoteJgrvOOCiDIc4
HT0q5CNVqNcWKAUf2aMxPKdZzq8Ymf90YfN6u8Eoy46SkzXuRDQY52uY3AAJlsZ2CfNV4Rf2WqPs
sIsVEZkvLfkkLsDuxSGezxWf/UWZIAqDaS72Q3DG/MRb3z/2NaoLt0LYmlsCfeiYVRsZ6RjNhCmT
hpNmCDmum6OO1A9l4X7RBN1BfSvJ/z4p1aWHLQhwqQGkKaXwk+K0tWSxuOgi0HE7Kp2vAKPcbshP
VnT53Cy7uOaVNV3jc8JXvLXtN3txaah0qEvvqAH9qarGCvcQ3O7lWg78zMPPrx+KxCjGIwpBz/L/
MvYPWHRNmmemzGFCu3dQ27OlXQGlvZQmsZfmm0pPDcEjUmuRm+BtR8QOdDi9qR77NKmyJSmICp0s
WLKNPKFYkWWRSW0saa9oBsNOfYRySkEoYusyj6pLQmZF4CR+FI/ToYiz16T3WYzsQbQE0gpLfOq7
WTEza9NALz1vrWxQetTXrjdTpvW0hRj2DLU1yuzLFaN25JfPZueR6c5uSpjuFHAO2Ux6hfcFTc2r
rxuCttfp48bhzmAPym2ZHJ4AX5YrRHxecxVTmigZ4XObBghrNOajmnBM0DtUI9qMZho/EFuHKc6I
0HTQu+4sm0c/sWVF6UwyxaWukQkxRanDYiBjOvnRdoQJN0uAmvxD8Hl3B44eDKxse7wRu7yvEERf
qKp3XwMxQnB93ZkPYPuDKrTd53IgFs+CCUwx1NLzmPayr0j2iNOgoijOh22mR0AxgCUzWrLoKuiU
Q9h7QkMhzcS0k8wOcywjv0eB1OpFB/gCAO7OEHEW3cf8LaJgRo0uvMRXKEs59VGH2U3fw0HO89tw
ema3f2RTH2R+f8tM1RxIWzKahDBvQliyKF3K/5aaLIW346GIQKuNLNvUL8Pu/cikxIUNo8EO/aKQ
zlWWpMOU8rnR3qKkJX1I9PVZS1fSWeq+fVlJmm+JRRQEPk67aW+osbj4Isz69jwsVYSn7NvDUuUr
YKu32ruCJJi18mTsk98jcTbaMHcQB3TYBjmgWUhN5LxKo1R4ec2snHt2iZVSUxhC4oM2ts0jq/nZ
pcHGmySbRHGVpYUI5+qm1JkwQdGe+KbwZHs5NiIoW0QFtgPpfZTlimd898qZF7bHZ+ktL9pzqR9K
HCKdKIobsBvTMB8NEctK+VzcdSAjMVbGXKHKMv3xw4temCVI6IedhM3YxUXrRZNb0ZO1SQ6em0RY
lzihkTN21r8KCuTgYCYYeuxD+rT4u50CriiVtMR9F+4K+wLdh+HO73hcesxswAMn8PqLXghFRySF
qg6j/ITRajkMWaB/EpXuubmqXXuasS61RTkJQ5iq236weCuLLMED/401gRexuBiyRTRIO7c9mjmr
55BkgAC1ViKSA15kiBF5ankAYIr70S7+hhcWg5UAfwW0NumYe2E6cEqIl3vJux+xiWIEGIz07RJQ
tGcWklECe4SdfpqgG8MVDgu2RmfQGad6KtnprGRbTfsAao7OS2fp6y5J7c7S1xp98mv5rIKtKdRH
QZBANwUir8SXISPoUT5kXaRqY9+ZhwwSfTMQQV25Le+DF6snppEV8q4P8fWJgV7nttDCc2peRmiw
QKBtnOKSjwyQuBSVdIXKR9wRuJJTrrZ5FbRuuukLV5dTQmTN+Pd7hUN4idaIZIRowAqgM1tAstPS
86Cqu+QQZ9hWL1AoIRog+REwLFXORQeSFgd4F5V9JXSccCRukTwdy3lGZZtZ/Xw7EaQKBfQfICQu
r6s3xFAKxaZFbkincA77nqe6Qta3FV8L2/lbn22c2LL/DAn3KhttrkMjziOlbW4LDK1hC/CQIYjY
EKPVJuUAnv12Y5SWVztq6BmD5L2wlUKVbsXLnc4oMeMwgPuyLkF6ufsywaB+VEdZqDjO7uXEnxLL
btRVNSrGCyOXRKaC3x0TylWn2H9vJQIPeNIbguZyr3emLiagJooKu/aFf6pp/oeO1PtVjGs9UHOQ
GT7LKuHAYOxC5SutO+TE2ttTZ0o9VX43ABcLys4j5zAoTWiDebVCvVctiSJRnONKjeA/lrfmNWHZ
LmEaIrtdjDLv5mYlH96kx6/7jnH72w8fWBk0ku7brC5ZDMkpc2Pv9fZteEjI/zD0jYmfJXhcp+/4
L3NVYk4oBYRH1Yr5ppF8pqQByMfxJnH8wRb8IcvRCW4XFJXwq1BeCl0hXL5NwHsLnBfDNtq+0w1g
ALvOS4BTk64QJK9nRxw+gmxDWqc94oPL0LlJAa955h7FK5Lmw1B1v1YsMpLejKcGftF9nT9Jq1a8
bMLpnbboqXj6uaIOG4Nub5/y85TFeDfJuBkNSwgRUliboREjo8Z+3vc+VaBZtQwJIEyjyaHm07yy
pgekX756fW5A2Ihxx40DM4DrvhjPmCXFJ5E8lJKUyZqSiSHNep1qKMUQuXnOuJv5iBR7EHhkL6FX
6KTtCWj9p0TWUWaD+spZA8S9eq1oDI5efF/S8xV/b6uzEeUkqIvZ2G5ey37ZiMixTLXbw1Pwl6rS
5nvcLxGV9EzrTRdyiyAsb5jKmtU3TG7I7VqjjnOvJk0OVyFCT46VRe7TSpKfwCWmi00Np6Eo8QjU
sDEVStO+8deS8b8ZWY/Zwg27YZ91/fT94PKyd3rkNVCSSNDw2+Lx0eaZwTLyzQREPodGUI2KbLRL
MakqGE/EzRRK+3bF1U8Lr9GUh9VZImc7RHVhi/tbR3UrSI/2KfkCvQCHImGPzIsXkgh6NRUjjmWG
eUEwiffUXPeKmZ4/IRdMuQh89PBoId6gWtqug96SJBxIJBag+kKfDmz8hsVeNeWF3/1vddADXpIO
At9TTdLkqwtsXKJa8b+OWRiWKcripiz9oChMZvSgF6ecJe3Lru5A3qmDCiYcECAjMupr6cRZ25Wl
EMuONZXWpsheK+RPMXIDvRWaxEQotOFG/24zM5obgW0+FCYOFqfSAZwiC/xNDbkDMwMFO3qxgzCB
fqB4RVsvAhoEtvDihPiYEMBs3KZV6yr0+l2efXCOmDqmN8tlysOrJojYRVzQeOqJLzleMcbL8SSD
wr/HfSsnKhQ3CY0cAXoD3Se8PcRB8/kMk5u5YJHfGyA5a82AHJRZDqMsxGCaJqcUybk/MDPP/ofJ
X5t5MWR/D48fV7junORtOmdWrTYWbl+NSXacNExmph9CIuHH7WX3poqtIQT3vEhRPwbkCSohcMFP
7WoRdduMEG+MAzFLbqWF/kngbVS6Qg8ALA1LgVZFx2/MUWb8kpI3YaXtkp9aYwZTJgbANNq4aMOA
ewgQV9/HrqAJ+mS4XFSjDpmlpHFibpsCcfTz08AI73VWdHKT17jk1TdK+XT7f0ZfvaVZrkmPoP7t
N0n1bP4KN6Gdqwoam59mwpQhZlcEdrmQWpVixCRrpwgTlILBjqXukxI9XzLuUIKSSddpcnj/+2qm
MLpOgTHQ17pMrzoT5I2BUz/ZvTBd8AophWfCbw8ACUt7oUpAxFTnLj4i+PwhzKsPQbT9k9G8MiL4
cg22TsZ65EEbHwd74fSArDj1WUbzMgLjSln8e0Eo7J2lDw6xjQFJaKJjt4KDnCMcE9QGNGOt3F5A
vlgoIomEAGKnS1yBDKEHl5Q/kxOCWkdaOUSlsytMHO+d+8B6nB5Y9K4KJUNoZBhpZmQnpayqR9UD
CTcvDsThFu/o3sVwX2zAfe7+30p0HvCaJyKbLnt36UNzClZc3Qo0vGje0G6pd6GcTq7v2oogK+Ok
UlapQIqqXBQmEKqsjhYHK1JigkFQQq7Nk8aopWzCKPTtV9m88Wu9TmwB2UpkK2UX2kzs2X/hhrJy
d3705txGdyxdsu6scNVvmWhlNlPUsNhJyU1lMRRBTjFqZQtiqg764+uUxh068ikEjgK4uE+zNxwB
Y/B/QuDttOhEXdYh+GlAF1diO/tgJ4WsxmTesdcUxUtBe4hmzLr3bBgOddXucVK0+D/rik0dEBsd
8xYK8OG/2N9iabsU3hDBA+b6UCPTBpPQNSvKqoS2BrbOqpNLG+LQa12ev8BFNuh/vXPQm/lRD8B2
bxQtvvgTJucmvXZ5HQv1X0aGPI+osOd1n2D/6IJl7p9ScvVk7WFAs4SRhJ/LhzzuQCwNn6T87RjV
yfO8AIRl72FirqtwGKUiu2LvlSG/1yC5+baog4OXHw5OqCC4/k8gIrgkC+yKnr68RlF8LBmWeUok
vD2N3qh4qmu7sKlrTj+IChvvL468Rnl9tVEjRYFm2PtVgE+v4yLzUWTOCQfjT/jJM3iFUjIKnF5I
QBMFk+B9yrrlyhQrboXhYCBvOMI8U2uuBtf6/U9pUlDRae4hyHdA67EnKzf0ZgAr66JBi0jLclJB
4HVJC4qlF2tOwfPxvJEarvCROncLWupzQR6ipMPWLcspvSBomTif+P28wgRqZLlrfOQmu13hfajE
z1ynqRLWJIbBt9vEqFHvqZXJwGVbRDWrm2ZiXvMusvMhCuEkDg+8iy47UzTnV1ImQpZF3UovvNLn
0ik5QiF8DCd3xzHcNbYI8dlm7zEn9RPN9MWh5XwZ9SIvnSIvCzbTma614BQKyeyfr4zZfQuaH/G9
bTfTvW2eb/tACCrJg7dbqbeCsTPhhUxLWLk+8xXCNPd2YHkE80G1LkgM29n+PNTHkHtzEDJIR8GX
6/I1Q2p3qgaD58rPUbIyYOko6ZXxSiHOT2OizNdCbxv9IbUdowNPvq8QsxJ4a6HoQYaL/8+X02pK
3MeRPWLZXTxhw09Tk9WK5FG3byEWdEVsIxho/tyO3qGkXVkQ6I7klnhyVmCphe+AtqA/bo7Yo68Q
LhV7QeEKim6etZvFmko62Jw1DatgyJ7Swlw+YyqjJhBXgYSOt2ALN3FO5falcqd8B/iSUfqwRHKQ
Q/GKmg3IvuC7mesBN6ep/+SWufgSlRz00ThATUgIct3roee803GNgtE345e41fRIn3bcxpfGSzDm
6GwoESjap0sRiFSsqnDWigkGRpiTTE8V/sMX0+D3yGCvOiInM43jsC7AEz5yznDtXZ1RWsiVUV1L
XO4xJw533LfnI9FDwRkqVPEdK2LtNJuXRS26UOyHTFOk0Wv/MOCFfSRbp3IOQanqZguD+OMW91rW
ydK+RhIiy5qciKWXJwk5X4NhD6wOtMjoMf+yR0pGz26Ox5bmZVsScTCrOt9unCuBrQteKYDyquhO
9ZGxr1GTDYjXAwajyqP/TfXzVY4M+lZSbAOgAHSKHDEX92vQpYcSHyEkEy0B+qIxZ36dAnDejZZj
LT85o/6AyNO+0GfpGkjZEwL7mGTQCrG+7z71mQDgozvl71EB+PW8XrDdrVPpCKgIbjclT7e65HyP
6ehtKb7IUkdp3Iw1bKv5yBIFgVifuIAAWZ8WkRS4XohQBcA+Gpu5VPCRigLTTNoM7unRusHgn8Tx
cTMQ2B4lLZA93O2/PHtXQEUPkzgS4QQlvndm9BfajgAyEJtCnojGw2bcAHLjik3y5Jz6/y7Y0miQ
ib+7liqVrW2Zso5L+fAyUeFkSalYPSm0MlVxtmU/uq2QsrWrxuN5N3p+tuGhh74tAkUJfw9+CANp
vQsfyrDybWQsnt5cb1XXcFcRHkIAYWiGowbtF1/Ji6UOGJt7PZjIBvNqonO+zLQT8gyuzLP4N8CX
lvEtr0+GmnCU+xs+NtCYwVbc9dxECbrcbZ8E++YkiFKpV3KYubiPup0tvj+Xr3Bql5Bi7WgkGWaP
dVACOXw7zmm8YxZbonDlLxadCrnwB0ORrl4fccyWjzC53f87tdOYZ7XOa15asLQGZDa7SS/1qu60
tkixFN7Vn6DEKhZii30qgBk+VNDuTL4Om0+G35EtdaSTemzhUBSA5znRiOaCXvmczPy3o5hK146H
pNfvuKxxvtrgPz7iocG9jEepl3U7PcAlBJCxwGOoiLgw3ZXKGWN3yKwhrSqbVc0mLLapqsOm+C4P
7RSRri7xexogF0QWgTrL26xUSdaxPIKvXbinm89AQzX0UoX+lb1FsfAeO3rJKlpcXML3mJrhxCQc
at/wMTnJTNetf8NiYSo6lBlE7vmNDLPwWXttP7nlPMRN5ZTSkdJMfEuOjXbmd6IyKv7Dm48mgkkg
+PxYr3G1EXcXmNuOq+TMVaYwM5kifeKCo5h6vrUFFDXTD35hpf5r1oKfzLBDKYtcPSq0xjVU2Gs/
TNYTtpppX31uVILqcx83zZU1VRJCnKwd76EpOJJCLB7xL+GOeV8pCU2Nm+W9QCGlbKXecYFWAUgJ
6k/KtWKmVmTM6Hvd2//RbneqTIOjN4Xe6U7lWN9NTDgK0wXw2bNHZ2Evf38LnmnQiZMxFKN6EU28
66pjyC6xxzBHUDg69lVuewUyQR89dqvDs+L39jhOw4cMOGLwci6tkb1Jl+PccpzEm7kKqDS3joac
+fBFFqOAZ0QYJWWApzif9AaMT24Xw+Cs+6X/dnhcKHaeqfTGl2kH4cGi+tYMgbbalW6PTO1bPD7B
hHJC+d+a9M+mB13HVATxeZAjNVuU7e3ACN/ywSpChM+VVRIbNKbcfYCLb9ID38vm7tzLoGJec3vs
4X0tIimESE9ytm7/yHxllzm8VfoMJaLBr3BjMxc2Zod14ok5evtswfhTEuGogPoUIinAm0Yb+w2t
S3/J9CBHwfdej97jOL5b1oTJiLVCy6aFhuh5ogvfCMY0NKUfKBrhXEU9gkAAVo54KbWQRy5tbKw4
nLwAP9z280b5n6Z7skhZ+PtaiMIijITJO9RaduUE+w9ZQ8fajPcfwHqAMYall7uUY+xe+10gKZgI
/MgXFvgT1mLbCSWs+3JfdQUViUYG+U3xEYrgBSOgqnI+56HT+OORAVM6WusisCirfvHvcXC76pQO
Yjmx97oomM0AT4YqlfLlYk1G5f4GDH8OX0GZcLBgTxssOWUqGbnIgyXuB8zwUUEyv5BPZ5RCN+NB
NNgpKnWBiagyOqK51ASi6HJbKktqO1cG2q1+73DgL2OY+/K4M6/wDYjtLdfatpSLCEP6xPWruKAf
nI/Gz2FM4gUY99PhlgcK87HO8ZFDNE4bFTsATSWl4SOZeNDRx9M6T/FJ2cotfclcLycN3V2/QIsn
FksXncJsKKDyZspIQE5SrRgI4o67JN63yJrvnlmuRzx8cs9hSUlRcerqCW2dUp9YFRya0BR5Lj2t
WUNdUSzLTxjI5IMLPnJtaHa8/Md9H+X8Rdl+85htEvReIhgK1bbVZEYZX3TzF/zF8FWfUqTK4S23
K0wbbjHM8dXhgDNgS5xoPMTVoJ/gZvHGdmQcvEQY/AbO2pv+0henLPhbH4sS7nAwyDhf5MTQygdE
LHw05bLYPvHkcjuSEnhh95b6+bF6uOlrn8XIq+fN+uZBvoNzYmpPQYYbf2lrZ6qXZm0gEaf7m5XW
4TeJ0nuwbNHKSJi28+HcIkjGFVHEYOXwroIgI9sgpZyo6ZF/mgPW+yuN8Iqa5BO+OdiXARKSAYVO
rtNhvBVbIDrVGC4v4r1TJhaJiZcCphj72SfBZGWrRQbGrLcBB8/H5RYpthk4LoJAtuZ85zdevR3O
JlclG5XczXGvUiNRGyI3t90iWwdSfwFD28sw+VQqjvhWe/HUGKGz5au8JgbikoYNQYL2sQI0U1RT
7La4vY2p9v6yv/S6Nf/CugXpm/GN98/E3YhKXVnBYVdToYhIB5aIhuzMpAApQGxrGtekR+I7Xq1J
LV5RTxqnvpDWT3PYp5q98dC40aOVHun/XL8iMTuBYJLNtxYZmC1OCz17pjQYjCMBW4mjMeaATlDy
C1qPdSpa+FJlNNUVK78lO427MjJjg9uXMNm3+7t+NOou+OHrXjk8Ac7jdWnKvr/Fc+8RWJkjkEtr
4xXNUanzogogoW6DskFnk/TtZKx78fssjYPJ6dLo3RZsCiCMfYFahzDLz7Pe8SZtlxG4cfG2Pk+2
+oHnPVetvBN7PnS7xekea4UOwwKqlbrlfxYknagk4OaNrU6cgHhVy+LMueyRo0LuEyeG6pzg45vY
ouTDEGOvKvMpnOkXXzaZKiQGbnmhGOwXgUByz0UWOJ1aKaeGsCjUCJP3RK8frHDb2VCedC8DU0fn
01mkfsniAYDAZg/4DxuWcTiUUN7UBoT6kBdwgW7sisbsl5cDxSoeQsl+NYhGLY4k3Tq8WMmoonE9
BJmQbFp67ln94nLUmzqrlbQYiHFmCExjeArFYwIHxj/bLMEjyO0IrOi96vSarEk3+7c18GSFD0Y4
07siXRsHSHgdtTNk7/ibriyiQB/IgmCJEGBhwUNZwsp+Y2/9IBcQT2iK+9r7+1ggkgrTzkWxYOJA
oKIeI2CjlTiZ1V0Yy02HY+xcCJwIPAICPD9aWYlWBS4bUiJGX0FnlNkZio6oUVSTtb1hGWx5h0x8
lnZ4yDgLP6/iqoPu2j25vmBKUwcNsw0xNMImjJvx6B6TDa76r+iboGb0iWNfs+eeLDRZFvw3jkx1
q7inemCFZcIB5owpMfOvIbSdvmMUeh9pcMywpc7F/i7GXCw9U84WLAXy3lQS5aCUYGmi4qlDtL7l
0EpoYSEJUgVvEz51Yy3RmapMVABAjLO5fwewJ9S+ZXf5zOfQR+HC0gdMNiHBWpdkl7BMPXQWHlrk
FU+A+3ZJE7eHd3c0FVcaF89XMxfL0/HzpgacjdmUjcsvohA6716zzHoru+E/3ip/aiciNSKVI732
QpwzcWBWoGsUtmYVZOHKWHHtbPqTJNKX0EauHbJapdP2a+DygN8RPWBWET9gILAw7/aMdY4Xf33v
TpQu3CLyMEirDpgsOexAIhqFqlRYtfjaX+m3izTAPZLlkSmW0CE73i14ftq1y9XBmjxhcF7xgc2S
IOXyaEzgM0PzPzjHHMXq5xVQEDfSeeonUCYozVi4mksEmT8Yc/uzFD+j5JuRG2BuAHGDBaS2S295
MtQ+THOB1BPQjEA0imdrpJFdwCfqXHhDavxZ8PIHKzHGIK+ygHG9p3Ozqy4GM0CyYDmHtYNdErEv
pEB4y+lGQgzHHYisZPPo7pYiWhp198sxfLT60W95C8xNj+xuDx15k0QKOeks4hqESl2nVac8JKmv
u33d+/uzh6Ueow4mSl4ZgIE+SXv3DnDLgz7oGk4hbE5mcHjR32W9dRWG5vQ10n3KaiamItmaJKsu
qQqgFt6HcqMv8bMnslS4IqsNCjl6herxC4FltvqbakWu/SMoHG7mq07kXjvk6RL63asmhYIkS3eE
aENdPbuXvvrIEMMWjA+/9JSPvPKbLXN7HwDd1NZ2mxZNW4uKwERauitJQ47RjHLxSsA+Qj1ZAkm0
vk38U3YKFpkQ73rI41YGaiAiXjxX3fKMIbQV/6ilBAijQPqveurev2wRU5rEYl1bCpS6AvpJ0+Jp
kgJoLC/r/TrZYEBR8caqZbg2U6L6+B7BNKNdlHczhoo+oUWgTfHU3UGtzi/sVqWWjkWsMUzEWT14
gzuCwsmwgJSdCel1d6NX2j1u6LDSA4fAhJyu+RRNr4iREg0dNLprRL3ZYauX4AkSJlmgdQz3KcOF
BZA2C8RjebQStme2DRUm8xbsVM9LTQi3qj+AJehy9mVX4acZMqH+7BXm1icxaP5XNnl0cCZ0PPTn
Ayoog8YSBICFKn60amH/9OokfQr2MmNC/oteOQwJfJgrqjmCA+MjLX89SPW7d/pzrl9+aHmAGoIM
wQnlQeTrE1nUZOz9NkHOgm/a1HRFm2ohQMWhgi9niASuNV3/QrSiCGmqxAxZLFKd8YALIMtVWGoE
pTLpPxCl69JeOo+yA7fs/pRuCP7AKMH4xSez7IHdoUN+4kJL/j23QvoRVulkw/8AWCv5Wvj9KfKB
BhrJQtEuAA9HXJ5uPRSysHp344jZkRVt9cmhQUIxQ7GwYuwLeNqnBhMVLhUQ7AWr9vvNoWp/sZam
wc8asbZdM9KBlb8gLLgzzUS9Z2jj/KQmhkMBmJco5Yp8ZDFPxKe+/y2nWPDHeSrp2zMMaOCz6a53
/GulLW1sHew5gfpbi2gZdfCPiOfHTq9dM9qEL0zMnNjw1UPqNPc1tx1qvM9nV2sDzuhzV/Hko/Ig
at/3NK6tGAQmwOxGzCvTxO4H36kPTHFEEXyGynS0XGSN9agdn3DByQ8l638QxMFrUXgXn3VqFtX4
kOaXm+zCBgMT97zidsEfKCLRc+wY9IRaqv50B3RljPzOpd0hkhXHkLuQMua0FtBKMewcdQh33x8L
0zRhnpFV5Ia2S07bivvU+dxnRQyiPfGQzre83/APB0Ngb/pspZkEWacJEN++WtFGSbp3DZDx0HEx
GPtTSz8K6S7ewCr+WNzfNUPNJSgVfY766Qy4vzizQwjAl/DMMiEpWVTJqhCfqk6eko8+X9MVkG9j
J9D3vfiyr2V874Khw/NrbJ4sXxtoqzYplr/PN2l924fZyRnhhoof8Gbp1peRKzfIHOpGTg7Y6gUk
9ed6PD1jCBdpdP0oSep3+K1D2KUkS7LyofV0x8JAaiPEeH6cmTCTNmeCZJZOsTn9JMIb6Q8XOcQ+
X6ZrJGvf8Nworo31m9Ouh84SVFcKQld9uiARBIWnPju26Rd2zAGlAMVJwy5fMFvdiiBl5cq0ea5T
UR/+v7R0skG4W0s8JPli5aYTIu4f794HFZefFXHcUOaMDdlNjahDdhx9u6a/1+HoXM/39r7+XSos
yZWvaNU+MOE5xtbcbxgIiaqeWs/R7aCP1bwAZX144l2blqWlZld8R6v0b60mIDts5gFJ2ceykS5R
mv4ezoCBcvJ3mk4MCxAi2ze1m1N6UXtJh6RFM7kbfqhOnqq4h43p/4L91vtGnMeg/8LfDACJed3O
WceHrgKmDWbQ7OxUUQqIVzT7Zqsz8KqEgMN0q1SiQ7dfbDaqXexQdwLxAwgtSRN10Syeoo4Jf7Nb
b1Tc5NULqX8P7y7AI3iX0OdUHUEouAMFGERueio3omBjyVDT1X1Xb9eznBgp84H8SLRzvX0bTPNh
HcMgvb9g2ZwPc5DM45Eei9jL3cVgGMddspn1H83DVOZAfX05n0+v5jX4C8y+51OhlS6i/ORyJqvy
Ezznj0Dn8e2efYjqwWX0gf1PhD2B1Poku6sRpbbSqc1+5+b6qNHHfHi28xyt6r5vntKwFBH4Mn0k
KLh5oUgen42HB0tvapcBkef/tIvmog0lSFWRvRFVJ8cNwJltU/xj+fK3djRaHn1SYcrsOQUOLBgS
NpnuXU++n+GRfRouP52G5/M2mOF1skuRsOPqOLPaYTQgw9D4xTP71BfmEMgedYI/O8zVdCSwDG1I
Z9J1o9SfoIAmWisefruobT9lzXOMCVirDvBu2utrhxl7pVjurMahOr3KeN0rmjpXp9MNI9Iv4LYZ
GNQYQev+FHdgmvHkcPUMyg8+D49JxAJrAnQLw9TDH3rqxfpAyrgZLNyXiHk2S51HbwvU/mYZdtcp
h7ffL7pXcb5Il+sJxlJ9mQMmfweJw1WAU8UJYOO7Smk0bAh1eJ4x3cm1tEgVPM/oQJ8KN0K3otcg
2EZVZNdmJzeYcDdvNoUGT76JHEZRjqVKT+vWxrJOBGQPdAJaRf6QY8FPtrnUen1R/6uSL5rnp3bs
yEpVOoPlL+jzLdRZ6oJl84nPesKTUtkjcCxnqgFe/Bjjtolo1iSbVwKDKElAmKED5esuWQaWvR2O
tpRaJ42wdfRLF87ODBNDhWL64Qx836Aj65XCvVhuhsvgINbB0ZycfCQoDg2ZmGq6XzEvNobJgUFw
XQPU1o0qA2dHdkNj8Shkp5tC2A47o7dvYWzYzIzUSY0WGCcYKiQuiiLsOu/s+XRyhfYpAMSb+oLf
RhepX9jnJd/hxXIRop+4ayH60l/4UHC5lowy1DGDzEfEc8jjnhKwG3/O9VJnfQjLchqhJZDo8EiI
Cw9MMOg+Yn51nmsBwcB0IacjOLQPNKeXPbduzB3EX0JTMG9pEWqCfFx0cAE9G6KDb8WDUk+604OY
Hwq2UC83CXZ6hTxex7zXOWfUhGc8GCNeZYeMmiTD5zJvWH63m1AgqjVJDdY0YwcgRpibMvpxqsR6
J/Qh60fuQiUE7121dyAwBOI3FZl9w8nIubbTmnvundfei1GcLK7IJ0LzF0S1ze6E0iWJ1t5ZQQWH
7Lo0iXiQorFUqhBfAOSgBbBYFOpBf66Bl4IYRrV0k1hBuQc/UWGQyInQGS8GgHGe8cJ8+s8pjdvU
KfiwzCN1zIZ75IRwpCcWzUpW6D6JS0FPdz9zbsI+IBxXzSeZhAd/wZ5JGN82g9ChP0d3hYLCoCnk
K/96kxmZM/YDRx/pDsIByETDd4bu00WwBep+CIsfDwFPR+e7Pop6j01IdqO8jV4JPsoa6NuKSLa5
I39Lp25OJQOap/Uj3jaPdNE2PkdfKVNd6jgWRNuaAGUCcTjVdac4+sxwt2KFtUZTA9PcAuK9Qy+6
sbmTvxt9tIWcavWMbn5fyL3s91mbN+aRvDJqKsQpO0VkEpxx8xk6WAtBJ9+GT3xrgzOxwYyeM6W+
6k10eOiRHSo+OrWAsIdlkQd4zE0iTtdwEwgY9Ty/I8jGsha9oXGQLISzT5/loxUP5WP2K9sxWqP8
kUHsRYhAyx3L+awbZg/luUFADgd+kXGaRpJ6EaZncNn74EP9MOaPes3iHlzOJnUx8AezXpGJG5Dw
MZFByerB/sTZhxPOohAQALCrnuM9vxdTUHT74pVAeq7XYj60PMhRDOwW7lElXXmiJqlEGfUR0OwK
eVqS5ad7vZk5BK3hVUSm40hKyYP0PROvJkK3Ce7ZVYNQjOxmQx3NeNVj94l1HUicqIe9x4eMSHz8
p7gH3sLfcR3H7piyxFzPMdtQeX3sjUci2+9enjx/z13m7E1r7FRSXRJzLzJdcPPjPJLxp65sdJrW
fYHfpKsFRVpTIWBVuz6iUSTU0wNnLCRudntYn6yT/jWsZO49hGLhwPtJwWbsOIZT1hIaft33hGWw
mKwOplMkwJlx1i7gHpl6nL6eTKwiImjAfvdG9NslAkXgHpNTzLxJyxv4n7QxOezlL/ZRPpNwO8Gb
P2HIYzo5bg8AvYCu5m2voMYav+aBUNi1R4651aftvCCKD8WCealxAc2MBks87ILKzOYJkqTj5fNI
De4X9qY2yUQTXk21tr7/8U5i0+4TkWh7nZzauJV7Z0SE0sYoC3TxMW/rXD8yaas1l2Mp4A7C2wQb
GJg1rTNLbW83PbQhA9Zdm8b8aHTZxkZyrBQh4uiyPfHkVNka9xHHy0/OCX4Zz1ja8+ssSfeEUttr
Ry5OggF58/LP16ZcZuSJBURPMVK/x/hrK/OnMH8zI8T+avAqwQXlu34pKz2bjVGZFYFxzOxv3ZFK
434YFo/7IJFyoW8JxyAL32OnrihwAxq0hSIcjbryqnC+tD9XjSMOhjSchE8Uhwm8E2POILlx7KNL
DREB4tXRYSsFJgCiBO4d4+0UzT86mYG2Tys1pp3oNt5H3ZW3q5rh4jsHxBjwLW74TE80mCmWyUiz
4eyWlz7XJrXlBlAOw1YMz/c0gMjld7haor4cbBlW3kKBJdBmNekdzPWajQJDwLuPKUl6BrKFbkkY
SxQ2bTypNosinvBxO7dYZxTHQpADhY8skIc2cieIx+bYd+inrbcq56CYXQE9o1Noe7K0b/yBBkxc
cS030D885G8YMDV97A8rNFU4YfU07Ncy4nDNal2fpI8+jRpf4+OxdOniQpthOMp9FFE0LEIILfbO
e1R3fBl6/rvddLyTCyK6xZkDw+VRR/Jaq0/4vsrS2qWZIo/doe4SooT98txKz/BxWs3Kwnn1bXLi
Y7UfmjU9bF/fWOegiS0PGIh1MIKSB62RK9r/kmsJvzs5y+jVcbsp4VjEmV2ZNugnotOQVMVRn8Jd
zzDcMjY10lenPJgMPA69Ii7u0EiEurl9Hz/VkEqjUzRprRUU5FEeBUWU9sxl43H03ektaKkW+zAu
vop3gZR50KlWsfYidKZ49LKZuN6limQTwuU9xDO4Z8yzbg3a0dQvLtAPmn4IE6OxYPEdjxJPHXon
h+wsz6LZf9ko2a2YmxMpfR7VWdV/ZCHZUBZfhteXcpT8Ta2FW+QJ8YJPavmgCiRCzjz9ZRC8V2ax
MUAbBp4hkpT7188HBANNHFAqH/HKXowm1Os9k9NF9uKef4yLVuwGoCHbZRGxCf8XhpbIzf+LGaEL
ZDuMkse5kneHWBvARsZ9VuURhlYLFvL0ONuAyf5umbWLh1Qb2SzPJcunVsdeX+mSvOvG8dJfCQSv
1+KDcy1g4r3xolAbSqs8k+rRc3QjSH+qAvdUzVKpbBsh7g6hZXY/vV/z9qXX3FYb6bKCzQrY926l
IwC6U3OOyM5wfumY8U3xmf3DRgRu5lQ2c6g4MuLQUSpEwwnJv5AASeHH511nUHD/DFdrswxTFHQN
LExDAUWmFkkMAekAhtpNjVhusENry7JzfxI/bJ6tw5sCcTUEudeDoqZa+d2fWdWTBO8oUiVicWMB
0n0JgCpPT6YyCVgCFz2OnFmGVja1L/G52a9dm0UdiD1XgTKZSUikzj6JOrKnyXH3Omsnyp9gGueN
W+pLf+HqGgwYYGn3O9rh8HK7KRtFDQdbs672M/ur/9nOi+uNSrDQTS+tq48kFfIaQANX9NKcZJ0e
SF0KKMwqcZk6XNdzwYvRJ6/EtUzMPuE/qM6YXyrSUS5XEJyNnqdD/EvyzSWWzxgQC8ptyj7ma+Di
ENmFUock5vnS5s+iYYy+e16nrFU6DYJcs+uzwUmrSQZ9/r6msO4THncEG/4l0BChbQdBEYejUNsi
ertyI8jyW/8vntMWMBF1Oc1d0NqyA9Qp40LmPH6aBAeCj4jZ14D98+oNFHBWZhvnfxgBUVpqeghu
SusLDm4R6S/YaKf3d1/HwSgypZhOroW/JMXh7nI9RrQRAynfsXR4Wq5wlnpP7/1SUZzE4nYaKWCG
yzqU1zqhZGgv+uGJuNpVYUuvWLlRmWouk5+jZ+kmuzCG4CCDIefHcpgkXj9UQxcYjagjUp1iG3FW
K7Qj4xp+PnHmnSptTfRjtlLr+O//XVGJfv2BrQwGqnKObauo7/XcGg55GAAzMhPkLbCCMFMqXJ5K
fpyWsOcbVKKOwKuPYkJoYTryOz7V581o9nnHqXOsbmvFflGvCDyM4Lsodb4SELjXjpFeTsEUQUc7
io6sZcAtAEBzbY0LQA38ZTtmzXVibmJAu659WpelxgRZNeZMWJ0Rb/TVGg/gU7V6lA5aMcumw3GO
IinmRsYdj4X24YEp4sFlFXDvhaO4ad4w7z3KmaAXok3iddkXFRCpEAs1z+Vvbqjs+ooYxxNGJTlr
SA0KiCjoCzSdeXlTc1gMLs9CIfDgLmvndhse2DqpVk/qEQdvrMkIe+ZVDOcqsM6A3zNoQS9Zxakh
SXc2DLQJNOeKD5Kh7QXsQBy7jzonKuzZ1MQGglCu9s3J33pWCdQ1fAgr43Fa/NZqtZeEMbXtROHT
cVWpz3shUEVqHkq+e/Siz8xJFlu2i3qyUPk1juITUcgOEYDG1cNOF6jp5toew3IWIqZfQIOzNN/8
H6P++Kw+p9+ayqQnrcLbXKvGrLWW9SWH+3CV94r6vAktO3swSyzpUBUMjluzVc2TtlWmTiILdCPZ
SkcR2oyXArt8aLjsOlQ3QGSqcliSHVCxbpMP330H5fo4RtMFnvxusTjAJ6uU2Jnteqq5x2ibb4Vl
3DWPqFczAXW6oMdoQvkCdKLVJdtv9BoV/B98reHKLceBqq2UEOljSDWxblCdd9KUUrjsjew5wRoO
IDQ29BKIGDSmOF2QuNEsBxlyAEp/3AhvHS5VdqEvUsUdskZZGKzOI9/JknQFirU+WqD3ktD4OPfg
Et/jXa23Eom1o5ilD1IYFWTvUdn5CwohHzGn4smCQ55GGcTdO7agp+0TxIa2eXaXVdbxOCYPICFm
7okPEWZ5Y70oGEoRC5Y/4Mb6/dkDYWB3+M/7QHzOmAuOfXPqcqF8zIhFiSxsLRQTEkulUwEXAzIG
xKBbBX3nzj9/bD95FfxJIUmC8gxxQhm2wSMgZ2+EskzozTMMGubRto7f5a8pfsnx3ObaUjfu2ooL
Op4vMMCX7hxdbVHaN2FifAo4nqw1yI6vvDIDR7LHxuORpiaP6HsnNRISisUrXPcCoOMfY9pSUSpw
xmHjKeHPcU8y/Ain/c4UnKLPTspwcDmv6NcK0oOexbKIhQIkh6zhYSCNmX5C1GIO1KZFRVp8aGq0
zcuK+U7gAv3Dm2ckuA4UG9KpkWvrVUy7WTFT9pzKSsRDYIN9wL5Faer5olvBdkylRVN0ul3AS3Ul
1tFKjNG+d/08ugcVKw7V26CvLln+1Y5+wNBwx+i2qRhSwJmIhtHWYaO3VyDMftBTuWhJBqo3dEU4
/gv+WDMzjhsV6WCkUuNfzh80GLh2Yvbq772lDhLFvcSBNXHjNqba/qPE5ekGIKqCC1kujRyVoIq2
iIS7fW6yI7PgsaZmfJotgl6BO4WU19oHIBhvYuQSiJLH/PAqUVB7gn5t5bk7HVxG2SHDV64dT5uJ
uAbrmfb0aiUsFFp5yp1AQnP1vSf0W8vVuPxjTDz18FH2piWJYUlMnJNpcma8lwjNVPymBevudYyf
7tFzjEF41fxieSLsA2mfuhgY4zjcW6czCAetzDTSfqLeMU68b991KgMZWV/qg/TJ415H2Wpenw1v
gcmSZSNShzBxi6QvUbJNse/qgl3vDZQ/0N/phHfCyKlvGYzyURpmUvghQd9pYOCiDDAGF1viJ2jd
2WAmQU4fBu4TsZl6N5Jd06gEALhAVIYSVAn6m5w4GfgYUlXXDpbNooOQrw1bb3KwqNwFS1/Oyrqs
8cOdkl4QuMtelV54gIzoA0tpC/ofexYjQneHm1AkFSv7YQtFwtdxnhp2xl9oroYpL9ov5XRwgzxF
TKXUkHn0yB7ig4rkWu0pQn158JSd1reJQQh9/mfeYmrEf6elGbaHorn9XzpkvwT4mH6a8cCYF40T
1pVHwxQHWnCFh/KhzfqtKg+dSCScsYsjx4zWhB+TGdE+l9yV1INg20M5uffKUDsgixxfLwLt/St6
a2weAQPBq9gIr/Qoe/1UxwqZe4p0g1aGZceEuuMv3IKiZG2mB1dQT3kZoG2ADvTbDBEvt59nw2X8
z8OMEVvLAJTURdBJxOvJj8qKdPb2d6wRvtdmEu74u0yx1RabRGCZq3v0SkrmbVyPfE+9wjtDLmoH
/bixZZgvqmTF2fiE0h5xG/x346Iv2aUK6R/RX0Tq5nMoMOR/YemAf2xWGTjboAf58HAkzPw3mo2A
CKGKG/DYVmi0dyRnYBIuUBCv1paWDZ+OjqcIOYs/AUWUu2S7SOEKh4VSweY2Vaqacg5JYZsOsMfC
xhrpL0NPqm+dfdwS3AYWXUst4M4c3AY5XAwEfmlLBqkJrGrj8HZnywaNTL1zrq3R/Mze1yI6jDbn
Y7kkVkB8j6VTPz9LkFDUVfqcuIR7zdsBGq1+5VvgS9MWyTwtjaDEdCsCFVO/uaEfcbzPFGkh1von
PiFwglYevsnW5lIPsKOnd4telOnmPtfX9D1wYgsQ33GKFvGJ86CGGVLEGlpTfLAcdqdJKlUxZQCi
q69Nh7XDwdgU4olpXoshgzTVdZyvBBNWL65bpOxG++bcvA7ODRSMIA/FX6mW5aASyEGMD6h3TIDS
XzvkCOfnKcDu0L867fQ97td7FsBGpw6imokb74nxTU5GNFKplcmxfdM3Bp0OT2hfF1SKKN4L3Q6X
KpyqMzGwW3NPaCojsS/p1Jzwixg1mhqaadjamo38mVOIiYSs8718v2HTUcbhorsMBXz+PZrjaskb
UpcCTTNiZkZbVjYu/gg2rACMiOVOwf8MaMl+A3p30B4anYTG1pAZFe9kNdmNJmDiokbeixX1BRDS
ue+ZXidUAchiucuzT5HB0+aGPLsZC1NRoho8MlrZYsub2dVuj6XoNtCOMbxw7dZIeB9DOQj0X9gi
gSXcgocAsvvBHYYzlyNKuvDZMkrwynYyd3ldrHqy8f6Cz0/plWWgyV2pQSYCNX3u0wAh/5kQQpC2
yHlhpP41+FZEvKyHaK09FAaf4E+eu2aiqCmE9QFA0wL2J7SY8Q6/Ou+FhLVu8ChrE2L0fT6/pn5J
RbsUNFP7bHMCg02lcaP0hAGvJjfmqnd/1Uk/Y21frovaobbJK1rrhUfk+SRzojOSbNnUthTATXFZ
x1ePcfXWKZ4UWifhwBVH/M7NqnzHxpArj25IOKBAO+YlLTASsyAnZJAqHZodKl7JvjOxmxsbp1EF
DxCC6aEVa6nBwNQZHUpBaMdBX69LvQAJEVE+Zo+NTUO6drxp+N0BiYn29O6Z3MLdCzsJnvfLaUvb
tapU9EzDvZNxSbgBpBHddkRrsgTl4naH1PEHzNm1ps34EV0drs5sRraib0+IpR2H+pg4jDqizKBR
0/0O2LjSW2QnjWHBeXqMY+LsFO1v/vr3RWucr07hJpzxo1J3tEemumbxdv4KhPkVt188AHObDrT6
Vtq6rxx844zRqYn/uJ1iRzFAU5Sv776OqazYETc/uCnQcqV6ECJFxPgK5soCBm3VPOmO8jyPOdwY
HTcA1pOA3fnaqTie4HkEOjNCGtVjZF64EPOJkIb6um50nVgVnC2EZUeEhAAhWbSoFqBQHJxtdpeP
11wbuw/WaTBBl9qt7Irv/Qhv4uxMrFyTBu8BoOpN5G8JkRoNEXMOU4x3FKpxVRGdV1nls0cLylDs
ELtKGPGlBSy5XMe/oi68g7qqXlmv8UU9EKaOjRurB0d0b8GYfUXaSS+b4gcWPBmMMlWQk3fKI4If
7zUtbhzifE6WY+afgFw8eNEU4BljMkLWvjzh4SFncxsQDHGIhDO/e0MGavu2Dnd/vfBMAgDwu6dm
BO3hfMq13HHgsW2iB1ROwqNQDjiNVagM/lZPv1gjsC3wIhUz0Wmy4k54uca5LF6gr7+v3kxCAer4
HPApJkEDnqAa9sx268gFBSACQGhMpCZuMJteGy8OAQIUmB4jkcYPJhIjkWg9RlI8KJQsqz1bMhKu
9pxm7MKrP27R/HwVf1J2iKExy7Z+E3mos2CNFvdLVrq3Ose68+dkPEI7U7Ny/OLptTqhTmMyPGix
Au4o8W89sHqfb7hz0UQlbAZRwHayQHxydwqJxoY6wFdEYFQITE8HKmPveW8Q3UT2+Hd3X3KI/22z
55o96e2KSehwebNbNn08Slyr9WsHDrq68L8t9GLayFwGvdl6FFkcc9TGnMtXlRFmPJdHsUb7NGx7
wiu8eIKFu8dTiw7LJg18Egn9QMDa0zgNccgM6VXoH0Q6vhVTNH4uH0sakmtUHKHyU3wR9NAnOahn
5RypCziwYqaDqpZPtChdve9YQDBLDoK0bxTuwAG+iMT//eHO1cXsugmZycb9+tLIpVC2utKJgUeh
ojPt2RMU4KdU/7dPtN7R/8Tr36fSI05VV98EMgoeSEoE1JVY2A4Sv5gDNJFsZgMBkuCmZUlZo/gR
hlJgpcT3E6KSSRtzFI4JDNc9GjgHp8EnA2QJlacRJGOwBYAWGhrpxA+qBxTl+N0LUavnDa02rBGL
S7lQ7L5mXc3T2VTeXSbFam67AMn2ZExmRlcSUf7/J8lq03EGhmU38sl9kEGd3ETQlRIpEcuJxUPt
oMDIQ5u/iVJaPDaVb5MWArzGcR8EUNgU1wXGGeJaLSe/S57efxEAMvGjKWmu9AdFtQMIQaAwMOZi
NeleL0ZfZKhq14UVtuo7WdQ9XL0Chx4ydP1ymu072AcziNsEISZGZTz7pE+eEIVJN8Q11pq/431O
W5sSqYx0Ex9muNo8fX2M6jZtjCYxJsAVZ74UJY+59Cj6hFq6XxsEhDlEO47xzWlKK8wtH8r9u4ZU
EpOwt8fvY3KmFIA8B6uvLYYSyMasktaRcvynrsOH2i7coSq/4DT1b8buXbAEOra0iSJZob/rVpjh
SuhOUielhhFTTjndnTAjZNjBvPEUsEV9hcOZrcNROJBOqcDPbf4OahSoMh+CzR6awn5ekfRudGTf
ALDTfxVKn6uL2029J/h2kX21h18G8jJtr2318e1CPvEFl9EfUBjtqrwbMeV6VJ4pJ9W0ZiEJFZNh
r26q9dM2BUiK4EJq4q1F2+kmBILpIJbj11W1L+YoWzwWmV7lF70VA6rPJJl3smBN4m6LSj/lmJ7l
PmtGsf9DfBlZrcxkOpAHDPkCQJ5adYPt8rgmzvjhzp+UFTuWjvEo277ZCszSqT9F3zPKLlWZj4NZ
22IKt12e2W1NijXddqa4HElOaYxYfFrivr7x/tGeOiltSa1G5ukrMkVqJcszF0wzvF5oUJcFXhE6
346Suz1sAClGMQFZBbpCJl19uC9avGf9AkqBvN18vOgIwiAhXk1t8NUjgGKmu6PeYdqQPsjbe5qn
Sp6HMdZun7bvTIhF+dlcUpdY4CM30WvZFrcRlrJX/qYOtMzX5BXQLQSHmgQTcEdCtIJZNlRCcH1A
TzRDXcRs1Z7NVRgtcWGHw7DvBRthV7HXuvFBeAT3pg7eDTmrg6/hqMJG/xSbIvZ0+N1em3gdt6a3
V80+p3RUzftMm4JOMOKYYhg72GDP3LpttiSZTnrDhs4i4YZDRKPoijGQMJcmkgq1ZY0W7u6/XvVm
HHH8MNuBct0X9C6UXsxQry4jK2ZgUIlti5YeckHrC724QRiyOvSv1tmkPZnV7pthp5N6VRNqSR58
1Polv7ndxt8IE8jmG8Vre/sTmQgiXYEcuaCXLpacPy4qYxlAgq7YtS9lQzKS6OMX9mU6FPo1ZZw7
zuIq3JXWLkzHpmMnZjbQIQawBWPSR4at7X+VSj1XLzCXFjhBtenk4aRsro1BM8dJtvEyHGidju07
pB9yzWGAWxidea3GzJVsyU+I2UsLpB8so2Vg1MtBCP9jg9YRlMqZ2ri5fjWCqb1pVje77M30mW4S
PhIduOjiskH/fhCJNesyM3X18kAPZCyxynWDdOF2cijJ9RNHTGFFqJBs69O7wM/F4Jd9v3IyeF/u
jGui1gl2AMGSzQRSZMBM6IpTsxaBqy9KQX2aZvlVp/JNEZerXczq7WSSC8SDkKArhMVG7mM150SO
CdtQz61lidpWVON2a/a4+naZO1ohDk0swXPbfVtjmt3xdk3FRpRRAnUohgzWt7fK4HRvsKxj5R04
/VlQZwOP6W5lhwO7gCveA6q0pEnyKoft4czlXzkPKlGyu3bPne0iW4LpLELncK2/Id/Bfdk8tKIY
RQtVO7fsZihFwhxlxWygO1bQ4OxLDWBTNhwhKLTqYUqD5Y3TiUijyUVvf3keiqo8P9HqLk18P/1T
dxT1jdiIsYMcKZbXgm6ALg8LBmYkaYYP5rdX2Sd2G2W6tBdmobNjWd6eSL1kMDM+mDU0M40jDvSw
bq+a531ZSPgFZqV1kZcp2N0/mNazCzg3fbYqllkOcKu2ChA/C9DkNnik1hi01Z572ZlWrDbTRdJ4
/TICbrODwTmCm06kiJDPbfupRV4vOh68rV2PV5ZkanU5JCoR7IbnjhUUToEZ5IAebWzO+EQYN3xx
GZl0wRPEAMy1KklhP1nb9jT9qEzcM3T3Zfz60WRf8PZgeXUqzzYHrY648bUe69SLfKxK66YEyCOY
qUwJVk7hQtd//Cu00wXX0W8r607/3/1RyMXaob9Le5tBgN7kyYi14godgdKYI2dai/6iOSt0ZwiD
0Z8Te3QmSHj3VKnt79tpuxoc78i8ClZNGaZVx82wvdD7B2EaBFbqJfkmoAY+9MIFVEQKcrbASHUt
sDOcnH6pv9UdF+ftGGc0Twjmf5YU1AnqlFG9L00IqMW39Iqyqh9+LQA1IgjLAH84wBI1Cw6uvHkT
cctSMHkIPGw5JBXUnSk+j40GCimhO2wZLUSTpzm7+xfuyHhFmwNd8P/wRpUjapvja0ygOzCvOtu9
hZngThhsUkX1bmL00KE+GfGtRZUjaUhzpN4QQIACAfPfZU+q4/5ihIlNFsv9t32Du9uipEtwiqmk
hcNkHcELka9RV0Uk+F7lG6XoKsTXnT71a9QS691tG5XhsQ4EjwON77tJob4NQJOo7LjnwmNR8o3y
louy/lzL2f0zlH8P1RSjHNo1K+qzvgQj98DOioPsmuKWlzwGIKNoCJQS+arOMUnRcm8SdD3nPZCy
UX141++/NJ/G9E4LGRKu8Xskbrg3earvknepSJLTCtfvX5xs2we9zG5i20Qu1K9DnBYAPyLxR9st
5Je7w+xPz2nQqcnmkQP8d5vCYa/2J4JGBjd2yLuhNWTbYWV2mLdeieo4NHTTmx6iIFURtOmWnmQQ
Zw8Spqa/EYxHnVbVyuS39aTcUN+4kQSkgsnfAaLA+mDEKloIxe23bIQ4EDCchpY8a5SQ4fzXMEDr
peZ256Daynl7pmCs53DCZXRdZyw5Yg4i2NdLTdK9lz2tKYod1+SAqciVmvgOYEDVU1t0DGMzD+9x
WB/G7bYPtRrdLGE6bLaYvONPvXdF23ZFw4ZmN7Nw7aHlBr4M6didKxx7iQd3wWCImeIJVpLO0lup
x/W5sv3Gym9+9qLhGf/hJ7t2IaW0+iWnZOPur/LrlxNqLvcPNYpeHU9Q6CFIUJob2hAVEznq1UBL
RHTVEifLzXdkD/KybeCIWdRi+VUc+yTQvGqBnP0/ur5kNsQ3hGml+1MBS6zaUxKevXj33j5OIVw+
dbFHO9wwMac0xXYmZDwNeYlkfcki/0QpxwJcx7KTroauekcdV8MbGNPWT5yBiOqR+MJdiKTBiYq7
rO8CZlyE1+rQsnr8m6m9NH8G24GShWLbwbvXuT1jsoiFPJ0cJcOF3hNQhzjPKPJ3h23/Y3bFDZPE
an86xnbgvAPsr0XzmeXBe2PBoEmZEXw/hgd4LcOz63HjjgiIUYcYUZVDv6nV3Vw834t3m7lp9tHX
nK4/JqkWBRP2dInHRaYa1tFTtKnZqzNGaHUYHqIs/kUMb7yR7RvTbbBQqN2zmt+aewAKsEVdbMML
ln4HEx3zkvVlVUlS07OG4d5xFJ4FvFEEW9ZOe6s4wWaW3bpWD2C4ovtIlY7tRDjDuMq0M71Hy2z/
BRzRm1l9lZLhpA8evSFVwgZN74I2Y92D+LbkVVck6ZkycmyKIuL72BcKy8dr1BvWzJ8mShG9y95b
tazanOl7P78y2S+mFokF+D0Fk7FOLHTLXzfgS0j7LJeM3VnCF9yujYtId2WPeC+Fca17A3R8PXm4
G2yzWiwRBxuFCiJ3xAqQJEOLy777fOlrynbX7EE1eDpke0eLTJrzGN/AcC1FX1rMf3M1cgspHUQn
xXwc1rr5ILsQI1Zh2jt20OabduoXphpf47O05WSqUvG8CRL+MvryrwWPrqRxLyaR0LJNyhlsbWU+
Kiq5nAEuIMDBWxKYpTx224hGSKcVRxcN+yo59YdWyJjtzmKWSaJzo3g03g46012woxcotqinGMSZ
eLcCJn2YD7svIrEOBHaVAbiiq2SyCG7YxH00hiqwsLPk3AWhGV9UjfS6h+vRFe5f58aUGMZ44BhT
ajdopYtn+1XiYTsmKjvOGXO26YA689fBMwFoe3W7n93Vqo6c1ogF3itUwelMZY0r1+N1c2mm5Yf3
7HKCgwTAgT5nqv0VTj1RpCOmwsBi3HB3gGibyWqRanaZfFlNOlP+aJk7nPsD20Z6Fzyi4gD8i/+P
g75LJ89CzYPfqaPDspnvSn5tEILeGekKr/vCwscyfzBJTU5JW/hpi3LZQF9Cuwg0osFrgjjQ6vBr
5U9NWVUgcohFCMD6patFLYmm6XxNxEmsckYOLI+rQ1I09J9gMvF9Q7uRJRQZx9x332E2zyEU3UFv
nJc38SHGJd3W0i13t/MwftZa2vwR4B6Syre7VNm37gY4SOrPxouQxfTzFfGNilGv84N4CxuWZ4uH
BBKvbxTz4616LGVUx0vEF7kNmkrrm1hjowMG1gWSbv3C38o5MSR7XCYR+I3B4SBrJ7XiFjDznQyY
qx0gs3ilQ1D4BDXgyjLqPe1C+rl2dE5P5POtU5CDcsyBIR2yCwC7ndjtaVQhMzORZ2T/Bs11geXF
85xaYExrcb9myZ7L41YclOGBOZn9rmb8ZLd7GIkBlbZmk593MuPg3GKwstx2PDMQHcF9xp2UuGjL
c7mpnuKx+ohZARcNkuPtHfUXmniXb1FkqLqQhVHcojgqo1wrhRVAcYez2lfv5M2tGv4M5wyqDEe0
lRrb2tRBUv8XpkaOph6aiXM1MtoQBMUxUckzLP5naDpXvwllVo7mbJQhUKYCvocvu3thEg+np58a
5zlScYAtjkEU7xJSE/Ohf4iFHeyqNk8Rs9OJ+KVpdNWZAmc8SoijyNrY9uEdwVQ8IQAXYkIeMzzj
avjJTL/4jGxN/d15jzlPd7e9rmMecvhLsQ8TVYIPPPOgtqgCgM5aKyl9YKgDq9Ahr6hY5v/wiJUa
wx7yAH8sis/LL1TGgq81R8R7IVekEvNQei9pK10W4U/MNWvrrcZdMrgq1ji23es0983tjH4Vv6hQ
7GhQkv651oyAoStVumEUVTYDpYgo2RD9nxsjY9BBVYFwvPe1T6K4Vvtv/e/Nj5acAhYCYtLy+1v6
bb5b3AqAeyQ4O3+CB7EpY2Pb8iQZD6JprVcxQSaQzyGBhJfnV8pnZXb+eFxwn0znIArNSLWa2UIs
iNag4f1Dxuz/f1VcYom7JvLKQbHaYJNnzmc1dX6/NW6D9qB6InFo5b3vKADQn9RedIjYMfQdlKr7
MS2MEDroVdqN0pDJLwcPNorZxwI73fwELNwo6JT6KPM1gm/olKBKsowk3+3rVnifSBjyrufxIdEw
cqVk7xhqDv8WEnMNX3YZA/AkDrNER+j8ubLWSmEtBtD0VyGUx11hTkSev+0LLjYB/RM34xUK8gSK
zF/OipTombjc2t9xHNiphWw3sIOns/kWUBw3UenNWQI5SFg5HWjFO52RTW1LelL54kOxej6w8mA1
lJ/PfKnWep/US02tP3aHj+4BZDHeuzHaZVuf7ZenqscbPNuQtGWSwAlR8f0iOw3DQ9yXkVLzuVMo
O2wFJCmkYmGF8C+dMqSMz/FhjRT50WoA661Nf6FK1PZubFjD8oSTeY+1XdQ9P9VYe/L8++JWpy06
k9OsbhwMB8tPMtsmGHyKBLnwsBXk5ehDx/9O/B1m4CV4Q2V1hyc2jbAgppWA3Dgql6AZVdaXBN/z
gc5EA8YojCBYJZs7Lg36OXaZGFYOjENGU1XuTDvTREeaNOWk5TFQoZAVPqI1vmo2uabMhzGdaIIq
i+KLOf0rZdvWpHUdyGmdb1Dy8VjKl1eWwayRUYq/swl9Qr1wbF2fYTfvgFyTyCPwUPYcF9XfxwBI
7exxNF+fSXXlERQEWI75fnZKVWWZYg3cI9pJ4nUrXCRVF+DXFpY0GiB3zKXmkA9ojvSnj2XqjZrn
kZpC9mlc7JAcSRYxHn86YJgT8z+HwrSuJOdauoDHLPKnIy12JFXqoYU4bxtKIX8OhkFOyspQCNQS
2S+T1cn+6E+zmAGLpOLHSK1ViXlHt+vclBX9nYV62tMOxftfCEHzOzHa2jaLkQJEPY+I3SNMj2Bx
OS21N9NHnkbQCAIQQM88NEKviPHt9L26lKd15fbnnBzLqlgZ05C3Ccr/TyGuQHxS7zbLwYxflVQI
Syjx5tYPF0XnTtzP2WWqEdfQvqVgCLirYaCLR7fm3xz5gTfIS00EsVzHqFUMF0UTsJIUekT3wMWt
MlX3ig8vq5buRLHoRLVITaAEua90CWJ+ov3cmfOfoj6a/LnD7ol8jNbx5gSCr0yGOVUdo2qCzOXX
Gx8xIBG791sanbs1GjQXOCYzyzz+umJE6zgUXaggGIUCb8Ej/d1kaEQCwQuJHrMhgXeVllRjAz0I
lJQBjRQuFFKThTuduRKwQtJCT0ILs8B3As7b3KwVUWGXx1O3ru1DzOJTT6RmkjvZ002dB6V1jakw
v9KOjDxVA8d3EcqxUrGUldTCwEyqGiGdt6ycAG3Wevchxi9EUKo2FhYoB1+6QmpQj6HeKE9N+Loc
K0jPpAKNQHTAbgsQbQZCimSZoTaAshfzxKMwKOAJkFiVvuNFBKcX0mkDrwPSvED0Znub+Q6vrR1o
EbqrMgsqu7GLNxVl2az5WKzaZQgcqjZiTP6aAyeU3RKk6gyf0UIUtT3CrlarWuWeMA+9mOOkiOdP
kdp5BNuKDUpRfeVSaWArohswjAvS8UEJ15AfUr6WeuMErinEgP26aP8N3+Xo9zxNuzIJEeV0R64U
PgevfM/dvlXXIiWL2w+P5LDDPo1R6FfwFEpwRVm3XGmwynqfg6yxs9Li+lHwONqNN2nSFDkJcPv1
JSQ8flDVASUgCjVi/K3hH2vd+PhG6WOqPUh5pb+sbKQwEg25f2S+zwdIffpNSfI4KnfffUtI5M9r
BxSCLli04OmOUDbtRmoSC9tM++hgI2Du2ubbWyN2siJukBoS2NZouK/s77T9Ny9W1egttd4a3V07
3pW+D2qHaF9qjnJ6WWtkmnuSy5MUIpgCkIkoQPs91w+xZDA0kvirP/t+leqp3hkq+TE9wGhYBjqz
vS0lvWCJAsBD0PhSE4gGhnPBVlY46/MV0rS5bcfzb3Up8JhOlZybysj6rloL+psB+giGc14w9tPy
t11vo9Ha+o5uuwtJlwdZlbZZ/Laj+eUBrOZNA+N96f5v1fMZt9TcG+A3en5sptV0aOM7qcsCk9p9
sUD4nNn5csWIkB2rlGn7D9rP1VLG54F5zkbvMkAZ5ZsNHqFjiNI/gN4eiHN5yI0aya+3wDnvyphv
Yf/1ym2/O91/8KHarpUdiYR6T9wii01wuOAxLxzlWXnd3BSx6bB5dqHLunjXmzSDNI7Ulp4UNT17
D4LJm/fF4SZj5FDcfIUkQkOtnvy8kJBN24ZkM5r6N9PlCLXDu6w5FrKRxUzi3sVw2SkayEd+2Es6
9ZouO4EWvIGh7agZVHvSs7i3IHBQuyTxPqvQcClkn2kOW2DSi31LPtCv2XoATlavY23JVdag0Epc
8tzTgtqx6uzCZhHzRJ+9KSwbHOxWAjK9ScvAWtgYYEXb5zn/mDdNSbFC3ktQgkYzo2V//TVX+RWG
F8CxiG2Fd5N33DPl00xbbJQ5XkaqqTmPL5JkONY3r8zSZhDBeOz1guZNeGBK8sCxGeFDJhx+KDG6
CXR3rDpbYQ/GScPLmiTqWFBo39xy38wjt6tWwQcAFFnGLZ11FyCxUJBG01UDail+RH5tMlz3g181
GaX2HSNydAjdzkqTfb3Rj3QpemcNhYaOWvuXp3Ly0y62c34Q99CVus0ql9YWrywYZ5NA7ylurS7N
VCfhMsrc1okbim6szqTwBQR/EkXK9IHlblTrWh0OGcX5ob9lDV7nRn/6EstgnNn73EcEt7UZnQ3f
0a4j4ZHo5XkO3eUvpkIaxySpCSkdMd97eyiAli1bprnvN33f1MhDc340ZSF3vOpisLmI+TZ9wZpG
cTGSzYZlLH0qUtUUagZQIOMPpp20GZdPEZSv2C4NyZp8R4O+kkXYlqBrTFf7WhG08+hJpSFUSIw0
4fn6UnoC6UZzifaeeaVi6FIzXtuMo7u/vJM5kEiMMVT9Eqs3t4PGajZbl/aGZYdSiZIBah+DoDoF
hAXyCtITJNuV7zFkKpvfvd5AvdINKTsTDeDa25XxSLTxNB/s6rp44cErAT33YxRhwe33sf+jBREl
Q6G1ZhNHeB6qYTb9USBP+weRWuHP5GW1Gs2Y8hHffWQLDML/qvp8sEVvMvp2iRK9r92B+lzFhhWg
2hXy+U3tkr2otenGhZHysYuemmWipw1R+4xdrX7RKymoRPxJylftAgnqkRVIQkqdwT5B1WVvMin5
yd2Pfvk31v5+eO5Wx75Cz3yTrSMxZ8SgxgrGJL8CE3ZHdwiYV0q3wbvPfcw0BoFeINpMCMnd2+9f
WYNHHXjtD1XYz9euDnvMOLb95Hj4xChbNn2QfJLTJZ1BS92S04NpE0rf4vQmy3Nh0Vw7FfSaGuCA
cgOdQiphTkVx+3fYiScMAxwUOTShBRikTAeu4HyJUj9Aw+L4SZVylfKIPEoGrGjuhd7UEOgC59Eh
5A9as9ap9ied5z+eXimA4bSjOcl1fAVVcJFwgk0lH82es172fdEND6VTBj90FAcjRgsxkAkQzv+C
+atc24006SZjTRx0RTt/UgIJS8g7puEhU+wDqldt711si7/wJ2PUAfeLopotNU/xx22YUFu+AXlv
2v47ddUL9XUfK2Y+YCJTVeeh+LLzzLx4w5ddlVGCLeVdkWp9a3pW18wM4Kvbv+cc/QK3EYAnO2qN
QF+y/QzotQDEr8CWYsWwSX5eXTR2jY67eBMzIuY/j7Pr4+hEpH6iS8NntbjUlc+Gzsq3EuR0B3RW
kCYsoMYDKutldXhCPG09dR/d/5vjWjWb+EjfrhJhBLKW0TT3jrdJ6cDYU0ClRgi313iWKPg44zUq
u2hbFP7F1x2jLbvtQWOr+D9YW2vJmDo4OQvfVyhPwUPrON8vWitVUk6/WFPGBYk7TKDnVp8xiACj
LQpLJZReOuhIFlnHKp1yVZkuAUZOBJpEI9F4xDOUBHkwlole1C88bEa7U9nkKp/xE2BfD/cimARk
1m53FD0a/sltexYxP7njfMRG+soUOUOyI1aG29+x8uuC9sbzEQOYZTvJynC28xKN3m3VfNcAsEAj
UAZuymqxnhr8nD+R50RiDawGqQOIbJIuWK73cekmKKXMq8c1sOdodkQw+TK+yx6KlPIesvhe1xU7
4Exa/dLDW2M8JifSL0v3PdpBSTbzofLsS30U/U52I9KBY4SxXjWKsoZAxUDqf8JnJeDAym6fyoTM
/4UQZhnm8ClQGWl3Evmla1lGsR2Gix/ATD7ZDY5t/27uYuP7qz7LUAS+qK+QDg3OUDLBVLP3uUth
PPb7RmFZp2EnyaNw6jgk3OGsB0+hkQOsezXinODt00ldbT0R6ZVgYak+yhh3sgdGGL60fJB3wrox
Z1kjnzIM5WjkfLN3+pxhXSvW7+7pBHeZ/fkrV7HCnqTN8U857p7+TzrcwmsrtkjKdeuQIHKT/ujm
2UZiIOvfbCcvQKppvgeHoZcLwPjuXXjtnw3BQU14mETGh+u3yJnDWxvLy26NDPYMfqN794v5ueMd
tFag9fQiyIhTTY5s3DRsexEwcUZY2gF4CJ0cA3nrCCJX1CSOXm0c8Hq/tEdxyTY1ITohJRcJ5qiA
EUM2em1XdPvWfM0GdsL1XrhBAR+S1ssNjBYqFQ4f4P68LXkzaObzR3xolVCl4HCBSwmnFkCSNvaa
HBiy1ig4DPovz6O/FoI7XBfZA4OKrhraF8MKJP5KqgpOF4ZcgCO/t6I6rQfDQFlV3/qEHz52+Gtd
kGf8LMEi41/lEbQnsVY/oby76a2dYUGVVHAH28rQ7bfABQoyVT8ksRPiVO5Cpi0NpY6kxZQXop/h
ZICEX8tK9hudW/I2/8iaCJh+tf/N4c2wHhW5Kir6dw66BGbZxAiVt+ANxkKIJS59Dnb498JBSV7I
gkY/WYfQRSMybErIa0jp9XMzhU9NbglXCi37HoPVrrT12Pz7bezBDFpsuPmpXmfQ7pJpPL60UPoA
+jsQC9+nbQN2WzQ6rwf7i4m39Akdr+aGDhgzyt8j4h9FafMDUK7cC5SdgeJVSGi2bcEB/6CNeFFX
Qp1pCpMvqT7OYUsa+K9Xe2bQzAlyz1azPf9RjLlqMQcsbq0n7PSGXgxedRh50FbnMjXaJYS3H4YN
eOX9MUWJWeZydHiyTUT9siMBpca9Oz30wVjvuGMDEFr1UGSFCVpOgRPWBKsnHrBeYghsvC6rOnJ7
uu3YRZaafb9pqayiUmXJ/QwJUaAtESGnX4pwReSH8VOM09mtKmu7tPRhobzjXnYPOhR4wqeQf3/C
d2ZMOK0b1/6K695B0IQ0RrQ3uvj9SYQv6vV+XI6nKCyVzGlz11vLr86EMuLFf06dMNTEtGp0zVPG
Ov/fsKXUHd9rxGAY8oXKEAps8oYlP5MBnZLZ0q05rrno4nXL6UfF40KOYOmihvqpdTdfyMaphoFC
wodHI1LKWPAds1rIqI4GJUqlmo14kRkhWHsGkvdoYWjjAyXvZBYzl5t4T+mjY8oBH0PrD3xukSev
oaXP/HdU3GvwYYNR2S2b69e182dru3azVRsU+dPnYHALi3+K5apUMkpZv6i/GZ+5kBiSZe+k60xm
CSTU7083RQ7XlwyEkFFQ55yat9oVmn33KZGT0Co6fK9ctb2MaOgXQZgqYxhTYY4jHIBN+FSYR6pT
e9Ni14ylQGWQTWDIeM+nhmfPYrSqYYHgHmEYRM5S2ZcZ8K6YoVdBMTSQRt5Z/MpsUkDuIUiTVyp1
QWjBbSREOOG7+zZQ4SOEWZTNtyuJVOvxWAqPkIdSRU/d1IlIbDRy+m7V2718tfnlhimC/S8L6Ic7
CDs7m/aPrmfyIvrQPxm1kwIL22HWX7JaaqzXDlXDLmjno3YNtMJgqpvv8Hpcm7eGaPetBpzdcGbZ
jgJCy90wpZqS30mWyfCaLzXMu5PW18oNLu4z2AbH+2itIpmHftDQVNSRx8qQlYDKQnuTBNeFmXaS
hI8bjm2RK1J9/PNI94YrYGIm9mFIGtLUvm0JYCINzC7Lu+SpaVZottMqDv5WH4BeZQBKTBHatk19
dTvSFqdo8KSqCgmRnv4ftNLEoyH+083oe+L8yq8eh16DDZ3C+xRyJYl+KYIdbAgW/HAYllSFtQiB
cu45ziGZ/CUqWiHezjshuD44cJTV/b44ucC5IEuGNy69hMHhOeb0JHqE/RzJFbfRWIvQdZ73jqYG
7UbIeqfUWGT5Z3IdGvCpH1sQ/Ig/5lyojSeCRzWnC3L6vBd07BsuL8954O1IbwRYVt52z0SPW7Ui
9rRLPw3O/X0YTo7IyoNRphayz+LbxAMkWahKNjbDVYwDbOJrJYaWw+43urRob386YM18ldVSlt8j
xYGbUtRTbQfhEEix2KXNx11wQAKDbrN3DKrjiLjNuQV82LAz3sxNE5TzpQ7XE15+5+zCSf4fmoPp
/KKt28Ux1Sgfg2iOjfDaUcRLfFy6SFAKKeq4LTkO0aFyPk2jdRd805sUXXK4kawcV4xuHVAxmZEF
rrBf1/+ad2YlOe0CrHfT7HQK4q8ChibcxWBJLkIn2sBX0wBDmXveRyiIACqHHNnoy6W1lTGDcIuZ
d5wi6uuTxNphfrtn3uKap5ugC4p1MH/l7h4uUMD5YXggXEPbS6Gyr7ckPuw6s+asX1QIBDUU46nX
vmqSnTCbSqxoEWV2F90ARSLLPtFVtYBS94Usw33DciMo3MSZWveq2DsVuflaFYi6MHY3nfArrPpj
U36F+WnLphQU15+UN6078iFqJyPZsXs8QpoavBBBYgoopkRE40rdOqF9Z9aMjceGD0QpL21T3pAH
e++SDYsgFEGffWaodwT7NiXCQiLyozzgNqNrG1howYWXQbQ1ymkjiiDt9ao4CmYwxZB2dAhWPsWH
Go0B1NcOby8XQCxJ0aJNy+6Jp+sWPampPeSpS9+GqgxW+GK+Wgjk8NmDmRd3esPCCZVGSFN6gTs1
TyEObnnogDEPDokw4Wle3ABfDEmx4OdPvMAy3mpsKsTtR2oVec/iz3KHMp8yQWXtqifWHDfd9Ee6
YEu1RxW61hZLc4xZ9sz1uka0UhTBO6LfeuzEBPi8VO8G3hY172zvYhch45+SPUOees3QiGrEE87l
28CGv0g27y8ioFXwYVoebdNRJtP5jSXDxnsnT4iSctCkRDFFv+/HD4a7uaKr4CtLn0TI8Gcn0ejJ
JBypsSLGxJqZmbLWJ5GwLcVBd3XTPMk0UdqVNfmvkT3hSXbp8RQ36QAUj/0RufHpcbA1q1jPuZLA
bJJ1Ob4NeDkvJhmkjyadWgQWG3CyDGXr3aDIbWJj7gm/NuT5USCgIPBHQsGnk255EZXHr11B58Nb
1CHnePVmtGLw6qMYcEeykEYsUZ485CudKw3inPPGqRVbFj78x8mAzNfEv9Nkp/nSulNZ7XV/5p0v
HIAFrAVzBB2D8vKey6rw9VoMk2QNE7mhQfvm2VCQsBzgY7HG0db08JCRbOmwijvzeUMWF/EnTmJe
uYQ3OM0hTb2dA5xuZYgZXRCtYHNNz7dhSaQ4IyqyOdW3GWPdjlDw5CsaUQzXqtIz5yHqomStMU0b
4BjyyWJpoyfd+b4mOU9jQ0GIdbDjUOSDEBxhk3x/7Ma6PuOax74q0xeh7IhfMt+1nNBHeVmcfbmL
Egks0bT+916E2HmQzyUSg7B4Hrmze8BmiJgi8iLPqiBFW+6GJBZgLLRgu5GdXcuAC99wIPUie6nV
uFI7uztfPgAAuRYOL1zW2xieg2nwLOrZM48zUCLjUYi5QIUNCmfYqzLqzuXkps19e8R0BUYtSA5Z
6TaA3dnGJFNo2rVDFjF1iEyNT6f1q4yzDLqQ7lZxbK5GRWBhJwi+hUwaOu353W+mPT86Cg/Bj+ZY
LKc0F/NZfAZkpwr76gxoU7PTzTBtvtuB0+x2W8JEHanKWAqICPaavGcLggPkZZewgkxYkdAwGori
1oe3SANS6sn8Qq+6oRi12Slmxyyct+nwa3R4X/IV3NVlNDPLVj1au3L+rOcoagI08UeiqriJlgd0
MAX2D3d7FQVp0/oIx+tRCHL7s+81q9c+Kkor48hGvGf+jQ/bx8DA9QOBq4l3MZBu5nFJFbWXkc6E
Vg0/oQMkEhAnpJaLWfnAsGmiURI2swnHRYfFpr1DTP5vTaZynvFkGqmvh/dBk0wndAzZXjh7rLaW
h54nOlKCVbbcGJePbNeYi6piIdlu/0VGpYNKEcdN+NRjZbO5oFLCR43XGE7UwlcNjxP3uYD+eglA
vG0heZVB3TFtxXixfWY0+8zbWzpYeMyiM6Em5O8YMcQmPgUX5JMopQmrkrQbGNO4XURADhdJG2Vl
jZ0M8dQXjqPtMITrdpm2yj2v0RJ6OVHRz1KCFeyVYu1CxS7C3/FGnWm7lKFapW9KrDbUu6rxB2Uw
hTH/S/zHO39Xtc+zPv89JwcwywI9dokiAbHC1iA5iwi3bx8FuV/ly0+QTxLmCbfFKi7ExZHGrcY2
L7LhFkfyWpGBHPbI8YbjA2o1spfKALbOuuXPqXSx7lI1CUydBHbjQkFdfimfhHtLS/EylVqlVeuR
70DQu222c+mhKYZRMzeOTYV7ARWCp+/qzF84IUDipdKDJ9O8dvt8nPrnQJq25u93uOWFPpec0SRT
KCpCpvGaQw4CFqC4WukAX51RPOEjSkgr+g842oMd6Krlifjw0VS1HXhSkKe91ZYmyQWisNlI34fO
rrZ6xBku6SY+WqqZ+peX60Ix8xAtmBLLReGlcNObQWT/K6eRHH0XDv/vkSQVFMbheofX2JfQGa5X
Ey8cU3bVDhHCR4cmpYk5qzwPwEEUNqyQQsrKHn3nwgegjYrFBSG2YkR+u2lf1Ynwmp34FazewdCx
z08DNpQlNgzDw1bqk/VAL6Hsu8KCji+wKwrMCztIIF0n/xlLK8MwrcRbEc9Hq90aL5tyKc85dayr
egHYJMrcAp0usnMJpqoXghFlgbYdCWADhFf8JxDNfJiIK1bf2tPfDVw9Rtie6gjNJztgYja9/+s5
7egeuIpdR26oN/ZlyJ5hU+Ib2i8vZFClQSnKCvzMDRYlX294r3BGz3aI4BWt86zi0RcGb6C5WwQn
gVn/DCj5lJ07e+YdlGdPGrKO/UIij4Pxbki0Wxd3t4iOmX4pfUq7TNjG60RTgsD+zZ/a1HgeHMWE
MMZt8cZJErjw1UKv6EkAO8AB8KJX3hjfmE4lb6AGWHpXFfDCVFzC1G2EK6ALbKVWoO0fSTUMoxEl
UBtYtJGvVxwQ+jFNr8gvLahw3X4Myb94TsDF5KTV0cpeSVcWecD6qrwgp1wjnHRN5470es1rWDu7
c1fD9v6zRsVVLSnhkMTkgoY41YCLl+leCSTsnjHH1xZYYGJRdZQX26r1rzLtml3L6l/cFufU5/Q6
wdejnnimMK9e/pOJyU4QeXRGmSkLiRMj9kSSA8Y9rx+dilQyaUSmNS2PddsHq/0kGw6J+wwe5KqF
YT/YXbtGs9XBeAt/Y3PRIE7fSrJFiPg9SZLiNH14pdgQIoDGVep0zl+ly/w4ptJbmcwB/wzrL7CB
OEBhQ1MbsehXh433vBu1axuR0WVJFmbpIIkhXTs6yWLnUlTUs6EX5NsitcK0SU2GooWMSlqg618p
mbFx34/7rrOmnZUdiFvmu2u+8HkqlNzlZ0Arz2/wOmISMj9yYRQbfdY57eQgYBJW7+WqTKxoj0v3
8vEsh5+AkYgv6gPVDyu70GD17ptQmDa/IHjoRMLq1Akc/6uSQrOIMJWwQ4WqN+2hojRB1e0OTjPJ
VSboeIXwgPTdnK0QGD335Gyp/QAQ0Vc0ogrUUE1tz61UK/3aI+aCMpIGnLp1D8icbVq+I5NSv9Rk
8eT1HLvGwDtMqJ/m6nVmB4Z+4edXdYhDQJ3xyOsm0cFBfIYXA1W6zZiGDPoVejwDxd8oP3m3UGOZ
/5/7Gy5XTAOhKoAr1NoOquDjukGXcLCd8KoSG714h7tIKGiPGBF4HxxwToeDFCr4bqVCUcqlk16o
tMEYlPcrYIYyp5/Z4z9y7Sx3wc3iNOLEhgaXUYPLGhMr7BwJCbDh5Dh4YkOT+GSjM7hlYuZGuF2t
JgKyw5gLWyUoJAl551Br3biCon76Ld6H7b6ENbyvC8yK1mwxPFMXVRtKUm5OY3w7AO0bE436oGCJ
wnhgsEWUAX12xNO7oUdg1+vvnw3xIAEsZRpNWmZ0ODLW+K3d24zCI7oRqgilKv2Bo+RCTMW5uyH9
H7WlzWOLGetbfQt/G2Pp9j+onAE1T9CTyK+dU8El2v3ux2t8+azjgEtBYbUM/jzgh2KTgfGpl90p
gUMEj+l9yqylcnatS8kzlJZv3ELTwCRZJfq10Rd2pMJ77QOkqgCNDVl3WHfaGQV97dQBbtOx/4CL
O4WKl97w09umSBox0wJl1JTQ+SuzsqUKs4BQHlO7Jfu98L1+VMhZs2fDwOWi7SD9qFt4n1Yvzhpb
cnNtt5JrQZ4hK6eBC75oG7wjEiwrm4Fw3latMtAxz0e6WtCUjJWDXA2mdR0gbT9FWP/DjGQ75g2a
EWPvAKGbMcLh3tLUaazMfsea7ENv5YD/KaSF7AkQqtG2Jrk2yVTv2FY47/HGlOGAtY7JBWECTdWb
h7m4s5h42r7sAgHaWAo86n1UZns2NOolmHUstc32U/ZrIGvq6+1rgH9Xm76IqeLqpG9uFOchy+iC
7sHHbR2tpvt1xhbGIbVJ8tLWce4F6cZ9jKGRcc18Zsnq6D7tptnaUGeyLkky4pTWHBM6zIu0eZqH
XuQ1bw7rNgNAJIYzbCH/38fAbXAWKC673VM2gDGSI153nb6x1mL/8uKGKKPhtt0VX0gG7T2Xc1ww
vgKA+Hi+BXfPob+PYhQnmWn9Xub3maWpMswPQ7K/R0MGO6jHa0pJV2rUiG4c0EQYiSlwi9auwpqL
O3EDMAXXb8NHdgHNhZccQ60VDO1buQNlI08K2DfHlZC2XXp/02+X2OqsWPNIoiKAybNBHfCm9/Ck
T4WpkB60IaQC7hl8pgMoA4mR5JPYlfntUCW4fkZLYIpef67KY0NrJHF2OYFKVSBBJypvH3qc9LTV
mGAHpULnJU/nUOuFkc7Hv1vWWzbqOa3l5yVy2+ly4oTiLf52Ev6mGeW92lMrG3+LVy0ZM5zK2Spe
J5gbXoG7VPL3RCPwt1JlZwXZ/ZoR6u796rOfRpqnNKs9ONPUHE0jptMRUbkKpVw/8bPzQsGp2+QJ
Cm62HdYVb/Z/L/TjLWM95AsVbU0W3q25PbTWdZ+xfnXHPzDOFfv6gvBbmUj/qeSaadgMu5xfTwjL
Rc1M5bwZntor9y31Rzl85PwZYZaLXvb5IfwApr70UwiycO+9vtUS6vVhgKjsZgayAuCUHtDa0cWo
5XTpOcca8e247Yjr3inyJuYyBYvG4bd8Tz5+Cel/ByxPHIuG/VG/dUfPtwIC7eDimhEHJkrWvXjY
XXO9EK44KlSlicFPsM5TSF7GuM7P/h0i+CARoNynK6PMXMprj89bbMJEqhY/oLlkqKRpM+W6zZYV
74IuLPpXKMrSlGZ+wzziceAc3e4LJb0Ii6ws2j0hdhD4uxh2hHGlcEwkmijfQO7c75fuB+UDglzr
RPGSs0cESmpFf+k7JERGdZ+LIihXKH7onmpzojdel7ARKUbWZQH/mzM9ptMqe7wlrZsLUQzw3IjM
WL+5amFYPuBhMxqLHBJy4p5ShDDkE8tFXnxUk6oycMBUwTKJNv2B804MEK/tot+kaRnMNIzZZWso
jELJXYnroYITmvb9A/M+U+4eu7oeTBgf7h85cF7kmDnJYVh2cSNJ9timVRy3UqnQOKDn1hBntn9i
xETbMYrJSKMEDgm2KXXNiYLXO5yfFvNTV5WtsBQ+21Mdj3MLaYqlsNClvG5wyMGhLX104hcgy6f/
PAah9ex/MlL1lWIFawFGlIswx4vBn0cO2qBTDW0iHu4rUF5nQDL79EN6y7JLxO2p9y6iqj9/6vvI
zWnLCuN0VeER8bO7ixEmIH/+x8b3hS6N6LGxb7kRGOCsT7cZR3gfs0iognzaP2gjSvfF7UPq/IVn
ep5XFjvHRCUMc3kulOj09k3pSwfJ7Fm3m13OVxeO72alQ530WFiN8qzF8KRIaJ1eDeBDU3t9cwVd
abgmfeTX+P/WE2f/EcYlDtEC4hmCtzKnyvq7bbHw4d21ThBHyEr1gq84Bnn/rAvaSoh3zZvwiB6v
iynGUAcurYGx89PLJQYaPd3hOpn/jIibupXSzT130GGbp8UmMe6nK3KRatPXaluxJ3imeU26YOqD
TXYH6rvWw6AHbaiOvVgM6mhXvvZ0M/5uklPTd3JIvCQhNarAm2xwnom9NmPsn0bRUHYShidEih+X
uukgzMY7ILewHU6wMWvHDIAc5JUGFJk7k3WwSmqoE8rIkb0oZfoRoAY+PKehbsKhvvRfGUeQnxcO
EJ25dTrgELIj3VatsK1GItvvNbdI5GiUK3I3w938iDLKLfarUVdDwFJV0K2XWrchd73qhdvquXza
GQzpPikhX/AUul/ik3KTfe0PptWVJ4u+KCoWbrOsEMRXPs+AfQBfOQGsRaKUkg115rkaMuY0X+25
RmAik1rMy4GKkQTSxj5kEbjNdl1EyJu6vME4NsMQZJRfBDd6/Eq0v6aiK3l6iogk322qnvrVEIL1
BlBAkCIk/CDqGLpRwwwW0DypCTyhR7ten4zJKYeOZ0E77Xfsi8bbjCzdB+CGPCeNh2GSWocmIQJc
V4N48RchW9TcHZJYt87DB0M0Yvt4T3SCSXqcUToE7KwSWEpxvz3oF761sgTvyfilntCV6spECMVO
ihz5/giDXI9qbERwgI951H3jGf91+x+atBIia8Ce6trp9Epq1DHUx3aYGvSf6borVmpVFcUsmdP/
WZe6/t8Roli6ubSk5DJHOkuZfZOYQuJS+VqhzjCih1yhl+xfpPTlRIJB4ga7nL0SBt/kGy9mTKjt
aR5E/7oWj9skfpxsxKkpip3OueZwcNWN1OhIEgXSDzVNknL6BG5v0zCZWiI6fLdejrWzQlejzosk
XRW7/vX/Xhs+qo4S7qHgR6//o2qjorbxMfjZ23yxn6EfR8Eu7CsyWjYlbLhlWRFfnW8eKqIQn3rT
zXIIKgcUrPTN75s+GFSElsAWRZKWBSAM49rQG661XrTXDO4kNObbMg7uTJ8dpeP/kGOroBkHq+GB
EB7u92HS/Ur6k/7WUYevbfJOqlrvEuQHCnT1CYt4zYvZsxQCB8iW42P4N5z5lLy53qcAXu3kzQyX
S2DkEbpH2UyYBbPmG4uc34jIk3zu/p2nokKQOL/3C+CKzqdZinW3jmzZepnZeljPGWFg0xb+h7YP
6jeaDi7T/j35D5WG5mctQdjAbvKcxyGIg2sQm3PMEokc1AoT0Y0logt3iUjVgZnrM3h5nUwZUV9h
slKsyGdZY6TDQkXgJu9mAvVlD3HEbLBd1TFmSWD5
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
