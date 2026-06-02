`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: slim_mamba_block
// Function:
//   Refactored exact block top that keeps the proven numeric operators but
//   replaces the legacy monolithic orchestration with explicit stage control.
//
// Stage order:
//   1) RMSNorm on h_t
//   2) in_proj on shared MAC fabric
//   3) SiLU activation fill of u-branch SRAM
//   4) exact SSM stage (dt + gate + state update + p capture)
//   5) out_proj on shared MAC fabric
//---------------------------------------------------------------

import slm_linear_cfg_pkg::*;
import slm_block_cfg_pkg::*;

module slim_mamba_block #(
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
    parameter string INPROJ_BANK0_INIT_FILE = "",
    parameter string INPROJ_BANK1_INIT_FILE = "",
    parameter string INPROJ_BANK2_INIT_FILE = "",
    parameter string INPROJ_BANK3_INIT_FILE = "",
    parameter string INPROJ_BANK4_INIT_FILE = "",
    parameter string INPROJ_BANK5_INIT_FILE = "",
    parameter string INPROJ_SCALE_INIT_FILE = "",
    parameter string DT_BANK0_INIT_FILE = "",
    parameter string DT_BANK1_INIT_FILE = "",
    parameter string DT_BANK2_INIT_FILE = "",
    parameter string DT_BANK3_INIT_FILE = "",
    parameter string DT_SCALE_INIT_FILE = "",
    parameter string OUTPROJ_BANK0_INIT_FILE = "",
    parameter string OUTPROJ_BANK1_INIT_FILE = "",
    parameter string OUTPROJ_BANK2_INIT_FILE = "",
    parameter string OUTPROJ_BANK3_INIT_FILE = "",
    parameter string OUTPROJ_BANK4_INIT_FILE = "",
    parameter string OUTPROJ_BANK5_INIT_FILE = "",
    parameter string OUTPROJ_SCALE_INIT_FILE = "",
    parameter string NORM_GAMMA_INIT_FILE = "",
    parameter string BIAS_INIT_FILE = "",
    parameter string STATE_U_TO_STATE_SCALE_INIT_FILE = "",
    parameter string STATE_TO_Q88_SCALE_INIT_FILE = "",
    parameter slm_block_cfg_t BLOCK_CFG = make_block_cfg_from_flags(1'b0, 1'b0, 1'b0, 1'b0, 1'b0)
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
    logic norm_start, inproj_start, ssm_start, outproj_start;
    logic uact_fill_active;

    logic norm_busy, norm_done;
    logic inproj_busy, inproj_done;
    logic ssm_busy, ssm_done;
    logic outproj_busy, outproj_done;
    logic inproj_op_busy, inproj_op_done;
    logic outproj_op_busy, outproj_op_done;
    logic inproj_launch_pulse, outproj_launch_pulse;
    logic inproj_desc_active, outproj_desc_active;
    slm_linear_desc_t inproj_desc_active_q;
    slm_linear_desc_t outproj_desc_active_q;

    logic norm_wr_en;
    logic [4:0] norm_wr_addr;
    logic signed [DATA_WIDTH-1:0] norm_wr_data [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] gamma_wr_zero [TILE_SIZE-1:0];

    logic h_inproj_wr_en;
    logic [4:0] h_inproj_wr_addr;
    logic signed [DATA_WIDTH-1:0] h_inproj_wr_data [TILE_SIZE-1:0];

    logic                         u_mux_rd_en;
    logic [5:0]                   u_mux_rd_addr;
    logic signed [DATA_WIDTH-1:0] u_mux_rd_data [TILE_SIZE-1:0];
    logic                         u_ssm_rd_en;
    logic [5:0]                   u_ssm_rd_addr;
    logic signed [DATA_WIDTH-1:0] u_ssm_rd_data [TILE_SIZE-1:0];
    logic                         z_rd_en;
    logic [5:0]                   z_rd_addr;
    logic signed [DATA_WIDTH-1:0] z_rd_data [TILE_SIZE-1:0];
    logic                         z_gate_rd_en;
    logic [5:0]                   z_gate_rd_addr;
    logic signed [DATA_WIDTH-1:0] z_gate_rd_data [TILE_SIZE-1:0];

    logic                         u_stream_busy, u_stream_done;
    logic                         u_stream_valid, u_stream_ready;
    logic signed [DATA_WIDTH-1:0] u_stream_vec [TILE_SIZE-1:0];
    logic                         uact_valid, uact_ready;
    logic signed [DATA_WIDTH-1:0] uact_vec [TILE_SIZE-1:0];
    logic                         uact_wr_en;
    logic [5:0]                   uact_wr_addr;
    logic signed [DATA_WIDTH-1:0] uact_wr_data [TILE_SIZE-1:0];
    logic                         uact_rd_en;
    logic [5:0]                   uact_rd_addr;
    logic signed [DATA_WIDTH-1:0] uact_rd_data [TILE_SIZE-1:0];
    logic [6:0]                   uact_wr_count;
    logic                         uact_fill_done;

    logic                         p_wr_en;
    logic [S_ADDR_W-1:0]          p_wr_addr;
    logic signed [DATA_WIDTH-1:0] p_wr_data [TILE_SIZE-1:0];
    logic                         p_rd_en_out;
    logic [5:0]                   p_rd_addr0_out, p_rd_addr1_out, p_rd_addr2_out, p_rd_addr3_out;
    logic signed [DATA_WIDTH-1:0] p_rd_data0_out [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] p_rd_data1_out [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] p_rd_data2_out [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] p_rd_data3_out [TILE_SIZE-1:0];

    logic [1:0]                    dt_mode, in_mode, out_mode;
    logic [6:0]                    dt_col_blocks, in_col_blocks, out_col_blocks;
    logic                          dt_reduce_rows, in_reduce_rows, out_reduce_rows;
    logic                          dt_valid_in, in_valid_in, out_valid_in;
    logic signed [DATA_WIDTH-1:0]  dt_A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  dt_A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  dt_A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  dt_A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  dt_B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  dt_B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  dt_B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  dt_B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  in_A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  in_A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  in_A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  in_A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  in_B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  in_B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  in_B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  in_B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  out_A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  out_A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  out_A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  out_A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  out_B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  out_B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  out_B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0]  out_B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];

    logic signed [ACC_WIDTH-1:0]   dt_reduced_vec [TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]   dt_reduced_mat_0 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]   dt_reduced_mat_1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]   dt_reduced_mat_2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]   dt_reduced_mat_3 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]   in_reduced_vec [TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]   in_reduced_mat_0 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]   in_reduced_mat_1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]   in_reduced_mat_2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]   in_reduced_mat_3 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]   out_reduced_vec [TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]   out_reduced_mat_0 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]   out_reduced_mat_1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]   out_reduced_mat_2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]   out_reduced_mat_3 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic                          dt_valid_out, in_valid_out, out_valid_out;
    logic                          state_clear_busy, state_clear_done;

    localparam slm_linear_desc_t INPROJ_DESC = BLOCK_CFG.inproj_desc;
    localparam slm_linear_desc_t OUTPROJ_DESC = BLOCK_CFG.outproj_desc;

    assign dt_reduce_rows = 1'b1;
    assign in_reduce_rows = 1'b1;
    assign out_reduce_rows = 1'b1;

    always_comb begin
        h_inproj_wr_en = norm_wr_en;
        h_inproj_wr_addr = norm_wr_addr;
        for (int i = 0; i < TILE_SIZE; i++) begin
            h_inproj_wr_data[i] = norm_wr_data[i];
            gamma_wr_zero[i] = '0;
            uact_wr_data[i] = uact_vec[i];
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            uact_wr_count <= '0;
        end else begin
            if (!uact_fill_active) begin
                uact_wr_count <= '0;
            end else if (uact_wr_en && (uact_wr_count < 7'd64)) begin
                uact_wr_count <= uact_wr_count + 1'b1;
            end
        end
    end

    assign uact_fill_done = (uact_wr_count == 7'd64);
    assign uact_ready = 1'b1;
    assign uact_wr_en = uact_valid && uact_ready;
    assign uact_wr_addr = uact_wr_count[5:0];
    assign uact_rd_en = u_ssm_rd_en;
    assign uact_rd_addr = u_ssm_rd_addr;

    slm_block_controller u_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .block_start(block_start),
        .norm_done(norm_done),
        .inproj_done(inproj_done),
        .uact_fill_done(uact_fill_done),
        .ssm_done(ssm_done),
        .outproj_done(outproj_done),
        .norm_start(norm_start),
        .inproj_start(inproj_start),
        .ssm_start(ssm_start),
        .outproj_start(outproj_start),
        .uact_fill_active(uact_fill_active),
        .block_busy(block_busy),
        .block_done(block_done)
    );

    slm_linear_controller #(
        .STAGE_DESC(INPROJ_DESC)
    ) u_inproj_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .launch_req(inproj_start),
        .op_busy_i(inproj_op_busy),
        .op_done_i(inproj_op_done),
        .op_start_pulse(inproj_launch_pulse),
        .op_busy_o(inproj_busy),
        .op_done_o(inproj_done),
        .desc_active(inproj_desc_active),
        .active_desc(inproj_desc_active_q)
    );

    slm_linear_controller #(
        .STAGE_DESC(OUTPROJ_DESC)
    ) u_outproj_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .launch_req(outproj_start),
        .op_busy_i(outproj_op_busy),
        .op_done_i(outproj_op_done),
        .op_start_pulse(outproj_launch_pulse),
        .op_busy_o(outproj_busy),
        .op_done_o(outproj_done),
        .desc_active(outproj_desc_active),
        .active_desc(outproj_desc_active_q)
    );

    reuse_rmsnorm_scheduler #(
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .H_DEPTH(32),
        .H_ADDR_W(5),
        .NORM_GAMMA_INIT_FILE(NORM_GAMMA_INIT_FILE)
    ) u_rmsnorm (
        .clk(clk),
        .rst_n(rst_n),
        .enable(1'b1),
        .start(norm_start),
        .busy(norm_busy),
        .done(norm_done),
        .h_wr_en(h_wr_en),
        .h_wr_addr(h_wr_addr),
        .h_wr_data(h_wr_data),
        .gamma_wr_en(1'b0),
        .gamma_wr_addr('0),
        .gamma_wr_data(gamma_wr_zero),
        .norm_wr_en(norm_wr_en),
        .norm_wr_addr(norm_wr_addr),
        .norm_wr_data(norm_wr_data)
    );

    slm_linear_stage #(
        .ROLE(SLM_LINEAR_INPROJ),
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .FRAC_BITS(FRAC_BITS),
        .N_BANK(N_BANK),
        .WDEPTH(WDEPTH),
        .WADDR_W(WADDR_W),
        .DATA_W(DATA_W),
        .XT_ADDR_W(6),
        .USE_PER_CHANNEL_SCALE(BLOCK_CFG.inproj_desc.use_per_channel_scale),
        .BANK0_INIT_FILE(INPROJ_BANK0_INIT_FILE),
        .BANK1_INIT_FILE(INPROJ_BANK1_INIT_FILE),
        .BANK2_INIT_FILE(INPROJ_BANK2_INIT_FILE),
        .BANK3_INIT_FILE(INPROJ_BANK3_INIT_FILE),
        .BANK4_INIT_FILE(INPROJ_BANK4_INIT_FILE),
        .BANK5_INIT_FILE(INPROJ_BANK5_INIT_FILE),
        .SCALE_INIT_FILE(INPROJ_SCALE_INIT_FILE)
    ) u_in_proj (
        .clk(clk),
        .rst_n(rst_n),
        .enable(1'b1),
        .start(inproj_launch_pulse),
        .busy(inproj_op_busy),
        .done(inproj_op_done),
        .h_wr_en(h_inproj_wr_en),
        .h_wr_addr(h_inproj_wr_addr),
        .h_wr_data(h_inproj_wr_data),
        .u_rd_en(u_mux_rd_en),
        .u_rd_addr(u_mux_rd_addr),
        .u_rd_data(u_mux_rd_data),
        .u_ssm_rd_en(1'b0),
        .u_ssm_rd_addr('0),
        .u_ssm_rd_data(),
        .z_rd_en(1'b0),
        .z_rd_addr('0),
        .z_rd_data(),
        .z_gate_rd_en(z_gate_rd_en),
        .z_gate_rd_addr(z_gate_rd_addr),
        .z_gate_rd_data(z_gate_rd_data),
        .dt_u_rd_en(),
        .dt_u_rd_addr(),
        .dt_u_rd_data('{default:'0}),
        .s_axis_TVALID(1'b0),
        .s_axis_TREADY(),
        .m_axis_TVALID(),
        .m_axis_TREADY(1'b0),
        .reduced_trunc(),
        .xt_axis_TVALID(),
        .xt_axis_TREADY(1'b0),
        .xt_axis_TDATA(),
        .p_rd_en(),
        .p_rd_addr0(),
        .p_rd_addr1(),
        .p_rd_addr2(),
        .p_rd_addr3(),
        .p_rd_data0('{default:'0}),
        .p_rd_data1('{default:'0}),
        .p_rd_data2('{default:'0}),
        .p_rd_data3('{default:'0}),
        .y_axis_TVALID(),
        .y_axis_TREADY(1'b0),
        .y_axis_TDATA(),
        .fabric_mode(in_mode),
        .fabric_col_blocks(in_col_blocks),
        .fabric_valid_in(in_valid_in),
        .fabric_A0_mat(in_A0_mat),
        .fabric_A1_mat(in_A1_mat),
        .fabric_A2_mat(in_A2_mat),
        .fabric_A3_mat(in_A3_mat),
        .fabric_B0_mat(in_B0_mat),
        .fabric_B1_mat(in_B1_mat),
        .fabric_B2_mat(in_B2_mat),
        .fabric_B3_mat(in_B3_mat),
        .fabric_reduced_vec(in_reduced_vec),
        .fabric_reduced_mat_0(in_reduced_mat_0),
        .fabric_reduced_mat_1(in_reduced_mat_1),
        .fabric_reduced_mat_2(in_reduced_mat_2),
        .fabric_reduced_mat_3(in_reduced_mat_3),
        .fabric_valid_out(in_valid_out)
    );

    reuse_z_stream_reader #(
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .Z_DEPTH(64),
        .Z_ADDR_W(6)
    ) u_u_reader (
        .clk(clk),
        .rst_n(rst_n),
        .enable(1'b1),
        .start(inproj_done),
        .busy(u_stream_busy),
        .done(u_stream_done),
        .z_rd_en(u_mux_rd_en),
        .z_rd_addr(u_mux_rd_addr),
        .z_rd_data(u_mux_rd_data),
        .out_valid(u_stream_valid),
        .out_ready(u_stream_ready),
        .out_vec(u_stream_vec)
    );

    reuse_silu_vec4 #(
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .FRAC_BITS(FRAC_BITS),
        .ADDR_BITS(ADDR_BITS),
        .LUT_FILE(LUT_FILE)
    ) u_u_silu (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(u_stream_valid),
        .in_ready(u_stream_ready),
        .in_vec(u_stream_vec),
        .out_valid(uact_valid),
        .out_ready(uact_ready),
        .out_vec(uact_vec)
    );

    reuse_ht_sram_sp #(
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(64),
        .ADDR_W(6)
    ) u_uact_sram (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(uact_wr_en),
        .wr_addr(uact_wr_addr),
        .wr_data(uact_wr_data),
        .rd_en(uact_rd_en),
        .rd_addr(uact_rd_addr),
        .rd_data(uact_rd_data)
    );

    slm_ssm_stage #(
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
        .DT_BANK0_INIT_FILE(DT_BANK0_INIT_FILE),
        .DT_BANK1_INIT_FILE(DT_BANK1_INIT_FILE),
        .DT_BANK2_INIT_FILE(DT_BANK2_INIT_FILE),
        .DT_BANK3_INIT_FILE(DT_BANK3_INIT_FILE),
        .DT_SCALE_INIT_FILE(DT_SCALE_INIT_FILE),
        .BIAS_INIT_FILE(BIAS_INIT_FILE),
        .STATE_U_TO_STATE_SCALE_INIT_FILE(STATE_U_TO_STATE_SCALE_INIT_FILE),
        .STATE_TO_Q88_SCALE_INIT_FILE(STATE_TO_Q88_SCALE_INIT_FILE),
        .BLOCK_CFG(BLOCK_CFG)
    ) u_ssm_stage (
        .clk(clk),
        .rst_n(rst_n),
        .start(ssm_start),
        .busy(ssm_busy),
        .done(ssm_done),
        .state_frame_start(block_start),
        .state_continuous_en(BLOCK_CFG.state_continuous_default),
        .state_force_clear(1'b0),
        .state_clear_busy(state_clear_busy),
        .state_clear_done(state_clear_done),
        .u_rd_en(u_ssm_rd_en),
        .u_rd_addr(u_ssm_rd_addr),
        .u_rd_data(uact_rd_data),
        .z_rd_en(z_rd_en),
        .z_rd_addr(z_rd_addr),
        .z_rd_data(z_rd_data),
        .p_wr_en(p_wr_en),
        .p_wr_addr(p_wr_addr),
        .p_wr_data(p_wr_data),
        .fabric_mode(dt_mode),
        .fabric_col_blocks(dt_col_blocks),
        .fabric_valid_in(dt_valid_in),
        .fabric_A0_mat(dt_A0_mat),
        .fabric_A1_mat(dt_A1_mat),
        .fabric_A2_mat(dt_A2_mat),
        .fabric_A3_mat(dt_A3_mat),
        .fabric_B0_mat(dt_B0_mat),
        .fabric_B1_mat(dt_B1_mat),
        .fabric_B2_mat(dt_B2_mat),
        .fabric_B3_mat(dt_B3_mat),
        .fabric_reduced_vec(dt_reduced_vec),
        .fabric_reduced_mat_0(dt_reduced_mat_0),
        .fabric_reduced_mat_1(dt_reduced_mat_1),
        .fabric_reduced_mat_2(dt_reduced_mat_2),
        .fabric_reduced_mat_3(dt_reduced_mat_3),
        .fabric_valid_out(dt_valid_out)
    );

    reuse_ht_sram #(
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(64),
        .ADDR_W(6)
    ) u_p_sram (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(p_wr_en),
        .wr_addr(p_wr_addr),
        .wr_data(p_wr_data),
        .rd_en(p_rd_en_out),
        .rd_addr0(p_rd_addr0_out),
        .rd_addr1(p_rd_addr1_out),
        .rd_addr2(p_rd_addr2_out),
        .rd_addr3(p_rd_addr3_out),
        .rd_data0(p_rd_data0_out),
        .rd_data1(p_rd_data1_out),
        .rd_data2(p_rd_data2_out),
        .rd_data3(p_rd_data3_out)
    );

    slm_linear_stage #(
        .ROLE(SLM_LINEAR_OUTPROJ),
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .FRAC_BITS(FRAC_BITS),
        .N_BANK(N_BANK),
        .WDEPTH(WDEPTH),
        .WADDR_W(WADDR_W),
        .DATA_W(DATA_W),
        .XT_ADDR_W(6),
        .USE_PER_CHANNEL_SCALE(BLOCK_CFG.outproj_desc.use_per_channel_scale),
        .BANK0_INIT_FILE(OUTPROJ_BANK0_INIT_FILE),
        .BANK1_INIT_FILE(OUTPROJ_BANK1_INIT_FILE),
        .BANK2_INIT_FILE(OUTPROJ_BANK2_INIT_FILE),
        .BANK3_INIT_FILE(OUTPROJ_BANK3_INIT_FILE),
        .BANK4_INIT_FILE(OUTPROJ_BANK4_INIT_FILE),
        .BANK5_INIT_FILE(OUTPROJ_BANK5_INIT_FILE),
        .SCALE_INIT_FILE(OUTPROJ_SCALE_INIT_FILE)
    ) u_out_proj (
        .clk(clk),
        .rst_n(rst_n),
        .enable(1'b1),
        .start(outproj_launch_pulse),
        .busy(outproj_op_busy),
        .done(outproj_op_done),
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
        .dt_u_rd_en(),
        .dt_u_rd_addr(),
        .dt_u_rd_data('{default:'0}),
        .s_axis_TVALID(1'b0),
        .s_axis_TREADY(),
        .m_axis_TVALID(),
        .m_axis_TREADY(1'b0),
        .reduced_trunc(),
        .xt_axis_TVALID(),
        .xt_axis_TREADY(1'b0),
        .xt_axis_TDATA(),
        .p_rd_en(p_rd_en_out),
        .p_rd_addr0(p_rd_addr0_out),
        .p_rd_addr1(p_rd_addr1_out),
        .p_rd_addr2(p_rd_addr2_out),
        .p_rd_addr3(p_rd_addr3_out),
        .p_rd_data0(p_rd_data0_out),
        .p_rd_data1(p_rd_data1_out),
        .p_rd_data2(p_rd_data2_out),
        .p_rd_data3(p_rd_data3_out),
        .y_axis_TVALID(y_axis_TVALID),
        .y_axis_TREADY(y_axis_TREADY),
        .y_axis_TDATA(y_axis_TDATA),
        .fabric_mode(out_mode),
        .fabric_col_blocks(out_col_blocks),
        .fabric_valid_in(out_valid_in),
        .fabric_A0_mat(out_A0_mat),
        .fabric_A1_mat(out_A1_mat),
        .fabric_A2_mat(out_A2_mat),
        .fabric_A3_mat(out_A3_mat),
        .fabric_B0_mat(out_B0_mat),
        .fabric_B1_mat(out_B1_mat),
        .fabric_B2_mat(out_B2_mat),
        .fabric_B3_mat(out_B3_mat),
        .fabric_reduced_vec(out_reduced_vec),
        .fabric_reduced_mat_0(out_reduced_mat_0),
        .fabric_reduced_mat_1(out_reduced_mat_1),
        .fabric_reduced_mat_2(out_reduced_mat_2),
        .fabric_reduced_mat_3(out_reduced_mat_3),
        .fabric_valid_out(out_valid_out)
    );

    slm_fabric_scheduler #(
        .TILE_SIZE(TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .FRAC_BITS(FRAC_BITS)
    ) u_mgr (
        .clk(clk),
        .rst_n(rst_n),
        .dt_busy(ssm_busy),
        .dt_mode(dt_mode),
        .dt_col_blocks(dt_col_blocks),
        .dt_reduce_rows(dt_reduce_rows),
        .dt_valid_in(dt_valid_in),
        .dt_A0_mat(dt_A0_mat),
        .dt_A1_mat(dt_A1_mat),
        .dt_A2_mat(dt_A2_mat),
        .dt_A3_mat(dt_A3_mat),
        .dt_B0_mat(dt_B0_mat),
        .dt_B1_mat(dt_B1_mat),
        .dt_B2_mat(dt_B2_mat),
        .dt_B3_mat(dt_B3_mat),
        .dt_reduced_vec(dt_reduced_vec),
        .dt_reduced_mat_0(dt_reduced_mat_0),
        .dt_reduced_mat_1(dt_reduced_mat_1),
        .dt_reduced_mat_2(dt_reduced_mat_2),
        .dt_reduced_mat_3(dt_reduced_mat_3),
        .dt_valid_out(dt_valid_out),
        .in_busy(inproj_busy),
        .in_mode(in_mode),
        .in_col_blocks(in_col_blocks),
        .in_reduce_rows(in_reduce_rows),
        .in_valid_in(in_valid_in),
        .in_A0_mat(in_A0_mat),
        .in_A1_mat(in_A1_mat),
        .in_A2_mat(in_A2_mat),
        .in_A3_mat(in_A3_mat),
        .in_B0_mat(in_B0_mat),
        .in_B1_mat(in_B1_mat),
        .in_B2_mat(in_B2_mat),
        .in_B3_mat(in_B3_mat),
        .in_reduced_vec(in_reduced_vec),
        .in_reduced_mat_0(in_reduced_mat_0),
        .in_reduced_mat_1(in_reduced_mat_1),
        .in_reduced_mat_2(in_reduced_mat_2),
        .in_reduced_mat_3(in_reduced_mat_3),
        .in_valid_out(in_valid_out),
        .out_busy(outproj_busy),
        .out_mode(out_mode),
        .out_col_blocks(out_col_blocks),
        .out_reduce_rows(out_reduce_rows),
        .out_valid_in(out_valid_in),
        .out_A0_mat(out_A0_mat),
        .out_A1_mat(out_A1_mat),
        .out_A2_mat(out_A2_mat),
        .out_A3_mat(out_A3_mat),
        .out_B0_mat(out_B0_mat),
        .out_B1_mat(out_B1_mat),
        .out_B2_mat(out_B2_mat),
        .out_B3_mat(out_B3_mat),
        .out_reduced_vec(out_reduced_vec),
        .out_reduced_mat_0(out_reduced_mat_0),
        .out_reduced_mat_1(out_reduced_mat_1),
        .out_reduced_mat_2(out_reduced_mat_2),
        .out_reduced_mat_3(out_reduced_mat_3),
        .out_valid_out(out_valid_out)
    );
endmodule

