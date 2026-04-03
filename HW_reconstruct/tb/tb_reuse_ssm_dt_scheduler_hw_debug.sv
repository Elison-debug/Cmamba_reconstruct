`timescale 1ns/1ps
//=============================================================================
// tb_reuse_ssm_dt_scheduler_hw_debug.sv
//
// Reads stage artifacts from:
//   HW_reconstruct/hw_debug/cases/<case>/stages/reuse_ssm_dt_scheduler/
//
// Scope:
//   - preload u_act SRAM
//   - preload dt WBUF banks
//   - issue 64 tile-start pulses
//   - compare dt output stream and xt stream
//=============================================================================
module tb_reuse_ssm_dt_scheduler_hw_debug;
  `include "tb_hw_debug_case_path.svh"

  `ifndef HW_DEBUG_CASE_DIR
    `define HW_DEBUG_CASE_DIR ""
  `endif

  localparam int TILE_SIZE   = 4;
  localparam int DATA_WIDTH  = 16;
  localparam int ACC_WIDTH   = 32;
  localparam int FRAC_BITS   = 8;
  localparam int N_BANK      = 6;
  localparam int WDEPTH      = 683;
  localparam int WADDR_W     = $clog2(WDEPTH);
  localparam int DATA_W      = 256;
  localparam int XT_ADDR_W   = 6;
  localparam int U_DEPTH     = 64;

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

  initial begin
    $dumpfile("tb_reuse_ssm_dt_scheduler_hw_debug.vcd");
    $dumpvars(0, tb_reuse_ssm_dt_scheduler_hw_debug);
  end

  string case_dir;
  string stage_dir;
  string rtl_stage_dir;

  logic [63:0]  u_act_in_mem [0:U_DEPTH-1];
  logic [63:0]  dt_golden_mem [0:U_DEPTH-1];
  logic [63:0]  xt_golden_mem [0:U_DEPTH-1];
  logic [255:0] dt_bank0_mem [0:WDEPTH-1];
  logic [255:0] dt_bank1_mem [0:WDEPTH-1];
  logic [255:0] dt_bank2_mem [0:WDEPTH-1];
  logic [255:0] dt_bank3_mem [0:WDEPTH-1];
  logic [255:0] dt_bank4_mem [0:WDEPTH-1];
  logic [255:0] dt_bank5_mem [0:WDEPTH-1];

  logic                         s_axis_TVALID;
  logic                         s_axis_TREADY;
  logic                         m_axis_TVALID;
  logic                         m_axis_TREADY;
  logic signed [DATA_WIDTH-1:0] reduced_trunc [TILE_SIZE-1:0];
  logic                         xt_axis_TVALID;
  logic                         xt_axis_TREADY;
  logic signed [DATA_WIDTH-1:0] xt_axis_TDATA [TILE_SIZE-1:0];
  logic                         ref_xt_axis_TVALID;
  logic                         ref_xt_axis_TREADY;
  logic signed [DATA_WIDTH-1:0] ref_xt_axis_TDATA [TILE_SIZE-1:0];
  logic                         ref_s_axis_TREADY;
  logic                         ref_m_axis_TVALID;
  logic signed [DATA_WIDTH-1:0] ref_reduced_trunc [TILE_SIZE-1:0];
  logic                         u_vec_rd_en;
  logic [XT_ADDR_W-1:0]         u_vec_rd_addr;
  logic signed [DATA_WIDTH-1:0] u_vec_rd_data [TILE_SIZE-1:0];

  logic [1:0]                    fabric_mode;
  logic [6:0]                    fabric_col_blocks;
  logic                          fabric_valid_in;
  logic signed [DATA_WIDTH-1:0]  fabric_A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0]  fabric_A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0]  fabric_A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0]  fabric_A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0]  fabric_B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0]  fabric_B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0]  fabric_B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0]  fabric_B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [ACC_WIDTH-1:0]   fabric_reduced_vec [TILE_SIZE-1:0];
  logic signed [ACC_WIDTH-1:0]   fabric_reduced_mat_0 [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [ACC_WIDTH-1:0]   fabric_reduced_mat_1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [ACC_WIDTH-1:0]   fabric_reduced_mat_2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [ACC_WIDTH-1:0]   fabric_reduced_mat_3 [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic                          fabric_valid_out;

  logic dt_errors, xt_errors;
  int dt_idx, xt_idx, dt_mismatch_count, xt_mismatch_count;
  int ref_dt_mismatch_count, ref_xt_mismatch_count;
  int cur_vs_ref_dt_mismatch_count, cur_vs_ref_xt_mismatch_count;
  bit dt_first_seen, xt_first_seen, ref_dt_first_seen, ref_xt_first_seen, cur_ref_dt_first_seen, cur_ref_xt_first_seen;
  int dbg_cycle;
  logic [63:0] dt_captured_mem [0:U_DEPTH-1];
  logic [63:0] xt_captured_mem [0:U_DEPTH-1];

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
        $fatal(1, "tb_reuse_ssm_dt_scheduler_hw_debug requires +CASE_DIR=<path> or compile define HW_DEBUG_CASE_DIR");
      end
      stage_dir = join_path(case_dir, "stages/reuse_ssm_dt_scheduler");
      rtl_stage_dir = join_path(case_dir, "rtl_out/reuse_ssm_dt_scheduler");
      $display("[%0t] CASE_DIR=%s", $time, case_dir);
      $display("[%0t] STAGE_DIR=%s", $time, stage_dir);

      $readmemh(join_path(stage_dir, "u_act_in_q88.mem"), u_act_in_mem);
      $readmemh(join_path(stage_dir, "dt_golden_q88.mem"), dt_golden_mem);
      $readmemh(join_path(stage_dir, "xt_golden_q88.mem"), xt_golden_mem);
      $readmemh(join_path(stage_dir, "dt_wbuf_bank0.mem"), dt_bank0_mem);
      $readmemh(join_path(stage_dir, "dt_wbuf_bank1.mem"), dt_bank1_mem);
      $readmemh(join_path(stage_dir, "dt_wbuf_bank2.mem"), dt_bank2_mem);
      $readmemh(join_path(stage_dir, "dt_wbuf_bank3.mem"), dt_bank3_mem);
      $readmemh(join_path(stage_dir, "dt_wbuf_bank4.mem"), dt_bank4_mem);
      $readmemh(join_path(stage_dir, "dt_wbuf_bank5.mem"), dt_bank5_mem);
    end
  endtask

  task automatic write_dump_mem(input string path, input logic [63:0] mem [0:U_DEPTH-1], input int count);
    integer fd;
    begin
      fd = $fopen(path, "w");
      if (fd == 0) begin
        $fatal(1, "failed to open dump path %s", path);
      end
      for (int idx = 0; idx < count; idx++) begin
        $fdisplay(fd, "%016X", mem[idx]);
      end
      $fclose(fd);
    end
  endtask

  reuse_ssm_dt_scheduler #(
      .TILE_SIZE (TILE_SIZE),
      .DATA_WIDTH(DATA_WIDTH),
      .ACC_WIDTH (ACC_WIDTH),
      .FRAC_BITS (FRAC_BITS),
      .N_BANK    (N_BANK),
      .WDEPTH    (WDEPTH),
      .WADDR_W   (WADDR_W),
      .DATA_W    (DATA_W),
      .XT_ADDR_W (XT_ADDR_W)
  ) dut (
      .clk(clk),
      .rst_n(rst_n),
      .sched_busy(),
      .u_vec_rd_en(u_vec_rd_en),
      .u_vec_rd_addr(u_vec_rd_addr),
      .u_vec_rd_data(u_vec_rd_data),
      .s_axis_TVALID(s_axis_TVALID),
      .s_axis_TREADY(s_axis_TREADY),
      .m_axis_TVALID(m_axis_TVALID),
      .m_axis_TREADY(m_axis_TREADY),
      .reduced_trunc(reduced_trunc),
      .xt_axis_TVALID(xt_axis_TVALID),
      .xt_axis_TREADY(xt_axis_TREADY),
      .xt_axis_TDATA(xt_axis_TDATA),
      .fabric_mode(fabric_mode),
      .fabric_col_blocks(fabric_col_blocks),
      .fabric_valid_in(fabric_valid_in),
      .fabric_A0_mat(fabric_A0_mat),
      .fabric_A1_mat(fabric_A1_mat),
      .fabric_A2_mat(fabric_A2_mat),
      .fabric_A3_mat(fabric_A3_mat),
      .fabric_B0_mat(fabric_B0_mat),
      .fabric_B1_mat(fabric_B1_mat),
      .fabric_B2_mat(fabric_B2_mat),
      .fabric_B3_mat(fabric_B3_mat),
      .fabric_reduced_vec(fabric_reduced_vec),
      .fabric_reduced_mat_0(fabric_reduced_mat_0),
      .fabric_reduced_mat_1(fabric_reduced_mat_1),
      .fabric_reduced_mat_2(fabric_reduced_mat_2),
      .fabric_reduced_mat_3(fabric_reduced_mat_3),
      .fabric_valid_out(fabric_valid_out)
  );

  reuse_shared_mac_fabric #(
      .TILE_SIZE (TILE_SIZE),
      .DATA_WIDTH(DATA_WIDTH),
      .ACC_WIDTH (ACC_WIDTH),
      .FRAC_BITS (FRAC_BITS)
  ) u_fabric (
      .clk(clk),
      .rst_n(rst_n),
      .mode(fabric_mode),
      .col_blocks_cfg(fabric_col_blocks),
      .reduce_rows(1'b0),
      .valid_in(fabric_valid_in),
      .A0_mat(fabric_A0_mat), .A1_mat(fabric_A1_mat),
      .A2_mat(fabric_A2_mat), .A3_mat(fabric_A3_mat),
      .B0_mat(fabric_B0_mat), .B1_mat(fabric_B1_mat),
      .B2_mat(fabric_B2_mat), .B3_mat(fabric_B3_mat),
      .reduced_vec(fabric_reduced_vec),
      .reduced_mat_0(fabric_reduced_mat_0),
      .reduced_mat_1(fabric_reduced_mat_1),
      .reduced_mat_2(fabric_reduced_mat_2),
      .reduced_mat_3(fabric_reduced_mat_3),
      .valid_reduced(fabric_valid_out)
  );

  slim_mac_mem_controller_combined_dp #(
      .TILE_SIZE (TILE_SIZE),
      .DATA_WIDTH(DATA_WIDTH),
      .ACC_WIDTH (ACC_WIDTH),
      .FRAC_BITS (FRAC_BITS),
      .N_BANK    (N_BANK),
      .WDEPTH    (WDEPTH),
      .WADDR_W   (WADDR_W),
      .DATA_W    (DATA_W),
      .XT_ADDR_W (XT_ADDR_W)
  ) u_ref (
      .clk(clk),
      .rst_n(rst_n),
      .s_axis_TVALID(s_axis_TVALID),
      .s_axis_TREADY(ref_s_axis_TREADY),
      .m_axis_TVALID(ref_m_axis_TVALID),
      .m_axis_TREADY(m_axis_TREADY),
      .reduced_trunc(ref_reduced_trunc),
      .xt_axis_TVALID(ref_xt_axis_TVALID),
      .xt_axis_TREADY(ref_xt_axis_TREADY),
      .xt_axis_TDATA(ref_xt_axis_TDATA)
  );

  reuse_ht_sram_sp #(
      .TILE_SIZE (TILE_SIZE),
      .DATA_WIDTH(DATA_WIDTH),
      .DEPTH     (64),
      .ADDR_W    (6)
  ) u_uact_sram (
      .clk(clk),
      .rst_n(rst_n),
      .wr_en(1'b0),
      .wr_addr('0),
      .wr_data('{default:'0}),
      .rd_en(u_vec_rd_en),
      .rd_addr(u_vec_rd_addr),
      .rd_data(u_vec_rd_data)
  );

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      dt_idx <= 0;
      xt_idx <= 0;
      dt_mismatch_count <= 0;
      xt_mismatch_count <= 0;
      ref_dt_mismatch_count <= 0;
      ref_xt_mismatch_count <= 0;
      cur_vs_ref_dt_mismatch_count <= 0;
      cur_vs_ref_xt_mismatch_count <= 0;
      dt_first_seen <= 1'b0;
      xt_first_seen <= 1'b0;
      ref_dt_first_seen <= 1'b0;
      ref_xt_first_seen <= 1'b0;
      cur_ref_dt_first_seen <= 1'b0;
      cur_ref_xt_first_seen <= 1'b0;
      dbg_cycle <= 0;
    end else begin
      if (dut.sched_busy) begin
        dbg_cycle <= dbg_cycle + 1;
        if (dbg_cycle < 8) begin
          $display("[%0t] DBG cyc=%0d data_cnt=%0d tile_cnt=%0d phase=%0d en=%b en_r=%b bank=%0d,%0d,%0d,%0d addr=%0d,%0d,%0d,%0d",
                   $time, dbg_cycle,
                   dut.data_cnt, dut.tile_cnt, dut.phase_reg,
                   dut.en_sel, dut.en_sel_reg,
                   dut.bank_sel[0], dut.bank_sel[1], dut.bank_sel[2], dut.bank_sel[3],
                   dut.addr_sel[0], dut.addr_sel[1], dut.addr_sel[2], dut.addr_sel[3]);
          $display("[%0t] DBG A0=%0d,%0d,%0d,%0d A1=%0d,%0d,%0d,%0d A2=%0d,%0d,%0d,%0d A3=%0d,%0d,%0d,%0d",
                   $time,
                   dut.A0_mat_reg[0][0], dut.A0_mat_reg[0][1], dut.A0_mat_reg[0][2], dut.A0_mat_reg[0][3],
                   dut.A1_mat_reg[0][0], dut.A1_mat_reg[0][1], dut.A1_mat_reg[0][2], dut.A1_mat_reg[0][3],
                   dut.A2_mat_reg[0][0], dut.A2_mat_reg[0][1], dut.A2_mat_reg[0][2], dut.A2_mat_reg[0][3],
                   dut.A3_mat_reg[0][0], dut.A3_mat_reg[0][1], dut.A3_mat_reg[0][2], dut.A3_mat_reg[0][3]);
          $display("[%0t] DBG B0=%0d,%0d,%0d,%0d B1=%0d,%0d,%0d,%0d B2=%0d,%0d,%0d,%0d B3=%0d,%0d,%0d,%0d",
                   $time,
                   dut.B0_mat_reg[0][0], dut.B0_mat_reg[0][1], dut.B0_mat_reg[0][2], dut.B0_mat_reg[0][3],
                   dut.B1_mat_reg[0][0], dut.B1_mat_reg[0][1], dut.B1_mat_reg[0][2], dut.B1_mat_reg[0][3],
                   dut.B2_mat_reg[0][0], dut.B2_mat_reg[0][1], dut.B2_mat_reg[0][2], dut.B2_mat_reg[0][3],
                   dut.B3_mat_reg[0][0], dut.B3_mat_reg[0][1], dut.B3_mat_reg[0][2], dut.B3_mat_reg[0][3]);
        end
      end else begin
        dbg_cycle <= 0;
      end
      if (m_axis_TVALID && m_axis_TREADY && dt_idx < U_DEPTH) begin
        dt_captured_mem[dt_idx] <= {
          reduced_trunc[3][15:0], reduced_trunc[2][15:0], reduced_trunc[1][15:0], reduced_trunc[0][15:0]
        };
        if (dt_idx < 8) begin
          $display("[%0t] DT idx=%0d got=%0d,%0d,%0d,%0d exp=%0d,%0d,%0d,%0d",
                   $time, dt_idx,
                   reduced_trunc[0], reduced_trunc[1], reduced_trunc[2], reduced_trunc[3],
                   unpack_lane64(dt_golden_mem[dt_idx], 0),
                   unpack_lane64(dt_golden_mem[dt_idx], 1),
                   unpack_lane64(dt_golden_mem[dt_idx], 2),
                   unpack_lane64(dt_golden_mem[dt_idx], 3));
        end
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          logic signed [DATA_WIDTH-1:0] got_v;
          logic signed [DATA_WIDTH-1:0] exp_v;
          got_v = reduced_trunc[lane];
          exp_v = unpack_lane64(dt_golden_mem[dt_idx], lane);
          if (got_v !== exp_v) begin
            dt_mismatch_count <= dt_mismatch_count + 1;
            if (!dt_first_seen) begin
              $error("[%0t] FIRST dt mismatch idx=%0d lane=%0d got=%0d exp=%0d", $time, dt_idx, lane, got_v, exp_v);
              dt_first_seen <= 1'b1;
            end
          end
          if (got_v !== ref_reduced_trunc[lane]) begin
            cur_vs_ref_dt_mismatch_count <= cur_vs_ref_dt_mismatch_count + 1;
            if (!cur_ref_dt_first_seen) begin
              $error("[%0t] FIRST cur-vs-ref dt mismatch idx=%0d lane=%0d cur=%0d ref=%0d", $time, dt_idx, lane, got_v, ref_reduced_trunc[lane]);
              cur_ref_dt_first_seen <= 1'b1;
            end
          end
          if (ref_reduced_trunc[lane] !== exp_v) begin
            ref_dt_mismatch_count <= ref_dt_mismatch_count + 1;
            if (!ref_dt_first_seen) begin
              $error("[%0t] FIRST ref dt mismatch idx=%0d lane=%0d got=%0d exp=%0d", $time, dt_idx, lane, ref_reduced_trunc[lane], exp_v);
              ref_dt_first_seen <= 1'b1;
            end
          end
        end
        dt_idx <= dt_idx + 1;
      end
      if (xt_axis_TVALID && xt_axis_TREADY && xt_idx < U_DEPTH) begin
        xt_captured_mem[xt_idx] <= {
          xt_axis_TDATA[3][15:0], xt_axis_TDATA[2][15:0], xt_axis_TDATA[1][15:0], xt_axis_TDATA[0][15:0]
        };
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          logic signed [DATA_WIDTH-1:0] got_v;
          logic signed [DATA_WIDTH-1:0] exp_v;
          got_v = xt_axis_TDATA[lane];
          exp_v = unpack_lane64(xt_golden_mem[xt_idx], lane);
          if (got_v !== exp_v) begin
            xt_mismatch_count <= xt_mismatch_count + 1;
            if (!xt_first_seen) begin
              $error("[%0t] FIRST xt mismatch idx=%0d lane=%0d got=%0d exp=%0d", $time, xt_idx, lane, got_v, exp_v);
              xt_first_seen <= 1'b1;
            end
          end
          if (got_v !== ref_xt_axis_TDATA[lane]) begin
            cur_vs_ref_xt_mismatch_count <= cur_vs_ref_xt_mismatch_count + 1;
            if (!cur_ref_xt_first_seen) begin
              $error("[%0t] FIRST cur-vs-ref xt mismatch idx=%0d lane=%0d cur=%0d ref=%0d", $time, xt_idx, lane, got_v, ref_xt_axis_TDATA[lane]);
              cur_ref_xt_first_seen <= 1'b1;
            end
          end
          if (ref_xt_axis_TDATA[lane] !== exp_v) begin
            ref_xt_mismatch_count <= ref_xt_mismatch_count + 1;
            if (!ref_xt_first_seen) begin
              $error("[%0t] FIRST ref xt mismatch idx=%0d lane=%0d got=%0d exp=%0d", $time, xt_idx, lane, ref_xt_axis_TDATA[lane], exp_v);
              ref_xt_first_seen <= 1'b1;
            end
          end
        end
        xt_idx <= xt_idx + 1;
      end
    end
  end

  initial begin
    load_case_files();
    s_axis_TVALID = 1'b0;
    m_axis_TREADY = 1'b1;
    xt_axis_TREADY = 1'b1;
    ref_xt_axis_TREADY = 1'b1;

    wait(rst_n);

    for (int addr = 0; addr < U_DEPTH; addr++) begin
      u_uact_sram.mem_sim[addr] = u_act_in_mem[addr];
    end
    for (int addr = 0; addr < WDEPTH; addr++) begin
      dut.u_wbuf.mem_sim[0][addr] = dt_bank0_mem[addr];
      dut.u_wbuf.mem_sim[1][addr] = dt_bank1_mem[addr];
      dut.u_wbuf.mem_sim[2][addr] = dt_bank2_mem[addr];
      dut.u_wbuf.mem_sim[3][addr] = dt_bank3_mem[addr];
      dut.u_wbuf.mem_sim[4][addr] = dt_bank4_mem[addr];
      dut.u_wbuf.mem_sim[5][addr] = dt_bank5_mem[addr];
      u_ref.u_wbuf.mem_sim[0][addr] = dt_bank0_mem[addr];
      u_ref.u_wbuf.mem_sim[1][addr] = dt_bank1_mem[addr];
      u_ref.u_wbuf.mem_sim[2][addr] = dt_bank2_mem[addr];
      u_ref.u_wbuf.mem_sim[3][addr] = dt_bank3_mem[addr];
      u_ref.u_wbuf.mem_sim[4][addr] = dt_bank4_mem[addr];
      u_ref.u_wbuf.mem_sim[5][addr] = dt_bank5_mem[addr];
    end
    for (int addr = 0; addr < U_DEPTH; addr++) begin
      u_ref.u_xt.mem_sim[addr] = u_act_in_mem[addr];
    end

    repeat (4) @(posedge clk);
    for (int t = 0; t < U_DEPTH; t++) begin
      @(posedge clk);
      s_axis_TVALID <= 1'b1;
      wait (s_axis_TREADY);
      @(posedge clk);
      s_axis_TVALID <= 1'b0;
      wait (!dut.sched_busy);
      repeat (2) @(posedge clk);
    end

    repeat (200) @(posedge clk);

    write_dump_mem(join_path(rtl_stage_dir, "dt_rtl_q88.mem"), dt_captured_mem, dt_idx);
    write_dump_mem(join_path(rtl_stage_dir, "xt_rtl_q88.mem"), xt_captured_mem, xt_idx);

    if (dt_idx != U_DEPTH)
      $fatal(1, "[%0t] dt stream collected=%0d expected=%0d", $time, dt_idx, U_DEPTH);
    if (xt_idx != U_DEPTH)
      $fatal(1, "[%0t] xt stream collected=%0d expected=%0d", $time, xt_idx, U_DEPTH);
    if (dt_mismatch_count != 0)
      $fatal(1, "[%0t] found %0d dt mismatches", $time, dt_mismatch_count);
    if (xt_mismatch_count != 0)
      $fatal(1, "[%0t] found %0d xt mismatches", $time, xt_mismatch_count);
    if (ref_dt_mismatch_count != 0)
      $fatal(1, "[%0t] reference controller found %0d dt mismatches vs golden", $time, ref_dt_mismatch_count);
    if (ref_xt_mismatch_count != 0)
      $fatal(1, "[%0t] reference controller found %0d xt mismatches vs golden", $time, ref_xt_mismatch_count);
    if (cur_vs_ref_dt_mismatch_count != 0)
      $fatal(1, "[%0t] reuse scheduler differs from reference controller on %0d dt lanes", $time, cur_vs_ref_dt_mismatch_count);
    if (cur_vs_ref_xt_mismatch_count != 0)
      $fatal(1, "[%0t] reuse scheduler differs from reference controller on %0d xt lanes", $time, cur_vs_ref_xt_mismatch_count);

    $display("[%0t] PASS reuse_ssm_dt_scheduler_hw_debug", $time);
    $finish;
  end
endmodule
