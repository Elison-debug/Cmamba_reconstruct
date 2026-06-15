`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: slim_mamba_chain4_project_top
// Function:
//   Project-bound top for the default c01 hardware case.
//   This wrapper fixes the stage directories and lookup-table asset paths
//   used by the four-block Slim-Mamba chain so that the Vivado project can
//   elaborate and synthesize without manual parameter entry.
//---------------------------------------------------------------

import slm_block_cfg_pkg::*;

module slim_mamba_chain4_project_top #(
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
    parameter int S_ADDR_W   = 6,
    parameter int G_FRAC_BITS = 8,
    parameter bit INTER_BLOCK_PIPELINE = 1,
    parameter string CASE_DIR = "E:/course/smamba/final_hw/cases/c01",
    parameter string LUT_FILE = "E:/course/smamba/HW/ip/sigmoid_lut_q016_2048.hex",
    parameter slm_block_cfg_t BLOCK_CFG_B0 = make_block_cfg_from_flags(1'b0, 1'b0, 1'b0, 1'b1, 1'b0),
    parameter slm_block_cfg_t BLOCK_CFG_B1 = make_block_cfg_from_flags(1'b0, 1'b0, 1'b0, 1'b1, 1'b0),
    parameter slm_block_cfg_t BLOCK_CFG_B2 = make_block_cfg_from_flags(1'b0, 1'b0, 1'b0, 1'b1, 1'b0),
    parameter slm_block_cfg_t BLOCK_CFG_B3 = make_block_cfg_from_flags(1'b0, 1'b0, 1'b0, 1'b1, 1'b0)
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
    localparam string STAGE_DIR_B0 = {CASE_DIR, "/stages/reuse_mamba_block_top_block0"};
    localparam string STAGE_DIR_B1 = {CASE_DIR, "/stages/reuse_mamba_block_top_block1"};
    localparam string STAGE_DIR_B2 = {CASE_DIR, "/stages/reuse_mamba_block_top_block2"};
    localparam string STAGE_DIR_B3 = {CASE_DIR, "/stages/reuse_mamba_block_top_block3"};

    slim_mamba_chain4_top #(
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
    ) u_chain_top (
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
