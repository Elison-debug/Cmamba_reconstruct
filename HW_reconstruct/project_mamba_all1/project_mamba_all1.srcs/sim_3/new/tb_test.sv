`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/14 03:02:16
// Design Name: 
// Module Name: tb_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_test;

  localparam int TILE_SIZE   = 4;
  localparam int DATA_WIDTH  = 16;
  localparam int ACC_WIDTH   = 32;
  localparam int FRAC_BITS   = 8;
  localparam int N_BANK      = 6;
  localparam int WDEPTH      = 1024;
  localparam int WADDR_W     = $clog2(WDEPTH);
  localparam int DATA_W      = 256;
  localparam int XT_ADDR_W   = 6;
  localparam int D           = 256;
  localparam int PIPE_LAT    = 4;
  localparam int ADDR_BITS   = 11;
  localparam string LUT_FILE = "sigmoid_lut_q016_2048.hex";
  localparam int S_ADDR_W    = 6;
  localparam int G_FRAC_BITS = 8;
  localparam int H_DEPTH     = 32;
  localparam int U_DEPTH     = 64;
  localparam int Y_DEPTH     = 32;
  localparam int OUT_WDEPTH  = 512;

  logic clk, rst_n;
  initial begin
    clk = 1'b0;
    forever #1 clk = ~clk;
  end

  logic                         s_axis_TVALID;
  logic                         s_axis_TREADY;
  logic                         block_auto_mode;
  logic                         block_start;
  logic                         block_busy;
  logic                         block_done;
  logic                         g_axis_TVALID;
  logic                         g_axis_TREADY;
  logic signed [DATA_WIDTH-1:0] g_axis_TDATA [TILE_SIZE-1:0];
  logic                         y_axis_TVALID;
  logic                         y_axis_TREADY;
  logic signed [DATA_WIDTH-1:0] y_axis_TDATA [TILE_SIZE-1:0];

  logic                         inproj_enable;
  logic                         inproj_start;
  logic                         inproj_busy;
  logic                         inproj_done;
  logic                         h_wr_en;
  logic [4:0]                   h_wr_addr;
  logic signed [DATA_WIDTH-1:0] h_wr_data [TILE_SIZE-1:0];
  logic                         u_rd_en;
  logic [5:0]                   u_rd_addr;
  logic signed [DATA_WIDTH-1:0] u_rd_data [TILE_SIZE-1:0];
  logic                         z_rd_en;
  logic [5:0]                   z_rd_addr;
  logic signed [DATA_WIDTH-1:0] z_rd_data [TILE_SIZE-1:0];
  logic                         outproj_enable;
  logic                         outproj_busy;
  bit                           debug_arm;
  integer                       debug_cycles;


reuse_mamba_block_top #(
      .TILE_SIZE  (TILE_SIZE),
      .DATA_WIDTH (DATA_WIDTH),
      .ACC_WIDTH  (ACC_WIDTH),
      .FRAC_BITS  (FRAC_BITS),
      .N_BANK     (N_BANK),
      .WDEPTH     (WDEPTH),
      .WADDR_W    (WADDR_W),
      .DATA_W     (DATA_W),
      .XT_ADDR_W  (XT_ADDR_W),
      .D          (D),
      .PIPE_LAT   (PIPE_LAT),
      .ADDR_BITS  (ADDR_BITS),
      .LUT_FILE   (LUT_FILE),
      .S_ADDR_W   (S_ADDR_W),
      .G_FRAC_BITS(G_FRAC_BITS)
  ) dut (
      .clk           (clk),
      .rst_n         (rst_n),
      .block_auto_mode(block_auto_mode),
      .block_start   (block_start),
      .block_busy    (block_busy),
      .block_done    (block_done),
      .s_axis_TVALID (s_axis_TVALID),
      .s_axis_TREADY (s_axis_TREADY),
      .g_axis_TVALID (g_axis_TVALID),
      .g_axis_TREADY (g_axis_TREADY),
      .g_axis_TDATA  (g_axis_TDATA),
      .y_axis_TVALID (y_axis_TVALID),
      .y_axis_TREADY (y_axis_TREADY),
      .y_axis_TDATA  (y_axis_TDATA),
      .inproj_enable (inproj_enable),
      .inproj_start  (inproj_start),
      .inproj_busy   (inproj_busy),
      .inproj_done   (inproj_done),
      .h_wr_en       (h_wr_en),
      .h_wr_addr     (h_wr_addr),
      .h_wr_data     (h_wr_data),
      .u_rd_en       (u_rd_en),
      .u_rd_addr     (u_rd_addr),
      .u_rd_data     (u_rd_data),
      .z_rd_en       (z_rd_en),
      .z_rd_addr     (z_rd_addr),
      .z_rd_data     (z_rd_data),
      .outproj_enable(outproj_enable),
      .outproj_busy  (outproj_busy)
  );

  task automatic write_h_from_case();
    begin
     $display(
         "[%0t] H    sram row0 data=%0d,%0d,%0d,%0d",
         $time,
         $signed(dut.u_in_proj.u_h_sram.u_ht_ip.u_copy0.inst.\native_mem_module .blk_mem_gen_v8_4_8_inst.memory[0][0]),
         $signed(dut.u_in_proj.u_h_sram.u_ht_ip.u_copy0.inst.\native_mem_module .blk_mem_gen_v8_4_8_inst.memory[0][1]),
         $signed(dut.u_in_proj.u_h_sram.u_ht_ip.u_copy0.inst.\native_mem_module .blk_mem_gen_v8_4_8_inst.memory[0][2]),
         $signed(dut.u_in_proj.u_h_sram.u_ht_ip.u_copy0.inst.\native_mem_module .blk_mem_gen_v8_4_8_inst.memory[0][3])
     );
    end
  endtask

endmodule
