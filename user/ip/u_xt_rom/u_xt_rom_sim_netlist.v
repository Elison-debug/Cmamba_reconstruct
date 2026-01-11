// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Sat Dec 20 03:26:35 2025
// Host        : DESKTOP-JL9PPGK running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/Mamba/project_reconstruct/project_reconstruct.gen/sources_1/ip/u_xt_rom/u_xt_rom_sim_netlist.v
// Design      : u_xt_rom
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "u_xt_rom,blk_mem_gen_v8_4_8,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module u_xt_rom
   (clka,
    ena,
    wea,
    addra,
    dina,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [5:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [63:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [63:0]douta;

  wire [5:0]addra;
  wire clka;
  wire [63:0]dina;
  wire [63:0]douta;
  wire ena;
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     6.250172 mW" *) 
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
  (* C_INIT_FILE = "u_xt_rom.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "0" *) 
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
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "64" *) 
  (* C_WRITE_WIDTH_B = "64" *) 
  (* C_XDEVICEFAMILY = "zynquplus" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  u_xt_rom_blk_mem_gen_v8_4_8 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 31552)
`pragma protect data_block
x+zxxbS3FZ/KiTdpSzzGkyM2OdzR3rU25Mlb0EH2ZwklnW5PRGT5UuGE8zolpGR7dH56I5dBZvQs
fvJIwoKMw3TroUKn+1e441wGyWFPV6zLpRiFiDXJSbGRa28+bl8kgl4cwPVqOMar9h/xCuXQzRmk
X3Dtl1Muue23PdANdS7Fl6P6xdl/s1z6KT914syOFG1rbWKXsDO7ZR4O9MyMyiSoUjWMS5j/p5tX
UejIy5ixgjLrYx4YIXq7tv0UGQ0m6CfsMyWAZ9liPKZme0SUtBpiE63g2nWqTTeBK6pdmZdfypUE
c6pN3JAOmJwJoNZo5ldhmpFB6+Oo6nDQdgX3elpI+bFdOORFEguYI4WjExo4VwvQmWVN8q1IjaMl
14aCyaa2iiTLCwbuucR0Ex7Z6voCovGLaqlwbe1kDirlSrltHiw/sDenudpUXvio8lEjl+QjiBl0
Dov9qee18m1VWImK2wWrggp2Q3mVFpysSxLeeJ/irnD1NQonmuZyFeGs9mLFScuppdCY5A1rfDv5
yUlf6reSw5JpjPd7o3b3qBbZnwxFwsN6G8yJFkjJZPeX/Xv81s3gAbiAa2WqSW+ZjNxZlRlvCabg
guligUo4WiwRcRpqx1bnHb9cAwxwmRRMjdcn7RfwBHk8L9CcEwLMDaoQfhXhT9wBM9jCvfIZe7+e
FIs/ArY5a6Hh8U264tG5g+ljMLyvwhsTyjlbY22G7uYGB9vpK4VR9S2lIgcknIteEKekFy759jtl
YvUvBFvQ6a3Sk5GFkSwRKtZUZbmYB3vdK4QKqeSAzZPf0AFrW1anpfzY3mh4QvwH2H7Lw5R9DIEw
s51XE7T6BstJUbPGtU7FNNAbAzclhxEcJhM1HyxP3kFqbAzuUPhVHjypX5ygr8WZnOrxfUas1Un/
5AI25wGtkVchAodvlxpzCY7qCI+ODPQJZyN1fGzjdQgJ3GER+6I8zbYMMoouq5hNr5dzQRUJm7OM
soZ1B6LDyhryt1bKwPDuQalpOmQJgzXtayGgh3APwEzjZzoQSXgnhGloAZdm0MxnpFlm1oCMCvgF
As/gpmvRmz36DfA2S5gupUHUWzuwrGVT9M+ICMKbTh6B9art50ODD4EDShKQFtp0aa8XixGL6W/a
Rk9Fj8BYlvJDS4474HnSDAC6FkxXHsdS9MyFUKm3oil3cSXDwVmS+Ceojmd8fF1pgCfjqEeHDkTf
K2yChzYOWU/0Aq8mz9z40rPFjB0HNfoJYXBN6+9bwASWGRLJ7oZ31f62wHcBXnE8oN8Jf1ryIG2Q
41oJcvyjxAtjtEffJC8FhXngp0grrzwyHMmnSaHtgqE2M/hLmNh7Eohotxm7/nch/Sj6yuKjRVaa
YdbD8lKz88eZALt89NBrCSw1n3LP30zuWcaSbVmHj/eXzjpRLHkj9MFCKaLu0h+B/8i1Pe0Q3qAf
wRPXWr7JsdQjZKtJShKD2iSjTDKoZ1ndfNnGmYpAjai2m2z066mwrLJCOaZFb8F3y7/DWNKZmrnp
B6M1yNUq1jbkJRkeDwMN4sfXGrCebtCCOVz20cimMD75gjZAgUaKNW2nXNrVfBaNlXUGnenk6Y/R
cGt/wiBoJEHp0x9RfTOoh7Kb5xekfqfnbG2TV8uCEcCsy7aU/tBkJ9wINIw+kMjJ4NlsQyBjTwaH
CQon3FFrKvx9rVhTQFzo7eHcEB6HxoJnBpKDfIR3k5AgUQd1Wdf2TlaliDpWQ8rhVAiLoYaqHL9k
EAZqsHwXYbY3O5kp92d7uBNz6WX8ZKEWw3TSEPz/wblsxQMme5LjfiGebVLFiSNhkrpHiWfvPxpd
2sZ95OupGXsKvBNRQges466d2ntLhFB7e6U9J47Mi6nKHEdSFp8q7kdVdTDRRGEGOPzc81TBrj9u
MMtTY64EbGbRoL3ckEHQgKgQQL4F2D50e8KYoSK3tLH/WVwCiHDKX8GtayV0EoEy1gHig1tTAEBB
tVn8EyHQJTsZestD8VrsmgMVX0w6ymF4O2d7JCH4g5eBoamxiaQcN/nMfdqkf/nPbLVNjGnrg7Jo
fQ//V8SticeQmVpQBuf8hnxLiGWS2qHqW10FMT5NXnQIc94xK72HXPvR05ZEpSWCTHtPUa1aviEY
E9O0sKM/s69SIBt0yKVUncyTt7GQLCvYXZ4frdjg+j4zF0F4+rfNblEjFRa73fBqL69B4uY/0k+0
hIla4d2xSjCzJklh7X3LfYcX/DnQITck5BLoLySEde80/xOt5fHXCXLCUtTCAdcJRazXtk7ndkPo
xuxBAH9PVIjLKMtfSZGcGs3OkmGQomVKI3LVmS6v52cTcYYJ+6ZMYR/Pk+4NHFF8RAkPWX+m6XLf
5CIw6zOVzDWC/O/seU8kN6+AfSoxC9j1WJw3wAasmvpt2FmoA7qyn5yYdoKNioAcfMWeZfatp4A5
ALFZ1XRL8SHTX6hvcC1UpnDDhp8iCYcDO72vyudjZYXm9Yb00eOe7MAnI5w03XxX2Rb2huzbDauK
UwfDKuyqmL7DaW/c4gGq+xqFeCMc4KKvzHd5OmYcAnhWs0nKd8/k+6/rzuoz0rxQviCfud192vEJ
jG6plVUDJYbZNr2f4EY/80zViJDI0iZK/rke19TmTXuVumwssiCpBmwB77+DLR/bt6Yhgp6Zi2PM
yYLGm5tdz7fYZrr8cazwszZ6RPdaqrOjHfPd+r6kFUPO6dC3trkGVL6M9ju5AiaI8fo5vSvx3LRs
kG5GhWeNPfCf95L7kh4hpmlS9jDzu431ayn8/khZ8PuPm4fKJy6wh4aoSEUBFPt7urhXBwlu19FH
tIcWzIGL4N8FEca8UdqnUe2JhHLFJf3njZR3XHZYolIJbunJV2T/4fokymO+HMkOFSLB0ehsCs46
hHKfLpk9fRVTw6XPzmeUytAB5/2+aiEwzaNQbvEeD95xvX69Z/podk7vOxqjO1OsNKMzEH7ap6UF
anvWXlbryKxbcjy3cW9nbrFlzuC5h1OiKf2cBm4tf0zJ/COshHWrXDTxUmbQSVatAP4uR2NTWsvK
kR8RwI8X67E/TO4fRXoDM3YyMaN9sq5tESqbctja1HDYC80RI+zikkFtKyfWvzKwo7Lj/wew1/ba
N1OHpOndkYDiTsPclv7cZxAaHH6vCmcqkOiblEq9Xhd4HTjpHRrhrf+YpC7PY3vLbKZuOoddpDqT
nfRQH6RXX4Nbo0vJ0U98FCOEsrf5wFTNI5raesVZkF/hdgbJEAgLRhkABsHOpFgn2kvlk+U2z7ys
mMqPVi0wtiuGvDwbFQ4QpeZjlDLl5vb/y2SRQMzqBuUcqm1OWYliNUSfaRns/sLiOm+jOEBlGJ8B
seNDyaSRXhpEkfVEbLbmp9FEJRDwab/tFle+CJmc1gr1Ljtags3VZ1sJVrG+RXp8HqFcEucNAJwb
Iz6Ar+F8uGm31BtgmhfIZtdZEHIppwwZTYKmHWd3HCC6O8LThQohQ8L8Vd9KqrooUNnseUXpMTts
Kp0xppqCTbujyccPnuEFLa+WTsRjtvVCeAer4sf8avzT/oaOhjCqSac9GO4fnEpZ9QweGDOa3Tgb
UQD/WxvyieqR+l0KuR/MSKr3SOQBQW2SFYE4+HdRVmzogVglKGYkJcxZAc2FPEcuzf9DQToHFkOX
WuV0kHj3Ts9tNIRm6c0gtgWNGs6rN+HSR0Y39BNc8lwDMpurKfVM6hgKuL0Vyyn2AjDoQDjx/YXK
rJJiPbIyFSMWUqC1gT4LbNYn7l3zSRLlmbftqFg32IeHPoJUWdweyjtT2Ljfd0d02p2J1RuMQv/e
AZFTOmxZy+d6NmYKZK1JmGS9BNn6iiXFEYBXKnOf9FeLn0dLI9KbI5XI4NG6LZThU/0ul0FLfdGW
TxDvUOGqHNFzwY6Wxkvon+jLZzQhyoEM8tBeUxnO7tdHRWcQYZHve76thR1pRgW5Dao8yM+soxvM
dlPKW1UxRlqekcLMFxQ5YSDkQ3DDBudlpP9qgXvEtiP4P0S14F0Zje0feuADCJLZ9cR8Hom1BYXN
48ucqWah3cIDRgQPIRDPh1v7uMQnvPwCh3QfxskhSGGrOxQqXHsJCbFnXsxO281HOgddAETN4u7g
O68LHQ24sqVLK3wuwzYtFnDie4Z6sqKk++nd1P/OKPOK1kfu+/VubTk0gtbzs8/dkV+RHJTf4sir
cKcdl5y1QRXOehITsq6lIMSb0uoMQQQY/iKsqbrnr7Pw3DwkK6dVVqTfcJEGx0RVReg+x3SgWmSi
n6vj0zwEgXurpRCKH585thBkacEogasprGPRI1lKZuZCvmmgdRD4AiEveyJ+xLCfmHWN0fAFAwGq
dHIqk+uCUTD3DL+DWNRRvN6YvqrCss92truyDudvQHTKbIVIAUe0or2TtIgaCU1Ew6DlizBXWivV
u7nXR/lTC8+GCdYc7/ALLBYGtpStOLotwXkTHcIYbMs4lQKjvEpkkpHURi+Jr2GM2AONWZJ8YAUo
mbizw/3ZwbuBR0sVa7woiLJmFjKJEboNSikXl69iEoV//txessYgNI+390AEfk++J3aKiPj0n2JT
ekP2hdMycZSvJLpKcbDrRqmHpKeoiRYKAuOIStl0cLCpPydkutqmWNHy54ikZUb3yI8Rox0g1kZx
Y5yIzJFlFfJ9c7L0YXxOgVJJoPwNtr7cO69P9kOXr98+sAsNwbiYCFP6slWvGVPtUQ7fYS8dv3cG
FkW9Y3/iFrlI66v9dKxfrfF6s1dQ/hZQ9aTpkJjgcf3LVhNWb7a45mUv7ItP+k8Zca1v276P3V3L
HliHR/+FqUKah5QMCqD8rXKEzy70Kv14lWZK8+l3tRf7j4Rp66ftwruJXGRTzVFnK+0X0sU9eBCF
6cvGltWS194Okzi1FVoyNlRyMyu7Zkben8jcDnsskkyW0aRkQt0tI942TkuZ/wlH2p2Qm/cLTWP3
udKPdMMYx66cwBXsT3CEz6j7TR0whd5trwYN389A+hEt1hYsmLeEfycRnJAPq/BvY2NYR3tReF94
mE1H/tEH3vXlf4uE8fhQ5FkvRM8bRT3J9xddphd0jtPoDTFOQySbGfQrTFEJm5NGUzcFzxSSwS3Y
QtugjvHIrJbItQaCxLxpJWIx9kaZi6mOmWKwUGVqorqiVodFdb15VoH/eDQb1vYEmpoKOAvX7InZ
Wf/ovb6YoHV4B1ejqWmylGOMPQtNKqjLlpg9bMRWu3KT0KX3wzFUIuzpm73Rcmexf1RL3pDCdhzH
/reYJmew+aIbM3yZH7C7WH1+vjJRsS1HgC1Fi27R16SiKIELYEbBLMKNSFcspqBke9b/vQ5P9ruF
242AX120ani2241R+3P+KdezcMLKwqXsjyjk6BLIW+jIcUI7OmtHiPAYpArazslcXjHjBlGps8qF
gBDsVPlZXdeBU9LNfGvq/Y+dwMSYiZYfmqPp99aqToq2Tz4pHchBZi6iL7RJPnkxOJ3FuauOOG3m
GTZDsJ05sDO1gJoWwQf3gf3YZLsDwasIyHmJljN9SN7GwKy3p1lwD5ojD6f1/d4qdcwhmvxBlqAo
hziKw1sMtrc7wGPPNUBJo+KlQqCMXRlUpcUD12UpmBMiXPbguRJ1MQ6joLorSrRDbJilzzsJ3BgY
dw2Q5Ik8eQesSE8C194/m/JwDud2h4vbSbTr4W9uX5zOTGnBi0563yVS8kFFQ0471SoIzcxWTDPO
aGwVKkDelaH0d0Pn8E1Wam6pGc8BMw1PNivzWc/HygPBUOCOGbAV4xx481Jv8hyvYSO0Uv/QPE1O
2dxkqIDBd1vFDrpguZ1ExoJ/fKpi8pfW72+jT75gWfug8j/HvoOomZ91Fm3Qz9riHbCx07QM8Nyb
ApjWEYldR6tOYU3sx6vPXNou3pHivJLCga0k+aL7ChiWcMNMvHKxYNtfhPs2pT6Z0/pWJhLyOimp
+HpBcEeGaJcDFFODbZ4TKTQnV7eGrBTDRA9ZDL6qBDXUvZWCqclWBPt2j7/X3fk99EK3tnY1ILR6
bms3XGTfil/spHAeODp+jkqbsYa78EC2hmobXzMp/ThGni+jAf+uMnCUojqrQpvCd0cz+LgUYNmk
Yw2tZ5rEPANeL/ll540c66gEAl4hhq24P6zp7rDfm8nk7pmDDXgvTREACinIaVA6VwNW6xkrN6jZ
HLZGc/zVnQxoUagZGGMTbOCRP3s9DBcGj1iMQUE1rMluslxOXPMnG9kxQ2DGkUUhknl39TREfQXT
1njToKWrIfsKXY28eg+0TQrHgb1GZpTK1ff91/e6G10occo6KfnN5wY87soGT/0rEJRrz+50eWMu
d8hoxn1yrOlxoYzyVUyvwJlD7eBQcz/yQRsLPaSIgAy40MQ38lF7aWT9zgaczR9XNbd9PDQ25nkJ
+Y4hf5bEUeQ0fUtQXZhRuqQi4FCFxhNRe2cToYBXf5dAwGK35UuOqnYad03CsFtBrR4Oty8BtZad
cIyTXKaWVnVciBq5k7yj5jeZ3ic70fZwbRKX53+x/j3aHVx+GH62P3iyLiSuZ5zBUFTbmQPXPeRM
d1kmuIeFsPK/Xhcwf/hTE8BmK8BvEgnePD3uGOG1H05FsL07GpB5mhpyL/feL5lWMbYqiraBfBAv
Lo+XvR8cCOwLqYjEA9mFrfxZGshRpXHp1fjrh4yG6WO9TbptyXfyCDn2lar46BOjQucKhY9evbqn
KUvcDXs3rsjV7ZX0A+8rEGjFAH+zomAQ2A+sRmd5YJcnzdz0F8gp6OBHEc49b/GXA3veV8/sWSnz
s7qr68eVAoKDWKNuIgou16iiVb3DC9suGTfa8CsQQ6RSwGnFnB/RjO+g+1c8jO6oAaglelG0LCAz
qOR3eWxPmHWeOyf1S0GwvhydBbJGR563x2fCJVnO8cWS++AZIF4TU4LKy47F2MbsHqGSQ9Z95HQv
89L3fHEkCBXXs4M9Q/1wXwg6sfQijvobR1AfLbhbxuDXqw+iU7ypMPeen6uGuKec6d6imtIDfE73
zH32+HwyVX3TTU3vLtLJWE8OWoy1Z8QlDppVt0t5AJoILQUjNq64Q2R7gzRx3sFfWAAzLpCZNriV
3NOTCIrI2CIP03HHTERgqwR2gZoW6sVpdPtg6ipkXxyZpOenzWLkbb7uvDxEqNBTC3CGx1TAwALT
svHQQISd+jN6H4io0SqmxVlrYjFRTP3l6jmbq9abG1YP3+99OA/hgnTeIP549V/8JzspXS5yDkfC
tSIdDlGt7OXstZ0Eqw0OlHtcas1p8f0+PQlCuyzaovGNPSV2gFnheS+7jdCMVoVHp7quvMJyYw5U
QJSx+QSJhqEd9XUcIpEyRqcWmvSNn9qbOxLcLhr7wURcnxFmNnzmxfZ7aDyfKP3BeMmq3FFntHd5
Zzt69y7BXLUvUjmBoAqJxUFFT9Y2ACvTIa1Wa/88AGKUr8ie7Y+hAYkbw78CQ1NzqR72EQzTwbV5
xQ2iAkaAvDAgJEo+urNHADs3FP3JGB5d/J9nY/dllfdeCFzKuGHrECxFMcO7mbmOc/JM14l3+BBP
1mL/9rTVnaJUyA/UQ9wYdhH6zRnO1Y65dKUobqyJmAbSI2nIlyzyenS0IjGNMm5dEZ0+/9s5Viai
MrnRCo7qCqMZWtuxYg81nUkSKp8enymNYa89aUaGAjwIcPW7xMhSQwObZagy/Cxlyg5Zm3+JAmXZ
8osk79cNscdOE62vqR5l29KwPolD1Y3nCFkKtXA7i7/jeXGyGyAJB3Om/Mq6uVbWSOjUo0CfQG2t
W6YEGlKrNqRAwvtSkSEbCeewiwwr5PZ8Fj+MtSY4M/AYJNKrPhg7WfcIdwWpf1FAI5FksagN2xLv
jilp4BZ02CH+NDRpkgnvAhH8FmCzwvj5wG5zjREvoYWlEsYq0KwUyn65lV2UlYnCB3gaxxdiVJOj
8fTb8xw6pgB5WJbEgtsNmLZNmptJxUB3kbqVYn97YTc9Vo0nFZ0d0HANxFhMRl4uUCOB8dat4Oiz
YC/jLj9FI5AtfcifRMIsBYM8bihglTZtaB3vmdu417CL7sCwXNk44Aqv84H4AfzjSWE1u23xOStc
Qc8UiMRbYta8IqrGAa8WgVpWf0oa63FsW228/ExmfOnhK1BmEQLJ3wStVJWxqMzN2iPDzA0zl79n
van+9bligzW7j2PZXZVHQMK5s+yEdi8+HInTsG8rY2nUNrb/3K2y1NTwsdVl+w8SouqeLLjR4Lj5
CrcHHylpefto+XhWFMLJk8F6WIE6drpOby9q/UOlkbmI/6ypFjHSqFZ+HJan8a/mEw4dmkcOjXzP
rP7HXMjo8ceh4FzT1NR738nVJDt3IdyTkQFlbaQnJuL8d9U5hkhHbwjVCy5wx9pLsi1K9PN25WBn
VWlEBVAjjge5dTv6Dv4IUvNJE+7PzWm04+A+qhm5gt8vzuNRF9ntxjaOHlNGFY5hlHNBgKWFL4SN
wmgvzhEkmUgu2Dn6c8E9KMn3SL2/XtV6CmBK0I/G8/zQcj7wjGKs4lAZzjdOioW+AUHgy/sest4f
7eb11nioepIR7v+eMmoEhXbkD5eWoyVugpH/afYVq5tyKIWEp0p8r3wE6s+uzjMoC/o6GWQcZuYW
comKG43GH8u3mBJSiffFMApaNME40WZzUtGDsxYNLLTjLFcI55oOokvmqpvLKmZ13kD9cOJdlQ+j
heXio3KEHInIHDQYAhO83kf+PyGby+OaPwJFIlIxG+SkcVqUfOBdLcAJcVc41gFL0/7bXe6SwuY7
0GSfbPW1l2w39nvuE2d3IhwpjOcH/hbT0h4HqKL2HU4oBzMZAjETzZd8Rndfoi09d1ASyoMO+eZ1
orw667C7UhpCnsaaM5NM8+wP4/C6eMiH4YBCmcJkB8JA2TLv++rOFVm2kiEIKMzSv+YOOsfei4zO
0OP5VjyjC8mbw9G8HH+ArsYiyTZjsoOGojiD2QqTmqkxgPEQEZ21IUmDwVHnZqtQIpQqnmT0zWKO
AI8lZP+87cpyKt2IG4AT9QbowztN+K17PcxoQWWAfE23bEzRPSrIjw3kQrnD2tCFkdhreYjSIizg
mDl4JA/ouyVnHqDwcG+LpEe2EMiKiWA/9gVAnDwbsMKw6d+T6zbpynCPIlsavXp2pqLSO9mPgX13
0yFwOCT/DcjDsHW9qh7kFsCwOLnNx+ufUg2cQe8UGqfYx3a3CjzRMyyei29rBozWk7FSTn+jvtv9
BUuAWCoT2jILGjp8pWM2OSRIAcfMNnRZDnEtDWNyduejvuZqXTfC1gr7NTCizgAdWHV00fceAy3s
QrU7sec8HdkSOMIBgh0l8yq+OwV/BhKelrCVAkzcYDq+IPv01upxmhFEAHTkGAuNzaorqjXWijNY
axyUezpMllXFUc3ZHcnWbrr+0CVpSGo/VIkk8zEWKUT53ueEwonJQUCuSafgIzG+P7nlTDXL9Knh
e2M6LnN5SQ9EOIZDNEpSGMkRlsuE8YsNQAE3a3wGBcpvjRA6Y4+pNq004quEaPC8GrgV6Vhhj+v8
Xc+TToU04PVTv4jZFAhNVcN3Ewxp8tBIsb8SRGj027EPByYGo/ut1DMkcrPP+Ldx1bS4bvD6qAIx
S+DknhrQf+0KecO0sbE649Wh7bYJlRWCMEntEGQ9RckZp2+UmgtUl+gUBRj8bQ8iyYinUP0NpK6n
Hj7vU4KQtaF8F3US3XSl9bsXMGJhutn5tMHDl5fibFeLWnpjWp69cXMsd6U8hq00dBIy0UcuS71s
YiUjlND24xsEdGFdH3/1pFVu1Gi0JzePLKzcXnVChvS04XIYM4bt+yzvxj1UsCUzBwsvdjshSWjB
ZHgbh91tYouVOzu890Nx8oDODs6NoFnQy41ekyPi+c8RHHCVt0+T16MGQqonkmUocNBRpeOKP2hn
5AUmZDgN9L1NYKSEXdgSnMAPL8sacrOV/feUG2M+qlNUJ5SXdwG4RFugT3EpkdmEqZuMlDbwLMNb
wvtTsew/DOmEmeX5tp8kCnw5uORTqstlEzyA55RwPkzjU8B3ynCSZE04ZDnfFEWNyYBLw1wMMgm+
gfv0mMReEafiiGrb72jB6erevJmSSPUMI2ynu6EVfcilnLKhoGoMFBaH04XhA43WaZC9Pjo13wix
CHkeR7zjikYZYJ0nFCFRj/sRDkNuQnzxjOLUMWlmFEqPX1ipRqt9muZgRgkNOr+TzjPS9dwHjFlE
BQorpQRtcL7/NYQ+CXpXGruzxKyXGfG1JbFJ06LDPrWlk7Mk+2y1Zj7Udr/vrAcHIH6pz5QdyiTC
oypm98IAi9+944T95vNCYf5gur2f1yH3nim8LH+gCkr0uM5+GIg/tJonW4kwaoXuiCx0sxhRC0Hh
BfbsJP+Y2dfisCNn2TyfAgW5yNWYGuM5fNQ/z4h2i0WVbSkmpuXapgGXECMadga1CJLdmI7CmEmO
/l4fOf0QNFXVXEgHCrFwtkrhC9p6NLclChU+GdjkJBkvYuOkt1sjMbYpNE6cneEs5WoyjB4/WCSI
hNhZx9i3UJk1cThnUharfyQ0ZtiWQtkFSG+eJ8yonJf20zlquqT2q/KrCYDM8ilroOzbDLXipxnv
eRMCl0SyrIk8GJd0JxAhp9oVmm79kSb+1nfq80zfR+5d6IMxFJ0N97xRYwp/kvYe0ri2w0sdOBSf
Ba7F4MfpUeDtYQZfhaxCEscyVfRswdBmK7ppy/NZJpxBNBSR2TqK01rJ3dpyZCNCYNwnP1gMYaHP
qtMNX8qgj6irTJh+TWSixlqA3IyN7n4WeWwCXLtOj4RR/giN9Xdxcf1e3LvwC2MvjRd72JtuvqjI
1hImeZqJK+Xcr2tjTUHPOJE9RjLpFdw9lOv2dDKBs9U30degXzcduXBJ4TJPs/af5yaZ3H3r4PtI
ETjxfkrvjEeROzeUu5xGVDhOYlZjUaHwoXmarPaLd2PcdrQg8PLp+3tLKD6QdP3ulv/H/YeLkSHb
DVF4hz4hKEbIwPTS9MZHGzfnEj7TRWjIBNU127483p+/jEJaXewEFX3XJTGRtlwfVXIvlaY7Uu4t
hMvu2VL+1GfsMDgciuLlosnFhzMBoTYoTrIxIathsDOZw4I6d5qTh11jZGKKU3FeArHHnqee4AMd
SSWXw5HJo9ibuyQC2am4jKxhdog3BxvJhcYyyKEckVT1RDK7ta2QcaohsE6aJtCuj2fRtSjqRMAX
ntg49HM2Y1/88sQsl+7Vopiq0phdqVde6dEyqG7Q6t2xRsE0tjSkmek078D8yAv2BmyE2fX1c2rd
k4EDd/WYuQPeJwr5icVH7uombg5HU1qWQQBm43dKvjIDZJ32QKXQ4Wkp7dEID8agSrtAlNrQ1VHg
YTxY2C78PybFu4gSwMysBlGZWr8k1ikSDI6s0JD4lSJ3uBw57WL4XAb+dF0WANPLewLu+nB6NQOw
SCSfsPnKfQl6NWT7oq/wTplU1nksq0uupxD80fE4JR+eT6Joa6n3l8/gkzq4YRjH2ZePbLmPkN7K
1UTDeyFhPjCNz3ywZ7E2WQJbWt/4xeG45TC9vtoAHTZ8Edc7RUdsqywgfurnIyVI+E5UVEI2OH6L
YZ2jyrckKBdOc56zAsc8Z5U9Xh60HpwR2thjtw7jmL116ev8vBz8B8T4y93nHOvg2FA5ZLba6ANq
+hDrG9brFir2vg/AaEudO+OT4KQvJygnjWAVPUgdqaO1lSM1bPiDmJUr1XNO3YmbSB6Y6pxbhcA1
A4uyXdTr+ZHVeyjqgbI/wcf1uxeDXWJR6CjJ52GPXXlS82wJbxUhu/ZyFdZrrFqKA+Pyb636wXrV
0ErgFfbuHJojH52oWt/lk/aaZpjTusSi6zLjpHQyyrlUh9142WVUQMMVxKj2gHyw/MlmPfIME5ga
EhqreLEFZQkj1sWyTyuEHDAwhmz0SPFAx7MfzIIdFPzkzT9Hv8cQ2sFSKUW0GKpPX96aXgmPWljq
K7BpPqd1BOY1j/v3Mk81ks1fDkFZhxbM9FAWUuCi3KL6ODamOs2ZwyIWhAZhXGBTW/TvvyTbZWtD
qotpY+0InTm51TUJN7nBKnaUBM9d5SnscTe0V+UlsTClD14S/viMqjlyYHAnKAXNpFH1JniI5qaB
MgPgVzaVJNOUbJml9gNC+f4fB1FU3EERAx0ZKjbdGB8P0YJPR8pv3OSkGa2lEgRaiyNS0aB+diT7
kTp+6DZrMZz5rXws1P2q2e/j+IW9j/cc/RAfweG8xBPdyXidJzSLNFAbU2T4WHugLLphR+hhTlDk
OZUj9RiNopuALraoA7im8CNQfDl2vIE66hw4QAuik3W5Ck12lCfyBy9u6LA5ssIYe7cr03Uiq5pA
/ntDjgCt7VVNZDBE4mND3l3zVp10x4aoRvZAwAhdqK4P8tzAxBs1MreTs6r2yN2yPwdiPw0ADLZn
GtpedLL80Wj1oY0E73Z6aV6aT+wwnTkwFQQ254OQYdRfjuEnjmoU3KewujTBbwQqlCVqcveuI+dz
CDsHJo6mfLCe1cOLvPV/FLIzw1y1L3VsH+peoPWKYwSDHHp/vw27CMPTG3EZD9q7XYGsG4zTm0kI
QllkpZBlsFYofI2t4tpERozlkvud3pIqtaMusQqBlRAebAfcYeVF3YMEfONzMq5amXgBeUcj2I6h
CoIqtoGcNrxkTOPdJKzizFJJGbQdp48Sc+Bi33aq43h3/69ARAQW7Vy8TjvOgiXkvMMZv1e2xLbf
kxt8+B20HtUoTMriM1raq26+ZNEMnnvigS1lD0jwaTN4ajMO7V0VGtGuvRMnVj36zTM9oHwUq9m8
h+aBfD823o0UJOUkivMOXyH7t2nYPwtrDsoHCuqiCPc7iKQq4bEHQFTK5x0okG0jymgNwOntZJ8F
G61Wh5GXWsbalqzUzsIYmDBJ2EFpGK14Rvqw4sNkwOd6wEXIsKT6aOQ6Uf80h8eq4bQJCon1HC6U
+ACxoQ8KwC2craDerltVo9Jq+iDVKGTmZgDGd4AxwSsMCRzkbTbCM4iQXdT9s4ewDggcDqG/eniI
HCxznaa+CleFRa10giXusVuCvk8l4LQpv3So2sQzzZjS3jNIm11Rkf1SEOIUpfBN3CtwMIYkEh7C
Q/0ySj7tYd1rIsFPa4hXELpRQLRkvo3qptu0xEAHgSqjGd1CJ3oJXzdZHGNfs5rWuUUT1EjHQEAK
V/nKN2T/IVjcIHXac/PW5TPn5NDnIEDCyL3GSXMYD1VBn3+/sXiVMOooDuMm5StUH5ctl5ehjoSb
OF9fICwN3rgxW4UpIe8/bdp+Mb6hbdL9/uXX7Ok1UCElIlr+/GrRYwk6tTGJsDlNnrE1OMWClO2Z
vSTEBYYsOu4BH76ngQz/r/dpx5awGkCWLJFMtwZPmw0gutFAeqVYKizY/OQovRx2jNehFYyKHG6L
Xpx0cLoZ3eFZQ8/2URbGYBpVTmXHm/k+T7un9qHf26HsvmjP0JitbSlFPd0hsqQoagLqjSEPTfgO
1n50K/AuY+OCSaiDlS3ZzhZowiStzoiNqI75ovQhxkQUP6dDIt1JtxtdcvoTRAmqeZGxkM3brciK
dEPx9zqFCXH1mBcMGGgeWGGxLMiTfTFP0CsRoJAN3NSS2MiP9e4XXsJ42Mls8YW20FASJ+B6Q/N0
Cb5hdav6jmLbG0a+jOSGRgKmifWwMlqb7Wp2WMSvYGtfejVjyQl++FuGJ360AFsKUkmscT0kHJGK
495xh4xGF9vJqEjuGk66lGbiF2MCabUfxl/xRsFTF0PhOjF1idjRw5hNfoW+5ogWfq4HNQffWboD
m0Z+ixdEAGADALa2/rUNCzq84lh4SUJpOytby7hra8otAYviQh9GJDgXjZ8sLnpwEDgI1jr7DsMq
wZuI3HV0UhEj1SZ7AIdlnykJDRFo0KkJuxMHy8qVzxEbnSFdEa6YVDq0/sKb+2Ttbv2S41W/CjT/
y30ijdWr8ruMqcojUhE9AD0si+i07pazhLuz913PRis287m4V036aH++TLqxFPw+RXq9WeqUwK8g
hYsvseva1GFnOvGslj2YiT9vD2fdyfIe4Sg5fEES4IACtGCDM8DUcJmtSGOTUbLayBzwvhEf4rRd
nIy8yWN9gLKHu8gZcG/j1I8CXhRINEquUL46CPuGzcPYW8To8CfYbr7e3ebQDY6I7Mdx5LfeCU4q
SOcZDtWpDjTDJMy55ONT5/G3S2kjjL2sViclfpSN9iaUjzl30WIbOAnNVBrQnBj2rAdJ7IYiAu7Y
yjhcSRLJfkW93g4tkQNIq0iC6gIlNVplxlzghGBKJhGV0KnbDo9kzy+a4BNlLWyOtFOX4ZN7EO9R
Q0YETO7hdXqqDGA+uHYsAd8VeSZjzXzw+SY4QJFL5IIcVmHnCnMlyl6FTYUdSb4IGfPJkdyLO+7D
Vj7mAD1SR54fIrP5+rtg/NcMnkgxIEpSWXZb6lCNwI3RjTjrzHa9btR0Hni1YQG+Li9itOd7gfB1
lV/7YCeQCpEKbYDWiaMZkrR2uKcf4EfCOAhQzUZeEIIQTq6GHbx1hQ/Hy5FNveLLI8qmdpxz4PYs
nfKnD5VR3wJSPZxAmIXfQKRAioky72Mn129jwc6Jl8taIIJu32xnhLt6F6sJ+EY+zgjODZwyXYN+
XLjQADwjql6d2Q2H98htbd8Bw7+EJwSm3mNkQe9y20dHz3rGtIqTj01Rt2Ka3+9kYj1QRqKD0gzu
M/P0y8VF7GusSbliWUohly6+2wdUO3qHjNiUbi/G0JEVuDyBjsy55J30QG/byi4/4fz18I9D7LaW
SDlD6PS6HUzuAST8ccx298RENQkVsFlw27D4nJPcmxIz7tBkP+RhIN/Zkq7sdp/egV7InojW9VP8
/lw/gC0UrQWJoOtUDR3xa7WBMRc6sxXAjuTKsLBR5T/99P0b2YTbw3z26dwJYGTMf3xKy89RmM91
dYLTxy+ZBJpFO9BAubYHWK+TNKbYo46ZsqNVKrfifhEgAuU9f9eEW1ZIgO1qR7PxVJPXF8sBezZe
n1jsI7QAv0eX01RGpTg5ChttFBa3bbtpEk1QoNXQiKFJ+S0rqCZQ8EGDo7DVIRat1lAv6y+kQJbV
QFi6sBeAnoYxaefwGrxM/e6x5rRAWSfv4TKP0x/vhOQ+jnCXleceYozwCEVd+PBwBW+kwm1vEuam
c0uTSgbc9vTxDjFgwfP73fWkiLmP+Wixmbx2ZGUeVXiQYirrkz+al1x/Wxpvpl14w1Vpn+4UsGre
+hmWf6CA0jYBE+E3N3kbbo4QuebG3vaZEiTXdNWOguIE0QufDZdAMyYo09wUJ3fDHKRP9jlCRDr/
x9Ccazjnd2FwnWtOo3O4B6GNlONGZgMxYGa+pATqZ9KDBEr7yx6kLDQXL8Tra9woIsSrLIoNTynG
EEyCjPYN5uns/0yGwooP7VFFNSbwQLwQ2udA9AKZIMbKsEnH9dqkZCPW3oxEKEfA8mIwfTDArTIy
TlkNRyQj7HFzHZeSNZetWCPr9zDgJ+SP+unpViL+5GQ72XsZXfchkHAJi2wxRPdPvBXyLQ78FmMW
JR+drzkmEqk/thwfAespii8RuvhBALL2MXEiUFGqW1ocnStorIIeycDvT7o2wV93qvbFZMs1/Xv9
TUMSbtj/pasdCLnai7SVxbG+8jxCNNbf2AocRna2DqCUjiQMex/5tjM9DkTFGnBrLQrAmgYYFukc
Yhy+au6fUb8UBG3g/uVIVh8BcE5LMUzRu4XUcHldosHRIjMgOggKel26c3y6sCWnG7cwM3BSfu9o
+ZRnQMCXbWZImvWtWEfchtlQoBfp9k7c0Aam842ouyb2CEgz3IlTAOYqEBG7RL2svhsi1Y3BKJiJ
eDz0fV4vbXBrP5qJP1xmTi+U70l3cVMuPb5u2JWapi5u+/Ee7VWyFWHFOWqO6RhEmtivN7lk9oYR
gtbgpRxGwkGZQouQyzPdy7JqY0mtcGVf2MoTKglblztza1u0+QvD9nMFFc1pS85utBi63lR3sHqH
apngfYa753+/KKj3bozb2sER4QAEUE8ycO/S9G+YI5qb33psrTnq7JjIr6IgjL/XWkAXyrb/Fzwa
FB3i6kQPpljZPI4xAP01vQZpXcYdNJISUkbGLohPmSNNi8J88H+Axdjc21CdMzMDJ4HaJpOKuxDx
Ryu1FxWm0mhxhWfY5zPvwfZcn0FgwlVAbNY76NqhZwBR7jIsHMaPCtEONJLtHNaZOfCyPEeRh+8P
tkiLFWrw4pytgx50oXnOyYDLGL5IGiNkQeVEmzumM/V6eQbmkoVgSzDvBgk8aaekJNFyDpWbnqFU
S2NtMGzv5kysYS+iv/ZEIwawPv3eOsOCtC50oATBI12PMDLDI7R+xkhKbGiAG2EMVRXmrzBQdORs
nvuCuoO3sSl21nMv5HCOc38qb8tTlLz4X84+qVgMNBV6CxEMFOQ+TpGXWmDhkr11E/hxxUHHD2X3
W+pDxm+GhPDN+6FfEi8e/EsOQtV2cBmdhLkPZQVsddRUMErQsVpUn6R3Hri1LQA8wjJwcI5drLq+
VuMEXuL5cfzaN+aTiiTKyyDmwPGZt7kn7Hul/a16ncRUYjBC6WvoNAl3WB6MZj2tZNy1clh0nYQH
NkXL5VbbYGQ8WCO3aTf+7A6giTEMs1sxaHZM65uPvgRjooQyYN+cjyU0Dgp8k/dGEq+8l0XoNDYu
8BLht2+94HNybrC3hecbhumF0hURAj1qUKmCBu8xBbxIT7TAlLmpxLHYWrEuxjt19PnkyHd2gfQP
nLIGLnlERQr51T1rlbL+gZU0K5bCnn/Zg9xxIEP/KbJFeysA2H+408G985p+i9iijDiVZbchorC+
VURB+OOKiQmITIIoqhkAOMPtj07fd3UYE0EnLcp+8Z8zGM6hpKXD+70EmrCT3I80Rtg2j7YNVqBR
s80j5vblvY4/qpVlZe9/4pmmKvjCZrNE4NvA9RpgqE9nZ5y7VBefrOzFXY5rdbKzDbFPTqy58e00
9Nr0XJm4hZl1EtFCqPUuXlZHrmJSIU2qooJFqDeT5r0HCvKwXrCJT/9DSquygFf+sVOrAl25szFZ
1o+j4pcrIuGrN309iM5kDg7ndk2VoIFndBcFHrKyBGxvl+A1NT/txZklK8w/vlXqrjQ36E27b/RG
AYrS76YGdxmDGCKXREMcGZVJayswtKubau937NmaMWVqCqwCAb1RGMP7LPZwX310NJLo5uvITWNW
6FFH0JzZEALB+6z3CmzkA/7wXMJwQhBCxy2mKFj2zLUfpEe5dRglfY2dnBTiK7WgPBopPA4kh0SK
rFL2j8rIcswiXdGQp4XUrWcLyviJ5FC4wY5gjtOGzYp4c06hXhw6V33FKaqpm9Li7ki9W5HzWFV0
wUXJ58LlyGMJWeeenM9uDqfIFltA07VohQzmhFtfKFZdCDdZmFCta+Pm75/LYLuwVjYKRLrypPpl
wI3+i6lQqc0CBk25TXNGVAMl9VMR/zZEzLQFbuyb9oHy7NaES2+rF+gI9rlNQEz8n0Shmg1OSdqP
oU9F/mYLGLzvx5xjhji40Gw+vA6aCHNeKJXMZNjhasBfCwRVYd/pXUifyHNYpayQkkQy51cTJ3BO
CDknj/DhwFjfl3Fn2GLiKeodOewW14y8Gme3MJeJOMB8nAU0M40/YTsIbkwI2cSvjGCzq8dN/2hD
oiSCiKsOsh7SOZroVLuvzTkAWHRFHzQbzZYzljHJv9xwRcbsKe6gCyHS61Jnp88cdR+7/Hp76Or/
59ciqArtAaLyt4vwy4EX6PjN32dpUI/9UrNzsw17BFt1oVin1DKrEEMcALl1p8DusQ/Bri65jFQH
1XCwMjqgMxVSmlraPPeXZebBqJhqWA+SHxj0KG3jdrG0ovNG2YK/O4YMgmUSw2lJusGWLeKBhwbT
ZYBzQ3gQ7u3q30KMiJVzTHtXcH9pHUmuqE+BbFy+DwxFdbx62kbeJBmGp4/jhSfVhCIxS9py1Nal
jzQZYkWGXR7VBnUrmSYIfqwHL23UtpqSr2nJqAlpWw3VQi+CZsBjhzThN+u/utfFeUq9pZ0hP1QE
UJELAzxBrpvPGhIj8E0dwPE6LmlP0v6V1dVzNNQxL9Eb0pPv0E+bWxhoToVXTmiRPukX0xpBpIQd
3pcoIHf0Di9XAlZS+8Hn8LMATCEW4Ag4tKG+6jAdsolBP0WgOz7QDVgu8PQKDqHnO2kmUKKay+9l
BodpiI9CuFcR6NUNMnmZszVX7d3B08oOgkgIRAsIoqiwcgu/MAIiUx+PSvHEAmix4Wg0nQqdpQx6
aGdVcD9padvTwtbulJ4nRrcLQbAS9QLW0vMiHIoXv3OonMOBghw2KwFQhSWbAN+ZCpG7WXjaVWpe
K4MRJTGBlx9EdkVG/kZzSYGBD1C0CZnnO/GPMC+8yVsC6LEIsV1XzGB1GE/E8r45zLMvyAeo6seW
1k4KLBJqmdqVWsKjbP2pyiyHYGUID6jT1XZHvC3/zGZMjZwF9yO7aLlW9cl5F2Zg8jQGmvhZLev9
5ml2HEAFzSE4rSjOM2S2RKpOXgO0F0xQ2BF2hYlmsiU9fJwoQa/F1SkW7bQ3x4hX7+6VABSmMN4U
5Ref1Y3ZUqNv8qNoReWyThtBroS/xNyJcZNZvfY6b4AV6Zj1eo+OgeFwyXL8d+boBykNhi7FhLl3
E9hpdM2Q6wJSvy3v/AMnwUbyDwxCAlr8PmQymjbqNRr7QjYvdLb3ffHJL0gd+SE0zYkgZvMYnlt9
P/aFN+MNoayZ2q+mkSV0X+Ql/fnnxKXl+q5mBvuI0VcwxGvyl+gQcSGgMmtxnwDpr4lA3iu5M/uQ
MvN08wKQyrGahkZwDPma5A+8aWmdkaNPQF299WO1IUaDSID4RgVAQrd7H6WjUl+arLVeQVW5yJZP
qVWRsA04vEcRC3jVMkxn7oqbd+ryOiF5UQo8mdfkStenhWTdeZ3qmxgfjeoTMngvhDaeumOaQxgS
ZpYtKxh0g/OagbN64d8umdYtlQqpdb4+gKfHPLQWxqzjIDY4aM+g5dyhiry3bD0HUdCap1u7vtFF
iM5oyldqANOXwN9Q0hFUwwXsrxKw/LTj3NyzyLNHnOsDKNvbdLWifYYFaq9mSzqWd+bKMIrOZCgG
Ml+As3Ebnm7/ue5T4PSCa/YrhIDUqRkyGWmLOAWxEdgUK0cwnoDLTks9H8zMTKUweI492k5KE4KT
BkeqwsT/j6LLLXFR/Q3XlH7ZcrKIbiB3ktmPz61QP1Au9s86+69pkB3WR4vefjP+r12mje0nS0WR
DUKQfsg6rY7of/cn1LWDxK8yZaAh87rEAQbRG1zxP0zN8ERGGfKMFfjuvAk37pcEqgdgsiduLSOq
7loFGTi24oJTiqUZcgPVhqaMwsZiUz6DbLBXM/XBNMAyP5W+c1YN7PbVZpGk4H60lI45Dg2B/o4z
UhCUCt3vUeGSkmXB1tH6J9zm+DeOjdKzwQXRi5q+UYamZsKDEK4UGyvwoD+hmCI4oO1N2eS0dMov
I8kk1kQjEMb+s9tqrY8U0fLoHw6XsG584OvpRFvu3bRnIYDMLkCaM8qtqCVu2IszEMYwmKRr49k/
nP2UB5VeaIE1KY3aClkxoElNA9T33p7b8VoyiimEdQ+6h3UeT2BhahJ+qEAoC9rrEegEcejjr1xk
mQg9Oxl9HKrMzLNpVD53Cju9HjBf9v9X3x5n+U0eh+a4DQusN6qU5YWxGljU930emc5ZcpZVceJU
2knRWoQNuqtJZ0GC6xVwHP+vaBs3tJeLJeFm6bBzqNITDSxZeO1kufWyga9vSdIBgbn9E/0/npT9
Es5Vbj/f8dN2ii3OQjdCPW+c1f6yOzejcKwecc5zwfcNZ/LXQlZ0qrttWloynTBUaaFf7JQT2b52
Y5756yqbCRa3hDDiY5XydnQ5SXYfMQX8/nCIrO3mXgbFdV3KdTCx/QxyAXVbcKBMyUpmnDsXIdV3
cRQi8BXJMGXdaOBHnZKNGvIZSv37mKTNVl7Xxb2XN2Q++DL55KYLB8d0z7lighDqkmf2DAZuZOek
Y/c1f79c+ldqlxz0Gu6yolO7RVi0nbGy2+FfKendk0D+bnY8U9G50Mdc6Z1Fv1vSN4yJ0TRl+6kn
HBlfIdgHGrHvO0FFIPhuh+dAnKhyORrkqbxGcBaTV4iI0cX0nDJY0eymOtouBmkRP2d9Ub8+vVg4
iI+pyVrfCas4PX5VUNZVOvhCjoZPvjyqAqwX0omr12jKt6zzie+N9E/d68X84Lt0G/U87zRU8pPX
/P8VNlgySDj2Gqmw0y23BFlgsaKRuS9uLnuWWBrhilvfzM551nzJQDKvYMMj7pJg5profyBtptNo
NnAUTtyK/KsBTew+V1g2ydSvOKusQydfJSyQL9/ZdLudxRwvQrjkJj+PXlwkHKl2Dqtj94KqjKS6
por0fUd/i3QvCagNVR9qJ8PzNuJCNLAf12UzJCRFHCtCgQta+m5hiKoOivBqqkZ3f23yorJwD3kF
+RAJ4eIGemEYKLTSRH1hFDRdowvgXX4pieq8S+M0KJPGqIIxjhpk7Fj4E1VP1Vwx8YEDtzjWeS7H
YFHpBEEuJKMgyOCuA5EpEIWMptlAW91lwLDyUg4fU3/DH92IxmbNv1KAzkUb460cvju4y5uWQwGA
YEWQcAIGvUt27SZ1f0TVn7dtOBbNWGe0RXOK/49CDru9JWB911yCEZpbG7U+6UGxYUUpEWbj90xQ
xPRcQ3h23F2Da5dzJhjY3fZnY9OR/4hyV9RZ7zKYz2DTAUisMk3leIYMTbmmLYu98wvwVmydEc4b
OxhQxSGpMzhvSqi1MTfi1NkE3nk97rUQxAGKsPmOyqJSDR9SEAG+ZG+1Pwc02mYEaZHiOGcxGtUk
324+2nshIWsgMwb1g1q5Pq4Q7QB++fP6iB2l9PKTJOHfoC5/BgMOkLOWUAbpIWGOf5QigXZzEj/u
1fQgawPL5uPDkGAHqVjK3Y9/xsRLcSVzol4a7K+MHCvvvzt1oJpk8dom7XFfw6qBL8q4vTmHGnai
g1/Pf/yPWqKUvi1rasldHIoxZ/TjpqI06i9RKabqlmCM4W0/DJYz2jIAiWuLbPSay2e79xkaIp28
NPjXVR9N7Q7RY5pcYzKajhEKyzHAWX95lHzt4ZtSz9P1Hd6mc/5kDujXAhOD19iaZSYWA1arPt3M
LgKvDlqIq2SEf2m0nLwBgiOn5sCRtTR+gy3064xERJ2nhs/hVEfOljQlckGc2aESk3lYgPtJMlJq
yV8yNdA0C5f+Av9/pFMCVyTI4W3h/ei9SVyl3AUWCZWrWVFCt/Fn6PLfEeCzzWiNuiQ6ED1mJiXP
HnRFU/jxVjYTQ6CfGpPsUvhvC8taIzS3n6xOa3m1nUFrqO9uKAiuu0diL137vmBML+8VvSSCQGcL
+kzXAySBcOvImRAGMp26godm1Bl8gtWswSzDh3zjQkgcWKL9DalkPA2473cyJT1Bjg/XHVWpSswR
M3p7e4YvdV9lRDssvXY/Erb238TPUt7WcV+PGECBAaG4CQxupyk6UD38Rmaswqd4faWMHR2RaUrP
4/YC4oAHWVYHIWPJ1JDyfW72LVaCsJIzaxO91y9uzwAsfWeXh/0h2XNcHaPTdgE7OUawx3XzmYhl
MAbOUObs5JWIT4BHblnLIR0zoLDpaZ75A/eFOF04uOWQu4BidzSFXVYsegyknBwmbESlh6/gIZ2G
2bk2XmKQx3JsEv3Z2FrVNaV83vrm8ccTzhW5t3o8hbN5aXfGrOqwfWC1+kOqiH63vQYuzv2GQWDM
rNZcCaZWW5gh2jMr/wHcYu8Whr7vukW8y8NNtsQErn8aXmjBfcqOFO6U3UfBysu0SWbE9WrNHnP1
pg6HkqQfC7a5wn9zeol52qWLuJNrowCrrBi01HXki779rjzkJTT+tDeyJKdy0vzm+E21xvLzF3V3
VUOPG0AQCdyht63d7o1drTfjbbTwlSoSKGofIcyb+Xc3Sn5OV6zSkl+M4PygVO6YlaMjDowF1n4k
eVHGLrBGGldswG3j1dDr7lROuBNTOY77vIvfdgWw8jbA42KA2wbuV1LUDa+iY5vtZGDryagwWdN9
dHyK7whe5QQwkY3pCt/VFHF1i2ANqf8mqNdOQmFE4RA1O71ceFKz9PBAmEVyTmiqjteXrESJbkmP
AEib3Znslp4wJvsMJivOMXBdPt8TS/U9mbEw7M6r87djGZktKwGse2rp+XbUp8j3Xq3OMVNilY6h
W0jGapzLmlHcjm8mvSjfTSLiq7QSNFb136qn8Q/j7VotaxsmpHTnVbRnfGaF28QHIlDilFfTx6Mo
SbDqtWqnJXvpqlN5VKsY1ljNgKvLqLMakI0IGqutWZaAwhXJa0m+N72ECk3b6OSiKZ4oWsDHGkDF
Apr83rQtL2jQmTuBI48N9FDvhs+aYIG+2zjw9LFK2pVp8SA/vDNAp8gL0DJ7/4ZpdVcfurATpcFh
yJbz42sE4kzFsZAwNkG1/CzhErCzcwVJc72l0ghijod6VRYldkV71XcwSnnPYukrLidaSJIylxYU
S6dRfcQrGOPXUHAeQMihv6mKZkgcHKTu++yHmC1FvQmQkC84D417YtinCE0qM/m+LvUXnYgQA8VL
+a8CUnBN9iHIfWI9ZtHyTdxZnwCD7z//kM31hFbTxxf3GS/fmnytpLn5qh7MNFjQqNnRp4EDbAr/
LVoj8xPsxWceOOvrL9/Guud3h3871wzPKXdR4d8LDBxf0CUXqYl/le8aU6bK3/2ON/Qg6s7NAZuq
MdFrJmWZeJgHaYZ9U67JqMFsmVlHLOTatgH3cO/b63ED6PmECLwG5JFGnlrRS9IPBp7xZus7zHLF
SIH14xzLeeuadc6yaLMBkoarh65V+Y5B9rI2PXQp1j+t8z6FEdMyXNgvfGvheZDH6fTeYYP8ZkHt
vsxlq+4mjae/RB3EmSGI45p7VDSDuA+gOOHXcYjldX1i35tzd3XxyF1qNoVDuIR7II1qcYE5acug
P6fjDREXWfGHxktsMn12JeHVSW7EKHqXg8MsLyRZAPWpv1+mGh3nWkm+3lfX58/9lkHuWEFXKYnJ
6s/Xo6/nI652PidTssFQDjHaAO+kixqtlgJzdf97FL0HbN/jJUc2tj9AA42srEsDlRGDoHCFZsqx
SM/raBEWuo3XtmfkJqpqit+YXIqTx/doKdlg26Q8HM5nAR5xq8DUQd0GKEbDAnp3niyTgDVm3RTR
4IbHGAq9vGNrGxsEbD8qTZCHp3K3ZK20YkVT5DlZ8SjoVfru6aKUCXxXiIqT1l9xXspgFbUoddgU
1I1wT206Gm9tCK5kjD0KLEVTRIvywpnWp0vslkt8ZgdClTvLd8hY/3Qj0Le5iuGJQ0vQWpUZr83T
d8Yl0naM8sZ7fr4acojQs0G0UOziCevnANFZUh9NFYFFKbsGD0n7YlIRxw3PJGwDmcgPkvLeIr3V
xv43mX2bE1oGPwj5V667su/Cw2Bs8devZJl7UZKNOCdlTtVAM4ywz/D9T5gk8tyb//RY7xKgdk5H
R0wCgngePx/Pb235yzj6+YIBQh+ukqgb00rT09zsAoPxdZ3hJGUVal4OoOi27GElIiPsOWYokWko
+dhPqkkvmCKBXTgCOh6Wctxd675AJZWWAV4JbU/4L3zBRTNMULka1vyX8iUBVFWdAJNgpYDVeWIj
hqg1Uph7+n84BCGfHY6XxlwU0NV3BKqmvAksS9DoDuJ7AZJ2eO3rqpJebpwC+Z3Huw2Y+13cg3jm
SKxKlT8WrPCM8VwUizY2LLjeFBdDvJh19+jW8Je5JaiD3EXNNgD2pj/f9KS6Xyro26BIezkE732C
vLtmGpe4mVFUS8jn4ybkMY6r3mXWRrqH/JsraVEIjckKUpR7raaKX8GvboLnmaslWczm+Y6LCtIx
7eNlCIuNQ8okDTrBAOXQb9R4gq/kG2fEmqF+499npAUg1h3QxgnfhqgVNWVGhylKZT2DSpGchbT8
N9caOqvFj2pzQP2HKXc1AxEcUF4RcUW3PdSODPcRfWrAz5m+sK8v+joTCDBcqaS/DZs2dywf4wKK
ZfmS8DDlZ2QLpwzhHgcTDNqRJBwlb/y4TqQKGplerZZaRBjVUcIFvWGv3FQ/P10E49wjtogDjF12
v8Y2znmY6zrcSWiidmXRAtyxA03BM0TDvfsIjbqMkrltFvE3CFZEAsbFWrZ4ynl/BUaRJJvK0Yp7
UpAqFSqjLEeHR9ZUkXN0+bkmvwtvLp3O3A3sC+AcpmYNiTwjC75X7EaDIFR+PyuhsT9oEpgyOlCt
o62jLjZp6wkqhTkzz2ghNIh+uBo467d5rhBDfRvapngYgKiSyQqaDe5ZxeaZHPSU4dANBJli1ChZ
wUpLGYiJFBFsACWzC/1szZFAMy99UuKWbkOWuDUe6hn/HPHWMJr8Gxu8G5IbjmoYwTgbfwxXpEKx
Mbe7jUkm1BjQ9GQWYiytUirtu09fg7pHvyfrbPG1S2dlF2C0eA7VUthflOU1P2wbexSAKPvFZb9U
/Mr5/sEYEQaCdRR6ZlwhdzTBaTY/rInIgarb5SLfPkzhLasTutqNFDeuh/vQDCkxUFzYNROFHt0D
zqoA7rp91P41kgdKjfMR2EvZ1urg2Ff2CNmjWdQKnqUtDWtHY3vUKP02+dRvgTXj7Gyg5QzIXEup
12DQ0u8dyWINFfylg/myrQR53+2VXqkx5khgSW3dnvytsSIgjSvnGMZgi/kPqSfSG+JhNNt58iVV
xS+W1/0vIHfDMtJ11v3HqvzX5mf/XApUsamfCWaqRdhe6vtr2dSi+N3Rx0m08mZWwJR9RbbV5v74
MjCOxPaQvovYCYEA+/DPsVfvA3+yvi4FSibsbDlSth4lYoJliIYRApqNygDPew/tqCbiodfDU4FQ
23VFPrkuKi+gd3AO+Mc/dBPrZcEr4wGIyNxY4wXplyvwrHxWIlF11T645WmMTvERirgI1bm/zoBP
KNLQlFJLEyINT0kgyN1VU6idPys8cd8nFqzdz64JYUvBq/ev3UKIjn1RJsjik7KjeyGN7irYO7J3
cEfQ6uN1ryRjDDYBrM+iq6b4A2fILEsk1OZ0bf4tVGsLkGz9mHzC8Lfqi8yeMCjecvOTGvSPAU60
smxXkYBC/nxXiSTRd0U+ID+A4XHAfdRdSNZWR/pXLbmh0rryvyKwvs4+ZrOKklsuiAD2dscPLmV6
ll+HNJRNQLX0YtnGsvUCw0d/4n9kinOgOuQvHAy0YpYJrpq1wEojuhZ7euFXc9m+vPAyMGpO1oQ8
WhYWHJdwMQXuevmi9GKhiqtWPF2IKTQQ+9WbS5FoXaABW4PdwIYnv+5mpUyrGTB5xAAlNqYYEu1T
2fbWI2Owo66iJ5C4IIUyzb/YxgQ/qba34PF8OlRBTSV93ViXkUUyb0U/XZFprpiLHwrEN2KC4Dv6
TeEhJ+zbnUiXTcasQa2sueKYAG03bTd8kuCPqNAuUDPx5wDKhEOvPI2Pn5gCojt55mgYI6yHOKv7
BMa4C4OSx5n2LC3hSD8AUPqfM/3MoZCB6mzVsd6QID7CZg0vivh8q0w4W8k7wySwB1WeXNAPrA0r
5WAe6uCZzdm+aHGiTgegbvA/cw6HfpwDpkcH95hLBVZR7ipwybORDoB7UnRNnYFKoUFPjFXaJItl
nLvd09doMKWQn1d/MWjrnt+pkPVG04RDHcz7ysCdFALWFaKXzyWk/Qh8rXYwwykKgW0HCRFeT5bb
GTma3uSPs5LdMzm/Fc9eVU8tXHZgUn50REIC5NosLB7ikLzjVTVYQBwBPRvsnOlWn6dfcyKGK/L7
68p90ASWaqkbEEsDxtsk5ajOLCSMWBfupp8xW+jzISdoX41wcv0t5q0VPbJaLio6+7u+Xa57GTav
eTgZOPNx8g99WVr592qddUJ80JNB/1V1TClUvnKdssq+GbXrVqCGkgPpQnLtMOAFjSWTkOwO7hog
OVmihA7jBlw8iIGomNfZAqmqHazLzhBD4xtFW3VvCkMtzOG4l4p4KrpUrVrO3+kyRwDNFcREVpdm
YOPBhpnrHznL+GXYI8xBexi44rGF6iY0To3Qk3E/r7LKFVH6+YUEjyPoJ08CrYMfzSpwjaCq8Yr/
vjMsNb3XmD9iIJgnG594B5C/pBXBgpdQ0fMWWMMV8Cnfqmyh8XfP5td+XdrByrpV4eVRk1mc6qHj
5roHVGMCGCXJZeyFYVN4rM2SD1wrwasJLZk4NPi2buxbiQNLH3dEhs4RIKgLmzBRcJxh33HbdN5V
gbftK6Pw/+OZpPcCkzh6yUN/FDSYrGMyi+fVOLlS6Q6l9XYX4ydpWIQOplwsnCJdI+quudN+xIqM
9Nde+3JWwLBP+zYJPay1FR3IDr/uKlzFWXmlxVe1ibWqvlQFpyUk5MDOdmS3csesiYiVRresOfC/
XAjbBiqR7BbAmRcwcjtMUYmbwWFW7WDIW5eJjatSkSBADIpWwWZRTxhtZWBsRGgDc41MzD8hMgtl
pPeeTR743Y+lyVFkfHyH4R29v+jSHg/Z9w9NlIaauEirMZcDribTU0WGRb2iQ+3vA5Ad5oeUkXZj
fzGqQ3Mvm/LIv4slEMOhH+NJURO8a7DK4ChJkzqOyhARoFiqcNzuRzweHBfK4kN4KNmHF/aPsk/W
kmCQ5kt5k73U8x+i59bz7/+LwVnpFKFEkbusu60gYirnlc8Uq/N9GOqUgx5g4Q69/TEpH2oK7pgJ
8F8vIzEse19gUPSWGY9A7gZCrCh/OpZbuF5pjlAf+uXeoU68/MM8Ar6FDOlcfupL/Jc0dcdgJIQw
FmjWvoEplP/szXoyeli7A3lilFAQRCW/h1dQ5XTVWUV9CiAnFvvCHlzU6Fr/fAOngqg+f7M/vHm1
bjN3nkJ9Ry9ldmUaJXeuwitmG/hsTnu1J9C3psvBSXwK9yZfLBtBrQBRD7i1psgQIQ1HBGlDmxK7
JsMfkZzCW3XKlAekChBUHyTjnoOLOqCE5Hyd1jSl5y6D/sZ3NPWuDxhi40RpHmrH+9sq8uqHmNrq
UsIUttOFv0xEmDlnkOfIgyw6EpJCQ8pQLXvYPay76bQAlpIOeZgbse0AjfOw2Ghcezgya1lvQsqa
VoMmLz2uuoRDi4ana48jxMaRFAu08kg5AoKRmtQdit3YJxPpBBAFI23LYOv9aaLpAFfZq5leSlKU
SFSBB5p3HdEZadY7jgjWOULu+em4e3OEZj/51qrOu/9SvcTDTw9ySmk+Rdb3bVlLB56ZZRGYfQ1a
vIaUQto7iKOVAtpcuaKccmjsZnhW412MWhMDoHLESa8sVD/dXZ5owPgoIKXOn3A8isAIlHHXyKOo
toAjiB8eUo5Vgq6vDJOaWa/grCz6aKqew+flI/8NwrOzriuKF5z7K2w8HFAIf+brCSBbyngI/44H
q4BGaVHb1Ivl3mnWUWyhIFl74MPO599KN0nAh2rZu3+8dp+IaHd1eH8c3x5F2vaHUBBU4JHSJ2ZR
SkqAXZ2Xe+/OIUTOmhWcxXc20J8yKv8Jkrdl66fBn83in2C6BsJrpbsPMUbMpafHWfFdEgPL6xa4
fMsCencnzIGNTGqA998ITdNYz8njgDBUbPLxxm6dEQxb/Hc7USG7J4XQIFIdoXuSW98y4gvNQyBJ
nR1aGrIZ6xV2Y0UlxToSFGRgDnpmC+wMwkL3tYpDS34ugP63YOzyz4FLemcHK2IQKNGrBjvu2ncc
rPQ07uXI6yDjtjP+NfSztk/P4KCk9r57ojjZpUehDbohyOU8uS1KFitpyT5bhtvchLRFFen8phL+
6SmJ4OIJ9MS++U34St9TcS0zJY2Ibw/ahnns62i8Y7yWBRd6WBo8tzCnKumD4799k6F7CgQy7yVT
3i7O21oaBIJBjU+qZeGzRn36IYuxHuwY76PneRlgQ1oH0Kzc8I+ZH887jFxriFTGo+htIy+fmqoo
HbkMDd2Ae2DdqbUU1WvYuiKgZNliNICTENPvKfCo9vW8PjaR5vxsyFyQGKmG/uGlTSHhEBLFRDTL
l2jn/p83rc4DRrdeOZMLAztgMOysIt7rUYmzP0R3m4Cna85SM0sm7XFnAsRvQZDB98rxQYhvfdqg
vcaFHUchifZZIlgzwJ69CW2Q4UN6KcpKZcwKhVBH/6iaFuLqM5OiHBDLmYyUHVKX//k9ZNb93xPb
NtAX9wur6hZ5kbozdG/U5u2DXw8PJsLhnF9ibDOVutSos6TBFqYE9dJ2qGtPIdZcLd2zNFrlee3+
Ca/ZbHgeqaPUqZN6NLLQ+y0LO2eDIcfnVvO/jOCnszFlKFqkrkqwFsHflGumw1liO1pbgWZc5Jjp
MZMevjQ69CLQAIm+AYR/a09ZscXDfTF9UIojnETJGVX0VrQ1E4rfDhxDFT1mCeOdB37zpABeMdbX
CSkIyV7kFM5aIT9rokYJQ2DyS7BZEnGRMF09jZL0b8lNNoGnDKuyzX0+/7KhbW2eQovOVVNe4FQB
Ch7qzzhgI/wzvgOA3XmW2MIy+CXujq6rmH6xIVW0w8OV+LrVHm33hbSdz2Ae7uS1OF/TYB4Uyq+I
A3ozCFl3bV6HsUbhTO34O0vzxGWxUqOFJec70qPvNU099qjaasRk3HrinJg7LW9IOJtEjxX7Xo0G
TdS1KAgv/hC9OxXlhlLW+bvK++Jgim6v+u33Ile021lUQRKMc2Xfvxvya8g5YLAEhykdEZfoUIBh
9Iij1KF6ObWOOtVULqGkp5aESnkfH2KbEPzlhU7RfEb5RcZW3koIrGSkh+k3MxfR9m/kqA5SpRN4
4G49trKrBcRiGg3yPjixhEdgzSatD1PiB8UEpAYnC6ZfoDqlaxVLOq4HJt0Byrlsx3niZAVOspo2
xJH79Oo9l4ZJqc/tCVgSWgCpJjhr+kMh+aXJ9LxUkEVvCtXdh5L5Zin4M2Xcv7+5ncq8Pt5T6lmT
l9H8Ocl7cZrqbKGUxJM7YvYMCLTsXW8SdQbdo/KsmCUv18Ljlp0Rp5t40vhpR+o35qoIe0+8PdnY
HvquXGStkfHCr7adNa3GljHGOremDFubnV0geh+zzIKHZtul+bX5JYXnwTDaHHp55DKgCdjDo1sK
DlAfTpd/7ywRurXcfQTBXsPHvrHg8M9ikAhd7D7YHapR+1MQi7J5qoMKuCkXuJZLmKyapJeiikYA
j0CYDePjW/6mjw+1yBZk+Vdb5P1Wc1sz/urwW5v84+s2tEdLxtjq6qjFLJJeHAgj/bjkrjelsRF6
nSAFzo0Ebf5XenngyycL73sYSAC5u5YwDh0sUgw+0j4mAL3avru0Ymg+ewV7I9nvDepjRuU9kcGp
KsiWnbQCETDenw47Oc3hzwVaaD8TVzo104HQpPe4WAlAq8eH57Ovp5B63WQrk28ugkKDLr+vfOc/
oWBVjYjL7S4MEKsniOEN0luvTKtS9WSteUMW46rdT6FgFNxS7BgSStgt2R0MqGtd7I/3Y6BDW9b2
8unF4VYdl9zqY0A9v4aF2P2VgI4/6YpX4CV61WmzLXXR33qlX/LRJ2h14mOG1/7kPzXrQDZQW0Te
z8At97DNB19T4uVgPJEJ2qrY/DUN84NMZkwtmr0M0Vx87n+59fip21H3n3O0UHsskfcutgGuRh9D
h3uIPgELZIhf/kQibXY5iHn9AjyZf/hoKRKHBpwzGE34FQZiz0Yqz3cGH7Id1ip+wNxhsPiuTMK8
65MqCoZywweSWpQre4aKVD2DD5SPrNf2awCo+R6HHzluIBcYQWRkgrHp8gQsQCJRtB/JjzZUFnCS
NUzwJ2TUyLMNF+k5ak1xLMox2p4NH2u5EsW06qcni3wjQzH7qCO8C3yYjYzR1j9sm91Mrtp3svmu
k2b1AVcLG2m+lFJrNpK6uMThPO7uTRerObLv+QGKqOVIfoZEElxgJYfwFmLfyzOf6EFU60oPIe+2
FJByh4NdJLkTvtccDgQCabPggYvdgLtqc7Z/Q6OurKOh3p9EEJzvNVI3MbKomoyHWtwlrtahsKs5
E672c4qQleV4IMV3Q/f4VMTzRMVZ6yIIlvW0ATbNilCa1DEztP9fybfGyMgrZt4ud8+5pxk7aHSi
YBdIOIvrp+N2jUfRQSuMsD6ZiAciZCDkl4rdjXYwmRFHp/ItfXz7DS6UU9He9WjN4dlXIkH4ZFOU
G2q35NyCGq81C1OEwVmv1knK0i1BZtr3YP62Nhiv2RizvzRpgZpRUmS/iqYxH4xJ0HZ/p1y4QAzT
5cHabINL92e65FhqW9+5CKeknB0qvFx1dLdWUTPOVrbsZCzxqSh6g7VfBzexuUg8fbn4lH9HV80x
TTa10qQHPBksY9YSqufPec+uBy/tANx139kPL6Vgzx3XnlLqsYL9LbEbrZBAtLMcrUv/uCcR2bUf
SbmeW5wNuRTbAZ+b+/ZH36AqimdMELqYOV1GWYlAiFcbRnQNLCFnaP5nRzJTUwbJ74D7yqi77JJD
jy8d13/gPlK3+6c23iK/TOAR1HWGhT61/WJ1UTHbRpaTq2YCxjpR8t4fpGhU+3SADhbxVM/SfFIx
KoQxlimYlKoBwVeSQSUbWx6UWPNfqq5GNO8MZN7VvvNXLaBBnNYn7RqE0SyPsWWXaQfTnUXZxXwq
pkpan7flvZXe7somaKhbYrLiYbGmsGAmGm2GQyjkNDtiC3KtOUmQDdVZEqzzClF+7ao0HdcLV3Gx
B1jXyOjWd2T7PVBHRWZlX8Ji7Amp0rga5QTxcEPaW31JIa8CpDbhc0k/gFVkBOYKbT2tjfylKwsb
FfTanjFilKRsNBaGQVxoGSlhWTHJ8wO9QpYq2JoeiUx3+tynhrPqOIoiRr+fp5T6uy+hNMpB0eky
32dpTKdAxAXdxzbWEREzeawQaAHM9d083CE5pbkzx18AgvRCyTat3jFPKLqsMCGl+qAg5+ZYN3UU
w5xwhMzoW95wIEvtlm2MP60JMLL+5wsO7b7SCYR3KvaLikeT6jO07hDD+hM32q4r8Lk9rNahiY1K
b3EisxkgNhPLhDtN2g9tP0GJZdFcDVSYPZdUUEuQ/K92tBdvs9M9dLIVWXjdXcUHkfDcDWxLb/I+
wNEATnm8RAv62Vur+tGc02FsuSJEjSWjoaJzAfy7IVU6y64aaVTt0BudXeusLC/kpXZex6gQdlOw
nKAc7s0fTHHlA9Zwt+m4z1+zSWm2G98OJ35vJhaB6xt/kgn59+Oh6j3AW2SL3YxgJb7RLhTBrtnE
nu5/rkgADrJVxYZTqntC/FimJQ7Yn/JbBfyaNVYiOcXxGD16dacPKLqMJBOvIDYTvqJFtFNha5HV
qPiVU/+8LT7aluCOzceKdDCv2gQ7l++cjBKgnKqV0KMv06a3A6EMRQdRS7Yk+/x1tDhSM/gnGCnM
3zrrz9j86XMMvVSZFJLjwu4Tr7EFVOVmcK34N3f4hiwVPtDYNINvicUmHrryUXp0p1vzTYpUOQIK
PdA7oxy2AxiWXocaKSfoqW4taDb6DY8QQjDIlC4fysp8anXSv4JnkMITq42C7staThNrfZv0henL
c2Ijr0i+qaoZCC5jlQ2bBUt2+yZcX12Q7pG+2uepOewVR/dB4bhCGvNLwog6p9dMazsZ6ZLrKL16
a3J1A0ydk9GeRKZ6srAXqRMlOnbCn0PksTd2djeYD93eZi6HCCW0CD2eSY20VoJ00GQppaNQ/IYE
vlRjr0AO96gt0AxI0b2sNVVNP2zJ1axpMDAPn25RpDR4SAjwEwYqI3YOKlsm6NjZaoIrHivdTH5W
opr6fY42cK1TyXYYSfIwDIY5xPmNDkwkulQ1WsOwVsaeo34rB2Bl1bTt3m28gAW/K62Et/Qum3Z7
qGawC20MhbVss+Hrkl6gplUzUpe1ADxQVHiAynMaTyCap5kCT2VaUXyxuskWEfN4yUiDVL5+5Lo9
F/345mMrszrK+f+dElEd5eRG/FIAUJ0/tHAKLDv6kXvKHVL9UO4JPh576uPEBmQDu8l2MMDSlJ1W
4kg8zrlTf7aEVV51wwUIWAj4UO+tINPuy9MAyyDp/UqtbEau2fZLYLR6lMnOagzSQEoqt8Y5cr+4
xyfmX2ALXdKsrLrLk5AhVckKSIYXDYxLZiFc1Mjs1nMNUi1uGzBRe9MtmPVLIbSH8P7LQ+i97pKu
lp8+bwNu464WVitrFeRzgoeyzUyWHZVUlYoysXnJi6esZETGg5v2SLgijgWEtpXakPbTyQ2ZseJ5
o7WaGfIDP/eZcFxYcCFj1diFYCOe6EItDMQefLiRVSABJVq3QXfFUi2/N8gRwBXCBOXMxJZ3ETYi
geEZco0dUuWJ06U1lYaXUW1kdEti987PCiaWeNL2h892DkgB29AiqbjVhFSVdN8aKC81TUOOzMZt
UOMe7nlMd/XX2un/4boERorW/mlU7KB4by4c5cyHfC7QSBPPh809qyKmrE+aYMNem+amYobswkXt
9JNNDDfe1hX24D72e9bq9yagAIMQodqTyeCNsYhauFa+Qf7dbWKmkQF5BdAYpRc1Imaap3YMwLG3
2Ism/zvUDcFQcI56ihCEOGYuwXMjC6gcuVTW7lY4hTP9OonvvZRvvJGNpM52fWXmtBYUZ44jfcyd
ZShDXGEVKRjaWdUVtN+FX3kP9qvXyWU8OIWlKJbMjCO0PKPhWThp0CvRBA+Csn76LRRpfpPCtgFG
x3D9AUPtplhOixrKdJZqqCLVfxAZ7Xaa5vXJYAJb8mrmAKeLqHRDQ/dR+griOiSOoxIPLN2XLHBN
HgK82KxhwRa69FVJT3vbHchvtwJJYtYWfCeEFqhSNBgSD1XfThCAr63LhRiuJa9Lah8DihpK3c8L
PrTj3JwJ9X2/2ALf9rj2SfkSZuLlKBWTnhIeC395MQeRLnjKhnyIPFDf1t2Z4WDdAZydqBskmh3A
dJsWQtVSUnXxTtUtuUAJkqdMe7m99+rCA8vK+TjS0Sb8eGYBQTWNNqJVSmgbIeFHxOq+GWdwU8YJ
9KD2dWG6Ps0W/yjvkZJI7wYtFd9tK86KpcQzZhUA2Dujmxhm0r/RV49IBQlQI/dqPAnJ+3hVF4r0
GFiosD5uwByK/dgMj18QSLT1JmLCrSmBENBJqRNr2tJ6C5APDYOpq1FlilKe/ETn+liYhbq+2bSi
xWzCp7BpLYt0bzFNlVBXJOYl+c/lExlRcFITUhZTESZAVG4VVX/zR3gM6ElvTOmmykix0ubFZU+l
o9UbsgOpbPiTZnfbZ2RIpZPEw8Hwun/in5dEL9AKjBvZLI4daBBYlSc/nFNAavEHH9bn+2kIDrno
uVECu2UkVS+avt8UT0HFb0dD7ZNGHAXZMbIqv2DNM3USfiJGbO9BdWcQIIVOP4btwx6DHR7K/BOV
ZDaX8NAV8Wi4EkdpquHhJ1zmdFqqYXER5eeaARui/vkC88i7jbETxqSsdD2njnf+5SPsZRP62QJ1
xQcT47dd80oKglbQdodfwZ+jycRGY1M20mC03JsVlctnAtuktVxcz6QsQPD75mdw6cjrSdI2rkis
AoSGHZIzWa5OLjapflQG6bssU1rapNQFee0KsY9cWjUX9NrmsIK9evYgKeTHsV2JDIguZA6hju7S
r92205ya4l59/kInE4GldU60xb4pApH64qrqPQMiyea/8p5dARc6PPyeZHlYOM0P/gSgYzaTROJs
w5uzbWVwZzheN8zcNj04wD+RJdVht7VetgdD/ReJxMcQefG5NIEHT58la52ZTooHNVqEXk9yEI1E
OrYP8+lD2w2GkN3nlkMCOcJ94RbFdMqyhxZJ/eUI6q5L/rKK9N2TuQfJtBs4aosXjBNRTj0bPuxR
MEDwU9Mvx4XuMzLxqTf9tLEH5Z51a1lW9/DRb3TlsnzSlakBYMc6Q7xiTyvUy4gQorMAKTxAW3aW
QloK2TEqBwSmdrMHaHRdOl9/d3kZEOI5RIgMZa+wdJiw8TZcIEmK3zaFrhCFzARriR0T69ZNGlZG
e5epP+wM0vDZazQJ2MzH8zCgAG4ll4A8r/rsUho/G/h7ZsjsxiGR9MulJVs2jfiyy8hA89rcC+IO
Vqv4PrmvYr1k5ur95HY/j6Qpjt0B8oUDlTPVAfoSB2M8/WAnPc5i/xoTb5k1Wv6jk/krFaHHAQwO
2Ar2eho1ETN4RnL+6UcmmVbj69g44fpSvz7IJ/+06XB5LoHawAyDe516U0482v6qgYrAupSbicrZ
csTQHWN+bSowa7oWT5yYs+1ryPKxSWMacYZrBwBYK08XGh6vkb0tNydWWcX7E0wpZayG9TffO4ra
B8ub8kziIJMf+Lnwn1w0mae5Wjzl7X/FJi1qOFHDvbJOsVnxO4xUmw0W2EnLiyQacrdGF0FDOP6P
bmHFQawwDdTEAUtDkFEtbFYgquVAeqZ/fj+Lnj8VyvbgWhxLVAomwpa36FECd9wS4SOFuCoj0PAf
g6rzcDUdm3Fdtl5Y2pT3PD6BtZ7wmUFXG446gVcmob8Db62lFdSCxXlzF/TpaU0d48j319YwrjPb
yT52pqV4daDlXxapnlGNDOtejzZQxybGNNZu/wavRGnXPEAkmZ7KdUtT8AxOqGZID+SG0ftQVi8B
N4CS3zwc0haLg3Zmt0wuoluqEXzG9p0CK0f8cjHPsTYbRnn4NkqdoDJI1MP7Y9LyVACkgeaMGxFx
trO8RP52u3NQhmC6pUUOfJJRepLOgqT7Qf4Q3uj2PH7Dxv+PK+BKOiDN8RMNzLRSSYyEeHT75Sil
7jbzn6XNQjk8Ojv+4jQk1MlEUSVC6mrwMMIexuhokbqVSBhnJhDkT0GIpXvtWpR/SK6pnc+7RMgE
MUaOWWg/k/PtwG77UqalmKCZ0FEcjoQSLVbD2yLc+tJi3nuyKqEkEXCWNTyr1RXWssBvSzm+A0Fo
F1xgne5ttu5EwAkyVSdbQDK6HDOrnYhBsOFLemYkiOsjFOQ/wyvsZ02eYuhVSaMqaJ+CpaTuL2yN
grKMjE11bmHVmxCHwnKJ7uOesQ2sN/Ir5lBuJiiRBwIxHCQdgyVy2e2dC5ys1/PPcbbmc4D4YYiX
UH26aD80szTa7SHV+Jd2JbZoSzadV5quBktn6awuMvBhFhNLC7N6bV6aYAOX4Q/jP7cWGmyKSbBD
K57DTEnAExxw3ySU/6fpShmcLPX4FZVJr+nvYyNdbUth2SVUfhbo5K05Ho9uIJoA7DVo05e1KYG0
2BeSyN51wQ7lVUY6tMnwim+z4CPi+TW8GaMnxQOv/5PUx2KLZ9kRE34w5GN5G/QNkpOQVdQfqc5b
ShJbZ9ZUiwsr5nttb5J2MmZ6Sz8dJtJkdJ0WRSugNwHYcryCfz++ls1LkoLuWlRhDgDFvhaVKBxp
nBxExRjRewAIFwtnurSZm0K8MX5kfFjPYNfIE0Okf3iynAAp8IX+bwhNKFtLJ4lhzCfU2GAsQMSQ
TID4YvL5cCDPn69O0Jp7CP0u7XR/fdw+xdOhETYVvGp6UFznJVg+kA2FCJl1+fszpdhyTLEmsSxZ
NTpKxt4X+wCD8BuI6xestCdkPOerbThZy+QKZJP5mpxRE/D/mWsBCFrpezjYjue+XJm5sm0Eq/Dz
Ou4YxtFAwg1hz/D1DZm1kH0cdIYMoQU9g/P9sCmTwXI7n8F1gV/JqqCMjrfkTvCMHW1DwWoMxU7h
/OVuCEZ52dvr7L+Zca2PMMykY/VT8ItinXV8EJniX54ihn5/0aqwwvFOCviFkaHw1gdwDKJ0vSIL
kpQl1XuMeetDVC0CU9sMjeH9rqiZztUmOF5d+8ZTYw6EVThsYjhBCqXq4tkXLzSTU4ZdJ4vlC7R9
QhUg+cHDm2dkyJupZJ1JazgppoLgi9IIYr0/gxOvFA5/Lx9CKF9l8Kmpw8n7MW/QU2U4XYOwNZaF
BUcFi9REA9y0rCP32FTg01SZyw3V248khke+13EWqOK0yJQPue29dt1DxjS+PRfIsKp0KDHFurTO
WBP/mS0jcKbmxcuMFFuHTflZuTUACy/C13sZovYqUz0g5v2ogEx1RP15b3PUndkGA9/NSFbpefDm
b16xzKJmuKlQibz/8NNlzZIO3sZx7wyvJjrxa4oZs0AbgNQG+P+7j7KcKvtxyXNmH/ceCIecp5jJ
wlVyNVUI8xvATbajRCqf4M43wlcUop2DlSjRIn7bZ/jrnnAg9lEU1CVuP0lxpNJMzVrIKqrtnUXv
HSXsuHziXwYw4fDc3GAPHbhNv1D4jL75HmH4KCFvJ0amgQIvtCBiEYXp/OMfzsL10sShVvm6PzsG
d03wcInGZl9bMyrmJcS3ZEQxBwXzDbGPTifnD8meedtTsn1EMWU//wvaBUhmj71sb1nx/5tkXCIc
7YQxXUvCRnwwa6BzJaRj3nbY17LaRRN+qjgRmVOLLCd+sQkvRQ63GMDMthHs41Q0C8QQ9PYPxwA0
DYwjaKt4PEVmbrLsKA7gDBkY9Erv2ASIpfNqnNTIKXcXtiegXfgRrCHimqDgrKNAi5FXUl6gtlp0
JcfcVjy3Mzt3x/XWrtbKG//TZkBgj4zpOb/DZsZOysbl+X8nyo5p+iO6b8tSXU+7OGDJYCFtBLpI
r04YtNQYSZ1g5LYjqNSHI/y/wAdMF4a6qZBy3KaC1qPbr5CBwOzstYeb1UTaDLvSSIRyXChcMrzb
Qk+LZ+gv8h7esEvJN3PWdUB/Nef03+4EciDFs7p35jET4pbIbS1d0CzlpHgT2Ct0YgTl/qESzwhb
r2iypQs9w2I1NFc11pSZ6j0i77/Lr8255A1Pu6Caj8Y498na0sbckCgOD1xXH9joEBmJr1Vq10jt
bCT/fuect5U0vwYn3ED8/CMn7AM47qQlflSI99cFiUyzPlyz7urpSBhMLPK469eYvFalqxzd3yza
BVr6rV6YsYD2HLnF1mFRSKBqrFrkualgGxBISQGjWKq71PugBFNdsjpl3hWZ9kDf425NZFrXuN1/
xQP0tndoEMtUrJN2L9yHpllQBgOJNWDF0k8X0hwNQeqzK3Hakbfw5CLH0hEWseCjeNkPr0rItUc9
zLhebCu+1utze16BSIoODwEHehNt8pHI9ri6GxfiNfrRUlpwwkNj7+hmIqyj/U3bnSNllzAZKgYL
ZueUjHWma7tyupX78F4V2/9VLHJ0h5nXj+8J4K6YHacr0I6komY4JyNa/0izI55jAjdz7APRLSHh
7bwTSPchoNZ1djF/fGc/zFe4Wok1OFvnboucYaEZ5PhtZrxUm4Baf6QkaF0l68HxNdhCi/DfOcZg
5MeiKeYviou219cBVjVnlKFx9geHrY1yjkD2Vdg5ceuWo6oaobVoVwZc3qocP32sJYRUHi8OawXR
GZWapbcr3dVns5k0YIIUwfsGPC7dMrWgr/RzoYJMyu5jd4lCT2pGEl2C/1uH+UC/oUiyr7XhhzU2
4srIYet7nnRAvAOXziaff0nGJUh3Er9OmEg034jrVYeZ5RM5058Pahokv4mfZ+Vr3p3S1xP77N/Q
wNbSKGODGbGRJh+TZ1yg6BgS+fphO+DWZ/Pv75c6CXYul3ngp55ZcJw1vCCyU6Ht05R5evweSQBL
R/z6mxCcE3JtJ9Aznl/6/zamLt2XAnYPc6A8R8PLP4eGS9of6jXYn0NQpWYrRDeTvvyD1zvGQRSU
YUfboLkt34P0HJnVCAZQ8zUaSDZh1GqjU+XK5ZqbM2bw0ojWn0/bcgymQhHe6eVzJeNe5R2nSv2u
TO9D3KYEldropxPo2301vp0DWXxy7r1NqObffVSq3UWf+4B7woFVmPoHGmAhp63fRLCWwMjzNBv+
VAVumT5k/fl6NOOl6Snz3cccnzS+ci8DFywS1HbscWdzFmcyVe+KKbVBtJEoF8QlGEWXN+B+qzGR
3pfZTMngIQeaWzUJkfJoHAcp/TGjuiCTgEdtt/dLTXW0FreLumfs2kr433feyC6k7sOQgJ8+FvKJ
RWCczaUSIla35XPN2FpJ8B+pjI4Bt2PGfn7A23pAcasaUpTI4yDL1PCZoFovnOtymbhNiFnBpRLF
FIpbuWRhKZcBrilED16JgMkd4RLaieYpp8/mHGyIOEbtcL7XLyJcWnbiVEbENCrSxqFUeQGbZHOC
TqNiqCvTbFOxVshEJvYZCVWidphv0yr/CcZkOqhFhKjlI83eCEehoqe/LMXqNBj18VV+iTuNCdHp
IGiomadD8rY2kL0BHmeCqGen35MBzmh7FZ8nO8rUnOGYAQNRriqggkHfAL62TL395lAOsq1cLW5G
1zofZoDbJZKc53vlVIBtqI01in+U55lFpTGDawmrQ9lwNzgHHLDPo6NkfrhcFFZQThkHf4SOIldb
19hbpqmj6Pteto5jT+njoWYy6Nv8u6oZ4u/oPSL5nsuj19IxwUx/wXzdQllAS0iyySFZL6QypJuc
Vvyzzql7U1ZkacxCdU7U36mnonuH/EX6Wc06Jr4RjDSRWHz6D0M6FDBCO4OcJGyLwlL+i+SiWvfn
EjbsDibRwX/x2AGL+y9lyOZz5PLzwTOyJ7cDK7TSD4JjNnJH7JswDJ0L3usfm1hD9BGTxgtXETxl
9DGTAfzKjGJ0DUozDBRaskSMksJfwvCjcS1Ai2hosUSz9ZnYykrYHMzT62PvPP0JxhXtFwvzeOq+
Aj6nq2xrbV+gc0ymlx9kK2wzeP9DKr8Ur8o8OSKHV0cXd+VnyIKEb1Ekglp9sCkkBSARcQgL6c0L
pCRfOVc/Nw/gGxzOsXpgUMD0H7ZEQER7wfz342YmOLEcIz5fOlgQkZcBH4GFnzYFVEBP1/+YXW1Y
c+oQ+T9u7qOrX1kggd89/ZF3/EUh0UiXX8CJd7ajUqOapt1DWHRR0LemCVGjM8RLquSM0/5MLpQn
MMk3ZSr7VS2BFfY4mSgnW9CPryITZtt//9/LkgOyyobVMMQhQvzyCfeolcEHsPfJvy4QM/glUU+4
7a5vEg+pDydyTCx07fBCk2dyujnsLeB2BRRyFZEZ1Nf0sVvLXPEcFLUi6YQQCi3lcS00xx3+zQc9
FudlRJB13mTRIClqkFB75f147pMNAhhZrdyrq3hqjGsKYBfnzXsi3xLCAS1347tWIS6CbaTApPAi
WNjXjtUUhrUcrBtrklAUE6mfNkHJI9iNKIvfWKQTjakbW8KcZYtv+SGsz+wUkc/Cxel2RB1yJLdT
4OYUh8TMpM8vYqu03Aay9CaOZSOklHpPZrFRR6uLCptecXEdlEugCfbUilwlVwOrH954UHAFMZ1y
CdbQHs0m2LYejnL8TVRTsdoSXsVPeP65QKVeIfKAWrSQPDcI783ErEcRluY7wg8X2GITMfFhVvER
dK1sHFu5ORT+USJsCJbDTRVrZDjWE9W3TszbrnwnndEpttwYFETeIQ/qoMsQMe4oT7X+Dl31Lc90
dZPmTWg65IYk3pO3fiUyS6XLCNWQ85F7Iuwu2sRW4yckTEBivjTSzN5Qxmk0feikNw8hh2mcv966
+N+S4N4KiYpM7xnvg8rHAgEWunh4z1aNNwK9EtVdW3qqhJ92qPjf0slSRhDBJDeuyGPZJyoqf00e
2rnovoOi/lcBeSCRqzjQ26v0op/TuKOMKHPB88DxYIhRPYIiWhSXblGZXwjgo2f2p0+2EIsgpvNV
+8hjsur6U1z5v3zG4NKgdGcbPBnzYuDSJjbSRhLeo9Z9B+CwQiVQkhqe4YYMG0kAiDPx/2+sQ95R
qMtTaw2CVP9mtKB39zb6WFtyIGs+raxy/90MgzJit1xqegP19mn1cqeo2jhgmXnDs82c3Z/ViAqO
zeFMEADwUmGJ8EZmOz3nrrbuEfvioxnqNdbdsP5p14Y/eL7IG80dsWMZhVBZebzdTRS7xZI55uce
UgH6nfynNYCGihKIiOTsklhpXNxbuhzm2u6LU9shJD/h6eMDB1ZvS8NzUrgYfNDPZPP5GRq63NzF
bymE/tPrQTVr/S9jyko8mW3oIjWDdXFEeTHDqPHJgM8py/dtY51dqs4jb/I233IYToOHkf661fSj
PZmW4wGLQO92CuPykDAELNAhAPY0HBiktwfNOVScaUzkDzp6vo10hqNHzaQsQikosVTnRZohr550
mgK78/CwqFg+ZeEmn+Nl97hTnoc+K6me1bMCYAHuJ6zB1y+BuvZ+tTuRlJQfoVOOYaHrJ2rprmxU
uYIAxEyzxs+YRC6m/cf75Z8awOM+Q+w6uZK5a0bLrIbIH1BTZpSfCcj4sTdDyq3EuJXKicbgH4Id
C4LFOxd8ymXC6v5t1azQCvWHGzZhCD4lAvzzKNoyyxQu/fl99DfFhjBCuRP3tW4HMdA9oUpxwcQU
cQAWH9iuIMoRZQHYz1ljLy4MRJXc4VqYVgP1Cgg6TLvgSrY7S5SIPL7dh7FW4Lq5i+22qnGQL79m
mKWTH+tOqAAZeB8kKKaCxPXav/mcXF5TMlt5+7YFY2zXvIb/uArsBSd3ls3bHaoFxQlHp84pIHfE
faUdCR3TtPl/3SjfCPSW2E0ia5u7OBlz4uAdYa+orxf1sykbthGnIU5QE92/jRlZYPlvACJQGRFd
xabrNai+rYcoQWpbBPeH40l8QCMtgjPUhXJXYscvyIv9TZSyYDMv00jbsjqajJHbjpnoloVe33Wv
LuKg52Cc7Tc9rzOaZEMYqQuak6NTikgbkj//gYXtPGR9zMBFTFv5JUurnSZrT7HpO4c9Fr6bWMky
Fq338rlJv5BucRIDBrX45TM+kYJXVYOyr7YPcDkiiFdE34ySde7YJZGI7AYgwzZnJ8hPc0OWIs1d
Jhgt3cKq60/xUkA9W+ehEd4g67gRAzlKyUtzJ3PcPUPkILY9sjbUhU4YW0JvED6rsbA91ttwOitc
t0zKOIKivTVewfxqGY4SmgJW3g7kLo5Gs2FRA3ZoWt78SRh8L7DUSGyShLrz0TbbQ3lQo7odpRGV
pAl4b+JHyP0lQgTvJwJ3RAhIOaqg1X/b4CS9+tYDbjyqNaMfViEcl5n/N4I55S2BcE7h9iqFuhqh
Z2i5piF5afVUsQQIBPREsGwoDY+Q/kgsaIo4ZjG8rxIfNPDj4gZuN8SqU9YIkdzEZpUhZph+/+4K
ghUIZMibHijlvBw2Tx2iO1qgllTrBsFIQNcCnhvyyT8BBwGdhUSo9t8ZG6o53axOeMuk7nlIZnJd
Nmpy3O6IG3k/NmI8Dvo+W4Zd1Zx0Ji9GX4XYDoPH9/4BLExXj2zjZ2tn722OrOJRZEkSji4iZERJ
RbFq3MGH3DE4fw1s6TPTbEsGJrFTtFy6+L9wRPCmpm8Xfd4nbkshneQekrUO9jHo2wcXNWtHcgM/
euyu326I3nyEya0JXUkDSWCuZJwMg5sa5aBIUXPnsetX8koFzCDT8Hh/lFjLroBmOiEyhgNIfaKG
aT2VI5I9I2eyexMpc4q1lUJI13pvD7kO8tnQ6IKJxTemrZb4Zb089D559X7dbwsum0fSnSBgfn1C
2va9FBvElBEjE7C9uR/MOdfburkwtSyCmLMfLbMiGH+Nw71sI0X0SCoPpQvvZec625/5LXlUk0/O
kwSPUJ+T1leBnenrB0SnuDurYIsSpGTT6QkXk3E3CpZpU/4ySZoKqIzLCb1jCRPpdDkf7LptImsM
PQYjI/tP7/lgMVmRn7jyPpt1wk9xqUUDpvHFaD4gJegpRW795v1r+5NSUevY2kwZxyylzwy6VUD1
qF6YjBCEvAtCG8I98fe/tU0LJa2sDFQrGTBWM3DMGA41agEwwOlIxQNB5Ih2A2JMbY0Y5xaWBB+/
ZZlNQ37LW9rMavsWINilQNOAQeq/2w9mUnMoR+db9RAqgBOchik3s5Nf0z35nguodX+OdRFkYbbq
CB/VrUKYn105lCO6zmawZtsHNRMzpXwh5YEwPPn+CkWLh72uS/sSpzVEQO9ac+48NHSIKBLF/7Jg
alZlKUYvfjZeJG76E8B/58Lu9pQGJd1KIgKCIyT8BQ+e1mHMk8qq8n+otGMr8LOdddiiMJlDII5N
FZcnJADbxmaHRm6327o8f3wihVbCF6RhpqPtkw2fCZGl0pLYOfWSnZ5FpyrOnkoFqucmL30pEvaI
rPltxtmQUZbAV+NQD6UvXNSy/plw58lZ2KmWjwdQvV+znvllvRepyHkqR5iPn+NtIoLNK97SJk0Y
YE1b2hd5wSSXxWun8K0lCac2tA15O9uVLM5EdQBtcg==
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
