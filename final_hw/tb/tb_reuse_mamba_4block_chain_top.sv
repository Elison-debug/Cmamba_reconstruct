`timescale 1ns/1ps

`ifndef HW_DEBUG_CASE_DIR
  `define HW_DEBUG_CASE_DIR "E:/course/smamba/final_hw/cases/c01"
`endif

module tb_reuse_mamba_4block_chain_top;
  localparam int TILE_SIZE  = 4;
  localparam int DATA_WIDTH = 16;
  localparam int H_DEPTH = 32;
  localparam int Y_DEPTH = 32;
  localparam string CASE_DIR = `HW_DEBUG_CASE_DIR;
  localparam string STAGE_B0_CONST = {CASE_DIR, "/stages/reuse_mamba_block_top_block0"};
  localparam string STAGE_B1_CONST = {CASE_DIR, "/stages/reuse_mamba_block_top_block1"};
  localparam string STAGE_B2_CONST = {CASE_DIR, "/stages/reuse_mamba_block_top_block2"};
  localparam string STAGE_B3_CONST = {CASE_DIR, "/stages/reuse_mamba_block_top_block3"};
  localparam string LUT_PATH_CONST = "E:/course/smamba/user/data/sigmoid_lut_q016_2048.hex";

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
  logic [63:0] h_wr_data_b3_mem [0:H_DEPTH-1];
  logic [63:0] y_b0_mem [0:Y_DEPTH-1];
  logic [63:0] y_b1_mem [0:Y_DEPTH-1];
  logic [63:0] y_b2_mem [0:Y_DEPTH-1];
  logic [63:0] y_b3_mem [0:Y_DEPTH-1];
  logic [63:0] y_golden_mem  [0:Y_DEPTH-1];

  int y_idx;
  int y_err;
  int blk_y_idx [0:3];
  int blk_y_err [0:3];
  bit b3_input_checked;

  string case_dir;
  string stage_b0;
  string stage_b1;
  string stage_b2;
  string stage_b3;
  string chain_dir;
  string lut_path;

  function automatic logic signed [DATA_WIDTH-1:0] unpack_lane64(input logic [63:0] packed_word, input int lane);
    unpack_lane64 = $signed(packed_word[lane*DATA_WIDTH +: DATA_WIDTH]);
  endfunction

  function automatic string join_path(input string a, input string b);
    join_path = {a, "/", b};
  endfunction

  task automatic load_case();
    begin
      case_dir = CASE_DIR;
      stage_b0 = join_path(case_dir, "stages/reuse_mamba_block_top_block0");
      stage_b1 = join_path(case_dir, "stages/reuse_mamba_block_top_block1");
      stage_b2 = join_path(case_dir, "stages/reuse_mamba_block_top_block2");
      stage_b3 = join_path(case_dir, "stages/reuse_mamba_block_top_block3");
      chain_dir = join_path(case_dir, "stages/reuse_mamba_block_top_chain4");
      lut_path = LUT_PATH_CONST;
      $readmemh(join_path(stage_b0, "h_wr_data_s16_q8p8.mem"), h_wr_data_mem);
      $readmemh(join_path(stage_b3, "h_wr_data_s16_q8p8.mem"), h_wr_data_b3_mem);
      $readmemh(join_path(stage_b0, "y_golden_q88.mem"), y_b0_mem);
      $readmemh(join_path(stage_b1, "y_golden_q88.mem"), y_b1_mem);
      $readmemh(join_path(stage_b2, "y_golden_q88.mem"), y_b2_mem);
      $readmemh(join_path(stage_b3, "y_golden_q88.mem"), y_b3_mem);
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
            got_v = y_data[lane];
            exp_v = unpack_lane64(exp_pack, lane);
            if (got_v !== exp_v) begin
              y_err++;
              if (y_err == 1) begin
                $error("[%0t] FIRST final-y mismatch row=%0d lane=%0d got=%0d exp=%0d", $time, y_idx, lane, got_v, exp_v);
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
    for (int bi = 0; bi < 4; bi++) begin
      blk_y_idx[bi] = 0;
      blk_y_err[bi] = 0;
    end
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
      $fatal(1, "[%0t] found %0d final-y mismatches in 4-block chain", $time, y_err);
    end
    $display("[%0t] PASS 4-block chain final y compare", $time);
    #100;
    $finish;
  end

  reuse_mamba_4block_chain_top #(
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

  always_ff @(posedge clk) begin
    if (rst_n && !b3_input_checked) begin
      // ST_LAUNCH == 2'd3, cur_blk==3 means block3 is about to start.
      if (dut.state == 2'd3 && dut.cur_blk == 2'd3) begin
        int b3_mis;
        b3_input_checked <= 1'b1;
        b3_mis = 0;
        for (int r = 0; r < H_DEPTH; r++) begin
          for (int lane = 0; lane < TILE_SIZE; lane++) begin
            if (dut.residual_cur[r][lane] !== unpack_lane64(h_wr_data_b3_mem[r], lane)) begin
              if (b3_mis < 8) begin
                $display("[%0t] DEBUG b3-input mismatch row=%0d lane=%0d got=%0d exp=%0d",
                         $time, r, lane, dut.residual_cur[r][lane], unpack_lane64(h_wr_data_b3_mem[r], lane));
              end
              b3_mis++;
            end
          end
        end
        if (b3_mis == 0) $display("[%0t] DEBUG b3-input compare PASS", $time);
        else $display("[%0t] DEBUG b3-input mismatches=%0d", $time, b3_mis);
      end
    end
  end

  always_ff @(posedge clk) begin
    for (int bi = 0; bi < 4; bi++) begin
      logic [63:0] exp_pack;
      logic signed [DATA_WIDTH-1:0] got_v, exp_v;
      if (dut.blk_y_valid[bi] && dut.blk_y_ready[bi]) begin
        case (bi)
          0: exp_pack = y_b0_mem[blk_y_idx[bi]];
          1: exp_pack = y_b1_mem[blk_y_idx[bi]];
          2: exp_pack = y_b2_mem[blk_y_idx[bi]];
          default: exp_pack = y_b3_mem[blk_y_idx[bi]];
        endcase
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          got_v = dut.blk_y_data[bi][lane];
          exp_v = unpack_lane64(exp_pack, lane);
          if (got_v !== exp_v) begin
            blk_y_err[bi]++;
            if (blk_y_err[bi] <= 4) begin
              $display("[%0t] DEBUG blk%0d-y mismatch row=%0d lane=%0d got=%0d exp=%0d",
                       $time, bi, blk_y_idx[bi], lane, got_v, exp_v);
            end
          end
        end
        blk_y_idx[bi]++;
      end
    end
  end

endmodule
