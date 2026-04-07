`timescale 1ns/1ps
module tb_reuse_mamba_board_shell;
  `include "tb_hw_debug_case_path.svh"

  `ifndef HW_DEBUG_CASE_DIR
    `define HW_DEBUG_CASE_DIR ""
  `endif

  `define CORE_HIER dut.u_core.u_core
  `define WAIT_FLAG_TRUE(flag, tag, cycles) \
    begin : wait_``flag``__blk \
      int __budget; \
      __budget = (cycles); \
      while (!(flag) && (__budget > 0)) begin \
        @(posedge sys_clk); \
        __budget--; \
      end \
      if (!(flag)) $fatal(1, "[%0t] timeout waiting for %s", $time, (tag)); \
    end
  `define WAIT_INT_EQ(var, target, tag, cycles) \
    begin : wait_``var``__blk \
      int __budget; \
      __budget = (cycles); \
      while (((var) != (target)) && (__budget > 0)) begin \
        @(posedge sys_clk); \
        __budget--; \
      end \
      if ((var) != (target)) $fatal(1, "[%0t] timeout waiting for %s (got=%0d exp=%0d)", $time, (tag), (var), (target)); \
    end

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
  localparam int AXIL_ADDR_W = 12;

  localparam int H_DEPTH     = 32;
  localparam int U_DEPTH     = 64;
  localparam int Y_DEPTH     = 32;
  localparam int OUT_WDEPTH  = 512;

  localparam logic [AXIL_ADDR_W-1:0] REG_CTRL       = 12'h000;
  localparam logic [AXIL_ADDR_W-1:0] REG_STATUS     = 12'h004;
  localparam logic [AXIL_ADDR_W-1:0] REG_H_ROWS     = 12'h040;
  localparam logic [AXIL_ADDR_W-1:0] REG_Y_ROWS     = 12'h044;
  localparam logic [AXIL_ADDR_W-1:0] REG_IRQ_ENABLE = 12'h048;

  localparam logic [31:0] CTRL_START           = 32'h0000_0001;
  localparam logic [31:0] CTRL_BLOCK_AUTO_MODE = 32'h0000_0002;
  localparam logic [31:0] CTRL_PRELOAD_H_START = 32'h0000_0004;

  localparam int CLK_HALF = 5;

  logic sys_clk;
  logic ext_reset_n;
  logic irq;

  logic [AXIL_ADDR_W-1:0] s_axi_awaddr;
  logic                   s_axi_awvalid;
  logic                   s_axi_awready;
  logic [31:0]            s_axi_wdata;
  logic [3:0]             s_axi_wstrb;
  logic                   s_axi_wvalid;
  logic                   s_axi_wready;
  logic [1:0]             s_axi_bresp;
  logic                   s_axi_bvalid;
  logic                   s_axi_bready;
  logic [AXIL_ADDR_W-1:0] s_axi_araddr;
  logic                   s_axi_arvalid;
  logic                   s_axi_arready;
  logic [31:0]            s_axi_rdata;
  logic [1:0]             s_axi_rresp;
  logic                   s_axi_rvalid;
  logic                   s_axi_rready;

  logic                            s_axis_h_tvalid;
  logic                            s_axis_h_tready;
  logic [TILE_SIZE*DATA_WIDTH-1:0] s_axis_h_tdata;
  logic                            s_axis_h_tlast;

  logic                            s_axis_g_tvalid;
  logic                            s_axis_g_tready;
  logic [TILE_SIZE*DATA_WIDTH-1:0] s_axis_g_tdata;
  logic                            s_axis_g_tlast;

  logic                            m_axis_y_tvalid;
  logic                            m_axis_y_tready;
  logic [TILE_SIZE*DATA_WIDTH-1:0] m_axis_y_tdata;
  logic                            m_axis_y_tlast;

  string case_dir;
  string stage_dir;

  logic [7:0]   h_wr_addr_mem [0:H_DEPTH-1];
  logic [63:0]  h_wr_data_mem [0:H_DEPTH-1];
  logic [63:0]  u_golden_mem  [0:U_DEPTH-1];
  logic [63:0]  z_golden_mem  [0:U_DEPTH-1];
  logic [63:0]  dt_golden_mem [0:U_DEPTH-1];
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

  int y_stream_idx;
  int y_stream_errors;
  int irq_count;
  bit first_y_mismatch_seen;
  bit first_key_probe_done;

  logic preload_track_en;
  logic block_track_en;
  logic preload_track_en_d;
  logic block_track_en_d;
  logic preload_busy_seen;
  logic preload_done_seen;
  logic block_busy_seen;
  logic block_done_seen;
  logic inproj_done_seen;
  logic outproj_busy_seen;

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
        $fatal(1, "tb_reuse_mamba_board_shell requires +CASE_DIR=<path> or compile define HW_DEBUG_CASE_DIR");
      end
      stage_dir = join_path(case_dir, "stages/reuse_mamba_block_top");

      $readmemh(join_path(stage_dir, "h_wr_addr.mem"), h_wr_addr_mem);
      $readmemh(join_path(stage_dir, "h_wr_data_q88.mem"), h_wr_data_mem);
      $readmemh(join_path(stage_dir, "u_golden_q88.mem"), u_golden_mem);
      $readmemh(join_path(stage_dir, "z_golden_q88.mem"), z_golden_mem);
      $readmemh(join_path(stage_dir, "dt_golden_q88.mem"), dt_golden_mem);
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
      for (int addr = 0; addr < WDEPTH; addr++) begin
        `CORE_HIER.u_in_proj.u_w_sram.u_weight.mem_sim[0][addr] = inproj_bank0_mem[addr];
        `CORE_HIER.u_in_proj.u_w_sram.u_weight.mem_sim[1][addr] = inproj_bank1_mem[addr];
        `CORE_HIER.u_in_proj.u_w_sram.u_weight.mem_sim[2][addr] = inproj_bank2_mem[addr];
        `CORE_HIER.u_in_proj.u_w_sram.u_weight.mem_sim[3][addr] = inproj_bank3_mem[addr];
        `CORE_HIER.u_in_proj.u_w_sram.u_weight.mem_sim[4][addr] = inproj_bank4_mem[addr];
        `CORE_HIER.u_in_proj.u_w_sram.u_weight.mem_sim[5][addr] = inproj_bank5_mem[addr];

        `CORE_HIER.u_dt_sched.dt_wbuf_mem_sim[0][addr] = dt_bank0_mem[addr];
        `CORE_HIER.u_dt_sched.dt_wbuf_mem_sim[1][addr] = dt_bank1_mem[addr];
        `CORE_HIER.u_dt_sched.dt_wbuf_mem_sim[2][addr] = dt_bank2_mem[addr];
        `CORE_HIER.u_dt_sched.dt_wbuf_mem_sim[3][addr] = dt_bank3_mem[addr];
      end
      for (int addr = 0; addr < OUT_WDEPTH; addr++) begin
        `CORE_HIER.u_out_proj.u_w_sram.u_weight.mem_sim[0][addr] = outproj_bank0_mem[addr];
        `CORE_HIER.u_out_proj.u_w_sram.u_weight.mem_sim[1][addr] = outproj_bank1_mem[addr];
        `CORE_HIER.u_out_proj.u_w_sram.u_weight.mem_sim[2][addr] = outproj_bank2_mem[addr];
        `CORE_HIER.u_out_proj.u_w_sram.u_weight.mem_sim[3][addr] = outproj_bank3_mem[addr];
        `CORE_HIER.u_out_proj.u_w_sram.u_weight.mem_sim[4][addr] = outproj_bank4_mem[addr];
        `CORE_HIER.u_out_proj.u_w_sram.u_weight.mem_sim[5][addr] = outproj_bank5_mem[addr];
      end
      for (int addr = 0; addr < 128; addr++) `CORE_HIER.u_in_proj.u_scale_mem.mem[addr] = inproj_scale_mem[addr];
      for (int addr = 0; addr < 64; addr++)  `CORE_HIER.u_dt_sched.u_scale_mem.mem[addr] = dt_scale_mem[addr];
      for (int addr = 0; addr < 32; addr++)  `CORE_HIER.u_out_proj.u_scale_mem.mem[addr] = outproj_scale_mem[addr];
      $display("[%0t] initialized inproj/dt/outproj memories from exported hw_debug case", $time);
    end
  endtask

  task automatic axi_write32(input logic [AXIL_ADDR_W-1:0] addr, input logic [31:0] data);
    bit aw_done, w_done;
    begin
      aw_done = 1'b0;
      w_done  = 1'b0;
      @(posedge sys_clk);
      s_axi_awaddr  <= addr;
      s_axi_awvalid <= 1'b1;
      s_axi_wdata   <= data;
      s_axi_wstrb   <= 4'hF;
      s_axi_wvalid  <= 1'b1;
      s_axi_bready  <= 1'b1;
      while (!(aw_done && w_done)) begin
        @(posedge sys_clk);
        if (!aw_done && s_axi_awvalid && s_axi_awready) begin
          s_axi_awvalid <= 1'b0;
          aw_done = 1'b1;
        end
        if (!w_done && s_axi_wvalid && s_axi_wready) begin
          s_axi_wvalid <= 1'b0;
          w_done = 1'b1;
        end
      end
      s_axi_awaddr <= '0;
      s_axi_wdata  <= '0;
      s_axi_wstrb  <= '0;
      wait (s_axi_bvalid);
      if (s_axi_bresp !== 2'b00)
        $fatal(1, "[%0t] AXI write resp error addr=0x%0h resp=%0b", $time, addr, s_axi_bresp);
      @(posedge sys_clk);
      s_axi_bready <= 1'b0;
    end
  endtask

  task automatic axi_read32(input logic [AXIL_ADDR_W-1:0] addr, output logic [31:0] data);
    begin
      @(posedge sys_clk);
      s_axi_araddr  <= addr;
      s_axi_arvalid <= 1'b1;
      s_axi_rready  <= 1'b1;
      wait (s_axi_arready);
      @(posedge sys_clk);
      s_axi_arvalid <= 1'b0;
      s_axi_araddr  <= '0;
      wait (s_axi_rvalid);
      if (s_axi_rresp !== 2'b00)
        $fatal(1, "[%0t] AXI read resp error addr=0x%0h resp=%0b", $time, addr, s_axi_rresp);
      data = s_axi_rdata;
      @(posedge sys_clk);
      s_axi_rready <= 1'b0;
    end
  endtask

  task automatic send_h_stream_from_case();
    begin
      for (int idx = 0; idx < H_DEPTH; idx++) begin
        @(posedge sys_clk);
        s_axis_h_tvalid <= 1'b1;
        s_axis_h_tdata  <= h_wr_data_mem[idx];
        s_axis_h_tlast  <= (idx == H_DEPTH-1);
        while (!s_axis_h_tready) @(posedge sys_clk);
      end
      @(posedge sys_clk);
      s_axis_h_tvalid <= 1'b0;
      s_axis_h_tdata  <= '0;
      s_axis_h_tlast  <= 1'b0;
    end
  endtask

  task automatic send_g_zero_stream();
    begin
      for (int idx = 0; idx < U_DEPTH; idx++) begin
        @(posedge sys_clk);
        s_axis_g_tvalid <= 1'b1;
        s_axis_g_tdata  <= '0;
        s_axis_g_tlast  <= (idx == U_DEPTH-1);
        while (!s_axis_g_tready) @(posedge sys_clk);
      end
      @(posedge sys_clk);
      s_axis_g_tvalid <= 1'b0;
      s_axis_g_tdata  <= '0;
      s_axis_g_tlast  <= 1'b0;
    end
  endtask

  task automatic collect_and_check_y_stream();
    logic signed [DATA_WIDTH-1:0] got_v;
    logic signed [DATA_WIDTH-1:0] exp_v;
    begin
      y_stream_idx = 0;
      y_stream_errors = 0;
      first_y_mismatch_seen = 1'b0;
      while (y_stream_idx < Y_DEPTH) begin
        @(posedge sys_clk);
        if (m_axis_y_tvalid && m_axis_y_tready) begin
          for (int lane = 0; lane < TILE_SIZE; lane++) begin
            got_v = $signed(m_axis_y_tdata[lane*DATA_WIDTH +: DATA_WIDTH]);
            exp_v = unpack_lane64(y_golden_mem[y_stream_idx], lane);
            if (got_v !== exp_v) begin
              y_stream_errors++;
              if (!first_y_mismatch_seen) begin
                $error("[%0t] FIRST y stream mismatch idx=%0d lane=%0d got=%0d exp=%0d", $time, y_stream_idx, lane, got_v, exp_v);
                first_y_mismatch_seen = 1'b1;
              end
            end
          end
          y_stream_idx++;
        end
      end
      $display("[%0t] y stream collected=%0d errors=%0d", $time, y_stream_idx, y_stream_errors);
    end
  endtask

  task automatic key_internal_probe();
    begin
      $display("[%0t] key probe: preload_done=%0b inproj_done=%0b block_busy=%0b outproj_busy=%0b", $time, dut.preload_h_done, dut.inproj_done, dut.block_busy, dut.outproj_busy);
      $display("[%0t] h row0=%0d,%0d,%0d,%0d", $time,
               $signed(`CORE_HIER.u_in_proj.u_h_sram.mem_sim[0][0*DATA_WIDTH +: DATA_WIDTH]),
               $signed(`CORE_HIER.u_in_proj.u_h_sram.mem_sim[0][1*DATA_WIDTH +: DATA_WIDTH]),
               $signed(`CORE_HIER.u_in_proj.u_h_sram.mem_sim[0][2*DATA_WIDTH +: DATA_WIDTH]),
               $signed(`CORE_HIER.u_in_proj.u_h_sram.mem_sim[0][3*DATA_WIDTH +: DATA_WIDTH]));
      $display("[%0t] u row0=%0d,%0d,%0d,%0d | z row0=%0d,%0d,%0d,%0d", $time,
               $signed(`CORE_HIER.u_in_proj.u_u_sram.mem_sim[0][0*DATA_WIDTH +: DATA_WIDTH]),
               $signed(`CORE_HIER.u_in_proj.u_u_sram.mem_sim[0][1*DATA_WIDTH +: DATA_WIDTH]),
               $signed(`CORE_HIER.u_in_proj.u_u_sram.mem_sim[0][2*DATA_WIDTH +: DATA_WIDTH]),
               $signed(`CORE_HIER.u_in_proj.u_u_sram.mem_sim[0][3*DATA_WIDTH +: DATA_WIDTH]),
               $signed(`CORE_HIER.u_in_proj.u_z_sram.mem_sim[0][0*DATA_WIDTH +: DATA_WIDTH]),
               $signed(`CORE_HIER.u_in_proj.u_z_sram.mem_sim[0][1*DATA_WIDTH +: DATA_WIDTH]),
               $signed(`CORE_HIER.u_in_proj.u_z_sram.mem_sim[0][2*DATA_WIDTH +: DATA_WIDTH]),
               $signed(`CORE_HIER.u_in_proj.u_z_sram.mem_sim[0][3*DATA_WIDTH +: DATA_WIDTH]));
    end
  endtask

  task automatic compare_first_rows_against_golden();
    begin
      for (int lane = 0; lane < TILE_SIZE; lane++) begin
        if ($signed(`CORE_HIER.u_in_proj.u_h_sram.mem_sim[0][lane*DATA_WIDTH +: DATA_WIDTH]) !== unpack_lane64(h_wr_data_mem[0], lane))
          $fatal(1, "[%0t] h row0 mismatch lane=%0d", $time, lane);
        if ($signed(`CORE_HIER.u_in_proj.u_u_sram.mem_sim[0][lane*DATA_WIDTH +: DATA_WIDTH]) !== unpack_lane64(u_golden_mem[0], lane))
          $fatal(1, "[%0t] u row0 mismatch lane=%0d", $time, lane);
        if ($signed(`CORE_HIER.u_in_proj.u_z_sram.mem_sim[0][lane*DATA_WIDTH +: DATA_WIDTH]) !== unpack_lane64(z_golden_mem[0], lane))
          $fatal(1, "[%0t] z row0 mismatch lane=%0d", $time, lane);
        if ($signed(`CORE_HIER.u_out_proj.u_y_sram.mem_sim[0][lane*DATA_WIDTH +: DATA_WIDTH]) !== unpack_lane64(y_golden_mem[0], lane))
          $fatal(1, "[%0t] y row0 mismatch lane=%0d", $time, lane);
      end
    end
  endtask


  task automatic sanity_check_weight_mems();
    begin
      if (`CORE_HIER.u_in_proj.u_w_sram.u_weight.mem_sim[0][0] !== inproj_bank0_mem[0])
        $fatal(1, "[%0t] inproj bank0 addr0 mismatch after init", $time);
      if (`CORE_HIER.u_dt_sched.dt_wbuf_mem_sim[0][0] !== dt_bank0_mem[0])
        $fatal(1, "[%0t] dt bank0 addr0 mismatch after init", $time);
      if (`CORE_HIER.u_out_proj.u_w_sram.u_weight.mem_sim[0][0] !== outproj_bank0_mem[0])
        $fatal(1, "[%0t] outproj bank0 addr0 mismatch after init", $time);
      if (`CORE_HIER.u_in_proj.u_scale_mem.mem[0] !== inproj_scale_mem[0])
        $fatal(1, "[%0t] inproj scale addr0 mismatch after init", $time);
      if (`CORE_HIER.u_dt_sched.u_scale_mem.mem[0] !== dt_scale_mem[0])
        $fatal(1, "[%0t] dt scale addr0 mismatch after init", $time);
      if (`CORE_HIER.u_out_proj.u_scale_mem.mem[0] !== outproj_scale_mem[0])
        $fatal(1, "[%0t] outproj scale addr0 mismatch after init", $time);
      $display("[%0t] sanity mem check passed: inproj/dt/outproj bank0 addr0 + scale addr0", $time);
    end
  endtask

  task automatic wait_n_cycles(input int n);
    begin
      repeat (n) @(posedge sys_clk);
    end
  endtask

  initial begin
    sys_clk = 1'b0;
    forever #CLK_HALF sys_clk = ~sys_clk;
  end

  initial begin
    ext_reset_n = 1'b0;
    repeat (20) @(posedge sys_clk);
    ext_reset_n = 1'b1;
  end

  initial begin
    if ($test$plusargs("DUMP_VCD")) begin
      $dumpfile("tb_reuse_mamba_board_shell.vcd");
      $dumpvars(0, tb_reuse_mamba_board_shell);
    end
  end

  reuse_mamba_board_shell #(
      .TILE_SIZE   (TILE_SIZE), .DATA_WIDTH  (DATA_WIDTH), .ACC_WIDTH   (ACC_WIDTH),
      .FRAC_BITS   (FRAC_BITS), .N_BANK      (N_BANK),     .WDEPTH      (WDEPTH),
      .WADDR_W     (WADDR_W),   .DATA_W      (DATA_W),     .XT_ADDR_W   (XT_ADDR_W),
      .D           (D),         .PIPE_LAT    (PIPE_LAT),   .ADDR_BITS   (ADDR_BITS),
      .LUT_FILE    (LUT_FILE),  .S_ADDR_W    (S_ADDR_W),   .G_FRAC_BITS (G_FRAC_BITS),
      .AXIL_ADDR_W (AXIL_ADDR_W)
  ) dut (
      .sys_clk(sys_clk), .ext_reset_n(ext_reset_n), .irq(irq),
      .s_axi_awaddr(s_axi_awaddr), .s_axi_awvalid(s_axi_awvalid), .s_axi_awready(s_axi_awready),
      .s_axi_wdata(s_axi_wdata), .s_axi_wstrb(s_axi_wstrb), .s_axi_wvalid(s_axi_wvalid), .s_axi_wready(s_axi_wready),
      .s_axi_bresp(s_axi_bresp), .s_axi_bvalid(s_axi_bvalid), .s_axi_bready(s_axi_bready),
      .s_axi_araddr(s_axi_araddr), .s_axi_arvalid(s_axi_arvalid), .s_axi_arready(s_axi_arready),
      .s_axi_rdata(s_axi_rdata), .s_axi_rresp(s_axi_rresp), .s_axi_rvalid(s_axi_rvalid), .s_axi_rready(s_axi_rready),
      .s_axis_h_tvalid(s_axis_h_tvalid), .s_axis_h_tready(s_axis_h_tready), .s_axis_h_tdata(s_axis_h_tdata), .s_axis_h_tlast(s_axis_h_tlast),
      .s_axis_g_tvalid(s_axis_g_tvalid), .s_axis_g_tready(s_axis_g_tready), .s_axis_g_tdata(s_axis_g_tdata), .s_axis_g_tlast(s_axis_g_tlast),
      .m_axis_y_tvalid(m_axis_y_tvalid), .m_axis_y_tready(m_axis_y_tready), .m_axis_y_tdata(m_axis_y_tdata), .m_axis_y_tlast(m_axis_y_tlast)
  );

  always_ff @(posedge sys_clk or negedge ext_reset_n) begin
    if (!ext_reset_n) m_axis_y_tready <= 1'b1;
    else              m_axis_y_tready <= 1'b1;
  end

  always_ff @(posedge sys_clk or negedge ext_reset_n) begin
    if (!ext_reset_n) begin
      irq_count          <= 0;
      first_key_probe_done <= 1'b0;
      preload_track_en_d <= 1'b0;
      block_track_en_d   <= 1'b0;
      preload_busy_seen  <= 1'b0;
      preload_done_seen  <= 1'b0;
      block_busy_seen    <= 1'b0;
      block_done_seen    <= 1'b0;
      inproj_done_seen   <= 1'b0;
      outproj_busy_seen  <= 1'b0;
    end else begin
      preload_track_en_d <= preload_track_en;
      block_track_en_d   <= block_track_en;
      if (irq) irq_count <= irq_count + 1;

      if (preload_track_en && !preload_track_en_d) begin
        preload_busy_seen <= 1'b0;
        preload_done_seen <= 1'b0;
      end else if (preload_track_en) begin
        if (dut.preload_h_busy) preload_busy_seen <= 1'b1;
        if (dut.preload_h_done) preload_done_seen <= 1'b1;
      end

      if (block_track_en && !block_track_en_d) begin
        block_busy_seen   <= 1'b0;
        block_done_seen   <= 1'b0;
        inproj_done_seen  <= 1'b0;
        outproj_busy_seen <= 1'b0;
      end else if (block_track_en) begin
        if (dut.block_busy)   block_busy_seen   <= 1'b1;
        if (dut.block_done)   block_done_seen   <= 1'b1;
        if (dut.inproj_done)  inproj_done_seen  <= 1'b1;
        if (dut.outproj_busy) outproj_busy_seen <= 1'b1;
      end

      if (dut.preload_h_done && !first_key_probe_done) begin
        first_key_probe_done <= 1'b1;
        key_internal_probe();
      end

      if (m_axis_y_tvalid && m_axis_y_tready && y_stream_idx < 4) begin
        $display("[%0t] y beat%0d = %0d,%0d,%0d,%0d last=%0b",
                 $time, y_stream_idx,
                 $signed(m_axis_y_tdata[0*DATA_WIDTH +: DATA_WIDTH]),
                 $signed(m_axis_y_tdata[1*DATA_WIDTH +: DATA_WIDTH]),
                 $signed(m_axis_y_tdata[2*DATA_WIDTH +: DATA_WIDTH]),
                 $signed(m_axis_y_tdata[3*DATA_WIDTH +: DATA_WIDTH]),
                 m_axis_y_tlast);
      end
    end
  end

  initial begin
    logic [31:0] status_rd;

    s_axi_awaddr    = '0;
    s_axi_awvalid   = 1'b0;
    s_axi_wdata     = '0;
    s_axi_wstrb     = '0;
    s_axi_wvalid    = 1'b0;
    s_axi_bready    = 1'b0;
    s_axi_araddr    = '0;
    s_axi_arvalid   = 1'b0;
    s_axi_rready    = 1'b0;
    s_axis_h_tvalid = 1'b0;
    s_axis_h_tdata  = '0;
    s_axis_h_tlast  = 1'b0;
    s_axis_g_tvalid = 1'b0;
    s_axis_g_tdata  = '0;
    s_axis_g_tlast  = 1'b0;
    y_stream_idx          = 0;
    y_stream_errors       = 0;
    first_y_mismatch_seen = 1'b0;
    preload_track_en      = 1'b0;
    block_track_en        = 1'b0;

    load_case_files();
    wait (ext_reset_n);
    repeat (8) @(posedge sys_clk);
    init_weight_mems_from_case();

    axi_write32(REG_H_ROWS, H_DEPTH);
    axi_write32(REG_Y_ROWS, Y_DEPTH);
    axi_write32(REG_IRQ_ENABLE, 32'h0000_0007);

    axi_read32(REG_STATUS, status_rd);
    $display("[%0t] STATUS(before preload)=0x%08h", $time, status_rd);

    $display("[%0t] launch preload_h via AXI-Lite + s_axis_h", $time);
    preload_track_en = 1'b1;
    fork
      begin axi_write32(REG_CTRL, CTRL_PRELOAD_H_START); end
      begin send_h_stream_from_case(); end
    join
    `WAIT_FLAG_TRUE(preload_done_seen, "preload_done_seen", 5000)
    preload_track_en = 1'b0;
    axi_read32(REG_STATUS, status_rd);
    $display("[%0t] preload_h finished (busy_seen=%0b done_seen=%0b status=0x%08h)", $time, preload_busy_seen, preload_done_seen, status_rd);

    $display("[%0t] launch block core via AXI-Lite + s_axis_g, collect m_axis_y", $time);
    block_track_en = 1'b1;
    fork
      begin collect_and_check_y_stream(); end
      begin send_g_zero_stream(); end
      begin axi_write32(REG_CTRL, CTRL_START); end
    join_none

        `WAIT_FLAG_TRUE(block_done_seen,  "block_done_seen",  20000)
    block_track_en = 1'b0;
    axi_read32(REG_STATUS, status_rd);
    $display("[%0t] block finished (busy_seen=%0b done_seen=%0b inproj_done_seen=%0b outproj_busy_seen=%0b status=0x%08h)",
             $time, block_busy_seen, block_done_seen, inproj_done_seen, outproj_busy_seen, status_rd);

    `WAIT_INT_EQ(y_stream_idx, Y_DEPTH, "y_stream_idx==Y_DEPTH", 20000)
    wait_n_cycles(20);
    compare_first_rows_against_golden();

    if (y_stream_errors != 0)
      $fatal(1, "[%0t] y stream mismatches=%0d", $time, y_stream_errors);
    if (irq_count == 0)
      $display("[%0t] note: irq not observed, but functional path completed", $time);

    $display("[%0t] PASS tb_reuse_mamba_board_shell", $time);
    $finish;
  end
endmodule
