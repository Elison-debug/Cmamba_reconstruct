`timescale 1ns/1ps

import slm_linear_cfg_pkg::*;

//---------------------------------------------------------------
// Module: slm_linear_stage
// Function:
//   Common stage-level contract for the three linear operators in the
//   Slim-Mamba block. The module presents one shared launch/busy/done
//   interface, one shared fabric interface, and one shared set of side-band
//   vector ports. The in_proj and out_proj roles are backed by the shared
//   linear GEMV execution core. The source vector can arrive either from SRAM
//   or from a tile stream, which lets later stages consume upstream output
//   streams without inserting an intermediate memory-only barrier. The dt_proj
//   role still uses its dedicated state-path scheduler.
//---------------------------------------------------------------
module slm_linear_stage #(
    parameter slm_linear_role_t ROLE = SLM_LINEAR_INPROJ,
    parameter int TILE_SIZE   = 4,
    parameter int DATA_WIDTH  = 16,
    parameter int ACC_WIDTH   = 32,
    parameter int FRAC_BITS   = 8,
    parameter int N_BANK      = 6,
    parameter int WDEPTH      = 1024,
    parameter int WADDR_W     = $clog2(WDEPTH),
    parameter int DATA_W      = 256,
    parameter int XT_ADDR_W   = 6,
    parameter bit USE_PER_CHANNEL_SCALE = 0,
    parameter string BANK0_INIT_FILE = "",
    parameter string BANK1_INIT_FILE = "",
    parameter string BANK2_INIT_FILE = "",
    parameter string BANK3_INIT_FILE = "",
    parameter string BANK4_INIT_FILE = "",
    parameter string BANK5_INIT_FILE = "",
    parameter string SCALE_INIT_FILE = ""
)(
    input  logic clk,
    input  logic rst_n,
    input  logic enable,
    input  logic start,
    output logic busy,
    output logic done,

    // in_proj h input
    input  logic                          h_wr_en,
    input  logic [4:0]                    h_wr_addr,
    input  logic signed [DATA_WIDTH-1:0]  h_wr_data [TILE_SIZE-1:0],

    // in_proj-side u/z vector SRAM read access
    input  logic                          u_rd_en,
    input  logic [XT_ADDR_W-1:0]          u_rd_addr,
    output logic signed [DATA_WIDTH-1:0]  u_rd_data [TILE_SIZE-1:0],
    input  logic                          u_ssm_rd_en,
    input  logic [XT_ADDR_W-1:0]          u_ssm_rd_addr,
    output logic signed [DATA_WIDTH-1:0]  u_ssm_rd_data [TILE_SIZE-1:0],
    input  logic                          z_rd_en,
    input  logic [XT_ADDR_W-1:0]          z_rd_addr,
    output logic signed [DATA_WIDTH-1:0]  z_rd_data [TILE_SIZE-1:0],
    input  logic                          z_gate_rd_en,
    input  logic [XT_ADDR_W-1:0]          z_gate_rd_addr,
    output logic signed [DATA_WIDTH-1:0]  z_gate_rd_data [TILE_SIZE-1:0],

    // dt-proj-side u vector request/readback
    output logic                          dt_u_rd_en,
    output logic [XT_ADDR_W-1:0]          dt_u_rd_addr,
    input  logic signed [DATA_WIDTH-1:0]  dt_u_rd_data [TILE_SIZE-1:0],

    // out-proj-side p buffer read access
    output logic                          p_rd_en,
    output logic [XT_ADDR_W-1:0]          p_rd_addr,
    input  logic signed [DATA_WIDTH-1:0]  p_rd_data [TILE_SIZE-1:0],
    input  logic                          out_compute_enable,
    input  logic [XT_ADDR_W:0]            out_preload_tiles_available,

    // dt-proj streaming interface
    input  logic                          s_axis_TVALID,
    output logic                          s_axis_TREADY,
    output logic                          m_axis_TVALID,
    input  logic                          m_axis_TREADY,
    output logic signed [DATA_WIDTH-1:0]  reduced_trunc [TILE_SIZE-1:0],
    output logic                          xt_axis_TVALID,
    input  logic                          xt_axis_TREADY,
    output logic signed [DATA_WIDTH-1:0]  xt_axis_TDATA [TILE_SIZE-1:0],

    // out-proj stream source / y output
    input  logic                          src_stream_valid,
    output logic                          src_stream_ready,
    input  logic signed [DATA_WIDTH-1:0]  src_stream_data [TILE_SIZE-1:0],
    output logic                          y_axis_TVALID,
    input  logic                          y_axis_TREADY,
    output logic signed [DATA_WIDTH-1:0]  y_axis_TDATA [TILE_SIZE-1:0],

    // common shared fabric contract
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
    generate
        if (ROLE == SLM_LINEAR_INPROJ) begin : g_inproj
            slm_in_proj_scheduler #(
                .TILE_SIZE(TILE_SIZE),
                .DATA_WIDTH(DATA_WIDTH),
                .ACC_WIDTH(ACC_WIDTH),
                .FRAC_BITS(FRAC_BITS),
                .N_BANK(N_BANK),
                .WDEPTH(WDEPTH),
                .WADDR_W(WADDR_W),
                .DATA_W(DATA_W),
                .USE_PER_CHANNEL_SCALE(USE_PER_CHANNEL_SCALE),
                .INPROJ_BANK0_INIT_FILE(BANK0_INIT_FILE),
                .INPROJ_BANK1_INIT_FILE(BANK1_INIT_FILE),
                .INPROJ_BANK2_INIT_FILE(BANK2_INIT_FILE),
                .INPROJ_BANK3_INIT_FILE(BANK3_INIT_FILE),
                .INPROJ_BANK4_INIT_FILE(BANK4_INIT_FILE),
                .INPROJ_BANK5_INIT_FILE(BANK5_INIT_FILE),
                .INPROJ_SCALE_INIT_FILE(SCALE_INIT_FILE)
            ) u_impl (
                .clk(clk), .rst_n(rst_n), .enable(enable), .start(start), .busy(busy), .done(done),
                .h_wr_en(h_wr_en), .h_wr_addr(h_wr_addr), .h_wr_data(h_wr_data),
                .u_rd_en(u_rd_en), .u_rd_addr(u_rd_addr), .u_rd_data(u_rd_data),
                .u_ssm_rd_en(u_ssm_rd_en), .u_ssm_rd_addr(u_ssm_rd_addr), .u_ssm_rd_data(u_ssm_rd_data),
                .z_rd_en(z_rd_en), .z_rd_addr(z_rd_addr), .z_rd_data(z_rd_data),
                .z_gate_rd_en(z_gate_rd_en), .z_gate_rd_addr(z_gate_rd_addr), .z_gate_rd_data(z_gate_rd_data),
                .fabric_mode(fabric_mode), .fabric_col_blocks(fabric_col_blocks), .fabric_valid_in(fabric_valid_in),
                .fabric_A0_mat(fabric_A0_mat), .fabric_A1_mat(fabric_A1_mat), .fabric_A2_mat(fabric_A2_mat), .fabric_A3_mat(fabric_A3_mat),
                .fabric_B0_mat(fabric_B0_mat), .fabric_B1_mat(fabric_B1_mat), .fabric_B2_mat(fabric_B2_mat), .fabric_B3_mat(fabric_B3_mat),
                .fabric_reduced_vec(fabric_reduced_vec), .fabric_reduced_mat_0(fabric_reduced_mat_0), .fabric_reduced_mat_1(fabric_reduced_mat_1),
                .fabric_reduced_mat_2(fabric_reduced_mat_2), .fabric_reduced_mat_3(fabric_reduced_mat_3), .fabric_valid_out(fabric_valid_out)
            );
            assign s_axis_TREADY = 1'b0;
            assign m_axis_TVALID = 1'b0;
            assign reduced_trunc = '{default:'0};
            assign xt_axis_TVALID = 1'b0;
            assign xt_axis_TDATA = '{default:'0};
            assign y_axis_TVALID = 1'b0;
            assign y_axis_TDATA = '{default:'0};
            assign dt_u_rd_en = 1'b0;
            assign dt_u_rd_addr = '0;
            assign p_rd_en = 1'b0;
            assign p_rd_addr = '0;
            assign src_stream_ready = 1'b0;
        end else if (ROLE == SLM_LINEAR_DTPROJ) begin : g_dtproj
            reuse_ssm_dt_scheduler #(
                .TILE_SIZE(TILE_SIZE),
                .DATA_WIDTH(DATA_WIDTH),
                .ACC_WIDTH(ACC_WIDTH),
                .FRAC_BITS(FRAC_BITS),
                .N_BANK(N_BANK),
                .WDEPTH(WDEPTH),
                .WADDR_W(WADDR_W),
                .DATA_W(DATA_W),
                .XT_ADDR_W(XT_ADDR_W),
                .DT_BANK0_INIT_FILE(BANK0_INIT_FILE),
                .DT_BANK1_INIT_FILE(BANK1_INIT_FILE),
                .DT_BANK2_INIT_FILE(BANK2_INIT_FILE),
                .DT_BANK3_INIT_FILE(BANK3_INIT_FILE),
                .DT_SCALE_INIT_FILE(SCALE_INIT_FILE)
            ) u_impl (
                .clk(clk), .rst_n(rst_n), .sched_busy(busy),
                .u_vec_rd_en(dt_u_rd_en), .u_vec_rd_addr(dt_u_rd_addr), .u_vec_rd_data(dt_u_rd_data),
                .s_axis_TVALID(s_axis_TVALID), .s_axis_TREADY(s_axis_TREADY),
                .m_axis_TVALID(m_axis_TVALID), .m_axis_TREADY(m_axis_TREADY), .reduced_trunc(reduced_trunc),
                .xt_axis_TVALID(xt_axis_TVALID), .xt_axis_TREADY(xt_axis_TREADY), .xt_axis_TDATA(xt_axis_TDATA),
                .fabric_mode(fabric_mode), .fabric_col_blocks(fabric_col_blocks), .fabric_valid_in(fabric_valid_in),
                .fabric_A0_mat(fabric_A0_mat), .fabric_A1_mat(fabric_A1_mat), .fabric_A2_mat(fabric_A2_mat), .fabric_A3_mat(fabric_A3_mat),
                .fabric_B0_mat(fabric_B0_mat), .fabric_B1_mat(fabric_B1_mat), .fabric_B2_mat(fabric_B2_mat), .fabric_B3_mat(fabric_B3_mat),
                .fabric_reduced_vec(fabric_reduced_vec), .fabric_reduced_mat_0(fabric_reduced_mat_0), .fabric_reduced_mat_1(fabric_reduced_mat_1),
                .fabric_reduced_mat_2(fabric_reduced_mat_2), .fabric_reduced_mat_3(fabric_reduced_mat_3), .fabric_valid_out(fabric_valid_out)
            );
            assign done = 1'b0;
            assign u_rd_data = '{default:'0};
            assign u_ssm_rd_data = '{default:'0};
            assign z_rd_data = '{default:'0};
            assign z_gate_rd_data = '{default:'0};
            assign y_axis_TVALID = 1'b0;
            assign y_axis_TDATA = '{default:'0};
            assign p_rd_en = 1'b0;
            assign p_rd_addr = '0;
            assign src_stream_ready = 1'b0;
        end else begin : g_outproj
            slm_out_proj_scheduler #(
                .TILE_SIZE(TILE_SIZE),
                .DATA_WIDTH(DATA_WIDTH),
                .ACC_WIDTH(ACC_WIDTH),
                .FRAC_BITS(FRAC_BITS),
                .N_BANK(N_BANK),
                .WDEPTH(WDEPTH),
                .WADDR_W(WADDR_W),
                .DATA_W(DATA_W),
                .USE_PER_CHANNEL_SCALE(USE_PER_CHANNEL_SCALE),
                .OUTPROJ_BANK0_INIT_FILE(BANK0_INIT_FILE),
                .OUTPROJ_BANK1_INIT_FILE(BANK1_INIT_FILE),
                .OUTPROJ_BANK2_INIT_FILE(BANK2_INIT_FILE),
                .OUTPROJ_BANK3_INIT_FILE(BANK3_INIT_FILE),
                .OUTPROJ_BANK4_INIT_FILE(BANK4_INIT_FILE),
                .OUTPROJ_BANK5_INIT_FILE(BANK5_INIT_FILE),
                .OUTPROJ_SCALE_INIT_FILE(SCALE_INIT_FILE)
            ) u_impl (
                .clk(clk), .rst_n(rst_n), .enable(enable), .start(start), .busy(busy), .done(done),
                .compute_enable(out_compute_enable),
                .preload_tiles_available(out_preload_tiles_available),
                .p_rd_en(p_rd_en), .p_rd_addr(p_rd_addr), .p_rd_data(p_rd_data),
                .y_axis_TVALID(y_axis_TVALID), .y_axis_TREADY(y_axis_TREADY), .y_axis_TDATA(y_axis_TDATA),
                .fabric_mode(fabric_mode), .fabric_col_blocks(fabric_col_blocks), .fabric_valid_in(fabric_valid_in),
                .fabric_A0_mat(fabric_A0_mat), .fabric_A1_mat(fabric_A1_mat), .fabric_A2_mat(fabric_A2_mat), .fabric_A3_mat(fabric_A3_mat),
                .fabric_B0_mat(fabric_B0_mat), .fabric_B1_mat(fabric_B1_mat), .fabric_B2_mat(fabric_B2_mat), .fabric_B3_mat(fabric_B3_mat),
                .fabric_reduced_vec(fabric_reduced_vec), .fabric_reduced_mat_0(fabric_reduced_mat_0), .fabric_reduced_mat_1(fabric_reduced_mat_1),
                .fabric_reduced_mat_2(fabric_reduced_mat_2), .fabric_reduced_mat_3(fabric_reduced_mat_3), .fabric_valid_out(fabric_valid_out)
            );
            assign u_rd_data = '{default:'0};
            assign u_ssm_rd_data = '{default:'0};
            assign z_rd_data = '{default:'0};
            assign z_gate_rd_data = '{default:'0};
            assign dt_u_rd_en = 1'b0;
            assign dt_u_rd_addr = '0;
            assign s_axis_TREADY = 1'b0;
            assign m_axis_TVALID = 1'b0;
            assign reduced_trunc = '{default:'0};
            assign xt_axis_TVALID = 1'b0;
            assign xt_axis_TDATA = '{default:'0};
            assign src_stream_ready = 1'b0;
        end
    endgenerate
endmodule

