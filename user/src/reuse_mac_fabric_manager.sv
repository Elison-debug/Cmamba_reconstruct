//---------------------------------------------------------------
// Module: reuse_mac_fabric_manager
// Function:
//   Central arbitration point for all schedulers that time-multiplex
//   the shared 4x4x4 MAC fabric.
//   Current policy is fixed-priority / single-owner:
//     1) SSM dt scheduler
//     2) in_proj stub
//     3) out_proj stub
//---------------------------------------------------------------
module reuse_mac_fabric_manager #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH  = 32,
    parameter int FRAC_BITS  = 8
)(
    input  logic clk,
    input  logic rst_n,

    // --- SSM dt scheduler ---
    input  logic                         dt_busy,
    input  logic [1:0]                   dt_mode,
    input  logic [6:0]                   dt_col_blocks,
    input  logic                         dt_valid_in,
    input  logic signed [DATA_WIDTH-1:0] dt_A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] dt_A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] dt_A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] dt_A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] dt_B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] dt_B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] dt_B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] dt_B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0]  dt_reduced_vec [TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0]  dt_reduced_mat_0 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0]  dt_reduced_mat_1 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0]  dt_reduced_mat_2 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0]  dt_reduced_mat_3 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic                         dt_valid_out,

    // --- in_proj scheduler ---
    input  logic                         in_busy,
    input  logic [1:0]                   in_mode,
    input  logic [6:0]                   in_col_blocks,
    input  logic                         in_valid_in,
    input  logic signed [DATA_WIDTH-1:0] in_A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] in_A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] in_A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] in_A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] in_B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] in_B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] in_B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] in_B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0]  in_reduced_vec [TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0]  in_reduced_mat_0 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0]  in_reduced_mat_1 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0]  in_reduced_mat_2 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0]  in_reduced_mat_3 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic                         in_valid_out,

    // --- out_proj scheduler ---
    input  logic                         out_busy,
    input  logic [1:0]                   out_mode,
    input  logic [6:0]                   out_col_blocks,
    input  logic                         out_valid_in,
    input  logic signed [DATA_WIDTH-1:0] out_A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] out_A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] out_A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] out_A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] out_B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] out_B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] out_B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] out_B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0]  out_reduced_vec [TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0]  out_reduced_mat_0 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0]  out_reduced_mat_1 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0]  out_reduced_mat_2 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [ACC_WIDTH-1:0]  out_reduced_mat_3 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic                         out_valid_out
);
    logic [1:0] active_mode;
    logic [6:0] active_col_blocks;
    logic       active_valid_in;
    logic signed [DATA_WIDTH-1:0] active_A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] active_A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] active_A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] active_A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] active_B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] active_B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] active_B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] active_B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];

    logic signed [ACC_WIDTH-1:0] fabric_reduced_vec [TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] fabric_reduced_mat_0 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] fabric_reduced_mat_1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] fabric_reduced_mat_2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0] fabric_reduced_mat_3 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic                        fabric_valid_out;

    logic sel_dt, sel_in, sel_out;
    always_comb begin
        sel_dt  = dt_busy;
        sel_in  = !sel_dt && in_busy;
        sel_out = !sel_dt && !sel_in && out_busy;

        active_mode     = dt_mode;
        active_col_blocks = dt_col_blocks;
        active_valid_in = 1'b0;
        active_A0_mat   = '{default:'0};
        active_A1_mat   = '{default:'0};
        active_A2_mat   = '{default:'0};
        active_A3_mat   = '{default:'0};
        active_B0_mat   = '{default:'0};
        active_B1_mat   = '{default:'0};
        active_B2_mat   = '{default:'0};
        active_B3_mat   = '{default:'0};

        if (sel_dt) begin
            active_mode     = dt_mode;
            active_col_blocks = dt_col_blocks;
            active_valid_in = dt_valid_in;
            active_A0_mat   = dt_A0_mat; active_A1_mat = dt_A1_mat;
            active_A2_mat   = dt_A2_mat; active_A3_mat = dt_A3_mat;
            active_B0_mat   = dt_B0_mat; active_B1_mat = dt_B1_mat;
            active_B2_mat   = dt_B2_mat; active_B3_mat = dt_B3_mat;
        end else if (sel_in) begin
            active_mode     = in_mode;
            active_col_blocks = in_col_blocks;
            active_valid_in = in_valid_in;
            active_A0_mat   = in_A0_mat; active_A1_mat = in_A1_mat;
            active_A2_mat   = in_A2_mat; active_A3_mat = in_A3_mat;
            active_B0_mat   = in_B0_mat; active_B1_mat = in_B1_mat;
            active_B2_mat   = in_B2_mat; active_B3_mat = in_B3_mat;
        end else if (sel_out) begin
            active_mode     = out_mode;
            active_col_blocks = out_col_blocks;
            active_valid_in = out_valid_in;
            active_A0_mat   = out_A0_mat; active_A1_mat = out_A1_mat;
            active_A2_mat   = out_A2_mat; active_A3_mat = out_A3_mat;
            active_B0_mat   = out_B0_mat; active_B1_mat = out_B1_mat;
            active_B2_mat   = out_B2_mat; active_B3_mat = out_B3_mat;
        end
    end

    reuse_shared_mac_fabric #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH),
        .FRAC_BITS (FRAC_BITS)
    ) u_shared_fabric (
        .clk(clk),
        .rst_n(rst_n),
        .mode(active_mode),
        .col_blocks_cfg(active_col_blocks),
        .valid_in(active_valid_in),
        .A0_mat(active_A0_mat), .A1_mat(active_A1_mat),
        .A2_mat(active_A2_mat), .A3_mat(active_A3_mat),
        .B0_mat(active_B0_mat), .B1_mat(active_B1_mat),
        .B2_mat(active_B2_mat), .B3_mat(active_B3_mat),
        .reduced_vec(fabric_reduced_vec),
        .reduced_mat_0(fabric_reduced_mat_0),
        .reduced_mat_1(fabric_reduced_mat_1),
        .reduced_mat_2(fabric_reduced_mat_2),
        .reduced_mat_3(fabric_reduced_mat_3),
        .valid_reduced(fabric_valid_out)
    );

    assign dt_reduced_vec   = fabric_reduced_vec;
    assign dt_reduced_mat_0 = fabric_reduced_mat_0;
    assign dt_reduced_mat_1 = fabric_reduced_mat_1;
    assign dt_reduced_mat_2 = fabric_reduced_mat_2;
    assign dt_reduced_mat_3 = fabric_reduced_mat_3;
    assign dt_valid_out     = sel_dt ? fabric_valid_out : 1'b0;

    assign in_reduced_vec   = fabric_reduced_vec;
    assign in_reduced_mat_0 = fabric_reduced_mat_0;
    assign in_reduced_mat_1 = fabric_reduced_mat_1;
    assign in_reduced_mat_2 = fabric_reduced_mat_2;
    assign in_reduced_mat_3 = fabric_reduced_mat_3;
    assign in_valid_out     = sel_in ? fabric_valid_out : 1'b0;

    assign out_reduced_vec   = fabric_reduced_vec;
    assign out_reduced_mat_0 = fabric_reduced_mat_0;
    assign out_reduced_mat_1 = fabric_reduced_mat_1;
    assign out_reduced_mat_2 = fabric_reduced_mat_2;
    assign out_reduced_mat_3 = fabric_reduced_mat_3;
    assign out_valid_out     = sel_out ? fabric_valid_out : 1'b0;
endmodule
