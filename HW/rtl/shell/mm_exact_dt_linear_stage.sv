`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: slm_exact_dt_linear_stage
// Function:
//   Exact-side wrapper for the proven dt projection scheduler. The arithmetic
//   path stays unchanged; only the stage ownership and naming move under the
//   refactored exact architecture.
//---------------------------------------------------------------
module slm_exact_dt_linear_stage #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH  = 32,
    parameter int FRAC_BITS  = 8,
    parameter int N_BANK     = 6,
    parameter int WDEPTH     = 1024,
    parameter int WADDR_W    = $clog2(WDEPTH),
    parameter int DATA_W     = 256,
    parameter int XT_ADDR_W  = 6,
    parameter string BANK0_INIT_FILE = "",
    parameter string BANK1_INIT_FILE = "",
    parameter string BANK2_INIT_FILE = "",
    parameter string BANK3_INIT_FILE = "",
    parameter string SCALE_INIT_FILE = ""
)(
    input  logic clk,
    input  logic rst_n,
    output logic sched_busy,

    output logic                         u_vec_rd_en,
    output logic [XT_ADDR_W-1:0]         u_vec_rd_addr,
    input  logic signed [DATA_WIDTH-1:0] u_vec_rd_data [TILE_SIZE-1:0],

    input  logic s_axis_TVALID,
    output logic s_axis_TREADY,
    output logic m_axis_TVALID,
    input  logic m_axis_TREADY,
    output logic signed [DATA_WIDTH-1:0] reduced_trunc [TILE_SIZE-1:0],

    output logic                         xt_axis_TVALID,
    input  logic                         xt_axis_TREADY,
    output logic signed [DATA_WIDTH-1:0] xt_axis_TDATA [TILE_SIZE-1:0],

    output logic [1:0]                    fabric_mode,
    output logic [6:0]                    fabric_col_blocks,
    output logic                          fabric_valid_in,
    output logic signed [DATA_WIDTH-1:0]  fabric_A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0]  fabric_A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0]  fabric_A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0]  fabric_A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0]  fabric_B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0]  fabric_B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0]  fabric_B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0]  fabric_B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [ACC_WIDTH-1:0]   fabric_reduced_vec [TILE_SIZE-1:0],
    input  logic signed [ACC_WIDTH-1:0]   fabric_reduced_mat_0 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [ACC_WIDTH-1:0]   fabric_reduced_mat_1 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [ACC_WIDTH-1:0]   fabric_reduced_mat_2 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic signed [ACC_WIDTH-1:0]   fabric_reduced_mat_3 [TILE_SIZE-1:0][TILE_SIZE-1:0],
    input  logic                          fabric_valid_out
);
    reuse_ssm_dt_scheduler #(
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .FRAC_BITS(FRAC_BITS),
        .N_BANK(N_BANK),
        .WDEPTH(WDEPTH),
        .WADDR_W(WADDR_W),
        .DATA_W(DATA_W),
        .XT_ADDR_W(XT_ADDR_W),
        .DT_BANK0_INIT_FILE(BANK0_INIT_FILE),
        .DT_BANK1_INIT_FILE(BANK1_INIT_FILE),
        .DT_BANK2_INIT_FILE(BANK2_INIT_FILE),
        .DT_BANK3_INIT_FILE(BANK3_INIT_FILE),
        .DT_SCALE_INIT_FILE(SCALE_INIT_FILE)
    ) u_impl (
        .clk(clk),
        .rst_n(rst_n),
        .sched_busy(sched_busy),
        .u_vec_rd_en(u_vec_rd_en),
        .u_vec_rd_addr(u_vec_rd_addr),
        .u_vec_rd_data(u_vec_rd_data),
        .s_axis_TVALID(s_axis_TVALID),
        .s_axis_TREADY(s_axis_TREADY),
        .m_axis_TVALID(m_axis_TVALID),
        .m_axis_TREADY(m_axis_TREADY),
        .reduced_trunc(reduced_trunc),
        .xt_axis_TVALID(xt_axis_TVALID),
        .xt_axis_TREADY(xt_axis_TREADY),
        .xt_axis_TDATA(xt_axis_TDATA),
        .fabric_mode(fabric_mode),
        .fabric_col_blocks(fabric_col_blocks),
        .fabric_valid_in(fabric_valid_in),
        .fabric_A0_mat(fabric_A0_mat),
        .fabric_A1_mat(fabric_A1_mat),
        .fabric_A2_mat(fabric_A2_mat),
        .fabric_A3_mat(fabric_A3_mat),
        .fabric_B0_mat(fabric_B0_mat),
        .fabric_B1_mat(fabric_B1_mat),
        .fabric_B2_mat(fabric_B2_mat),
        .fabric_B3_mat(fabric_B3_mat),
        .fabric_reduced_vec(fabric_reduced_vec),
        .fabric_reduced_mat_0(fabric_reduced_mat_0),
        .fabric_reduced_mat_1(fabric_reduced_mat_1),
        .fabric_reduced_mat_2(fabric_reduced_mat_2),
        .fabric_reduced_mat_3(fabric_reduced_mat_3),
        .fabric_valid_out(fabric_valid_out)
    );
endmodule

