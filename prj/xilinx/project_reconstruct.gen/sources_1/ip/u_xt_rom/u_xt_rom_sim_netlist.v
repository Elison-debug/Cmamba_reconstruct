// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Sun Jan 11 15:49:20 2026
// Host        : G14-DAWN running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               e:/Master/2025/Mamba/Cmamba_reconstruct/prj/xilinx/project_reconstruct.gen/sources_1/ip/u_xt_rom/u_xt_rom_sim_netlist.v
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 31568)
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
