`timescale 1ns/1ps

module tb_mm_state_policy_smoke;
  localparam int TILE_SIZE = 4;
  localparam int DATA_WIDTH = 16;
  localparam int STATE_ADDR_W = 6;
  localparam int HANDSHAKE_TIMEOUT_CYCLES = 256;
  localparam int OUTPUT_TIMEOUT_CYCLES = 2048;

  logic clk;
  logic rst_n;
  logic state_frame_start;
  logic state_continuous_en;
  logic state_force_clear;
  logic state_clear_done;
  logic dt_valid, dt_ready;
  logic [STATE_ADDR_W-1:0] dt_addr;
  logic [DATA_WIDTH-1:0] lam_vec [TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0] u_vec [TILE_SIZE-1:0];
  logic gate_valid, gate_ready;
  logic signed [DATA_WIDTH-1:0] gate_vec [TILE_SIZE-1:0];
  logic p_valid, p_ready;
  logic [STATE_ADDR_W-1:0] p_addr;
  logic signed [DATA_WIDTH-1:0] p_vec [TILE_SIZE-1:0];

  logic signed [DATA_WIDTH-1:0] frame1_vec [TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0] frame2_reset_vec [TILE_SIZE-1:0];
  logic signed [DATA_WIDTH-1:0] frame2_cont_vec [TILE_SIZE-1:0];

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  task automatic drive_one_sample(
    input logic start_of_frame,
    input logic [STATE_ADDR_W-1:0] sample_addr
  );
    int wait_cyc;
    begin
      state_frame_start <= start_of_frame;
      dt_addr <= sample_addr;
      dt_valid <= 1'b1;
      gate_valid <= 1'b1;
      wait_cyc = 0;
      do begin
        @(posedge clk);
        wait_cyc++;
        if (wait_cyc > HANDSHAKE_TIMEOUT_CYCLES) begin
          $fatal(1, "[%0t] timeout waiting dt/gate handshake start_of_frame=%0d dt_ready=%0d gate_ready=%0d",
                   $time, start_of_frame, dt_ready, gate_ready);
        end
      end while (!(dt_ready && gate_ready));
      dt_valid <= 1'b0;
      gate_valid <= 1'b0;
      state_frame_start <= 1'b0;
      wait_cyc = 0;
      do begin
        @(posedge clk);
        wait_cyc++;
        if (wait_cyc > OUTPUT_TIMEOUT_CYCLES) begin
          $fatal(1, "[%0t] timeout waiting p_valid start_of_frame=%0d", $time, start_of_frame);
        end
      end while (!p_valid);
    end
  endtask

  initial begin
    rst_n = 1'b0;
    state_frame_start = 1'b0;
    state_continuous_en = 1'b0;
    state_force_clear = 1'b0;
    dt_valid = 1'b0;
    dt_addr = '0;
    gate_valid = 1'b0;
    p_ready = 1'b1;

    for (int i = 0; i < TILE_SIZE; i++) begin
      lam_vec[i] = 16'd32768; // 0.5 in Q0.16, matching the Python/RTL dt-sigmoid path
      u_vec[i] = 16'sd200;
      gate_vec[i] = 16'sd256; // 1.0 in Q8.8
      frame1_vec[i] = '0;
      frame2_reset_vec[i] = '0;
      frame2_cont_vec[i] = '0;
    end

    repeat (10) @(posedge clk);
    rst_n = 1'b1;
    repeat (4) @(posedge clk);

    // Frame-1 (reset behavior)
    drive_one_sample(1'b1, '0);
    for (int i = 0; i < TILE_SIZE; i++) frame1_vec[i] = p_vec[i];

    // Frame-2 with reset-on-frame-start
    drive_one_sample(1'b1, '0);
    for (int i = 0; i < TILE_SIZE; i++) frame2_reset_vec[i] = p_vec[i];

    // Force clear then run continuous mode
    state_force_clear <= 1'b1;
    @(posedge clk);
    state_force_clear <= 1'b0;
    repeat (2) @(posedge clk);

    state_continuous_en <= 1'b1;
    drive_one_sample(1'b1, 6'd0);
    // second sample advances to the next sequential state address, so it can
    // observe the previous write-forward/state-RAM effect.
    drive_one_sample(1'b0, 6'd1);
    for (int i = 0; i < TILE_SIZE; i++) frame2_cont_vec[i] = p_vec[i];

    for (int i = 0; i < TILE_SIZE; i++) begin
      if (frame1_vec[i] !== frame2_reset_vec[i]) begin
        $fatal(1, "reset policy mismatch lane=%0d first=%0d second_reset=%0d", i, frame1_vec[i], frame2_reset_vec[i]);
      end
      if (frame2_cont_vec[i] === frame1_vec[i]) begin
        $fatal(1, "continuous policy not reflected lane=%0d first=%0d second_cont=%0d", i, frame1_vec[i], frame2_cont_vec[i]);
      end
    end

    $display("[%0t] PASS tb_mm_state_policy_smoke", $time);
    #20;
    $finish;
  end

  mm_state_datapath #(
    .TILE_SIZE(TILE_SIZE),
    .DATA_WIDTH(DATA_WIDTH),
    .STATE_ADDR_W(STATE_ADDR_W)
  ) u_dut (
    .clk(clk),
    .rst_n(rst_n),
    .state_frame_start(state_frame_start),
    .state_continuous_en(state_continuous_en),
    .state_force_clear(state_force_clear),
    .state_clear_done(state_clear_done),
    .dt_valid(dt_valid),
    .dt_ready(dt_ready),
    .dt_addr(dt_addr),
    .lam_vec(lam_vec),
    .u_vec(u_vec),
    .gate_valid(gate_valid),
    .gate_ready(gate_ready),
    .gate_vec(gate_vec),
    .p_valid(p_valid),
    .p_ready(p_ready),
    .p_addr(p_addr),
    .p_vec(p_vec)
  );
endmodule


