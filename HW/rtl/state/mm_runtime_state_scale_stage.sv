`timescale 1ns/1ps

module mm_runtime_state_scale_stage #(
    parameter int TILE_SIZE = 4,
    parameter int DATA_WIDTH = 16,
    parameter int SCALE_W = 32,
    parameter int SCALE_FRAC_BITS = 16
)(
    input  logic clk,
    input  logic rst_n,
    input  logic in_valid,
    output logic in_ready,
    input  logic [5:0] in_addr,
    input  logic [DATA_WIDTH-1:0] in_lam_vec [TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] in_u_vec [TILE_SIZE-1:0],
    output logic out_valid,
    input  logic out_ready,
    output logic [5:0] out_addr,
    output logic [DATA_WIDTH-1:0] out_lam_vec [TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0] out_u_vec [TILE_SIZE-1:0],
    output logic [SCALE_W-1:0] out_u_to_state_scale_vec [TILE_SIZE-1:0],
    output logic [SCALE_W-1:0] out_state_to_q88_scale_vec [TILE_SIZE-1:0]
);
    // Isolated runtime scaling stage for state and lambda vectors.
    // The interface is explicit so the block can route it independently.
    logic wr_ptr, rd_ptr;
    logic [1:0] used_cnt;
    logic [5:0] buf_addr [1:0];
    logic [DATA_WIDTH-1:0] buf_lam [1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] buf_u [1:0][TILE_SIZE-1:0];
    logic [SCALE_W-1:0] buf_u2s [1:0][TILE_SIZE-1:0];
    logic [SCALE_W-1:0] buf_s2q [1:0][TILE_SIZE-1:0];
    logic out_fire;

    logic in_busy;
    logic [5:0] in_addr_r;
    logic [DATA_WIDTH-1:0] in_lam_r [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] in_u_r [TILE_SIZE-1:0];
    logic lane_done [TILE_SIZE-1:0];
    logic [SCALE_W-1:0] lane_u2s [TILE_SIZE-1:0];
    logic [SCALE_W-1:0] lane_s2q [TILE_SIZE-1:0];
    logic start_lane_r;
    logic all_lane_done;
    logic write_fire;

    assign in_ready = (used_cnt != 2'd2) && !in_busy;
    assign out_valid = (used_cnt != 2'd0);
    assign out_fire = out_valid && out_ready;
    assign write_fire = in_busy && all_lane_done && (used_cnt != 2'd2);

    always_comb begin
        all_lane_done = 1'b1;
        out_addr = buf_addr[rd_ptr];
        for (int i = 0; i < TILE_SIZE; i++) begin
            all_lane_done &= lane_done[i];
            out_lam_vec[i] = buf_lam[rd_ptr][i];
            out_u_vec[i] = buf_u[rd_ptr][i];
            out_u_to_state_scale_vec[i] = buf_u2s[rd_ptr][i];
            out_state_to_q88_scale_vec[i] = buf_s2q[rd_ptr][i];
        end
    end

    for (genvar gi = 0; gi < TILE_SIZE; gi++) begin : g_lane_scale
        mm_runtime_state_scale_lane #(
            .DATA_WIDTH(DATA_WIDTH),
            .SCALE_W(SCALE_W),
            .SCALE_FRAC_BITS(SCALE_FRAC_BITS)
        ) u_lane (
            .clk(clk),
            .rst_n(rst_n),
            .start(start_lane_r),
            .u_q88(in_u_r[gi]),
            .done(lane_done[gi]),
            .u_to_state_q16(lane_u2s[gi]),
            .state_to_q88_q16(lane_s2q[gi])
        );
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            wr_ptr <= 1'b0;
            rd_ptr <= 1'b0;
            used_cnt <= 2'd0;
            in_busy <= 1'b0;
            start_lane_r <= 1'b0;
            in_addr_r <= '0;
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
endmodule


