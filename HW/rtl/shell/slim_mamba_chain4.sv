`timescale 1ns/1ps

import slm_chain_cfg_pkg::*;
import slm_block_cfg_pkg::*;

module slim_mamba_chain4 #(
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
    localparam int N_BLOCKS = MM_EXACT_DEFAULT_N_BLOCKS;

    logic launch_req [0:N_BLOCKS-1];
    logic blk_start_pulse [0:N_BLOCKS-1];
    logic blk_busy_raw [0:N_BLOCKS-1];
    logic blk_done_raw [0:N_BLOCKS-1];
    logic blk_busy [0:N_BLOCKS-1];
    logic blk_done [0:N_BLOCKS-1];
    logic blk_y_valid [0:N_BLOCKS-1];
    logic blk_y_ready [0:N_BLOCKS-1];
    logic signed [DATA_WIDTH-1:0] blk_y_data [0:N_BLOCKS-1][TILE_SIZE-1:0];
    logic blk_h_wr_en [0:N_BLOCKS-1];
    logic [4:0] blk_h_wr_addr [0:N_BLOCKS-1];
    logic signed [DATA_WIDTH-1:0] blk_h_wr_data [0:N_BLOCKS-1][TILE_SIZE-1:0];

    slm_chain_controller #(
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .H_ROWS(MM_EXACT_DEFAULT_H_ROWS),
        .N_BLOCKS(N_BLOCKS),
        .INTER_BLOCK_PIPELINE(INTER_BLOCK_PIPELINE)
    ) u_pipe_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .busy(busy),
        .done(done),
        .h_wr_en(h_wr_en),
        .h_wr_addr(h_wr_addr),
        .h_wr_data(h_wr_data),
        .launch_req(launch_req),
        .blk_busy(blk_busy),
        .blk_done(blk_done),
        .blk_y_valid(blk_y_valid),
        .blk_y_ready(blk_y_ready),
        .blk_y_data(blk_y_data),
        .blk_h_wr_en(blk_h_wr_en),
        .blk_h_wr_addr(blk_h_wr_addr),
        .blk_h_wr_data(blk_h_wr_data),
        .y_valid(y_valid),
        .y_ready(y_ready),
        .y_data(y_data)
    );

    genvar bi;
    generate
        for (bi = 0; bi < N_BLOCKS; bi++) begin : g_blk_ctrl
            slm_block_launch_ctrl u_blk_ctrl (
                .clk(clk),
                .rst_n(rst_n),
                .launch_req(launch_req[bi]),
                .block_busy_i(blk_busy_raw[bi]),
                .block_done_i(blk_done_raw[bi]),
                .block_start_pulse(blk_start_pulse[bi]),
                .block_busy_o(blk_busy[bi]),
                .block_done_o(blk_done[bi])
            );
        end
    endgenerate

    slim_mamba_block_from_stage_dir #(
        .TILE_SIZE(TILE_SIZE), .DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH), .FRAC_BITS(FRAC_BITS),
        .N_BANK(N_BANK), .WDEPTH(WDEPTH), .WADDR_W(WADDR_W), .DATA_W(DATA_W), .XT_ADDR_W(XT_ADDR_W),
        .D(D), .PIPE_LAT(PIPE_LAT), .ADDR_BITS(ADDR_BITS), .LUT_FILE(LUT_FILE), .S_ADDR_W(S_ADDR_W), .G_FRAC_BITS(G_FRAC_BITS),
        .BLOCK_CFG(BLOCK_CFG_B0),
        .STAGE_DIR(STAGE_DIR_B0)
    ) u_blk0 (
        .clk(clk), .rst_n(rst_n), .block_start(blk_start_pulse[0]), .block_busy(blk_busy_raw[0]), .block_done(blk_done_raw[0]),
        .h_wr_en(blk_h_wr_en[0]), .h_wr_addr(blk_h_wr_addr[0]), .h_wr_data(blk_h_wr_data[0]),
        .y_axis_TVALID(blk_y_valid[0]), .y_axis_TREADY(blk_y_ready[0]), .y_axis_TDATA(blk_y_data[0])
    );

    slim_mamba_block_from_stage_dir #(
        .TILE_SIZE(TILE_SIZE), .DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH), .FRAC_BITS(FRAC_BITS),
        .N_BANK(N_BANK), .WDEPTH(WDEPTH), .WADDR_W(WADDR_W), .DATA_W(DATA_W), .XT_ADDR_W(XT_ADDR_W),
        .D(D), .PIPE_LAT(PIPE_LAT), .ADDR_BITS(ADDR_BITS), .LUT_FILE(LUT_FILE), .S_ADDR_W(S_ADDR_W), .G_FRAC_BITS(G_FRAC_BITS),
        .BLOCK_CFG(BLOCK_CFG_B1),
        .STAGE_DIR(STAGE_DIR_B1)
    ) u_blk1 (
        .clk(clk), .rst_n(rst_n), .block_start(blk_start_pulse[1]), .block_busy(blk_busy_raw[1]), .block_done(blk_done_raw[1]),
        .h_wr_en(blk_h_wr_en[1]), .h_wr_addr(blk_h_wr_addr[1]), .h_wr_data(blk_h_wr_data[1]),
        .y_axis_TVALID(blk_y_valid[1]), .y_axis_TREADY(blk_y_ready[1]), .y_axis_TDATA(blk_y_data[1])
    );

    slim_mamba_block_from_stage_dir #(
        .TILE_SIZE(TILE_SIZE), .DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH), .FRAC_BITS(FRAC_BITS),
        .N_BANK(N_BANK), .WDEPTH(WDEPTH), .WADDR_W(WADDR_W), .DATA_W(DATA_W), .XT_ADDR_W(XT_ADDR_W),
        .D(D), .PIPE_LAT(PIPE_LAT), .ADDR_BITS(ADDR_BITS), .LUT_FILE(LUT_FILE), .S_ADDR_W(S_ADDR_W), .G_FRAC_BITS(G_FRAC_BITS),
        .BLOCK_CFG(BLOCK_CFG_B2),
        .STAGE_DIR(STAGE_DIR_B2)
    ) u_blk2 (
        .clk(clk), .rst_n(rst_n), .block_start(blk_start_pulse[2]), .block_busy(blk_busy_raw[2]), .block_done(blk_done_raw[2]),
        .h_wr_en(blk_h_wr_en[2]), .h_wr_addr(blk_h_wr_addr[2]), .h_wr_data(blk_h_wr_data[2]),
        .y_axis_TVALID(blk_y_valid[2]), .y_axis_TREADY(blk_y_ready[2]), .y_axis_TDATA(blk_y_data[2])
    );

    slim_mamba_block_from_stage_dir #(
        .TILE_SIZE(TILE_SIZE), .DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH), .FRAC_BITS(FRAC_BITS),
        .N_BANK(N_BANK), .WDEPTH(WDEPTH), .WADDR_W(WADDR_W), .DATA_W(DATA_W), .XT_ADDR_W(XT_ADDR_W),
        .D(D), .PIPE_LAT(PIPE_LAT), .ADDR_BITS(ADDR_BITS), .LUT_FILE(LUT_FILE), .S_ADDR_W(S_ADDR_W), .G_FRAC_BITS(G_FRAC_BITS),
        .BLOCK_CFG(BLOCK_CFG_B3),
        .STAGE_DIR(STAGE_DIR_B3)
    ) u_blk3 (
        .clk(clk), .rst_n(rst_n), .block_start(blk_start_pulse[3]), .block_busy(blk_busy_raw[3]), .block_done(blk_done_raw[3]),
        .h_wr_en(blk_h_wr_en[3]), .h_wr_addr(blk_h_wr_addr[3]), .h_wr_data(blk_h_wr_data[3]),
        .y_axis_TVALID(blk_y_valid[3]), .y_axis_TREADY(blk_y_ready[3]), .y_axis_TDATA(blk_y_data[3])
    );
endmodule

