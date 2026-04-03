// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Fri Apr  3 02:03:28 2026
// Host        : 13600kf running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               e:/course/master/mamba/Cmamba_reconstruct/HW_reconstruct/project_mamba_all1/project_mamba_all1.gen/sources_1/ip/bias_ROM/bias_ROM_sim_netlist.v
// Design      : bias_ROM
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bias_ROM,blk_mem_gen_v8_4_8,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module bias_ROM
   (clka,
    ena,
    addra,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [5:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [63:0]douta;

  wire [5:0]addra;
  wire clka;
  wire [63:0]douta;
  wire ena;
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
  wire [63:0]NLW_U0_doutb_UNCONNECTED;
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
  (* C_COMMON_CLK = "0" *) 
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     5.831765 mW" *) 
  (* C_FAMILY = "zynquplus" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "1" *) 
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
  (* C_INIT_FILE = "bias_ROM.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "3" *) 
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
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "64" *) 
  (* C_WRITE_WIDTH_B = "64" *) 
  (* C_XDEVICEFAMILY = "zynquplus" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  bias_ROM_blk_mem_gen_v8_4_8 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[63:0]),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(1'b0),
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
        .wea(1'b0),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 31168)
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
