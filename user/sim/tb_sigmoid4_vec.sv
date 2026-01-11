`timescale 1ns/1ps

module tb_sigmoid4_vec;

  localparam int TILE_SIZE = 4;
  localparam int IN_W      = 16;
  localparam int OUT_W     = 16;
  localparam int ADDR_BITS = 11;

  localparam string LUT_FILE = "D:/Mamba/Cmamba_reconstruct/sigmoid_lut_q016_2048.hex";

  localparam logic signed [IN_W-1:0] X_MIN = -16'sd1024;
  localparam logic signed [IN_W-1:0] X_MAX =  16'sd1023;

  logic clk, rst_n;

  logic in_valid;
  logic in_ready;
  logic signed [IN_W-1:0] in_vec [TILE_SIZE-1:0];

  logic out_valid;
  logic out_ready;
  logic [OUT_W-1:0] out_vec [TILE_SIZE-1:0];

  // clock
  initial begin
    clk = 1'b0;
    forever #1 clk = ~clk;
  end

  // reset + init
  initial begin
    rst_n    = 1'b0;
    in_valid = 1'b0;
    for (int i=0;i<TILE_SIZE;i++) in_vec[i] = '0;
    repeat(8) @(posedge clk);
    rst_n = 1'b1;
  end

  // DUT
  sigmoid4_vec #(
    .TILE_SIZE (TILE_SIZE),
    .IN_W      (IN_W),
    .OUT_W     (OUT_W),
    .ADDR_BITS (ADDR_BITS),
    .LUT_FILE  (LUT_FILE)
  ) dut (
    .clk       (clk),
    .rst_n     (rst_n),
    .in_valid  (in_valid),
    .in_ready  (in_ready),
    .in_vec    (in_vec),
    .out_valid (out_valid),
    .out_ready (out_ready),
    .out_vec   (out_vec)
  );

  // TB ROM model
  localparam int LUT_SIZE = (1<<ADDR_BITS);
  logic [OUT_W-1:0] tb_rom [0:LUT_SIZE-1];

  initial begin
    $readmemh(LUT_FILE, tb_rom);
  end

  function automatic logic signed [IN_W-1:0] clamp_q88(input logic signed [IN_W-1:0] x);
    if (x < X_MIN)       clamp_q88 = X_MIN;
    else if (x > X_MAX)  clamp_q88 = X_MAX;
    else                 clamp_q88 = x;
  endfunction

  // ✅ 修复：显式切片，避免工具差异
  function automatic logic [ADDR_BITS-1:0] addr_from_x(input logic signed [IN_W-1:0] x);
    logic signed [IN_W-1:0] xc;
    logic signed [IN_W-1:0] sum;
    begin
      xc  = clamp_q88(x);
      sum = xc + 16'sd1024;              // 0..2047
      addr_from_x = sum[ADDR_BITS-1:0];  // 显式切片
    end
  endfunction

  // scoreboard queue: expected output vectors (aligned to out_fire)
  logic [OUT_W-1:0] exp_q [$][TILE_SIZE-1:0];
  int sent_cnt;

  wire in_fire  = in_valid && in_ready;
  wire out_fire = out_valid && out_ready;

  // out_ready single driver
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) out_ready <= 1'b1;
    else       out_ready <= ($urandom_range(0, 9) < 7); // 70% ready
  end

  // hold check
  logic hold_seen;
  logic [OUT_W-1:0] hold_vec [TILE_SIZE-1:0];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      hold_seen <= 1'b0;
      for (int i=0;i<TILE_SIZE;i++) hold_vec[i] <= '0;
    end else begin
      if (out_valid && !out_ready) begin
        if (!hold_seen) begin
          hold_seen <= 1'b1;
          for (int i=0;i<TILE_SIZE;i++) hold_vec[i] <= out_vec[i];
        end else begin
          for (int i=0;i<TILE_SIZE;i++) begin
            if (out_vec[i] !== hold_vec[i]) begin
              $error("[%0t] HOLD violated lane%0d old=%h new=%h", $time, i, hold_vec[i], out_vec[i]);
            end
          end
        end
      end else begin
        hold_seen <= 1'b0;
      end
    end
  end

  // deterministic test vectors (keep your set)
  logic signed [IN_W-1:0] tv [0:11][TILE_SIZE-1:0];
  initial begin
    tv[0]  = '{ -16'sd768,  -16'sd256,   16'sd0,      16'sd256  }; // -3,-1,0,+1
    tv[1]  = '{ -16'sd512,  -16'sd128,   16'sd128,    16'sd512  }; // -2,-0.5,0.5,2
    tv[2]  = '{ -16'sd1024, -16'sd512,   16'sd512,    16'sd1023 }; // -4,-2,2,~4
    tv[3]  = '{  16'sd0,     16'sd0,     16'sd0,      16'sd0    };
    tv[4]  = '{  16'sd256,   16'sd256,   16'sd256,    16'sd256  };
    tv[5]  = '{ -16'sd256,  -16'sd256,  -16'sd256,   -16'sd256  };
    tv[6]  = '{  16'sd768,   16'sd512,   16'sd256,    16'sd128  };
    tv[7]  = '{ -16'sd768,  -16'sd512,  -16'sd256,   -16'sd128  };
    tv[8]  = '{  16'sd20000, -16'sd20000, 16'sd15000, -16'sd15000 };
    tv[9]  = '{ -16'sd30000, 16'sd30000,  16'sd0,      16'sd1     };
    tv[10] = '{  16'sd1023,  16'sd1022,  -16'sd1024,  -16'sd1023 };
    tv[11] = '{  16'sd600,   16'sd350,   -16'sd700,   -16'sd900  };
  end

  // enqueue expected when a vector is *accepted* (in_fire), so it stays aligned even if stage0_addr updates the same cycle
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      exp_q.delete();
      sent_cnt <= 0;
    end else begin
      if (in_fire) begin
        logic [OUT_W-1:0] e [TILE_SIZE-1:0];
        for (int i=0;i<TILE_SIZE;i++) begin
          e[i] = tb_rom[addr_from_x(tv[sent_cnt][i])];
        end
        exp_q.push_back(e);
        sent_cnt <= sent_cnt + 1;
      end
    end
  end

  // sender
  task automatic send_vec(input int idx);
    begin
      do @(posedge clk); while (!rst_n || !in_ready);

      for (int i=0;i<TILE_SIZE;i++) in_vec[i] = tv[idx][i];
      in_valid = 1'b1;

      // wait until it actually fires (robust to sudden backpressure)
      do @(posedge clk); while (!(in_valid && in_ready));

      $display("[%0t] SEND idx=%0d  in_q88=%0d,%0d,%0d,%0d",
               $time, idx, tv[idx][0], tv[idx][1], tv[idx][2], tv[idx][3]);

      in_valid = 1'b0;
    end
  endtask

  // ✅ 在线 checker：从一开始就盯 out_fire，不会错过任何输出
  int got;
  bit sent_done;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      got <= 0;
    end else begin
      if (out_fire) begin
        if (exp_q.size() == 0) begin
          $error("[%0t] OUT fired but expected queue empty!", $time);
        end else begin
          logic [OUT_W-1:0] expv [TILE_SIZE-1:0];
          expv = exp_q.pop_front();

          $display("[%0t] OUT  got=%h,%h,%h,%h  exp=%h,%h,%h,%h",
                   $time, out_vec[0], out_vec[1], out_vec[2], out_vec[3],
                   expv[0], expv[1], expv[2], expv[3]);

          for (int i=0;i<TILE_SIZE;i++) begin
            if (out_vec[i] !== expv[i]) begin
              $error("[%0t] MISMATCH lane%0d got=%h exp=%h", $time, i, out_vec[i], expv[i]);
            end
          end

          got <= got + 1;
        end
      end
    end
  end

  // stimulus
  initial begin
    sent_done = 0;
    wait(rst_n);

    for (int idx=0; idx<12; idx++) begin
      send_vec(idx);
    end

    sent_done = 1;
  end

  // finish condition
  initial begin
    wait(rst_n);
    wait(sent_done);
    wait(got == 12);

    repeat(5) @(posedge clk);

    if (exp_q.size()!=0) $error("[%0t] End but expected queue not empty: size=%0d", $time, exp_q.size());
    else $display("✅ PASS: all vectors matched LUT exactly + hold check OK.");
    $finish;
  end

endmodule
