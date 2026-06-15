`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: slm_in_proj_scheduler
// Function:
//   Input projection stage for Slim-Mamba. The module stores the normalized
//   h_t vectors, invokes the shared linear GEMV execution core, and routes
//   the projected tiles into the u and z vector memories.
//---------------------------------------------------------------
module slm_in_proj_scheduler #(
    parameter int TILE_SIZE   = 4,
    parameter int DATA_WIDTH  = 16,
    parameter int ACC_WIDTH   = 32,
    parameter int FRAC_BITS   = 8,
    parameter int N_BANK      = 6,
    parameter int WDEPTH      = 1024,
    parameter int WADDR_W     = $clog2(WDEPTH),
    parameter int DATA_W      = 256,
    parameter int IN_DIM      = 128,
    parameter int OUT_DIM     = 512,
    parameter int H_DEPTH     = IN_DIM / TILE_SIZE,
    parameter int H_ADDR_W    = $clog2(H_DEPTH),
    parameter int U_DEPTH     = (OUT_DIM/2) / TILE_SIZE,
    parameter int U_ADDR_W    = $clog2(U_DEPTH),
    parameter int SCALE_W            = 16,
    parameter int SCALE_FRAC_BITS    = 15,
    parameter bit USE_PER_CHANNEL_SCALE = 0,
    parameter string INPROJ_BANK0_INIT_FILE = "",
    parameter string INPROJ_BANK1_INIT_FILE = "",
    parameter string INPROJ_BANK2_INIT_FILE = "",
    parameter string INPROJ_BANK3_INIT_FILE = "",
    parameter string INPROJ_BANK4_INIT_FILE = "",
    parameter string INPROJ_BANK5_INIT_FILE = "",
    parameter string INPROJ_SCALE_INIT_FILE = "",
    parameter int REQUANT_ROUND_MODE = 1,
    parameter int REQUANT_SAT_MODE   = 1
)(
    input  logic clk,
    input  logic rst_n,
    input  logic enable,
    input  logic start,
    output logic busy,
    output logic done,

    input  logic                          h_wr_en,
    input  logic [H_ADDR_W-1:0]           h_wr_addr,
    input  logic signed [DATA_WIDTH-1:0]  h_wr_data [TILE_SIZE-1:0],

    input  logic                          u_rd_en,
    input  logic [U_ADDR_W-1:0]           u_rd_addr,
    output logic signed [DATA_WIDTH-1:0]  u_rd_data [TILE_SIZE-1:0],
    input  logic                          u_ssm_rd_en,
    input  logic [U_ADDR_W-1:0]           u_ssm_rd_addr,
    output logic signed [DATA_WIDTH-1:0]  u_ssm_rd_data [TILE_SIZE-1:0],
    input  logic                          z_rd_en,
    input  logic [U_ADDR_W-1:0]           z_rd_addr,
    output logic signed [DATA_WIDTH-1:0]  z_rd_data [TILE_SIZE-1:0],
    input  logic                          z_gate_rd_en,
    input  logic [U_ADDR_W-1:0]           z_gate_rd_addr,
    output logic signed [DATA_WIDTH-1:0]  z_gate_rd_data [TILE_SIZE-1:0],

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
    localparam logic [H_ADDR_W:0] H_TILE_COUNT = H_DEPTH;

    logic                         h_core_rd_en;
    logic [H_ADDR_W-1:0]          h_core_rd_addr0, h_core_rd_addr1, h_core_rd_addr2, h_core_rd_addr3;
    logic signed [DATA_WIDTH-1:0] h_core_rd_data0 [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] h_core_rd_data1 [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] h_core_rd_data2 [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] h_core_rd_data3 [TILE_SIZE-1:0];

    logic                         proj_valid;
    logic [ROW_TILE_W-1:0]        proj_tile_index;
    logic signed [DATA_WIDTH-1:0] proj_tile_data [TILE_SIZE-1:0];
    logic                         u_wr_en, z_wr_en;
    logic [U_ADDR_W-1:0]          out_wr_addr;

    reuse_ht_sram #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH     (H_DEPTH),
        .ADDR_W    (H_ADDR_W)
    ) u_h_sram (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(h_wr_en),
        .wr_addr(h_wr_addr),
        .wr_data(h_wr_data),
        .rd_en(h_core_rd_en),
        .rd_addr0(h_core_rd_addr0),
        .rd_addr1(h_core_rd_addr1),
        .rd_addr2(h_core_rd_addr2),
        .rd_addr3(h_core_rd_addr3),
        .rd_data0(h_core_rd_data0),
        .rd_data1(h_core_rd_data1),
        .rd_data2(h_core_rd_data2),
        .rd_data3(h_core_rd_data3)
    );

    reuse_vec_out_sram #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH     (U_DEPTH),
        .ADDR_W    (U_ADDR_W)
    ) u_u_sram (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(u_wr_en),
        .wr_addr(out_wr_addr),
        .wr_data(proj_tile_data),
        .rd_en(u_rd_en),
        .rd_addr(u_rd_addr),
        .rd_data(u_rd_data),
        .rd2_en(u_ssm_rd_en),
        .rd2_addr(u_ssm_rd_addr),
        .rd2_data(u_ssm_rd_data)
    );

    reuse_vec_out_sram #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH     (U_DEPTH),
        .ADDR_W    (U_ADDR_W)
    ) u_z_sram (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(z_wr_en),
        .wr_addr(out_wr_addr),
        .wr_data(proj_tile_data),
        .rd_en(z_rd_en),
        .rd_addr(z_rd_addr),
        .rd_data(z_rd_data),
        .rd2_en(z_gate_rd_en),
        .rd2_addr(z_gate_rd_addr),
        .rd2_data(z_gate_rd_data)
    );

    always_comb begin
        if (proj_tile_index >= U_DEPTH)
            out_wr_addr = proj_tile_index - U_DEPTH;
        else
            out_wr_addr = proj_tile_index[U_ADDR_W-1:0];
    end

    assign u_wr_en = proj_valid && (proj_tile_index < U_DEPTH);
    assign z_wr_en = proj_valid && (proj_tile_index >= U_DEPTH);

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
        .SRC_ADDR_W(H_ADDR_W),
        .SCALE_W(SCALE_W),
        .SCALE_FRAC_BITS(SCALE_FRAC_BITS),
        .USE_PER_CHANNEL_SCALE(USE_PER_CHANNEL_SCALE),
        .USE_STREAM_SOURCE(1'b0),
        .BANK0_INIT_FILE(INPROJ_BANK0_INIT_FILE),
        .BANK1_INIT_FILE(INPROJ_BANK1_INIT_FILE),
        .BANK2_INIT_FILE(INPROJ_BANK2_INIT_FILE),
        .BANK3_INIT_FILE(INPROJ_BANK3_INIT_FILE),
        .BANK4_INIT_FILE(INPROJ_BANK4_INIT_FILE),
        .BANK5_INIT_FILE(INPROJ_BANK5_INIT_FILE),
        .SCALE_INIT_FILE(INPROJ_SCALE_INIT_FILE),
        .REQUANT_ROUND_MODE(REQUANT_ROUND_MODE),
        .REQUANT_SAT_MODE(REQUANT_SAT_MODE)
    ) u_core (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .start(start),
        .compute_enable(1'b1),
        .src_tiles_available(H_TILE_COUNT),
        .busy(busy),
        .done(done),
        .src_stream_valid(1'b0),
        .src_stream_ready(),
        .src_stream_data('{default:'0}),
        .src_rd_en(h_core_rd_en),
        .src_rd_addr0(h_core_rd_addr0),
        .src_rd_addr1(h_core_rd_addr1),
        .src_rd_addr2(h_core_rd_addr2),
        .src_rd_addr3(h_core_rd_addr3),
        .src_rd_data0(h_core_rd_data0),
        .src_rd_data1(h_core_rd_data1),
        .src_rd_data2(h_core_rd_data2),
        .src_rd_data3(h_core_rd_data3),
        .dst_valid(proj_valid),
        .dst_ready(1'b1),
        .dst_tile_index(proj_tile_index),
        .dst_data(proj_tile_data),
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
