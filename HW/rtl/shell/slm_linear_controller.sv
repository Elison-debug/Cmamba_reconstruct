`timescale 1ns/1ps

import slm_linear_cfg_pkg::*;

//---------------------------------------------------------------
// Module: slm_linear_controller
// Function:
//   Unified lifecycle controller for a linear operator stage.
//   This module standardizes launch / busy / done semantics and keeps the
//   stage descriptor attached to the active transaction so block-level control
//   and future scheduling policies can reason about linear operators through
//   one interface.
//---------------------------------------------------------------
module slm_linear_controller #(
    parameter slm_linear_desc_t STAGE_DESC = make_linear_desc(
        SLM_LINEAR_INPROJ, 2'b00, 1'b1, 1'b0, 8'd0, 8'd0, 16'd0
    )
)(
    input  logic clk,
    input  logic rst_n,
    input  logic launch_req,
    input  logic op_busy_i,
    input  logic op_done_i,
    output logic op_start_pulse,
    output logic op_busy_o,
    output logic op_done_o,
    output logic desc_active,
    output slm_linear_desc_t active_desc
);
    logic active_q;
    logic done_seen_q;

    assign active_desc = STAGE_DESC;
    assign desc_active = active_q;
    assign op_busy_o = active_q;
    assign op_done_o = done_seen_q;
    assign op_start_pulse = launch_req && !active_q;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            active_q <= 1'b0;
            done_seen_q <= 1'b0;
        end else begin
            done_seen_q <= 1'b0;

            if (launch_req && !active_q) begin
                active_q <= 1'b1;
            end

            if (active_q && op_done_i) begin
                active_q <= 1'b0;
                done_seen_q <= 1'b1;
            end else if (active_q && !op_busy_i && !launch_req) begin
                // Defensive fallback: an operator should normally assert done,
                // but the controller releases ownership if the stage goes
                // idle without an explicit done pulse.
                active_q <= 1'b0;
                done_seen_q <= 1'b1;
            end
        end
    end
endmodule

