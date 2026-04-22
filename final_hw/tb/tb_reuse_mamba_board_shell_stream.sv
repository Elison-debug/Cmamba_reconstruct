`timescale 1ns/1ps

`ifndef HW_DEBUG_CASE_DIR
  `define HW_DEBUG_CASE_DIR "E:/course/smamba/final_hw/cases/c02"
`endif

module tb_reuse_mamba_board_shell_stream;
  localparam int TILE_SIZE  = 4;
  localparam int DATA_WIDTH = 16;
  localparam int H_DEPTH    = 32;
  localparam int Y_DEPTH    = 32;
  localparam int N_FRAMES   = 3;
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
  logic [63:0] y_stream_golden_mem  [0:(N_FRAMES*Y_DEPTH)-1];

  int tx_idx;
  int rx_frame;
  int rx_row;
  int rx_total_beats;
  int rx_tlast_count;
  int mismatch_cnt;

  function automatic logic signed [DATA_WIDTH-1:0] unpack_lane64(input logic [63:0] packed_word, input int lane);
    unpack_lane64 = $signed(packed_word[lane*DATA_WIDTH +: DATA_WIDTH]);
  endfunction

  function automatic bit lane_diff_gt_1(input logic [63:0] got_w, input logic [63:0] exp_w);
    int lane;
    logic signed [DATA_WIDTH-1:0] g;
    logic signed [DATA_WIDTH-1:0] e;
    int d;
    begin
      lane_diff_gt_1 = 1'b0;
      for (lane = 0; lane < TILE_SIZE; lane++) begin
        g = unpack_lane64(got_w, lane);
        e = unpack_lane64(exp_w, lane);
        d = g - e;
        if (d < 0) d = -d;
        if (d > 1) begin
          lane_diff_gt_1 = 1'b1;
        end
      end
    end
  endfunction

  function automatic logic [63:0] pack_vec4(input logic signed [DATA_WIDTH-1:0] vec [TILE_SIZE-1:0]);
    logic [63:0] tmp;
    begin
      tmp = '0;
      for (int i = 0; i < TILE_SIZE; i++) begin
        tmp[i*DATA_WIDTH +: DATA_WIDTH] = vec[i];
      end
      pack_vec4 = tmp;
    end
  endfunction

  task automatic load_case();
    string stage_b0;
    begin
      stage_b0 = {CASE_DIR, "/stages/reuse_mamba_block_top_block0"};
      $readmemh({stage_b0, "/h_wr_data_s16_q8p8.mem"}, h_wr_data_mem);
      $readmemh({CASE_DIR, "/stages/reuse_mamba_block_top_chain4/stream_y_golden_q88.mem"}, y_stream_golden_mem);
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
    repeat (8) @(posedge clk);
    while (tx_idx < total_beats) begin
      s_axis_h_tvalid <= 1'b1;
      s_axis_h_tdata  <= h_wr_data_mem[tx_idx % H_DEPTH];
      s_axis_h_tlast  <= ((tx_idx % H_DEPTH) == (H_DEPTH - 1));
      do @(posedge clk); while (!(s_axis_h_tvalid && s_axis_h_tready));
      tx_idx <= tx_idx + 1;
    end
    @(posedge clk);
    s_axis_h_tvalid <= 1'b0;
    s_axis_h_tdata  <= '0;
    s_axis_h_tlast  <= 1'b0;
    $display("[%0t] INFO push_h_stream done tx_idx=%0d", $time, tx_idx);
  end

  // Strict checker:
  // 1) Never allow X/Z on output handshake/data/last.
  // 2) Compare every beat against continuous-state golden stream.
  // 3) TLAST must align to frame boundaries.
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

        if ($isunknown(y_stream_golden_mem[rx_total_beats])) begin
          $fatal(1, "[%0t] expected stream golden is X/Z at beat=%0d (check CASE_DIR and mem file)",
                 $time, rx_total_beats);
        end
        if (lane_diff_gt_1(m_axis_y_tdata, y_stream_golden_mem[rx_total_beats])) begin
          mismatch_cnt++;
          if (mismatch_cnt <= 8) begin
            $display("[%0t] stream golden mismatch beat=%0d frame=%0d row=%0d got=%h exp=%h",
                     $time, rx_total_beats, rx_frame, rx_row, m_axis_y_tdata, y_stream_golden_mem[rx_total_beats]);
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

  // Block3 stage probes around the first divergence frame.
  // Frame index is 0-based; beat=64 belongs to frame index 2.
  localparam int DBG_FRAME = 2;
  localparam int DBG_ROWS  = 8;
  localparam int DBG_TOKS  = 16;
  int dbg_blk3_frame;
  int dbg_norm_idx;
  int dbg_uact_idx;
  int dbg_dt_idx;
  int dbg_ssm_idx;
  int dbg_out_idx;
  int dbg_hin_idx;
  int dbg_state_idx;
  logic [63:0] dbg_hin_packed;
  logic [63:0] dbg_norm_packed;
  logic [63:0] dbg_uact_packed;
  logic [63:0] dbg_dt_packed;
  logic [63:0] dbg_ssm_packed;
  logic [63:0] dbg_out_packed;
  logic [63:0] dbg_state_packed;
  logic        dbg_out_fire;

  always_comb begin
    dbg_norm_packed = pack_vec4(dut.u_core.u_core.u_blk3.norm_wr_data);
    dbg_uact_packed = pack_vec4(dut.u_core.u_core.u_blk3.uact_wr_data);
    dbg_dt_packed   = pack_vec4(dut.u_core.u_core.u_blk3.dt_mac_vec);
    dbg_ssm_packed  = pack_vec4(dut.u_core.u_core.u_blk3.ssm_p_data);
    dbg_out_packed  = pack_vec4(dut.u_core.u_core.blk_y_data[3]);
    dbg_hin_packed  = pack_vec4(dut.u_core.u_core.blk_h_wr_data[3]);
    dbg_state_packed = dut.u_core.u_core.u_blk3.u_ssm_core.u_ew.s_new_packed;
  end

  assign dbg_out_fire = dut.u_core.u_core.blk_y_valid[3] && dut.u_core.u_core.blk_y_ready[3];

  initial begin : block3_stage_probe
    dbg_blk3_frame = -1;
    dbg_norm_idx = 0;
    dbg_uact_idx = 0;
    dbg_dt_idx = 0;
    dbg_ssm_idx = 0;
    dbg_out_idx = 0;
    dbg_hin_idx = 0;
    dbg_state_idx = 0;
    wait(rst_n);
    forever begin
      @(posedge clk);
      if (dut.u_core.u_core.blk_start_pulse[3]) begin
        dbg_blk3_frame = dbg_blk3_frame + 1;
        dbg_norm_idx = 0;
        dbg_uact_idx = 0;
        dbg_dt_idx = 0;
        dbg_ssm_idx = 0;
        dbg_out_idx = 0;
        dbg_hin_idx = 0;
        dbg_state_idx = 0;
        if (dbg_blk3_frame == DBG_FRAME) begin
          $display("[%0t] DBG block3 frame=%0d start", $time, dbg_blk3_frame);
        end
      end

      if (dbg_blk3_frame == DBG_FRAME) begin
        if (dut.u_core.u_core.u_blk3.norm_wr_en && (dbg_norm_idx < DBG_ROWS)) begin
          $display("[%0t] DBG3 rmsnorm idx=%0d addr=%0d data=%h",
                   $time, dbg_norm_idx, dut.u_core.u_core.u_blk3.norm_wr_addr, dbg_norm_packed);
          dbg_norm_idx = dbg_norm_idx + 1;
        end
        if (dut.u_core.u_core.blk_h_wr_en[3] && (dbg_hin_idx < DBG_ROWS)) begin
          $display("[%0t] DBG3 hin idx=%0d addr=%0d data=%h",
                   $time, dbg_hin_idx, dut.u_core.u_core.blk_h_wr_addr[3], dbg_hin_packed);
          dbg_hin_idx = dbg_hin_idx + 1;
        end
        if (dut.u_core.u_core.u_blk3.uact_wr_en && (dbg_uact_idx < DBG_TOKS)) begin
          $display("[%0t] DBG3 inproj_uact idx=%0d addr=%0d data=%h",
                   $time, dbg_uact_idx, dut.u_core.u_core.u_blk3.uact_wr_addr, dbg_uact_packed);
          dbg_uact_idx = dbg_uact_idx + 1;
        end
        if (dut.u_core.u_core.u_blk3.dt_mac_valid && dut.u_core.u_core.u_blk3.dt_mac_ready && (dbg_dt_idx < DBG_TOKS)) begin
          $display("[%0t] DBG3 dt idx=%0d saddr=%0d data=%h",
                   $time, dbg_dt_idx, dut.u_core.u_core.u_blk3.u_ssm_core.s_addr_cnt, dbg_dt_packed);
          dbg_dt_idx = dbg_dt_idx + 1;
        end
        if (dut.u_core.u_core.u_blk3.ssm_p_valid && dut.u_core.u_core.u_blk3.ssm_p_ready && (dbg_ssm_idx < DBG_TOKS)) begin
          $display("[%0t] DBG3 ssm idx=%0d saddr=%0d ew_last_wr_addr=%0d data=%h",
                   $time,
                   dbg_ssm_idx,
                   dut.u_core.u_core.u_blk3.u_ssm_core.s_addr_cnt,
                   dut.u_core.u_core.u_blk3.u_ssm_core.u_ew.last_wr_addr,
                   dbg_ssm_packed);
          dbg_ssm_idx = dbg_ssm_idx + 1;
        end
        if (dut.u_core.u_core.u_blk3.u_ssm_core.u_ew.state_we && (dbg_state_idx < DBG_TOKS)) begin
          $display("[%0t] DBG3 ew_state idx=%0d waddr=%0d data_q15=%h",
                   $time,
                   dbg_state_idx,
                   dut.u_core.u_core.u_blk3.u_ssm_core.u_ew.s_addr_w,
                   dbg_state_packed);
          dbg_state_idx = dbg_state_idx + 1;
        end
        if (dbg_out_fire && (dbg_out_idx < DBG_ROWS)) begin
          $display("[%0t] DBG3 outproj idx=%0d data=%h",
                   $time, dbg_out_idx, dbg_out_packed);
          dbg_out_idx = dbg_out_idx + 1;
        end
      end
    end
  end

  reuse_mamba_board_shell_stream #(
    .TILE_SIZE(TILE_SIZE),
    .DATA_WIDTH(DATA_WIDTH),
    .H_ROWS(H_DEPTH)
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

  // NOTE:
  // Keep stream TB path source aligned with stream_ps/post-synth flow by
  // using adapter defaults. Do not override internal params via defparam.
  // localparam string LUT_PATH_CONST/STAGE_B*_CONST are retained only for
  // quick manual bring-up if needed in a dedicated RTL-only debug branch.
endmodule
