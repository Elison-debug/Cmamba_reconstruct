`timescale 1ns/1ps
`include "tb_hw_debug_case_path.svh"

`ifndef HW_DEBUG_CASE_DIR
  `define HW_DEBUG_CASE_DIR "E:/course/smamba/final_hw/cases/c01"
`endif

module tb_slim_mamba_chain4;
  localparam int TILE_SIZE  = 4;
  localparam int DATA_WIDTH = 16;
  localparam int H_DEPTH = 32;
  localparam int Y_DEPTH = 32;
  localparam bit ALLOW_LSB1_FOR_Y = 1;
  localparam string CASE_DIR = `HW_DEBUG_CASE_DIR;
  localparam string STAGE_B0_CONST = {CASE_DIR, "/stages/reuse_mamba_block_top_block0"};
  localparam string STAGE_B1_CONST = {CASE_DIR, "/stages/reuse_mamba_block_top_block1"};
  localparam string STAGE_B2_CONST = {CASE_DIR, "/stages/reuse_mamba_block_top_block2"};
  localparam string STAGE_B3_CONST = {CASE_DIR, "/stages/reuse_mamba_block_top_block3"};
  localparam string LUT_PATH_CONST = "E:/course/smamba/HW/ip/sigmoid_lut_q016_2048.hex";

  logic clk;
  logic rst_n;
  logic start;
  logic busy;
  logic done;
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

  function automatic string join_path(input string a, input string b);
    join_path = {a, "/", b};
  endfunction

  function automatic int abs_i(input int v);
    if (v < 0) abs_i = -v;
    else       abs_i = v;
  endfunction

  task automatic load_case();
    string stage_b0;
    string chain_dir;
    begin
      stage_b0 = join_path(CASE_DIR, "stages/reuse_mamba_block_top_block0");
      chain_dir = join_path(CASE_DIR, "stages/reuse_mamba_block_top_chain4");
      $readmemh(join_path(stage_b0, "h_wr_data_s16_q8p8.mem"), h_wr_data_mem);
      $readmemh(join_path(chain_dir, "final_y_golden_q88.mem"), y_golden_mem);
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
                $error("[%0t] FIRST slim chain final-y mismatch row=%0d lane=%0d got=%0d exp=%0d",
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
    start = 1'b0;
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
    start <= 1'b1;
    @(posedge clk);
    start <= 1'b0;

    fork
      check_y();
      begin
        wait(done);
      end
    join

    if (y_err != 0) begin
      $fatal(1, "[%0t] found %0d final-y mismatches in slim 4-block chain", $time, y_err);
    end
    $display("[%0t] PASS slim 4-block chain final y compare", $time);
    #100;
    $finish;
  end

  initial begin : timeout_guard
    #5000000;
    $fatal(1, "[%0t] timeout waiting slim chain completion y_idx=%0d busy=%0b", $time, y_idx, busy);
  end

  slim_mamba_chain4 #(
      .TILE_SIZE(TILE_SIZE),
      .DATA_WIDTH(DATA_WIDTH),
      .LUT_FILE(LUT_PATH_CONST),
      .STAGE_DIR_B0(STAGE_B0_CONST),
      .STAGE_DIR_B1(STAGE_B1_CONST),
      .STAGE_DIR_B2(STAGE_B2_CONST),
      .STAGE_DIR_B3(STAGE_B3_CONST)
  ) dut (
      .clk(clk),
      .rst_n(rst_n),
      .start(start),
      .busy(busy),
      .done(done),
      .h_wr_en(h_wr_en),
      .h_wr_addr(h_wr_addr),
      .h_wr_data(h_wr_data),
      .y_valid(y_valid),
      .y_ready(y_ready),
      .y_data(y_data)
  );
endmodule

