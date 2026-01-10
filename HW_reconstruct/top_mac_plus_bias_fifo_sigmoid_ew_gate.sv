`timescale 1ns/1ps

// 顶层：mac -> bias -> sigmoid -> join -> EW update (s) -> gate (s ⊙ g)
module top_mac_plus_bias_fifo_sigmoid_ew_gate #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH  = 32,
    parameter int FRAC_BITS  = 8,

    parameter int N_BANK     = 6,
    parameter int WDEPTH     = 683,
    parameter int WADDR_W    = $clog2(WDEPTH),
    parameter int DATA_W     = 256,
    parameter int XT_ADDR_W  = 6,

    parameter int D          = 256,
    parameter int PIPE_LAT   = 4,

    parameter int ADDR_BITS  = 11,
    parameter string LUT_FILE = "D:/Mamba/Cmamba_reconstruct/sigmoid_lut_q016_2048.hex",

    parameter int S_ADDR_W   = 6,   // state depth = 2^S_ADDR_W
    parameter int G_FRAC_BITS = 8
)(
    input  logic clk,
    input  logic rst_n,

    // 输入 AXIS（MAC 上层）
    input  logic s_axis_TVALID,
    output logic s_axis_TREADY,

    // gate 输入（上层提供 g_t）
    input  logic                         g_axis_TVALID,
    output logic                         g_axis_TREADY,
    input  logic signed [DATA_WIDTH-1:0] g_axis_TDATA [TILE_SIZE-1:0],

    // gate 输出（y_t）
    output logic                         y_axis_TVALID,
    input  logic                         y_axis_TREADY,
    output logic signed [DATA_WIDTH-1:0] y_axis_TDATA [TILE_SIZE-1:0]
);

    // ========== MAC + controller 输出 ==========
    logic                         mac_m_valid;
    logic signed [DATA_WIDTH-1:0] mac_vec [TILE_SIZE-1:0];
    logic                         mac_m_ready;
    assign mac_m_ready = 1'b1;

    logic                         xt_v;
    logic                         xt_r_int;
    logic signed [DATA_WIDTH-1:0] xt_d [TILE_SIZE-1:0];

    slim_mac_mem_controller_combined_dp #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH),
        .FRAC_BITS (FRAC_BITS),
        .N_BANK    (N_BANK),
        .WDEPTH    (WDEPTH),
        .WADDR_W   (WADDR_W),
        .DATA_W    (DATA_W),
        .XT_ADDR_W (XT_ADDR_W)
    ) u_mac (
        .clk          (clk),
        .rst_n        (rst_n),
        .s_axis_TVALID(s_axis_TVALID),
        .s_axis_TREADY(s_axis_TREADY),
        .m_axis_TVALID(mac_m_valid),
        .m_axis_TREADY(mac_m_ready),
        .reduced_trunc(mac_vec),
        .xt_axis_TVALID(xt_v),
        .xt_axis_TREADY(xt_r_int),
        .xt_axis_TDATA (xt_d)
    );

    // ========== pulse -> stream ==========
    logic                         ad_valid, ad_ready;
    logic signed [DATA_WIDTH-1:0] ad_vec [TILE_SIZE-1:0];
    pulse_to_stream_adapter #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_p2s (
        .clk        (clk),
        .rst_n      (rst_n),
        .pulse_valid(mac_m_valid),
        .pulse_vec  (mac_vec),
        .out_valid  (ad_valid),
        .out_ready  (ad_ready),
        .out_vec    (ad_vec)
    );

    // ========== Bias add ==========
    logic                         bias_valid, bias_ready;
    logic signed [DATA_WIDTH-1:0] bias_vec [TILE_SIZE-1:0];
    bias_add_regslice_ip_A #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .D         (D),
        .PIPE_LAT  (PIPE_LAT)
    ) u_bias_add (
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (ad_valid),
        .in_ready (ad_ready),
        .in_vec   (ad_vec),
        .sof      (1'b0),
        .out_valid(bias_valid),
        .out_ready(bias_ready),
        .out_vec  (bias_vec)
    );

    // ========== FIFO: bias -> sigmoid ==========
    logic                         fifo2sig_valid, fifo2sig_ready;
    logic signed [DATA_WIDTH-1:0] fifo2sig_vec [TILE_SIZE-1:0];
    vec_fifo_axis_ip #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_bias_fifo (
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (bias_valid),
        .in_ready (bias_ready),
        .in_vec   (bias_vec),
        .out_valid(fifo2sig_valid),
        .out_ready(fifo2sig_ready),
        .out_vec  (fifo2sig_vec)
    );

    // ========== Sigmoid ==========
    logic sig_in_ready;
    logic sigmoid_out_valid, sigmoid_out_ready;
    logic [DATA_WIDTH-1:0] sigmoid_out_vec [TILE_SIZE-1:0];
    assign fifo2sig_ready = sig_in_ready;

    sigmoid4_vec #(
        .TILE_SIZE (TILE_SIZE),
        .IN_W      (DATA_WIDTH),
        .OUT_W     (DATA_WIDTH),
        .ADDR_BITS (ADDR_BITS),
        .LUT_FILE  (LUT_FILE)
    ) u_sigmoid (
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (fifo2sig_valid),
        .in_ready (sig_in_ready),
        .in_vec   (fifo2sig_vec),
        .out_valid(sigmoid_out_valid),
        .out_ready(sigmoid_out_ready),
        .out_vec  (sigmoid_out_vec)
    );

    // ========== lambda skid + FIFO ==========
    logic lam_in_valid, lam_in_ready;
    logic [DATA_WIDTH-1:0] lam_in_vec [TILE_SIZE-1:0];
    logic lam_skid0_valid, lam_skid1_valid;
    logic [DATA_WIDTH-1:0] lam_skid0_vec [TILE_SIZE-1:0];
    logic [DATA_WIDTH-1:0] lam_skid1_vec [TILE_SIZE-1:0];
    assign sigmoid_out_ready = ~lam_skid1_valid;
    assign lam_in_valid = lam_skid0_valid;
    always_comb for (int i=0; i<TILE_SIZE; i++) lam_in_vec[i] = lam_skid0_vec[i];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lam_skid0_valid <= 1'b0; lam_skid1_valid <= 1'b0;
            for (int i=0; i<TILE_SIZE; i++) begin
                lam_skid0_vec[i] <= '0;
                lam_skid1_vec[i] <= '0;
            end
        end else begin
            logic nxt0_v, nxt1_v;
            logic [DATA_WIDTH-1:0] nxt0_vec [TILE_SIZE-1:0];
            logic [DATA_WIDTH-1:0] nxt1_vec [TILE_SIZE-1:0];
            nxt0_v = lam_skid0_valid; nxt1_v = lam_skid1_valid;
            for (int i=0; i<TILE_SIZE; i++) begin
                nxt0_vec[i] = lam_skid0_vec[i];
                nxt1_vec[i] = lam_skid1_vec[i];
            end
            if (lam_in_valid && lam_in_ready) begin
                nxt0_v = nxt1_v;
                for (int i=0; i<TILE_SIZE; i++) nxt0_vec[i] = nxt1_vec[i];
                nxt1_v = 1'b0;
            end
            if (sigmoid_out_valid && sigmoid_out_ready) begin
                if (!nxt0_v) begin
                    nxt0_v = 1'b1;
                    for (int i=0; i<TILE_SIZE; i++) nxt0_vec[i] = sigmoid_out_vec[i];
                end else if (!nxt1_v) begin
                    nxt1_v = 1'b1;
                    for (int i=0; i<TILE_SIZE; i++) nxt1_vec[i] = sigmoid_out_vec[i];
                end
            end
            lam_skid0_valid <= nxt0_v;
            lam_skid1_valid <= nxt1_v;
            for (int i=0; i<TILE_SIZE; i++) begin
                lam_skid0_vec[i] <= nxt0_vec[i];
                lam_skid1_vec[i] <= nxt1_vec[i];
            end
        end
    end

    logic lam_valid, lam_ready_int;
    logic [DATA_WIDTH-1:0] lam_vec [TILE_SIZE-1:0];
    logic [DATA_WIDTH-1:0] lam_vec_u [TILE_SIZE-1:0];
    vec_fifo_axis_ip #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_lam_fifo (
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (lam_in_valid),
        .in_ready (lam_in_ready),
        .in_vec   (lam_in_vec),
        .out_valid(lam_valid),
        .out_ready(lam_ready_int),
        .out_vec  (lam_vec)
    );

    // ========== JOIN λ + xt ==========
    logic join_a_ready, join_b_ready;
    logic join_out_valid, join_out_ready_int;
    logic ew_in_ready;
    logic [DATA_WIDTH-1:0] join_lam_vec [TILE_SIZE-1:0];
    logic [DATA_WIDTH-1:0] join_xt_vec  [TILE_SIZE-1:0];

    logic [DATA_WIDTH-1:0] xt_axis_TDATA_u [TILE_SIZE-1:0];
    always_comb begin
        for (int i=0; i<TILE_SIZE; i++) xt_axis_TDATA_u[i] = xt_d[i];
    end
    always_comb begin
        for (int i=0; i<TILE_SIZE; i++) lam_vec_u[i] = lam_vec[i];
    end

    axis_vec_join2 #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_join (
        .clk      (clk),
        .rst_n    (rst_n),
        .a_valid  (lam_valid),
        .a_ready  (join_a_ready),
        .a_vec    (lam_vec_u),
        .b_valid  (xt_v),
        .b_ready  (join_b_ready),
        .b_vec    (xt_axis_TDATA_u),
        .out_valid(join_out_valid),
        .out_ready(join_out_ready_int),
        .lam_vec  (join_lam_vec),
        .xt_vec   (join_xt_vec)
    );
    assign lam_ready_int = join_a_ready;
    assign xt_r_int      = join_b_ready;

    // ========== EW 更新 ==========
    logic [S_ADDR_W-1:0] s_addr_cnt;
    wire  [S_ADDR_W-1:0] s_addr_mux = s_addr_cnt;
    wire join_fire = join_out_valid && join_out_ready_int;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) s_addr_cnt <= '0;
        else if (join_fire) s_addr_cnt <= s_addr_cnt + 1'b1;
    end

    logic signed [DATA_WIDTH-1:0] join_xt_vec_s [TILE_SIZE-1:0];
    always_comb begin
        for (int i=0; i<TILE_SIZE; i++) join_xt_vec_s[i] = $signed(join_xt_vec[i]);
    end

    logic                         s_out_valid;
    logic                         s_out_ready;
    logic signed [DATA_WIDTH-1:0] s_out_vec [TILE_SIZE-1:0];

    ew_update_vec4 #(
        .TILE_SIZE (TILE_SIZE),
        .W         (DATA_WIDTH),
        .S_ADDR_W  (S_ADDR_W)
    ) u_ew (
        .clk       (clk),
        .rst_n     (rst_n),
        .in_valid  (join_out_valid),
        .in_ready  (ew_in_ready),
        .lam_vec   (join_lam_vec),
        .u_vec     (join_xt_vec_s),
        .s_addr    (s_addr_mux),
        .out_valid (s_out_valid),
        .out_ready (s_out_ready),
        .s_new_vec (s_out_vec)
    );

    assign join_out_ready_int = ew_in_ready;

    // -----------------------------------
    // Gate: align s and g via join, then EWM
    // -----------------------------------
    logic s_gate_ready;
    assign s_out_ready = s_gate_ready;

    ewm_gate_sbuf_vec4 #(
        .TILE_SIZE (TILE_SIZE),
        .W         (DATA_WIDTH),
        .FRAC_BITS (G_FRAC_BITS),
        .S_ADDR_W  (S_ADDR_W)
    ) u_gate (
        .clk       (clk),
        .rst_n     (rst_n),
        .g_valid   (g_axis_TVALID),
        .g_ready   (g_axis_TREADY),
        .g_vec     (g_axis_TDATA),
        .s_valid   (s_out_valid),
        .s_ready   (s_gate_ready),
        .s_vec     (s_out_vec),
        .y_valid   (y_axis_TVALID),
        .y_ready   (y_axis_TREADY),
        .y_vec     (y_axis_TDATA)
    );

endmodule
