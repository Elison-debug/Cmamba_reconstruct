`timescale 1ns/1ps
//---------------------------------------------------------------
// Stream-first shell (no legacy g/debug path).
// Flow: load one H frame -> run core -> stream Y -> repeat.
//---------------------------------------------------------------
module reuse_mamba_board_shell_stream #(
    parameter integer TILE_SIZE   = 4,
    parameter integer DATA_WIDTH  = 16,
    parameter integer ACC_WIDTH   = 32,
    parameter integer FRAC_BITS   = 8,
    parameter integer N_BANK      = 6,
    parameter integer WDEPTH      = 1024,
    parameter integer WADDR_W     = $clog2(WDEPTH),
    parameter integer DATA_W      = 256,
    parameter integer XT_ADDR_W   = 6,
    parameter integer D           = 256,
    parameter integer PIPE_LAT    = 4,
    parameter integer ADDR_BITS   = 11,
    parameter LUT_FILE            = "sigmoid_lut_q016_2048.hex",
    parameter integer S_ADDR_W    = 6,
    parameter integer G_FRAC_BITS = 8,
    parameter integer H_ROWS      = 32,
    parameter integer CHAIN4_ENABLE = 1,
    parameter STAGE_DIR = "HW_reconstruct/hw_debug/cases/test_case3_smoke/stages/reuse_mamba_block_top",
    parameter STAGE_DIR_B0 = "HW_reconstruct/hw_debug/cases/test_case3_smoke/stages/reuse_mamba_block_top_block0",
    parameter STAGE_DIR_B1 = "HW_reconstruct/hw_debug/cases/test_case3_smoke/stages/reuse_mamba_block_top_block1",
    parameter STAGE_DIR_B2 = "HW_reconstruct/hw_debug/cases/test_case3_smoke/stages/reuse_mamba_block_top_block2",
    parameter STAGE_DIR_B3 = "HW_reconstruct/hw_debug/cases/test_case3_smoke/stages/reuse_mamba_block_top_block3",
    parameter INPROJ_BANK0_INIT_FILE = {STAGE_DIR, "/inproj_wbuf_bank0.mem"},
    parameter INPROJ_BANK1_INIT_FILE = {STAGE_DIR, "/inproj_wbuf_bank1.mem"},
    parameter INPROJ_BANK2_INIT_FILE = {STAGE_DIR, "/inproj_wbuf_bank2.mem"},
    parameter INPROJ_BANK3_INIT_FILE = {STAGE_DIR, "/inproj_wbuf_bank3.mem"},
    parameter INPROJ_BANK4_INIT_FILE = {STAGE_DIR, "/inproj_wbuf_bank4.mem"},
    parameter INPROJ_BANK5_INIT_FILE = {STAGE_DIR, "/inproj_wbuf_bank5.mem"},
    parameter INPROJ_SCALE_INIT_FILE = {STAGE_DIR, "/inproj_scale_q15.mem"},
    parameter DT_BANK0_INIT_FILE = {STAGE_DIR, "/dt_wbuf_bank0.mem"},
    parameter DT_BANK1_INIT_FILE = {STAGE_DIR, "/dt_wbuf_bank1.mem"},
    parameter DT_BANK2_INIT_FILE = {STAGE_DIR, "/dt_wbuf_bank2.mem"},
    parameter DT_BANK3_INIT_FILE = {STAGE_DIR, "/dt_wbuf_bank3.mem"},
    parameter DT_SCALE_INIT_FILE = {STAGE_DIR, "/dt_scale_q15.mem"},
    parameter OUTPROJ_BANK0_INIT_FILE = {STAGE_DIR, "/outproj_wbuf_bank0.mem"},
    parameter OUTPROJ_BANK1_INIT_FILE = {STAGE_DIR, "/outproj_wbuf_bank1.mem"},
    parameter OUTPROJ_BANK2_INIT_FILE = {STAGE_DIR, "/outproj_wbuf_bank2.mem"},
    parameter OUTPROJ_BANK3_INIT_FILE = {STAGE_DIR, "/outproj_wbuf_bank3.mem"},
    parameter OUTPROJ_BANK4_INIT_FILE = {STAGE_DIR, "/outproj_wbuf_bank4.mem"},
    parameter OUTPROJ_BANK5_INIT_FILE = {STAGE_DIR, "/outproj_wbuf_bank5.mem"},
    parameter OUTPROJ_SCALE_INIT_FILE = {STAGE_DIR, "/outproj_scale_q15.mem"},
    parameter ENABLE_RMSNORM = 1,
    parameter NORM_GAMMA_INIT_FILE = {STAGE_DIR, "/norm_gamma_s16_q8p8.mem"},
    parameter USE_SCALED_STATE_SCAN = 1,
    parameter STATE_U_TO_STATE_SCALE_INIT_FILE = {STAGE_DIR, "/state_u_to_state_q16.mem"},
    parameter STATE_TO_Q88_SCALE_INIT_FILE = {STAGE_DIR, "/state_to_q88_q16.mem"}
) (
    input  wire                           sys_clk,
    input  wire                           ext_reset_n,
    input  wire                           s_axis_h_tvalid,
    output wire                           s_axis_h_tready,
    input  wire [TILE_SIZE*DATA_WIDTH-1:0] s_axis_h_tdata,
    input  wire                           s_axis_h_tlast,
    output wire                           m_axis_y_tvalid,
    input  wire                           m_axis_y_tready,
    output wire [TILE_SIZE*DATA_WIDTH-1:0] m_axis_y_tdata,
    output wire                           m_axis_y_tlast,
    output wire                           frame_busy
);
    localparam integer H_ADDR_W = 5;
    localparam [15:0] H_ROWS_CFG = H_ROWS[15:0];

    wire                           rst_n_int;
    wire                           preload_h_busy;
    wire                           preload_h_done;
    wire                           h_wr_en;
    wire [H_ADDR_W-1:0]            h_wr_addr;
    wire signed [TILE_SIZE*DATA_WIDTH-1:0] h_wr_data_flat;

    reg                            preload_h_start_pulse;
    reg                            core_start_pulse;
    reg [15:0]                     y_row_cnt;
    reg                            core_launch_pending;
    wire                           core_busy;
    wire                           core_done;
    wire                           core_rst_n_o;
    wire                           y_fire;
    wire                           y_last_int;
    wire [15:0]                    h_rows_safe;

    assign rst_n_int    = ext_reset_n;
    assign frame_busy   = preload_h_busy | core_busy;
    assign h_rows_safe  = (H_ROWS_CFG == 16'd0) ? 16'd1 : H_ROWS_CFG;
    assign y_fire       = m_axis_y_tvalid & m_axis_y_tready;
    assign y_last_int   = y_fire && (y_row_cnt == (h_rows_safe - 16'd1));
    assign m_axis_y_tlast = y_last_int;

    reuse_mamba_h_stream_loader #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .H_ADDR_W  (H_ADDR_W)
    ) u_h_loader (
        .clk          (sys_clk),
        .rst_n        (rst_n_int),
        .start        (preload_h_start_pulse),
        .rows_cfg     (H_ROWS_CFG),
        .busy         (preload_h_busy),
        .done         (preload_h_done),
        .s_axis_tvalid(s_axis_h_tvalid),
        .s_axis_tready(s_axis_h_tready),
        .s_axis_tdata (s_axis_h_tdata),
        .s_axis_tlast (s_axis_h_tlast),
        .h_wr_en      (h_wr_en),
        .h_wr_addr    (h_wr_addr),
        .h_wr_data    (h_wr_data_flat)
    );

    always @(posedge sys_clk) begin
        if (!rst_n_int) begin
            preload_h_start_pulse <= 1'b0;
            core_start_pulse      <= 1'b0;
            y_row_cnt             <= 16'd0;
            core_launch_pending   <= 1'b0;
        end else begin
            preload_h_start_pulse <= 1'b0;
            core_start_pulse      <= 1'b0;

            // Auto-arm next H frame when core and loader are both idle.
            if (!preload_h_busy && !core_busy && !core_launch_pending && !preload_h_done) begin
                preload_h_start_pulse <= 1'b1;
            end

            // Launch compute as soon as one H frame has been loaded.
            if (preload_h_done && !core_busy) begin
                core_start_pulse <= 1'b1;
                core_launch_pending <= 1'b1;
            end
            if (core_busy) begin
                core_launch_pending <= 1'b0;
            end

            if (core_start_pulse) begin
                y_row_cnt <= 16'd0;
            end else if (y_fire) begin
                if (y_row_cnt == (h_rows_safe - 16'd1))
                    y_row_cnt <= 16'd0;
                else
                    y_row_cnt <= y_row_cnt + 16'd1;
            end
        end
    end

    generate
    if (CHAIN4_ENABLE != 0) begin : g_chain4_core
        reuse_mamba_chain4_core_adapter #(
            .TILE_SIZE   (TILE_SIZE),
            .DATA_WIDTH  (DATA_WIDTH),
            .ACC_WIDTH   (ACC_WIDTH),
            .FRAC_BITS   (FRAC_BITS),
            .N_BANK      (N_BANK),
            .WDEPTH      (WDEPTH),
            .WADDR_W     (WADDR_W),
            .DATA_W      (DATA_W),
            .XT_ADDR_W   (XT_ADDR_W),
            .D           (D),
            .PIPE_LAT    (PIPE_LAT),
            .ADDR_BITS   (ADDR_BITS),
            .LUT_FILE    (LUT_FILE),
            .S_ADDR_W    (S_ADDR_W),
            .G_FRAC_BITS (G_FRAC_BITS),
            .STAGE_DIR_B0(STAGE_DIR_B0),
            .STAGE_DIR_B1(STAGE_DIR_B1),
            .STAGE_DIR_B2(STAGE_DIR_B2),
            .STAGE_DIR_B3(STAGE_DIR_B3)
        ) u_core (
            .sys_clk       (sys_clk),
            .ext_reset_n   (rst_n_int),
            .core_rst_n_o  (core_rst_n_o),
            .start         (core_start_pulse),
            .busy          (core_busy),
            .done          (core_done),
            .h_wr_en       (h_wr_en),
            .h_wr_addr     (h_wr_addr),
            .h_wr_data     (h_wr_data_flat),
            .y_axis_tvalid (m_axis_y_tvalid),
            .y_axis_tready (m_axis_y_tready),
            .y_axis_tdata  (m_axis_y_tdata)
        );
    end else begin : g_single_core
        wire unused_g_ready;
        reuse_mamba_core_adapter #(
            .TILE_SIZE(TILE_SIZE), .DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH), .FRAC_BITS(FRAC_BITS),
            .N_BANK(N_BANK), .WDEPTH(WDEPTH), .WADDR_W(WADDR_W), .DATA_W(DATA_W), .XT_ADDR_W(XT_ADDR_W), .D(D),
            .PIPE_LAT(PIPE_LAT), .ADDR_BITS(ADDR_BITS), .LUT_FILE(LUT_FILE), .S_ADDR_W(S_ADDR_W), .G_FRAC_BITS(G_FRAC_BITS),
            .INPROJ_BANK0_INIT_FILE(INPROJ_BANK0_INIT_FILE), .INPROJ_BANK1_INIT_FILE(INPROJ_BANK1_INIT_FILE),
            .INPROJ_BANK2_INIT_FILE(INPROJ_BANK2_INIT_FILE), .INPROJ_BANK3_INIT_FILE(INPROJ_BANK3_INIT_FILE),
            .INPROJ_BANK4_INIT_FILE(INPROJ_BANK4_INIT_FILE), .INPROJ_BANK5_INIT_FILE(INPROJ_BANK5_INIT_FILE),
            .INPROJ_SCALE_INIT_FILE(INPROJ_SCALE_INIT_FILE),
            .DT_BANK0_INIT_FILE(DT_BANK0_INIT_FILE), .DT_BANK1_INIT_FILE(DT_BANK1_INIT_FILE),
            .DT_BANK2_INIT_FILE(DT_BANK2_INIT_FILE), .DT_BANK3_INIT_FILE(DT_BANK3_INIT_FILE),
            .DT_SCALE_INIT_FILE(DT_SCALE_INIT_FILE),
            .OUTPROJ_BANK0_INIT_FILE(OUTPROJ_BANK0_INIT_FILE), .OUTPROJ_BANK1_INIT_FILE(OUTPROJ_BANK1_INIT_FILE),
            .OUTPROJ_BANK2_INIT_FILE(OUTPROJ_BANK2_INIT_FILE), .OUTPROJ_BANK3_INIT_FILE(OUTPROJ_BANK3_INIT_FILE),
            .OUTPROJ_BANK4_INIT_FILE(OUTPROJ_BANK4_INIT_FILE), .OUTPROJ_BANK5_INIT_FILE(OUTPROJ_BANK5_INIT_FILE),
            .OUTPROJ_SCALE_INIT_FILE(OUTPROJ_SCALE_INIT_FILE),
            .ENABLE_RMSNORM(ENABLE_RMSNORM), .NORM_GAMMA_INIT_FILE(NORM_GAMMA_INIT_FILE),
            .USE_SCALED_STATE_SCAN(USE_SCALED_STATE_SCAN),
            .STATE_U_TO_STATE_SCALE_INIT_FILE(STATE_U_TO_STATE_SCALE_INIT_FILE),
            .STATE_TO_Q88_SCALE_INIT_FILE(STATE_TO_Q88_SCALE_INIT_FILE)
        ) u_core (
            .sys_clk         (sys_clk),
            .ext_reset_n     (rst_n_int),
            .core_rst_n_o    (core_rst_n_o),
            .block_auto_mode (1'b1),
            .block_start     (core_start_pulse),
            .block_busy      (core_busy),
            .block_done      (core_done),
            .s_axis_tvalid   (1'b0),
            .s_axis_tready   (),
            .g_axis_tvalid   (1'b0),
            .g_axis_tready   (unused_g_ready),
            .g_axis_tdata    ({(TILE_SIZE*DATA_WIDTH){1'b0}}),
            .y_axis_tvalid   (m_axis_y_tvalid),
            .y_axis_tready   (m_axis_y_tready),
            .y_axis_tdata    (m_axis_y_tdata),
            .inproj_enable   (1'b1),
            .inproj_start    (1'b1),
            .inproj_busy     (),
            .inproj_done     (),
            .h_wr_en         (h_wr_en),
            .h_wr_addr       (h_wr_addr),
            .h_wr_data       (h_wr_data_flat),
            .u_rd_en         (1'b0),
            .u_rd_addr       (6'd0),
            .u_rd_data       (),
            .z_rd_en         (1'b0),
            .z_rd_addr       (6'd0),
            .z_rd_data       (),
            .outproj_enable  (1'b1),
            .outproj_busy    ()
        );
    end
    endgenerate
endmodule
