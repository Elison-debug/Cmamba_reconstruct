`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: slim_mamba_block_from_stage_dir
// Function:
//   Parameter-grouping wrapper around slim_mamba_block. A single
//   STAGE_DIR defines all operator memory images for one block instance.
//---------------------------------------------------------------
import slm_block_cfg_pkg::*;

module slim_mamba_block_from_stage_dir #(
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
    parameter string STAGE_DIR = "",
    parameter slm_block_cfg_t BLOCK_CFG = make_block_cfg_from_flags(1'b0, 1'b0, 1'b0, 1'b1, 1'b0)
)(
    input  logic clk,
    input  logic rst_n,
    input  logic block_start,
    output logic block_busy,
    output logic block_done,

    input  logic                         h_wr_en,
    input  logic [4:0]                   h_wr_addr,
    input  logic signed [DATA_WIDTH-1:0] h_wr_data [TILE_SIZE-1:0],

    output logic                         y_axis_TVALID,
    input  logic                         y_axis_TREADY,
    output logic signed [DATA_WIDTH-1:0] y_axis_TDATA [TILE_SIZE-1:0]
);
    localparam string IN0  = {STAGE_DIR, "/inproj_wbuf_bank0.mem"};
    localparam string IN1  = {STAGE_DIR, "/inproj_wbuf_bank1.mem"};
    localparam string IN2  = {STAGE_DIR, "/inproj_wbuf_bank2.mem"};
    localparam string IN3  = {STAGE_DIR, "/inproj_wbuf_bank3.mem"};
    localparam string IN4  = {STAGE_DIR, "/inproj_wbuf_bank4.mem"};
    localparam string IN5  = {STAGE_DIR, "/inproj_wbuf_bank5.mem"};
    localparam string INS  = {STAGE_DIR, "/inproj_scale_q15.mem"};
    localparam string DT0  = {STAGE_DIR, "/dt_wbuf_bank0.mem"};
    localparam string DT1  = {STAGE_DIR, "/dt_wbuf_bank1.mem"};
    localparam string DT2  = {STAGE_DIR, "/dt_wbuf_bank2.mem"};
    localparam string DT3  = {STAGE_DIR, "/dt_wbuf_bank3.mem"};
    localparam string DTS  = {STAGE_DIR, "/dt_scale_q15.mem"};
    localparam string OUT0 = {STAGE_DIR, "/outproj_wbuf_bank0.mem"};
    localparam string OUT1 = {STAGE_DIR, "/outproj_wbuf_bank1.mem"};
    localparam string OUT2 = {STAGE_DIR, "/outproj_wbuf_bank2.mem"};
    localparam string OUT3 = {STAGE_DIR, "/outproj_wbuf_bank3.mem"};
    localparam string OUT4 = {STAGE_DIR, "/outproj_wbuf_bank4.mem"};
    localparam string OUT5 = {STAGE_DIR, "/outproj_wbuf_bank5.mem"};
    localparam string OUTS = {STAGE_DIR, "/outproj_scale_q15.mem"};
    localparam string GAM  = {STAGE_DIR, "/norm_gamma_s16_q8p8.mem"};
    localparam string BIAS = {STAGE_DIR, "/bias_ROM.mem"};
    localparam string SUS  = {STAGE_DIR, "/state_u_to_state_q16.mem"};
    localparam string STQ  = {STAGE_DIR, "/state_to_q88_q16.mem"};

    slim_mamba_block #(
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
        .INPROJ_BANK0_INIT_FILE(IN0),
        .INPROJ_BANK1_INIT_FILE(IN1),
        .INPROJ_BANK2_INIT_FILE(IN2),
        .INPROJ_BANK3_INIT_FILE(IN3),
        .INPROJ_BANK4_INIT_FILE(IN4),
        .INPROJ_BANK5_INIT_FILE(IN5),
        .INPROJ_SCALE_INIT_FILE(INS),
        .DT_BANK0_INIT_FILE(DT0),
        .DT_BANK1_INIT_FILE(DT1),
        .DT_BANK2_INIT_FILE(DT2),
        .DT_BANK3_INIT_FILE(DT3),
        .DT_SCALE_INIT_FILE(DTS),
        .OUTPROJ_BANK0_INIT_FILE(OUT0),
        .OUTPROJ_BANK1_INIT_FILE(OUT1),
        .OUTPROJ_BANK2_INIT_FILE(OUT2),
        .OUTPROJ_BANK3_INIT_FILE(OUT3),
        .OUTPROJ_BANK4_INIT_FILE(OUT4),
        .OUTPROJ_BANK5_INIT_FILE(OUT5),
        .OUTPROJ_SCALE_INIT_FILE(OUTS),
        .NORM_GAMMA_INIT_FILE(GAM),
        .BIAS_INIT_FILE(BIAS),
        .STATE_U_TO_STATE_SCALE_INIT_FILE(SUS),
        .STATE_TO_Q88_SCALE_INIT_FILE(STQ),
        .BLOCK_CFG(BLOCK_CFG)
    ) u_impl (
        .clk(clk),
        .rst_n(rst_n),
        .block_start(block_start),
        .block_busy(block_busy),
        .block_done(block_done),
        .h_wr_en(h_wr_en),
        .h_wr_addr(h_wr_addr),
        .h_wr_data(h_wr_data),
        .y_axis_TVALID(y_axis_TVALID),
        .y_axis_TREADY(y_axis_TREADY),
        .y_axis_TDATA(y_axis_TDATA)
    );
endmodule

