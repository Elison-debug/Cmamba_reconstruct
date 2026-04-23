`timescale 1ns/1ps

module reuse_block_ctrl (
    input  logic clk,
    input  logic rst_n,
    input  logic launch_req,
    input  logic block_busy_i,
    input  logic block_done_i,
    output logic block_start_pulse,
    output logic block_busy_o,
    output logic block_done_o
);
    logic launch_pending;
    logic launch_fired;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            block_start_pulse <= 1'b0;
            launch_pending    <= 1'b0;
            launch_fired      <= 1'b0;
        end else begin
            block_start_pulse <= 1'b0;

            if (launch_req) begin
                launch_pending <= 1'b1;
                launch_fired   <= 1'b0;
            end

            // Fire at most one start pulse per launch request.
            if (launch_pending && !launch_fired && !block_busy_i) begin
                block_start_pulse <= 1'b1;
                launch_fired      <= 1'b1;
            end

            if (block_busy_i) begin
                launch_pending <= 1'b0;
                launch_fired   <= 1'b0;
            end
        end
    end

    assign block_busy_o = block_busy_i;
    assign block_done_o = block_done_i;
endmodule
