//---------------------------------------------------------------
// Module: reuse_slim_mac_mem_controller_combined_dp
// Function:
//   Compatibility wrapper that preserves the original SSM-facing
//   controller interface while internally routing the dt-projection
//   path through the new shared-fabric hierarchy.
//---------------------------------------------------------------
module reuse_slim_mac_mem_controller_combined_dp #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH  = 32,
    parameter int FRAC_BITS  = 8,
    parameter int N_BANK     = 6,
    parameter int WDEPTH     = 683,
    parameter int WADDR_W    = $clog2(WDEPTH),
    parameter int DATA_W     = 256,
    parameter int XT_ADDR_W  = 6
)(
    input  logic clk,
    input  logic rst_n,
    input  logic s_axis_TVALID,
    output logic s_axis_TREADY,
    output logic m_axis_TVALID,
    input  logic m_axis_TREADY,
    output logic signed [DATA_WIDTH-1:0] reduced_trunc [TILE_SIZE-1:0],
    output logic                         xt_axis_TVALID,
    input  logic                         xt_axis_TREADY,
    output logic signed [DATA_WIDTH-1:0] xt_axis_TDATA [TILE_SIZE-1:0],

    input  logic                         inproj_enable,
    input  logic                         inproj_start,
    output logic                         inproj_busy,
    output logic                         inproj_done,
    input  logic                         h_wr_en,
    input  logic [4:0]                   h_wr_addr,
    input  logic signed [DATA_WIDTH-1:0] h_wr_data [TILE_SIZE-1:0],
    input  logic                         u_rd_en,
    input  logic [5:0]                   u_rd_addr,
    output logic signed [DATA_WIDTH-1:0] u_rd_data [TILE_SIZE-1:0],
    input  logic                         z_rd_en,
    input  logic [5:0]                   z_rd_addr,
    output logic signed [DATA_WIDTH-1:0] z_rd_data [TILE_SIZE-1:0]
);
    logic inproj_enable_i, inproj_start_i, h_wr_en_i, u_rd_en_i, z_rd_en_i;
    logic dt_busy, out_busy;
    logic dt_u_rd_en;
    logic [5:0] dt_u_rd_addr;
    logic signed [DATA_WIDTH-1:0] dt_u_rd_data [TILE_SIZE-1:0];
    logic [1:0] dt_mode, in_mode, out_mode;
    logic [6:0] dt_col_blocks, in_col_blocks, out_col_blocks;
    logic dt_valid_in, in_valid_in, out_valid_in;
    logic signed [DATA_WIDTH-1:0] dt_A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] dt_A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] dt_A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] dt_A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] dt_B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] dt_B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] dt_B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] dt_B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]  dt_reduced_vec [TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]  dt_reduced_mat_0 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]  dt_reduced_mat_1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]  dt_reduced_mat_2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]  dt_reduced_mat_3 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic                         dt_valid_out;

    logic signed [DATA_WIDTH-1:0] in_A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] in_A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] in_A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] in_A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] in_B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] in_B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] in_B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] in_B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]  in_reduced_vec [TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]  in_reduced_mat_0 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]  in_reduced_mat_1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]  in_reduced_mat_2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]  in_reduced_mat_3 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic                         in_valid_out;

    logic signed [DATA_WIDTH-1:0] out_A0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] out_A1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] out_A2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] out_A3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] out_B0_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] out_B1_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] out_B2_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] out_B3_mat [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]  out_reduced_vec [TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]  out_reduced_mat_0 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]  out_reduced_mat_1 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]  out_reduced_mat_2 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic signed [ACC_WIDTH-1:0]  out_reduced_mat_3 [TILE_SIZE-1:0][TILE_SIZE-1:0];
    logic                         out_valid_out;
    logic                         out_p_rd_en;
    logic [5:0]                   out_p_rd_addr;
    logic signed [DATA_WIDTH-1:0] out_p_rd_data [TILE_SIZE-1:0];
    logic                         out_y_valid;
    logic signed [DATA_WIDTH-1:0] out_y_data [TILE_SIZE-1:0];

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++) begin
            out_p_rd_data[i] = '0;
            out_y_data[i] = '0;
        end
    end

    reuse_ssm_dt_scheduler #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH),
        .FRAC_BITS (FRAC_BITS),
        .N_BANK    (N_BANK),
        .WDEPTH    (WDEPTH),
        .WADDR_W   (WADDR_W),
        .DATA_W    (DATA_W),
        .XT_ADDR_W (XT_ADDR_W)
    ) u_dt_sched (
        .clk(clk),
        .rst_n(rst_n),
        .sched_busy(dt_busy),
        .u_vec_rd_en(dt_u_rd_en),
        .u_vec_rd_addr(dt_u_rd_addr),
        .u_vec_rd_data(dt_u_rd_data),
        .s_axis_TVALID(s_axis_TVALID),
        .s_axis_TREADY(s_axis_TREADY),
        .m_axis_TVALID(m_axis_TVALID),
        .m_axis_TREADY(m_axis_TREADY),
        .reduced_trunc(reduced_trunc),
        .xt_axis_TVALID(xt_axis_TVALID),
        .xt_axis_TREADY(xt_axis_TREADY),
        .xt_axis_TDATA(xt_axis_TDATA),
        .fabric_mode(dt_mode),
        .fabric_col_blocks(dt_col_blocks),
        .fabric_valid_in(dt_valid_in),
        .fabric_A0_mat(dt_A0_mat), .fabric_A1_mat(dt_A1_mat),
        .fabric_A2_mat(dt_A2_mat), .fabric_A3_mat(dt_A3_mat),
        .fabric_B0_mat(dt_B0_mat), .fabric_B1_mat(dt_B1_mat),
        .fabric_B2_mat(dt_B2_mat), .fabric_B3_mat(dt_B3_mat),
        .fabric_reduced_vec(dt_reduced_vec),
        .fabric_reduced_mat_0(dt_reduced_mat_0),
        .fabric_reduced_mat_1(dt_reduced_mat_1),
        .fabric_reduced_mat_2(dt_reduced_mat_2),
        .fabric_reduced_mat_3(dt_reduced_mat_3),
        .fabric_valid_out(dt_valid_out)
    );

    assign inproj_enable_i = (inproj_enable === 1'b1);
    assign inproj_start_i  = (inproj_start  === 1'b1);
    assign h_wr_en_i       = (h_wr_en       === 1'b1);
    assign u_rd_en_i       = (u_rd_en       === 1'b1);
    assign z_rd_en_i       = (z_rd_en       === 1'b1);

    reuse_in_proj_scheduler #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH)
    ) u_in_proj (
        .clk(clk),
        .rst_n(rst_n),
        .enable(inproj_enable_i),
        .start(inproj_start_i),
        .busy(inproj_busy),
        .done(inproj_done),
        .h_wr_en(h_wr_en_i),
        .h_wr_addr(h_wr_addr),
        .h_wr_data(h_wr_data),
        .u_rd_en(u_rd_en_i),
        .u_rd_addr(u_rd_addr),
        .u_rd_data(u_rd_data),
        .u_ssm_rd_en(dt_u_rd_en),
        .u_ssm_rd_addr(dt_u_rd_addr),
        .u_ssm_rd_data(dt_u_rd_data),
        .z_rd_en(z_rd_en_i),
        .z_rd_addr(z_rd_addr),
        .z_rd_data(z_rd_data),
        .z_gate_rd_en(1'b0),
        .z_gate_rd_addr('0),
        .z_gate_rd_data(),
        .fabric_mode(in_mode), .fabric_col_blocks(in_col_blocks), .fabric_valid_in(in_valid_in),
        .fabric_A0_mat(in_A0_mat), .fabric_A1_mat(in_A1_mat),
        .fabric_A2_mat(in_A2_mat), .fabric_A3_mat(in_A3_mat),
        .fabric_B0_mat(in_B0_mat), .fabric_B1_mat(in_B1_mat),
        .fabric_B2_mat(in_B2_mat), .fabric_B3_mat(in_B3_mat),
        .fabric_reduced_vec(in_reduced_vec),
        .fabric_reduced_mat_0(in_reduced_mat_0),
        .fabric_reduced_mat_1(in_reduced_mat_1),
        .fabric_reduced_mat_2(in_reduced_mat_2),
        .fabric_reduced_mat_3(in_reduced_mat_3),
        .fabric_valid_out(in_valid_out)
    );

    reuse_out_proj_scheduler_stub #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH)
    ) u_out_stub (
        .clk(clk), .rst_n(rst_n), .enable(1'b0), .start(1'b0), .busy(out_busy), .done(),
        .p_rd_en(out_p_rd_en), .p_rd_addr(out_p_rd_addr), .p_rd_data(out_p_rd_data),
        .y_axis_TVALID(out_y_valid), .y_axis_TREADY(1'b0), .y_axis_TDATA(out_y_data),
        .fabric_mode(out_mode), .fabric_col_blocks(out_col_blocks), .fabric_valid_in(out_valid_in),
        .fabric_A0_mat(out_A0_mat), .fabric_A1_mat(out_A1_mat),
        .fabric_A2_mat(out_A2_mat), .fabric_A3_mat(out_A3_mat),
        .fabric_B0_mat(out_B0_mat), .fabric_B1_mat(out_B1_mat),
        .fabric_B2_mat(out_B2_mat), .fabric_B3_mat(out_B3_mat),
        .fabric_reduced_vec(out_reduced_vec),
        .fabric_reduced_mat_0(out_reduced_mat_0),
        .fabric_reduced_mat_1(out_reduced_mat_1),
        .fabric_reduced_mat_2(out_reduced_mat_2),
        .fabric_reduced_mat_3(out_reduced_mat_3),
        .fabric_valid_out(out_valid_out)
    );

    reuse_mac_fabric_manager #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH),
        .FRAC_BITS (FRAC_BITS)
    ) u_mgr (
        .clk(clk), .rst_n(rst_n),
        .dt_busy(dt_busy), .dt_mode(dt_mode), .dt_col_blocks(dt_col_blocks), .dt_valid_in(dt_valid_in),
        .dt_A0_mat(dt_A0_mat), .dt_A1_mat(dt_A1_mat),
        .dt_A2_mat(dt_A2_mat), .dt_A3_mat(dt_A3_mat),
        .dt_B0_mat(dt_B0_mat), .dt_B1_mat(dt_B1_mat),
        .dt_B2_mat(dt_B2_mat), .dt_B3_mat(dt_B3_mat),
        .dt_reduced_vec(dt_reduced_vec),
        .dt_reduced_mat_0(dt_reduced_mat_0),
        .dt_reduced_mat_1(dt_reduced_mat_1),
        .dt_reduced_mat_2(dt_reduced_mat_2),
        .dt_reduced_mat_3(dt_reduced_mat_3),
        .dt_valid_out(dt_valid_out),
        .in_busy(inproj_busy), .in_mode(in_mode), .in_col_blocks(in_col_blocks), .in_valid_in(in_valid_in),
        .in_A0_mat(in_A0_mat), .in_A1_mat(in_A1_mat),
        .in_A2_mat(in_A2_mat), .in_A3_mat(in_A3_mat),
        .in_B0_mat(in_B0_mat), .in_B1_mat(in_B1_mat),
        .in_B2_mat(in_B2_mat), .in_B3_mat(in_B3_mat),
        .in_reduced_vec(in_reduced_vec),
        .in_reduced_mat_0(in_reduced_mat_0),
        .in_reduced_mat_1(in_reduced_mat_1),
        .in_reduced_mat_2(in_reduced_mat_2),
        .in_reduced_mat_3(in_reduced_mat_3),
        .in_valid_out(in_valid_out),
        .out_busy(out_busy), .out_mode(out_mode), .out_col_blocks(out_col_blocks), .out_valid_in(out_valid_in),
        .out_A0_mat(out_A0_mat), .out_A1_mat(out_A1_mat),
        .out_A2_mat(out_A2_mat), .out_A3_mat(out_A3_mat),
        .out_B0_mat(out_B0_mat), .out_B1_mat(out_B1_mat),
        .out_B2_mat(out_B2_mat), .out_B3_mat(out_B3_mat),
        .out_reduced_vec(out_reduced_vec),
        .out_reduced_mat_0(out_reduced_mat_0),
        .out_reduced_mat_1(out_reduced_mat_1),
        .out_reduced_mat_2(out_reduced_mat_2),
        .out_reduced_mat_3(out_reduced_mat_3),
        .out_valid_out(out_valid_out)
    );
endmodule
