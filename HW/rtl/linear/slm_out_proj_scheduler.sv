`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: slm_out_proj_scheduler
// Function:
//   Output projection stage for Slim-Mamba. The module preloads p_t tiles from
//   the p-stage buffer SRAM into the shared linear GEMV core and forwards the
//   projected y_t tiles on the AXIS output. Preload can begin before the
//   state stage finishes, but GEMV execution is held off until compute_enable
//   is asserted.
//---------------------------------------------------------------
module slm_out_proj_scheduler #(
    parameter int TILE_SIZE   = 4,
    parameter int DATA_WIDTH  = 16,
    parameter int ACC_WIDTH   = 32,
    parameter int FRAC_BITS   = 8,
    parameter int N_BANK      = 6,
    parameter int WDEPTH      = 512,
    parameter int WADDR_W     = $clog2(WDEPTH),
    parameter int DATA_W      = 256,
    parameter int IN_DIM      = 256,
    parameter int OUT_DIM     = 128,
    parameter int P_DEPTH     = IN_DIM / TILE_SIZE,
    parameter int P_ADDR_W    = $clog2(P_DEPTH),
    parameter int Y_DEPTH     = OUT_DIM / TILE_SIZE,
    parameter int Y_ADDR_W    = $clog2(Y_DEPTH),
    parameter int SCALE_W            = 16,
    parameter int SCALE_FRAC_BITS    = 15,
    parameter bit USE_PER_CHANNEL_SCALE = 0,
    parameter string OUTPROJ_BANK0_INIT_FILE = "",
    parameter string OUTPROJ_BANK1_INIT_FILE = "",
    parameter string OUTPROJ_BANK2_INIT_FILE = "",
    parameter string OUTPROJ_BANK3_INIT_FILE = "",
    parameter string OUTPROJ_BANK4_INIT_FILE = "",
    parameter string OUTPROJ_BANK5_INIT_FILE = "",
    parameter string OUTPROJ_SCALE_INIT_FILE = "",
    parameter int REQUANT_ROUND_MODE = 1,
    parameter int REQUANT_SAT_MODE   = 1
)(
    input  logic clk,
    input  logic rst_n,
    input  logic enable,
    input  logic start,
    input  logic compute_enable,
    input  logic [P_ADDR_W:0] preload_tiles_available,
    output logic busy,
    output logic done,

    output logic                         p_rd_en,
    output logic [P_ADDR_W-1:0]          p_rd_addr,
    input  logic signed [DATA_WIDTH-1:0] p_rd_data [TILE_SIZE-1:0],

    output logic                         y_axis_TVALID,
    input  logic                         y_axis_TREADY,
    output logic signed [DATA_WIDTH-1:0] y_axis_TDATA [TILE_SIZE-1:0],

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
    localparam int ROW_TILES = OUT_DIM / TILE_SIZE;
    localparam int ROW_TILE_W = (ROW_TILES > 1) ? $clog2(ROW_TILES) : 1;

    logic [Y_ADDR_W-1:0]          y_wr_addr;
    logic                         y_wr_valid;
    logic [ROW_TILE_W-1:0]        y_wr_tile_index;
    logic signed [DATA_WIDTH-1:0] y_wr_data [TILE_SIZE-1:0];

    assign y_wr_addr     = y_wr_tile_index[Y_ADDR_W-1:0];
    assign y_axis_TVALID = y_wr_valid;
    assign y_axis_TDATA  = y_wr_data;

    slm_linear_gemv_core #(
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .FRAC_BITS(FRAC_BITS),
        .N_BANK(N_BANK),
        .WDEPTH(WDEPTH),
        .WADDR_W(WADDR_W),
        .DATA_W(DATA_W),
        .IN_DIM(IN_DIM),
        .OUT_DIM(OUT_DIM),
        .SRC_ADDR_W(P_ADDR_W),
        .SCALE_W(SCALE_W),
        .SCALE_FRAC_BITS(SCALE_FRAC_BITS),
        .USE_PER_CHANNEL_SCALE(USE_PER_CHANNEL_SCALE),
        .USE_STREAM_SOURCE(1'b0),
        .BANK0_INIT_FILE(OUTPROJ_BANK0_INIT_FILE),
        .BANK1_INIT_FILE(OUTPROJ_BANK1_INIT_FILE),
        .BANK2_INIT_FILE(OUTPROJ_BANK2_INIT_FILE),
        .BANK3_INIT_FILE(OUTPROJ_BANK3_INIT_FILE),
        .BANK4_INIT_FILE(OUTPROJ_BANK4_INIT_FILE),
        .BANK5_INIT_FILE(OUTPROJ_BANK5_INIT_FILE),
        .SCALE_INIT_FILE(OUTPROJ_SCALE_INIT_FILE),
        .REQUANT_ROUND_MODE(REQUANT_ROUND_MODE),
        .REQUANT_SAT_MODE(REQUANT_SAT_MODE)
    ) u_core (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .start(start),
        .compute_enable(compute_enable),
        .src_tiles_available(preload_tiles_available),
        .busy(busy),
        .done(done),
        .src_stream_valid(1'b0),
        .src_stream_ready(),
        .src_stream_data('{default:'0}),
        .src_rd_en(p_rd_en),
        .src_rd_addr0(p_rd_addr),
        .src_rd_addr1(),
        .src_rd_addr2(),
        .src_rd_addr3(),
        .src_rd_data0(p_rd_data),
        .src_rd_data1('{default:'0}),
        .src_rd_data2('{default:'0}),
        .src_rd_data3('{default:'0}),
        .dst_valid(y_wr_valid),
        .dst_ready(y_axis_TREADY),
        .dst_tile_index(y_wr_tile_index),
        .dst_data(y_wr_data),
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
