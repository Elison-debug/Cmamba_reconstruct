// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *)
module u_xt_rom(clka, ena, wea, addra, dina, douta);
  input clka /* synthesis syn_isclock = 1 */;
  input ena;
  input [0:0]wea;
  input [5:0]addra;
  input [63:0]dina;
  output [63:0]douta;
endmodule
