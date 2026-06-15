`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: slm_ssm_stage
// Function:
//   Slim-Mamba state stage.
//   This stage owns:
//     - dt projection scheduling on the shared MAC fabric
//     - z-branch stream and gate preparation
//     - state update and clear control
//     - streamed emission of p_t rows toward the later out_proj stage
//
// The control boundary is explicit and self-contained.
//---------------------------------------------------------------

import slm_linear_cfg_pkg::*;
import slm_block_cfg_pkg::*;

module slm_ssm_stage #(
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
    parameter string DT_BANK0_INIT_FILE = "",
    parameter string DT_BANK1_INIT_FILE = "",
    parameter string DT_BANK2_INIT_FILE = "",
    parameter string DT_BANK3_INIT_FILE = "",
    parameter string DT_SCALE_INIT_FILE = "",
    parameter string BIAS_INIT_FILE = "",
    parameter string STATE_U_TO_STATE_SCALE_INIT_FILE = "",
    parameter string STATE_TO_Q88_SCALE_INIT_FILE = "",
    parameter slm_block_cfg_t BLOCK_CFG = make_block_cfg_from_flags(1'b0, 1'b0, 1'b0, 1'b0, 1'b0)
)(
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    output logic busy,
    output logic done,

    input  logic state_frame_start,
    input  logic state_continuous_en,
    input  logic state_force_clear,
    output logic state_clear_busy,
    output logic state_clear_done,

    output logic                         u_rd_en,
    output logic [XT_ADDR_W-1:0]         u_rd_addr,
    input  logic signed [DATA_WIDTH-1:0] u_rd_data [TILE_SIZE-1:0],

    output logic                         z_rd_en,
    output logic [XT_ADDR_W-1:0]         z_rd_addr,
    input  logic signed [DATA_WIDTH-1:0] z_rd_data [TILE_SIZE-1:0],

    output logic                         p_stream_valid,
    input  logic                         p_stream_ready,
    output logic signed [DATA_WIDTH-1:0] p_stream_data [TILE_SIZE-1:0],

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
    localparam int SSM_TILE_COUNT = 64;

    logic dt_busy;
    logic dt_linear_busy;
    logic dt_linear_done;
    logic dt_linear_launch_pulse;
    logic dt_desc_active;
    logic [7:0] dt_issue_count;
    logic dt_run_active;
    logic stage_busy_q;
    logic stage_done_q;
    logic [7:0] p_stream_count;
    logic p_stream_done;

    logic s_axis_TVALID_int;
    logic s_axis_TREADY_int;
    logic dt_mac_valid;
    logic signed [DATA_WIDTH-1:0] dt_mac_vec [TILE_SIZE-1:0];
    logic dt_mac_ready;
    logic xt_v;
    logic xt_r_int;
    logic signed [DATA_WIDTH-1:0] xt_d [TILE_SIZE-1:0];

    logic z_stream_start_int;
    logic z_stream_busy, z_stream_done;
    logic z_stream_valid, z_stream_ready;
    logic signed [DATA_WIDTH-1:0] z_stream_vec [TILE_SIZE-1:0];
    logic silu_valid, silu_ready;
    logic signed [DATA_WIDTH-1:0] silu_vec [TILE_SIZE-1:0];
    logic gate_axis_valid, gate_axis_ready;
    logic signed [DATA_WIDTH-1:0] gate_axis_data [TILE_SIZE-1:0];

    logic ssm_p_valid;
    logic ssm_p_ready;
    logic signed [DATA_WIDTH-1:0] ssm_p_data [TILE_SIZE-1:0];
    slm_linear_desc_t dt_desc_active_q;

    localparam slm_linear_desc_t DTPROJ_DESC = BLOCK_CFG.dt_desc;

    assign busy = stage_busy_q;
    assign done = stage_done_q;
    assign p_stream_valid = ssm_p_valid;
    assign p_stream_data = ssm_p_data;
    assign ssm_p_ready = p_stream_ready;
    assign p_stream_done = stage_busy_q && ssm_p_valid && p_stream_ready && (p_stream_count == SSM_TILE_COUNT-1);
    assign s_axis_TVALID_int = dt_run_active && (dt_issue_count < SSM_TILE_COUNT);
    assign dt_linear_busy = dt_run_active || dt_busy;
    assign dt_linear_done = dt_run_active && (dt_issue_count == SSM_TILE_COUNT) && !dt_busy;

    slm_linear_controller #(
        .STAGE_DESC(DTPROJ_DESC)
    ) u_dt_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .launch_req(start),
        .op_busy_i(dt_linear_busy),
        .op_done_i(dt_linear_done),
        .op_start_pulse(dt_linear_launch_pulse),
        .op_busy_o(),
        .op_done_o(),
        .desc_active(dt_desc_active),
        .active_desc(dt_desc_active_q)
    );

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            dt_issue_count <= '0;
            dt_run_active <= 1'b0;
            z_stream_start_int <= 1'b0;
            stage_busy_q <= 1'b0;
            stage_done_q <= 1'b0;
            p_stream_count <= '0;
        end else begin
            z_stream_start_int <= 1'b0;
            stage_done_q <= 1'b0;

            if (dt_linear_launch_pulse && !stage_busy_q) begin
                dt_issue_count <= '0;
                dt_run_active <= 1'b1;
                z_stream_start_int <= 1'b1;
                stage_busy_q <= 1'b1;
                p_stream_count <= '0;
            end

            if (s_axis_TVALID_int && s_axis_TREADY_int) begin
                dt_issue_count <= dt_issue_count + 1'b1;
            end

            if (stage_busy_q && ssm_p_valid && p_stream_ready && (p_stream_count < SSM_TILE_COUNT)) begin
                p_stream_count <= p_stream_count + 1'b1;
            end

            if (dt_linear_done) begin
                dt_run_active <= 1'b0;
            end

            if (p_stream_done) begin
                stage_busy_q <= 1'b0;
                stage_done_q <= 1'b1;
            end
        end
    end

    slm_linear_stage #(
        .ROLE(SLM_LINEAR_DTPROJ),
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .FRAC_BITS(FRAC_BITS),
        .N_BANK(N_BANK),
        .WDEPTH(WDEPTH),
        .WADDR_W(WADDR_W),
        .DATA_W(DATA_W),
        .XT_ADDR_W(XT_ADDR_W),
        .BANK0_INIT_FILE(DT_BANK0_INIT_FILE),
        .BANK1_INIT_FILE(DT_BANK1_INIT_FILE),
        .BANK2_INIT_FILE(DT_BANK2_INIT_FILE),
        .BANK3_INIT_FILE(DT_BANK3_INIT_FILE),
        .SCALE_INIT_FILE(DT_SCALE_INIT_FILE)
    ) u_dt_sched (
        .clk(clk),
        .rst_n(rst_n),
        .enable(1'b1),
        .start(dt_linear_launch_pulse),
        .busy(dt_busy),
        .done(),
        .h_wr_en(1'b0),
        .h_wr_addr('0),
        .h_wr_data('{default:'0}),
        .u_rd_en(1'b0),
        .u_rd_addr('0),
        .u_rd_data(),
        .u_ssm_rd_en(1'b0),
        .u_ssm_rd_addr('0),
        .u_ssm_rd_data(),
        .z_rd_en(1'b0),
        .z_rd_addr('0),
        .z_rd_data(),
        .z_gate_rd_en(1'b0),
        .z_gate_rd_addr('0),
        .z_gate_rd_data(),
        .dt_u_rd_en(u_rd_en),
        .dt_u_rd_addr(u_rd_addr),
        .dt_u_rd_data(u_rd_data),
        .p_rd_en(),
        .p_rd_addr(),
        .p_rd_data('{default:'0}),
        .out_compute_enable(1'b1),
        .out_preload_tiles_available('0),
        .s_axis_TVALID(s_axis_TVALID_int),
        .s_axis_TREADY(s_axis_TREADY_int),
        .m_axis_TVALID(dt_mac_valid),
        .m_axis_TREADY(dt_mac_ready),
        .reduced_trunc(dt_mac_vec),
        .xt_axis_TVALID(xt_v),
        .xt_axis_TREADY(xt_r_int),
        .xt_axis_TDATA(xt_d),
        .src_stream_valid(1'b0),
        .src_stream_ready(),
        .src_stream_data('{default:'0}),
        .y_axis_TVALID(),
        .y_axis_TREADY(1'b0),
        .y_axis_TDATA(),
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

    reuse_z_stream_reader #(
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .Z_DEPTH(64),
        .Z_ADDR_W(XT_ADDR_W)
    ) u_z_reader (
        .clk(clk),
        .rst_n(rst_n),
        .enable(1'b1),
        .start(z_stream_start_int),
        .busy(z_stream_busy),
        .done(z_stream_done),
        .z_rd_en(z_rd_en),
        .z_rd_addr(z_rd_addr),
        .z_rd_data(z_rd_data),
        .out_valid(z_stream_valid),
        .out_ready(z_stream_ready),
        .out_vec(z_stream_vec)
    );

    reuse_silu_vec4 #(
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .FRAC_BITS(FRAC_BITS),
        .ADDR_BITS(ADDR_BITS),
        .LUT_FILE(LUT_FILE)
    ) u_silu (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(z_stream_valid),
        .in_ready(z_stream_ready),
        .in_vec(z_stream_vec),
        .out_valid(silu_valid),
        .out_ready(silu_ready),
        .out_vec(silu_vec)
    );

    always_comb begin
        gate_axis_valid = silu_valid;
        silu_ready = gate_axis_ready;
        for (int i = 0; i < TILE_SIZE; i++) begin
            gate_axis_data[i] = silu_vec[i];
        end
    end

    reuse_ssm_core #(
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .D(D),
        .PIPE_LAT(PIPE_LAT),
        .ADDR_BITS(ADDR_BITS),
        .LUT_FILE(LUT_FILE),
        .S_ADDR_W(S_ADDR_W),
        .G_FRAC_BITS(G_FRAC_BITS),
        .BIAS_INIT_FILE(BIAS_INIT_FILE),
        .USE_SCALED_STATE_SCAN(BLOCK_CFG.use_scaled_state_scan),
        .STATE_U_TO_STATE_SCALE_INIT_FILE(STATE_U_TO_STATE_SCALE_INIT_FILE),
        .STATE_TO_Q88_SCALE_INIT_FILE(STATE_TO_Q88_SCALE_INIT_FILE)
    ) u_ssm_core (
        .clk(clk),
        .rst_n(rst_n),
        .state_frame_start(state_frame_start),
        .state_continuous_en(state_continuous_en),
        .state_force_clear(state_force_clear),
        .state_clear_busy(state_clear_busy),
        .state_clear_done(state_clear_done),
        .mac_m_valid(dt_mac_valid),
        .mac_vec(dt_mac_vec),
        .mac_m_ready(dt_mac_ready),
        .xt_v(xt_v),
        .xt_r_int(xt_r_int),
        .xt_d(xt_d),
        .gate_axis_valid(gate_axis_valid),
        .gate_axis_ready(gate_axis_ready),
        .gate_axis_data(gate_axis_data),
        .y_axis_TVALID(ssm_p_valid),
        .y_axis_TREADY(ssm_p_ready),
        .y_axis_TDATA(ssm_p_data)
    );

endmodule

