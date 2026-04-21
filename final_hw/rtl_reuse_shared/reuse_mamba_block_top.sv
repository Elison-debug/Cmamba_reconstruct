`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: reuse_mamba_block_top
// Function:
//   New block-level top that explicitly organizes:
//     in_proj -> ssm -> out_proj
//   around one shared 4x4x4 MAC fabric.
//
// Current status:
//   - in_proj / ssm dt / out_proj all run on the shared fabric
//   - weight banks use the aligned 4-array export layout
//   - scheduler writeback uses the shared requant/scale engine
//   - SSM internal post-processing logic is preserved in reuse_ssm_core
//---------------------------------------------------------------
module reuse_mamba_block_top #(
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
    parameter bit INPROJ_USE_PER_CHANNEL_SCALE = 0,
    parameter bit DT_USE_PER_CHANNEL_SCALE = 0,
    parameter bit OUTPROJ_USE_PER_CHANNEL_SCALE = 0,
    parameter bit ENABLE_RMSNORM = 0,
    parameter string NORM_GAMMA_INIT_FILE = "",
    parameter string BIAS_INIT_FILE = "",
    parameter bit USE_SCALED_STATE_SCAN = 0,
    parameter string STATE_U_TO_STATE_SCALE_INIT_FILE = "",
    parameter string STATE_TO_Q88_SCALE_INIT_FILE = ""
)(
    input  logic clk,
    input  logic rst_n,

    // Optional block-level automatic sequencing
    input  logic block_auto_mode,
    input  logic block_start,
    output logic block_busy,
    output logic block_done,

    // SSM start / gate / output
    input  logic s_axis_TVALID,
    output logic s_axis_TREADY,
    input  logic                         g_axis_TVALID,
    output logic                         g_axis_TREADY,
    input  logic signed [DATA_WIDTH-1:0] g_axis_TDATA [TILE_SIZE-1:0],
    output logic                         y_axis_TVALID,
    input  logic                         y_axis_TREADY,
    output logic signed [DATA_WIDTH-1:0] y_axis_TDATA [TILE_SIZE-1:0],

    // in_proj controls
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
    output logic signed [DATA_WIDTH-1:0] z_rd_data [TILE_SIZE-1:0],

    // out_proj placeholder controls
    input  logic                         outproj_enable,
    output logic                         outproj_busy
);
    localparam int SSM_TILE_COUNT = 64;

    logic inproj_start_int;
    logic inproj_enable_int;
    logic s_axis_TVALID_int;
    logic [7:0] dt_issue_count;
    logic       block_active;
    logic       block_done_reg;
    logic       dt_run_active;
    logic       dt_started;
    logic       z_stream_start_int;
    logic       pcap_start_int;
    logic       outproj_started;
    logic       pcap_done_d;
    logic       uact_fill_active;

    logic dt_busy;
    logic [1:0] dt_mode, in_mode, out_mode;
    logic [6:0] dt_col_blocks, in_col_blocks, out_col_blocks;
    logic dt_reduce_rows, in_reduce_rows, out_reduce_rows;
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

    logic                         dt_mac_valid;
    logic signed [DATA_WIDTH-1:0] dt_mac_vec [TILE_SIZE-1:0];
    logic                         dt_mac_ready;
    logic                         xt_v;
    logic                         xt_r_int;
    logic signed [DATA_WIDTH-1:0] xt_d [TILE_SIZE-1:0];
    logic                         dt_u_rd_en;
    logic [5:0]                   dt_u_rd_addr;
    logic signed [DATA_WIDTH-1:0] dt_u_rd_data [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] dt_u_raw_rd_data [TILE_SIZE-1:0];
    logic                         u_auto_rd_en;
    logic [5:0]                   u_auto_rd_addr;
    logic signed [DATA_WIDTH-1:0] u_auto_rd_data [TILE_SIZE-1:0];
    logic                         u_mux_rd_en;
    logic [5:0]                   u_mux_rd_addr;
    logic signed [DATA_WIDTH-1:0] u_mux_rd_data [TILE_SIZE-1:0];
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
    logic                         z_gate_rd_en;
    logic [5:0]                   z_gate_rd_addr;
    logic signed [DATA_WIDTH-1:0] z_gate_rd_data [TILE_SIZE-1:0];
    logic                         z_stream_busy, z_stream_done;
    logic                         z_stream_valid, z_stream_ready;
    logic signed [DATA_WIDTH-1:0] z_stream_vec [TILE_SIZE-1:0];
    logic                         silu_valid, silu_ready;
    logic signed [DATA_WIDTH-1:0] silu_vec [TILE_SIZE-1:0];
    logic                         g_axis_int_valid, g_axis_int_ready;
    logic signed [DATA_WIDTH-1:0] g_axis_int_data [TILE_SIZE-1:0];
    logic                         ssm_p_valid;
    logic                         ssm_p_ready;
    logic signed [DATA_WIDTH-1:0] ssm_p_data [TILE_SIZE-1:0];
    logic                         pcap_busy, pcap_done;
    logic                         pcap_start;
    logic                         p_wr_en;
    logic [5:0]                   p_wr_addr;
    logic signed [DATA_WIDTH-1:0] p_wr_data [TILE_SIZE-1:0];
    logic                         p_rd_en_out;
    logic [5:0]                   p_rd_addr_out;
    logic [5:0]                   p_rd_addr0_out, p_rd_addr1_out, p_rd_addr2_out, p_rd_addr3_out;
    logic signed [DATA_WIDTH-1:0] p_rd_data_out [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] p_rd_data0_out [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] p_rd_data1_out [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] p_rd_data2_out [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] p_rd_data3_out [TILE_SIZE-1:0];
    logic                         outproj_enable_int;
    logic                         outproj_start_int;
    logic                         outproj_done_int;
    logic                         norm_start_int;
    logic                         norm_busy;
    logic                         norm_done;
    logic                         norm_pending;
    logic                         norm_wr_en;
    logic [4:0]                   norm_wr_addr;
    logic signed [DATA_WIDTH-1:0] norm_wr_data [TILE_SIZE-1:0];
    logic                         h_inproj_wr_en;
    logic [4:0]                   h_inproj_wr_addr;
    logic signed [DATA_WIDTH-1:0] h_inproj_wr_data [TILE_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] gamma_wr_zero [TILE_SIZE-1:0];

    assign block_busy = block_active;
    assign block_done = block_done_reg;
    assign inproj_enable_int = 1'b1;
    assign outproj_enable_int = 1'b1;
    assign s_axis_TVALID_int = dt_run_active && (dt_issue_count < SSM_TILE_COUNT);
    assign pcap_start = pcap_start_int;
    assign uact_fill_done = (uact_wr_count == 7'd64);
    assign h_inproj_wr_en = ENABLE_RMSNORM ? norm_wr_en : h_wr_en;
    assign h_inproj_wr_addr = ENABLE_RMSNORM ? norm_wr_addr : h_wr_addr;
    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++) begin
            h_inproj_wr_data[i] = ENABLE_RMSNORM ? norm_wr_data[i] : h_wr_data[i];
            gamma_wr_zero[i] = '0;
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            inproj_start_int   <= 1'b0;
            norm_start_int     <= 1'b0;
            norm_pending       <= 1'b0;
            dt_issue_count     <= '0;
            block_active       <= 1'b0;
            block_done_reg     <= 1'b0;
            dt_run_active      <= 1'b0;
            dt_started         <= 1'b0;
            z_stream_start_int <= 1'b0;
            pcap_start_int     <= 1'b0;
            outproj_started    <= 1'b0;
            outproj_start_int  <= 1'b0;
            pcap_done_d        <= 1'b0;
            uact_fill_active   <= 1'b0;
        end else begin
            inproj_start_int   <= 1'b0;
            norm_start_int     <= 1'b0;
            z_stream_start_int <= 1'b0;
            pcap_start_int     <= 1'b0;
            outproj_start_int  <= 1'b0;
            pcap_done_d        <= pcap_done;

            if (block_start && !block_active) begin
                dt_issue_count   <= '0;
                block_active     <= 1'b1;
                block_done_reg   <= 1'b0;
                dt_run_active    <= 1'b0;
                dt_started       <= 1'b0;
                outproj_started  <= 1'b0;
                uact_fill_active <= 1'b0;
                if (ENABLE_RMSNORM) begin
                    norm_start_int <= 1'b1;
                    norm_pending   <= 1'b1;
                end else begin
                    inproj_start_int <= 1'b1;
                    norm_pending     <= 1'b0;
                end
            end
            if (ENABLE_RMSNORM && norm_done && norm_pending) begin
                inproj_start_int <= 1'b1;
                norm_pending <= 1'b0;
            end

            if (inproj_done)
                uact_fill_active <= 1'b1;
            else if (uact_fill_done)
                uact_fill_active <= 1'b0;

            if (s_axis_TVALID_int && s_axis_TREADY)
                dt_issue_count <= dt_issue_count + 1'b1;

            if (block_active && uact_fill_done && !dt_started) begin
                dt_started         <= 1'b1;
                dt_run_active      <= 1'b1;
                z_stream_start_int <= 1'b1;
                pcap_start_int     <= 1'b1;
            end

            if (dt_run_active && (dt_issue_count == SSM_TILE_COUNT) && !dt_busy)
                dt_run_active <= 1'b0;

            if (block_active && pcap_done && !pcap_done_d && !outproj_started) begin
                outproj_start_int <= 1'b1;
                outproj_started   <= 1'b1;
            end

            if (block_active && outproj_done_int) begin
                block_active   <= 1'b0;
                block_done_reg <= 1'b1;
            end
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

    if (ENABLE_RMSNORM) begin : g_rmsnorm
        reuse_rmsnorm_scheduler #(
            .TILE_SIZE(TILE_SIZE),
            .DATA_WIDTH(DATA_WIDTH),
            .H_DEPTH(32),
            .H_ADDR_W(5),
            .RMS_APPROX_RECIP(1'b1),
            .NORM_GAMMA_INIT_FILE(NORM_GAMMA_INIT_FILE)
        ) u_rmsnorm (
            .clk(clk),
            .rst_n(rst_n),
            .enable(1'b1),
            .start(norm_start_int),
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
    end else begin : g_no_rmsnorm
        assign norm_busy = 1'b0;
        assign norm_done = 1'b0;
        assign norm_wr_en = 1'b0;
        assign norm_wr_addr = '0;
        for (genvar i = 0; i < TILE_SIZE; i++) begin : g_norm_zero
            assign norm_wr_data[i] = '0;
        end
    end

    reuse_ssm_dt_scheduler #(
        .TILE_SIZE          (TILE_SIZE),
        .DATA_WIDTH         (DATA_WIDTH),
        .ACC_WIDTH          (ACC_WIDTH),
        .FRAC_BITS          (FRAC_BITS),
        .USE_PER_CHANNEL_SCALE(DT_USE_PER_CHANNEL_SCALE),
        .N_BANK             (N_BANK),
        .WDEPTH             (WDEPTH),
        .WADDR_W            (WADDR_W),
        .DATA_W             (DATA_W),
        .XT_ADDR_W          (XT_ADDR_W),
        .DT_BANK0_INIT_FILE (DT_BANK0_INIT_FILE),
        .DT_BANK1_INIT_FILE (DT_BANK1_INIT_FILE),
        .DT_BANK2_INIT_FILE (DT_BANK2_INIT_FILE),
        .DT_BANK3_INIT_FILE (DT_BANK3_INIT_FILE),
        .DT_SCALE_INIT_FILE (DT_SCALE_INIT_FILE)
    ) u_dt_sched (
        .clk(clk),
        .rst_n(rst_n),
        .sched_busy(dt_busy),
        .u_vec_rd_en(dt_u_rd_en),
        .u_vec_rd_addr(dt_u_rd_addr),
        .u_vec_rd_data(dt_u_rd_data),
        .s_axis_TVALID(s_axis_TVALID_int),
        .s_axis_TREADY(s_axis_TREADY),
        .m_axis_TVALID(dt_mac_valid),
        .m_axis_TREADY(dt_mac_ready),
        .reduced_trunc(dt_mac_vec),
        .xt_axis_TVALID(xt_v),
        .xt_axis_TREADY(xt_r_int),
        .xt_axis_TDATA(xt_d),
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

    assign u_mux_rd_en   = u_auto_rd_en;
    assign u_mux_rd_addr = u_auto_rd_addr;
    assign u_rd_data     = u_mux_rd_data;
    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++)
            u_auto_rd_data[i] = u_mux_rd_data[i];
    end

    reuse_in_proj_scheduler #(
        .TILE_SIZE              (TILE_SIZE),
        .DATA_WIDTH             (DATA_WIDTH),
        .ACC_WIDTH              (ACC_WIDTH),
        .USE_PER_CHANNEL_SCALE  (INPROJ_USE_PER_CHANNEL_SCALE),
        .INPROJ_BANK0_INIT_FILE (INPROJ_BANK0_INIT_FILE),
        .INPROJ_BANK1_INIT_FILE (INPROJ_BANK1_INIT_FILE),
        .INPROJ_BANK2_INIT_FILE (INPROJ_BANK2_INIT_FILE),
        .INPROJ_BANK3_INIT_FILE (INPROJ_BANK3_INIT_FILE),
        .INPROJ_BANK4_INIT_FILE (INPROJ_BANK4_INIT_FILE),
        .INPROJ_BANK5_INIT_FILE (INPROJ_BANK5_INIT_FILE),
        .INPROJ_SCALE_INIT_FILE (INPROJ_SCALE_INIT_FILE)
    ) u_in_proj (
        .clk(clk),
        .rst_n(rst_n),
        .enable(inproj_enable_int),
        .start(inproj_start_int),
        .busy(inproj_busy),
        .done(inproj_done),
        .h_wr_en(h_inproj_wr_en),
        .h_wr_addr(h_inproj_wr_addr),
        .h_wr_data(h_inproj_wr_data),
        .u_rd_en(u_mux_rd_en),
        .u_rd_addr(u_mux_rd_addr),
        .u_rd_data(u_mux_rd_data),
        .u_ssm_rd_en(dt_u_rd_en),
        .u_ssm_rd_addr(dt_u_rd_addr),
        .u_ssm_rd_data(dt_u_raw_rd_data),
        .z_rd_en(z_rd_en),
        .z_rd_addr(z_rd_addr),
        .z_rd_data(z_rd_data),
        .z_gate_rd_en(z_gate_rd_en),
        .z_gate_rd_addr(z_gate_rd_addr),
        .z_gate_rd_data(z_gate_rd_data),
        .fabric_mode(in_mode),
        .fabric_col_blocks(in_col_blocks),
        .fabric_valid_in(in_valid_in),
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

    reuse_z_stream_reader #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .Z_DEPTH   (64),
        .Z_ADDR_W  (6)
    ) u_u_reader (
        .clk     (clk),
        .rst_n   (rst_n),
        .enable  (1'b1),
        .start   (inproj_done),
        .busy    (u_stream_busy),
        .done    (u_stream_done),
        .z_rd_en (u_auto_rd_en),
        .z_rd_addr(u_auto_rd_addr),
        .z_rd_data(u_auto_rd_data),
        .out_valid(u_stream_valid),
        .out_ready(u_stream_ready),
        .out_vec (u_stream_vec)
    );

    reuse_silu_vec4 #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .FRAC_BITS (FRAC_BITS),
        .ADDR_BITS (ADDR_BITS),
        .LUT_FILE  (LUT_FILE)
    ) u_u_silu (
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (u_stream_valid),
        .in_ready (u_stream_ready),
        .in_vec   (u_stream_vec),
        .out_valid(uact_valid),
        .out_ready(uact_ready),
        .out_vec  (uact_vec)
    );

    assign uact_ready  = 1'b1;
    assign uact_wr_en  = uact_valid && uact_ready;
    assign uact_wr_addr = uact_wr_count[5:0];
    assign uact_rd_en   = dt_u_rd_en;
    assign uact_rd_addr = dt_u_rd_addr;
    assign dt_u_rd_data = uact_rd_data;
    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++)
            uact_wr_data[i] = uact_vec[i];
    end

    reuse_ht_sram_sp #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH     (64),
        .ADDR_W    (6)
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

    reuse_out_proj_scheduler #(
        .TILE_SIZE               (TILE_SIZE),
        .DATA_WIDTH              (DATA_WIDTH),
        .ACC_WIDTH               (ACC_WIDTH),
        .USE_PER_CHANNEL_SCALE   (OUTPROJ_USE_PER_CHANNEL_SCALE),
        .OUTPROJ_BANK0_INIT_FILE (OUTPROJ_BANK0_INIT_FILE),
        .OUTPROJ_BANK1_INIT_FILE (OUTPROJ_BANK1_INIT_FILE),
        .OUTPROJ_BANK2_INIT_FILE (OUTPROJ_BANK2_INIT_FILE),
        .OUTPROJ_BANK3_INIT_FILE (OUTPROJ_BANK3_INIT_FILE),
        .OUTPROJ_BANK4_INIT_FILE (OUTPROJ_BANK4_INIT_FILE),
        .OUTPROJ_BANK5_INIT_FILE (OUTPROJ_BANK5_INIT_FILE),
        .OUTPROJ_SCALE_INIT_FILE (OUTPROJ_SCALE_INIT_FILE)
    ) u_out_proj (
        .clk(clk),
        .rst_n(rst_n),
        .enable(outproj_enable_int),
        .start(outproj_start_int),
        .busy(outproj_busy),
        .done(outproj_done_int),
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

    reuse_pt_capture #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH     (64),
        .ADDR_W    (6)
    ) u_pcap (
        .clk(clk),
        .rst_n(rst_n),
        .enable(outproj_enable_int),
        .start(pcap_start),
        .busy(pcap_busy),
        .done(pcap_done),
        .s_axis_TVALID(ssm_p_valid),
        .s_axis_TREADY(ssm_p_ready),
        .s_axis_TDATA(ssm_p_data),
        .p_wr_en(p_wr_en),
        .p_wr_addr(p_wr_addr),
        .p_wr_data(p_wr_data)
    );

    assign p_rd_addr_out = p_rd_addr0_out;
    assign p_rd_data_out = p_rd_data0_out;

    reuse_ht_sram #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH     (64),
        .ADDR_W    (6)
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

    reuse_z_stream_reader #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .Z_DEPTH   (64),
        .Z_ADDR_W  (6)
    ) u_z_reader (
        .clk     (clk),
        .rst_n   (rst_n),
        .enable  (1'b1),
        .start   (z_stream_start_int),
        .busy    (z_stream_busy),
        .done    (z_stream_done),
        .z_rd_en (z_gate_rd_en),
        .z_rd_addr(z_gate_rd_addr),
        .z_rd_data(z_gate_rd_data),
        .out_valid(z_stream_valid),
        .out_ready(z_stream_ready),
        .out_vec (z_stream_vec)
    );

    reuse_silu_vec4 #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .FRAC_BITS (FRAC_BITS),
        .ADDR_BITS (ADDR_BITS),
        .LUT_FILE  (LUT_FILE)
    ) u_silu (
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (z_stream_valid),
        .in_ready (z_stream_ready),
        .in_vec   (z_stream_vec),
        .out_valid(silu_valid),
        .out_ready(silu_ready),
        .out_vec  (silu_vec)
    );

    always_comb begin
            g_axis_int_valid = silu_valid;
            silu_ready       = g_axis_int_ready;
            g_axis_TREADY    = 1'b0;
            for (int i = 0; i < TILE_SIZE; i++)
                g_axis_int_data[i] = silu_vec[i];
    end

    reuse_mac_fabric_manager #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH),
        .FRAC_BITS (FRAC_BITS)
    ) u_mgr (
        .clk(clk),
        .rst_n(rst_n),
        .dt_busy(dt_busy),
        .dt_mode(dt_mode),
        .dt_col_blocks(dt_col_blocks),
        .dt_reduce_rows(dt_reduce_rows),
        .dt_valid_in(dt_valid_in),
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
        .in_busy(inproj_busy),
        .in_mode(in_mode),
        .in_col_blocks(in_col_blocks),
        .in_reduce_rows(in_reduce_rows),
        .in_valid_in(in_valid_in),
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
        .out_busy(outproj_busy),
        .out_mode(out_mode),
        .out_col_blocks(out_col_blocks),
        .out_reduce_rows(out_reduce_rows),
        .out_valid_in(out_valid_in),
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

    reuse_ssm_core #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .D         (D),
        .PIPE_LAT  (PIPE_LAT),
        .ADDR_BITS (ADDR_BITS),
        .LUT_FILE  (LUT_FILE),
        .S_ADDR_W  (S_ADDR_W),
        .G_FRAC_BITS(G_FRAC_BITS),
        .BIAS_INIT_FILE(BIAS_INIT_FILE),
        .USE_SCALED_STATE_SCAN(USE_SCALED_STATE_SCAN),
        .STATE_U_TO_STATE_SCALE_INIT_FILE(STATE_U_TO_STATE_SCALE_INIT_FILE),
        .STATE_TO_Q88_SCALE_INIT_FILE(STATE_TO_Q88_SCALE_INIT_FILE)
    ) u_ssm_core (
        .clk(clk),
        .rst_n(rst_n),
        .mac_m_valid(dt_mac_valid),
        .mac_vec(dt_mac_vec),
        .mac_m_ready(dt_mac_ready),
        .xt_v(xt_v),
        .xt_r_int(xt_r_int),
        .xt_d(xt_d),
        .g_axis_TVALID(g_axis_int_valid),
        .g_axis_TREADY(g_axis_int_ready),
        .g_axis_TDATA(g_axis_int_data),
        .y_axis_TVALID(ssm_p_valid),
        .y_axis_TREADY(ssm_p_ready),
        .y_axis_TDATA(ssm_p_data)
    );

    assign dt_reduce_rows  = 1'b1;
    assign in_reduce_rows  = 1'b1;
    assign out_reduce_rows = 1'b1;
endmodule
