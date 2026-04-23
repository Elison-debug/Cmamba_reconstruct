`timescale 1ns/1ps

`ifndef HW_DEBUG_CASE_DIR
  `define HW_DEBUG_CASE_DIR "E:/course/smamba/final_hw/cases/c03"
`endif

module tb_reuse_mamba_board_shell_stream;
  localparam int TILE_SIZE  = 4;
  localparam int DATA_WIDTH = 16;
  localparam int H_DEPTH    = 32;
  localparam int Y_DEPTH    = 32;
  localparam int N_FRAMES   = 8;
  localparam int FILE_FRAMES = 8;
  localparam int FRAME_BASE = 0;
  localparam string CASE_DIR = `HW_DEBUG_CASE_DIR;
  localparam string STAGE_B0_CONST = {CASE_DIR, "/stages/reuse_mamba_block_top_block0"};
  localparam string STAGE_B1_CONST = {CASE_DIR, "/stages/reuse_mamba_block_top_block1"};
  localparam string STAGE_B2_CONST = {CASE_DIR, "/stages/reuse_mamba_block_top_block2"};
  localparam string STAGE_B3_CONST = {CASE_DIR, "/stages/reuse_mamba_block_top_block3"};
  localparam string LUT_PATH_CONST = "E:/course/smamba/user/data/sigmoid_lut_q016_2048.hex";
  localparam bit REPEAT_FRAME0_ONLY = 1'b0;
  localparam bit CHECK_INTERNAL_SIGNALS = 1'b1;

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
  logic [63:0] h_stream_input_mem [0:(FILE_FRAMES*H_DEPTH)-1];
  logic [63:0] b1_h_stream_golden_mem [0:(FILE_FRAMES*H_DEPTH)-1];
  logic [63:0] b2_h_stream_golden_mem [0:(FILE_FRAMES*H_DEPTH)-1];
  logic [63:0] b3_h_stream_golden_mem [0:(FILE_FRAMES*H_DEPTH)-1];
  logic [63:0] y_stream_golden_mem  [0:(FILE_FRAMES*Y_DEPTH)-1];
  logic [63:0] b0_h_norm_golden_mem [0:(FILE_FRAMES*H_DEPTH)-1];
  logic [63:0] b0_u_golden_mem      [0:(FILE_FRAMES*64)-1];
  logic [63:0] b0_z_golden_mem      [0:(FILE_FRAMES*64)-1];
  logic [63:0] b0_zsilu_golden_mem  [0:(FILE_FRAMES*64)-1];
  logic [63:0] b0_dt_golden_mem     [0:(FILE_FRAMES*64)-1];
  logic [63:0] b0_ssm_golden_mem    [0:(FILE_FRAMES*64)-1];
  logic [63:0] b0_gate_golden_mem   [0:(FILE_FRAMES*64)-1];
  logic [63:0] b0_y_golden_mem [0:Y_DEPTH-1];
  logic [63:0] b1_y_golden_mem [0:Y_DEPTH-1];
  logic [63:0] b2_y_golden_mem [0:Y_DEPTH-1];
  logic [63:0] b3_y_golden_mem [0:Y_DEPTH-1];

  int tx_idx;
  int rx_frame;
  int rx_row;
  int rx_total_beats;
  int rx_tlast_count;
  int mismatch_cnt;
  int load_id;
  int load_beat_cnt;
  int blk_frame_idx [0:3];
  int blk_row_idx [0:3];
  int blk_mismatch_total [0:3];
  int blk_frame_mismatch [0:3][0:FILE_FRAMES-1];
  int b0_stage_frame;
  int b0_hnorm_row;
  int b0_u_row;
  int b0_z_row;
  int b0_zsilu_row;
  int b0_dt_row;
  int b0_ssm_row;
  int b0_gate_row;
  int b0_hnorm_mis;
  int b0_u_mis;
  int b0_z_mis;
  int b0_zsilu_mis;
  int b0_dt_mis;
  int b0_ssm_mis;
  int b0_gate_mis;
  int b0_hin_mis;
  int b0_hin_writes;
  int b1_hin_mis;
  int b1_hin_writes;
  int b2_hin_mis;
  int b2_hin_writes;
  int b3_hin_mis;
  int b3_hin_writes;
  bit b0_hnorm_first;
  bit b0_u_first;
  bit b0_z_first;
  bit b0_zsilu_first;
  bit b0_dt_first;
  bit b0_ssm_first;
  bit b0_gate_first;
  bit b0_hin_first;
  bit b3_state_clear_busy_d;
  logic [63:0] blk_last_row0 [0:3];
  logic        blk_last_row0_valid [0:3];
  logic        blk_fire [0:3];
  logic [63:0] blk_out_packed [0:3];

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

  function automatic logic [63:0] blk_golden_word(input int blk, input int row);
    begin
      case (blk)
        0: blk_golden_word = b0_y_golden_mem[row];
        1: blk_golden_word = b1_y_golden_mem[row];
        2: blk_golden_word = b2_y_golden_mem[row];
        default: blk_golden_word = b3_y_golden_mem[row];
      endcase
    end
  endfunction

  function automatic int frame_row_idx(input int frame_idx, input int row_idx, input int rows_per_frame);
    begin
      if (REPEAT_FRAME0_ONLY || (frame_idx < 0)) begin
        frame_row_idx = row_idx;
      end else begin
        frame_row_idx = frame_idx * rows_per_frame + row_idx;
      end
    end
  endfunction

  task automatic load_case();
    string stage_b0;
    string stage_b1;
    string stage_b2;
    string stage_b3;
    begin
      stage_b0 = {CASE_DIR, "/stages/reuse_mamba_block_top_block0"};
      stage_b1 = {CASE_DIR, "/stages/reuse_mamba_block_top_block1"};
      stage_b2 = {CASE_DIR, "/stages/reuse_mamba_block_top_block2"};
      stage_b3 = {CASE_DIR, "/stages/reuse_mamba_block_top_block3"};
      $readmemh({stage_b0, "/h_wr_data_s16_q8p8.mem"}, h_wr_data_mem);
      $readmemh({CASE_DIR, "/stages/reuse_mamba_block_top_chain4/stream_h_input_stateless_q88.mem"}, h_stream_input_mem);
      $readmemh({CASE_DIR, "/stages/reuse_mamba_block_top_chain4/stream_block1_h_in_stateless_q88.mem"}, b1_h_stream_golden_mem);
      $readmemh({CASE_DIR, "/stages/reuse_mamba_block_top_chain4/stream_block2_h_in_stateless_q88.mem"}, b2_h_stream_golden_mem);
      $readmemh({CASE_DIR, "/stages/reuse_mamba_block_top_chain4/stream_block3_h_in_stateless_q88.mem"}, b3_h_stream_golden_mem);
      $readmemh({CASE_DIR, "/stages/reuse_mamba_block_top_chain4/stream_block0_h_norm_stateless_q88.mem"}, b0_h_norm_golden_mem);
      $readmemh({CASE_DIR, "/stages/reuse_mamba_block_top_chain4/stream_block0_u_stateless_q88.mem"}, b0_u_golden_mem);
      $readmemh({CASE_DIR, "/stages/reuse_mamba_block_top_chain4/stream_block0_z_stateless_q88.mem"}, b0_z_golden_mem);
      $readmemh({CASE_DIR, "/stages/reuse_mamba_block_top_chain4/stream_block0_z_silu_stateless_q88.mem"}, b0_zsilu_golden_mem);
      $readmemh({CASE_DIR, "/stages/reuse_mamba_block_top_chain4/stream_block0_dt_stateless_q88.mem"}, b0_dt_golden_mem);
      $readmemh({CASE_DIR, "/stages/reuse_mamba_block_top_chain4/stream_block0_ssm_stateless_q88.mem"}, b0_ssm_golden_mem);
      $readmemh({CASE_DIR, "/stages/reuse_mamba_block_top_chain4/stream_block0_gate_y_stateless_q88.mem"}, b0_gate_golden_mem);
      $readmemh({stage_b0, "/y_golden_q88.mem"}, b0_y_golden_mem);
      $readmemh({stage_b1, "/y_golden_q88.mem"}, b1_y_golden_mem);
      $readmemh({stage_b2, "/y_golden_q88.mem"}, b2_y_golden_mem);
      $readmemh({stage_b3, "/y_golden_q88.mem"}, b3_y_golden_mem);
      $readmemh({CASE_DIR, "/stages/reuse_mamba_block_top_chain4/stream_y_golden_stateless_q88.mem"}, y_stream_golden_mem);
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
    load_id = -1;
    load_beat_cnt = 0;
    b0_stage_frame = -1;
    b0_hnorm_row = 0;
    b0_u_row = 0;
    b0_z_row = 0;
    b0_zsilu_row = 0;
    b0_dt_row = 0;
    b0_ssm_row = 0;
    b0_gate_row = 0;
    b0_hnorm_mis = 0;
    b0_u_mis = 0;
    b0_z_mis = 0;
    b0_zsilu_mis = 0;
    b0_dt_mis = 0;
    b0_ssm_mis = 0;
    b0_gate_mis = 0;
    b0_hin_mis = 0;
    b0_hin_writes = 0;
    b1_hin_mis = 0;
    b1_hin_writes = 0;
    b2_hin_mis = 0;
    b2_hin_writes = 0;
    b3_hin_mis = 0;
    b3_hin_writes = 0;
    b0_hnorm_first = 1'b0;
    b0_u_first = 1'b0;
    b0_z_first = 1'b0;
    b0_zsilu_first = 1'b0;
    b0_dt_first = 1'b0;
    b0_ssm_first = 1'b0;
    b0_gate_first = 1'b0;
    b0_hin_first = 1'b0;
    b3_state_clear_busy_d = 1'b0;
    for (int b = 0; b < 4; b++) begin
      blk_frame_idx[b] = -1;
      blk_row_idx[b] = 0;
      blk_mismatch_total[b] = 0;
      blk_last_row0[b] = '0;
      blk_last_row0_valid[b] = 1'b0;
      for (int f = 0; f < FILE_FRAMES; f++) begin
        blk_frame_mismatch[b][f] = 0;
      end
    end
    if (!REPEAT_FRAME0_ONLY && ((FRAME_BASE < 0) || ((FRAME_BASE + N_FRAMES) > FILE_FRAMES))) begin
      $fatal(1, "[%0t] invalid frame window FRAME_BASE=%0d N_FRAMES=%0d FILE_FRAMES=%0d",
             $time, FRAME_BASE, N_FRAMES, FILE_FRAMES);
    end
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
      s_axis_h_tdata  <= REPEAT_FRAME0_ONLY
                         ? h_stream_input_mem[tx_idx % H_DEPTH]
                         : h_stream_input_mem[frame_row_idx(FRAME_BASE + (tx_idx / H_DEPTH), tx_idx % H_DEPTH, H_DEPTH)];
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

  always_comb begin
    for (int b = 0; b < 4; b++) begin
      blk_fire[b] = dut.u_core.u_core.blk_y_valid[b] && dut.u_core.u_core.blk_y_ready[b];
      blk_out_packed[b] = pack_vec4(dut.u_core.u_core.blk_y_data[b]);
    end
  end

  initial begin : check_block_outputs
    wait(rst_n);
    if (!CHECK_INTERNAL_SIGNALS) begin
      forever @(posedge clk);
    end
    forever begin
      @(posedge clk);
      if (dut.u_core.u_core.blk_start_pulse[0]) begin
        b0_stage_frame = b0_stage_frame + 1;
        b0_hnorm_row = 0;
        b0_u_row = 0;
        b0_z_row = 0;
        b0_zsilu_row = 0;
        b0_dt_row = 0;
        b0_ssm_row = 0;
        b0_gate_row = 0;
      end

      // block0 raw input write check into RMSNorm raw-h SRAM
      if (dut.u_core.u_core.u_blk0.h_wr_en) begin
        int ridx;
        logic [63:0] got_w;
        logic [63:0] exp_w;
        ridx = dut.u_core.u_core.u_blk0.h_wr_addr;
        got_w = pack_vec4(dut.u_core.u_core.u_blk0.h_wr_data);
        if ((b0_hin_writes >= 0) && (b0_hin_writes < (N_FRAMES*H_DEPTH))) begin
          exp_w = REPEAT_FRAME0_ONLY
                  ? h_stream_input_mem[b0_hin_writes % H_DEPTH]
                  : h_stream_input_mem[frame_row_idx(FRAME_BASE + (b0_hin_writes / H_DEPTH), b0_hin_writes % H_DEPTH, H_DEPTH)];
        end else begin
          exp_w = h_wr_data_mem[ridx];
        end
        if (b0_hin_writes < 40) begin
          $display("[%0t] B0-HIN wr_count=%0d row=%0d got=%h exp=%h",
                   $time, b0_hin_writes, ridx, got_w, exp_w);
        end
        if (lane_diff_gt_1(got_w, exp_w)) begin
          b0_hin_mis = b0_hin_mis + 1;
          if (!b0_hin_first) begin
            $display("[%0t] B0-HIN first mismatch wr_count=%0d row=%0d got=%h exp=%h",
                     $time, b0_hin_writes, ridx, got_w, exp_w);
            b0_hin_first = 1'b1;
          end
        end
        b0_hin_writes = b0_hin_writes + 1;
      end

      if (dut.u_core.u_core.u_blk3.h_wr_en) begin
        int ridx3;
        logic [63:0] got3;
        logic [63:0] exp3;
        ridx3 = dut.u_core.u_core.u_blk3.h_wr_addr;
        got3 = pack_vec4(dut.u_core.u_core.u_blk3.h_wr_data);
        if ((b3_hin_writes >= 0) && (b3_hin_writes < (N_FRAMES*H_DEPTH))) begin
          exp3 = REPEAT_FRAME0_ONLY
                 ? b3_h_stream_golden_mem[b3_hin_writes % H_DEPTH]
                 : b3_h_stream_golden_mem[frame_row_idx(FRAME_BASE + (b3_hin_writes / H_DEPTH), b3_hin_writes % H_DEPTH, H_DEPTH)];
        end else begin
          exp3 = '0;
        end
        if (lane_diff_gt_1(got3, exp3)) begin
          b3_hin_mis = b3_hin_mis + 1;
          if (b3_hin_mis <= 8) begin
            $display("[%0t] B3-HIN mismatch wr_count=%0d row=%0d got=%h exp=%h",
                     $time, b3_hin_writes, ridx3, got3, exp3);
          end
        end
        b3_hin_writes = b3_hin_writes + 1;
      end

      if (dut.u_core.u_core.u_blk1.h_wr_en) begin
        int ridx1;
        logic [63:0] got1;
        logic [63:0] exp1;
        ridx1 = dut.u_core.u_core.u_blk1.h_wr_addr;
        got1 = pack_vec4(dut.u_core.u_core.u_blk1.h_wr_data);
        exp1 = ((b1_hin_writes >= 0) && (b1_hin_writes < (N_FRAMES*H_DEPTH)))
               ? (REPEAT_FRAME0_ONLY
                  ? b1_h_stream_golden_mem[b1_hin_writes % H_DEPTH]
                  : b1_h_stream_golden_mem[frame_row_idx(FRAME_BASE + (b1_hin_writes / H_DEPTH), b1_hin_writes % H_DEPTH, H_DEPTH)])
               : '0;
        if (lane_diff_gt_1(got1, exp1)) begin
          b1_hin_mis = b1_hin_mis + 1;
          if (b1_hin_mis <= 8) begin
            $display("[%0t] B1-HIN mismatch wr_count=%0d row=%0d got=%h exp=%h",
                     $time, b1_hin_writes, ridx1, got1, exp1);
          end
        end
        b1_hin_writes = b1_hin_writes + 1;
      end

      if (dut.u_core.u_core.u_blk2.h_wr_en) begin
        int ridx2;
        logic [63:0] got2;
        logic [63:0] exp2;
        ridx2 = dut.u_core.u_core.u_blk2.h_wr_addr;
        got2 = pack_vec4(dut.u_core.u_core.u_blk2.h_wr_data);
        exp2 = ((b2_hin_writes >= 0) && (b2_hin_writes < (N_FRAMES*H_DEPTH)))
               ? (REPEAT_FRAME0_ONLY
                  ? b2_h_stream_golden_mem[b2_hin_writes % H_DEPTH]
                  : b2_h_stream_golden_mem[frame_row_idx(FRAME_BASE + (b2_hin_writes / H_DEPTH), b2_hin_writes % H_DEPTH, H_DEPTH)])
               : '0;
        if (lane_diff_gt_1(got2, exp2)) begin
          b2_hin_mis = b2_hin_mis + 1;
          if (b2_hin_mis <= 8) begin
            $display("[%0t] B2-HIN mismatch wr_count=%0d row=%0d got=%h exp=%h",
                     $time, b2_hin_writes, ridx2, got2, exp2);
          end
        end
        b2_hin_writes = b2_hin_writes + 1;
      end

      // Block3 state clear observability (stateless mode should clear every frame start).
      if (!b3_state_clear_busy_d && dut.u_core.u_core.u_blk3.u_ssm_core.state_clear_busy) begin
        $display("[%0t] B3-STATE clear start", $time);
      end
      if (dut.u_core.u_core.u_blk3.u_ssm_core.state_clear_done) begin
        $display("[%0t] B3-STATE clear done", $time);
      end
      b3_state_clear_busy_d <= dut.u_core.u_core.u_blk3.u_ssm_core.state_clear_busy;

      // block0: RMSNorm output (final ST_NORM writes only)
      if (dut.u_core.u_core.u_blk0.norm_wr_en &&
          (dut.u_core.u_core.u_blk0.g_rmsnorm.u_rmsnorm.state == 3'd5)) begin
        int ridx;
        logic [63:0] got_w;
        logic [63:0] exp_w;
        ridx = dut.u_core.u_core.u_blk0.norm_wr_addr;
        got_w = pack_vec4(dut.u_core.u_core.u_blk0.norm_wr_data);
        exp_w = b0_h_norm_golden_mem[frame_row_idx(FRAME_BASE + b0_stage_frame, ridx, H_DEPTH)];
        if (lane_diff_gt_1(got_w, exp_w)) begin
          b0_hnorm_mis = b0_hnorm_mis + 1;
          if (!b0_hnorm_first) begin
            $display("[%0t] B0-HNORM first mismatch frame=%0d row=%0d got=%h exp=%h",
                     $time, b0_stage_frame, ridx, got_w, exp_w);
            b0_hnorm_first = 1'b1;
          end
        end
        b0_hnorm_row = b0_hnorm_row + 1;
      end

      // block0: u stream (pre-silu)
      if (dut.u_core.u_core.u_blk0.u_stream_valid && dut.u_core.u_core.u_blk0.u_stream_ready) begin
        logic [63:0] got_w;
        logic [63:0] exp_w;
        got_w = pack_vec4(dut.u_core.u_core.u_blk0.u_stream_vec);
        exp_w = b0_u_golden_mem[frame_row_idx(FRAME_BASE + b0_stage_frame, b0_u_row, 64)];
        if (lane_diff_gt_1(got_w, exp_w)) begin
          b0_u_mis = b0_u_mis + 1;
          if (!b0_u_first) begin
            $display("[%0t] B0-U first mismatch frame=%0d row=%0d got=%h exp=%h",
                     $time, b0_stage_frame, b0_u_row, got_w, exp_w);
            b0_u_first = 1'b1;
          end
        end
        b0_u_row = (b0_u_row == 63) ? 0 : (b0_u_row + 1);
      end

      // block0: z stream (pre-silu)
      if (dut.u_core.u_core.u_blk0.z_stream_valid && dut.u_core.u_core.u_blk0.z_stream_ready) begin
        logic [63:0] got_w;
        logic [63:0] exp_w;
        got_w = pack_vec4(dut.u_core.u_core.u_blk0.z_stream_vec);
        exp_w = b0_z_golden_mem[frame_row_idx(FRAME_BASE + b0_stage_frame, b0_z_row, 64)];
        if (lane_diff_gt_1(got_w, exp_w)) begin
          b0_z_mis = b0_z_mis + 1;
          if (!b0_z_first) begin
            $display("[%0t] B0-Z first mismatch frame=%0d row=%0d got=%h exp=%h",
                     $time, b0_stage_frame, b0_z_row, got_w, exp_w);
            b0_z_first = 1'b1;
          end
        end
        b0_z_row = (b0_z_row == 63) ? 0 : (b0_z_row + 1);
      end

      // block0: z silu stream
      if (dut.u_core.u_core.u_blk0.silu_valid && dut.u_core.u_core.u_blk0.silu_ready) begin
        logic [63:0] got_w;
        logic [63:0] exp_w;
        got_w = pack_vec4(dut.u_core.u_core.u_blk0.silu_vec);
        exp_w = b0_zsilu_golden_mem[frame_row_idx(FRAME_BASE + b0_stage_frame, b0_zsilu_row, 64)];
        if (lane_diff_gt_1(got_w, exp_w)) begin
          b0_zsilu_mis = b0_zsilu_mis + 1;
          if (!b0_zsilu_first) begin
            $display("[%0t] B0-ZSILU first mismatch frame=%0d row=%0d got=%h exp=%h",
                     $time, b0_stage_frame, b0_zsilu_row, got_w, exp_w);
            b0_zsilu_first = 1'b1;
          end
        end
        b0_zsilu_row = (b0_zsilu_row == 63) ? 0 : (b0_zsilu_row + 1);
      end

      // block0: dt stream to ssm_core (pre-bias dt_mac)
      if (dut.u_core.u_core.u_blk0.dt_mac_valid) begin
        logic [63:0] got_w;
        logic [63:0] exp_w;
        got_w = pack_vec4(dut.u_core.u_core.u_blk0.dt_mac_vec);
        exp_w = b0_dt_golden_mem[frame_row_idx(FRAME_BASE + b0_stage_frame, b0_dt_row, 64)];
        if (lane_diff_gt_1(got_w, exp_w)) begin
          b0_dt_mis = b0_dt_mis + 1;
          if (!b0_dt_first) begin
            $display("[%0t] B0-DT first mismatch frame=%0d row=%0d got=%h exp=%h",
                     $time, b0_stage_frame, b0_dt_row, got_w, exp_w);
            b0_dt_first = 1'b1;
          end
        end
        b0_dt_row = (b0_dt_row == 63) ? 0 : (b0_dt_row + 1);
      end

      // block0: ssm output before gate (u_ssm_core.s_out_vec)
      if (dut.u_core.u_core.u_blk0.u_ssm_core.s_out_valid &&
          dut.u_core.u_core.u_blk0.u_ssm_core.s_out_ready) begin
        logic [63:0] got_w;
        logic [63:0] exp_w;
        got_w = pack_vec4(dut.u_core.u_core.u_blk0.u_ssm_core.s_out_vec);
        exp_w = b0_ssm_golden_mem[frame_row_idx(FRAME_BASE + b0_stage_frame, b0_ssm_row, 64)];
        if (lane_diff_gt_1(got_w, exp_w)) begin
          b0_ssm_mis = b0_ssm_mis + 1;
          if (!b0_ssm_first) begin
            $display("[%0t] B0-SSM first mismatch frame=%0d row=%0d got=%h exp=%h",
                     $time, b0_stage_frame, b0_ssm_row, got_w, exp_w);
            b0_ssm_first = 1'b1;
          end
        end
        b0_ssm_row = (b0_ssm_row == 63) ? 0 : (b0_ssm_row + 1);
      end

      // block0: gate_y stream (u_ssm_core output)
      if (dut.u_core.u_core.u_blk0.ssm_p_valid && dut.u_core.u_core.u_blk0.ssm_p_ready) begin
        logic [63:0] got_w;
        logic [63:0] exp_w;
        got_w = pack_vec4(dut.u_core.u_core.u_blk0.ssm_p_data);
        exp_w = b0_gate_golden_mem[frame_row_idx(FRAME_BASE + b0_stage_frame, b0_gate_row, 64)];
        if (lane_diff_gt_1(got_w, exp_w)) begin
          b0_gate_mis = b0_gate_mis + 1;
          if (!b0_gate_first) begin
            $display("[%0t] B0-GATE first mismatch frame=%0d row=%0d got=%h exp=%h",
                     $time, b0_stage_frame, b0_gate_row, got_w, exp_w);
            b0_gate_first = 1'b1;
          end
        end
        b0_gate_row = (b0_gate_row == 63) ? 0 : (b0_gate_row + 1);
      end

      for (int b = 0; b < 4; b++) begin
        if (dut.u_core.u_core.blk_start_pulse[b]) begin
          blk_frame_idx[b] = blk_frame_idx[b] + 1;
          blk_row_idx[b] = 0;
          $display("[%0t] BLK%0d start frame=%0d", $time, b, blk_frame_idx[b]);
        end
        if (blk_fire[b]) begin
          int fidx;
          int ridx;
          logic [63:0] exp_w;
          fidx = blk_frame_idx[b];
          ridx = blk_row_idx[b];
          exp_w = blk_golden_word(b, ridx);
          if (lane_diff_gt_1(blk_out_packed[b], exp_w)) begin
            blk_mismatch_total[b] = blk_mismatch_total[b] + 1;
            if (fidx >= 0 && fidx < FILE_FRAMES) begin
              blk_frame_mismatch[b][fidx] = blk_frame_mismatch[b][fidx] + 1;
            end
            if (blk_frame_mismatch[b][fidx] <= 4) begin
              $display("[%0t] BLK%0d mismatch frame=%0d row=%0d got=%h exp=%h",
                       $time, b, fidx, ridx, blk_out_packed[b], exp_w);
            end
          end
          if (ridx == 0) begin
            if (blk_last_row0_valid[b] && (blk_out_packed[b] !== blk_last_row0[b])) begin
              $display("[%0t] BLK%0d row0 changed vs prev frame: prev=%h now=%h",
                       $time, b, blk_last_row0[b], blk_out_packed[b]);
            end
            blk_last_row0[b] = blk_out_packed[b];
            blk_last_row0_valid[b] = 1'b1;
          end
          if (ridx == (Y_DEPTH - 1)) begin
            $display("[%0t] BLK%0d frame=%0d done mismatches=%0d",
                     $time, b, fidx, (fidx >= 0 && fidx < FILE_FRAMES) ? blk_frame_mismatch[b][fidx] : -1);
            blk_row_idx[b] = 0;
          end else begin
            blk_row_idx[b] = ridx + 1;
          end
        end
      end
    end
  end

  // Shell loader integrity: each preload session must write exactly one full H frame.
  initial begin : check_loader_preload
    wait(rst_n);
    forever begin
      @(posedge clk);
      if (dut.preload_h_start_pulse) begin
        load_id = load_id + 1;
        load_beat_cnt = 0;
      end
      if (dut.h_wr_en) begin
        load_beat_cnt = load_beat_cnt + 1;
      end
      if (dut.preload_h_done) begin
        $display("[%0t] LOADER done load_id=%0d beats=%0d", $time, load_id, load_beat_cnt);
        if (load_beat_cnt != H_DEPTH) begin
          $fatal(1, "[%0t] LOADER beat-count mismatch load_id=%0d beats=%0d exp=%0d",
                 $time, load_id, load_beat_cnt, H_DEPTH);
        end
      end
    end
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

        if ($isunknown(REPEAT_FRAME0_ONLY
                       ? y_stream_golden_mem[rx_row]
                       : y_stream_golden_mem[frame_row_idx(FRAME_BASE + rx_frame, rx_row, Y_DEPTH)])) begin
          $fatal(1, "[%0t] expected stream golden is X/Z at beat=%0d (check CASE_DIR and mem file)",
                 $time, rx_total_beats);
        end
        if (lane_diff_gt_1(m_axis_y_tdata,
                           REPEAT_FRAME0_ONLY
                           ? y_stream_golden_mem[rx_row]
                           : y_stream_golden_mem[frame_row_idx(FRAME_BASE + rx_frame, rx_row, Y_DEPTH)])) begin
          mismatch_cnt++;
          if (mismatch_cnt <= 8) begin
            $display("[%0t] stream golden mismatch beat=%0d frame=%0d row=%0d got=%h exp=%h",
                     $time, rx_total_beats, rx_frame, rx_row, m_axis_y_tdata,
                     (REPEAT_FRAME0_ONLY
                      ? y_stream_golden_mem[rx_row]
                      : y_stream_golden_mem[frame_row_idx(FRAME_BASE + rx_frame, rx_row, Y_DEPTH)]));
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
    for (int b = 0; b < 4; b++) begin
      $display("[%0t] BLK%0d total mismatch=%0d", $time, b, blk_mismatch_total[b]);
      for (int f = 0; f < N_FRAMES; f++) begin
        $display("[%0t] BLK%0d frame=%0d mismatch=%0d", $time, b, f, blk_frame_mismatch[b][f]);
      end
    end
    $display("[%0t] B0-STAGE mismatch summary: hin=%0d hnorm=%0d u=%0d z=%0d z_silu=%0d dt=%0d ssm=%0d gate=%0d",
             $time, b0_hin_mis, b0_hnorm_mis, b0_u_mis, b0_z_mis, b0_zsilu_mis, b0_dt_mis, b0_ssm_mis, b0_gate_mis);
    $display("[%0t] B1-HIN mismatch summary: hin=%0d writes=%0d", $time, b1_hin_mis, b1_hin_writes);
    $display("[%0t] B2-HIN mismatch summary: hin=%0d writes=%0d", $time, b2_hin_mis, b2_hin_writes);
    $display("[%0t] B3-HIN mismatch summary: hin=%0d writes=%0d", $time, b3_hin_mis, b3_hin_writes);
    if (mismatch_cnt != 0) begin
      $fatal(1, "[%0t] stream multi-frame mismatch count=%0d", $time, mismatch_cnt);
    end
    $display("[%0t] PASS stream shell multi-frame check (%0d frames)", $time, N_FRAMES);
    #100;
    $finish;
  end

  initial begin : timeout_guard
    #8000000;
    $fatal(1, "[%0t] timeout in tb_reuse_mamba_board_shell_stream tx_idx=%0d rx_frame=%0d rx_row=%0d total=%0d tlast=%0d busy=%b",
             $time, tx_idx, rx_frame, rx_row, rx_total_beats, rx_tlast_count, frame_busy);
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

  // Force stage-dir source to current CASE_DIR for adapter-internal ROM init.
  defparam dut.u_core.STAGE_DIR_B0 = STAGE_B0_CONST;
  defparam dut.u_core.STAGE_DIR_B1 = STAGE_B1_CONST;
  defparam dut.u_core.STAGE_DIR_B2 = STAGE_B2_CONST;
  defparam dut.u_core.STAGE_DIR_B3 = STAGE_B3_CONST;
endmodule

