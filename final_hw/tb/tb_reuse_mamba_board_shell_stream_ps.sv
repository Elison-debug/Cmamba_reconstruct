`timescale 1ns/1ps

`ifndef HW_DEBUG_CASE_DIR
  `define HW_DEBUG_CASE_DIR "E:/course/smamba/final_hw/cases/c01"
`endif

module tb_reuse_mamba_board_shell_stream_ps;
  localparam int TILE_SIZE   = 4;
  localparam int DATA_WIDTH  = 16;
  localparam int H_DEPTH     = 32;
  localparam int Y_DEPTH     = 32;
  localparam int N_FRAMES    = 3;
  localparam bit CHECK_FRAME0_GOLDEN = 1;
  localparam bit REQUIRE_REPEATABLE = 1;

  localparam string STAGE_B0_CONST = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top_block0"};

  logic clk;
  logic rst_n;

  logic                             s_axis_h_tvalid;
  logic                             s_axis_h_tready;
  logic [TILE_SIZE*DATA_WIDTH-1:0]  s_axis_h_tdata;
  logic                             s_axis_h_tlast;
  logic                             dut_s_axis_h_tvalid;
  logic                             dut_s_axis_h_tready;
  logic [TILE_SIZE*DATA_WIDTH-1:0]  dut_s_axis_h_tdata;
  logic                             dut_s_axis_h_tlast;
  logic [511:0]                     s_axis_h_tdata_512;
  logic [511:0]                     dut_s_axis_h_tdata_512;
  logic                             m_axis_y_tvalid;
  logic                             m_axis_y_tready;
  logic [TILE_SIZE*DATA_WIDTH-1:0]  m_axis_y_tdata;
  logic                             m_axis_y_tlast;
  logic                             dut_m_axis_y_tvalid;
  logic                             dut_m_axis_y_tready;
  logic [TILE_SIZE*DATA_WIDTH-1:0]  dut_m_axis_y_tdata;
  logic                             dut_m_axis_y_tlast;
  logic [511:0]                     dut_m_axis_y_tdata_512;
  logic [511:0]                     m_axis_y_tdata_512;
  logic                             frame_busy;

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

  task automatic load_case_files();
    begin
      $readmemh({STAGE_B0_CONST, "/h_wr_data_s16_q8p8.mem"}, h_wr_data_mem);
      $readmemh({`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top_chain4/final_y_golden_q88.mem"}, y_golden_mem);
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
    load_case_files();
    repeat (20) @(posedge clk);
    rst_n = 1'b1;
  end

  initial begin : push_h_stream
    int total_beats;
    total_beats = N_FRAMES * H_DEPTH;
    wait(rst_n);
    repeat (8) @(posedge clk);
    $display("[%0t] PS-STREAM-TB launch h stream", $time);
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
  end

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
    #6000000;
    $fatal(1, "[%0t] timeout in tb_reuse_mamba_board_shell_stream_ps tx_idx=%0d rx_frame=%0d rx_row=%0d total=%0d tlast=%0d busy=%b",
           $time, tx_idx, rx_frame, rx_row, rx_total_beats, rx_tlast_count, frame_busy);
  end

//  axis_register_slice_0 u_rs_h_in (
//    .aclk          (clk),
//    .aresetn       (rst_n),
//    .s_axis_tvalid (s_axis_h_tvalid),
//    .s_axis_tready (s_axis_h_tready),
//    .s_axis_tdata  (s_axis_h_tdata),
//    .s_axis_tlast  (s_axis_h_tlast),
//    .m_axis_tvalid (dut_s_axis_h_tvalid),
//    .m_axis_tready (dut_s_axis_h_tready),
//    .m_axis_tdata  (dut_s_axis_h_tdata),
//    .m_axis_tlast  (dut_s_axis_h_tlast)
//  );

//  axis_register_slice_0 u_rs_y_out (
//    .aclk          (clk),
//    .aresetn       (rst_n),
//    .s_axis_tvalid (dut_m_axis_y_tvalid),
//    .s_axis_tready (dut_m_axis_y_tready),
//    .s_axis_tdata  (dut_m_axis_y_tdata),
//    .s_axis_tlast  (dut_m_axis_y_tlast),
//    .m_axis_tvalid (m_axis_y_tvalid),
//    .m_axis_tready (m_axis_y_tready),
//    .m_axis_tdata  (m_axis_y_tdata),
//    .m_axis_tlast  (m_axis_y_tlast)
//  );

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
