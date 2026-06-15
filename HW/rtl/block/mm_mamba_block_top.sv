`timescale 1ns/1ps

import mm_gemv_job_pkg::*;

module mm_mamba_block_top #(
    parameter int TILE_SIZE = 4,
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH = 32,
    parameter int STATE_ADDR_W = 6
)(
    input  logic clk,
    input  logic rst_n,
    input  logic block_start,
    input  logic state_continuous_en,
    output logic block_busy,
    output logic block_done,
    output logic state_clear_done
);
    mm_gemv_job_t dispatch_job;
    logic dispatch_valid, dispatch_ready;
    logic issue_valid, issue_ready;
    mm_gemv_job_t issue_job;

    logic eng_valid_in, eng_valid_out;
    logic [1:0] eng_mode;
    logic [6:0] eng_col_blocks;
    logic eng_reduce_rows;
    logic signed [ACC_WIDTH-1:0] eng_reduced_vec [TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] eng_reduced_mat_0 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] eng_reduced_mat_1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] eng_reduced_mat_2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] eng_reduced_mat_3 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic gemv_busy, gemv_done;
    logic [15:0] gemv_done_job_id;
    logic result_valid;
    mm_op_t result_op;
    logic [15:0] result_job_id;
    logic signed [ACC_WIDTH-1:0] result_vec [TILE_SIZE-1:0];

    logic signed [DATA_WIDTH-1:0] A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic p_valid, p_ready;
    logic [STATE_ADDR_W-1:0] p_addr;
    logic signed [DATA_WIDTH-1:0] p_vec [TILE_SIZE-1:0];

    logic dt_valid;
    logic dt_ready;
    logic [STATE_ADDR_W-1:0] dt_addr;
    logic [DATA_WIDTH-1:0] lam_vec [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] u_vec [TILE_SIZE-1:0];
    logic gate_valid;
    logic gate_ready;
    logic signed [DATA_WIDTH-1:0] gate_vec [TILE_SIZE-1:0];
    logic [STATE_ADDR_W-1:0] state_addr_ctr;

    always_comb begin
        p_ready = 1'b1;

        // Bring-up matrix generation to avoid zero-only datapaths.
        for (int i = 0; i < TILE_SIZE; i++) begin
            for (int j = 0; j < TILE_SIZE; j++) begin
                A0_mat[i][j] = u_vec[j];
                A1_mat[i][j] = gate_vec[j];
                A2_mat[i][j] = $signed({1'b0, lam_vec[j][DATA_WIDTH-2:0]});
                A3_mat[i][j] = (i == j) ? $signed(16'sd256) : $signed(16'sd0);
                B0_mat[i][j] = (i == j) ? $signed(16'sd256) : $signed(16'sd0);
                B1_mat[i][j] = (i == j) ? $signed(16'sd128) : $signed(16'sd0);
                B2_mat[i][j] = (i == j) ? $signed(16'sd64)  : $signed(16'sd0);
                B3_mat[i][j] = (i == j) ? $signed(16'sd32)  : $signed(16'sd0);
            end
        end
    end

    // Minimal dataflow used by the prototype block top:
    // - capture INPROJ vector as state input and gate input
    // - capture DTPROJ vector as lambda
    // - pulse dt_valid when dt result arrives
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            dt_valid <= 1'b0;
            gate_valid <= 1'b0;
            state_addr_ctr <= '0;
            dt_addr <= '0;
            lam_vec <= '{default:'0};
            u_vec <= '{default:'0};
            gate_vec <= '{default:'0};
        end else begin
            dt_valid <= 1'b0;
            gate_valid <= 1'b0;
            if (result_valid) begin
                case (result_op)
                    MM_OP_INPROJ: begin
                        for (int i = 0; i < TILE_SIZE; i++) begin
                            u_vec[i] <= result_vec[i][DATA_WIDTH-1:0];
                            gate_vec[i] <= result_vec[i][DATA_WIDTH-1:0];
                        end
                    end
                    MM_OP_DTPROJ: begin
                        for (int i = 0; i < TILE_SIZE; i++) begin
                            lam_vec[i] <= result_vec[i][DATA_WIDTH-1:0];
                        end
                        dt_addr <= state_addr_ctr;
                        dt_valid <= 1'b1;
                        gate_valid <= 1'b1;
                        if (dt_ready && gate_ready) begin
                            state_addr_ctr <= state_addr_ctr + 1'b1;
                        end
                    end
                    default: begin
                    end
                endcase
            end
        end
    end

    mm_block_controller u_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .block_start(block_start),
        .block_busy(block_busy),
        .block_done(block_done),
        .job_valid(dispatch_valid),
        .job_ready(dispatch_ready),
        .job_out(dispatch_job),
        .gemv_done(gemv_done),
        .gemv_done_job_id(gemv_done_job_id)
    );

    mm_gemv_dispatcher u_dispatcher (
        .clk(clk),
        .rst_n(rst_n),
        .job_valid(dispatch_valid),
        .job_ready(dispatch_ready),
        .job_in(dispatch_job),
        .issue_valid(issue_valid),
        .issue_ready(issue_ready),
        .issue_job(issue_job)
    );

    mm_gemv_scheduler #(
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) u_sched (
        .clk(clk),
        .rst_n(rst_n),
        .job_valid(issue_valid),
        .job_ready(issue_ready),
        .job_in(issue_job),
        .eng_valid_in(eng_valid_in),
        .eng_mode(eng_mode),
        .eng_col_blocks(eng_col_blocks),
        .eng_reduce_rows(eng_reduce_rows),
        .eng_valid_out(eng_valid_out),
        .eng_reduced_vec(eng_reduced_vec),
        .result_valid(result_valid),
        .result_op(result_op),
        .result_job_id(result_job_id),
        .result_vec(result_vec),
        .busy(gemv_busy),
        .done(gemv_done),
        .done_job_id(gemv_done_job_id)
    );

    mm_shared_gemv_engine #(
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) u_engine (
        .clk(clk),
        .rst_n(rst_n),
        .mode(eng_mode),
        .col_blocks_cfg(eng_col_blocks),
        .reduce_rows(eng_reduce_rows),
        .valid_in(eng_valid_in),
        .A0_mat(A0_mat),
        .A1_mat(A1_mat),
        .A2_mat(A2_mat),
        .A3_mat(A3_mat),
        .B0_mat(B0_mat),
        .B1_mat(B1_mat),
        .B2_mat(B2_mat),
        .B3_mat(B3_mat),
        .reduced_vec(eng_reduced_vec),
        .reduced_mat_0(eng_reduced_mat_0),
        .reduced_mat_1(eng_reduced_mat_1),
        .reduced_mat_2(eng_reduced_mat_2),
        .reduced_mat_3(eng_reduced_mat_3),
        .valid_reduced(eng_valid_out)
    );

    mm_state_datapath #(
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .STATE_ADDR_W(STATE_ADDR_W)
    ) u_state_path (
        .clk(clk),
        .rst_n(rst_n),
        .state_frame_start(block_start),
        .state_continuous_en(state_continuous_en),
        .state_force_clear(1'b0),
        .state_clear_done(state_clear_done),
        .dt_valid(dt_valid),
        .dt_ready(dt_ready),
        .dt_addr(dt_addr),
        .lam_vec(lam_vec),
        .u_vec(u_vec),
        .gate_valid(gate_valid),
        .gate_ready(gate_ready),
        .gate_vec(gate_vec),
        .p_valid(p_valid),
        .p_ready(p_ready),
        .p_addr(p_addr),
        .p_vec(p_vec)
    );
endmodule


