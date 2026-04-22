`timescale 1ns/1ps

module tb_reuse_ssm_state_reset_ctrl;
  localparam int S_ADDR_W = 3; // depth = 8
  localparam int DATA_W   = 64;
  localparam int DEPTH    = (1 << S_ADDR_W);

  logic clk;
  logic rst_n;
  logic frame_start;
  logic force_clear;
  logic continuous_state_en;
  logic pipe_quiescent;

  logic clear_busy;
  logic clear_done;
  logic quiesce_req;
  logic compute_hold;
  logic state_wr_en;
  logic [S_ADDR_W-1:0] state_wr_addr;
  logic [DATA_W-1:0] state_wr_data;

  int wr_count;
  int addr_expect;

  reuse_ssm_state_reset_ctrl #(
      .S_ADDR_W(S_ADDR_W),
      .DATA_W(DATA_W)
  ) dut (
      .clk(clk),
      .rst_n(rst_n),
      .frame_start(frame_start),
      .force_clear(force_clear),
      .continuous_state_en(continuous_state_en),
      .pipe_quiescent(pipe_quiescent),
      .clear_busy(clear_busy),
      .clear_done(clear_done),
      .quiesce_req(quiesce_req),
      .compute_hold(compute_hold),
      .state_wr_en(state_wr_en),
      .state_wr_addr(state_wr_addr),
      .state_wr_data(state_wr_data)
  );

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  task automatic pulse_frame_start();
    begin
      @(posedge clk);
      frame_start <= 1'b1;
      @(posedge clk);
      frame_start <= 1'b0;
    end
  endtask

  task automatic pulse_force_clear();
    begin
      @(posedge clk);
      force_clear <= 1'b1;
      @(posedge clk);
      force_clear <= 1'b0;
    end
  endtask

  task automatic reset_scoreboard();
    begin
      wr_count    = 0;
      addr_expect = 0;
    end
  endtask

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      reset_scoreboard();
    end else begin
      if (state_wr_en) begin
        if (state_wr_addr !== addr_expect[S_ADDR_W-1:0]) begin
          $fatal(1, "clear addr mismatch: got=%0d exp=%0d", state_wr_addr, addr_expect);
        end
        if (state_wr_data !== '0) begin
          $fatal(1, "clear data is not zero: %h", state_wr_data);
        end
        wr_count    <= wr_count + 1;
        addr_expect <= addr_expect + 1;
      end
      if (compute_hold !== quiesce_req) begin
        $fatal(1, "compute_hold must match quiesce_req");
      end
    end
  end

  initial begin
    rst_n               = 1'b0;
    frame_start         = 1'b0;
    force_clear         = 1'b0;
    continuous_state_en = 1'b1;
    pipe_quiescent      = 1'b1;
    repeat (5) @(posedge clk);
    rst_n = 1'b1;

    // Case 1: stateful mode, frame_start should not clear.
    reset_scoreboard();
    pulse_frame_start();
    repeat (6) @(posedge clk);
    if (wr_count != 0 || clear_busy !== 1'b0) begin
      $fatal(1, "stateful mode should not clear: wr=%0d busy=%0b", wr_count, clear_busy);
    end

    // Case 2: stateless mode, frame_start triggers full clear.
    continuous_state_en = 1'b0;
    reset_scoreboard();
    pulse_frame_start();
    wait (clear_done === 1'b1);
    @(posedge clk);
    if (wr_count != DEPTH) begin
      $fatal(1, "stateless frame clear write count mismatch: got=%0d exp=%0d", wr_count, DEPTH);
    end
    if (clear_busy !== 1'b0) begin
      $fatal(1, "stateless frame clear must end with busy=0");
    end

    // Case 3: force_clear works even when stateful mode is enabled.
    continuous_state_en = 1'b1;
    reset_scoreboard();
    pulse_force_clear();
    wait (clear_done === 1'b1);
    @(posedge clk);
    if (wr_count != DEPTH) begin
      $fatal(1, "force clear write count mismatch: got=%0d exp=%0d", wr_count, DEPTH);
    end
    if (clear_busy !== 1'b0) begin
      $fatal(1, "force clear must end with busy=0");
    end

    // Case 4: trigger during clear should not start a second clear.
    continuous_state_en = 1'b0;
    reset_scoreboard();
    pulse_frame_start();
    repeat (2) @(posedge clk);
    pulse_frame_start();
    wait (clear_done === 1'b1);
    @(posedge clk);
    if (wr_count != DEPTH || clear_busy !== 1'b0) begin
      $fatal(1, "retrigger handling mismatch: wr=%0d busy=%0b", wr_count, clear_busy);
    end

    // Case 5: clear must wait for pipeline drain.
    continuous_state_en = 1'b0;
    pipe_quiescent      = 1'b0;
    reset_scoreboard();
    pulse_frame_start();
    repeat (3) @(posedge clk);
    if (state_wr_en !== 1'b0 || quiesce_req !== 1'b1) begin
      $fatal(1, "must wait quiescent before clear: wr_en=%0b quiesce=%0b", state_wr_en, quiesce_req);
    end
    pipe_quiescent = 1'b1;
    wait (clear_done === 1'b1);
    @(posedge clk);
    if (wr_count != DEPTH || clear_busy !== 1'b0) begin
      $fatal(1, "quiesce-gated clear mismatch: wr=%0d busy=%0b", wr_count, clear_busy);
    end

    $display("tb_reuse_ssm_state_reset_ctrl PASS");
    $finish;
  end
endmodule
