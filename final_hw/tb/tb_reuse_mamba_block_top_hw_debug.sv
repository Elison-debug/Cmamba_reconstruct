`timescale 1ns/1ps
//=============================================================================
// tb_reuse_mamba_block_top_hw_debug.sv
//
// XSIM-oriented testbench that reads stage artifacts from:
//   HW_reconstruct/hw_debug/cases/<case_name>/stages/reuse_mamba_block_top/
//
// Usage:
//   xsim tb_reuse_mamba_block_top_hw_debug +CASE_DIR=<abs_or_rel_case_dir>
//
// Current scope:
//   - initialize in_proj / dt weights from exported bank mem files
//   - initialize h_t SRAM write stream from exported mem files
//   - run block_auto_mode once
//   - compare in_proj u/z SRAM contents against exported golden mem
//
//=============================================================================
module tb_reuse_mamba_block_top_hw_debug;
  `include "tb_hw_debug_case_path.svh"

  `ifndef HW_DEBUG_CASE_DIR
    `define HW_DEBUG_CASE_DIR ""
  `endif

  localparam int TILE_SIZE   = 4;
  localparam int DATA_WIDTH  = 16;
  localparam int ACC_WIDTH   = 32;
  localparam int FRAC_BITS   = 8;
  localparam int N_BANK      = 6;
  localparam int WDEPTH      = 1024;
  localparam int WADDR_W     = $clog2(WDEPTH);
  localparam int DATA_W      = 256;
  localparam int XT_ADDR_W   = 6;
  localparam int D           = 256;
  localparam int PIPE_LAT    = 4;
  localparam int ADDR_BITS   = 11;
  localparam string LUT_FILE = "sigmoid_lut_q016_2048.hex";
  localparam int S_ADDR_W    = 6;
  localparam int G_FRAC_BITS = 8;
  localparam int H_DEPTH     = 32;
  localparam int U_DEPTH     = 64;
  localparam int Y_DEPTH     = 32;
  localparam int OUT_WDEPTH  = 512;

  localparam string INPROJ_BANK0_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/inproj_wbuf_bank0.mem"};
  localparam string INPROJ_BANK1_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/inproj_wbuf_bank1.mem"};
  localparam string INPROJ_BANK2_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/inproj_wbuf_bank2.mem"};
  localparam string INPROJ_BANK3_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/inproj_wbuf_bank3.mem"};
  localparam string INPROJ_BANK4_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/inproj_wbuf_bank4.mem"};
  localparam string INPROJ_BANK5_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/inproj_wbuf_bank5.mem"};
  localparam string INPROJ_SCALE_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/inproj_scale_q15.mem"};
  localparam string DT_BANK0_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/dt_wbuf_bank0.mem"};
  localparam string DT_BANK1_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/dt_wbuf_bank1.mem"};
  localparam string DT_BANK2_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/dt_wbuf_bank2.mem"};
  localparam string DT_BANK3_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/dt_wbuf_bank3.mem"};
  localparam string DT_SCALE_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/dt_scale_q15.mem"};
  localparam string OUTPROJ_BANK0_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/outproj_wbuf_bank0.mem"};
  localparam string OUTPROJ_BANK1_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/outproj_wbuf_bank1.mem"};
  localparam string OUTPROJ_BANK2_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/outproj_wbuf_bank2.mem"};
  localparam string OUTPROJ_BANK3_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/outproj_wbuf_bank3.mem"};
  localparam string OUTPROJ_BANK4_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/outproj_wbuf_bank4.mem"};
  localparam string OUTPROJ_BANK5_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/outproj_wbuf_bank5.mem"};
  localparam string OUTPROJ_SCALE_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/outproj_scale_q15.mem"};
  localparam string NORM_GAMMA_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/norm_gamma_s16_q8p8.mem"};
  localparam string STATE_U_TO_STATE_SCALE_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/state_u_to_state_q16.mem"};
  localparam string STATE_TO_Q88_SCALE_INIT_FILE = {`HW_DEBUG_CASE_DIR, "/stages/reuse_mamba_block_top/state_to_q88_q16.mem"};


  logic clk, rst_n;
  initial begin
    clk = 1'b0;
    forever #1 clk = ~clk;
  end

  always_ff @(posedge clk) begin
    if (rst_n) begin
      if (dut.dt_u_rd_en || dut.u_dt_sched.xt_axis_TVALID || dut.dt_mac_valid ||
          dut.u_ssm_core.sigmoid_out_valid || dut.u_ssm_core.s_out_valid) begin
        $display(
            "[%0t] DTDBG flow=%0d dt_rd_en=%0b dt_rd_addr=%0d dt_rd=%0d,%0d,%0d,%0d xt_v=%0b xt=%0d,%0d,%0d,%0d dt_v=%0b dt=%0d,%0d,%0d,%0d lam_v=%0b lam=%0d,%0d,%0d,%0d ssm_v=%0b ssm=%0d,%0d,%0d,%0d",
            $time,
            {dut.block_done_reg, dut.dt_run_active, dut.block_active},
            dut.dt_u_rd_en,
            dut.dt_u_rd_addr,
            dut.dt_u_rd_data[0], dut.dt_u_rd_data[1], dut.dt_u_rd_data[2], dut.dt_u_rd_data[3],
            dut.u_dt_sched.xt_axis_TVALID,
            dut.xt_d[0], dut.xt_d[1], dut.xt_d[2], dut.xt_d[3],
            dut.dt_mac_valid,
            dut.dt_mac_vec[0], dut.dt_mac_vec[1], dut.dt_mac_vec[2], dut.dt_mac_vec[3],
            dut.u_ssm_core.sigmoid_out_valid,
            dut.u_ssm_core.sigmoid_out_vec[0], dut.u_ssm_core.sigmoid_out_vec[1],
            dut.u_ssm_core.sigmoid_out_vec[2], dut.u_ssm_core.sigmoid_out_vec[3],
            dut.u_ssm_core.s_out_valid,
            dut.u_ssm_core.s_out_vec[0], dut.u_ssm_core.s_out_vec[1],
            dut.u_ssm_core.s_out_vec[2], dut.u_ssm_core.s_out_vec[3]
        );
      end
    end
  end

  initial begin
    rst_n = 1'b0;
    repeat (10) @(posedge clk);
    rst_n = 1'b1;
  end

  initial begin
    $dumpfile("tb_reuse_mamba_block_top_hw_debug.vcd");
    $dumpvars(0, tb_reuse_mamba_block_top_hw_debug);
  end

  logic                         s_axis_TVALID;
  logic                         s_axis_TREADY;
  logic                         block_auto_mode;
  logic                         block_start;
  logic                         block_busy;
  logic                         block_done;
  logic                         g_axis_TVALID;
  logic                         g_axis_TREADY;
  logic signed [DATA_WIDTH-1:0] g_axis_TDATA [TILE_SIZE-1:0];
  logic                         y_axis_TVALID;
  logic                         y_axis_TREADY;
  logic signed [DATA_WIDTH-1:0] y_axis_TDATA [TILE_SIZE-1:0];

  logic                         inproj_enable;
  logic                         inproj_start;
  logic                         inproj_busy;
  logic                         inproj_done;
  logic                         h_wr_en;
  logic [4:0]                   h_wr_addr;
  logic signed [DATA_WIDTH-1:0] h_wr_data [TILE_SIZE-1:0];
  logic                         u_rd_en;
  logic [5:0]                   u_rd_addr;
  logic signed [DATA_WIDTH-1:0] u_rd_data [TILE_SIZE-1:0];
  logic                         z_rd_en;
  logic [5:0]                   z_rd_addr;
  logic signed [DATA_WIDTH-1:0] z_rd_data [TILE_SIZE-1:0];
  logic                         outproj_enable;
  logic                         outproj_busy;
  bit                           debug_arm;
  integer                       debug_cycles;

  reuse_mamba_block_top #(
      .TILE_SIZE  (TILE_SIZE),
      .DATA_WIDTH (DATA_WIDTH),
      .ACC_WIDTH  (ACC_WIDTH),
      .FRAC_BITS  (FRAC_BITS),
      .N_BANK     (N_BANK),
      .WDEPTH     (WDEPTH),
      .WADDR_W    (WADDR_W),
      .DATA_W     (DATA_W),
      .XT_ADDR_W  (XT_ADDR_W),
      .D          (D),
      .PIPE_LAT   (PIPE_LAT),
      .ADDR_BITS  (ADDR_BITS),
      .LUT_FILE   (LUT_FILE),
      .S_ADDR_W   (S_ADDR_W),
      .G_FRAC_BITS(G_FRAC_BITS),
      .INPROJ_BANK0_INIT_FILE (INPROJ_BANK0_INIT_FILE),
      .INPROJ_BANK1_INIT_FILE (INPROJ_BANK1_INIT_FILE),
      .INPROJ_BANK2_INIT_FILE (INPROJ_BANK2_INIT_FILE),
      .INPROJ_BANK3_INIT_FILE (INPROJ_BANK3_INIT_FILE),
      .INPROJ_BANK4_INIT_FILE (INPROJ_BANK4_INIT_FILE),
      .INPROJ_BANK5_INIT_FILE (INPROJ_BANK5_INIT_FILE),
      .INPROJ_SCALE_INIT_FILE (INPROJ_SCALE_INIT_FILE),
      .DT_BANK0_INIT_FILE     (DT_BANK0_INIT_FILE),
      .DT_BANK1_INIT_FILE     (DT_BANK1_INIT_FILE),
      .DT_BANK2_INIT_FILE     (DT_BANK2_INIT_FILE),
      .DT_BANK3_INIT_FILE     (DT_BANK3_INIT_FILE),
      .DT_SCALE_INIT_FILE     (DT_SCALE_INIT_FILE),
      .OUTPROJ_BANK0_INIT_FILE(OUTPROJ_BANK0_INIT_FILE),
      .OUTPROJ_BANK1_INIT_FILE(OUTPROJ_BANK1_INIT_FILE),
      .OUTPROJ_BANK2_INIT_FILE(OUTPROJ_BANK2_INIT_FILE),
      .OUTPROJ_BANK3_INIT_FILE(OUTPROJ_BANK3_INIT_FILE),
      .OUTPROJ_BANK4_INIT_FILE(OUTPROJ_BANK4_INIT_FILE),
      .OUTPROJ_BANK5_INIT_FILE(OUTPROJ_BANK5_INIT_FILE),
      .OUTPROJ_SCALE_INIT_FILE(OUTPROJ_SCALE_INIT_FILE),
      .INPROJ_USE_PER_CHANNEL_SCALE(1'b1),
      .DT_USE_PER_CHANNEL_SCALE(1'b1),
      .OUTPROJ_USE_PER_CHANNEL_SCALE(1'b1),
      // h_wr_data_s16_q8p8.mem stores pre-norm h; keep RMSNorm enabled here
      // so u/z golden and RTL datapath are aligned.
      .ENABLE_RMSNORM (1'b1),
      .NORM_GAMMA_INIT_FILE (NORM_GAMMA_INIT_FILE),
      .USE_SCALED_STATE_SCAN(1'b1),
      .STATE_U_TO_STATE_SCALE_INIT_FILE(STATE_U_TO_STATE_SCALE_INIT_FILE),
      .STATE_TO_Q88_SCALE_INIT_FILE(STATE_TO_Q88_SCALE_INIT_FILE)
  ) dut (
      .clk           (clk),
      .rst_n         (rst_n),
      .block_auto_mode(block_auto_mode),
      .block_start   (block_start),
      .block_busy    (block_busy),
      .block_done    (block_done),
      .s_axis_TVALID (s_axis_TVALID),
      .s_axis_TREADY (s_axis_TREADY),
      .g_axis_TVALID (g_axis_TVALID),
      .g_axis_TREADY (g_axis_TREADY),
      .g_axis_TDATA  (g_axis_TDATA),
      .y_axis_TVALID (y_axis_TVALID),
      .y_axis_TREADY (y_axis_TREADY),
      .y_axis_TDATA  (y_axis_TDATA),
      .inproj_enable (inproj_enable),
      .inproj_start  (inproj_start),
      .inproj_busy   (inproj_busy),
      .inproj_done   (inproj_done),
      .h_wr_en       (h_wr_en),
      .h_wr_addr     (h_wr_addr),
      .h_wr_data     (h_wr_data),
      .u_rd_en       (u_rd_en),
      .u_rd_addr     (u_rd_addr),
      .u_rd_data     (u_rd_data),
      .z_rd_en       (z_rd_en),
      .z_rd_addr     (z_rd_addr),
      .z_rd_data     (z_rd_data),
      .outproj_enable(outproj_enable),
      .outproj_busy  (outproj_busy)
  );

  string case_dir;
  string stage_dir;

  logic [7:0]   h_wr_addr_mem [0:H_DEPTH-1];
  logic [63:0]  h_wr_data_mem [0:H_DEPTH-1];
  logic [63:0]  u_golden_mem  [0:U_DEPTH-1];
  logic [63:0]  z_golden_mem  [0:U_DEPTH-1];
  logic [63:0]  u_act_golden_mem [0:U_DEPTH-1];
  logic [63:0]  z_silu_golden_mem [0:U_DEPTH-1];
  logic [63:0]  dt_golden_mem [0:U_DEPTH-1];
  logic [63:0]  lam_golden_mem [0:U_DEPTH-1];
  logic [63:0]  ssm_golden_mem [0:U_DEPTH-1];
  logic [63:0]  gate_y_golden_mem [0:U_DEPTH-1];
  logic [255:0] inproj_bank0_mem [0:WDEPTH-1];
  logic [255:0] inproj_bank1_mem [0:WDEPTH-1];
  logic [255:0] inproj_bank2_mem [0:WDEPTH-1];
  logic [255:0] inproj_bank3_mem [0:WDEPTH-1];
  logic [255:0] inproj_bank4_mem [0:WDEPTH-1];
  logic [255:0] inproj_bank5_mem [0:WDEPTH-1];
  logic [255:0] dt_bank0_mem [0:WDEPTH-1];
  logic [255:0] dt_bank1_mem [0:WDEPTH-1];
  logic [255:0] dt_bank2_mem [0:WDEPTH-1];
  logic [255:0] dt_bank3_mem [0:WDEPTH-1];
  logic [255:0] dt_bank4_mem [0:WDEPTH-1];
  logic [255:0] dt_bank5_mem [0:WDEPTH-1];
  logic [255:0] outproj_bank0_mem [0:OUT_WDEPTH-1];
  logic [255:0] outproj_bank1_mem [0:OUT_WDEPTH-1];
  logic [255:0] outproj_bank2_mem [0:OUT_WDEPTH-1];
  logic [255:0] outproj_bank3_mem [0:OUT_WDEPTH-1];
  logic [255:0] outproj_bank4_mem [0:OUT_WDEPTH-1];
  logic [255:0] outproj_bank5_mem [0:OUT_WDEPTH-1];
  logic [63:0]  inproj_scale_mem [0:127];
  logic [63:0]  dt_scale_mem [0:63];
  logic [63:0]  outproj_scale_mem [0:31];
  logic [63:0]  y_golden_mem [0:Y_DEPTH-1];
  int dt_rd_checks;
  int dt_rd_errors;
  int xt_checks;
  int xt_errors;
  int stream_errors;
  int p_mem_errors;
  int p_stream_errors;
  int p_stream_ok;
  int p_stream_idx;
  bit p_stream_first_mismatch_seen;
  int y_stream_errors;
  int y_stream_ok;
  int y_stream_idx;
  bit y_stream_first_mismatch_seen;
  int y_mem_errors;
  int outproj_dbg_count;
  int z_silu_errors;
  int z_silu_ok;
  int z_silu_idx;
  bit z_silu_first_mismatch_seen;
  int dt_stream_errors;
  int dt_stream_ok;
  int dt_stream_idx;
  bit dt_stream_first_mismatch_seen;
  int lam_stream_errors;
  int lam_stream_ok;
  int lam_stream_idx;
  bit lam_stream_first_mismatch_seen;
  int ssm_stream_errors;
  int ssm_stream_ok;
  int ssm_stream_idx;
  bit ssm_stream_first_mismatch_seen;
  int gate_stream_errors;
  int gate_stream_ok;
  int gate_stream_idx;
  bit gate_stream_first_mismatch_seen;

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
      if (!$value$plusargs("CASE_DIR=%s", case_dir)) begin
        case_dir = case_dir_macro;
      end
      if (case_dir.len() == 0) begin
        $fatal(1, "tb_reuse_mamba_block_top_hw_debug requires +CASE_DIR=<path> or compile define HW_DEBUG_CASE_DIR");
      end
      stage_dir = join_path(case_dir, "stages/reuse_mamba_block_top");
      $display("[%0t] CASE_DIR=%s", $time, case_dir);
      $display("[%0t] STAGE_DIR=%s", $time, stage_dir);

      $readmemh(join_path(stage_dir, "h_wr_addr.mem"), h_wr_addr_mem);
      $readmemh(join_path(stage_dir, "h_wr_data_s16_q8p8.mem"), h_wr_data_mem);
      $readmemh(join_path(stage_dir, "u_golden_q88.mem"), u_golden_mem);
      $readmemh(join_path(stage_dir, "z_golden_q88.mem"), z_golden_mem);
      $readmemh(join_path(stage_dir, "u_act_golden_q88.mem"), u_act_golden_mem);
      $readmemh(join_path(stage_dir, "z_silu_golden_q88.mem"), z_silu_golden_mem);
      $readmemh(join_path(stage_dir, "dt_golden_q88.mem"), dt_golden_mem);
      $readmemh(join_path(stage_dir, "lam_golden_q016.mem"), lam_golden_mem);
      $readmemh(join_path(stage_dir, "ssm_golden_q88.mem"), ssm_golden_mem);
      $readmemh(join_path(stage_dir, "gate_y_golden_q88.mem"), gate_y_golden_mem);
      $readmemh(join_path(stage_dir, "inproj_wbuf_bank0.mem"), inproj_bank0_mem);
      $readmemh(join_path(stage_dir, "inproj_wbuf_bank1.mem"), inproj_bank1_mem);
      $readmemh(join_path(stage_dir, "inproj_wbuf_bank2.mem"), inproj_bank2_mem);
      $readmemh(join_path(stage_dir, "inproj_wbuf_bank3.mem"), inproj_bank3_mem);
      $readmemh(join_path(stage_dir, "inproj_wbuf_bank4.mem"), inproj_bank4_mem);
      $readmemh(join_path(stage_dir, "inproj_wbuf_bank5.mem"), inproj_bank5_mem);
      $readmemh(join_path(stage_dir, "dt_wbuf_bank0.mem"), dt_bank0_mem);
      $readmemh(join_path(stage_dir, "dt_wbuf_bank1.mem"), dt_bank1_mem);
      $readmemh(join_path(stage_dir, "dt_wbuf_bank2.mem"), dt_bank2_mem);
      $readmemh(join_path(stage_dir, "dt_wbuf_bank3.mem"), dt_bank3_mem);
      $readmemh(join_path(stage_dir, "dt_wbuf_bank4.mem"), dt_bank4_mem);
      $readmemh(join_path(stage_dir, "dt_wbuf_bank5.mem"), dt_bank5_mem);
      $readmemh(join_path(stage_dir, "outproj_wbuf_bank0.mem"), outproj_bank0_mem);
      $readmemh(join_path(stage_dir, "outproj_wbuf_bank1.mem"), outproj_bank1_mem);
      $readmemh(join_path(stage_dir, "outproj_wbuf_bank2.mem"), outproj_bank2_mem);
      $readmemh(join_path(stage_dir, "outproj_wbuf_bank3.mem"), outproj_bank3_mem);
      $readmemh(join_path(stage_dir, "outproj_wbuf_bank4.mem"), outproj_bank4_mem);
      $readmemh(join_path(stage_dir, "outproj_wbuf_bank5.mem"), outproj_bank5_mem);
      $readmemh(join_path(stage_dir, "inproj_scale_q15.mem"), inproj_scale_mem);
      $readmemh(join_path(stage_dir, "dt_scale_q15.mem"), dt_scale_mem);
      $readmemh(join_path(stage_dir, "outproj_scale_q15.mem"), outproj_scale_mem);
      $readmemh(join_path(stage_dir, "y_golden_q88.mem"), y_golden_mem);
    end
  endtask

  task automatic init_weight_mems_from_case();
    begin
//      for (int addr = 0; addr < WDEPTH; addr++) begin
//        dut.u_in_proj.u_w_sram.u_weight.mem_sim[0][addr] = inproj_bank0_mem[addr];
//        dut.u_in_proj.u_w_sram.u_weight.mem_sim[1][addr] = inproj_bank1_mem[addr];
//        dut.u_in_proj.u_w_sram.u_weight.mem_sim[2][addr] = inproj_bank2_mem[addr];
//        dut.u_in_proj.u_w_sram.u_weight.mem_sim[3][addr] = inproj_bank3_mem[addr];
//        dut.u_in_proj.u_w_sram.u_weight.mem_sim[4][addr] = inproj_bank4_mem[addr];
//        dut.u_in_proj.u_w_sram.u_weight.mem_sim[5][addr] = inproj_bank5_mem[addr];

//        dut.u_dt_sched.dt_wbuf_mem_sim[0][addr] = dt_bank0_mem[addr];
//        dut.u_dt_sched.dt_wbuf_mem_sim[1][addr] = dt_bank1_mem[addr];
//        dut.u_dt_sched.dt_wbuf_mem_sim[2][addr] = dt_bank2_mem[addr];
//        dut.u_dt_sched.dt_wbuf_mem_sim[3][addr] = dt_bank3_mem[addr];
//      end
      for (int addr = 0; addr < 128; addr++) begin
        dut.u_in_proj.u_scale_mem.mem[addr] = inproj_scale_mem[addr];
      end
//      for (int addr = 0; addr < 64; addr++) begin
//        dut.u_dt_sched.u_scale_mem.mem[addr] = dt_scale_mem[addr];
//      end
      $display("[%0t] FILE  inproj bank0 addr0 = %h", $time, inproj_bank0_mem[0]);
      $display("[%0t] SRAM  inproj bank0 addr0 = %h", $time, dut.u_in_proj.u_w_sram.u_weight.mem_sim0[0]);
      $display("[%0t] FILE  dt     bank0 addr0 = %h", $time, dt_bank0_mem[0]);
      $display("[%0t] SRAM  dt     bank0 addr0 = %h", $time, dut.u_dt_sched.dt_wbuf_mem_sim0[0]);
//      for (int addr = 0; addr < OUT_WDEPTH; addr++) begin
//        dut.u_out_proj.u_w_sram.u_weight.mem_sim[0][addr] = outproj_bank0_mem[addr];
//        dut.u_out_proj.u_w_sram.u_weight.mem_sim[1][addr] = outproj_bank1_mem[addr];
//        dut.u_out_proj.u_w_sram.u_weight.mem_sim[2][addr] = outproj_bank2_mem[addr];
//        dut.u_out_proj.u_w_sram.u_weight.mem_sim[3][addr] = outproj_bank3_mem[addr];
//        dut.u_out_proj.u_w_sram.u_weight.mem_sim[4][addr] = outproj_bank4_mem[addr];
//        dut.u_out_proj.u_w_sram.u_weight.mem_sim[5][addr] = outproj_bank5_mem[addr];
//      end
      for (int addr = 0; addr < 32; addr++) begin
        dut.u_out_proj.u_scale_mem.mem[addr] = outproj_scale_mem[addr];
      end
      $display("[%0t] FILE  outproj bank0 addr0 = %h", $time, outproj_bank0_mem[0]);
      $display("[%0t] SRAM  outproj bank0 addr0 = %h", $time, dut.u_out_proj.u_w_sram.u_weight.mem_sim0[0]);
    end
  endtask

  task automatic write_h_from_case();
    begin
      for (int idx = 0; idx < H_DEPTH; idx++) begin
        @(posedge clk);
        h_wr_en   <= 1'b1;
        h_wr_addr <= h_wr_addr_mem[idx][4:0];
        for (int lane = 0; lane < TILE_SIZE; lane++)
          h_wr_data[lane] <= unpack_lane64(h_wr_data_mem[idx], lane);
      end
      @(posedge clk);
      h_wr_en   <= 1'b0;
      h_wr_addr <= '0;
      for (int lane = 0; lane < TILE_SIZE; lane++)
        h_wr_data[lane] <= '0;
      $display(
          "[%0t] H    file row0 addr=%0d data=%0d,%0d,%0d,%0d",
          $time,
          h_wr_addr_mem[0][4:0],
          unpack_lane64(h_wr_data_mem[0], 0),
          unpack_lane64(h_wr_data_mem[0], 1),
          unpack_lane64(h_wr_data_mem[0], 2),
          unpack_lane64(h_wr_data_mem[0], 3)
      );
      $display(
          "[%0t] H    sram row0 data=%0d,%0d,%0d,%0d",
          $time,
          $signed(dut.u_in_proj.u_h_sram.mem_sim[0][0*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_in_proj.u_h_sram.mem_sim[0][1*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_in_proj.u_h_sram.mem_sim[0][2*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_in_proj.u_h_sram.mem_sim[0][3*DATA_WIDTH +: DATA_WIDTH])
      );
    end
  endtask

  task automatic compare_uz_mem();
    int u_ok;
    int z_ok;
    bit first_u_mismatch_seen;
    bit first_z_mismatch_seen;
    logic signed [DATA_WIDTH-1:0] got_u;
    logic signed [DATA_WIDTH-1:0] exp_u;
    logic signed [DATA_WIDTH-1:0] got_z;
    logic signed [DATA_WIDTH-1:0] exp_z;
    begin
      u_ok = 0;
      z_ok = 0;
      first_u_mismatch_seen = 1'b0;
      first_z_mismatch_seen = 1'b0;
      $display(
          "[%0t] U/Z  golden row0 u=%0d,%0d,%0d,%0d z=%0d,%0d,%0d,%0d",
          $time,
          unpack_lane64(u_golden_mem[0], 0),
          unpack_lane64(u_golden_mem[0], 1),
          unpack_lane64(u_golden_mem[0], 2),
          unpack_lane64(u_golden_mem[0], 3),
          unpack_lane64(z_golden_mem[0], 0),
          unpack_lane64(z_golden_mem[0], 1),
          unpack_lane64(z_golden_mem[0], 2),
          unpack_lane64(z_golden_mem[0], 3)
      );
      $display(
          "[%0t] U/Z  SRAM   row0 u=%0d,%0d,%0d,%0d z=%0d,%0d,%0d,%0d",
          $time,
          $signed(dut.u_in_proj.u_u_sram.u_vec_ip.g_vec_ip_64.u_copy0.inst.\native_mem_module .blk_mem_gen_v8_4_8_inst.memory[0][0*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_in_proj.u_u_sram.u_vec_ip.g_vec_ip_64.u_copy0.inst.\native_mem_module .blk_mem_gen_v8_4_8_inst.memory[0][1*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_in_proj.u_u_sram.u_vec_ip.g_vec_ip_64.u_copy0.inst.\native_mem_module .blk_mem_gen_v8_4_8_inst.memory[0][2*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_in_proj.u_u_sram.u_vec_ip.g_vec_ip_64.u_copy0.inst.\native_mem_module .blk_mem_gen_v8_4_8_inst.memory[0][3*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_in_proj.u_z_sram.u_vec_ip.g_vec_ip_64.u_copy0.inst.\native_mem_module .blk_mem_gen_v8_4_8_inst.memory[0][0*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_in_proj.u_z_sram.u_vec_ip.g_vec_ip_64.u_copy0.inst.\native_mem_module .blk_mem_gen_v8_4_8_inst.memory[0][1*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_in_proj.u_z_sram.u_vec_ip.g_vec_ip_64.u_copy0.inst.\native_mem_module .blk_mem_gen_v8_4_8_inst.memory[0][2*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_in_proj.u_z_sram.u_vec_ip.g_vec_ip_64.u_copy0.inst.\native_mem_module .blk_mem_gen_v8_4_8_inst.memory[0][3*DATA_WIDTH +: DATA_WIDTH])
      );
      for (int addr = 0; addr < U_DEPTH; addr++) begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          got_u = $signed(dut.u_in_proj.u_u_sram.u_vec_ip.g_vec_ip_64.u_copy0.inst.\native_mem_module .blk_mem_gen_v8_4_8_inst.memory[addr][lane*DATA_WIDTH +: DATA_WIDTH]);
          exp_u = unpack_lane64(u_golden_mem[addr], lane);
          if (got_u !== exp_u) begin
            if (!first_u_mismatch_seen) begin
              $error("[%0t] FIRST u SRAM mismatch addr=%0d lane=%0d got=%0d exp=%0d", $time, addr, lane, got_u, exp_u);
              first_u_mismatch_seen = 1'b1;
            end
          end else begin
            u_ok++;
          end

          got_z = $signed(dut.u_in_proj.u_z_sram.u_vec_ip.g_vec_ip_64.u_copy0.inst.\native_mem_module .blk_mem_gen_v8_4_8_inst.memory[addr][lane*DATA_WIDTH +: DATA_WIDTH]);
          exp_z = unpack_lane64(z_golden_mem[addr], lane);
          if (got_z !== exp_z) begin
            if (!first_z_mismatch_seen) begin
              $error("[%0t] FIRST z SRAM mismatch addr=%0d lane=%0d got=%0d exp=%0d", $time, addr, lane, got_z, exp_z);
              first_z_mismatch_seen = 1'b1;
            end
          end else begin
            z_ok++;
          end
        end
      end
      $display("[%0t] MATCH reuse_mamba_block_top hw_debug u lanes=%0d z lanes=%0d", $time, u_ok, z_ok);
    end
  endtask

  task automatic compare_p_mem();
    int p_ok;
    bit first_p_mismatch_seen;
    logic signed [DATA_WIDTH-1:0] got_p;
    logic signed [DATA_WIDTH-1:0] exp_p;
    begin
      p_ok = 0;
      first_p_mismatch_seen = 1'b0;
      $display(
          "[%0t] P    golden row0=%0d,%0d,%0d,%0d",
          $time,
          unpack_lane64(gate_y_golden_mem[0], 0),
          unpack_lane64(gate_y_golden_mem[0], 1),
          unpack_lane64(gate_y_golden_mem[0], 2),
          unpack_lane64(gate_y_golden_mem[0], 3)
      );
      $display(
          "[%0t] P    SRAM   row0=%0d,%0d,%0d,%0d",
          $time,
          $signed(dut.u_p_sram.mem_sim[0][0*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_p_sram.mem_sim[0][1*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_p_sram.mem_sim[0][2*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_p_sram.mem_sim[0][3*DATA_WIDTH +: DATA_WIDTH])
      );
      for (int addr = 0; addr < U_DEPTH; addr++) begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          got_p = $signed(dut.u_p_sram.mem_sim[addr][lane*DATA_WIDTH +: DATA_WIDTH]);
          exp_p = unpack_lane64(gate_y_golden_mem[addr], lane);
          if (got_p !== exp_p) begin
            p_mem_errors++;
            if (!first_p_mismatch_seen) begin
              $error("[%0t] FIRST p SRAM mismatch addr=%0d lane=%0d got=%0d exp=%0d",
                     $time, addr, lane, got_p, exp_p);
              first_p_mismatch_seen = 1'b1;
            end
          end else begin
            p_ok++;
          end
        end
      end
      $display("[%0t] MATCH p_capture SRAM lanes=%0d", $time, p_ok);
    end
  endtask

  task automatic compare_y_mem();
    int y_ok;
    bit first_y_mismatch_seen;
    logic signed [DATA_WIDTH-1:0] got_y;
    logic signed [DATA_WIDTH-1:0] exp_y;
    begin
      y_ok = 0;
      first_y_mismatch_seen = 1'b0;
      $display(
          "[%0t] Y    golden row0=%0d,%0d,%0d,%0d",
          $time,
          unpack_lane64(y_golden_mem[0], 0),
          unpack_lane64(y_golden_mem[0], 1),
          unpack_lane64(y_golden_mem[0], 2),
          unpack_lane64(y_golden_mem[0], 3)
      );
      $display(
          "[%0t] Y    SRAM   row0=%0d,%0d,%0d,%0d",
          $time,
          $signed(dut.u_out_proj.u_y_sram.u_vec_ip.g_vec_ip_32.u_copy0.inst.\native_mem_module .blk_mem_gen_v8_4_8_inst.memory[0][0*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_out_proj.u_y_sram.u_vec_ip.g_vec_ip_32.u_copy0.inst.\native_mem_module .blk_mem_gen_v8_4_8_inst.memory[0][1*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_out_proj.u_y_sram.u_vec_ip.g_vec_ip_32.u_copy0.inst.\native_mem_module .blk_mem_gen_v8_4_8_inst.memory[0][2*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_out_proj.u_y_sram.u_vec_ip.g_vec_ip_32.u_copy0.inst.\native_mem_module .blk_mem_gen_v8_4_8_inst.memory[0][3*DATA_WIDTH +: DATA_WIDTH])
      );
      for (int addr = 0; addr < Y_DEPTH; addr++) begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          got_y = $signed(dut.u_out_proj.u_y_sram.u_vec_ip.g_vec_ip_32.u_copy0.inst.\native_mem_module .blk_mem_gen_v8_4_8_inst.memory[addr][lane*DATA_WIDTH +: DATA_WIDTH]);
          exp_y = unpack_lane64(y_golden_mem[addr], lane);
          if (got_y !== exp_y) begin
            y_mem_errors++;
            if (!first_y_mismatch_seen) begin
              $error("[%0t] FIRST y SRAM mismatch addr=%0d lane=%0d got=%0d exp=%0d",
                     $time, addr, lane, got_y, exp_y);
              first_y_mismatch_seen = 1'b1;
            end
            $display("[%0t] Y SRAM mismatch addr=%0d lane=%0d got=%0d exp=%0d",
                     $time, addr, lane, got_y, exp_y);
          end else begin
            y_ok++;
          end
        end
      end
      $display("[%0t] MATCH y SRAM lanes=%0d", $time, y_ok);
    end
  endtask

  task automatic compare_stream_q88(
      input string tag,
      ref logic valid_sig,
      ref logic ready_sig,
      ref logic signed [DATA_WIDTH-1:0] vec_sig [TILE_SIZE-1:0],
      input logic [63:0] golden_mem [0:U_DEPTH-1]
  );
    int idx;
    int ok;
    int budget;
    bit first_mismatch_seen;
    logic signed [DATA_WIDTH-1:0] got_v;
    logic signed [DATA_WIDTH-1:0] exp_v;
    begin
      idx = 0;
      ok = 0;
      budget = 20000;
      first_mismatch_seen = 1'b0;
      while (idx < U_DEPTH && budget > 0) begin
        @(posedge clk);
        budget--;
        if (valid_sig && ready_sig) begin
          for (int lane = 0; lane < TILE_SIZE; lane++) begin
            got_v = vec_sig[lane];
            exp_v = unpack_lane64(golden_mem[idx], lane);
            if (got_v !== exp_v) begin
              stream_errors++;
              if (!first_mismatch_seen) begin
                $error("[%0t] FIRST %s mismatch idx=%0d lane=%0d got=%0d exp=%0d",
                       $time, tag, idx, lane, got_v, exp_v);
                first_mismatch_seen = 1'b1;
              end
            end else begin
              ok++;
            end
          end
          idx++;
        end
      end
      if (idx != U_DEPTH) begin
        stream_errors++;
        $error("[%0t] %s stream timeout collected=%0d expected=%0d", $time, tag, idx, U_DEPTH);
      end
      $display("[%0t] MATCH %s lanes=%0d", $time, tag, ok);
    end
  endtask

  task automatic compare_stream_u16(
      input string tag,
      ref logic valid_sig,
      ref logic ready_sig,
      ref logic [DATA_WIDTH-1:0] vec_sig [TILE_SIZE-1:0],
      input logic [63:0] golden_mem [0:U_DEPTH-1]
  );
    int idx;
    int ok;
    int budget;
    bit first_mismatch_seen;
    logic [DATA_WIDTH-1:0] got_v;
    logic [DATA_WIDTH-1:0] exp_v;
    begin
      idx = 0;
      ok = 0;
      budget = 20000;
      first_mismatch_seen = 1'b0;
      while (idx < U_DEPTH && budget > 0) begin
        @(posedge clk);
        budget--;
        if (valid_sig && ready_sig) begin
          for (int lane = 0; lane < TILE_SIZE; lane++) begin
            got_v = vec_sig[lane];
            exp_v = golden_mem[idx][lane*DATA_WIDTH +: DATA_WIDTH];
            if (got_v !== exp_v) begin
              stream_errors++;
              if (!first_mismatch_seen) begin
                $error("[%0t] FIRST %s mismatch idx=%0d lane=%0d got=%0d exp=%0d",
                       $time, tag, idx, lane, got_v, exp_v);
                first_mismatch_seen = 1'b1;
              end
            end else begin
              ok++;
            end
          end
          idx++;
        end
      end
      if (idx != U_DEPTH) begin
        stream_errors++;
        $error("[%0t] %s stream timeout collected=%0d expected=%0d", $time, tag, idx, U_DEPTH);
      end
      $display("[%0t] MATCH %s lanes=%0d", $time, tag, ok);
    end
  endtask

  int dt_req_addr_q[$];
  bit dt_first_rd_mismatch_seen;
  bit xt_first_mismatch_seen;
  int xt_fire_dbg_count;
  logic dt_u_rd_en_d1;
  logic [XT_ADDR_W-1:0] dt_u_rd_addr_d1;
  int xt_stream_idx;

  task automatic check_dt_read_lane_match(input int exp_addr);
    logic [63:0] exp_pack;
    logic signed [DATA_WIDTH-1:0] got_v;
    logic signed [DATA_WIDTH-1:0] exp_v;
    begin
      exp_pack = u_act_golden_mem[exp_addr];
      dt_rd_checks++;
      for (int lane = 0; lane < TILE_SIZE; lane++) begin
        got_v = dut.dt_u_rd_data[lane];
        exp_v = unpack_lane64(exp_pack, lane);
        if (got_v !== exp_v) begin
          dt_rd_errors++;
          if (!dt_first_rd_mismatch_seen) begin
            $error("[%0t] FIRST dt read mismatch addr=%0d lane=%0d got=%0d exp=%0d",
                   $time, exp_addr, lane, got_v, exp_v);
            dt_first_rd_mismatch_seen = 1'b1;
          end
        end
      end
    end
  endtask

  task automatic check_xt_fire_match(input logic [63:0] exp_pack);
    logic signed [DATA_WIDTH-1:0] got_v;
    logic signed [DATA_WIDTH-1:0] exp_v;
    begin
      xt_checks++;
      for (int lane = 0; lane < TILE_SIZE; lane++) begin
        got_v = dut.xt_d[lane];
        exp_v = unpack_lane64(exp_pack, lane);
        if (got_v !== exp_v) begin
          xt_errors++;
          if (!xt_first_mismatch_seen) begin
            $error("[%0t] FIRST xt stream mismatch lane=%0d got=%0d exp=%0d",
                   $time, lane, got_v, exp_v);
            xt_first_mismatch_seen = 1'b1;
          end
        end
      end
    end
  endtask

  task automatic start_block_once();
    begin
      @(posedge clk);
      block_start <= 1'b1;
      @(posedge clk);
      block_start <= 1'b0;
    end
  endtask

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      debug_arm    <= 1'b0;
      debug_cycles <= 0;
      dt_req_addr_q.delete();
      dt_rd_checks <= 0;
      dt_rd_errors <= 0;
      xt_checks <= 0;
      xt_errors <= 0;
      stream_errors <= 0;
      p_mem_errors <= 0;
      p_stream_errors <= 0;
      p_stream_ok <= 0;
      p_stream_idx <= 0;
      p_stream_first_mismatch_seen <= 1'b0;
      z_silu_errors <= 0;
      z_silu_ok <= 0;
      z_silu_idx <= 0;
      z_silu_first_mismatch_seen <= 1'b0;
      dt_stream_errors <= 0;
      dt_stream_ok <= 0;
      dt_stream_idx <= 0;
      dt_stream_first_mismatch_seen <= 1'b0;
      lam_stream_errors <= 0;
      lam_stream_ok <= 0;
      lam_stream_idx <= 0;
      lam_stream_first_mismatch_seen <= 1'b0;
      ssm_stream_errors <= 0;
      ssm_stream_ok <= 0;
      ssm_stream_idx <= 0;
      ssm_stream_first_mismatch_seen <= 1'b0;
      gate_stream_errors <= 0;
      gate_stream_ok <= 0;
      gate_stream_idx <= 0;
      gate_stream_first_mismatch_seen <= 1'b0;
      y_stream_errors <= 0;
      y_stream_ok <= 0;
      y_stream_idx <= 0;
      y_stream_first_mismatch_seen <= 1'b0;
      y_mem_errors <= 0;
      outproj_dbg_count <= 0;
      dt_first_rd_mismatch_seen <= 1'b0;
      xt_first_mismatch_seen <= 1'b0;
      xt_fire_dbg_count <= 0;
      dt_u_rd_en_d1 <= 1'b0;
      dt_u_rd_addr_d1 <= '0;
      xt_stream_idx <= 0;
    end else begin
      if (dut.dt_u_rd_en) begin
        dt_req_addr_q.push_back(dut.dt_u_rd_addr);
      end
      dt_u_rd_en_d1 <= dut.dt_u_rd_en;
      dt_u_rd_addr_d1 <= dut.dt_u_rd_addr;
      if (outproj_dbg_count < 32 &&
          (dut.u_out_proj.state == 3'd1 || dut.u_out_proj.y_wr_en)) begin
        $display("[%0t] OUTDBG cyc=%0d st=%0d row=%0d data=%0d tile=%0d valid=%0b ff1=%0b ff2=%0b fvin=%0b grp=%0b ywr=%0b yaddr=%0d paddr=%0d,%0d,%0d,%0d",
                 $time,
                 outproj_dbg_count + 1,
                 dut.u_out_proj.state,
                 dut.u_out_proj.row_tile_linear,
                 dut.u_out_proj.data_cnt,
                 dut.u_out_proj.tile_cnt,
                 dut.u_out_proj.valid_in,
                 dut.u_out_proj.fetch_fire_d1,
                 dut.u_out_proj.fetch_fire_d2,
                 dut.u_out_proj.fabric_valid_in,
                 dut.u_out_proj.group_start,
                 dut.u_out_proj.y_wr_en,
                 dut.u_out_proj.y_wr_addr,
                 dut.u_out_proj.p_rd_addr0,
                 dut.u_out_proj.p_rd_addr1,
                 dut.u_out_proj.p_rd_addr2,
                 dut.u_out_proj.p_rd_addr3);
        $display("[%0t] OUTDBG A0=%0d,%0d,%0d,%0d A1=%0d,%0d,%0d,%0d",
                 $time,
                 $signed(dut.u_out_proj.A0_mat_reg[0][0]), $signed(dut.u_out_proj.A0_mat_reg[0][1]),
                 $signed(dut.u_out_proj.A0_mat_reg[0][2]), $signed(dut.u_out_proj.A0_mat_reg[0][3]),
                 $signed(dut.u_out_proj.A1_mat_reg[0][0]), $signed(dut.u_out_proj.A1_mat_reg[0][1]),
                 $signed(dut.u_out_proj.A1_mat_reg[0][2]), $signed(dut.u_out_proj.A1_mat_reg[0][3]));
        $display("[%0t] OUTDBG A2=%0d,%0d,%0d,%0d A3=%0d,%0d,%0d,%0d",
                 $time,
                 $signed(dut.u_out_proj.A2_mat_reg[0][0]), $signed(dut.u_out_proj.A2_mat_reg[0][1]),
                 $signed(dut.u_out_proj.A2_mat_reg[0][2]), $signed(dut.u_out_proj.A2_mat_reg[0][3]),
                 $signed(dut.u_out_proj.A3_mat_reg[0][0]), $signed(dut.u_out_proj.A3_mat_reg[0][1]),
                 $signed(dut.u_out_proj.A3_mat_reg[0][2]), $signed(dut.u_out_proj.A3_mat_reg[0][3]));
        $display("[%0t] OUTDBG B0=%0d,%0d,%0d,%0d B1=%0d,%0d,%0d,%0d",
                 $time,
                 $signed(dut.u_out_proj.B0_mat_reg[0][0]), $signed(dut.u_out_proj.B0_mat_reg[0][1]),
                 $signed(dut.u_out_proj.B0_mat_reg[0][2]), $signed(dut.u_out_proj.B0_mat_reg[0][3]),
                 $signed(dut.u_out_proj.B1_mat_reg[0][0]), $signed(dut.u_out_proj.B1_mat_reg[0][1]),
                 $signed(dut.u_out_proj.B1_mat_reg[0][2]), $signed(dut.u_out_proj.B1_mat_reg[0][3]));
        $display("[%0t] OUTDBG B2=%0d,%0d,%0d,%0d B3=%0d,%0d,%0d,%0d",
                 $time,
                 $signed(dut.u_out_proj.B2_mat_reg[0][0]), $signed(dut.u_out_proj.B2_mat_reg[0][1]),
                 $signed(dut.u_out_proj.B2_mat_reg[0][2]), $signed(dut.u_out_proj.B2_mat_reg[0][3]),
                 $signed(dut.u_out_proj.B3_mat_reg[0][0]), $signed(dut.u_out_proj.B3_mat_reg[0][1]),
                 $signed(dut.u_out_proj.B3_mat_reg[0][2]), $signed(dut.u_out_proj.B3_mat_reg[0][3]));
        $display("[%0t] OUTDBG p0=%0d,%0d,%0d,%0d red=%0d,%0d,%0d,%0d final=%0d,%0d,%0d,%0d y=%0d,%0d,%0d,%0d",
                 $time,
                 $signed(dut.p_rd_data0_out[0]), $signed(dut.p_rd_data0_out[1]),
                 $signed(dut.p_rd_data0_out[2]), $signed(dut.p_rd_data0_out[3]),
                 $signed(dut.out_reduced_vec[0]), $signed(dut.out_reduced_vec[1]),
                 $signed(dut.out_reduced_vec[2]), $signed(dut.out_reduced_vec[3]),
                 $signed(dut.u_out_proj.final_vec[0]), $signed(dut.u_out_proj.final_vec[1]),
                 $signed(dut.u_out_proj.final_vec[2]), $signed(dut.u_out_proj.final_vec[3]),
                 $signed(dut.y_axis_TDATA[0]), $signed(dut.y_axis_TDATA[1]),
                 $signed(dut.y_axis_TDATA[2]), $signed(dut.y_axis_TDATA[3]));
        outproj_dbg_count <= outproj_dbg_count + 1;
      end
      if (dt_u_rd_en_d1) begin
        int exp_addr;
        if (dt_rd_checks < 12) begin
          $display("[%0t] DTREAD d1 addr=%0d rd=%0d,%0d,%0d,%0d qsz=%0d",
                   $time,
                   dt_u_rd_addr_d1,
                   $signed(dut.dt_u_rd_data[0]), $signed(dut.dt_u_rd_data[1]),
                   $signed(dut.dt_u_rd_data[2]), $signed(dut.dt_u_rd_data[3]),
                   dt_req_addr_q.size());
        end
        if (dt_req_addr_q.size() == 0) begin
          dt_rd_errors <= dt_rd_errors + 1;
          if (!dt_first_rd_mismatch_seen) begin
            $error("[%0t] dt_u_rd_en_d1 fired with empty dt read queue", $time);
            dt_first_rd_mismatch_seen <= 1'b1;
          end
        end else begin
          exp_addr = dt_req_addr_q.pop_front();
          check_dt_read_lane_match(exp_addr);
        end
      end
      if (dut.xt_v && dut.xt_r_int) begin
        logic [63:0] exp_xt_pack;
        if (xt_stream_idx < U_DEPTH)
          exp_xt_pack = u_act_golden_mem[xt_stream_idx];
        else
          exp_xt_pack = '0;
        if (xt_fire_dbg_count < 12) begin
          $display("[%0t] XTFIRE idx=%0d out=%0d,%0d,%0d,%0d",
                   $time,
                   xt_stream_idx,
                   $signed(dut.xt_d[0]), $signed(dut.xt_d[1]),
                   $signed(dut.xt_d[2]), $signed(dut.xt_d[3]));
          xt_fire_dbg_count <= xt_fire_dbg_count + 1;
        end
        if (xt_stream_idx >= U_DEPTH) begin
          xt_errors <= xt_errors + 1;
          if (!xt_first_mismatch_seen) begin
            $error("[%0t] xt stream produced more than %0d vectors", $time, U_DEPTH);
            xt_first_mismatch_seen <= 1'b1;
          end
        end else begin
          check_xt_fire_match(exp_xt_pack);
          xt_stream_idx <= xt_stream_idx + 1;
        end
      end
      if (dut.p_wr_en && p_stream_idx < U_DEPTH) begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          logic signed [DATA_WIDTH-1:0] got_v;
          logic signed [DATA_WIDTH-1:0] exp_v;
          got_v = dut.p_wr_data[lane];
          exp_v = unpack_lane64(gate_y_golden_mem[p_stream_idx], lane);
          if (got_v !== exp_v) begin
            p_stream_errors++;
            if (!p_stream_first_mismatch_seen) begin
              $error("[%0t] FIRST p stream mismatch idx=%0d lane=%0d got=%0d exp=%0d",
                     $time, p_stream_idx, lane, got_v, exp_v);
              p_stream_first_mismatch_seen <= 1'b1;
            end
          end else begin
            p_stream_ok++;
          end
        end
        p_stream_idx <= p_stream_idx + 1;
      end
      if (y_axis_TVALID && y_axis_TREADY && y_stream_idx < Y_DEPTH) begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          logic signed [DATA_WIDTH-1:0] got_v;
          logic signed [DATA_WIDTH-1:0] exp_v;
          got_v = y_axis_TDATA[lane];
          exp_v = unpack_lane64(y_golden_mem[y_stream_idx], lane);
          if (got_v !== exp_v) begin
            y_stream_errors++;
            if (!y_stream_first_mismatch_seen) begin
              $error("[%0t] FIRST y stream mismatch idx=%0d lane=%0d got=%0d exp=%0d",
                     $time, y_stream_idx, lane, got_v, exp_v);
              y_stream_first_mismatch_seen <= 1'b1;
            end
          end else begin
            y_stream_ok++;
          end
        end
        y_stream_idx <= y_stream_idx + 1;
      end
      if (dut.silu_valid && dut.silu_ready && z_silu_idx < U_DEPTH) begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          logic signed [DATA_WIDTH-1:0] got_v;
          logic signed [DATA_WIDTH-1:0] exp_v;
          got_v = dut.silu_vec[lane];
          exp_v = unpack_lane64(z_silu_golden_mem[z_silu_idx], lane);
          if (got_v !== exp_v) begin
            z_silu_errors++;
            if (!z_silu_first_mismatch_seen) begin
              $error("[%0t] FIRST z_silu stream mismatch idx=%0d lane=%0d got=%0d exp=%0d",
                     $time, z_silu_idx, lane, got_v, exp_v);
              z_silu_first_mismatch_seen <= 1'b1;
            end
          end else begin
            z_silu_ok++;
          end
        end
        z_silu_idx <= z_silu_idx + 1;
      end
      if (dut.dt_mac_valid && dut.dt_mac_ready && dt_stream_idx < U_DEPTH) begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          logic signed [DATA_WIDTH-1:0] got_v;
          logic signed [DATA_WIDTH-1:0] exp_v;
          got_v = dut.dt_mac_vec[lane];
          exp_v = unpack_lane64(dt_golden_mem[dt_stream_idx], lane);
          if (got_v !== exp_v) begin
            dt_stream_errors++;
            if (!dt_stream_first_mismatch_seen) begin
              $error("[%0t] FIRST dt stream mismatch idx=%0d lane=%0d got=%0d exp=%0d",
                     $time, dt_stream_idx, lane, got_v, exp_v);
              dt_stream_first_mismatch_seen <= 1'b1;
            end
          end else begin
            dt_stream_ok++;
          end
        end
        dt_stream_idx <= dt_stream_idx + 1;
      end
      if (dut.u_ssm_core.sigmoid_out_valid && dut.u_ssm_core.sigmoid_out_ready && lam_stream_idx < U_DEPTH) begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          logic [DATA_WIDTH-1:0] got_v;
          logic [DATA_WIDTH-1:0] exp_v;
          got_v = dut.u_ssm_core.sigmoid_out_vec[lane];
          exp_v = lam_golden_mem[lam_stream_idx][lane*DATA_WIDTH +: DATA_WIDTH];
          if (got_v !== exp_v) begin
            lam_stream_errors++;
            if (!lam_stream_first_mismatch_seen) begin
              $error("[%0t] FIRST lam stream mismatch idx=%0d lane=%0d got=%0d exp=%0d",
                     $time, lam_stream_idx, lane, got_v, exp_v);
              lam_stream_first_mismatch_seen <= 1'b1;
            end
          end else begin
            lam_stream_ok++;
          end
        end
        lam_stream_idx <= lam_stream_idx + 1;
      end
      if (dut.u_ssm_core.s_out_valid && dut.u_ssm_core.s_out_ready && ssm_stream_idx < U_DEPTH) begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          logic signed [DATA_WIDTH-1:0] got_v;
          logic signed [DATA_WIDTH-1:0] exp_v;
          got_v = dut.u_ssm_core.s_out_vec[lane];
          exp_v = unpack_lane64(ssm_golden_mem[ssm_stream_idx], lane);
          if (got_v !== exp_v) begin
            ssm_stream_errors++;
            if (!ssm_stream_first_mismatch_seen) begin
              $error("[%0t] FIRST ssm stream mismatch idx=%0d lane=%0d got=%0d exp=%0d",
                     $time, ssm_stream_idx, lane, got_v, exp_v);
              ssm_stream_first_mismatch_seen <= 1'b1;
            end
          end else begin
            ssm_stream_ok++;
          end
        end
        ssm_stream_idx <= ssm_stream_idx + 1;
      end
      if (dut.ssm_p_valid && dut.ssm_p_ready && gate_stream_idx < U_DEPTH) begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          logic signed [DATA_WIDTH-1:0] got_v;
          logic signed [DATA_WIDTH-1:0] exp_v;
          got_v = dut.ssm_p_data[lane];
          exp_v = unpack_lane64(gate_y_golden_mem[gate_stream_idx], lane);
          if (got_v !== exp_v) begin
            gate_stream_errors++;
            if (!gate_stream_first_mismatch_seen) begin
              $error("[%0t] FIRST gate_y stream mismatch idx=%0d lane=%0d got=%0d exp=%0d",
                     $time, gate_stream_idx, lane, got_v, exp_v);
              gate_stream_first_mismatch_seen <= 1'b1;
            end
          end else begin
            gate_stream_ok++;
          end
        end
        gate_stream_idx <= gate_stream_idx + 1;
      end
      if (block_start) begin
        debug_arm    <= 1'b1;
        debug_cycles <= 0;
      end else if (debug_arm) begin
        debug_cycles <= debug_cycles + 1;
        if ((dut.u_in_proj.valid_in || dut.u_in_proj.fetch_fire_d1 ||
             dut.u_in_proj.fabric_valid_in || dut.u_in_proj.out_phase_active) &&
            (debug_cycles < 24)) begin
          $display(
              "[%0t] DBG cyc=%0d state=%0d data_cnt=%0d tile_cnt=%0d out_phase=%0d out_cnt=%0d valid_in=%0b ff1=%0b ff2=%0b fvin=%0b en=%b en_r=%b out=%b haddr=%0d,%0d,%0d,%0d",
              $time,
              debug_cycles,
              dut.u_in_proj.state,
              dut.u_in_proj.data_cnt,
              dut.u_in_proj.tile_cnt,
              dut.u_in_proj.out_phase_active,
              dut.u_in_proj.out_phase_cnt,
              dut.u_in_proj.valid_in,
              dut.u_in_proj.fetch_fire_d1,
              dut.u_in_proj.fetch_fire_d2,
              dut.u_in_proj.fabric_valid_in,
              dut.u_in_proj.en_sel,
              dut.u_in_proj.en_sel_reg,
              dut.u_in_proj.out_sel,
              dut.u_in_proj.h_rd_addr0,
              dut.u_in_proj.h_rd_addr1,
              dut.u_in_proj.h_rd_addr2,
              dut.u_in_proj.h_rd_addr3
          );
          $display(
              "[%0t] DBG A0reg row0=%0d,%0d,%0d,%0d  B0reg row0=%0d,%0d,%0d,%0d  h0=%0d,%0d,%0d,%0d  h1=%0d,%0d,%0d,%0d",
              $time,
              $signed(dut.u_in_proj.A0_mat_reg[0][0]),
              $signed(dut.u_in_proj.A0_mat_reg[0][1]),
              $signed(dut.u_in_proj.A0_mat_reg[0][2]),
              $signed(dut.u_in_proj.A0_mat_reg[0][3]),
              $signed(dut.u_in_proj.B0_mat_reg[0][0]),
              $signed(dut.u_in_proj.B0_mat_reg[0][1]),
              $signed(dut.u_in_proj.B0_mat_reg[0][2]),
              $signed(dut.u_in_proj.B0_mat_reg[0][3]),
              $signed(dut.u_in_proj.h_rd_data0[0]),
              $signed(dut.u_in_proj.h_rd_data0[1]),
              $signed(dut.u_in_proj.h_rd_data0[2]),
              $signed(dut.u_in_proj.h_rd_data0[3]),
              $signed(dut.u_in_proj.h_rd_data1[0]),
              $signed(dut.u_in_proj.h_rd_data1[1]),
              $signed(dut.u_in_proj.h_rd_data1[2]),
              $signed(dut.u_in_proj.h_rd_data1[3])
          );
        end
        if (debug_cycles >= 24)
          debug_arm <= 1'b0;
      end
    end
  end

  integer top_debug_cycles;
  bit     post_inproj_arm;
  integer post_inproj_cycles;
  bit     uact_dump_done;
  bit     dt_read_dump_done;
  integer uact_write_dbg_count;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      top_debug_cycles <= 0;
      post_inproj_arm  <= 1'b0;
      post_inproj_cycles <= 0;
      uact_dump_done <= 1'b0;
      dt_read_dump_done <= 1'b0;
      uact_write_dbg_count <= 0;
    end else if (block_start || block_busy) begin
      top_debug_cycles <= top_debug_cycles + 1;
      if (dut.uact_wr_en && (uact_write_dbg_count < 8)) begin
        $display("[%0t] UACT WRITE addr=%0d data=%0d,%0d,%0d,%0d silu=%0d,%0d,%0d,%0d u_stream=%0d,%0d,%0d,%0d",
                 $time,
                 dut.uact_wr_addr,
                 $signed(dut.uact_wr_data[0]), $signed(dut.uact_wr_data[1]),
                 $signed(dut.uact_wr_data[2]), $signed(dut.uact_wr_data[3]),
                 $signed(dut.uact_vec[0]), $signed(dut.uact_vec[1]),
                 $signed(dut.uact_vec[2]), $signed(dut.uact_vec[3]),
                 $signed(dut.u_stream_vec[0]), $signed(dut.u_stream_vec[1]),
                 $signed(dut.u_stream_vec[2]), $signed(dut.u_stream_vec[3]));
        uact_write_dbg_count <= uact_write_dbg_count + 1;
      end
      if (dut.uact_fill_done && !uact_dump_done) begin
        $display("[%0t] UACT SRAM row0=%0d,%0d,%0d,%0d",
                 $time,
                 $signed(dut.u_uact_sram.mem_sim[0][0*DATA_WIDTH +: DATA_WIDTH]),
                 $signed(dut.u_uact_sram.mem_sim[0][1*DATA_WIDTH +: DATA_WIDTH]),
                 $signed(dut.u_uact_sram.mem_sim[0][2*DATA_WIDTH +: DATA_WIDTH]),
                 $signed(dut.u_uact_sram.mem_sim[0][3*DATA_WIDTH +: DATA_WIDTH]));
        $display("[%0t] UACT SRAM row1=%0d,%0d,%0d,%0d",
                 $time,
                 $signed(dut.u_uact_sram.mem_sim[1][0*DATA_WIDTH +: DATA_WIDTH]),
                 $signed(dut.u_uact_sram.mem_sim[1][1*DATA_WIDTH +: DATA_WIDTH]),
                 $signed(dut.u_uact_sram.mem_sim[1][2*DATA_WIDTH +: DATA_WIDTH]),
                 $signed(dut.u_uact_sram.mem_sim[1][3*DATA_WIDTH +: DATA_WIDTH]));
        $display("[%0t] UACT SRAM row63=%0d,%0d,%0d,%0d",
                 $time,
                 $signed(dut.u_uact_sram.mem_sim[63][0*DATA_WIDTH +: DATA_WIDTH]),
                 $signed(dut.u_uact_sram.mem_sim[63][1*DATA_WIDTH +: DATA_WIDTH]),
                 $signed(dut.u_uact_sram.mem_sim[63][2*DATA_WIDTH +: DATA_WIDTH]),
                 $signed(dut.u_uact_sram.mem_sim[63][3*DATA_WIDTH +: DATA_WIDTH]));
        uact_dump_done <= 1'b1;
      end
      if (dut.dt_u_rd_en && !dt_read_dump_done) begin
        $display("[%0t] DT first read addr=%0d uact_q=%0d,%0d,%0d,%0d dt_u_rd=%0d,%0d,%0d,%0d",
                 $time,
                 dut.dt_u_rd_addr,
                 $signed(dut.u_uact_sram.q[0*DATA_WIDTH +: DATA_WIDTH]),
                 $signed(dut.u_uact_sram.q[1*DATA_WIDTH +: DATA_WIDTH]),
                 $signed(dut.u_uact_sram.q[2*DATA_WIDTH +: DATA_WIDTH]),
                 $signed(dut.u_uact_sram.q[3*DATA_WIDTH +: DATA_WIDTH]),
                 dut.dt_u_rd_data[0], dut.dt_u_rd_data[1], dut.dt_u_rd_data[2], dut.dt_u_rd_data[3]);
        dt_read_dump_done <= 1'b1;
      end
      if (inproj_done) begin
        post_inproj_arm <= 1'b1;
        post_inproj_cycles <= 0;
      end else if (post_inproj_arm) begin
        post_inproj_cycles <= post_inproj_cycles + 1;
        if (post_inproj_cycles < 120) begin
          $display(
              "[%0t] POST flow=%0d in_done=%0b u_auto_en=%0b u_auto_addr=%0d z_auto_en=%0b z_auto_addr=%0d u_busy=%0b u_done=%0b u_v=%0b z_busy=%0b z_done=%0b z_v=%0b silu_v=%0b uact_v=%0b uact_we=%0b uact_cnt=%0d uact_done=%0b dt_rd_en=%0b dt_rd_addr=%0d dt_rd0=%0d dt_v=%0b dt0=%0d lam_v=%0b lam0=%0d ssm_v=%0b ssm0=%0d",
              $time,
              {dut.block_done_reg, dut.dt_run_active, dut.block_active},
              inproj_done,
              dut.u_auto_rd_en,
              dut.u_auto_rd_addr,
              dut.z_gate_rd_en,
              dut.z_gate_rd_addr,
              dut.u_stream_busy,
              dut.u_stream_done,
              dut.u_stream_valid,
              dut.z_stream_busy,
              dut.z_stream_done,
              dut.z_stream_valid,
              dut.silu_valid,
              dut.uact_valid,
              dut.uact_wr_en,
              dut.uact_wr_count,
              dut.uact_fill_done,
              dut.dt_u_rd_en,
              dut.dt_u_rd_addr,
              dut.dt_u_rd_data[0],
              dut.dt_mac_valid,
              dut.dt_mac_vec[0],
              dut.u_ssm_core.sigmoid_out_valid,
              dut.u_ssm_core.sigmoid_out_vec[0],
              dut.u_ssm_core.s_out_valid
              ,
              dut.u_ssm_core.s_out_vec[0]
          );
        end else begin
          post_inproj_arm <= 1'b0;
        end
      end
      if (top_debug_cycles < 200) begin
        if (inproj_done || dut.u_stream_valid || dut.uact_valid || dut.z_stream_valid ||
            dut.silu_valid || dut.dt_mac_valid || dut.u_ssm_core.sigmoid_out_valid ||
            dut.u_ssm_core.s_out_valid || dut.uact_wr_en || dut.uact_fill_done) begin
          $display(
              "[%0t] TOP flow=%0d in_done=%0b u_busy=%0b u_v=%0b uact_v=%0b uact_we=%0b uact_cnt=%0d uact_done=%0b z_v=%0b silu_v=%0b dt_v=%0b lam_v=%0b ssm_v=%0b dt_ready=%0b",
              $time,
              {dut.block_done_reg, dut.dt_run_active, dut.block_active},
              inproj_done,
              dut.u_stream_busy,
              dut.u_stream_valid,
              dut.uact_valid,
              dut.uact_wr_en,
              dut.uact_wr_count,
              dut.uact_fill_done,
              dut.z_stream_valid,
              dut.silu_valid,
              dut.dt_mac_valid,
              dut.u_ssm_core.sigmoid_out_valid,
              dut.u_ssm_core.s_out_valid,
              s_axis_TREADY
          );
        end
      end
      if (dut.p_wr_en && p_stream_idx < 8) begin
        $display("[%0t] PWRITE idx=%0d addr=%0d data=%0d,%0d,%0d,%0d",
                 $time, p_stream_idx, dut.p_wr_addr,
                 $signed(dut.p_wr_data[0]), $signed(dut.p_wr_data[1]),
                 $signed(dut.p_wr_data[2]), $signed(dut.p_wr_data[3]));
      end
    end else begin
      top_debug_cycles <= 0;
      post_inproj_arm <= 1'b0;
      post_inproj_cycles <= 0;
      uact_dump_done <= 1'b0;
      dt_read_dump_done <= 1'b0;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      y_axis_TREADY <= 1'b1;
    else
      y_axis_TREADY <= 1'b1;
  end

  always_comb begin
    g_axis_TVALID = 1'b1;
    for (int i = 0; i < TILE_SIZE; i++)
      g_axis_TDATA[i] = '0;
  end

  initial begin
    s_axis_TVALID   = 1'b0;
    block_auto_mode = 1'b1;
    block_start     = 1'b0;
    inproj_enable   = 1'b1;
    inproj_start    = 1'b0;
    h_wr_en         = 1'b0;
    h_wr_addr       = '0;
    u_rd_en         = 1'b0;
    u_rd_addr       = '0;
    z_rd_en         = 1'b0;
    z_rd_addr       = '0;
    outproj_enable  = 1'b0;
    for (int i = 0; i < TILE_SIZE; i++)
      h_wr_data[i] = '0;

    load_case_files();
    wait(rst_n);
    repeat (5) @(posedge clk);

    $display("[%0t] init weight memories from hw_debug case", $time);
    init_weight_mems_from_case();

    $display("[%0t] write h_t SRAM from hw_debug case", $time);
    write_h_from_case();

    $display("[%0t] start block auto sequence", $time);
    start_block_once();
    wait(inproj_done);
    repeat (8) @(posedge clk);

    compare_uz_mem();
    wait(block_done);
    repeat (50) @(posedge clk);
    compare_p_mem();
    compare_y_mem();
    if (dt_rd_checks == 0)
      $fatal(1, "[%0t] no dt SRAM read checks observed", $time);
    if (xt_checks == 0)
      $fatal(1, "[%0t] no xt stream checks observed", $time);
    if (dt_rd_errors != 0)
      $fatal(1, "[%0t] found %0d dt SRAM read mismatches", $time, dt_rd_errors);
    if (xt_errors != 0)
      $fatal(1, "[%0t] found %0d xt stream mismatches", $time, xt_errors);
    if (xt_checks != U_DEPTH)
      $fatal(1, "[%0t] xt stream collected=%0d expected=%0d", $time, xt_checks, U_DEPTH);
    if (p_stream_idx != U_DEPTH)
      $fatal(1, "[%0t] p stream collected=%0d expected=%0d", $time, p_stream_idx, U_DEPTH);
    if (y_stream_idx != Y_DEPTH)
      $fatal(1, "[%0t] y stream collected=%0d expected=%0d", $time, y_stream_idx, Y_DEPTH);
    if (z_silu_idx != U_DEPTH)
      $fatal(1, "[%0t] z_silu stream collected=%0d expected=%0d", $time, z_silu_idx, U_DEPTH);
    if (dt_stream_idx != U_DEPTH)
      $fatal(1, "[%0t] dt stream collected=%0d expected=%0d", $time, dt_stream_idx, U_DEPTH);
    if (lam_stream_idx != U_DEPTH)
      $fatal(1, "[%0t] lam stream collected=%0d expected=%0d", $time, lam_stream_idx, U_DEPTH);
    if (ssm_stream_idx != U_DEPTH)
      $fatal(1, "[%0t] ssm stream collected=%0d expected=%0d", $time, ssm_stream_idx, U_DEPTH);
    if (gate_stream_idx != U_DEPTH)
      $fatal(1, "[%0t] gate_y stream collected=%0d expected=%0d", $time, gate_stream_idx, U_DEPTH);
    if (dt_stream_errors != 0)
      $fatal(1, "[%0t] found %0d dt stream mismatches", $time, dt_stream_errors);
    if (lam_stream_errors != 0)
      $fatal(1, "[%0t] found %0d lam stream mismatches", $time, lam_stream_errors);
    if (ssm_stream_errors != 0)
      $fatal(1, "[%0t] found %0d ssm stream mismatches", $time, ssm_stream_errors);
    if (z_silu_errors != 0)
      $fatal(1, "[%0t] found %0d z_silu stream mismatches", $time, z_silu_errors);
    if (gate_stream_errors != 0)
      $fatal(1, "[%0t] found %0d gate_y stream mismatches", $time, gate_stream_errors);
    if (p_stream_errors != 0)
      $fatal(1, "[%0t] found %0d p stream mismatches", $time, p_stream_errors);
    if (y_stream_errors != 0)
      $fatal(1, "[%0t] found %0d y stream mismatches", $time, y_stream_errors);
    if (stream_errors != 0)
      $fatal(1, "[%0t] found %0d legacy stream compare mismatches", $time, stream_errors);
    if (p_mem_errors != 0)
      $fatal(1, "[%0t] found %0d p SRAM mismatches", $time, p_mem_errors);
    if (y_mem_errors != 0)
      $fatal(1, "[%0t] found %0d y SRAM mismatches", $time, y_mem_errors);
    $display("[%0t] PASS reuse_mamba_block_top_hw_debug full compare", $time);
    $finish;
  end
endmodule
