`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: reuse_ssm_state_reset_ctrl
// Function:
//   Frame-boundary state clear controller for SSM state RAM.
//   - Stateless mode : clear RAM at each frame_start.
//   - Stateful mode  : keep RAM contents across frames.
//   - force_clear    : software/debug forced clear pulse.
//   - Pipeline-safe  : request quiesce before clear when datapath
//                      has multi-stage in-flight updates.
//
// This module only emits clear write commands. It does not own RAM.
//---------------------------------------------------------------
module reuse_ssm_state_reset_ctrl #(
    parameter int S_ADDR_W = 6,
    parameter int DATA_W   = 64
)(
    input  logic                  clk,
    input  logic                  rst_n,

    // Frame/sample boundary pulse from outer controller.
    input  logic                  frame_start,
    // Optional forced clear request (pulse).
    input  logic                  force_clear,
    // 1: keep state across frames. 0: clear state at frame boundary.
    input  logic                  continuous_state_en,
    // 1: datapath is drained and no in-flight state update remains.
    input  logic                  pipe_quiescent,

    // Clear sequence status.
    output logic                  clear_busy,
    output logic                  clear_done,
    // Request upstream to stop launching new work and drain pipeline.
    output logic                  quiesce_req,
    // Suggested stall signal for datapath feeding scan state.
    output logic                  compute_hold,

    // Clear write command to state RAM.
    output logic                  state_wr_en,
    output logic [S_ADDR_W-1:0]   state_wr_addr,
    output logic [DATA_W-1:0]     state_wr_data
);
    localparam int DEPTH = (1 << S_ADDR_W);

    logic [S_ADDR_W-1:0] clr_addr;
    logic                wait_quiesce;
    wire trigger_clear = force_clear || (frame_start && !continuous_state_en);

    assign quiesce_req   = wait_quiesce || state_wr_en;
    assign clear_busy    = wait_quiesce || state_wr_en;
    assign compute_hold  = wait_quiesce || state_wr_en;
    assign state_wr_addr = clr_addr;
    assign state_wr_data = '0;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state_wr_en <= 1'b0;
            wait_quiesce <= 1'b0;
            clr_addr    <= '0;
            clear_done  <= 1'b0;
        end else begin
            clear_done <= 1'b0;

            if (state_wr_en) begin
                if (clr_addr == S_ADDR_W'(DEPTH - 1)) begin
                    state_wr_en <= 1'b0;
                    clr_addr    <= '0;
                    clear_done  <= 1'b1;
                end else begin
                    clr_addr <= clr_addr + 1'b1;
                end
            end else if (wait_quiesce) begin
                if (pipe_quiescent) begin
                    wait_quiesce <= 1'b0;
                    state_wr_en  <= 1'b1;
                    clr_addr     <= '0;
                end
            end else if (trigger_clear) begin
                if (pipe_quiescent) begin
                    state_wr_en <= 1'b1;
                    clr_addr    <= '0;
                end else begin
                    wait_quiesce <= 1'b1;
                end
            end
        end
    end
endmodule
