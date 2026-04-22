`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: reuse_mamba_chain4_core_adapter
// Function:
//   Board-shell/core bridge for reuse_mamba_4block_chain_top.
//   - Synchronizes external active-low reset into sys_clk
//   - Packs/unpacks 4-lane vectors
//---------------------------------------------------------------

module reuse_mamba_chain4_core_adapter #(
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
    parameter string LUT_FILE = "E:/course/smamba/final_hw/ip/sigmoid_lut_q016_2048.hex",
    parameter int S_ADDR_W   = 6,
    parameter int G_FRAC_BITS = 8,
    parameter string STAGE_DIR_B0 = "E:/course/smamba/final_hw/cases/c01/stages/reuse_mamba_block_top_block0",
    parameter string STAGE_DIR_B1 = "E:/course/smamba/final_hw/cases/c01/stages/reuse_mamba_block_top_block1",
    parameter string STAGE_DIR_B2 = "E:/course/smamba/final_hw/cases/c01/stages/reuse_mamba_block_top_block2",
    parameter string STAGE_DIR_B3 = "E:/course/smamba/final_hw/cases/c01/stages/reuse_mamba_block_top_block3"
)(
    input  logic sys_clk,
    input  logic ext_reset_n,
    output logic core_rst_n_o,

    input  logic start,
    output logic busy,
    output logic done,

    input  logic                         h_wr_en,
    input  logic [4:0]                   h_wr_addr,
    input  logic signed [TILE_SIZE*DATA_WIDTH-1:0] h_wr_data,

    output logic                         y_axis_tvalid,
    input  logic                         y_axis_tready,
    output logic signed [TILE_SIZE*DATA_WIDTH-1:0] y_axis_tdata
);
    logic signed [DATA_WIDTH-1:0] h_wr_data_arr [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] y_axis_tdata_arr [TILE_SIZE-1:0];

    // ext_reset_n is already synchronized at the board-shell top level.
    assign core_rst_n_o = ext_reset_n;

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++) begin
            h_wr_data_arr[i] = h_wr_data[i*DATA_WIDTH +: DATA_WIDTH];
            y_axis_tdata[i*DATA_WIDTH +: DATA_WIDTH] = y_axis_tdata_arr[i];
        end
    end

    reuse_mamba_4block_chain_top #(
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
        .STAGE_DIR_B0(STAGE_DIR_B0),
        .STAGE_DIR_B1(STAGE_DIR_B1),
        .STAGE_DIR_B2(STAGE_DIR_B2),
        .STAGE_DIR_B3(STAGE_DIR_B3)
    ) u_core (
        .clk    (sys_clk),
        .rst_n  (ext_reset_n),
        .start  (start),
        .busy   (busy),
        .done   (done),
        .h_wr_en(h_wr_en),
        .h_wr_addr(h_wr_addr),
        .h_wr_data(h_wr_data_arr),
        .y_valid(y_axis_tvalid),
        .y_ready(y_axis_tready),
        .y_data (y_axis_tdata_arr)
    );
endmodule
