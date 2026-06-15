`timescale 1ns/1ps

import mm_gemv_job_pkg::*;

module mm_gemv_scheduler #(
    parameter int TILE_SIZE = 4,
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH = 32
)(
    input  logic clk,
    input  logic rst_n,
    input  logic job_valid,
    output logic job_ready,
    input  mm_gemv_job_t job_in,
    output logic eng_valid_in,
    output logic [1:0] eng_mode,
    output logic [6:0] eng_col_blocks,
    output logic eng_reduce_rows,
    input  logic eng_valid_out,
    input  logic signed [ACC_WIDTH-1:0] eng_reduced_vec [TILE_SIZE-1:0],
    output logic result_valid,
    output mm_op_t result_op,
    output logic [15:0] result_job_id,
    output logic signed [ACC_WIDTH-1:0] result_vec [TILE_SIZE-1:0],
    output logic busy,
    output logic done,
    output logic [15:0] done_job_id
);
    typedef enum logic [1:0] { ST_IDLE, ST_RUN, ST_DONE } state_t;
    state_t state;
    mm_gemv_job_t cur_job;

    assign job_ready       = (state == ST_IDLE);
    assign eng_valid_in    = (state == ST_RUN);
    assign eng_mode        = cur_job.mode;
    assign eng_col_blocks  = cur_job.k_groups[6:0];
    assign eng_reduce_rows = cur_job.reduce_rows;
    assign busy            = (state != ST_IDLE);
    assign done            = (state == ST_DONE);
    assign done_job_id     = cur_job.job_id;
    assign result_valid    = (state == ST_RUN) && eng_valid_out;
    assign result_op       = cur_job.op_type;
    assign result_job_id   = cur_job.job_id;
    assign result_vec      = eng_reduced_vec;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state <= ST_IDLE;
            cur_job <= '0;
        end else begin
            case (state)
                ST_IDLE: begin
                    if (job_valid) begin
                        cur_job <= job_in;
                        state <= ST_RUN;
                    end
                end
                ST_RUN: begin
                    if (eng_valid_out) begin
                        state <= ST_DONE;
                    end
                end
                ST_DONE: begin
                    state <= ST_IDLE;
                end
            endcase
        end
    end
endmodule


