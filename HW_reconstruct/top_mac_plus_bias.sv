// ============================================================
// top_mac_plus_bias.sv
// Purpose:
//   Connect: slim_mac_mem_controller_combined_dp
//         -> pulse_to_stream_adapter
//         -> bias_add_regslice_ip_A (calls bias_ROM IP)
//
// For simulation bring-up:
//   - Controller output "done pulse" (m_axis_TVALID) is converted to
//     streaming valid/ready via adapter, then fed to bias adder.
//   - bias_out_ready is tied high (always ready).
//
// Easy extension later:
//   bias_out_valid/ready/out_vec can be wired into FIFO -> sigmoid.
// ============================================================

module top_mac_plus_bias #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH  = 32,
    parameter int FRAC_BITS  = 8,

    // Controller internal params (keep same as your controller)
    parameter int N_BANK     = 6,
    parameter int WDEPTH     = 683,
    parameter int WADDR_W    = $clog2(WDEPTH),
    parameter int DATA_W     = 256,
    parameter int XT_ADDR_W  = 6,

    // Bias params
    parameter int D          = 256,
    // bias_add_regslice_ip 仿真测得总延迟 4 拍（ROM+对齐寄存+输出保持）
    parameter int PIPE_LAT   = 4
)(
    input  logic clk,
    input  logic rst_n,

    // ---- Upstream control for controller start ----
    input  logic s_axis_TVALID,
    output logic s_axis_TREADY,

    // ---- Final output after bias ----
    output logic                     bias_out_valid,
    input  logic                     bias_out_ready,
    output logic signed [DATA_WIDTH-1:0] bias_out_vec [TILE_SIZE-1:0]
);

    // ============================================================
    // 0) Controller instance
    // ============================================================

    logic                     mac_m_valid;   // controller m_axis_TVALID (done pulse)
    logic                     mac_m_ready;   // controller m_axis_TREADY
    logic signed [DATA_WIDTH-1:0] mac_vec [TILE_SIZE-1:0]; // reduced_trunc

    // 仿真先不让 controller 因下游 ready 卡住
    // 如果你希望 controller 只在 bias 链路可接收时才启动，可改成后面 adapter 的 ready 条件
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

        .pulse_valid(mac_m_valid), // 1-cycle done pulse
        .pulse_vec  (mac_vec),

        .out_valid  (ad_valid),
        .out_ready  (ad_ready),
        .out_vec    (ad_vec)
    );

    // ============================================================
    // 2) Bias adder (calls bias_ROM IP)
    // ============================================================

    logic sof_bias;

    // 仿真先固定 0：bias 地址连续递增循环
    // 如果你希望每次“新向量开始”从 bias[0] 开始，把 sof_bias 接到你的帧起点脉冲
    assign sof_bias = 1'b0;

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

        .out_valid(bias_out_valid),
        .out_ready(bias_out_ready),
        .out_vec  (bias_out_vec)
    );

endmodule
