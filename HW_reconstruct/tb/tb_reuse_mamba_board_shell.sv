`timescale 1ns/1ps

`ifndef HW_DEBUG_CASE_DIR
  `define HW_DEBUG_CASE_DIR "../../../../../hw_debug/cases/test_case3_smoke"
`endif

`define CORE_HIER dut.u_core.u_core

module tb_reuse_mamba_board_shell;
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
  localparam int S_ADDR_W    = 6;
  localparam int G_FRAC_BITS = 8;
  localparam int AXIL_ADDR_W = 12;
  localparam int G_DEPTH     = 64;
  localparam int G_ADDR_W    = $clog2(G_DEPTH);

  localparam int H_DEPTH     = 32;
  localparam int U_DEPTH     = 64;
  localparam int Y_DEPTH     = 32;
  localparam int OUT_WDEPTH  = 512;

  localparam logic [AXIL_ADDR_W-1:0] REG_CTRL       = 12'h000;
  localparam logic [AXIL_ADDR_W-1:0] REG_STATUS     = 12'h004;
  localparam logic [AXIL_ADDR_W-1:0] REG_H_ROWS     = 12'h040;
  localparam logic [AXIL_ADDR_W-1:0] REG_Y_ROWS     = 12'h044;
  localparam logic [AXIL_ADDR_W-1:0] REG_IRQ_ENABLE = 12'h048;


  // REG_CTRL bits definitions bit 0: start block processing, bit 1: block auto mode enable, bit 2: preload h start, bit 3: soft_reset_pulse, bit4-31: reserved
  localparam logic [31:0] CTRL_START           = 32'h0000_0001;//32'h0000_0000+4'b0001;
  localparam logic [31:0] CTRL_BLOCK_AUTO_MODE = 32'h0000_0002;//32'h0000_0000+4'b0010;(auto mode 0 means start next block immediately when current block is done, without waiting for another CTRL_START)
  localparam logic [31:0] CTRL_PRELOAD_H_START = 32'h0000_0004;//32'h0000_0000+4'b0100;

  logic sys_clk; initial sys_clk = 1'b0; always #5 sys_clk = ~sys_clk;
  logic ext_reset_n;
  logic irq;

  logic [AXIL_ADDR_W-1:0] s_axi_awaddr;
  logic s_axi_awvalid;
  logic s_axi_awready;
  logic [31:0] s_axi_wdata;
  logic [3:0] s_axi_wstrb;
  logic s_axi_wvalid;
  logic s_axi_wready;
  logic [1:0] s_axi_bresp;
  logic s_axi_bvalid;
  logic s_axi_bready;
  logic [AXIL_ADDR_W-1:0] s_axi_araddr;
  logic s_axi_arvalid;
  logic s_axi_arready;
  logic [31:0] s_axi_rdata;
  logic [1:0] s_axi_rresp;
  logic s_axi_rvalid;
  logic s_axi_rready;

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

  logic [63:0]  h_wr_data_mem [0:H_DEPTH-1];
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
  bit first_y_mismatch_seen;

  // one-driver sticky flags
  logic preload_h_done_seen;
  logic preload_g_done_seen;
  logic block_done_seen;
  logic block_busy_seen;
  logic track_preload_h, track_preload_g, track_block;
  logic track_preload_h_d, track_preload_g_d, track_block_d;

  function automatic string join_path(input string a, input string b);
    join_path = {a, "/", b};
  endfunction

  function automatic logic signed [DATA_WIDTH-1:0] unpack_lane64(input logic [63:0] packed_word, input int lane);
    unpack_lane64 = $signed(packed_word[lane*DATA_WIDTH +: DATA_WIDTH]);
  endfunction

  task automatic load_case_files();
    string case_dir_macro;
    begin
      case_dir_macro = `HW_DEBUG_CASE_DIR;
      if (!$value$plusargs("CASE_DIR=%s", case_dir)) case_dir = case_dir_macro;
      if (case_dir.len() == 0) $fatal(1, "need +CASE_DIR or HW_DEBUG_CASE_DIR");
      stage_dir = join_path(case_dir, "stages/reuse_mamba_block_top");
      $readmemh(join_path(stage_dir, "h_wr_data_q88.mem"), h_wr_data_mem);
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
      for (int addr = 0; addr < 64;  addr++) `CORE_HIER.u_dt_sched.u_scale_mem.mem[addr] = dt_scale_mem[addr];
      for (int addr = 0; addr < 32;  addr++) `CORE_HIER.u_out_proj.u_scale_mem.mem[addr] = outproj_scale_mem[addr];
      $display("[%0t] initialized inproj/dt/outproj memories from exported hw_debug case", $time);
    end
  endtask

  task automatic sanity_check_weight_mems();
    begin
      if (`CORE_HIER.u_in_proj.u_w_sram.u_weight.mem_sim[0][0] !== inproj_bank0_mem[0])
        $fatal(1, "inproj bank0 addr0 mismatch");
      if (`CORE_HIER.u_dt_sched.dt_wbuf_mem_sim[0][0] !== dt_bank0_mem[0])
        $fatal(1, "dt bank0 addr0 mismatch");
      if (`CORE_HIER.u_out_proj.u_w_sram.u_weight.mem_sim[0][0] !== outproj_bank0_mem[0])
        $fatal(1, "outproj bank0 addr0 mismatch");
      if (`CORE_HIER.u_in_proj.u_scale_mem.mem[0] !== inproj_scale_mem[0])
        $fatal(1, "inproj scale addr0 mismatch");
      if (`CORE_HIER.u_dt_sched.u_scale_mem.mem[0] !== dt_scale_mem[0])
        $fatal(1, "dt scale addr0 mismatch");
      if (`CORE_HIER.u_out_proj.u_scale_mem.mem[0] !== outproj_scale_mem[0])
        $fatal(1, "outproj scale addr0 mismatch");
      $display("[%0t] sanity mem check passed", $time);
    end
  endtask

  task automatic axi_write32(input logic [AXIL_ADDR_W-1:0] addr, input logic [31:0] data);
    bit aw_done, w_done;
    begin
      aw_done = 1'b0; w_done = 1'b0;
      @(posedge sys_clk);
      s_axi_awaddr  <= addr;
      s_axi_awvalid <= 1'b1;
      s_axi_wdata   <= data;
      s_axi_wstrb   <= 4'hF;
      s_axi_wvalid  <= 1'b1;
      s_axi_bready  <= 1'b1;
      while (!(aw_done && w_done)) begin
        @(posedge sys_clk);
        if (!aw_done && s_axi_awvalid && s_axi_awready) begin s_axi_awvalid <= 1'b0; aw_done = 1'b1; end
        if (!w_done  && s_axi_wvalid  && s_axi_wready ) begin s_axi_wvalid  <= 1'b0; w_done  = 1'b1; end
      end
      s_axi_awaddr <= '0; s_axi_wdata <= '0; s_axi_wstrb <= '0;
      wait (s_axi_bvalid);
      if (s_axi_bresp !== 2'b00) $fatal(1, "AXI write resp error addr=0x%0h", addr);
      @(posedge sys_clk); s_axi_bready <= 1'b0;
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
      s_axis_h_tvalid <= 1'b0; s_axis_h_tdata <= '0; s_axis_h_tlast <= 1'b0;
    end
  endtask

  task automatic send_g_zero_stream_once();
    begin
      for (int idx = 0; idx < U_DEPTH; idx++) begin
        @(posedge sys_clk);
        s_axis_g_tvalid <= 1'b1;
        s_axis_g_tdata  <= '0;
        s_axis_g_tlast  <= (idx == U_DEPTH-1);
        while (!s_axis_g_tready) @(posedge sys_clk);
      end
      @(posedge sys_clk);
      s_axis_g_tvalid <= 1'b0; s_axis_g_tdata <= '0; s_axis_g_tlast <= 1'b0;
    end
  endtask

  task automatic collect_and_check_y_stream();
    logic signed [DATA_WIDTH-1:0] got_v, exp_v;
    logic [63:0] exp_pack;
    begin
      while (y_stream_idx < Y_DEPTH) begin
        @(posedge sys_clk);
        if (m_axis_y_tvalid && m_axis_y_tready) begin
          exp_pack = y_golden_mem[y_stream_idx];
          for (int lane = 0; lane < TILE_SIZE; lane++) begin
            got_v = $signed(m_axis_y_tdata[lane*DATA_WIDTH +: DATA_WIDTH]);
            exp_v = unpack_lane64(exp_pack, lane);
            if (got_v !== exp_v) begin
              y_stream_errors++;
              if (!first_y_mismatch_seen) begin
                $error("[%0t] FIRST y stream mismatch idx=%0d lane=%0d got=%0d exp=%0d",
                       $time, y_stream_idx, lane, got_v, exp_v);
                first_y_mismatch_seen = 1'b1;
              end
            end
          end
          y_stream_idx++;
        end
      end
    end
  endtask

  `define WAIT_TRUE(expr, tag, cycles) \
    begin \
      int __cyc; \
      __cyc = 0; \
      while (!(expr) && (__cyc < (cycles))) begin \
        @(posedge sys_clk); \
        __cyc = __cyc + 1; \
      end \
      if (!(expr)) $fatal(1, "[%0t] timeout waiting for %s", $time, tag); \
    end

  reuse_mamba_board_shell #(
      .TILE_SIZE(TILE_SIZE), .DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH), .FRAC_BITS(FRAC_BITS),
      .N_BANK(N_BANK), .WDEPTH(WDEPTH), .WADDR_W(WADDR_W), .DATA_W(DATA_W), .XT_ADDR_W(XT_ADDR_W),
      .D(D), .PIPE_LAT(PIPE_LAT), .ADDR_BITS(ADDR_BITS), .S_ADDR_W(S_ADDR_W), .G_FRAC_BITS(G_FRAC_BITS),
      .AXIL_ADDR_W(AXIL_ADDR_W), .G_DEPTH(G_DEPTH), .G_ADDR_W(G_ADDR_W)
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
    if (!ext_reset_n) begin
      preload_h_done_seen <= 1'b0;
      preload_g_done_seen <= 1'b0;
      block_done_seen     <= 1'b0;
      block_busy_seen     <= 1'b0;
      track_preload_h_d   <= 1'b0;
      track_preload_g_d   <= 1'b0;
      track_block_d       <= 1'b0;
    end else begin
      track_preload_h_d <= track_preload_h;
      track_preload_g_d <= track_preload_g;
      track_block_d     <= track_block;
      if (track_preload_h && !track_preload_h_d) preload_h_done_seen <= 1'b0;
      if (track_preload_g && !track_preload_g_d) preload_g_done_seen <= 1'b0;
      if (track_block     && !track_block_d) begin block_done_seen <= 1'b0; block_busy_seen <= 1'b0; end
      if (track_preload_h && dut.preload_h_done) preload_h_done_seen <= 1'b1;
      //if (track_preload_g && dut.preload_g_done) preload_g_done_seen <= 1'b1;
      if (track_block && dut.block_busy) block_busy_seen <= 1'b1;
      if (track_block && dut.block_done) block_done_seen <= 1'b1;
    end
  end

  initial begin
    ext_reset_n = 1'b0;
    s_axi_awaddr = '0; s_axi_awvalid = 1'b0; s_axi_wdata='0; s_axi_wstrb='0; s_axi_wvalid=1'b0;
    s_axi_bready = 1'b0; s_axi_araddr='0; s_axi_arvalid=1'b0; s_axi_rready=1'b0;
    s_axis_h_tvalid=1'b0; s_axis_h_tdata='0; s_axis_h_tlast=1'b0;
    s_axis_g_tvalid=1'b0; s_axis_g_tdata='0; s_axis_g_tlast=1'b0;
    m_axis_y_tready=1'b1;
    y_stream_idx = 0; y_stream_errors = 0; first_y_mismatch_seen = 1'b0;
    track_preload_h = 1'b0; track_preload_g = 1'b0; track_block = 1'b0;

    load_case_files();
    repeat (20) @(posedge sys_clk);
    ext_reset_n = 1'b1;
    repeat (5) @(posedge sys_clk);

    init_weight_mems_from_case();
    sanity_check_weight_mems();

    axi_write32(REG_H_ROWS, H_DEPTH);
    axi_write32(REG_Y_ROWS, Y_DEPTH);
    axi_write32(REG_IRQ_ENABLE, 32'h0);

    $display("[%0t] launch preload_h via AXI-Lite + s_axis_h", $time);
    track_preload_h = 1'b1;
    fork
      send_h_stream_from_case();
      axi_write32(REG_CTRL, CTRL_PRELOAD_H_START);
    join
    `WAIT_TRUE(preload_h_done_seen, "preload_h_done_seen", 10000);
    track_preload_h = 1'b0;
    $display("[%0t] preload_h finished", $time);

    repeat (8) @(posedge sys_clk);
    $display("[%0t] launch block start", $time);
    //track_preload_g = 1'b1;
    track_block     = 1'b1;
    // fork
    //   send_g_zero_stream_once();
         axi_write32(REG_CTRL, CTRL_START);  
    // join
    // `WAIT_TRUE(preload_g_done_seen, "preload_g_done_seen", 10000);
    `WAIT_TRUE(block_busy_seen, "block_busy_seen", 10000);
    $display("[%0t] block running", $time);

    fork
      collect_and_check_y_stream();
    join_none

    `WAIT_TRUE(block_done_seen, "block_done_seen", 50000);
    `WAIT_TRUE((y_stream_idx == Y_DEPTH), "y_stream_idx==Y_DEPTH", 50000);
    track_preload_g = 1'b0;
    track_block     = 1'b0;

    repeat (20) @(posedge sys_clk);
    if (y_stream_errors != 0)
      $fatal(1, "[%0t] found %0d y stream mismatches", $time, y_stream_errors);
    $display("[%0t] PASS shell minimal test", $time);
    $finish;
  end
endmodule
