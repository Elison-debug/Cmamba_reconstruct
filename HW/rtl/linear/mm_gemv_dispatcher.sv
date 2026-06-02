`timescale 1ns/1ps

import mm_gemv_job_pkg::*;

module mm_gemv_dispatcher (
    input  logic clk,
    input  logic rst_n,
    input  logic job_valid,
    output logic job_ready,
    input  mm_gemv_job_t job_in,
    output logic issue_valid,
    input  logic issue_ready,
    output mm_gemv_job_t issue_job
);
    logic full;
    mm_gemv_job_t job_q;

    assign job_ready  = !full;
    assign issue_valid = full;
    assign issue_job   = job_q;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            full <= 1'b0;
            job_q <= '0;
        end else begin
            if (job_valid && job_ready) begin
                full <= 1'b1;
                job_q <= job_in;
            end else if (issue_valid && issue_ready) begin
                full <= 1'b0;
            end
        end
    end
endmodule


