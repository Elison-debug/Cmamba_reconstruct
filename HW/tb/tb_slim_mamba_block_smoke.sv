`timescale 1ns/1ps

module tb_slim_mamba_block_smoke;
  localparam int TILE_SIZE  = 4;
  localparam int DATA_WIDTH = 16;
  localparam int TIMEOUT_CYCLES = 30000;
  localparam string LUT_PATH_CONST = "E:/course/smamba/HW/ip/sigmoid_lut_q016_2048.hex";

  logic clk;
  logic rst_n;
  logic block_start;
  logic block_busy;
  logic block_done;
  logic h_wr_en;
  logic [4:0] h_wr_addr;
  logic signed [DATA_WIDTH-1:0] h_wr_data [TILE_SIZE-1:0];
  logic y_valid;
  logic y_ready;
  logic signed [DATA_WIDTH-1:0] y_data [TILE_SIZE-1:0];

  int cyc;
  int y_count;

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  task automatic preload_zero_h();
    begin
      for (int r = 0; r < 32; r++) begin
        @(posedge clk);
        h_wr_en <= 1'b1;
        h_wr_addr <= r[4:0];
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
          h_wr_data[lane] <= '0;
        end
      end
      @(posedge clk);
      h_wr_en <= 1'b0;
      h_wr_addr <= '0;
    end
  endtask

  initial begin
    rst_n = 1'b0;
    block_start = 1'b0;
    h_wr_en = 1'b0;
    h_wr_addr = '0;
    y_ready = 1'b1;
    cyc = 0;
    y_count = 0;
    for (int lane = 0; lane < TILE_SIZE; lane++) begin
      h_wr_data[lane] = '0;
    end

    repeat (20) @(posedge clk);
    rst_n = 1'b1;
    repeat (5) @(posedge clk);
    preload_zero_h();
    repeat (4) @(posedge clk);
    block_start = 1'b1;
    @(posedge clk);
    block_start = 1'b0;
  end

  always @(posedge clk) begin
    if (rst_n && y_valid && y_ready) begin
      y_count <= y_count + 1;
    end
  end

  initial begin
    wait(rst_n);
    while (!block_done && cyc < TIMEOUT_CYCLES) begin
      @(posedge clk);
      cyc++;
    end

    if (!block_done) begin
      $fatal(1, "[%0t] timeout waiting block_done", $time);
    end
    if (block_busy !== 1'b0) begin
      $fatal(1, "[%0t] block_done asserted while block_busy still high", $time);
    end
    if (y_count == 0) begin
      $fatal(1, "[%0t] no output beats observed", $time);
    end

    $display("[%0t] PASS tb_slim_mamba_block_smoke cycles=%0d y_count=%0d",
             $time, cyc, y_count);
    #50;
    $finish;
  end

  slim_mamba_block #(
      .TILE_SIZE(TILE_SIZE),
      .DATA_WIDTH(DATA_WIDTH),
      .LUT_FILE(LUT_PATH_CONST)
  ) u_dut (
      .clk(clk),
      .rst_n(rst_n),
      .block_start(block_start),
      .block_busy(block_busy),
      .block_done(block_done),
      .h_wr_en(h_wr_en),
      .h_wr_addr(h_wr_addr),
      .h_wr_data(h_wr_data),
      .y_axis_TVALID(y_valid),
      .y_axis_TREADY(y_ready),
      .y_axis_TDATA(y_data)
  );
endmodule

