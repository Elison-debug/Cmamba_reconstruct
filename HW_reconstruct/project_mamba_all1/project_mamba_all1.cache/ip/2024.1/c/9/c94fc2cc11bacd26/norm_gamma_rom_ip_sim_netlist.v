// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Thu Apr 16 22:24:22 2026
// Host        : DESKTOP-JL9PPGK running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ norm_gamma_rom_ip_sim_netlist.v
// Design      : norm_gamma_rom_ip
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "norm_gamma_rom_ip,blk_mem_gen_v8_4_8,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clka,
    ena,
    wea,
    addra,
    dina,
    clkb,
    enb,
    addrb,
    doutb);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [4:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [63:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [4:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [63:0]doutb;

  wire [4:0]addra;
  wire [4:0]addrb;
  wire clka;
  wire [63:0]dina;
  wire [63:0]doutb;
  wire ena;
  wire enb;
  wire [0:0]wea;
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
  wire [63:0]NLW_U0_douta_UNCONNECTED;
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
  (* C_COUNT_36K_BRAM = "1" *) 
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     2.327111 mW" *) 
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
  (* C_INIT_FILE = "norm_gamma_rom_ip.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "1" *) 
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
  (* C_WRITE_MODE_A = "NO_CHANGE" *) 
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
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(NLW_U0_douta_UNCONNECTED[63:0]),
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
        .web(1'b0));
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 32496)
`pragma protect data_block
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
NQEpJllZ
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
