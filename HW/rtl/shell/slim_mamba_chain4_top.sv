`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: slim_mamba_chain4_top
// Function:
//   Stable namespace-preserving top for the refactored HW tree.
//   The external contract remains unchanged, while the internal chain now
//   uses the exact refactored block implementation instead of the legacy
//   monolithic block core.
//---------------------------------------------------------------

import slm_block_cfg_pkg::*;

module slim_mamba_chain4_top #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH  = 32,
    parameter int FRAC_BITS  = 8,
    parameter int N_BANK     = 6,
    parameter int WDEPTH     = 1024,
    parameter int WADDR_W    = $clog2(WDEPTH),
    parameter int DATA_W     = 256,
    parameter int XT_ADDR_W  = 6,
    parameter int D          = 256,
    parameter int PIPE_LAT   = 4,
    parameter int ADDR_BITS  = 11,
    parameter string LUT_FILE = "sigmoid_lut_q016_2048.hex",
    parameter int S_ADDR_W   = 6,
    parameter int G_FRAC_BITS = 8,
    parameter bit INTER_BLOCK_PIPELINE = 1,
    parameter slm_block_cfg_t BLOCK_CFG_B0 = make_block_cfg_from_flags(1'b0, 1'b0, 1'b0, 1'b1, 1'b0),
    parameter slm_block_cfg_t BLOCK_CFG_B1 = make_block_cfg_from_flags(1'b0, 1'b0, 1'b0, 1'b1, 1'b0),
    parameter slm_block_cfg_t BLOCK_CFG_B2 = make_block_cfg_from_flags(1'b0, 1'b0, 1'b0, 1'b1, 1'b0),
    parameter slm_block_cfg_t BLOCK_CFG_B3 = make_block_cfg_from_flags(1'b0, 1'b0, 1'b0, 1'b1, 1'b0),
    parameter string STAGE_DIR_B0 = "",
    parameter string STAGE_DIR_B1 = "",
    parameter string STAGE_DIR_B2 = "",
    parameter string STAGE_DIR_B3 = ""
) (
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    output logic busy,
    output logic done,

    input  logic                         h_wr_en,
    input  logic [4:0]                   h_wr_addr,
    input  logic signed [DATA_WIDTH-1:0] h_wr_data [TILE_SIZE-1:0],

    output logic                         y_valid,
    input  logic                         y_ready,
    output logic signed [DATA_WIDTH-1:0] y_data [TILE_SIZE-1:0]
);
    slim_mamba_chain4 #(
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .FRAC_BITS(FRAC_BITS),
        .N_BANK(N_BANK),
        .WDEPTH(WDEPTH),
        .WADDR_W(WADDR_W),
        .DATA_W(DATA_W),
        .XT_ADDR_W(XT_ADDR_W),
        .D(D),
        .PIPE_LAT(PIPE_LAT),
        .ADDR_BITS(ADDR_BITS),
        .LUT_FILE(LUT_FILE),
        .S_ADDR_W(S_ADDR_W),
        .G_FRAC_BITS(G_FRAC_BITS),
        .INTER_BLOCK_PIPELINE(INTER_BLOCK_PIPELINE),
        .BLOCK_CFG_B0(BLOCK_CFG_B0),
        .BLOCK_CFG_B1(BLOCK_CFG_B1),
        .BLOCK_CFG_B2(BLOCK_CFG_B2),
        .BLOCK_CFG_B3(BLOCK_CFG_B3),
        .STAGE_DIR_B0(STAGE_DIR_B0),
        .STAGE_DIR_B1(STAGE_DIR_B1),
        .STAGE_DIR_B2(STAGE_DIR_B2),
        .STAGE_DIR_B3(STAGE_DIR_B3)
    ) u_exact_chain_core (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .busy(busy),
        .done(done),
        .h_wr_en(h_wr_en),
        .h_wr_addr(h_wr_addr),
        .h_wr_data(h_wr_data),
        .y_valid(y_valid),
        .y_ready(y_ready),
        .y_data(y_data)
    );
endmodule

