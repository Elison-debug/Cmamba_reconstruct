// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Sun Jan 11 15:49:19 2026
// Host        : G14-DAWN running 64-bit major release  (build 9200)
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     5.931282 mW" *) 
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
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 31648)
`pragma protect data_block
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
CaG6VkCBCQvNfMRsSA==
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
