`timescale 1ns/1ps
`include "tb_hw_debug_case_path.svh"

`ifndef HW_DEBUG_CASE_DIR
  `define HW_DEBUG_CASE_DIR "E:/course/smamba/HW/cases/04"
`endif

module tb_reuse_mamba_block_top_hw_debug;
  localparam int TILE_SIZE   = 4;
  localparam int DATA_WIDTH  = 16;
  localparam int H_DEPTH     = 32;
  localparam int Y_DEPTH     = 32;
  localparam bit ALLOW_LSB1_FOR_Y = 1;

  localparam string CASE_DIR = `HW_DEBUG_CASE_DIR;
  localparam string STAGE_B0 = {CASE_DIR, "/stages/reuse_mamba_block_top_block0"};
  localparam string STAGE_B1 = {CASE_DIR, "/stages/reuse_mamba_block_top_block1"};
  localparam string STAGE_B2 = {CASE_DIR, "/stages/reuse_mamba_block_top_block2"};
  localparam string STAGE_B3 = {CASE_DIR, "/stages/reuse_mamba_block_top_block3"};
  localparam string STAGE_C4 = {CASE_DIR, "/stages/reuse_mamba_block_top_chain4"};

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

  logic [63:0] h_wr_data_mem  [0:H_DEPTH-1];
  logic [63:0] y_final_golden [0:Y_DEPTH-1];

  int tx_idx;
  int rx_idx;
  int cap_row_idx;
  int cap_frame_idx;
  int y_mismatch_cnt;
  bit y_first_reported;
  bit send_done;
  bit frame_armed;

  function automatic logic signed [DATA_WIDTH-1:0] unpack_lane64(input logic [63:0] packed_word, input int lane);
    unpack_lane64 = $signed(packed_word[lane*DATA_WIDTH +: DATA_WIDTH]);
  endfunction

  function automatic int abs_i(input int v);
    if (v < 0) abs_i = -v;
    else       abs_i = v;
  endfunction

  task automatic load_case_files();
    begin
      $readmemh({STAGE_B0, "/h_wr_data_s16_q8p8.mem"}, h_wr_data_mem);
      $readmemh({STAGE_C4, "/final_y_golden_q88.mem"}, y_final_golden);
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
    cap_row_idx = 0;
    cap_frame_idx = 0;
    y_mismatch_cnt = 0;
    y_first_reported = 1'b0;
    send_done = 1'b0;
    frame_armed = 1'b0;
    load_case_files();
    $display("[TB] CASE_DIR=%s", CASE_DIR);
    $display("[TB] STAGE_B0=%s", STAGE_B0);
    $display("[TB] DUT_STAGE_B0=%s", dut.STAGE_DIR_B0);
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

  initial begin : check_final_y
    wait(rst_n);
    forever begin
      @(posedge clk);

      // Arm frame capture only after full H-frame has been sent.
      if (send_done && !frame_armed) begin
        frame_armed <= 1'b1;
        cap_row_idx <= 0;
        cap_frame_idx <= 0;
      end

      if (!(frame_armed && m_axis_y_tvalid && m_axis_y_tready))
        continue;

      if (cap_row_idx < Y_DEPTH) begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          int got_v, exp_v, d;
          got_v = $signed(m_axis_y_tdata[lane*DATA_WIDTH +: DATA_WIDTH]);
          exp_v = unpack_lane64(y_final_golden[cap_row_idx], lane);
          d = got_v - exp_v;
          if (ALLOW_LSB1_FOR_Y ? (abs_i(d) > 1) : (d != 0)) begin
            y_mismatch_cnt++;
            if (!y_first_reported) begin
              $display("[%0t] FINAL-Y first mismatch row=%0d lane=%0d got=%0d exp=%0d",
                       $time, cap_row_idx, lane, got_v, exp_v);
              y_first_reported = 1'b1;
            end
          end
        end
      end
      cap_row_idx++;

      if (m_axis_y_tlast) begin
        if (cap_row_idx == Y_DEPTH) begin
          rx_idx = cap_row_idx;
          break;
        end
        // Misframed burst; restart capture on next frame boundary.
        cap_frame_idx <= cap_frame_idx + 1;
        cap_row_idx <= 0;
      end
    end

    repeat (20) @(posedge clk);
    $display("[%0t] SUMMARY y_rows=%0d frame_idx=%0d final_y_mis=%0d", $time, rx_idx, cap_frame_idx, y_mismatch_cnt);
    if (y_mismatch_cnt != 0) begin
      $fatal(1, "[%0t] Final y mismatch count=%0d (tol=%0d)", $time, y_mismatch_cnt, (ALLOW_LSB1_FOR_Y ? 1 : 0));
    end
    $display("[%0t] PASS tb_reuse_mamba_block_top_hw_debug", $time);
    #100;
    $finish;
  end

  initial begin : timeout_guard
    #2000000;
    $fatal(1, "[%0t] timeout tx=%0d rx=%0d frame_busy=%0b", $time, tx_idx, rx_idx, frame_busy);
  end

  reuse_mamba_board_shell_stream #(
    .TILE_SIZE (TILE_SIZE),
    .DATA_WIDTH(DATA_WIDTH),
    .H_ROWS    (H_DEPTH),
    .STAGE_DIR_B0(STAGE_B0),
    .STAGE_DIR_B1(STAGE_B1),
    .STAGE_DIR_B2(STAGE_B2),
    .STAGE_DIR_B3(STAGE_B3)
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
