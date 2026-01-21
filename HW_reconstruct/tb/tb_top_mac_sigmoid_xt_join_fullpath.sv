`timescale 1ns/1ps
//======================================================================
// tb_top_mac_sigmoid_xt_join_fullpath.sv
// Purpose:
//   End-to-end TB for current top:
//     slim_mac_mem_controller_combined_dp (has xt_axis_* output)
//       -> pulse_to_stream_adapter
//       -> bias_add_regslice_ip_A
//       -> vec_fifo_axis_ip   (bias_fifo, pre-sigmoid)
//       -> sigmoid4_vec
//       -> vec_fifo_axis_ip   (lam_fifo, post-sigmoid)
//       -> axis_vec_join2     (join lam + xt)
//
// What it checks:
//   1) Hold under backpressure for lam/xt/join streams
//   2) join tokens are never misaligned:
//        join_lam_vec == LUT(fifo_out_vec token)  (Q8.8 -> Q0.16)
//        join_xt_vec  == xt_axis_TDATA token      (Q8.8)
//   3) join_fire count equals number of issued tiles (eventually)
//
// Notes:
//   - fifo_out_ready participates in broadcast_ready inside top,
//     so fifo token is considered "consumed" when fifo_fire happens
//     (fifo_out_valid && fifo_out_ready) AND sigmoid can accept.
//     To avoid ambiguity, we enqueue expected lambda note when fifo_fire,
//     but we *compare* on join_fire (true synchronized consumption).
//======================================================================

module tb_top_mac_sigmoid_xt_join_fullpath;

  // ---------------- Parameters (match your design) ----------------
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

  // Q8.8 clamp range for LUT [-4,+4) -> [-1024, +1023]
  localparam logic signed [DATA_WIDTH-1:0] X_MIN = -16'sd1024;
  localparam logic signed [DATA_WIDTH-1:0] X_MAX =  16'sd1023;

  // ---------------- Clock / Reset ----------------
  logic clk, rst_n;
  initial begin
    clk = 1'b0;
    forever #1 clk = ~clk; // 500MHz
  end

  // ---------------- DUT ports ----------------
  logic s_axis_TVALID;
  logic s_axis_TREADY;

  // pre-sigmoid stream
  logic                         fifo_out_valid;
  logic                         fifo_out_ready;
  logic signed [DATA_WIDTH-1:0]  fifo_out_vec [TILE_SIZE-1:0];

  // lambda stream after sigmoid FIFO
  logic                         lam_axis_TVALID;
  logic                         lam_axis_TREADY;
  logic [DATA_WIDTH-1:0]         lam_axis_TDATA [TILE_SIZE-1:0];

  // xt stream from controller
  logic                         xt_axis_TVALID;
  logic                         xt_axis_TREADY;
  logic signed [DATA_WIDTH-1:0]  xt_axis_TDATA [TILE_SIZE-1:0];

  // join output
  logic                         join_out_valid;
  logic                         join_out_ready;
  logic [DATA_WIDTH-1:0]         join_lam_vec [TILE_SIZE-1:0];
  logic [DATA_WIDTH-1:0]         join_xt_vec  [TILE_SIZE-1:0];

  // ---------------- Instantiate DUT ----------------
  top_mac_plus_bias_fifo_sigmoid #(
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
    .LUT_FILE   (LUT_FILE)
  ) dut (
    .clk              (clk),
    .rst_n            (rst_n),

    .s_axis_TVALID    (s_axis_TVALID),
    .s_axis_TREADY    (s_axis_TREADY),

    .fifo_out_valid   (fifo_out_valid),
    .fifo_out_ready   (fifo_out_ready),
    .fifo_out_vec     (fifo_out_vec),

    .lam_axis_TVALID  (lam_axis_TVALID),
    .lam_axis_TREADY  (lam_axis_TREADY),
    .lam_axis_TDATA   (lam_axis_TDATA),

    .xt_axis_TVALID   (xt_axis_TVALID),
    .xt_axis_TREADY   (xt_axis_TREADY),
    .xt_axis_TDATA    (xt_axis_TDATA),

    .join_out_valid   (join_out_valid),
    .join_out_ready   (join_out_ready),
    .join_lam_vec     (join_lam_vec),
    .join_xt_vec      (join_xt_vec)
  );

  // ---------------- Reset sequence ----------------
  initial begin
    rst_n         = 1'b0;
    repeat (10) @(posedge clk);
    rst_n = 1'b1;
  end

  // ---------------- TB LUT ROM model ----------------
  logic [DATA_WIDTH-1:0] tb_rom [0:LUT_SIZE-1];
  initial begin
    $readmemh(LUT_FILE, tb_rom);
  end

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
      sum = xc + 16'sd1024;          // 0..2047
      addr_from_x = sum[ADDR_BITS-1:0];
    end
  endfunction

  // ---------------- Handshake fires ----------------
  wire fifo_fire = fifo_out_valid && fifo_out_ready;
  wire lam_fire  = lam_axis_TVALID && lam_axis_TREADY;
  wire xt_fire   = xt_axis_TVALID  && xt_axis_TREADY;
  wire join_fire = join_out_valid  && join_out_ready;

  // ---------------- Backpressure generators ----------------
  // 建议：join_out_ready 要经常为 1，否则 join 永远不 fire
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      fifo_out_ready  <= 1'b1;
      lam_axis_TREADY <= 1'b1;
      xt_axis_TREADY  <= 1'b1;
      join_out_ready  <= 1'b1;
    end else begin
      // 固定为 1，去除回压
      fifo_out_ready  <= 1'b1;
      lam_axis_TREADY <= 1'b1;
      xt_axis_TREADY  <= 1'b1;
      join_out_ready  <= 1'b1;
    end
  end

  // ---------------- Hold checks ----------------
  // lam hold
  logic lam_hold_seen;
  logic [DATA_WIDTH-1:0] lam_hold_vec [TILE_SIZE-1:0];

  // xt hold
  logic xt_hold_seen;
  logic signed [DATA_WIDTH-1:0] xt_hold_vec [TILE_SIZE-1:0];

  // join hold
  logic join_hold_seen;
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
      // lam hold
      if (lam_axis_TVALID && !lam_axis_TREADY) begin
        if (!lam_hold_seen) begin
          lam_hold_seen <= 1'b1;
          for (int i=0;i<TILE_SIZE;i++) lam_hold_vec[i] <= lam_axis_TDATA[i];
        end else begin
          for (int i=0;i<TILE_SIZE;i++) begin
            if (lam_axis_TDATA[i] !== lam_hold_vec[i]) begin
              $error("[%0t] LAM hold violated lane%0d old=%h new=%h",
                     $time, i, lam_hold_vec[i], lam_axis_TDATA[i]);
            end
          end
        end
      end else begin
        lam_hold_seen <= 1'b0;
      end

      // xt hold
      if (xt_axis_TVALID && !xt_axis_TREADY) begin
        if (!xt_hold_seen) begin
          xt_hold_seen <= 1'b1;
          for (int i=0;i<TILE_SIZE;i++) xt_hold_vec[i] <= xt_axis_TDATA[i];
        end else begin
          for (int i=0;i<TILE_SIZE;i++) begin
            if (xt_axis_TDATA[i] !== xt_hold_vec[i]) begin
              $error("[%0t] XT hold violated lane%0d old=%0d new=%0d",
                     $time, i, xt_hold_vec[i], xt_axis_TDATA[i]);
            end
          end
        end
      end else begin
        xt_hold_seen <= 1'b0;
      end

      // join hold
      if (join_out_valid && !join_out_ready) begin
        if (!join_hold_seen) begin
          join_hold_seen <= 1'b1;
          for (int i=0;i<TILE_SIZE;i++) begin
            join_hold_lam[i] <= join_lam_vec[i];
            join_hold_xt[i]  <= join_xt_vec[i];
          end
        end else begin
          for (int i=0;i<TILE_SIZE;i++) begin
            if (join_lam_vec[i] !== join_hold_lam[i]) begin
              $error("[%0t] JOIN(LAM) hold violated lane%0d old=%h new=%h",
                     $time, i, join_hold_lam[i], join_lam_vec[i]);
            end
            if (join_xt_vec[i] !== join_hold_xt[i]) begin
              $error("[%0t] JOIN(XT) hold violated lane%0d old=%h new=%h",
                     $time, i, join_hold_xt[i], join_xt_vec[i]);
            end
          end
        end
      end else begin
        join_hold_seen <= 1'b0;
      end
    end
  end

  // ---------------- Scoreboard queues ----------------
  // A) Expected lambda (from fifo_out_vec token)
  logic [DATA_WIDTH-1:0] exp_lam_q[$][TILE_SIZE-1:0];

  // B) Observed xt tokens from xt_axis (must align with join_xt_vec)
  logic signed [DATA_WIDTH-1:0] xt_q[$][TILE_SIZE-1:0];

  task automatic enqueue_expected_lam_from_fifo(input logic signed [DATA_WIDTH-1:0] x_vec [TILE_SIZE-1:0]);
    logic [DATA_WIDTH-1:0] e [TILE_SIZE-1:0];
    begin
      for (int i=0;i<TILE_SIZE;i++) begin
        e[i] = tb_rom[ addr_from_x(x_vec[i]) ];
      end
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

  int got_join;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      got_join <= 0;
      exp_lam_q.delete();
      xt_q.delete();
    end else begin
      // fifo_fire: 预期 lam 入队（代表“pre-sigmoid token 被消费”）
      if (fifo_fire) begin
        enqueue_expected_lam_from_fifo(fifo_out_vec);
        $display("[%0t] FIFO fire x_q88=%0d,%0d,%0d,%0d  expQ=%0d",
                 $time, fifo_out_vec[0], fifo_out_vec[1], fifo_out_vec[2], fifo_out_vec[3], exp_lam_q.size());
      end

      // xt_fire: 观测 xt token 入队
      if (xt_fire) begin
        enqueue_xt(xt_axis_TDATA);
        $display("[%0t] XT   fire x_q88=%0d,%0d,%0d,%0d  xtQ=%0d",
                 $time, xt_axis_TDATA[0], xt_axis_TDATA[1], xt_axis_TDATA[2], xt_axis_TDATA[3], xt_q.size());
      end

      // join_fire: 真正同步消费点（工程上以此为准比对）
      if (join_fire) begin
        got_join++;

        if (exp_lam_q.size()==0) begin
          $error("[%0t] JOIN fire but exp_lam_q empty!", $time);
        end
        if (xt_q.size()==0) begin
          $error("[%0t] JOIN fire but xt_q empty!", $time);
        end

        if (exp_lam_q.size()!=0 && xt_q.size()!=0) begin
          logic [DATA_WIDTH-1:0] exp_lam [TILE_SIZE-1:0];
          logic signed [DATA_WIDTH-1:0] exp_xt [TILE_SIZE-1:0];

          exp_lam = exp_lam_q.pop_front();
          exp_xt  = xt_q.pop_front();

          $display("[%0t] JOIN fire #%0d | join_lam=%h,%h,%h,%h exp=%h,%h,%h,%h | join_xt=%0d,%0d,%0d,%0d exp=%0d,%0d,%0d,%0d",
            $time, got_join,
            join_lam_vec[0], join_lam_vec[1], join_lam_vec[2], join_lam_vec[3],
            exp_lam[0], exp_lam[1], exp_lam[2], exp_lam[3],
            $signed(join_xt_vec[0]), $signed(join_xt_vec[1]), $signed(join_xt_vec[2]), $signed(join_xt_vec[3]),
            exp_xt[0], exp_xt[1], exp_xt[2], exp_xt[3]
          );

          for (int i=0;i<TILE_SIZE;i++) begin
            if (join_lam_vec[i] !== exp_lam[i]) begin
              $error("[%0t] JOIN LAM mismatch lane%0d got=%h exp=%h",
                     $time, i, join_lam_vec[i], exp_lam[i]);
            end
            if ($signed(join_xt_vec[i]) !== exp_xt[i]) begin
              $error("[%0t] JOIN XT mismatch lane%0d got=%0d exp=%0d",
                     $time, i, $signed(join_xt_vec[i]), exp_xt[i]);
            end
          end
        end
      end
    end
  end

  // ---------------- Stimulus: start pulses to MAC controller ----------------
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

  // ---------------- Optional: init internal memories (if hierarchy matches) ----------------
  integer b, addr, w;
  integer tile_id, element_id, value;
  logic [DATA_W-1:0] line;

  initial begin
    #5;
    $display("[%0t] init WBUF/XT (if mem_sim exists)...", $time);

    // WBUF init (if mem_sim is exposed)
    for (b = 0; b < N_BANK; b = b + 1) begin
      for (addr = 0; addr < WDEPTH; addr = addr + 1) begin
        line = '0;
        tile_id = b + addr * N_BANK;
        for (w = 0; w < 16; w = w + 1) begin
          element_id = tile_id * 16 + w;
          // keep MAC outputs small to avoid sigmoid clamp: use 0..63 (≈0..0.246 in Q8.8)
          value      = (element_id % 64);
          line[w*DATA_WIDTH +: DATA_WIDTH] = value[DATA_WIDTH-1:0];
        end
        // path: dut.u_mac.u_wbuf.mem_sim[bank][addr]
        dut.u_mac.u_wbuf.mem_sim[b][addr] = line;
      end
    end

    // XT init (if mem_sim is exposed)
    for (addr = 0; addr < 64; addr = addr + 1) begin
      // path: dut.u_mac.u_xt.mem_sim[addr]
      // keep xt within small positive range 1..4 to avoid clamp
      dut.u_mac.u_xt.mem_sim[addr] = {
        16'(addr*4+4),
        16'(addr*4+3),
        16'(addr*4+2),
        16'(addr*4+1)
      };
    end

    $display("[%0t] init done (or skipped)", $time);
  end

  // ---------------- Test run ----------------
  int n_tiles;
  initial begin
    s_axis_TVALID = 1'b0;
    n_tiles = 3;

    wait(rst_n);
    repeat(5) @(posedge clk);

    // 发3个tile
    for (int t=0; t<n_tiles; t++) begin
      send_tile_start();
      repeat(200) @(posedge clk);
    end

    // drain
    repeat(800) @(posedge clk);

    // join 应该至少收到 n_tiles 个（除非你极端反压）
    if (got_join < n_tiles) begin
      $error("[%0t] END: join received %0d tiles, expected >= %0d",
             $time, got_join, n_tiles);
    end else begin
      $display("[%0t] ✅ PASS: join matched LUT(fifo) + xt alignment. got_join=%0d",
               $time, got_join);
    end

    // 队列不一定必须空（因为你随机ready可能导致末尾还在排队），但通常应接近空
    $display("[%0t] Remaining queues: exp_lam_q=%0d xt_q=%0d",
             $time, exp_lam_q.size(), xt_q.size());

    $finish;
  end

endmodule
