`timescale 1ns/1ps

module mm_shared_gemv_engine #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH  = 32,
    parameter int FRAC_BITS  = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic [1:0] mode,
    input  logic [6:0] col_blocks_cfg,
    input  logic reduce_rows,
    input  logic valid_in,
    input  logic signed [DATA_WIDTH-1:0] A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0] reduced_vec [TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0] reduced_mat_0 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0] reduced_mat_1 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0] reduced_mat_2 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0] reduced_mat_3 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic                        valid_reduced
);
    logic valid_a0, valid_a1, valid_a2, valid_a3;
    logic signed [ACC_WIDTH-1:0] raw_mat_0 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] raw_mat_1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] raw_mat_2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] raw_mat_3 [TILE_SIZE-1:0][TILE_SIZE-1:0];

    logic signed [ACC_WIDTH-1:0] acc_mat_0 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] acc_mat_1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] acc_mat_2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] acc_mat_3 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] sum_col_next [TILE_SIZE-1:0];

    logic [6:0] block_ctr;
    logic running;
    logic last_block;
    logic all_valid;

    assign all_valid = valid_a0 & valid_a1 & valid_a2 & valid_a3;
    assign last_block = running && (block_ctr == col_blocks_cfg - 1'b1);

    always_comb begin
        for (int col = 0; col < TILE_SIZE; col++) begin
            sum_col_next[col] = '0;
            for (int row = 0; row < TILE_SIZE; row++) begin
                sum_col_next[col] += (acc_mat_0[row][col] + raw_mat_0[row][col]);
                sum_col_next[col] += (acc_mat_1[row][col] + raw_mat_1[row][col]);
                sum_col_next[col] += (acc_mat_2[row][col] + raw_mat_2[row][col]);
                sum_col_next[col] += (acc_mat_3[row][col] + raw_mat_3[row][col]);
            end
        end
    end

    mm_array4x4 #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH),
        .FRAC_BITS (FRAC_BITS)
    ) u_array0 (
        .clk(clk),
        .rst_n(rst_n),
        .pe_mode(mode),
        .a_in(A0_mat),
        .b_in(B0_mat),
        .acc_in('{default:'0}),
        .valid_in(valid_in),
        .valid_out(valid_a0),
        .result_out(raw_mat_0)
    );

    mm_array4x4 #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH),
        .FRAC_BITS (FRAC_BITS)
    ) u_array1 (
        .clk(clk),
        .rst_n(rst_n),
        .pe_mode(mode),
        .a_in(A1_mat),
        .b_in(B1_mat),
        .acc_in('{default:'0}),
        .valid_in(valid_in),
        .valid_out(valid_a1),
        .result_out(raw_mat_1)
    );

    mm_array4x4 #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH),
        .FRAC_BITS (FRAC_BITS)
    ) u_array2 (
        .clk(clk),
        .rst_n(rst_n),
        .pe_mode(mode),
        .a_in(A2_mat),
        .b_in(B2_mat),
        .acc_in('{default:'0}),
        .valid_in(valid_in),
        .valid_out(valid_a2),
        .result_out(raw_mat_2)
    );

    mm_array4x4 #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH),
        .FRAC_BITS (FRAC_BITS)
    ) u_array3 (
        .clk(clk),
        .rst_n(rst_n),
        .pe_mode(mode),
        .a_in(A3_mat),
        .b_in(B3_mat),
        .acc_in('{default:'0}),
        .valid_in(valid_in),
        .valid_out(valid_a3),
        .result_out(raw_mat_3)
    );

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            running <= 1'b0;
            block_ctr <= '0;
            valid_reduced <= 1'b0;
            reduced_vec <= '{default:'0};
            reduced_mat_0 <= '{default:'0};
            reduced_mat_1 <= '{default:'0};
            reduced_mat_2 <= '{default:'0};
            reduced_mat_3 <= '{default:'0};
            acc_mat_0 <= '{default:'0};
            acc_mat_1 <= '{default:'0};
            acc_mat_2 <= '{default:'0};
            acc_mat_3 <= '{default:'0};
        end else begin
            valid_reduced <= 1'b0;

            if (valid_in && !running) begin
                running <= 1'b1;
                block_ctr <= '0;
                acc_mat_0 <= '{default:'0};
                acc_mat_1 <= '{default:'0};
                acc_mat_2 <= '{default:'0};
                acc_mat_3 <= '{default:'0};
            end

            if (all_valid && running) begin
                for (int i = 0; i < TILE_SIZE; i++) begin
                    for (int j = 0; j < TILE_SIZE; j++) begin
                        acc_mat_0[i][j] <= acc_mat_0[i][j] + raw_mat_0[i][j];
                        acc_mat_1[i][j] <= acc_mat_1[i][j] + raw_mat_1[i][j];
                        acc_mat_2[i][j] <= acc_mat_2[i][j] + raw_mat_2[i][j];
                        acc_mat_3[i][j] <= acc_mat_3[i][j] + raw_mat_3[i][j];
                    end
                end

                if (last_block) begin
                    running <= 1'b0;
                    valid_reduced <= 1'b1;
                    for (int i = 0; i < TILE_SIZE; i++) begin
                        for (int j = 0; j < TILE_SIZE; j++) begin
                            reduced_mat_0[i][j] <= acc_mat_0[i][j] + raw_mat_0[i][j];
                            reduced_mat_1[i][j] <= acc_mat_1[i][j] + raw_mat_1[i][j];
                            reduced_mat_2[i][j] <= acc_mat_2[i][j] + raw_mat_2[i][j];
                            reduced_mat_3[i][j] <= acc_mat_3[i][j] + raw_mat_3[i][j];
                        end
                    end

                    if (reduce_rows) begin
                        for (int col = 0; col < TILE_SIZE; col++) begin
                            reduced_vec[col] <= sum_col_next[col];
                        end
                    end else begin
                        reduced_vec <= '{default:'0};
                    end
                end else begin
                    block_ctr <= block_ctr + 1'b1;
                end
            end
        end
    end
endmodule


