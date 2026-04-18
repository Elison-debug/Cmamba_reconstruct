// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Thu Apr 16 22:24:24 2026
// Host        : DESKTOP-JL9PPGK running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/Mamba/CMamba_refactor/Cmamba_reconstruct/HW_reconstruct/project_mamba_all1/project_mamba_all1.gen/sources_1/ip/norm_gamma_rom_ip_1/norm_gamma_rom_ip_sim_netlist.v
// Design      : norm_gamma_rom_ip
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "norm_gamma_rom_ip,blk_mem_gen_v8_4_8,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module norm_gamma_rom_ip
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
  norm_gamma_rom_ip_blk_mem_gen_v8_4_8 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 32528)
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
