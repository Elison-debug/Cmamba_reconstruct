`timescale 1ns/1ps

module tb_mm_mamba_block_top_smoke;
  localparam int TIMEOUT_CYCLES = 10000;

  logic clk;
  logic rst_n;
  logic block_start;
  logic block_busy;
  logic block_done;
  logic state_clear_done;

  int cyc;

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst_n = 1'b0;
    block_start = 1'b0;
    repeat (20) @(posedge clk);
    rst_n = 1'b1;
    repeat (5) @(posedge clk);
    block_start = 1'b1;
    @(posedge clk);
    block_start = 1'b0;
  end

  initial begin
    cyc = 0;
    wait(rst_n);
    while (!block_done && cyc < TIMEOUT_CYCLES) begin
      @(posedge clk);
      cyc++;
    end

    if (!block_done) begin
      $fatal(1, "[%0t] timeout waiting block_done", $time);
    end

    // Keep this smoke TB strict on handshakes and completion only.
    if (block_busy !== 1'b0) begin
      $fatal(1, "[%0t] block_done asserted while block_busy still high", $time);
    end

    $display("[%0t] PASS tb_mm_mamba_block_top_smoke cycles=%0d", $time, cyc);
    #50;
    $finish;
  end

  mm_mamba_block_top u_dut (
    .clk(clk),
    .rst_n(rst_n),
    .block_start(block_start),
    .state_continuous_en(1'b0),
    .block_busy(block_busy),
    .block_done(block_done),
    .state_clear_done(state_clear_done)
  );
endmodule


