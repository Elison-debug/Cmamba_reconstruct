`timescale 1ns/1ps

import slm_chain_cfg_pkg::*;

module slm_chain_controller #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int H_ROWS     = MM_EXACT_DEFAULT_H_ROWS,
    parameter int N_BLOCKS   = MM_EXACT_DEFAULT_N_BLOCKS,
    parameter bit INTER_BLOCK_PIPELINE = 1
) (
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    output logic busy,
    output logic done,

    input  logic                         h_wr_en,
    input  logic [4:0]                   h_wr_addr,
    input  logic signed [DATA_WIDTH-1:0] h_wr_data [TILE_SIZE-1:0],

    output logic launch_req [0:N_BLOCKS-1],
    input  logic blk_busy   [0:N_BLOCKS-1],
    input  logic blk_done   [0:N_BLOCKS-1],

    input  logic blk_y_valid [0:N_BLOCKS-1],
    output logic blk_y_ready [0:N_BLOCKS-1],
    input  logic signed [DATA_WIDTH-1:0] blk_y_data [0:N_BLOCKS-1][TILE_SIZE-1:0],

    output logic blk_h_wr_en [0:N_BLOCKS-1],
    output logic [4:0] blk_h_wr_addr [0:N_BLOCKS-1],
    output logic signed [DATA_WIDTH-1:0] blk_h_wr_data [0:N_BLOCKS-1][TILE_SIZE-1:0],

    output logic                         y_valid,
    input  logic                         y_ready,
    output logic signed [DATA_WIDTH-1:0] y_data [TILE_SIZE-1:0]
);
    localparam int BLK_W = (N_BLOCKS <= 1) ? 1 : $clog2(N_BLOCKS);

    function automatic logic signed [DATA_WIDTH-1:0] sat_add_s16(
        input logic signed [DATA_WIDTH-1:0] a,
        input logic signed [DATA_WIDTH-1:0] b
    );
        logic signed [DATA_WIDTH:0] s;
        begin
            s = $signed(a) + $signed(b);
            if (s > 17'sd32767) sat_add_s16 = 16'sd32767;
            else if (s < -17'sd32768) sat_add_s16 = -16'sd32768;
            else sat_add_s16 = s[DATA_WIDTH-1:0];
        end
    endfunction

    typedef enum logic [1:0] {
        ST_IDLE    = 2'd0,
        ST_RUN     = 2'd1,
        ST_PRELOAD = 2'd2,
        ST_LAUNCH  = 2'd3
    } chain_state_t;

    localparam slm_chain_cfg_t CHAIN_CFG = make_chain_cfg(INTER_BLOCK_PIPELINE, H_ROWS, N_BLOCKS);

    chain_state_t state;
    logic [BLK_W-1:0] cur_blk;
    logic [$clog2(H_ROWS+1)-1:0] y_row_cnt;
    logic [$clog2(H_ROWS+1)-1:0] preload_row_cnt;
    logic signed [DATA_WIDTH-1:0] h0_shadow [0:H_ROWS-1][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] residual_cur [0:H_ROWS-1][TILE_SIZE-1:0];
    logic pipe_wr_valid;
    logic [BLK_W-1:0] pipe_wr_blk;
    logic [4:0] pipe_wr_addr;
    logic signed [DATA_WIDTH-1:0] pipe_wr_data [TILE_SIZE-1:0];

    always_comb begin
        for (int b = 0; b < N_BLOCKS; b++) begin
            blk_h_wr_en[b] = 1'b0;
            blk_h_wr_addr[b] = 5'd0;
            blk_y_ready[b] = 1'b0;
            launch_req[b] = 1'b0;
            for (int lane = 0; lane < TILE_SIZE; lane++) begin
                blk_h_wr_data[b][lane] = '0;
            end
        end

        if (!busy && h_wr_en) begin
            blk_h_wr_en[0] = 1'b1;
            blk_h_wr_addr[0] = h_wr_addr;
            for (int lane = 0; lane < TILE_SIZE; lane++) begin
                blk_h_wr_data[0][lane] = h_wr_data[lane];
            end
        end else if (state == ST_PRELOAD && (cur_blk < (N_BLOCKS-1))) begin
            blk_h_wr_en[cur_blk + 1'b1] = 1'b1;
            blk_h_wr_addr[cur_blk + 1'b1] = preload_row_cnt[4:0];
            for (int lane = 0; lane < TILE_SIZE; lane++) begin
                blk_h_wr_data[cur_blk + 1'b1][lane] = residual_cur[preload_row_cnt][lane];
            end
        end else if (CHAIN_CFG.inter_block_pipeline && pipe_wr_valid) begin
            blk_h_wr_en[pipe_wr_blk] = 1'b1;
            blk_h_wr_addr[pipe_wr_blk] = pipe_wr_addr;
            for (int lane = 0; lane < TILE_SIZE; lane++) begin
                blk_h_wr_data[pipe_wr_blk][lane] = pipe_wr_data[lane];
            end
        end

        if (state == ST_RUN) begin
            if (blk_busy[cur_blk]) begin
                if (cur_blk == (N_BLOCKS-1)) begin
                    blk_y_ready[N_BLOCKS-1] = y_ready;
                end else begin
                    blk_y_ready[cur_blk] = 1'b1;
                end
            end
        end

        if (state == ST_IDLE && start && !busy) begin
            launch_req[0] = 1'b1;
        end
        if (state == ST_LAUNCH) begin
            launch_req[cur_blk] = 1'b1;
        end
    end

    always_comb begin
        y_valid = (state == ST_RUN && cur_blk == (N_BLOCKS-1) && blk_busy[N_BLOCKS-1]) ? blk_y_valid[N_BLOCKS-1] : 1'b0;
        for (int lane = 0; lane < TILE_SIZE; lane++) begin
            y_data[lane] = blk_y_data[N_BLOCKS-1][lane];
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state <= ST_IDLE;
            busy <= 1'b0;
            done <= 1'b0;
            cur_blk <= '0;
            y_row_cnt <= '0;
            preload_row_cnt <= '0;
            pipe_wr_valid <= 1'b0;
            pipe_wr_blk <= '0;
            pipe_wr_addr <= '0;
            for (int r = 0; r < H_ROWS; r++) begin
                for (int lane = 0; lane < TILE_SIZE; lane++) begin
                    h0_shadow[r][lane] <= '0;
                    residual_cur[r][lane] <= '0;
                end
            end
            for (int lane = 0; lane < TILE_SIZE; lane++) begin
                pipe_wr_data[lane] <= '0;
            end
        end else begin
            done <= 1'b0;
            if (pipe_wr_valid) begin
                pipe_wr_valid <= 1'b0;
            end

            if (!busy && h_wr_en) begin
                for (int lane = 0; lane < TILE_SIZE; lane++) begin
                    h0_shadow[h_wr_addr][lane] <= h_wr_data[lane];
                end
            end

            case (state)
                ST_IDLE: begin
                    if (start && !busy) begin
                        busy <= 1'b1;
                        cur_blk <= '0;
                        y_row_cnt <= '0;
                        preload_row_cnt <= '0;
                        for (int r = 0; r < H_ROWS; r++) begin
                            for (int lane = 0; lane < TILE_SIZE; lane++) begin
                                residual_cur[r][lane] <= h0_shadow[r][lane];
                            end
                        end
                        state <= ST_RUN;
                    end
                end

                ST_RUN: begin
                    if (blk_busy[cur_blk] && blk_y_valid[cur_blk] && blk_y_ready[cur_blk]) begin
                        if (cur_blk < (N_BLOCKS-1)) begin
                            for (int lane = 0; lane < TILE_SIZE; lane++) begin
                                residual_cur[y_row_cnt][lane] <= sat_add_s16(residual_cur[y_row_cnt][lane], blk_y_data[cur_blk][lane]);
                                pipe_wr_data[lane] <= sat_add_s16(residual_cur[y_row_cnt][lane], blk_y_data[cur_blk][lane]);
                            end
                            if (CHAIN_CFG.inter_block_pipeline) begin
                                pipe_wr_valid <= 1'b1;
                                pipe_wr_blk <= cur_blk + 1'b1;
                                pipe_wr_addr <= y_row_cnt[4:0];
                            end
                        end
                        if (y_row_cnt == (H_ROWS-1)) begin
                            if (cur_blk == (N_BLOCKS-1)) begin
                                busy <= 1'b0;
                                done <= 1'b1;
                                state <= ST_IDLE;
                            end else begin
                                if (CHAIN_CFG.inter_block_pipeline) begin
                                    cur_blk <= cur_blk + 1'b1;
                                    y_row_cnt <= '0;
                                    state <= ST_LAUNCH;
                                end else begin
                                    preload_row_cnt <= '0;
                                    state <= ST_PRELOAD;
                                end
                            end
                        end else begin
                            y_row_cnt <= y_row_cnt + 1'b1;
                        end
                    end
                end

                ST_PRELOAD: begin
                    if (preload_row_cnt == (H_ROWS-1)) begin
                        cur_blk <= cur_blk + 1'b1;
                        y_row_cnt <= '0;
                        state <= ST_LAUNCH;
                    end else begin
                        preload_row_cnt <= preload_row_cnt + 1'b1;
                    end
                end

                ST_LAUNCH: begin
                    state <= ST_RUN;
                end

                default: state <= ST_IDLE;
            endcase
        end
    end
endmodule

