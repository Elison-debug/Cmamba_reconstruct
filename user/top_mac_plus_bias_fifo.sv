// ============================================================
// top_mac_plus_bias_fifo.sv
// Purpose:
//   slim_mac_mem_controller_combined_dp
//     -> pulse_to_stream_adapter
//     -> bias_add_regslice_ip_A (bias_ROM IP)
//     -> vec_fifo_axis_ip (bias2sigmoid_fifo IP)
//
// Notes:
//   - bias 的 out_ready 接 FIFO 的 in_ready（由 FIFO 反压）
//   - 顶层对外暴露 FIFO 的 out_valid/out_ready/out_vec（后续接 sigmoid）
//   - 仍然保留 bias_raw_* 方便你观察 bias 加法是否正确
// ============================================================

module top_mac_plus_bias_fifo #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH  = 32,
    parameter int FRAC_BITS  = 8,

    // Controller internal params
    parameter int N_BANK     = 6,
    parameter int WDEPTH     = 683,
    parameter int WADDR_W    = $clog2(WDEPTH),
    parameter int DATA_W     = 256,
    parameter int XT_ADDR_W  = 6,

    // Bias params
    parameter int D          = 256,
    parameter int PIPE_LAT   = 4
)(
    input  logic clk,
    input  logic rst_n,

    // ---- Upstream control for controller start ----
    input  logic s_axis_TVALID,
    output logic s_axis_TREADY,

    // ---- FIFO output stream (to sigmoid) ----
    output logic                      fifo_out_valid,
    input  logic                      fifo_out_ready,
    output logic signed [DATA_WIDTH-1:0] fifo_out_vec [TILE_SIZE-1:0],

    // ---- Optional: tap bias output before FIFO (debug) ----
    output logic                      bias_raw_valid,
    output logic signed [DATA_WIDTH-1:0] bias_raw_vec [TILE_SIZE-1:0]
);

    // ============================================================
    // 0) Controller instance
    // ============================================================
    logic                      mac_m_valid;   // done pulse
    logic                      mac_m_ready;
    logic signed [DATA_WIDTH-1:0] mac_vec [TILE_SIZE-1:0];

    // controller 不被下游卡住（你目前的策略）
    assign mac_m_ready = 1'b1;

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

        .reduced_trunc(mac_vec)
    );

    // ============================================================
    // 1) Adapter: pulse -> streaming (valid/ready)
    // ============================================================
    logic ad_valid, ad_ready;
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
    // 2) Bias adder (calls bias_ROM IP)
    // ============================================================
    logic sof_bias;

    assign sof_bias = 1'b0;

    logic                      bias_valid;
    logic                      bias_ready;   // 将由 FIFO in_ready 提供
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

        .sof      (sof_bias),

        .out_valid(bias_valid),
        .out_ready(bias_ready),
        .out_vec  (bias_vec)
    );

    // debug tap before FIFO
    assign bias_raw_valid = bias_valid;
    always_comb begin
        for (int i=0; i<TILE_SIZE; i++) begin
            bias_raw_vec[i] = bias_vec[i];
        end
    end

    // ============================================================
    // 3) FIFO: bias -> sigmoid
    // ============================================================
    vec_fifo_axis_ip #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_vec_fifo (
        .clk      (clk),
        .rst_n    (rst_n),

        .in_valid (bias_valid),
        .in_ready (bias_ready),
        .in_vec   (bias_vec),

        .out_valid(fifo_out_valid),
        .out_ready(fifo_out_ready),
        .out_vec  (fifo_out_vec)
    );

endmodule
