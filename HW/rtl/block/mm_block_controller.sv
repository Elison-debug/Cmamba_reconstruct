`timescale 1ns/1ps

import mm_gemv_job_pkg::*;

module mm_block_controller #(
    parameter logic [7:0] INPROJ_ROW_TILES  = 8'd128,
    parameter logic [7:0] INPROJ_K_GROUPS   = 8'd8,
    parameter logic [1:0] INPROJ_MODE       = 2'b00,
    parameter logic       INPROJ_REDUCE     = 1'b1,
    parameter logic       INPROJ_USE_SCALE  = 1'b0,

    parameter logic [7:0] DTPROJ_ROW_TILES  = 8'd64,
    parameter logic [7:0] DTPROJ_K_GROUPS   = 8'd16,
    parameter logic [1:0] DTPROJ_MODE       = 2'b00,
    parameter logic       DTPROJ_REDUCE     = 1'b1,
    parameter logic       DTPROJ_USE_SCALE  = 1'b1,

    parameter logic [7:0] OUTPROJ_ROW_TILES = 8'd32,
    parameter logic [7:0] OUTPROJ_K_GROUPS  = 8'd16,
    parameter logic [1:0] OUTPROJ_MODE      = 2'b00,
    parameter logic       OUTPROJ_REDUCE    = 1'b1,
    parameter logic       OUTPROJ_USE_SCALE = 1'b1
)(
    input  logic clk,
    input  logic rst_n,
    input  logic block_start,
    output logic block_busy,
    output logic block_done,
    output logic job_valid,
    input  logic job_ready,
    output mm_gemv_job_t job_out,
    input  logic gemv_done,
    input  logic [15:0] gemv_done_job_id
);

    typedef enum logic [2:0] {
        ST_IDLE,
        ST_SUBMIT_INPROJ,
        ST_WAIT_INPROJ,
        ST_SUBMIT_DTPROJ,
        ST_WAIT_DTPROJ,
        ST_SUBMIT_OUTPROJ,
        ST_WAIT_OUTPROJ,
        ST_DONE
    } state_t;

    state_t state;
    mm_gemv_job_t job_r;

    assign block_busy = (state != ST_IDLE && state != ST_DONE);
    assign block_done = (state == ST_DONE);
    assign job_valid = (state == ST_SUBMIT_INPROJ) ||
                       (state == ST_SUBMIT_DTPROJ) ||
                       (state == ST_SUBMIT_OUTPROJ);
    assign job_out = job_r;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state <= ST_IDLE;
            job_r <= '0;
        end else begin
            case (state)
                ST_IDLE: begin
                    if (block_start) begin
                        job_r <= '{op_type:MM_OP_INPROJ, row_tiles:INPROJ_ROW_TILES, k_groups:INPROJ_K_GROUPS,
                                   mode:INPROJ_MODE, reduce_rows:INPROJ_REDUCE,
                                   use_per_channel_scale:INPROJ_USE_SCALE, job_id:16'd1};
                        state <= ST_SUBMIT_INPROJ;
                    end
                end
                ST_SUBMIT_INPROJ: if (job_ready) state <= ST_WAIT_INPROJ;
                ST_WAIT_INPROJ: begin
                    if (gemv_done && gemv_done_job_id == 16'd1) begin
                        job_r <= '{op_type:MM_OP_DTPROJ, row_tiles:DTPROJ_ROW_TILES, k_groups:DTPROJ_K_GROUPS,
                                   mode:DTPROJ_MODE, reduce_rows:DTPROJ_REDUCE,
                                   use_per_channel_scale:DTPROJ_USE_SCALE, job_id:16'd2};
                        state <= ST_SUBMIT_DTPROJ;
                    end
                end
                ST_SUBMIT_DTPROJ: if (job_ready) state <= ST_WAIT_DTPROJ;
                ST_WAIT_DTPROJ: begin
                    if (gemv_done && gemv_done_job_id == 16'd2) begin
                        job_r <= '{op_type:MM_OP_OUTPROJ, row_tiles:OUTPROJ_ROW_TILES, k_groups:OUTPROJ_K_GROUPS,
                                   mode:OUTPROJ_MODE, reduce_rows:OUTPROJ_REDUCE,
                                   use_per_channel_scale:OUTPROJ_USE_SCALE, job_id:16'd3};
                        state <= ST_SUBMIT_OUTPROJ;
                    end
                end
                ST_SUBMIT_OUTPROJ: if (job_ready) state <= ST_WAIT_OUTPROJ;
                ST_WAIT_OUTPROJ: if (gemv_done && gemv_done_job_id == 16'd3) state <= ST_DONE;
                ST_DONE: state <= ST_IDLE;
            endcase
        end
    end
endmodule


