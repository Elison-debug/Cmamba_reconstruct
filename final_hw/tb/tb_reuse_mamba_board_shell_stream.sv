`timescale 1ns/1ps

`ifndef HW_DEBUG_CASE_DIR
  `define HW_DEBUG_CASE_DIR "E:/course/smamba/HW_reconstruct/hw_debug/cases/test_case3_smoke"
`endif

module tb_reuse_mamba_board_shell_stream;
  localparam int TILE_SIZE  = 4;
  localparam int DATA_WIDTH = 16;
  localparam int H_DEPTH    = 32;
  localparam int Y_DEPTH    = 32;
  localparam int N_FRAMES   = 3;
  localparam bit CHECK_FRAME0_GOLDEN = 0;
  localparam bit REQUIRE_REPEATABLE = 0;
  localparam string CASE_DIR = `HW_DEBUG_CASE_DIR;
  localparam string STAGE_B0_CONST = {CASE_DIR, "/stages/reuse_mamba_block_top_block0"};
  localparam string STAGE_B1_CONST = {CASE_DIR, "/stages/reuse_mamba_block_top_block1"};
  localparam string STAGE_B2_CONST = {CASE_DIR, "/stages/reuse_mamba_block_top_block2"};
  localparam string STAGE_B3_CONST = {CASE_DIR, "/stages/reuse_mamba_block_top_block3"};
  localparam string LUT_PATH_CONST = "E:/course/smamba/user/data/sigmoid_lut_q016_2048.hex";

  logic clk;
  logic rst_n;

  logic                           s_axis_h_tvalid;
  logic                           s_axis_h_tready;
  logic [TILE_SIZE*DATA_WIDTH-1:0] s_axis_h_tdata;
  logic                           s_axis_h_tlast;

  logic                           m_axis_y_tvalid;
  logic                           m_axis_y_tready;
  logic [TILE_SIZE*DATA_WIDTH-1:0] m_axis_y_tdata;
  logic                           m_axis_y_tlast;
  logic                           frame_busy;

  logic [63:0] h_wr_data_mem [0:H_DEPTH-1];
  logic [63:0] y_frame0_mem  [0:Y_DEPTH-1];
  logic [63:0] y_golden_mem  [0:Y_DEPTH-1];

  int tx_idx;
  int rx_frame;
  int rx_row;
  int rx_total_beats;
  int rx_tlast_count;
  int mismatch_cnt;

  function automatic logic signed [DATA_WIDTH-1:0] unpack_lane64(input logic [63:0] packed_word, input int lane);
    unpack_lane64 = $signed(packed_word[lane*DATA_WIDTH +: DATA_WIDTH]);
  endfunction

  task automatic load_case();
    string stage_b0;
    begin
      stage_b0 = {CASE_DIR, "/stages/reuse_mamba_block_top_block0"};
      $readmemh({stage_b0, "/h_wr_data_s16_q8p8.mem"}, h_wr_data_mem);
      $readmemh({stage_b0, "/y_golden_q88.mem"}, y_golden_mem);
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
    rx_frame = 0;
    rx_row = 0;
    rx_total_beats = 0;
    rx_tlast_count = 0;
    mismatch_cnt = 0;
    load_case();
    repeat (20) @(posedge clk);
    rst_n = 1'b1;
  end

  // Continuous producer: pushes N_FRAMES*H_DEPTH beats with backpressure handling.
  initial begin : push_h_stream
    int total_beats;
    total_beats = N_FRAMES * H_DEPTH;
    wait(rst_n);
    @(posedge clk);
    while (tx_idx < total_beats) begin
      @(posedge clk);
      s_axis_h_tvalid <= 1'b1;
      s_axis_h_tdata  <= h_wr_data_mem[tx_idx % H_DEPTH];
      s_axis_h_tlast  <= ((tx_idx % H_DEPTH) == (H_DEPTH - 1));
      if (s_axis_h_tvalid && s_axis_h_tready) begin
        tx_idx <= tx_idx + 1;
      end
    end
    @(posedge clk);
    s_axis_h_tvalid <= 1'b0;
    s_axis_h_tdata  <= '0;
    s_axis_h_tlast  <= 1'b0;
    $display("[%0t] INFO push_h_stream done tx_idx=%0d", $time, tx_idx);
  end

  // Strict checker:
  // 1) Never allow X/Z on output handshake/data/last.
  // 2) Frame0 must match exported y_golden.
  // 3) Optional repeatability check for later frames.
  // 4) TLAST must align to frame boundaries.
  initial begin : check_y_stream
    wait(rst_n);
    while (rx_total_beats < (N_FRAMES * Y_DEPTH)) begin
      @(posedge clk);
      if ($isunknown(m_axis_y_tvalid) || $isunknown(m_axis_y_tready)) begin
        $fatal(1, "[%0t] X/Z on y handshake", $time);
      end
      if (m_axis_y_tvalid && m_axis_y_tready) begin
        if ($isunknown(m_axis_y_tdata) || $isunknown(m_axis_y_tlast)) begin
          $fatal(1, "[%0t] X/Z on y payload frame=%0d row=%0d data=%h last=%b",
                 $time, rx_frame, rx_row, m_axis_y_tdata, m_axis_y_tlast);
        end

        if (rx_frame == 0) begin
          if (m_axis_y_tdata !== y_golden_mem[rx_row]) begin
            if (CHECK_FRAME0_GOLDEN) begin
              mismatch_cnt++;
              if (mismatch_cnt <= 8) begin
                $display("[%0t] golden mismatch frame=%0d row=%0d got=%h exp=%h",
                         $time, rx_frame, rx_row, m_axis_y_tdata, y_golden_mem[rx_row]);
              end
            end
          end
          y_frame0_mem[rx_row] = m_axis_y_tdata;
        end else if (REQUIRE_REPEATABLE) begin
          if (m_axis_y_tdata !== y_frame0_mem[rx_row]) begin
            mismatch_cnt++;
            if (mismatch_cnt <= 8) begin
              $display("[%0t] mismatch frame=%0d row=%0d got=%h exp=%h",
                       $time, rx_frame, rx_row, m_axis_y_tdata, y_frame0_mem[rx_row]);
            end
          end
        end
        rx_total_beats++;

        if (rx_row == (Y_DEPTH - 1)) begin
          if (m_axis_y_tlast !== 1'b1) begin
            $fatal(1, "[%0t] missing tlast at frame end frame=%0d row=%0d", $time, rx_frame, rx_row);
          end
          rx_tlast_count++;
          rx_row   = 0;
          rx_frame = rx_frame + 1;
          $display("[%0t] INFO frame complete frame=%0d total=%0d", $time, rx_frame, rx_total_beats);
        end else begin
          if (m_axis_y_tlast === 1'b1) begin
            $fatal(1, "[%0t] early tlast frame=%0d row=%0d", $time, rx_frame, rx_row);
          end
          rx_row = rx_row + 1;
        end
      end
    end

    if (rx_tlast_count != N_FRAMES) begin
      $fatal(1, "[%0t] tlast count mismatch got=%0d exp=%0d", $time, rx_tlast_count, N_FRAMES);
    end
    if (mismatch_cnt != 0) begin
      $fatal(1, "[%0t] stream multi-frame mismatch count=%0d", $time, mismatch_cnt);
    end
    $display("[%0t] PASS stream shell multi-frame check (%0d frames)", $time, N_FRAMES);
    #100;
    $finish;
  end

  initial begin : timeout_guard
    #2000000;
    $fatal(1, "[%0t] timeout in tb_reuse_mamba_board_shell_stream tx_idx=%0d rx_frame=%0d rx_row=%0d total=%0d tlast=%0d busy=%b",
             $time, tx_idx, rx_frame, rx_row, rx_total_beats, rx_tlast_count, frame_busy);
  end

  reuse_mamba_board_shell_stream #(
    .TILE_SIZE(TILE_SIZE),
    .DATA_WIDTH(DATA_WIDTH),
    .LUT_FILE(LUT_PATH_CONST),
    .CHAIN4_ENABLE(1),
    .H_ROWS(H_DEPTH),
    .STAGE_DIR_B0(STAGE_B0_CONST),
    .STAGE_DIR_B1(STAGE_B1_CONST),
    .STAGE_DIR_B2(STAGE_B2_CONST),
    .STAGE_DIR_B3(STAGE_B3_CONST)
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
