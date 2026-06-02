`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: slm_block_controller
// Function:
//   Clean block-level orchestration for the exact datapath.
//   This module replaces the ad-hoc flag coupling in the legacy block top
//   with an explicit FSM, while preserving the original execution order:
//     RMSNorm -> in_proj -> u activation fill -> SSM/p capture -> out_proj
//---------------------------------------------------------------

module slm_block_controller (
    input  logic clk,
    input  logic rst_n,
    input  logic block_start,

    input  logic norm_done,
    input  logic inproj_done,
    input  logic uact_fill_done,
    input  logic ssm_done,
    input  logic outproj_done,

    output logic norm_start,
    output logic inproj_start,
    output logic ssm_start,
    output logic outproj_start,
    output logic uact_fill_active,
    output logic block_busy,
    output logic block_done
);
    typedef enum logic [2:0] {
        ST_IDLE,
        ST_NORM,
        ST_INPROJ,
        ST_WAIT_UACT,
        ST_SSM,
        ST_OUTPROJ,
        ST_DONE
    } state_t;

    state_t state;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state <= ST_IDLE;
        end else begin
            case (state)
                ST_IDLE: begin
                    if (block_start) begin
                        state <= ST_NORM;
                    end
                end
                ST_NORM: begin
                    if (norm_done) begin
                        state <= ST_INPROJ;
                    end
                end
                ST_INPROJ: begin
                    if (inproj_done) begin
                        state <= ST_WAIT_UACT;
                    end
                end
                ST_WAIT_UACT: begin
                    if (uact_fill_done) begin
                        state <= ST_SSM;
                    end
                end
                ST_SSM: begin
                    if (ssm_done) begin
                        state <= ST_OUTPROJ;
                    end
                end
                ST_OUTPROJ: begin
                    if (outproj_done) begin
                        state <= ST_DONE;
                    end
                end
                ST_DONE: begin
                    state <= ST_IDLE;
                end
                default: begin
                    state <= ST_IDLE;
                end
            endcase
        end
    end

    assign norm_start = (state == ST_IDLE) && block_start;
    assign inproj_start = (state == ST_NORM) && norm_done;
    assign ssm_start = (state == ST_WAIT_UACT) && uact_fill_done;
    assign outproj_start = (state == ST_SSM) && ssm_done;
    assign uact_fill_active = (state == ST_WAIT_UACT);
    assign block_busy = (state != ST_IDLE) && (state != ST_DONE);
    assign block_done = (state == ST_DONE);
endmodule

