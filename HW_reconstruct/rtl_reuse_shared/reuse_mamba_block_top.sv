`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: reuse_mamba_block_top
// Function:
//   New block-level top that explicitly organizes:
//     in_proj -> ssm -> out_proj
//   around one shared 4x4x4 MAC fabric.
//
// Current status:
//   - in_proj path is connected to the shared fabric
//   - ssm dt path is connected to the shared fabric
//   - out_proj is still a stub
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
    parameter int G_FRAC_BITS = 8
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

    typedef enum logic [3:0] {
        BLK_IDLE,
        BLK_START_INPROJ,
        BLK_WAIT_INPROJ,
        BLK_WAIT_UACT,
        BLK_ISSUE_DT,
        BLK_WAIT_DT_BUSY,
        BLK_WAIT_OUTPROJ,
        BLK_DONE
    } blk_st_t;

    blk_st_t blk_st;
    logic inproj_start_int;
    logic inproj_enable_int;
    logic s_axis_TVALID_int;
    logic y_fire;
    logic [7:0] dt_issue_count;
    logic       dt_seen_busy;

    logic dt_busy, out_busy;
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
    logic                         outproj_done_seen;

    assign block_busy = (blk_st != BLK_IDLE && blk_st != BLK_DONE);
    assign block_done = (blk_st == BLK_DONE);
    assign inproj_enable_int = block_auto_mode ? 1'b1 : inproj_enable;
    assign outproj_enable_int = block_auto_mode ? 1'b1 : outproj_enable;
    assign s_axis_TVALID_int = block_auto_mode ? (blk_st == BLK_ISSUE_DT) : s_axis_TVALID;
    assign y_fire = y_axis_TVALID && y_axis_TREADY;
    assign pcap_start = block_auto_mode ? inproj_done : 1'b0;
    assign outproj_start_int = block_auto_mode ? pcap_done : 1'b0;
    assign uact_fill_done = (uact_wr_count == 7'd64);

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            blk_st           <= BLK_IDLE;
            inproj_start_int <= 1'b0;
            dt_issue_count   <= '0;
            dt_seen_busy     <= 1'b0;
            outproj_done_seen<= 1'b0;
        end else begin
            inproj_start_int <= 1'b0;
            if (!block_auto_mode || blk_st == BLK_IDLE)
                outproj_done_seen <= 1'b0;
            else if (outproj_done_int)
                outproj_done_seen <= 1'b1;

            if (!block_auto_mode) begin
                blk_st         <= BLK_IDLE;
                dt_issue_count <= '0;
                dt_seen_busy   <= 1'b0;
            end else begin
                case (blk_st)
                    BLK_IDLE: begin
                        dt_issue_count <= '0;
                        dt_seen_busy   <= 1'b0;
                        outproj_done_seen <= 1'b0;
                        if (block_start) begin
                            inproj_start_int <= 1'b1;
                            blk_st <= BLK_START_INPROJ;
                        end
                    end

                    BLK_START_INPROJ: begin
                        blk_st <= BLK_WAIT_INPROJ;
                    end

                    BLK_WAIT_INPROJ: begin
                        if (inproj_done)
                            blk_st <= BLK_WAIT_UACT;
                    end

                    BLK_WAIT_UACT: begin
                        if (uact_fill_done)
                            blk_st <= BLK_ISSUE_DT;
                    end

                    BLK_ISSUE_DT: begin
                        if (s_axis_TREADY) begin
                            dt_issue_count <= dt_issue_count + 1'b1;
                            dt_seen_busy   <= 1'b0;
                            blk_st <= BLK_WAIT_DT_BUSY;
                        end
                    end

                    BLK_WAIT_DT_BUSY: begin
                        if (dt_busy) begin
                            dt_seen_busy <= 1'b1;
                        end else if (dt_seen_busy) begin
                            if (dt_issue_count < SSM_TILE_COUNT)
                                blk_st <= BLK_ISSUE_DT;
                            else if (outproj_done_int || outproj_done_seen)
                                blk_st <= BLK_DONE;
                            else
                                blk_st <= BLK_WAIT_OUTPROJ;
                        end
                    end

                    BLK_WAIT_OUTPROJ: begin
                        if (outproj_done_int || outproj_done_seen)
                            blk_st <= BLK_DONE;
                    end

                    BLK_DONE: begin
                        if (!block_start)
                            blk_st <= BLK_IDLE;
                    end

                    default: blk_st <= BLK_IDLE;
                endcase
            end
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            uact_wr_count <= '0;
        end else begin
            if (!block_auto_mode || blk_st == BLK_IDLE || blk_st == BLK_START_INPROJ || blk_st == BLK_WAIT_INPROJ) begin
                uact_wr_count <= '0;
            end else if (uact_wr_en && (uact_wr_count < 7'd64)) begin
                uact_wr_count <= uact_wr_count + 1'b1;
            end
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

    assign u_mux_rd_en   = block_auto_mode ? u_auto_rd_en   : u_rd_en;
    assign u_mux_rd_addr = block_auto_mode ? u_auto_rd_addr : u_rd_addr;
    assign u_rd_data     = u_mux_rd_data;
    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++)
            u_auto_rd_data[i] = u_mux_rd_data[i];
    end

    reuse_in_proj_scheduler #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH)
    ) u_in_proj (
        .clk(clk),
        .rst_n(rst_n),
        .enable(inproj_enable_int),
        .start(block_auto_mode ? inproj_start_int : inproj_start),
        .busy(inproj_busy),
        .done(inproj_done),
        .h_wr_en(h_wr_en),
        .h_wr_addr(h_wr_addr),
        .h_wr_data(h_wr_data),
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
        .enable  (block_auto_mode),
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

    reuse_out_proj_scheduler_stub #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH)
    ) u_out_proj (
        .clk(clk),
        .rst_n(rst_n),
        .enable(outproj_enable_int),
        .start(block_auto_mode ? outproj_start_int : outproj_enable),
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
        .enable  (block_auto_mode),
        .start   (inproj_done),
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
        if (block_auto_mode) begin
            g_axis_int_valid = silu_valid;
            silu_ready       = g_axis_int_ready;
            g_axis_TREADY    = 1'b0;
            for (int i = 0; i < TILE_SIZE; i++)
                g_axis_int_data[i] = silu_vec[i];
        end else begin
            g_axis_int_valid = g_axis_TVALID;
            silu_ready       = 1'b0;
            g_axis_TREADY    = g_axis_int_ready;
            for (int i = 0; i < TILE_SIZE; i++)
                g_axis_int_data[i] = g_axis_TDATA[i];
        end
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
        .G_FRAC_BITS(G_FRAC_BITS)
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
