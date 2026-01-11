`timescale 1ns/1ps

module tb_axis_join_ew_update_top;
  localparam int TILE_SIZE = 4;
  localparam int W         = 16;
  localparam int S_ADDR_W  = 6; // depth 64

  // clock / reset
  logic clk;
  logic rst_n;
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz
  end
  initial begin
    rst_n = 0;
    repeat (5) @(posedge clk);
    rst_n = 1;
  end

  // DUT IO
  logic                  lam_valid;
  logic                  lam_ready;
  logic [W-1:0]          lam_vec   [TILE_SIZE-1:0];

  logic                  xt_valid;
  logic                  xt_ready;
  logic [W-1:0]          xt_vec    [TILE_SIZE-1:0];

  logic [S_ADDR_W-1:0]   s_addr_in;

  logic                  out_valid;
  logic                  out_ready;
  logic signed [W-1:0]   s_new_vec [TILE_SIZE-1:0];

  // Instantiate top,使用外部地址（AUTO_ADDR=0）
  axis_join_ew_update_top #(
      .TILE_SIZE (TILE_SIZE),
      .W         (W),
      .S_ADDR_W  (S_ADDR_W),
      .AUTO_ADDR (0)
  ) dut (
      .clk        (clk),
      .rst_n      (rst_n),
      .lam_valid  (lam_valid),
      .lam_ready  (lam_ready),
      .lam_vec_in (lam_vec),
      .xt_valid   (xt_valid),
      .xt_ready   (xt_ready),
      .xt_vec_in  (xt_vec),
      .s_addr_in  (s_addr_in),
      .out_valid  (out_valid),
      .out_ready  (out_ready),
      .s_new_vec  (s_new_vec)
  );

  // expected state table
  logic signed [15:0] exp_state [0:(1<<S_ADDR_W)-1][0:TILE_SIZE-1];

  function automatic integer ema_step(input integer lam_q0_16, input integer s_prev_q8_8, input integer u_q8_8);
    integer term1, term2;
    begin
      term1 = (lam_q0_16 * s_prev_q8_8) >>> 16;
      term2 = ((16'hFFFF - lam_q0_16) * u_q8_8) >>> 16;
      ema_step = term1 + term2;
    end
  endfunction

  // queue to track addresses
  logic [S_ADDR_W-1:0] addr_q [$];

  task automatic send_tile(input [S_ADDR_W-1:0] addr,
                           input [W-1:0] lam0, lam1, lam2, lam3,
                           input signed [W-1:0] u0, u1, u2, u3);
    begin
      @(posedge clk);
      while (!(lam_ready && xt_ready)) @(posedge clk);
      s_addr_in <= addr;
      lam_vec[0] <= lam0; lam_vec[1] <= lam1; lam_vec[2] <= lam2; lam_vec[3] <= lam3;
      xt_vec[0]  <= u0;   xt_vec[1]  <= u1;   xt_vec[2]  <= u2;   xt_vec[3]  <= u3;
      lam_valid  <= 1'b1;
      xt_valid   <= 1'b1;
      @(posedge clk);
      lam_valid  <= 1'b0;
      xt_valid   <= 1'b0;
      addr_q.push_back(addr);
    end
  endtask

  // Monitor output
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      out_ready <= 1'b1;
      lam_valid <= 1'b0;
      xt_valid  <= 1'b0;
      s_addr_in <= '0;
      addr_q    <= {};
      for (int a=0; a<(1<<S_ADDR_W); a++)
        for (int i=0; i<TILE_SIZE; i++)
          exp_state[a][i] = 0;
    end else begin
      if (out_valid && out_ready) begin
        if (addr_q.size() == 0) begin
          $error("addr queue underflow");
        end else begin
          logic [S_ADDR_W-1:0] addr_pop;
          addr_pop = addr_q.pop_front();
          for (int i=0; i<TILE_SIZE; i++) begin
            if ($signed(s_new_vec[i]) !== $signed(exp_state[addr_pop][i]))
              $error("Mismatch lane%0d addr%0d got=%0d exp=%0d", i, addr_pop, $signed(s_new_vec[i]), $signed(exp_state[addr_pop][i]));
            else
              $display("[%0t] PASS lane%0d addr%0d val=%0d", $time, i, addr_pop, $signed(s_new_vec[i]));
          end
        end
      end
    end
  end

  // Stimulus
  initial begin
    // wait reset deassert
    @(posedge rst_n);

    // Tile0 @ addr0 (lam=0.5, u=1/2/3/4)
    send_tile(6'd0, 16'h8000,16'h8000,16'h8000,16'h8000,
                   16'sd256,16'sd512,16'sd768,16'sd1024);
    exp_state[0][0] = ema_step(16'h8000, 0, 16'sd256);
    exp_state[0][1] = ema_step(16'h8000, 0, 16'sd512);
    exp_state[0][2] = ema_step(16'h8000, 0, 16'sd768);
    exp_state[0][3] = ema_step(16'h8000, 0, 16'sd1024);

    // Tile1 @ addr1 (lam=0.25, u=1/-1/2/-2)
    send_tile(6'd1, 16'h4000,16'h4000,16'h4000,16'h4000,
                   16'sd256,-16'sd256,16'sd512,-16'sd512);
    exp_state[1][0] = ema_step(16'h4000, 0, 16'sd256);
    exp_state[1][1] = ema_step(16'h4000, 0, -16'sd256);
    exp_state[1][2] = ema_step(16'h4000, 0, 16'sd512);
    exp_state[1][3] = ema_step(16'h4000, 0, -16'sd512);

    // Tile2 reuse addr0 (lam=0.75, u=0.5 each)
    send_tile(6'd0, 16'hC000,16'hC000,16'hC000,16'hC000,
                   16'sd128,16'sd128,16'sd128,16'sd128);
    exp_state[0][0] = ema_step(16'hC000, exp_state[0][0], 16'sd128);
    exp_state[0][1] = ema_step(16'hC000, exp_state[0][1], 16'sd128);
    exp_state[0][2] = ema_step(16'hC000, exp_state[0][2], 16'sd128);
    exp_state[0][3] = ema_step(16'hC000, exp_state[0][3], 16'sd128);

    // wait some cycles then finish
    repeat (100) @(posedge clk);
    $finish;
  end

endmodule
