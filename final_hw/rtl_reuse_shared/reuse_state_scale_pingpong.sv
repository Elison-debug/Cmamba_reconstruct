`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: reuse_state_scale_pingpong
// Function:
//   2-bank ping-pong buffer for SSM scaled-state inputs.
//   It decouples join output from ew_update input and computes
//   per-lane runtime scale factors from current u(q8.8).
//---------------------------------------------------------------
module reuse_state_scale_pingpong #(
    parameter int TILE_SIZE = 4,
    parameter int DATA_WIDTH = 16,
    parameter int S_ADDR_W = 6,
    parameter int STATE_SCALE_W = 32,
    parameter int STATE_SCALE_FRAC_BITS = 16
)(
    input  logic clk,
    input  logic rst_n,
    input  logic in_valid,
    output logic in_ready,
    input  logic [S_ADDR_W-1:0] in_addr,
    input  logic [DATA_WIDTH-1:0] in_lam_vec [TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] in_u_vec [TILE_SIZE-1:0],
    output logic out_valid,
    input  logic out_ready,
    output logic [S_ADDR_W-1:0] out_addr,
    output logic [DATA_WIDTH-1:0] out_lam_vec [TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0] out_u_vec [TILE_SIZE-1:0],
    output logic [STATE_SCALE_W-1:0] out_u_to_state_scale_vec [TILE_SIZE-1:0],
    output logic [STATE_SCALE_W-1:0] out_state_to_q88_scale_vec [TILE_SIZE-1:0]
);
    function automatic logic [STATE_SCALE_W-1:0] calc_u_to_state_q16(
        input logic signed [DATA_WIDTH-1:0] u_q88
    );
        logic [DATA_WIDTH:0] abs_u;
        logic [DATA_WIDTH:0] abs_u_eff;
        logic [63:0] num_u;
        logic [63:0] den_u;
        logic [63:0] q_u;
        begin
            if (u_q88[DATA_WIDTH-1]) begin
                if (u_q88 == {1'b1, {(DATA_WIDTH-1){1'b0}}})
                    abs_u = ({{DATA_WIDTH{1'b0}}, 1'b1} << (DATA_WIDTH-1));
                else
                    abs_u = -u_q88;
            end else begin
                abs_u = u_q88;
            end
            abs_u_eff = (abs_u == '0) ? {{(DATA_WIDTH-8){1'b0}}, 9'd256} : abs_u;
            num_u = (64'd32767 << STATE_SCALE_FRAC_BITS) + (abs_u_eff >> 1);
            den_u = abs_u_eff;
            q_u = num_u / den_u;
            if (q_u > {STATE_SCALE_W{1'b1}})
                calc_u_to_state_q16 = {STATE_SCALE_W{1'b1}};
            else
                calc_u_to_state_q16 = q_u[STATE_SCALE_W-1:0];
        end
    endfunction

    function automatic logic [STATE_SCALE_W-1:0] calc_state_to_q88_q16(
        input logic signed [DATA_WIDTH-1:0] u_q88
    );
        logic [DATA_WIDTH:0] abs_u;
        logic [DATA_WIDTH:0] abs_u_eff;
        logic [63:0] num_s;
        logic [63:0] q_s;
        begin
            if (u_q88[DATA_WIDTH-1]) begin
                if (u_q88 == {1'b1, {(DATA_WIDTH-1){1'b0}}})
                    abs_u = ({{DATA_WIDTH{1'b0}}, 1'b1} << (DATA_WIDTH-1));
                else
                    abs_u = -u_q88;
            end else begin
                abs_u = u_q88;
            end
            abs_u_eff = (abs_u == '0) ? {{(DATA_WIDTH-8){1'b0}}, 9'd256} : abs_u;
            num_s = (abs_u_eff << STATE_SCALE_FRAC_BITS) + 64'd16383;
            q_s = num_s / 64'd32767;
            if (q_s > {STATE_SCALE_W{1'b1}})
                calc_state_to_q88_q16 = {STATE_SCALE_W{1'b1}};
            else
                calc_state_to_q88_q16 = q_s[STATE_SCALE_W-1:0];
        end
    endfunction

    logic wr_ptr, rd_ptr;
    logic [1:0] used_cnt;
    logic [S_ADDR_W-1:0] buf_addr [1:0];
    logic [DATA_WIDTH-1:0] buf_lam [1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] buf_u [1:0][TILE_SIZE-1:0];
    logic [STATE_SCALE_W-1:0] buf_u2s [1:0][TILE_SIZE-1:0];
    logic [STATE_SCALE_W-1:0] buf_s2q [1:0][TILE_SIZE-1:0];
    logic in_fire, out_fire;

    assign in_ready = (used_cnt != 2'd2);
    assign out_valid = (used_cnt != 2'd0);
    assign in_fire = in_valid && in_ready;
    assign out_fire = out_valid && out_ready;

    always_comb begin
        out_addr = buf_addr[rd_ptr];
        for (int i = 0; i < TILE_SIZE; i++) begin
            out_lam_vec[i] = buf_lam[rd_ptr][i];
            out_u_vec[i] = buf_u[rd_ptr][i];
            out_u_to_state_scale_vec[i] = buf_u2s[rd_ptr][i];
            out_state_to_q88_scale_vec[i] = buf_s2q[rd_ptr][i];
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            wr_ptr <= 1'b0;
            rd_ptr <= 1'b0;
            used_cnt <= 2'd0;
            for (int b = 0; b < 2; b++) begin
                buf_addr[b] <= '0;
                for (int i = 0; i < TILE_SIZE; i++) begin
                    buf_lam[b][i] <= '0;
                    buf_u[b][i] <= '0;
                    buf_u2s[b][i] <= '0;
                    buf_s2q[b][i] <= '0;
                end
            end
        end else begin
            if (in_fire) begin
                buf_addr[wr_ptr] <= in_addr;
                for (int i = 0; i < TILE_SIZE; i++) begin
                    buf_lam[wr_ptr][i] <= in_lam_vec[i];
                    buf_u[wr_ptr][i] <= in_u_vec[i];
                    buf_u2s[wr_ptr][i] <= calc_u_to_state_q16(in_u_vec[i]);
                    buf_s2q[wr_ptr][i] <= calc_state_to_q88_q16(in_u_vec[i]);
                end
            end

            if (in_fire && !out_fire) begin
                wr_ptr <= ~wr_ptr;
                used_cnt <= used_cnt + 1'b1;
            end else if (!in_fire && out_fire) begin
                rd_ptr <= ~rd_ptr;
                used_cnt <= used_cnt - 1'b1;
            end else if (in_fire && out_fire) begin
                wr_ptr <= ~wr_ptr;
                rd_ptr <= ~rd_ptr;
            end
        end
    end
endmodule
