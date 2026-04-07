`timescale 1ns/1ps

module tb_reuse_ssm_core_hw_debug;
  `include "tb_hw_debug_case_path.svh"

  `ifndef HW_DEBUG_CASE_DIR
    `define HW_DEBUG_CASE_DIR ""
  `endif

  localparam int TILE_SIZE   = 4;
  localparam int DATA_WIDTH  = 16;
  localparam int D           = 256;
  localparam int PIPE_LAT    = 4;
  localparam int ADDR_BITS   = 11;
  localparam string LUT_FILE = "sigmoid_lut_q016_2048.hex";
  localparam int S_ADDR_W    = 6;
  localparam int G_FRAC_BITS = 8;
  localparam int DEPTH       = 64;

  logic clk, rst_n;
  initial begin
    clk = 1'b0;
    forever #1 clk = ~clk;
  end
  initial begin
    rst_n = 1'b0;
    repeat (10) @(posedge clk);
    rst_n = 1'b1;
  end

  logic                         mac_m_valid;
  logic signed [DATA_WIDTH-1:0] mac_vec [TILE_SIZE-1:0];
  logic                         mac_m_ready;
  logic                         xt_v;
  logic                         xt_r_int;
  logic signed [DATA_WIDTH-1:0] xt_d [TILE_SIZE-1:0];
  logic                         g_axis_TVALID;
  logic                         g_axis_TREADY;
  logic signed [DATA_WIDTH-1:0] g_axis_TDATA [TILE_SIZE-1:0];
  logic                         y_axis_TVALID;
  logic                         y_axis_TREADY;
  logic signed [DATA_WIDTH-1:0] y_axis_TDATA [TILE_SIZE-1:0];

  reuse_ssm_core #(
      .TILE_SIZE(TILE_SIZE),
      .DATA_WIDTH(DATA_WIDTH),
      .D(D),
      .PIPE_LAT(PIPE_LAT),
      .ADDR_BITS(ADDR_BITS),
      .LUT_FILE(LUT_FILE),
      .S_ADDR_W(S_ADDR_W),
      .G_FRAC_BITS(G_FRAC_BITS)
  ) dut (
      .clk(clk),
      .rst_n(rst_n),
      .mac_m_valid(mac_m_valid),
      .mac_vec(mac_vec),
      .mac_m_ready(mac_m_ready),
      .xt_v(xt_v),
      .xt_r_int(xt_r_int),
      .xt_d(xt_d),
      .g_axis_TVALID(g_axis_TVALID),
      .g_axis_TREADY(g_axis_TREADY),
      .g_axis_TDATA(g_axis_TDATA),
      .y_axis_TVALID(y_axis_TVALID),
      .y_axis_TREADY(y_axis_TREADY),
      .y_axis_TDATA(y_axis_TDATA)
  );

  string case_dir;
  string stage_dir;
  logic [63:0] mac_in_mem [0:DEPTH-1];
  logic [63:0] xt_in_mem [0:DEPTH-1];
  logic [63:0] g_in_mem [0:DEPTH-1];
  logic [63:0] lam_golden_mem [0:DEPTH-1];
  logic [63:0] ssm_golden_mem [0:DEPTH-1];
  logic [63:0] gate_y_golden_mem [0:DEPTH-1];
  int stream_errors;
  int lam_idx, ssm_idx, gate_idx;
  bit lam_first_mismatch_seen, ssm_first_mismatch_seen, gate_first_mismatch_seen;
  int dbg_mac_seen, dbg_ad_seen, dbg_bias_seen, dbg_fifo_seen, dbg_sig_seen, dbg_join_seen, dbg_ssm_seen, dbg_y_seen;
  int dbg_ew_seen;

  function automatic string join_path(input string a, input string b);
    begin
      join_path = {a, "/", b};
    end
  endfunction

  function automatic logic signed [DATA_WIDTH-1:0] unpack_lane64(
      input logic [63:0] packed_word,
      input int lane
  );
    begin
      unpack_lane64 = $signed(packed_word[lane*DATA_WIDTH +: DATA_WIDTH]);
    end
  endfunction

  task automatic load_case_files();
    string case_dir_macro;
    begin
      case_dir_macro = `HW_DEBUG_CASE_DIR;
      if (!$value$plusargs("CASE_DIR=%s", case_dir))
        case_dir = case_dir_macro;
      if (case_dir.len() == 0)
        $fatal(1, "tb_reuse_ssm_core_hw_debug requires +CASE_DIR=<path> or HW_DEBUG_CASE_DIR");
      stage_dir = join_path(case_dir, "stages/reuse_ssm_core");
      $readmemh(join_path(stage_dir, "mac_in_q88.mem"), mac_in_mem);
      $readmemh(join_path(stage_dir, "xt_in_q88.mem"), xt_in_mem);
      $readmemh(join_path(stage_dir, "g_in_q88.mem"), g_in_mem);
      $readmemh(join_path(stage_dir, "lam_golden_q016.mem"), lam_golden_mem);
      $readmemh(join_path(stage_dir, "ssm_golden_q88.mem"), ssm_golden_mem);
      $readmemh(join_path(stage_dir, "gate_y_golden_q88.mem"), gate_y_golden_mem);
    end
  endtask

  initial begin
    mac_m_valid = 1'b0;
    xt_v = 1'b0;
    g_axis_TVALID = 1'b0;
    y_axis_TREADY = 1'b1;
    for (int i = 0; i < TILE_SIZE; i++) begin
      mac_vec[i] = '0;
      xt_d[i] = '0;
      g_axis_TDATA[i] = '0;
    end

    load_case_files();
    wait(rst_n);
    repeat (5) @(posedge clk);

    fork
      begin : drv_mac
        repeat (2) @(posedge clk);
        for (int idx = 0; idx < DEPTH; idx++) begin
          do @(posedge clk); while (dut.ad_valid && !dut.ad_ready);
          mac_m_valid <= 1'b1;
          for (int lane = 0; lane < TILE_SIZE; lane++)
            mac_vec[lane] <= unpack_lane64(mac_in_mem[idx], lane);
          @(posedge clk);
          mac_m_valid <= 1'b0;
          for (int i = 0; i < TILE_SIZE; i++) mac_vec[i] <= '0;
        end
      end
      begin : drv_xt
        repeat (2) @(posedge clk);
        for (int idx = 0; idx < DEPTH; idx++) begin
          xt_v <= 1'b1;
          for (int lane = 0; lane < TILE_SIZE; lane++)
            xt_d[lane] <= unpack_lane64(xt_in_mem[idx], lane);
          do @(posedge clk); while (!xt_r_int);
          xt_v <= 1'b0;
          for (int i = 0; i < TILE_SIZE; i++) xt_d[i] <= '0;
        end
      end
      begin : drv_g
        repeat (2) @(posedge clk);
        for (int idx = 0; idx < DEPTH; idx++) begin
          g_axis_TVALID <= 1'b1;
          for (int lane = 0; lane < TILE_SIZE; lane++)
            g_axis_TDATA[lane] <= unpack_lane64(g_in_mem[idx], lane);
          do @(posedge clk); while (!g_axis_TREADY);
          g_axis_TVALID <= 1'b0;
          for (int i = 0; i < TILE_SIZE; i++) g_axis_TDATA[i] <= '0;
        end
      end
    join
    repeat (200) @(posedge clk);
    if (lam_idx != DEPTH) begin
      stream_errors++;
      $error("[%0t] lam stream timeout collected=%0d expected=%0d", $time, lam_idx, DEPTH);
    end
    if (ssm_idx != DEPTH) begin
      stream_errors++;
      $error("[%0t] ssm stream timeout collected=%0d expected=%0d", $time, ssm_idx, DEPTH);
    end
    if (gate_idx != DEPTH) begin
      stream_errors++;
      $error("[%0t] gate_y stream timeout collected=%0d expected=%0d", $time, gate_idx, DEPTH);
    end
    if (stream_errors != 0)
      $fatal(1, "[%0t] found %0d reuse_ssm_core stream mismatches", $time, stream_errors);
    $display("[%0t] PASS reuse_ssm_core_hw_debug", $time);
    $finish;
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      stream_errors <= 0;
      lam_idx <= 0;
      ssm_idx <= 0;
      gate_idx <= 0;
      lam_first_mismatch_seen <= 1'b0;
      ssm_first_mismatch_seen <= 1'b0;
      gate_first_mismatch_seen <= 1'b0;
      dbg_mac_seen <= 0;
      dbg_ad_seen <= 0;
      dbg_bias_seen <= 0;
      dbg_fifo_seen <= 0;
      dbg_sig_seen <= 0;
      dbg_join_seen <= 0;
      dbg_ssm_seen <= 0;
      dbg_y_seen <= 0;
      dbg_ew_seen <= 0;
    end else begin
      if (mac_m_valid && dbg_mac_seen < 4) begin
        $display("[%0t] MAC pulse row0=%0d,%0d,%0d,%0d", $time, mac_vec[0], mac_vec[1], mac_vec[2], mac_vec[3]);
        dbg_mac_seen <= dbg_mac_seen + 1;
      end
      if (dut.ad_valid && dut.ad_ready && dbg_ad_seen < 4) begin
        $display("[%0t] AD fire row0=%0d,%0d,%0d,%0d", $time, dut.ad_vec[0], dut.ad_vec[1], dut.ad_vec[2], dut.ad_vec[3]);
        dbg_ad_seen <= dbg_ad_seen + 1;
      end
      if (dut.bias_valid && dut.bias_ready && dbg_bias_seen < 4) begin
        $display("[%0t] BIAS fire row0=%0d,%0d,%0d,%0d", $time, dut.bias_vec[0], dut.bias_vec[1], dut.bias_vec[2], dut.bias_vec[3]);
        dbg_bias_seen <= dbg_bias_seen + 1;
      end
      if (dut.fifo2sig_valid && dut.fifo2sig_ready && dbg_fifo_seen < 4) begin
        $display("[%0t] FIFO2SIG fire row0=%0d,%0d,%0d,%0d", $time, dut.fifo2sig_vec[0], dut.fifo2sig_vec[1], dut.fifo2sig_vec[2], dut.fifo2sig_vec[3]);
        dbg_fifo_seen <= dbg_fifo_seen + 1;
      end
      if (dut.sigmoid_out_valid && dut.sigmoid_out_ready && dbg_sig_seen < 4) begin
        $display("[%0t] SIG fire row0=%0d,%0d,%0d,%0d", $time, dut.sigmoid_out_vec[0], dut.sigmoid_out_vec[1], dut.sigmoid_out_vec[2], dut.sigmoid_out_vec[3]);
        dbg_sig_seen <= dbg_sig_seen + 1;
      end
      if (dut.join_out_valid && dut.join_out_ready_int && dbg_join_seen < 4) begin
        $display("[%0t] JOIN fire lam=%0d,%0d,%0d,%0d xt=%0d,%0d,%0d,%0d", $time,
          dut.join_lam_vec[0], dut.join_lam_vec[1], dut.join_lam_vec[2], dut.join_lam_vec[3],
          dut.join_xt_vec[0], dut.join_xt_vec[1], dut.join_xt_vec[2], dut.join_xt_vec[3]);
        dbg_join_seen <= dbg_join_seen + 1;
      end
      if (dut.s_out_valid && dut.s_out_ready && dbg_ssm_seen < 4) begin
        $display("[%0t] SSM fire row0=%0d,%0d,%0d,%0d", $time, dut.s_out_vec[0], dut.s_out_vec[1], dut.s_out_vec[2], dut.s_out_vec[3]);
        dbg_ssm_seen <= dbg_ssm_seen + 1;
      end
      if (dut.u_ew.st == dut.u_ew.ST_CALC && dbg_ew_seen < 4) begin
        $display("[%0t] EW CALC addr_r=%0d addr_w=%0d last_wr_v=%0b last_wr_addr=%0d",
                 $time, dut.u_ew.s_addr_r, dut.u_ew.s_addr_w, dut.u_ew.last_wr_valid, dut.u_ew.last_wr_addr);
        $display("[%0t] EW s_prev=%0d,%0d,%0d,%0d", $time,
                 dut.u_ew.s_prev_vec[0], dut.u_ew.s_prev_vec[1], dut.u_ew.s_prev_vec[2], dut.u_ew.s_prev_vec[3]);
        $display("[%0t] EW lam_r =%0d,%0d,%0d,%0d one_m=%0d,%0d,%0d,%0d", $time,
                 dut.u_ew.lam_r[0], dut.u_ew.lam_r[1], dut.u_ew.lam_r[2], dut.u_ew.lam_r[3],
                 dut.u_ew.one_minus[0], dut.u_ew.one_minus[1], dut.u_ew.one_minus[2], dut.u_ew.one_minus[3]);
        $display("[%0t] EW u_r   =%0d,%0d,%0d,%0d", $time,
                 dut.u_ew.u_r[0], dut.u_ew.u_r[1], dut.u_ew.u_r[2], dut.u_ew.u_r[3]);
        dbg_ew_seen <= dbg_ew_seen + 1;
      end
      if (dut.u_ew.ewa_v && dut.u_ew.ewa_r && dbg_ew_seen <= 4) begin
        $display("[%0t] EW MULA=%0d,%0d,%0d,%0d MULB=%0d,%0d,%0d,%0d SUM=%0d,%0d,%0d,%0d",
                 $time,
                 $signed(dut.u_ew.mul_a[0]), $signed(dut.u_ew.mul_a[1]), $signed(dut.u_ew.mul_a[2]), $signed(dut.u_ew.mul_a[3]),
                 $signed(dut.u_ew.mul_b[0]), $signed(dut.u_ew.mul_b[1]), $signed(dut.u_ew.mul_b[2]), $signed(dut.u_ew.mul_b[3]),
                 $signed(dut.u_ew.sum_y[0]), $signed(dut.u_ew.sum_y[1]), $signed(dut.u_ew.sum_y[2]), $signed(dut.u_ew.sum_y[3]));
      end
      if (y_axis_TVALID && y_axis_TREADY && dbg_y_seen < 4) begin
        $display("[%0t] Y fire row0=%0d,%0d,%0d,%0d", $time, y_axis_TDATA[0], y_axis_TDATA[1], y_axis_TDATA[2], y_axis_TDATA[3]);
        dbg_y_seen <= dbg_y_seen + 1;
      end

      if (dut.sigmoid_out_valid && dut.sigmoid_out_ready && lam_idx < DEPTH) begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          logic [DATA_WIDTH-1:0] got_v;
          logic [DATA_WIDTH-1:0] exp_v;
          got_v = dut.sigmoid_out_vec[lane];
          exp_v = lam_golden_mem[lam_idx][lane*DATA_WIDTH +: DATA_WIDTH];
          if (got_v !== exp_v) begin
            stream_errors++;
            if (!lam_first_mismatch_seen) begin
              $error("[%0t] FIRST lam mismatch idx=%0d lane=%0d got=%0d exp=%0d",
                     $time, lam_idx, lane, got_v, exp_v);
              lam_first_mismatch_seen <= 1'b1;
            end
          end
        end
        lam_idx <= lam_idx + 1;
      end

      if (dut.s_out_valid && dut.s_out_ready && ssm_idx < DEPTH) begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          logic signed [DATA_WIDTH-1:0] got_v;
          logic signed [DATA_WIDTH-1:0] exp_v;
          got_v = dut.s_out_vec[lane];
          exp_v = unpack_lane64(ssm_golden_mem[ssm_idx], lane);
          if (got_v !== exp_v) begin
            stream_errors++;
            if (!ssm_first_mismatch_seen) begin
              $error("[%0t] FIRST ssm mismatch idx=%0d lane=%0d got=%0d exp=%0d",
                     $time, ssm_idx, lane, got_v, exp_v);
              ssm_first_mismatch_seen <= 1'b1;
            end
          end
        end
        ssm_idx <= ssm_idx + 1;
      end

      if (y_axis_TVALID && y_axis_TREADY && gate_idx < DEPTH) begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          logic signed [DATA_WIDTH-1:0] got_v;
          logic signed [DATA_WIDTH-1:0] exp_v;
          got_v = y_axis_TDATA[lane];
          exp_v = unpack_lane64(gate_y_golden_mem[gate_idx], lane);
          if (got_v !== exp_v) begin
            stream_errors++;
            if (!gate_first_mismatch_seen) begin
              $error("[%0t] FIRST gate_y mismatch idx=%0d lane=%0d got=%0d exp=%0d",
                     $time, gate_idx, lane, got_v, exp_v);
              gate_first_mismatch_seen <= 1'b1;
            end
          end
        end
        gate_idx <= gate_idx + 1;
      end
    end
  end
endmodule
