//---------------------------------------------------------------
// Module: reuse_shared_mac_fabric
// Function:
//   Thin wrapper around the existing 4x4x4 MAC pipeline so the
//   controller can treat it as a standalone shared compute fabric.
//   Behavior and tile/memory schedule stay unchanged.
//---------------------------------------------------------------
module reuse_shared_mac_fabric #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH  = 32,
    parameter int FRAC_BITS  = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic [1:0] mode,
    input  logic [6:0] col_blocks_cfg,
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

    reuse_pipeline_4array_with_reduction #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH),
        .FRAC_BITS (FRAC_BITS)
    ) u_shared_pipeline (
        .clk(clk),
        .rst_n(rst_n),
        .mode(mode),
        .col_blocks_cfg(col_blocks_cfg),
        .valid_in(valid_in),
        .A0_mat(A0_mat), .A1_mat(A1_mat), .A2_mat(A2_mat), .A3_mat(A3_mat),
        .B0_mat(B0_mat), .B1_mat(B1_mat), .B2_mat(B2_mat), .B3_mat(B3_mat),
        .reduced_vec(reduced_vec),
        .reduced_mat_0(reduced_mat_0),
        .reduced_mat_1(reduced_mat_1),
        .reduced_mat_2(reduced_mat_2),
        .reduced_mat_3(reduced_mat_3),
        .valid_reduced(valid_reduced)
    );

endmodule
