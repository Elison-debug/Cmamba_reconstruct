`timescale 1ns/1ps

module tb_ew_update_vec4;
  localparam int TILE_SIZE = 4;
  localparam int W         = 16;
  localparam int S_ADDR_W  = 6; // depth 64

  logic clk;
  logic rst_n;

  // DUT I/O
  logic                 in_valid;
  logic                 in_ready;
  logic [W-1:0]         lam_vec [TILE_SIZE-1:0];
  logic signed [W-1:0]  u_vec   [TILE_SIZE-1:0];
  logic [S_ADDR_W-1:0]  s_addr;

  logic                 out_valid;
  logic                 out_ready;
  logic signed [W-1:0]  s_new_vec [TILE_SIZE-1:0];

  ew_update_vec4 #(
      .TILE_SIZE (TILE_SIZE),
      .W         (W),
      .S_ADDR_W  (S_ADDR_W)
  ) dut (
      .clk      (clk),
      .rst_n    (rst_n),
      .in_valid (in_valid),
      .in_ready (in_ready),
      .lam_vec  (lam_vec),
      .u_vec    (u_vec),
      .s_addr   (s_addr),
      .out_valid(out_valid),
      .out_ready(out_ready),
      .s_new_vec(s_new_vec)
  );

  // clock
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz
  end

  // reset
  initial begin
    rst_n = 0;
    in_valid = 0;
    out_ready = 1'b1;
    s_addr = '0;
    for (int i=0;i<TILE_SIZE;i++) begin
      lam_vec[i] = '0;
      u_vec[i]   = '0;
    end
    for (int a=0; a<(1<<S_ADDR_W); a++) begin
      for (int j=0; j<TILE_SIZE; j++) exp_state[a][j] = 0;
    end
    repeat (5) @(posedge clk);
    rst_n = 1;
  end

  // expected state (Q8.8 signed)
  logic signed [15:0] exp_state [0:(1<<S_ADDR_W)-1][0:TILE_SIZE-1];

  function automatic integer ema_step(input integer lam_q0_16, input integer s_prev_q8_8, input integer u_q8_8);
    integer term1, term2;
    begin
      term1 = (lam_q0_16 * s_prev_q8_8) >>> 16;          // Q8.24 -> Q8.8
      term2 = ((16'hFFFF - lam_q0_16) * u_q8_8) >>> 16;  // Q8.24 -> Q8.8
      ema_step = term1 + term2;
    end
  endfunction

  task automatic send_tile(input [S_ADDR_W-1:0] addr,
                           input [W-1:0] lam0, lam1, lam2, lam3,
                           input signed [W-1:0] u0, u1, u2, u3);
    begin
      @(posedge clk);
      while (!in_ready) @(posedge clk);
      s_addr   <= addr;
      lam_vec[0] <= lam0; lam_vec[1] <= lam1; lam_vec[2] <= lam2; lam_vec[3] <= lam3;
      u_vec[0]   <= u0;   u_vec[1]   <= u1;   u_vec[2]   <= u2;   u_vec[3]   <= u3;
      in_valid <= 1'b1;
      @(posedge clk);
      in_valid <= 1'b0;
    end
  endtask

  // monitor and check
  always_ff @(posedge clk) begin
    if (rst_n && out_valid && out_ready) begin
      integer addr;
      integer exp;
      addr = s_addr;
      for (int i=0;i<TILE_SIZE;i++) begin
        exp = exp_state[addr][i];
        if ($signed(s_new_vec[i]) !== $signed(exp))
          $error("Mismatch lane%0d addr%0d got=%0d exp=%0d", i, addr, $signed(s_new_vec[i]), exp);
        else
          $display("[%0t] PASS lane%0d addr%0d val=%0d", $time, i, addr, $signed(s_new_vec[i]));
      end
    end
  end

  // stimulus
  initial begin
    // wait reset
    @(posedge rst_n);
    // Tile0 @ addr0
    send_tile(6'd0, 16'h8000,16'h8000,16'h8000,16'h8000,
                   16'sd256,16'sd512,16'sd768,16'sd1024); // lam=0.5, u=1,2,3,4 (Q8.8)
    exp_state[0][0] = ema_step(16'h8000, 0, 16'sd256);
    exp_state[0][1] = ema_step(16'h8000, 0, 16'sd512);
    exp_state[0][2] = ema_step(16'h8000, 0, 16'sd768);
    exp_state[0][3] = ema_step(16'h8000, 0, 16'sd1024);

    // Tile1 @ addr1
    send_tile(6'd1, 16'h4000,16'h4000,16'h4000,16'h4000,
                   16'sd256,-16'sd256,16'sd512,-16'sd512); // lam=0.25
    exp_state[1][0] = ema_step(16'h4000, 0, 16'sd256);
    exp_state[1][1] = ema_step(16'h4000, 0, -16'sd256);
    exp_state[1][2] = ema_step(16'h4000, 0, 16'sd512);
    exp_state[1][3] = ema_step(16'h4000, 0, -16'sd512);

    // Tile2 reuse addr0 to test state feedback
    send_tile(6'd0, 16'hC000,16'hC000,16'hC000,16'hC000,
                   16'sd128,16'sd128,16'sd128,16'sd128); // lam=0.75
    exp_state[0][0] = ema_step(16'hC000, exp_state[0][0], 16'sd128);
    exp_state[0][1] = ema_step(16'hC000, exp_state[0][1], 16'sd128);
    exp_state[0][2] = ema_step(16'hC000, exp_state[0][2], 16'sd128);
    exp_state[0][3] = ema_step(16'hC000, exp_state[0][3], 16'sd128);

    // Tile3 @ addr2 (新地址测试)
    send_tile(6'd2, 16'h2000,16'h2000,16'h2000,16'h2000,
                   -16'sd128,-16'sd64,16'sd64,16'sd128); // lam=0.125
    exp_state[2][0] = ema_step(16'h2000, 0, -16'sd128);
    exp_state[2][1] = ema_step(16'h2000, 0, -16'sd64);
    exp_state[2][2] = ema_step(16'h2000, 0,  16'sd64);
    exp_state[2][3] = ema_step(16'h2000, 0,  16'sd128);

    // Tile4 reuse addr1 (验证非零反馈)
    send_tile(6'd1, 16'h6000,16'h6000,16'h6000,16'h6000,
                   16'sd32,16'sd64,16'sd96,16'sd128); // lam=0.375
    exp_state[1][0] = ema_step(16'h6000, exp_state[1][0], 16'sd32);
    exp_state[1][1] = ema_step(16'h6000, exp_state[1][1], 16'sd64);
    exp_state[1][2] = ema_step(16'h6000, exp_state[1][2], 16'sd96);
    exp_state[1][3] = ema_step(16'h6000, exp_state[1][3], 16'sd128);

    // Tile5 reuse addr0 again (多次反馈)
    send_tile(6'd0, 16'h8000,16'h8000,16'h8000,16'h8000,
                   -16'sd256,-16'sd256,-16'sd256,-16'sd256); // lam=0.5
    exp_state[0][0] = ema_step(16'h8000, exp_state[0][0], -16'sd256);
    exp_state[0][1] = ema_step(16'h8000, exp_state[0][1], -16'sd256);
    exp_state[0][2] = ema_step(16'h8000, exp_state[0][2], -16'sd256);
    exp_state[0][3] = ema_step(16'h8000, exp_state[0][3], -16'sd256);

    // run some cycles
    repeat(100) @(posedge clk);
    $finish;
  end

endmodule
