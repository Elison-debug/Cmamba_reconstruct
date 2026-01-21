`timescale 1ns/1ps
//======================================================================
// tb_top_mac_plus_bias_fifo_sigmoid_ew.sv
// Reference TB based on tb_top_mac_sigmoid_xt_join_fullpath
// Checks:
//   - lam/xt/join hold under backpressure
//   - join_lam matches LUT(fifo_out_vec), join_xt matches xt stream
//   - EW stage produces same tile count as join (basic liveness)
// Notes:
//   - Uses internal auto-increment state address in EW.
//   - Initializes wbuf/xt mem_sim like reference TB to avoid clamp.
//======================================================================
module tb_top_mac_plus_bias_fifo_sigmoid_ew;
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
  localparam int LUT_SIZE   = (1<<ADDR_BITS);
  localparam string LUT_FILE = "D:/Mamba/Cmamba_reconstruct/sigmoid_lut_q016_2048.hex";

  // Q8.8 clamp range [-4,+4)
  localparam logic signed [DATA_WIDTH-1:0] X_MIN = -16'sd1024;
  localparam logic signed [DATA_WIDTH-1:0] X_MAX =  16'sd1023;

  // clock/reset
  logic clk, rst_n;
  initial begin
    clk = 1'b0;
    forever #1 clk = ~clk; // 500MHz
  end
  initial begin
    rst_n = 1'b0;
    repeat (10) @(posedge clk);
    rst_n = 1'b1;
  end

  // VCD dump for offline debug
  initial begin
    $dumpfile("tb_top_mac_plus_bias_fifo_sigmoid_ew.vcd");
    $dumpvars(0, tb_top_mac_plus_bias_fifo_sigmoid_ew);
  end

  // DUT ports
  logic s_axis_TVALID;
  logic s_axis_TREADY;

  logic                         fifo_out_valid;
  logic                         fifo_out_ready;
  logic signed [DATA_WIDTH-1:0] fifo_out_vec [TILE_SIZE-1:0];

  logic                         lam_axis_TVALID;
  logic                         lam_axis_TREADY;
  logic [DATA_WIDTH-1:0]        lam_axis_TDATA [TILE_SIZE-1:0];

  logic                         xt_axis_TVALID;
  logic                         xt_axis_TREADY;
  logic signed [DATA_WIDTH-1:0] xt_axis_TDATA [TILE_SIZE-1:0];

  logic                         join_out_valid;
  logic                         join_out_ready;
  logic [DATA_WIDTH-1:0]        join_lam_vec [TILE_SIZE-1:0];
  logic [DATA_WIDTH-1:0]        join_xt_vec  [TILE_SIZE-1:0];

  logic                         s_out_valid;
  logic                         s_out_ready;
  logic signed [DATA_WIDTH-1:0] s_out_vec   [TILE_SIZE-1:0];

  // expose internal A_mat_reg for waveform alignment
  logic signed [DATA_WIDTH-1:0] A0_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0] A1_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0] A2_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0] A3_mat_reg [TILE_SIZE-1:0][TILE_SIZE-1:0];
  always_comb begin
    A0_mat_reg = dut.u_mac.A0_mat_reg;
    A1_mat_reg = dut.u_mac.A1_mat_reg;
    A2_mat_reg = dut.u_mac.A2_mat_reg;
    A3_mat_reg = dut.u_mac.A3_mat_reg;
  end

  // DUT
  top_mac_plus_bias_fifo_sigmoid_ew #(
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
      .S_ADDR_W   (6)
  ) dut (
      .clk             (clk),
      .rst_n           (rst_n),
      .s_axis_TVALID   (s_axis_TVALID),
      .s_axis_TREADY   (s_axis_TREADY),
      .fifo_out_valid  (fifo_out_valid),
      .fifo_out_ready  (fifo_out_ready),
      .fifo_out_vec    (fifo_out_vec),
      .lam_axis_TVALID (lam_axis_TVALID),
      .lam_axis_TREADY (lam_axis_TREADY),
      .lam_axis_TDATA  (lam_axis_TDATA),
      .xt_axis_TVALID  (xt_axis_TVALID),
      .xt_axis_TREADY  (xt_axis_TREADY),
      .xt_axis_TDATA   (xt_axis_TDATA),
      .join_out_valid  (join_out_valid),
      .join_out_ready  (join_out_ready),
      .join_lam_vec    (join_lam_vec),
      .join_xt_vec     (join_xt_vec),
      .s_out_valid     (s_out_valid),
      .s_out_ready     (s_out_ready),
      .s_out_vec       (s_out_vec)
  );

  // LUT model for expected lambda
  logic [DATA_WIDTH-1:0] tb_rom [0:LUT_SIZE-1];
  initial $readmemh(LUT_FILE, tb_rom);

  function automatic logic signed [DATA_WIDTH-1:0] clamp_q88(input logic signed [DATA_WIDTH-1:0] x);
    if (x < X_MIN)       clamp_q88 = X_MIN;
    else if (x > X_MAX)  clamp_q88 = X_MAX;
    else                 clamp_q88 = x;
  endfunction
  function automatic logic [ADDR_BITS-1:0] addr_from_x(input logic signed [DATA_WIDTH-1:0] x);
    logic signed [DATA_WIDTH-1:0] xc;
    logic signed [DATA_WIDTH-1:0] sum;
    begin
      xc  = clamp_q88(x);
      sum = xc + 16'sd1024;
      addr_from_x = sum[ADDR_BITS-1:0];
    end
  endfunction

  // handshakes
  wire fifo_fire = fifo_out_valid && fifo_out_ready;
  wire xt_fire   = xt_axis_TVALID && xt_axis_TREADY;
  wire join_fire = join_out_valid && join_out_ready;
  wire s_fire    = s_out_valid    && s_out_ready;

  // ready defaults (can be modified to add backpressure)
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      fifo_out_ready  <= 1'b1;
      lam_axis_TREADY <= 1'b1;
      xt_axis_TREADY  <= 1'b1;
      join_out_ready  <= 1'b1;
      s_out_ready     <= 1'b1;
    end else begin
      fifo_out_ready  <= 1'b1;
      lam_axis_TREADY <= 1'b1;
      xt_axis_TREADY  <= 1'b1;
      join_out_ready  <= 1'b1;
      s_out_ready     <= 1'b1;
    end
  end

  // hold checks (lam/xt/join)
  logic lam_hold_seen, xt_hold_seen, join_hold_seen;
  logic [DATA_WIDTH-1:0] lam_hold_vec [TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0] xt_hold_vec [TILE_SIZE-1:0];
  logic [DATA_WIDTH-1:0] join_hold_lam [TILE_SIZE-1:0];
  logic [DATA_WIDTH-1:0] join_hold_xt  [TILE_SIZE-1:0];
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      lam_hold_seen <= 1'b0;
      xt_hold_seen  <= 1'b0;
      join_hold_seen<= 1'b0;
      for (int i=0;i<TILE_SIZE;i++) begin
        lam_hold_vec[i]  <= '0;
        xt_hold_vec[i]   <= '0;
        join_hold_lam[i] <= '0;
        join_hold_xt[i]  <= '0;
      end
    end else begin
      if (lam_axis_TVALID && !lam_axis_TREADY) begin
        if (!lam_hold_seen) begin
          lam_hold_seen <= 1'b1;
          for (int i=0;i<TILE_SIZE;i++) lam_hold_vec[i] <= lam_axis_TDATA[i];
        end else begin
          for (int i=0;i<TILE_SIZE;i++)
            if (lam_axis_TDATA[i] !== lam_hold_vec[i])
              $error("[%0t] LAM hold violated lane%0d old=%h new=%h", $time, i, lam_hold_vec[i], lam_axis_TDATA[i]);
        end
      end else lam_hold_seen <= 1'b0;

      if (xt_axis_TVALID && !xt_axis_TREADY) begin
        if (!xt_hold_seen) begin
          xt_hold_seen <= 1'b1;
          for (int i=0;i<TILE_SIZE;i++) xt_hold_vec[i] <= xt_axis_TDATA[i];
        end else begin
          for (int i=0;i<TILE_SIZE;i++)
            if (xt_axis_TDATA[i] !== xt_hold_vec[i])
              $error("[%0t] XT hold violated lane%0d old=%0d new=%0d", $time, i, xt_hold_vec[i], xt_axis_TDATA[i]);
        end
      end else xt_hold_seen <= 1'b0;

      if (join_out_valid && !join_out_ready) begin
        if (!join_hold_seen) begin
          join_hold_seen <= 1'b1;
          for (int i=0;i<TILE_SIZE;i++) begin
            join_hold_lam[i] <= join_lam_vec[i];
            join_hold_xt[i]  <= join_xt_vec[i];
          end
        end else begin
          for (int i=0;i<TILE_SIZE;i++) begin
            if (join_lam_vec[i] !== join_hold_lam[i])
              $error("[%0t] JOIN(LAM) hold violated lane%0d old=%h new=%h", $time, i, join_hold_lam[i], join_lam_vec[i]);
            if (join_xt_vec[i] !== join_hold_xt[i])
              $error("[%0t] JOIN(XT) hold violated lane%0d old=%h new=%h", $time, i, join_hold_xt[i], join_xt_vec[i]);
          end
        end
      end else join_hold_seen <= 1'b0;
    end
  end

  // scoreboards
  logic [DATA_WIDTH-1:0] exp_lam_q[$][TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0] xt_q[$][TILE_SIZE-1:0];
  int got_join, got_s;

  task automatic enqueue_expected_lam_from_fifo(input logic signed [DATA_WIDTH-1:0] x_vec [TILE_SIZE-1:0]);
    logic [DATA_WIDTH-1:0] e [TILE_SIZE-1:0];
    begin
      for (int i=0;i<TILE_SIZE;i++) e[i] = tb_rom[ addr_from_x(x_vec[i]) ];
      exp_lam_q.push_back(e);
    end
  endtask
  task automatic enqueue_xt(input logic signed [DATA_WIDTH-1:0] x_vec [TILE_SIZE-1:0]);
    logic signed [DATA_WIDTH-1:0] t [TILE_SIZE-1:0];
    begin
      for (int i=0;i<TILE_SIZE;i++) t[i] = x_vec[i];
      xt_q.push_back(t);
    end
  endtask

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      got_join <= 0;
      got_s    <= 0;
      exp_lam_q.delete();
      xt_q.delete();
    end else begin
      if (fifo_fire) enqueue_expected_lam_from_fifo(fifo_out_vec);
      if (xt_fire)   enqueue_xt(xt_axis_TDATA);

      if (join_fire) begin
        got_join++;
        if (exp_lam_q.size()==0 || xt_q.size()==0) begin
          $error("[%0t] JOIN fire with empty queues", $time);
        end else begin
          logic [DATA_WIDTH-1:0] exp_lam [TILE_SIZE-1:0];
          logic signed [DATA_WIDTH-1:0] exp_xt [TILE_SIZE-1:0];
          exp_lam = exp_lam_q.pop_front();
          exp_xt  = xt_q.pop_front();
          for (int i=0;i<TILE_SIZE;i++) begin
            if (join_lam_vec[i] !== exp_lam[i])
              $error("[%0t] JOIN LAM mismatch lane%0d got=%h exp=%h", $time, i, join_lam_vec[i], exp_lam[i]);
            if ($signed(join_xt_vec[i]) !== exp_xt[i])
              $error("[%0t] JOIN XT mismatch lane%0d got=%0d exp=%0d", $time, i, $signed(join_xt_vec[i]), exp_xt[i]);
          end
        end
      end

      if (s_fire) begin
        got_s++;
        $display("[%0t] EW out #%0d vec=%0d,%0d,%0d,%0d",
                 $time, got_s,
                 $signed(s_out_vec[0]), $signed(s_out_vec[1]),
                 $signed(s_out_vec[2]), $signed(s_out_vec[3]));
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
      $display("[%0t] 🚀 Tile start accepted", $time);
    end
  endtask

  // init internal memories (if mem_sim exists) -- align with MAC standalone TB
  // debug copies for waveform (match standalone TB signals)
  logic [31:0] b, addr, w;
  logic [31:0] tile_id, element_id, value;
  logic [DATA_W-1:0] line;
  initial begin
    b = 0;
    addr = 0;
    w = 0;
    tile_id = 0;
    element_id = 0;
    value = 0;
    line = '0;
  end

  initial begin
    integer b_i;
    integer addr_i;
    integer w_i;
    integer tile_id_i;
    integer element_id_i;
    integer value_i;
    logic [DATA_W-1:0] line_i;
    #5;
    $display("[%0t] init WBUF/XT (if mem_sim exists)...", $time);
    // WBUF: fill with unique values like standalone MAC TB
    for (b_i = 0; b_i < N_BANK; b_i = b_i + 1) begin
      for (addr_i = 0; addr_i < WDEPTH; addr_i = addr_i + 1) begin
        line_i = '0;
        tile_id_i = b_i + addr_i * N_BANK;
        for (w_i = 0; w_i < 16; w_i = w_i + 1) begin
          element_id_i = tile_id_i * 16 + w_i;
          value_i = 1 + element_id_i;
          line_i[w_i*DATA_WIDTH +: DATA_WIDTH] = value_i[DATA_WIDTH-1:0];
          // drive debug signals for waveform
          b = b_i;
          addr = addr_i;
          w = w_i;
          tile_id = tile_id_i;
          element_id = element_id_i;
          value = value_i;
          line = line_i;
        end
        dut.u_mac.u_wbuf.mem_sim[b_i][addr_i] = line_i;
      end
    end
    // XT: scale up to Q8.8 so EW output is non-zero after >>8
    for (addr = 0; addr < 64; addr = addr + 1) begin
      dut.u_mac.u_xt.mem_sim[addr] = {
        16'((4*addr + 4) << 8),
        16'((4*addr + 3) << 8),
        16'((4*addr + 2) << 8),
        16'((4*addr + 1) << 8)
      };
    end
    $display("[%0t] init done", $time);
  end

  // run：对齐 standalone MAC TB 的节奏（3 tiles，每次间隔 30 拍）
  int n_tiles;
  initial begin
    s_axis_TVALID = 1'b0;
    n_tiles = 3;
    wait(rst_n);
    repeat(5) @(posedge clk);
    // align with standalone MAC TB timing
    @(posedge clk);
    repeat(1) @(posedge clk);

    for (int t=0; t<n_tiles; t++) begin
      send_tile_start();
      repeat(30) @(posedge clk); // tile_len ≈20, leave some gap
    end
    repeat(20) @(posedge clk);
    if (got_join < n_tiles)
      $error("[%0t] join received %0d tiles, expected >= %0d", $time, got_join, n_tiles);
    if (got_s < got_join)
      $error("[%0t] EW outputs %0d < joins %0d", $time, got_s, got_join);
    else
      $display("[%0t] ✅ PASS basic join/EW liveness got_join=%0d got_s=%0d", $time, got_join, got_s);
    $finish;
  end
endmodule
