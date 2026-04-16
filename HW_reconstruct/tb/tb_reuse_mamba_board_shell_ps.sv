`timescale 1ns/1ps

`ifndef HW_DEBUG_CASE_DIR
  `define HW_DEBUG_CASE_DIR "E:/course/smamba/HW_reconstruct/hw_debug/cases/test_case3_smoke"
`endif

module tb_reuse_mamba_board_shell_ps;
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
  localparam int Y_DEPTH     = 32;

  localparam logic [AXIL_ADDR_W-1:0] REG_CTRL       = 12'h000;
  localparam logic [AXIL_ADDR_W-1:0] REG_STATUS     = 12'h004;
  localparam logic [AXIL_ADDR_W-1:0] REG_H_ROWS     = 12'h040;
  localparam logic [AXIL_ADDR_W-1:0] REG_Y_ROWS     = 12'h044;
  localparam logic [AXIL_ADDR_W-1:0] REG_IRQ_ENABLE = 12'h048;

  // CTRL bits
  // [0] start processing
  // [1] inverted block_auto_mode shadow inside CSR logic; keep 0 for current auto mode
  // [2] preload_h start
  // [3] soft reset pulse
  localparam logic [31:0] CTRL_START           = 32'h0000_0001;
  localparam logic [31:0] CTRL_PRELOAD_H_START = 32'h0000_0004;

  // STATUS bits
  // [0] block_busy
  // [1] block_done
  // [2] preload_h_busy
  // [3] preload_h_done
  // [4] dma_error
  localparam logic [31:0] STATUS_BLOCK_BUSY    = 32'h0000_0001;
  localparam logic [31:0] STATUS_BLOCK_DONE    = 32'h0000_0002;
  localparam logic [31:0] STATUS_PRELOAD_BUSY  = 32'h0000_0004;
  localparam logic [31:0] STATUS_PRELOAD_DONE  = 32'h0000_0008;
  localparam logic [31:0] STATUS_DMA_ERROR     = 32'h0000_0010;

  // Timing model for post-synthesis functional simulation:
  // - sys_clk: 100 MHz, 10 ns period.
  // - AXI4-Lite: single outstanding transaction, AW/W may handshake independently,
  //   response is waited for before issuing the next write/read.
  // - AXIS h-stream: TVALID is held until TREADY, TLAST asserted on final beat.
  // - AXIS g-stream is tied inactive because current board shell data path ignores
  //   external g input during block_auto_mode bring-up.

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
  logic [63:0]  y_golden_mem  [0:Y_DEPTH-1];

  int y_stream_idx;
  int y_stream_errors;
  bit first_y_mismatch_seen;

  logic preload_irq_seen;
  logic block_irq_seen;
  logic track_preload;
  logic track_block;
  bit first_dt_x_seen;
  bit first_ssm_x_seen;
  bit first_pcap_x_seen;
  bit first_y_x_seen;
  int dt_dbg_count;
  int ssm_dbg_count;
  int pcap_dbg_count;
  int y_dbg_count;
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
      $readmemh(join_path(stage_dir, "y_golden_q88.mem"), y_golden_mem);
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
      if (s_axi_bresp !== 2'b00) $fatal(1, "AXI write resp error addr=0x%0h", addr);
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
      while (!(s_axi_arvalid && s_axi_arready)) @(posedge sys_clk);
      @(posedge sys_clk);
      s_axi_arvalid <= 1'b0;
      s_axi_araddr  <= '0;
      wait (s_axi_rvalid);
      data = s_axi_rdata;
      if (s_axi_rresp !== 2'b00) $fatal(1, "AXI read resp error addr=0x%0h", addr);
      @(posedge sys_clk);
      s_axi_rready <= 1'b0;
    end
  endtask

  task automatic wait_status_mask(
      input logic [31:0] mask,
      input logic [31:0] value,
      input int max_cycles,
      input string tag
  );
    logic [31:0] status_v;
    int cyc;
    begin
      cyc = 0;
      status_v = '0;
      while (cyc < max_cycles) begin
        axi_read32(REG_STATUS, status_v);
        if ((status_v & mask) == value) begin
          if (status_v & STATUS_DMA_ERROR)
            $fatal(1, "[%0t] dma_error observed while waiting for %s", $time, tag);
          return;
        end
        cyc = cyc + 1;
        repeat (2) @(posedge sys_clk);
      end
      $fatal(1, "[%0t] timeout waiting for %s, last status=0x%08h", $time, tag, status_v);
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
                $error("[%0t] FIRST y mismatch idx=%0d lane=%0d got=%0d exp=%0d",
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
      preload_irq_seen <= 1'b0;
      block_irq_seen   <= 1'b0;
      first_dt_x_seen  <= 1'b0;
      first_ssm_x_seen <= 1'b0;
      first_pcap_x_seen<= 1'b0;
      first_y_x_seen   <= 1'b0;
      dt_dbg_count      <= 0;
      ssm_dbg_count     <= 0;
      pcap_dbg_count    <= 0;
      y_dbg_count       <= 0;
    end else begin
      //  if (dut.u_core.u_core.u_dt_sched.dt_mac_valid && dt_dbg_count < 4) begin
      //    $display("[%0t] DEBUG dt_mac[%0d] = {%0h,%0h,%0h,%0h}", $time, dt_dbg_count, dut.u_core.u_core.dt_mac_vec[0], dut.u_core.u_core.dt_mac_vec[1], dut.u_core.u_core.dt_mac_vec[2], dut.u_core.u_core.dt_mac_vec[3]);
      //    dt_dbg_count <= dt_dbg_count + 1;
      //  end
//       if (dut.u_core.u_core.ssm_p_valid && ssm_dbg_count < 4) begin
//         $display("[%0t] DEBUG ssm_p[%0d] = {%0h,%0h,%0h,%0h}", $time, ssm_dbg_count, dut.u_core.u_core.ssm_p_data[0], dut.u_core.u_core.ssm_p_data[1], dut.u_core.u_core.ssm_p_data[2], dut.u_core.u_core.ssm_p_data[3]);
//         ssm_dbg_count <= ssm_dbg_count + 1;
//       end
//       if (dut.u_core.u_core.p_wr_en && pcap_dbg_count < 4) begin
//         $display("[%0t] DEBUG pcap[%0d] = {%0h,%0h,%0h,%0h}", $time, pcap_dbg_count, dut.u_core.u_core.p_wr_data[0], dut.u_core.u_core.p_wr_data[1], dut.u_core.u_core.p_wr_data[2], dut.u_core.u_core.p_wr_data[3]);
//         pcap_dbg_count <= pcap_dbg_count + 1;
//       end
//       if (m_axis_y_tvalid && m_axis_y_tready && y_dbg_count < 4) begin
//         $display("[%0t] DEBUG y[%0d] = {%0h,%0h,%0h,%0h}", $time, y_dbg_count, m_axis_y_tdata[15:0], m_axis_y_tdata[31:16], m_axis_y_tdata[47:32], m_axis_y_tdata[63:48]);
//         y_dbg_count <= y_dbg_count + 1;
//       end
      if (track_preload && irq)
        preload_irq_seen <= 1'b1;
      if (track_block && irq)
        block_irq_seen <= 1'b1;
      if (!track_preload)
        preload_irq_seen <= 1'b0;
      if (!track_block)
        block_irq_seen <= 1'b0;
    end
  end


  initial begin : watchdog
    logic [31:0] status_v;
    wait (ext_reset_n == 1'b1);
    #300000ns;
    axi_read32(REG_STATUS, status_v);
    $fatal(1, "[%0t] watchdog timeout status=0x%08h y_stream_idx=%0d irq=%0b", $time, status_v, y_stream_idx, irq);
  end

  initial begin
    ext_reset_n = 1'b0;
    s_axi_awaddr = '0; s_axi_awvalid = 1'b0; s_axi_wdata='0; s_axi_wstrb='0; s_axi_wvalid=1'b0;
    s_axi_bready = 1'b0; s_axi_araddr='0; s_axi_arvalid=1'b0; s_axi_rready=1'b0;
    s_axis_h_tvalid=1'b0; s_axis_h_tdata='0; s_axis_h_tlast=1'b0;
    s_axis_g_tvalid=1'b0; s_axis_g_tdata='0; s_axis_g_tlast=1'b0;
    m_axis_y_tready=1'b1;
    y_stream_idx = 0; y_stream_errors = 0; first_y_mismatch_seen = 1'b0;
    track_preload = 1'b0; track_block = 1'b0;

    load_case_files();
    repeat (20) @(posedge sys_clk);
    ext_reset_n = 1'b1;
    repeat (10) @(posedge sys_clk);

    axi_write32(REG_H_ROWS, H_DEPTH);
    axi_write32(REG_Y_ROWS, Y_DEPTH);
    axi_write32(REG_IRQ_ENABLE, 32'h3);

    $display("[%0t] PS-TB launch preload_h via AXI-Lite + s_axis_h", $time);
    track_preload = 1'b1;
    fork
      send_h_stream_from_case();
      axi_write32(REG_CTRL, CTRL_PRELOAD_H_START);
    join
    wait (preload_irq_seen == 1'b1);
    track_preload = 1'b0;
    $display("[%0t] PS-TB preload_h finished", $time);

    repeat (8) @(posedge sys_clk);
    $display("[%0t] PS-TB launch block start", $time);
    track_block = 1'b1;
    axi_write32(REG_CTRL, CTRL_START);
    wait_status_mask(STATUS_BLOCK_BUSY, STATUS_BLOCK_BUSY, 10000, "block_busy");
    $display("[%0t] PS-TB block running", $time);

    fork
      collect_and_check_y_stream();
    join_none

    wait_status_mask(STATUS_BLOCK_BUSY, 32'h0, 200000, "block_idle");
    track_block = 1'b0;
    wait (y_stream_idx == Y_DEPTH);

    repeat (20) @(posedge sys_clk);
    if (y_stream_errors != 0)
      $fatal(1, "[%0t] found %0d y stream mismatches", $time, y_stream_errors);
    $display("[%0t] PASS shell post-synth test", $time);
    $finish;
  end
endmodule



