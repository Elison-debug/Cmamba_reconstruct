`timescale 1ns/1ps

module top_mac_plus_bias_fifo_sigmoid #(
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
    parameter string LUT_FILE = "D:/Mamba/Cmamba_reconstruct/sigmoid_lut_q016_2048.hex"
)(
    input  logic clk,
    input  logic rst_n,

    input  logic s_axis_TVALID,
    output logic s_axis_TREADY,

    // [B/TB expects] pre-sigmoid stream
    output logic                         fifo_out_valid,
    input  logic                         fifo_out_ready,
    output logic signed [DATA_WIDTH-1:0]  fifo_out_vec [TILE_SIZE-1:0],

    // [B/TB expects] lambda stream after sigmoid FIFO
    output logic                         lam_axis_TVALID,
    input  logic                         lam_axis_TREADY,
    output logic [DATA_WIDTH-1:0]         lam_axis_TDATA [TILE_SIZE-1:0],

    // [B/TB expects] xt stream from controller
    output logic                         xt_axis_TVALID,
    input  logic                         xt_axis_TREADY,
    output logic signed [DATA_WIDTH-1:0]  xt_axis_TDATA [TILE_SIZE-1:0],

    // [B/TB expects] join output
    output logic                         join_out_valid,
    input  logic                         join_out_ready,
    output logic [DATA_WIDTH-1:0]         join_lam_vec [TILE_SIZE-1:0],
    output logic [DATA_WIDTH-1:0]         join_xt_vec  [TILE_SIZE-1:0]
);

    // ============================================================
    // 0) Controller instance (produces MAC vec + xt stream)
    // ============================================================
    logic                         mac_m_valid;
    logic                         mac_m_ready;
    logic signed [DATA_WIDTH-1:0] mac_vec [TILE_SIZE-1:0];

    assign mac_m_ready = 1'b1;

    logic                         xt_v;
    logic                         xt_r_int;   // <-- internal ready back to controller
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
        .xt_axis_TREADY(xt_r_int),  // <-- 回推 ready
        .xt_axis_TDATA (xt_d)
    );

    // export xt stream to top ports (valid/data直通，ready由后面join控制)
    assign xt_axis_TVALID = xt_v;
    always_comb begin
        for (int i=0; i<TILE_SIZE; i++) begin
            xt_axis_TDATA[i] = xt_d[i];
        end
    end

    // ============================================================
    // 1) pulse -> stream
    // ============================================================
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

    // ============================================================
    // 2) Bias add
    // ============================================================
    logic                         bias_valid;
    logic                         bias_ready;
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

    // ============================================================
    // 3) FIFO: bias -> pre-sigmoid stream
    // ============================================================
    logic                         fifo2sig_valid;
    logic                         fifo2sig_ready;
    logic signed [DATA_WIDTH-1:0]  fifo2sig_vec [TILE_SIZE-1:0];

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

    // export pre-sigmoid stream
    assign fifo_out_valid = fifo2sig_valid;
    always_comb begin
        for (int i=0; i<TILE_SIZE; i++) begin
            fifo_out_vec[i] = fifo2sig_vec[i];
        end
    end

    // ============================================================
    // 4) Sigmoid: Q8.8 -> Q0.16
    // ============================================================
    logic                         sig_in_ready;
    logic                         sigmoid_out_valid;
    logic                         sigmoid_out_ready;
    logic [DATA_WIDTH-1:0]         sigmoid_out_vec [TILE_SIZE-1:0];

    // broadcast consumption: pre-sigmoid token pops only when debug sink AND sigmoid sink ready
    wire broadcast_ready = fifo_out_ready && sig_in_ready;
    assign fifo2sig_ready = broadcast_ready;

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

    // ============================================================
    // 5) Skid buffer (depth 2) then FIFO: sigmoid -> lam_fifo (Q0.16)
    // ============================================================
    // skid decouples sigmoid from join backpressure to avoid dropping 3rd tile
    logic                         lam_in_valid;
    logic                         lam_in_ready;
    logic [DATA_WIDTH-1:0]         lam_in_vec [TILE_SIZE-1:0];

    logic                         lam_skid0_valid, lam_skid1_valid;
    logic [DATA_WIDTH-1:0]         lam_skid0_vec [TILE_SIZE-1:0];
    logic [DATA_WIDTH-1:0]         lam_skid1_vec [TILE_SIZE-1:0];

    // accept from sigmoid when space available (two slots)
    assign sigmoid_out_ready = ~lam_skid1_valid;

    // drive FIFO input from skid head
    assign lam_in_valid = lam_skid0_valid;
    always_comb begin
        for (int i=0; i<TILE_SIZE; i++) lam_in_vec[i] = lam_skid0_vec[i];
    end

    // skid push/pop
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lam_skid0_valid <= 1'b0;
            lam_skid1_valid <= 1'b0;
            for (int i=0; i<TILE_SIZE; i++) begin
                lam_skid0_vec[i] <= '0;
                lam_skid1_vec[i] <= '0;
            end
        end else begin
            // next-state temp vars to avoid drop when pop & push in same cycle
            logic nxt0_v, nxt1_v;
            logic [DATA_WIDTH-1:0] nxt0_vec [TILE_SIZE-1:0];
            logic [DATA_WIDTH-1:0] nxt1_vec [TILE_SIZE-1:0];

            nxt0_v = lam_skid0_valid;
            nxt1_v = lam_skid1_valid;
            for (int i=0; i<TILE_SIZE; i++) begin
                nxt0_vec[i] = lam_skid0_vec[i];
                nxt1_vec[i] = lam_skid1_vec[i];
            end

            // pop to FIFO when it accepts
            if (lam_in_valid && lam_in_ready) begin
                nxt0_v = nxt1_v;
                for (int i=0; i<TILE_SIZE; i++) nxt0_vec[i] = nxt1_vec[i];
                nxt1_v = 1'b0;
            end

            // push from sigmoid when available and space (after possible pop)
            if (sigmoid_out_valid && sigmoid_out_ready) begin
                if (!nxt0_v) begin
                    nxt0_v = 1'b1;
                    for (int i=0; i<TILE_SIZE; i++) nxt0_vec[i] = sigmoid_out_vec[i];
                end else if (!nxt1_v) begin
                    nxt1_v = 1'b1;
                    for (int i=0; i<TILE_SIZE; i++) nxt1_vec[i] = sigmoid_out_vec[i];
                end
            end

            // commit
            lam_skid0_valid <= nxt0_v;
            lam_skid1_valid <= nxt1_v;
            for (int i=0; i<TILE_SIZE; i++) begin
                lam_skid0_vec[i] <= nxt0_vec[i];
                lam_skid1_vec[i] <= nxt1_vec[i];
            end
        end
    end

    logic                         lam_valid;
    logic                         lam_ready_int;   // <-- 真正回推给 lam_fifo 的ready（由join决定）
    logic [DATA_WIDTH-1:0]         lam_vec [TILE_SIZE-1:0];

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
        .out_ready(lam_ready_int),   // <-- 这里必须接 join 回推
        .out_vec  (lam_vec)
    );

    // export lam stream (给TB观察用，不参与消费节拍)
    assign lam_axis_TVALID = lam_valid;
    always_comb begin
        for (int i=0; i<TILE_SIZE; i++) begin
            lam_axis_TDATA[i] = lam_vec[i];
        end
    end

    // ============================================================
    // 6) JOIN: lam + xt  → step2 input
    // ============================================================
    logic join_a_ready;
    logic join_b_ready;

    axis_vec_join2 #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_join (
        .clk      (clk),
        .rst_n    (rst_n),

        .a_valid  (lam_valid),
        .a_ready  (join_a_ready),     // <-- 必须接出来
        .a_vec    (lam_vec),

        .b_valid  (xt_axis_TVALID),
        .b_ready  (join_b_ready),     // <-- 必须接出来
        .b_vec    (xt_axis_TDATA),

        .out_valid(join_out_valid),
        .out_ready(join_out_ready),

        .lam_vec  (join_lam_vec),
        .xt_vec   (join_xt_vec)
    );

    // ============================================================
    // 7) 工程正确：把 join a_ready/b_ready 回推到两路 FIFO
    // ============================================================
    // 外部 lam_axis_TREADY / xt_axis_TREADY 只作为“观测端的允许”（一般TB会给1）
    // 真正 pop 由 join 控制：必须两边同时允许才前进
    assign lam_ready_int = join_a_ready && lam_axis_TREADY;
    assign xt_r_int      = join_b_ready && xt_axis_TREADY;

endmodule
