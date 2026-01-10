`timescale 1ns/1ps
//======================================================================
// tb_top_mac_to_sigmoid_fullpath.sv
// Purpose:
//   End-to-end TB for:
//     slim_mac_mem_controller_combined_dp
//       -> pulse_to_stream_adapter
//       -> bias_add_regslice_ip_A
//       -> vec_fifo_axis_ip (bias2sigmoid_fifo)
//       -> sigmoid4_vec
//
// What it checks:
//   1) Full AXI-style handshake correctness under backpressure
//   2) Sigmoid output equals LUT(tb_rom[addr]) for the *same token*
//      coming out of the FIFO pre-sigmoid stream.
//
// Notes:
//   - This TB assumes your top is: top_mac_plus_bias_fifo_sigmoid
//   - IMPORTANT: In your provided top, there is an old assignment
//       assign fifo2sig_ready = fifo_out_ready;
//     that MUST be removed, otherwise fifo2sig_ready will be multi-driven.
//   - This TB does NOT need to model the internal MAC math.
//     It verifies consistency: FIFO token -> sigmoid token mapping.
//======================================================================

module tb_top_mac_to_sigmoid_fullpath;

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

  // Q8.8 clamp range for LUT [-4,+4)
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

  // pre-sigmoid (FIFO) stream
  logic                         fifo_out_valid;
  logic                         fifo_out_ready;
  logic signed [DATA_WIDTH-1:0] fifo_out_vec [TILE_SIZE-1:0];

  // post-sigmoid stream
  logic                         sigmoid_out_valid;
  logic                         sigmoid_out_ready;
  logic        [DATA_WIDTH-1:0] sigmoid_out_vec [TILE_SIZE-1:0];

  // bias raw debug (optional)
  logic                         bias_raw_valid;
  logic signed [DATA_WIDTH-1:0] bias_raw_vec [TILE_SIZE-1:0];

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

    .sigmoid_out_valid(sigmoid_out_valid),
    .sigmoid_out_ready(sigmoid_out_ready),
    .sigmoid_out_vec  (sigmoid_out_vec),

    .bias_raw_valid   (bias_raw_valid),
    .bias_raw_vec     (bias_raw_vec)
  );

  // ---------------- Reset sequence ----------------
  initial begin
    rst_n         = 1'b0;
    s_axis_TVALID = 1'b0;
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
  wire fifo_fire  = fifo_out_valid    && fifo_out_ready;
  wire sig_fire   = sigmoid_out_valid && sigmoid_out_ready;

  // ---------------- Backpressure generators ----------------
  // NOTE: For your top's "broadcast_ready = fifo_out_ready && sig_in_ready",
  //       it is safer to keep fifo_out_ready mostly 1, and randomize sigmoid_out_ready.
  //       If you randomize BOTH, throughput can become very low (still correct though).

  // pre-sigmoid debug sink ready (keep mostly 1)
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) fifo_out_ready <= 1'b1;
    else        fifo_out_ready <= ($urandom_range(0,9) < 9); // 90% ready
  end

  // post-sigmoid downstream ready (stress backpressure)
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) sigmoid_out_ready <= 1'b1;
    else        sigmoid_out_ready <= ($urandom_range(0,9) < 7); // 70% ready
  end

  // ---------------- Hold checks ----------------
  // Pre-sigmoid hold
  logic pre_hold_seen;
  logic signed [DATA_WIDTH-1:0] pre_hold_vec [TILE_SIZE-1:0];

  // Post-sigmoid hold
  logic post_hold_seen;
  logic [DATA_WIDTH-1:0] post_hold_vec [TILE_SIZE-1:0];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pre_hold_seen <= 1'b0;
      post_hold_seen <= 1'b0;
      for (int i=0;i<TILE_SIZE;i++) begin
        pre_hold_vec[i]  <= '0;
        post_hold_vec[i] <= '0;
      end
    end else begin
      // pre
      if (fifo_out_valid && !fifo_out_ready) begin
        if (!pre_hold_seen) begin
          pre_hold_seen <= 1'b1;
          for (int i=0;i<TILE_SIZE;i++) pre_hold_vec[i] <= fifo_out_vec[i];
        end else begin
          for (int i=0;i<TILE_SIZE;i++) begin
            if (fifo_out_vec[i] !== pre_hold_vec[i]) begin
              $error("[%0t] PRE hold violated lane%0d old=%0d new=%0d",
                     $time, i, pre_hold_vec[i], fifo_out_vec[i]);
            end
          end
        end
      end else begin
        pre_hold_seen <= 1'b0;
      end

      // post
      if (sigmoid_out_valid && !sigmoid_out_ready) begin
        if (!post_hold_seen) begin
          post_hold_seen <= 1'b1;
          for (int i=0;i<TILE_SIZE;i++) post_hold_vec[i] <= sigmoid_out_vec[i];
        end else begin
          for (int i=0;i<TILE_SIZE;i++) begin
            if (sigmoid_out_vec[i] !== post_hold_vec[i]) begin
              $error("[%0t] POST hold violated lane%0d old=%h new=%h",
                     $time, i, post_hold_vec[i], sigmoid_out_vec[i]);
            end
          end
        end
      end else begin
        post_hold_seen <= 1'b0;
      end
    end
  end

  // ---------------- Scoreboard: FIFO token -> expected sigmoid output ----------------
  // We enqueue expected sigmoid outputs when the pre-sigmoid FIFO token is consumed (fifo_fire).
  // Then we compare when post-sigmoid token is consumed (sig_fire).
  logic [DATA_WIDTH-1:0] exp_q[$][TILE_SIZE-1:0];

  task automatic enqueue_expected_from_fifo(input logic signed [DATA_WIDTH-1:0] x_vec [TILE_SIZE-1:0]);
    logic [DATA_WIDTH-1:0] e [TILE_SIZE-1:0];
    begin
      for (int i=0;i<TILE_SIZE;i++) begin
        e[i] = tb_rom[ addr_from_x(x_vec[i]) ];
      end
      exp_q.push_back(e);
    end
  endtask

  int got;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      got <= 0;
      exp_q.delete();
    end else begin
      if (fifo_fire) begin
        enqueue_expected_from_fifo(fifo_out_vec);
        $display("[%0t] PRE  fire  x_q88=%0d,%0d,%0d,%0d  q=%0d",
                 $time, fifo_out_vec[0], fifo_out_vec[1], fifo_out_vec[2], fifo_out_vec[3], exp_q.size());
      end

      if (sig_fire) begin
        if (exp_q.size()==0) begin
          $error("[%0t] POST fire but expected queue empty!", $time);
        end else begin
          logic [DATA_WIDTH-1:0] expv [TILE_SIZE-1:0];
          expv = exp_q.pop_front();
          got++;

          $display("[%0t] POST fire got=%h,%h,%h,%h  exp=%h,%h,%h,%h  q=%0d",
                   $time,
                   sigmoid_out_vec[0], sigmoid_out_vec[1], sigmoid_out_vec[2], sigmoid_out_vec[3],
                   expv[0], expv[1], expv[2], expv[3],
                   exp_q.size());

          for (int i=0;i<TILE_SIZE;i++) begin
            if (sigmoid_out_vec[i] !== expv[i]) begin
              $error("[%0t] MISMATCH lane%0d got=%h exp=%h",
                     $time, i, sigmoid_out_vec[i], expv[i]);
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
      // hold until accepted
      while (!(s_axis_TVALID && s_axis_TREADY)) @(posedge clk);
      @(posedge clk);
      s_axis_TVALID <= 1'b0;
      $display("[%0t] 🚀 Tile start accepted", $time);
    end
  endtask

  // ---------------- Optional: init internal memories (only if hierarchical names match) ----------------
  // If you don't need deterministic numeric correctness of MAC, you can comment this out.
  integer b, addr, w;
  integer tile_id, element_id, value;
  logic [DATA_W-1:0] line;

  initial begin
    // wait a bit for elaboration
    #5;

    // Try to init WBUF/XT if the paths exist in your design.
    // If your hierarchy differs, Vivado will error; then just comment this block.
    $display("[%0t] init WBUF/XT (if mem_sim exists)...", $time);

    for (b = 0; b < N_BANK; b = b + 1) begin
      for (addr = 0; addr < WDEPTH; addr = addr + 1) begin
        line = '0;
        tile_id = b + addr * N_BANK;
        for (w = 0; w < 16; w = w + 1) begin
          element_id = tile_id * 16 + w;
          value      = 1 + element_id;
          line[w*DATA_WIDTH +: DATA_WIDTH] = value[DATA_WIDTH-1:0];
        end
        // WBUF 行为模型公开 mem_sim（见 slim_multi_bank_wbuf_dp）
        dut.u_mac.u_wbuf.mem_sim[b][addr] = line;
      end
    end

    for (addr = 0; addr < 64; addr = addr + 1) begin
      // XT 行为模型公开 mem_sim（见 xt_input_buf）
      dut.u_mac.u_xt.mem_sim[addr] = {
        16'(4*addr + 4), 16'(4*addr + 3), 16'(4*addr + 2), 16'(4*addr + 1)
      };
    end

    $display("[%0t] init done (or skipped)", $time);
  end

  // ---------------- Test run ----------------
  initial begin
    wait(rst_n);
    repeat(5) @(posedge clk);

    // Fire a few tiles; adjust gaps depending on your MAC latency/throughput
    send_tile_start();
    repeat(200) @(posedge clk);

    send_tile_start();
    repeat(200) @(posedge clk);

    send_tile_start();
    repeat(400) @(posedge clk);

    // drain
    repeat(300) @(posedge clk);

    if (exp_q.size() != 0) begin
      $error("[%0t] END but expected queue not empty: size=%0d", $time, exp_q.size());
    end else begin
      $display("[%0t] ✅ PASS: full path MAC->...->FIFO->sigmoid matched LUT + hold OK. got=%0d", $time, got);
    end

    $finish;
  end

endmodule
