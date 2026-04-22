`timescale 1ns/1ps

`ifndef HW_DEBUG_CASE_DIR
  `define HW_DEBUG_CASE_DIR "E:/course/smamba/final_hw/cases/c02"
`endif

module tb_reuse_mamba_block_top_hw_debug;
  localparam int TILE_SIZE   = 4;
  localparam int DATA_WIDTH  = 16;
  localparam int H_DEPTH     = 32;
  localparam int Y_DEPTH     = 32;
  localparam bit ALLOW_LSB1_FOR_Y = 1;

  localparam string CASE_DIR = `HW_DEBUG_CASE_DIR;
  localparam string STAGE_B0_CONST = {CASE_DIR, "/stages/reuse_mamba_block_top_block0"};

  logic clk;
  logic rst_n;

  logic                             s_axis_h_tvalid;
  logic                             s_axis_h_tready;
  logic [TILE_SIZE*DATA_WIDTH-1:0]  s_axis_h_tdata;
  logic                             s_axis_h_tlast;
  logic                             m_axis_y_tvalid;
  logic                             m_axis_y_tready;
  logic [TILE_SIZE*DATA_WIDTH-1:0]  m_axis_y_tdata;
  logic                             m_axis_y_tlast;
  logic                             frame_busy;

  logic [63:0] h_wr_data_mem   [0:H_DEPTH-1];
  logic [63:0] h_norm_golden   [0:H_DEPTH-1];
  logic [63:0] y_blk0_golden   [0:Y_DEPTH-1];
  logic [63:0] y_final_golden  [0:Y_DEPTH-1];

  int tx_idx;
  int rx_idx;
  int rms_seen_rows;
  int rms_cmp_rows;
  int blk0_seen_rows;
  int rms_mismatch_cnt;
  int blk0_mismatch_cnt;
  int y_mismatch_cnt;
  bit rms_first_reported;
  bit blk0_first_reported;
  bit y_first_reported;
  bit send_done;

  function automatic logic signed [DATA_WIDTH-1:0] unpack_lane64(input logic [63:0] packed_word, input int lane);
    unpack_lane64 = $signed(packed_word[lane*DATA_WIDTH +: DATA_WIDTH]);
  endfunction

  function automatic int abs_i(input int v);
    if (v < 0) abs_i = -v;
    else       abs_i = v;
  endfunction

  task automatic load_case_files();
    begin
      $readmemh({STAGE_B0_CONST, "/h_wr_data_s16_q8p8.mem"}, h_wr_data_mem);
      $readmemh({STAGE_B0_CONST, "/h_norm_golden_s16_q8p8.mem"}, h_norm_golden);
      $readmemh({STAGE_B0_CONST, "/y_golden_q88.mem"}, y_blk0_golden);
      $readmemh({CASE_DIR, "/stages/reuse_mamba_block_top_chain4/final_y_golden_q88.mem"}, y_final_golden);
    end
  endtask

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst_n = 1'b0;
    s_axis_h_tvalid = 1'b0;
    s_axis_h_tdata  = '0;
    s_axis_h_tlast  = 1'b0;
    m_axis_y_tready = 1'b1;
    tx_idx = 0;
    rx_idx = 0;
    rms_seen_rows = 0;
    rms_cmp_rows = 0;
    blk0_seen_rows = 0;
    rms_mismatch_cnt = 0;
    blk0_mismatch_cnt = 0;
    y_mismatch_cnt = 0;
    rms_first_reported = 1'b0;
    blk0_first_reported = 1'b0;
    y_first_reported = 1'b0;
    send_done = 1'b0;
    load_case_files();
    repeat (20) @(posedge clk);
    rst_n = 1'b1;
  end

  initial begin : drive_h_frame
    wait(rst_n);
    @(posedge clk);
    while (tx_idx < H_DEPTH) begin
      @(posedge clk);
      s_axis_h_tvalid <= 1'b1;
      s_axis_h_tdata  <= h_wr_data_mem[tx_idx];
      s_axis_h_tlast  <= (tx_idx == (H_DEPTH - 1));
      if (s_axis_h_tready) begin
        tx_idx <= tx_idx + 1;
      end
    end
    @(posedge clk);
    s_axis_h_tvalid <= 1'b0;
    s_axis_h_tdata  <= '0;
    s_axis_h_tlast  <= 1'b0;
    send_done <= 1'b1;
  end

  // RMSNorm writeback check (strict exact compare).
  // Important: u_rmsnorm drives norm_wr_en in multiple internal phases.
  // Only ST_NORM writes are final valid normalized outputs.
  always @(posedge clk) begin
    if (rst_n && dut.u_core.u_core.u_blk0.norm_wr_en) begin
      int row_idx;
      row_idx = dut.u_core.u_core.u_blk0.norm_wr_addr;
      if (dut.u_core.u_core.u_blk0.g_rmsnorm.u_rmsnorm.state == 3'd5) begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          logic signed [DATA_WIDTH-1:0] got_v, exp_v;
          got_v = dut.u_core.u_core.u_blk0.norm_wr_data[lane];
          exp_v = unpack_lane64(h_norm_golden[row_idx], lane);
          if (got_v !== exp_v) begin
            rms_mismatch_cnt++;
            if (!rms_first_reported) begin
              $display("[%0t] RMS first mismatch row=%0d lane=%0d got=%0d exp=%0d",
                       $time, row_idx, lane, got_v, exp_v);
              rms_first_reported <= 1'b1;
            end
          end
        end
        rms_cmp_rows <= rms_cmp_rows + 1;
      end
      rms_seen_rows <= rms_seen_rows + 1;
    end
  end

  // blk0 local y stream check (allow optional 1-LSB tolerance).
  always @(posedge clk) begin
    if (rst_n && dut.u_core.u_core.blk_y_valid[0] && dut.u_core.u_core.blk_y_ready[0]) begin
      for (int lane = 0; lane < TILE_SIZE; lane++) begin
        int got_v, exp_v, d;
        got_v = dut.u_core.u_core.blk_y_data[0][lane];
        exp_v = unpack_lane64(y_blk0_golden[blk0_seen_rows], lane);
        d = got_v - exp_v;
        if (ALLOW_LSB1_FOR_Y ? (abs_i(d) > 1) : (d != 0)) begin
          blk0_mismatch_cnt++;
          if (!blk0_first_reported) begin
            $display("[%0t] BLK0-Y first mismatch row=%0d lane=%0d got=%0d exp=%0d",
                     $time, blk0_seen_rows, lane, got_v, exp_v);
            blk0_first_reported <= 1'b1;
          end
        end
      end
      blk0_seen_rows <= blk0_seen_rows + 1;
    end
  end

  // Final y output check (allow optional 1-LSB tolerance).
  initial begin : check_final_y
    wait(rst_n);
    while (rx_idx < Y_DEPTH) begin
      @(posedge clk);
      if (m_axis_y_tvalid && m_axis_y_tready) begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          int got_v, exp_v, d;
          got_v = $signed(m_axis_y_tdata[lane*DATA_WIDTH +: DATA_WIDTH]);
          exp_v = unpack_lane64(y_final_golden[rx_idx], lane);
          d = got_v - exp_v;
          if (ALLOW_LSB1_FOR_Y ? (abs_i(d) > 1) : (d != 0)) begin
            y_mismatch_cnt++;
            if (!y_first_reported) begin
              $display("[%0t] FINAL-Y first mismatch row=%0d lane=%0d got=%0d exp=%0d",
                       $time, rx_idx, lane, got_v, exp_v);
              y_first_reported = 1'b1;
            end
          end
        end
        rx_idx++;
      end
    end

    // Small settle for late debug counters.
    repeat (20) @(posedge clk);
    $display("[%0t] SUMMARY rms_rows_total=%0d rms_rows_compared=%0d blk0_rows=%0d y_rows=%0d", $time, rms_seen_rows, rms_cmp_rows, blk0_seen_rows, rx_idx);
    $display("[%0t] SUMMARY rms_mis=%0d blk0_y_mis=%0d final_y_mis=%0d", $time, rms_mismatch_cnt, blk0_mismatch_cnt, y_mismatch_cnt);

    if (rms_mismatch_cnt != 0) begin
      $fatal(1, "[%0t] RMSNorm mismatch count=%0d", $time, rms_mismatch_cnt);
    end
    if (blk0_mismatch_cnt != 0) begin
      $fatal(1, "[%0t] BLK0 y mismatch count=%0d (tol=%0d)", $time, blk0_mismatch_cnt, (ALLOW_LSB1_FOR_Y ? 1 : 0));
    end
    if (y_mismatch_cnt != 0) begin
      $fatal(1, "[%0t] Final y mismatch count=%0d (tol=%0d)", $time, y_mismatch_cnt, (ALLOW_LSB1_FOR_Y ? 1 : 0));
    end
    $display("[%0t] PASS tb_reuse_mamba_block_top_hw_debug", $time);
    #100;
    $finish;
  end

  initial begin : timeout_guard
    #2000000;
    $fatal(1, "[%0t] timeout tx=%0d rx=%0d send_done=%0b frame_busy=%0b", $time, tx_idx, rx_idx, send_done, frame_busy);
  end

  reuse_mamba_board_shell_stream #(
    .TILE_SIZE (TILE_SIZE),
    .DATA_WIDTH(DATA_WIDTH),
    .H_ROWS    (H_DEPTH)
  ) dut (
    .sys_clk        (clk),
    .ext_reset_n    (rst_n),
    .s_axis_h_tvalid(s_axis_h_tvalid),
    .s_axis_h_tready(s_axis_h_tready),
    .s_axis_h_tdata (s_axis_h_tdata),
    .s_axis_h_tlast (s_axis_h_tlast),
    .m_axis_y_tvalid(m_axis_y_tvalid),
    .m_axis_y_tready(m_axis_y_tready),
    .m_axis_y_tdata (m_axis_y_tdata),
    .m_axis_y_tlast (m_axis_y_tlast),
    .frame_busy     (frame_busy)
  );

endmodule
