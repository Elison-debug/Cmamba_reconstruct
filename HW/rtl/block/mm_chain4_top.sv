`timescale 1ns/1ps

module mm_chain4_top #(
    parameter int N_BLOCKS = 4,
    parameter bit STATE_CONTINUOUS_DEFAULT = 0
)(
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    output logic busy,
    output logic done
);
    typedef enum logic [1:0] {
        ST_IDLE,
        ST_RUN,
        ST_DONE
    } chain_state_t;

    chain_state_t st;
    logic [1:0] blk_idx;

    logic [N_BLOCKS-1:0] blk_start;
    logic [N_BLOCKS-1:0] blk_busy;
    logic [N_BLOCKS-1:0] blk_done;
    logic [N_BLOCKS-1:0] blk_state_clear_done;

    genvar gi;
    generate
        for (gi = 0; gi < N_BLOCKS; gi++) begin : g_blk
            mm_mamba_block_top u_blk (
                .clk(clk),
                .rst_n(rst_n),
                .block_start(blk_start[gi]),
                .state_continuous_en(STATE_CONTINUOUS_DEFAULT),
                .block_busy(blk_busy[gi]),
                .block_done(blk_done[gi]),
                .state_clear_done(blk_state_clear_done[gi])
            );
        end
    endgenerate

    always_comb begin
        for (int i = 0; i < N_BLOCKS; i++) begin
            blk_start[i] = 1'b0;
        end
        if (st == ST_RUN) begin
            blk_start[blk_idx] = 1'b1;
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            st <= ST_IDLE;
            blk_idx <= '0;
            done <= 1'b0;
        end else begin
            done <= 1'b0;
            case (st)
                ST_IDLE: begin
                    blk_idx <= '0;
                    if (start) begin
                        st <= ST_RUN;
                    end
                end
                ST_RUN: begin
                    if (blk_done[blk_idx]) begin
                        if (blk_idx == N_BLOCKS-1) begin
                            st <= ST_DONE;
                        end else begin
                            blk_idx <= blk_idx + 1'b1;
                        end
                    end
                end
                ST_DONE: begin
                    done <= 1'b1;
                    st <= ST_IDLE;
                end
                default: st <= ST_IDLE;
            endcase
        end
    end

    assign busy = (st == ST_RUN);
endmodule


