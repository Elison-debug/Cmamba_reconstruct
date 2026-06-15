`timescale 1ns/1ps

module mm_state_datapath #(
    parameter int TILE_SIZE = 4,
    parameter int DATA_WIDTH = 16,
    parameter int STATE_ADDR_W = 6,
    parameter int SCALE_W = 32,
    parameter int SCALE_FRAC_BITS = 16
)(
    input  logic clk,
    input  logic rst_n,
    input  logic state_frame_start,
    input  logic state_continuous_en,
    input  logic state_force_clear,
    output logic state_clear_done,
    input  logic dt_valid,
    output logic dt_ready,
    input  logic [STATE_ADDR_W-1:0] dt_addr,
    input  logic [DATA_WIDTH-1:0] lam_vec [TILE_SIZE-1:0],
    input  logic signed [DATA_WIDTH-1:0] u_vec [TILE_SIZE-1:0],
    input  logic gate_valid,
    output logic gate_ready,
    input  logic signed [DATA_WIDTH-1:0] gate_vec [TILE_SIZE-1:0],
    output logic p_valid,
    input  logic p_ready,
    output logic [STATE_ADDR_W-1:0] p_addr,
    output logic signed [DATA_WIDTH-1:0] p_vec [TILE_SIZE-1:0]
);
    logic scale_valid, scale_ready;
    logic [STATE_ADDR_W-1:0] scale_addr;
    logic [DATA_WIDTH-1:0] scale_lam_vec [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] scale_u_vec [TILE_SIZE-1:0];
    logic [SCALE_W-1:0] scale_u2s [TILE_SIZE-1:0];
    logic [SCALE_W-1:0] scale_s2q [TILE_SIZE-1:0];

    logic state_valid, state_ready;
    logic [STATE_ADDR_W-1:0] state_addr;
    logic signed [DATA_WIDTH-1:0] state_vec [TILE_SIZE-1:0];

    mm_runtime_state_scale_stage #(
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .SCALE_W(SCALE_W),
        .SCALE_FRAC_BITS(SCALE_FRAC_BITS)
    ) u_scale (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(dt_valid),
        .in_ready(dt_ready),
        .in_addr(dt_addr),
        .in_lam_vec(lam_vec),
        .in_u_vec(u_vec),
        .out_valid(scale_valid),
        .out_ready(scale_ready),
        .out_addr(scale_addr),
        .out_lam_vec(scale_lam_vec),
        .out_u_vec(scale_u_vec),
        .out_u_to_state_scale_vec(scale_u2s),
        .out_state_to_q88_scale_vec(scale_s2q)
    );

    mm_gated_state_update_stage #(
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .STATE_ADDR_W(STATE_ADDR_W),
        .SCALE_W(SCALE_W)
    ) u_state (
        .clk(clk),
        .rst_n(rst_n),
        .state_frame_start(state_frame_start),
        .state_continuous_en(state_continuous_en),
        .state_force_clear(state_force_clear),
        .state_clear_done(state_clear_done),
        .in_valid(scale_valid),
        .in_ready(scale_ready),
        .in_addr(scale_addr),
        .lam_vec(scale_lam_vec),
        .u_vec(scale_u_vec),
        .u_to_state_scale_vec(scale_u2s),
        .state_to_q88_scale_vec(scale_s2q),
        .out_valid(state_valid),
        .out_ready(state_ready),
        .out_addr(state_addr),
        .h_q88_vec(state_vec)
    );

    mm_gate_out_stage #(
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .STATE_ADDR_W(STATE_ADDR_W)
    ) u_gate_out (
        .clk(clk),
        .rst_n(rst_n),
        .h_valid(state_valid),
        .h_ready(state_ready),
        .h_addr(state_addr),
        .h_vec(state_vec),
        .g_valid(gate_valid),
        .g_ready(gate_ready),
        .g_vec(gate_vec),
        .out_valid(p_valid),
        .out_ready(p_ready),
        .out_addr(p_addr),
        .out_vec(p_vec)
    );
endmodule


