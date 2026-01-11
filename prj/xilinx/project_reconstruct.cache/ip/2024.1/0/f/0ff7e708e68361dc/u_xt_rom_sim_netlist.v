// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Sat Dec 20 03:26:34 2025
// Host        : DESKTOP-JL9PPGK running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ u_xt_rom_sim_netlist.v
// Design      : u_xt_rom
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "u_xt_rom,blk_mem_gen_v8_4_8,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_8 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 31632)
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
