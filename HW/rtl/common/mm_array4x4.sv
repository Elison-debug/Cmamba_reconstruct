`timescale 1ns/1ps

module mm_array4x4 #(
    parameter int TILE_SIZE = 4,
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH  = 32,
    parameter int FRAC_BITS  = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic [1:0] pe_mode,
    input  logic signed [DATA_WIDTH-1:0] a_in [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] b_in [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [ACC_WIDTH-1:0] acc_in [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic valid_in,
    output logic valid_out,
    output logic signed [ACC_WIDTH-1:0] result_out [TILE_SIZE-1:0][TILE_SIZE-1:0]
);
    logic pe_valid_out [TILE_SIZE-1:0][TILE_SIZE-1:0];

    genvar i, j;
    generate
        for (i = 0; i < TILE_SIZE; i++) begin : g_row
            for (j = 0; j < TILE_SIZE; j++) begin : g_col
                mm_pe_unit_pipe #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .ACC_WIDTH (ACC_WIDTH),
                    .FRAC_BITS (FRAC_BITS)
                ) u_pe (
                    .clk(clk),
                    .rst_n(rst_n),
                    .valid_in(valid_in),
                    .valid_out(pe_valid_out[i][j]),
                    .mode(pe_mode),
                    .a_in(a_in[i][j]),
                    .b_in(b_in[i][j]),
                    .acc_in(acc_in[i][j]),
                    .result_out(result_out[i][j])
                );
            end
        end
    endgenerate

    logic pe_valid_aggregate;
    always_comb begin
        pe_valid_aggregate = 1'b0;
        for (int rr = 0; rr < TILE_SIZE; rr++) begin
            for (int cc = 0; cc < TILE_SIZE; cc++) begin
                pe_valid_aggregate |= pe_valid_out[rr][cc];
            end
        end
    end

    assign valid_out = pe_valid_aggregate;
endmodule


