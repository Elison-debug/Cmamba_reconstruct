`timescale 1ns/1ps
`include "tb_hw_debug_case_path.svh"

`ifndef HW_DEBUG_CASE_DIR
  `define HW_DEBUG_CASE_DIR "E:/course/smamba/final_hw/cases/c01"
`endif

import slm_block_cfg_pkg::*;

module tb_slim_mamba_block_hw_debug;
  localparam int TILE_SIZE   = 4;
  localparam int DATA_WIDTH  = 16;
  localparam int H_DEPTH     = 32;
  localparam int Y_DEPTH     = 32;
  localparam bit ALLOW_LSB1_FOR_Y = 1;

  localparam string CASE_DIR  = `HW_DEBUG_CASE_DIR;
  localparam string STAGE_B0  = {CASE_DIR, "/stages/reuse_mamba_block_top_block0"};
  localparam string LUT_PATH  = "E:/course/smamba/HW/ip/sigmoid_lut_q016_2048.hex";

  localparam string IN0  = {STAGE_B0, "/inproj_wbuf_bank0.mem"};
  localparam string IN1  = {STAGE_B0, "/inproj_wbuf_bank1.mem"};
  localparam string IN2  = {STAGE_B0, "/inproj_wbuf_bank2.mem"};
  localparam string IN3  = {STAGE_B0, "/inproj_wbuf_bank3.mem"};
  localparam string IN4  = {STAGE_B0, "/inproj_wbuf_bank4.mem"};
  localparam string IN5  = {STAGE_B0, "/inproj_wbuf_bank5.mem"};
  localparam string INS  = {STAGE_B0, "/inproj_scale_q15.mem"};
  localparam string DT0  = {STAGE_B0, "/dt_wbuf_bank0.mem"};
  localparam string DT1  = {STAGE_B0, "/dt_wbuf_bank1.mem"};
  localparam string DT2  = {STAGE_B0, "/dt_wbuf_bank2.mem"};
  localparam string DT3  = {STAGE_B0, "/dt_wbuf_bank3.mem"};
  localparam string DTS  = {STAGE_B0, "/dt_scale_q15.mem"};
  localparam string OUT0 = {STAGE_B0, "/outproj_wbuf_bank0.mem"};
  localparam string OUT1 = {STAGE_B0, "/outproj_wbuf_bank1.mem"};
  localparam string OUT2 = {STAGE_B0, "/outproj_wbuf_bank2.mem"};
  localparam string OUT3 = {STAGE_B0, "/outproj_wbuf_bank3.mem"};
  localparam string OUT4 = {STAGE_B0, "/outproj_wbuf_bank4.mem"};
  localparam string OUT5 = {STAGE_B0, "/outproj_wbuf_bank5.mem"};
  localparam string OUTS = {STAGE_B0, "/outproj_scale_q15.mem"};
  localparam string GAM  = {STAGE_B0, "/norm_gamma_s16_q8p8.mem"};
  localparam string BIAS = {STAGE_B0, "/bias_ROM.mem"};
  localparam string SUS  = {STAGE_B0, "/state_u_to_state_q16.mem"};
  localparam string STQ  = {STAGE_B0, "/state_to_q88_q16.mem"};

  logic clk;
  logic rst_n;
  logic block_start;
  logic block_busy;
  logic block_done;
  logic h_wr_en;
  logic [4:0] h_wr_addr;
  logic signed [DATA_WIDTH-1:0] h_wr_data [TILE_SIZE-1:0];
  logic y_valid;
  logic y_ready;
  logic signed [DATA_WIDTH-1:0] y_data [TILE_SIZE-1:0];

  logic [63:0] h_wr_data_mem [0:H_DEPTH-1];
  logic [63:0] y_golden_mem  [0:Y_DEPTH-1];

  int y_idx;
  int y_err;

  function automatic logic signed [DATA_WIDTH-1:0] unpack_lane64(input logic [63:0] packed_word, input int lane);
    unpack_lane64 = $signed(packed_word[lane*DATA_WIDTH +: DATA_WIDTH]);
  endfunction

  function automatic int abs_i(input int v);
    if (v < 0) abs_i = -v;
    else       abs_i = v;
  endfunction

  task automatic load_case();
    begin
      $readmemh({STAGE_B0, "/h_wr_data_s16_q8p8.mem"}, h_wr_data_mem);
      $readmemh({STAGE_B0, "/y_golden_q88.mem"}, y_golden_mem);
    end
  endtask

  task automatic preload_h0();
    begin
      for (int r = 0; r < H_DEPTH; r++) begin
        @(posedge clk);
        h_wr_en <= 1'b1;
        h_wr_addr <= r[4:0];
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          h_wr_data[lane] <= unpack_lane64(h_wr_data_mem[r], lane);
        end
      end
      @(posedge clk);
      h_wr_en <= 1'b0;
      h_wr_addr <= '0;
      for (int lane = 0; lane < TILE_SIZE; lane++) begin
        h_wr_data[lane] <= '0;
      end
    end
  endtask

  task automatic check_y();
    logic signed [DATA_WIDTH-1:0] got_v, exp_v;
    logic [63:0] exp_pack;
    begin
      while (y_idx < Y_DEPTH) begin
        @(posedge clk);
        if (y_valid && y_ready) begin
          exp_pack = y_golden_mem[y_idx];
          for (int lane = 0; lane < TILE_SIZE; lane++) begin
            int d;
            got_v = y_data[lane];
            exp_v = unpack_lane64(exp_pack, lane);
            d = got_v - exp_v;
            if (ALLOW_LSB1_FOR_Y ? (abs_i(d) > 1) : (d != 0)) begin
              y_err++;
              if (y_err == 1) begin
                $error("[%0t] FIRST exact-block y mismatch row=%0d lane=%0d got=%0d exp=%0d",
                       $time, y_idx, lane, got_v, exp_v);
              end
            end
          end
          y_idx++;
        end
      end
    end
  endtask

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst_n = 1'b0;
    block_start = 1'b0;
    h_wr_en = 1'b0;
    h_wr_addr = '0;
    y_ready = 1'b1;
    y_idx = 0;
    y_err = 0;
    for (int lane = 0; lane < TILE_SIZE; lane++) begin
      h_wr_data[lane] = '0;
    end

    load_case();
    repeat (20) @(posedge clk);
    rst_n = 1'b1;
    repeat (10) @(posedge clk);
    preload_h0();
    repeat (8) @(posedge clk);

    @(posedge clk);
    block_start <= 1'b1;
    @(posedge clk);
    block_start <= 1'b0;

    fork
      check_y();
      begin
        wait(block_done);
      end
    join

    if (y_err != 0) begin
      $fatal(1, "[%0t] found %0d exact-block y mismatches", $time, y_err);
    end
    $display("[%0t] PASS exact block final y compare", $time);
    #100;
    $finish;
  end

  initial begin : timeout_guard
    #3000000;
    $fatal(1, "[%0t] timeout waiting exact block completion y_idx=%0d busy=%0b", $time, y_idx, block_busy);
  end

  slim_mamba_block #(
      .TILE_SIZE(TILE_SIZE),
      .DATA_WIDTH(DATA_WIDTH),
      .LUT_FILE(LUT_PATH),
      .INPROJ_BANK0_INIT_FILE(IN0),
      .INPROJ_BANK1_INIT_FILE(IN1),
      .INPROJ_BANK2_INIT_FILE(IN2),
      .INPROJ_BANK3_INIT_FILE(IN3),
      .INPROJ_BANK4_INIT_FILE(IN4),
      .INPROJ_BANK5_INIT_FILE(IN5),
      .INPROJ_SCALE_INIT_FILE(INS),
      .DT_BANK0_INIT_FILE(DT0),
      .DT_BANK1_INIT_FILE(DT1),
      .DT_BANK2_INIT_FILE(DT2),
      .DT_BANK3_INIT_FILE(DT3),
      .DT_SCALE_INIT_FILE(DTS),
      .OUTPROJ_BANK0_INIT_FILE(OUT0),
      .OUTPROJ_BANK1_INIT_FILE(OUT1),
      .OUTPROJ_BANK2_INIT_FILE(OUT2),
      .OUTPROJ_BANK3_INIT_FILE(OUT3),
      .OUTPROJ_BANK4_INIT_FILE(OUT4),
      .OUTPROJ_BANK5_INIT_FILE(OUT5),
      .OUTPROJ_SCALE_INIT_FILE(OUTS),
      .NORM_GAMMA_INIT_FILE(GAM),
      .BIAS_INIT_FILE(BIAS),
      .STATE_U_TO_STATE_SCALE_INIT_FILE(SUS),
      .STATE_TO_Q88_SCALE_INIT_FILE(STQ),
      .BLOCK_CFG(make_block_cfg_from_flags(1'b0, 1'b0, 1'b0, 1'b1, 1'b0))
  ) dut (
      .clk(clk),
      .rst_n(rst_n),
      .block_start(block_start),
      .block_busy(block_busy),
      .block_done(block_done),
      .h_wr_en(h_wr_en),
      .h_wr_addr(h_wr_addr),
      .h_wr_data(h_wr_data),
      .y_axis_TVALID(y_valid),
      .y_axis_TREADY(y_ready),
      .y_axis_TDATA(y_data)
  );
endmodule

