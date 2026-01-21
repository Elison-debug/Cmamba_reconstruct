// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *)
module slim_WBUF_bank_dp(clka, ena, addra, douta, clkb, enb, addrb, doutb);
  input clka /* synthesis syn_isclock = 1 */;
  input ena;
  input [9:0]addra;
  output [255:0]douta;
  input clkb /* synthesis syn_isclock = 1 */;
  input enb;
  input [9:0]addrb;
  output [255:0]doutb;
endmodule
