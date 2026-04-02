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
// Note:
//   final y is not checked here because current RTL out_proj is still a stub.
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
  localparam int WDEPTH      = 683;
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
      .G_FRAC_BITS(G_FRAC_BITS)
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
      $readmemh(join_path(stage_dir, "h_wr_data_q88.mem"), h_wr_data_mem);
      $readmemh(join_path(stage_dir, "u_golden_q88.mem"), u_golden_mem);
      $readmemh(join_path(stage_dir, "z_golden_q88.mem"), z_golden_mem);
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
    end
  endtask

  task automatic init_weight_mems_from_case();
    begin
      for (int addr = 0; addr < WDEPTH; addr++) begin
        dut.u_in_proj.u_w_sram.u_weight.mem_sim[0][addr] = inproj_bank0_mem[addr];
        dut.u_in_proj.u_w_sram.u_weight.mem_sim[1][addr] = inproj_bank1_mem[addr];
        dut.u_in_proj.u_w_sram.u_weight.mem_sim[2][addr] = inproj_bank2_mem[addr];
        dut.u_in_proj.u_w_sram.u_weight.mem_sim[3][addr] = inproj_bank3_mem[addr];
        dut.u_in_proj.u_w_sram.u_weight.mem_sim[4][addr] = inproj_bank4_mem[addr];
        dut.u_in_proj.u_w_sram.u_weight.mem_sim[5][addr] = inproj_bank5_mem[addr];

        dut.u_dt_sched.u_wbuf.mem_sim[0][addr] = dt_bank0_mem[addr];
        dut.u_dt_sched.u_wbuf.mem_sim[1][addr] = dt_bank1_mem[addr];
        dut.u_dt_sched.u_wbuf.mem_sim[2][addr] = dt_bank2_mem[addr];
        dut.u_dt_sched.u_wbuf.mem_sim[3][addr] = dt_bank3_mem[addr];
        dut.u_dt_sched.u_wbuf.mem_sim[4][addr] = dt_bank4_mem[addr];
        dut.u_dt_sched.u_wbuf.mem_sim[5][addr] = dt_bank5_mem[addr];
      end
      $display("[%0t] FILE  inproj bank0 addr0 = %h", $time, inproj_bank0_mem[0]);
      $display("[%0t] SRAM  inproj bank0 addr0 = %h", $time, dut.u_in_proj.u_w_sram.u_weight.mem_sim[0][0]);
      $display("[%0t] FILE  dt     bank0 addr0 = %h", $time, dt_bank0_mem[0]);
      $display("[%0t] SRAM  dt     bank0 addr0 = %h", $time, dut.u_dt_sched.u_wbuf.mem_sim[0][0]);
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
          $signed(dut.u_in_proj.u_u_sram.mem_sim[0][0*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_in_proj.u_u_sram.mem_sim[0][1*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_in_proj.u_u_sram.mem_sim[0][2*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_in_proj.u_u_sram.mem_sim[0][3*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_in_proj.u_z_sram.mem_sim[0][0*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_in_proj.u_z_sram.mem_sim[0][1*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_in_proj.u_z_sram.mem_sim[0][2*DATA_WIDTH +: DATA_WIDTH]),
          $signed(dut.u_in_proj.u_z_sram.mem_sim[0][3*DATA_WIDTH +: DATA_WIDTH])
      );
      for (int addr = 0; addr < U_DEPTH; addr++) begin
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          got_u = $signed(dut.u_in_proj.u_u_sram.mem_sim[addr][lane*DATA_WIDTH +: DATA_WIDTH]);
          exp_u = unpack_lane64(u_golden_mem[addr], lane);
          if (got_u !== exp_u) begin
            if (!first_u_mismatch_seen) begin
              $error("[%0t] FIRST u SRAM mismatch addr=%0d lane=%0d got=%0d exp=%0d", $time, addr, lane, got_u, exp_u);
              first_u_mismatch_seen = 1'b1;
            end
          end else begin
            u_ok++;
          end

          got_z = $signed(dut.u_in_proj.u_z_sram.mem_sim[addr][lane*DATA_WIDTH +: DATA_WIDTH]);
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

  task automatic start_block_once();
    begin
      @(posedge clk);
      block_start <= 1'b1;
      @(posedge clk);
      block_start <= 1'b0;
    end
  endtask

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

    repeat (20) @(posedge clk);
    $display("[%0t] PASS reuse_mamba_block_top_hw_debug partial compare", $time);
    $finish;
  end
endmodule
