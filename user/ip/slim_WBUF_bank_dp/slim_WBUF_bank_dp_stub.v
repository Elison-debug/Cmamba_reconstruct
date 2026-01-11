// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Sat Dec 20 03:25:56 2025
// Host        : DESKTOP-JL9PPGK running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/Mamba/project_reconstruct/project_reconstruct.gen/sources_1/ip/slim_WBUF_bank_dp/slim_WBUF_bank_dp_stub.v
// Design      : slim_WBUF_bank_dp
// Purpose     : Stub declaration of top-level module interface
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *)
module slim_WBUF_bank_dp(clka, ena, addra, douta, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="ena,addra[9:0],douta[255:0],enb,addrb[9:0],doutb[255:0]" */
/* synthesis syn_force_seq_prim="clka" */
/* synthesis syn_force_seq_prim="clkb" */;
  input clka /* synthesis syn_isclock = 1 */;
  input ena;
  input [9:0]addra;
  output [255:0]douta;
  input clkb /* synthesis syn_isclock = 1 */;
  input enb;
  input [9:0]addrb;
  output [255:0]doutb;
endmodule
