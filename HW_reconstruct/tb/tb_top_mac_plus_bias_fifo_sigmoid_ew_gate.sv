`timescale 1ns/1ps
//======================================================================
// tb_top_mac_plus_bias_fifo_sigmoid_ew_gate.sv
// Smoke test for full path with output gate:
//   mac -> bias -> sigmoid -> join -> EW update -> gate (s ⊙ g)
// - g is generated from s_out fire (valid & ready) with a small delay
// - y is checked against queued s (g=1.0)
// - dumps VCD
//======================================================================
module tb_top_mac_plus_bias_fifo_sigmoid_ew_gate;
  localparam int TILE_SIZE  = 4;
  localparam int DATA_WIDTH = 16;
  localparam int ACC_WIDTH  = 32;
  localparam int FRAC_BITS  = 8;

  localparam int N_BANK     = 6;
  localparam int WDEPTH     = 683;
  localparam int WADDR_W    = $clog2(WDEPTH);
  localparam int DATA_W     = 256;
  localparam int XT_ADDR_W  = 6;

  localparam int D          = 256;
  localparam int PIPE_LAT   = 4;

  localparam int ADDR_BITS  = 11;
  localparam string LUT_FILE = "D:/Mamba/Cmamba_reconstruct/sigmoid_lut_q016_2048.hex";
  localparam int S_ADDR_W   = 6;
  localparam int G_FRAC_BITS = 8;

  // clock/reset
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

  // VCD dump
  initial begin
    $dumpfile("tb_top_mac_plus_bias_fifo_sigmoid_ew_gate.vcd");
    $dumpvars(0, tb_top_mac_plus_bias_fifo_sigmoid_ew_gate);
  end

  // DUT ports
  logic s_axis_TVALID;
  logic s_axis_TREADY;

  logic                         g_axis_TVALID;
  logic                         g_axis_TREADY;
  logic signed [DATA_WIDTH-1:0] g_axis_TDATA [TILE_SIZE-1:0];

  logic                         y_axis_TVALID;
  logic                         y_axis_TREADY;
  logic signed [DATA_WIDTH-1:0] y_axis_TDATA [TILE_SIZE-1:0];

  top_mac_plus_bias_fifo_sigmoid_ew_gate #(
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
      .s_axis_TVALID (s_axis_TVALID),
      .s_axis_TREADY (s_axis_TREADY),
      .g_axis_TVALID (g_axis_TVALID),
      .g_axis_TREADY (g_axis_TREADY),
      .g_axis_TDATA  (g_axis_TDATA),
      .y_axis_TVALID (y_axis_TVALID),
      .y_axis_TREADY (y_axis_TREADY),
      .y_axis_TDATA  (y_axis_TDATA)
  );

  // packed debug vectors for VCD (arrays aren't dumped reliably)
  logic signed [TILE_SIZE*DATA_WIDTH-1:0] dbg_s_out;
  logic signed [TILE_SIZE*DATA_WIDTH-1:0] dbg_g_in;
  logic signed [TILE_SIZE*DATA_WIDTH-1:0] dbg_y_out;
  logic [TILE_SIZE*DATA_WIDTH-1:0]        dbg_fifo2sig;
  logic [TILE_SIZE*DATA_WIDTH-1:0]        dbg_sigmoid;
  logic [TILE_SIZE*DATA_WIDTH-1:0]        dbg_lam;
  logic [TILE_SIZE*DATA_WIDTH-1:0]        dbg_join_lam;
  logic [TILE_SIZE*DATA_WIDTH-1:0]        dbg_join_xt;

  always_comb begin
    for (int i=0; i<TILE_SIZE; i++) begin
      dbg_s_out[i*DATA_WIDTH +: DATA_WIDTH]    = dut.s_out_vec[i];
      dbg_g_in[i*DATA_WIDTH +: DATA_WIDTH]     = g_axis_TDATA[i];
      dbg_y_out[i*DATA_WIDTH +: DATA_WIDTH]    = y_axis_TDATA[i];
      dbg_fifo2sig[i*DATA_WIDTH +: DATA_WIDTH] = dut.fifo2sig_vec[i];
      dbg_sigmoid[i*DATA_WIDTH +: DATA_WIDTH]  = dut.sigmoid_out_vec[i];
      dbg_lam[i*DATA_WIDTH +: DATA_WIDTH]      = dut.lam_vec[i];
      dbg_join_lam[i*DATA_WIDTH +: DATA_WIDTH] = dut.join_lam_vec[i];
      dbg_join_xt[i*DATA_WIDTH +: DATA_WIDTH]  = dut.join_xt_vec[i];
    end
  end

  // default ready
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      y_axis_TREADY <= 1'b1;
    end else begin
      y_axis_TREADY <= 1'b1;
    end
  end

  // ------------------------------------------------------------
  // Init internal memories
  // ------------------------------------------------------------
  initial begin
    integer b_i;
    integer addr_i;
    integer w_i;
    integer tile_id_i;
    integer element_id_i;
    integer value_i;
    logic [DATA_W-1:0] line_i;
    #5;
    $display("[%0t] init WBUF/XT...", $time);
    for (b_i = 0; b_i < N_BANK; b_i = b_i + 1) begin
      for (addr_i = 0; addr_i < WDEPTH; addr_i = addr_i + 1) begin
        line_i = '0;
        tile_id_i = b_i + addr_i * N_BANK;
        for (w_i = 0; w_i < 16; w_i = w_i + 1) begin
          element_id_i = tile_id_i * 16 + w_i;
          value_i = 1 + element_id_i;
          line_i[w_i*DATA_WIDTH +: DATA_WIDTH] = value_i[DATA_WIDTH-1:0];
        end
        dut.u_mac.u_wbuf.mem_sim[b_i][addr_i] = line_i;
      end
    end
    for (int addr = 0; addr < 64; addr = addr + 1) begin
      dut.u_mac.u_xt.mem_sim[addr] = {
        16'((4*addr + 4) << 8),
        16'((4*addr + 3) << 8),
        16'((4*addr + 2) << 8),
        16'((4*addr + 1) << 8)
      };
    end
    $display("[%0t] init done", $time);
  end

  // ------------------------------------------------------------
  // gate generator: align g to s with fixed delay, only 3 tokens
  // ------------------------------------------------------------
  function automatic logic signed [DATA_WIDTH-1:0] g_pattern(input int tok, input int lane);
    logic signed [DATA_WIDTH-1:0] base;
    begin
      base = 16'sh0100 + (tok[7:0] <<< 4); // Q8.8: 1.0 + token*0.0625
      g_pattern = base + (lane <<< 3);     // lane skew
    end
  endfunction

  localparam int G_DELAY = 2; // delay >=1 to ensure s_buffer write completed
  logic g_pipe_valid [0:G_DELAY-1];
  logic signed [DATA_WIDTH-1:0] g_pipe_data [0:G_DELAY-1][TILE_SIZE-1:0];
  int g_enq_cnt;
  int g_sent_cnt;

  wire g_pipe_out_ready = g_axis_TREADY || !g_pipe_valid[G_DELAY-1];
  wire s_fire = dut.s_out_valid && dut.s_out_ready;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      g_enq_cnt <= 0;
      g_sent_cnt <= 0;
      for (int i=0; i<G_DELAY; i++) begin
        g_pipe_valid[i] <= 1'b0;
        for (int j=0; j<TILE_SIZE; j++) g_pipe_data[i][j] <= '0;
      end
    end else begin
      if (g_pipe_out_ready) begin
        for (int i=G_DELAY-1; i>0; i--) begin
          g_pipe_valid[i] <= g_pipe_valid[i-1];
          for (int j=0; j<TILE_SIZE; j++) g_pipe_data[i][j] <= g_pipe_data[i-1][j];
        end
        g_pipe_valid[0] <= 1'b0;
        if (s_fire && g_enq_cnt < 3) begin
          g_pipe_valid[0] <= 1'b1;
          for (int j=0; j<TILE_SIZE; j++) g_pipe_data[0][j] <= g_pattern(g_enq_cnt, j);
          g_enq_cnt <= g_enq_cnt + 1;
        end
      end

      if (g_axis_TVALID && g_axis_TREADY)
        g_sent_cnt <= g_sent_cnt + 1;
    end
  end

  assign g_axis_TVALID = g_pipe_valid[G_DELAY-1] && (g_sent_cnt < 3);
  always_comb begin
    for (int i=0; i<TILE_SIZE; i++) begin
      if (g_axis_TVALID)
        g_axis_TDATA[i] = g_pipe_data[G_DELAY-1][i];
      else
        g_axis_TDATA[i] = '0;
    end
  end

  // ------------------------------------------------------------
  // Scoreboard: y should equal s_out ⊙ g (Q8.8)
  // ------------------------------------------------------------
  logic signed [DATA_WIDTH-1:0] s_q[$][TILE_SIZE-1:0];
  int got_s, got_y;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      got_s <= 0;
      got_y <= 0;
      s_q.delete();
    end else begin
      if (s_fire) begin
        logic signed [DATA_WIDTH-1:0] s_tmp [TILE_SIZE-1:0];
        for (int i=0; i<TILE_SIZE; i++) s_tmp[i] = dut.s_out_vec[i];
        s_q.push_back(s_tmp);
        got_s++;
      end
      if (y_axis_TVALID && y_axis_TREADY) begin
        got_y++;
        if (s_q.size() == 0) begin
          $error("[%0t] y fired with empty s queue", $time);
        end else begin
          logic signed [DATA_WIDTH-1:0] exp_s [TILE_SIZE-1:0];
          exp_s = s_q.pop_front();
          for (int i=0; i<TILE_SIZE; i++) begin
            logic signed [31:0] prod;
            logic signed [DATA_WIDTH-1:0] exp_y;
            prod = exp_s[i] * g_pattern(got_y-1, i);
            exp_y = prod[FRAC_BITS +: DATA_WIDTH];
            if (y_axis_TDATA[i] !== exp_y)
              $error("[%0t] y mismatch lane%0d got=%0d exp=%0d",
                     $time, i, $signed(y_axis_TDATA[i]), $signed(exp_y));
          end
        end
      end
    end
  end

  // stimulus: tile start pulses
  task automatic send_tile_start();
    begin
      @(posedge clk);
      s_axis_TVALID <= 1'b1;
      while (!(s_axis_TVALID && s_axis_TREADY)) @(posedge clk);
      @(posedge clk);
      s_axis_TVALID <= 1'b0;
      $display("[%0t] Tile start accepted", $time);
    end
  endtask

  int n_tiles;
  initial begin
    s_axis_TVALID = 1'b0;
    n_tiles = 3;
    wait(rst_n);
    repeat(5) @(posedge clk);
    for (int t=0; t<n_tiles; t++) begin
      send_tile_start();
      repeat(30) @(posedge clk);
    end
    repeat(50) @(posedge clk);
    if (got_y == 0)
      $error("[%0t] no y output observed", $time);
    else
      $display("[%0t] PASS basic gate outputs got_s=%0d got_y=%0d", $time, got_s, got_y);
    $finish;
  end
endmodule
