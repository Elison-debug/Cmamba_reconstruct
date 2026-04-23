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
    logic wr_ptr, rd_ptr;
    logic [1:0] used_cnt;
    logic [S_ADDR_W-1:0] buf_addr [1:0];
    logic [DATA_WIDTH-1:0] buf_lam [1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] buf_u [1:0][TILE_SIZE-1:0];
    logic [STATE_SCALE_W-1:0] buf_u2s [1:0][TILE_SIZE-1:0];
    logic [STATE_SCALE_W-1:0] buf_s2q [1:0][TILE_SIZE-1:0];
    logic out_fire;

    logic in_busy;
    logic in_valid_r;
    logic [S_ADDR_W-1:0] in_addr_r;
    logic [DATA_WIDTH-1:0] in_lam_r [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] in_u_r [TILE_SIZE-1:0];
    logic lane_busy [TILE_SIZE-1:0];
    logic lane_done [TILE_SIZE-1:0];
    logic [STATE_SCALE_W-1:0] lane_u2s [TILE_SIZE-1:0];
    logic [STATE_SCALE_W-1:0] lane_s2q [TILE_SIZE-1:0];
    logic start_lane;
    logic all_lane_done;
    logic write_fire;
    logic start_lane_r;

    assign in_ready = (used_cnt != 2'd2) && !in_busy;
    assign out_valid = (used_cnt != 2'd0);
    assign out_fire = out_valid && out_ready;
    assign write_fire = in_busy && all_lane_done && (used_cnt != 2'd2);

    always_comb begin
        all_lane_done = 1'b1;
        for (int i = 0; i < TILE_SIZE; i++) begin
            all_lane_done &= lane_done[i];
        end
        out_addr = buf_addr[rd_ptr];
        for (int i = 0; i < TILE_SIZE; i++) begin
            out_lam_vec[i] = buf_lam[rd_ptr][i];
            out_u_vec[i] = buf_u[rd_ptr][i];
            out_u_to_state_scale_vec[i] = buf_u2s[rd_ptr][i];
            out_state_to_q88_scale_vec[i] = buf_s2q[rd_ptr][i];
        end
    end

    genvar gi;
    generate
        for (gi = 0; gi < TILE_SIZE; gi++) begin : g_lane_scale
            reuse_runtime_scale_lane_seq #(
                .DATA_WIDTH(DATA_WIDTH),
                .SCALE_W(STATE_SCALE_W),
                .SCALE_FRAC_BITS(STATE_SCALE_FRAC_BITS)
            ) u_lane (
                .clk             (clk),
                .rst_n           (rst_n),
                .start           (start_lane),
                .u_q88           (in_u_r[gi]),
                .busy            (lane_busy[gi]),
                .done            (lane_done[gi]),
                .u_to_state_q16  (lane_u2s[gi]),
                .state_to_q88_q16(lane_s2q[gi])
            );
        end
    endgenerate

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            wr_ptr <= 1'b0;
            rd_ptr <= 1'b0;
            used_cnt <= 2'd0;
            in_busy <= 1'b0;
            in_valid_r <= 1'b0;
            in_addr_r <= '0;
            start_lane_r <= 1'b0;
            for (int b = 0; b < 2; b++) begin
                buf_addr[b] <= '0;
                for (int i = 0; i < TILE_SIZE; i++) begin
                    buf_lam[b][i] <= '0;
                    buf_u[b][i] <= '0;
                    buf_u2s[b][i] <= '0;
                    buf_s2q[b][i] <= '0;
                end
            end
            for (int i = 0; i < TILE_SIZE; i++) begin
                in_lam_r[i] <= '0;
                in_u_r[i] <= '0;
            end
        end else begin
            start_lane_r <= 1'b0;
            if (!in_busy && in_valid && in_ready) begin
                in_busy <= 1'b1;
                in_valid_r <= 1'b1;
                in_addr_r <= in_addr;
                start_lane_r <= 1'b1;
                for (int i = 0; i < TILE_SIZE; i++) begin
                    in_lam_r[i] <= in_lam_vec[i];
                    in_u_r[i] <= in_u_vec[i];
                end
            end

            if (write_fire) begin
                buf_addr[wr_ptr] <= in_addr_r;
                for (int i = 0; i < TILE_SIZE; i++) begin
                    buf_lam[wr_ptr][i] <= in_lam_r[i];
                    buf_u[wr_ptr][i] <= in_u_r[i];
                    buf_u2s[wr_ptr][i] <= lane_u2s[i];
                    buf_s2q[wr_ptr][i] <= lane_s2q[i];
                end
                in_busy <= 1'b0;
                in_valid_r <= 1'b0;
            end

            if (write_fire && !out_fire) begin
                wr_ptr <= ~wr_ptr;
                used_cnt <= used_cnt + 1'b1;
            end else if (!write_fire && out_fire) begin
                rd_ptr <= ~rd_ptr;
                used_cnt <= used_cnt - 1'b1;
            end else if (write_fire && out_fire) begin
                wr_ptr <= ~wr_ptr;
                rd_ptr <= ~rd_ptr;
            end
        end
    end

    assign start_lane = start_lane_r;
endmodule
