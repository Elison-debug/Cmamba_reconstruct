`timescale 1ns/1ps

module tb_mm_chain4_top_smoke;
  localparam int TIMEOUT_CYCLES = 40000;

  logic clk;
  logic rst_n;
  logic start;
  logic busy;
  logic done;
  int cyc;

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst_n = 1'b0;
    start = 1'b0;
    repeat (20) @(posedge clk);
    rst_n = 1'b1;
    repeat (8) @(posedge clk);
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
  end

  initial begin
    cyc = 0;
    wait(rst_n);
    while (!done && cyc < TIMEOUT_CYCLES) begin
      @(posedge clk);
      cyc++;
    end

    if (!done) begin
      $fatal(1, "[%0t] timeout waiting done", $time);
    end
    if (busy !== 1'b0) begin
      $fatal(1, "[%0t] done asserted while busy still high", $time);
    end

    $display("[%0t] PASS tb_mm_chain4_top_smoke cycles=%0d", $time, cyc);
    #50;
    $finish;
  end

  mm_chain4_top u_dut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .busy(busy),
    .done(done)
  );
endmodule



