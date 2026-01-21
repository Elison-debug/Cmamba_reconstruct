`timescale 1ns/1ps

// Wrapper for post-synth netlist ports (flattened unpacked arrays).
module top_mac_plus_bias_fifo_sigmoid_ew_gate_post_synth_wrapper #(
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
    parameter string LUT_FILE = "E:/Master/2025/Mamba/Cmamba_reconstruct/user/data/sigmoid_lut_q016_2048.hex",

    parameter int S_ADDR_W   = 6,
    parameter int G_FRAC_BITS = 8
)(
    input  logic clk,
    input  logic rst_n,

    input  logic s_axis_TVALID,
    output logic s_axis_TREADY,

    input  logic                         g_axis_TVALID,
    output logic                         g_axis_TREADY,
    input  logic signed [DATA_WIDTH-1:0] g_axis_TDATA [TILE_SIZE-1:0],

    output logic                         y_axis_TVALID,
    input  logic                         y_axis_TREADY,
    output logic signed [DATA_WIDTH-1:0] y_axis_TDATA [TILE_SIZE-1:0]
);
    localparam int PS_TILE_SIZE = 4;
    initial begin
        if (TILE_SIZE != PS_TILE_SIZE) begin
            $error("POST_SYNTH wrapper expects TILE_SIZE=%0d, got %0d", PS_TILE_SIZE, TILE_SIZE);
        end
    end

`ifdef POST_SYNTH
    top_mac_plus_bias_fifo_sigmoid_ew_gate #(
        .TILE_SIZE  (TILE_SIZE),
        .DATA_WIDTH (DATA_WIDTH),
        .ACC_WIDTH  (ACC_WIDTH),
        .FRAC_BITS  (FRAC_BITS),
        .N_BANK     (N_BANK),
        .WDEPTH     (WDEPTH),
        .WADDR_W    (WADDR_W),
        .DATA_W     (DATA_W),
        .XT_ADDR_W  (XT_ADDR_W),
        .D          (D),
        .PIPE_LAT   (PIPE_LAT),
        .ADDR_BITS  (ADDR_BITS),
        .LUT_FILE   (LUT_FILE),
        .S_ADDR_W   (S_ADDR_W),
        .G_FRAC_BITS(G_FRAC_BITS)
    ) dut (
        .clk           (clk),
        .rst_n         (rst_n),
        .s_axis_TVALID (s_axis_TVALID),
        .s_axis_TREADY (s_axis_TREADY),
        .g_axis_TVALID (g_axis_TVALID),
        .g_axis_TREADY (g_axis_TREADY),
        .\g_axis_TDATA[0] (g_axis_TDATA[0]),
        .\g_axis_TDATA[1] (g_axis_TDATA[1]),
        .\g_axis_TDATA[2] (g_axis_TDATA[2]),
        .\g_axis_TDATA[3] (g_axis_TDATA[3]),
        .y_axis_TVALID (y_axis_TVALID),
        .y_axis_TREADY (y_axis_TREADY),
        .\y_axis_TDATA[0] (y_axis_TDATA[0]),
        .\y_axis_TDATA[1] (y_axis_TDATA[1]),
        .\y_axis_TDATA[2] (y_axis_TDATA[2]),
        .\y_axis_TDATA[3] (y_axis_TDATA[3])
    );
`else
    top_mac_plus_bias_fifo_sigmoid_ew_gate #(
        .TILE_SIZE  (TILE_SIZE),
        .DATA_WIDTH (DATA_WIDTH),
        .ACC_WIDTH  (ACC_WIDTH),
        .FRAC_BITS  (FRAC_BITS),
        .N_BANK     (N_BANK),
        .WDEPTH     (WDEPTH),
        .WADDR_W    (WADDR_W),
        .DATA_W     (DATA_W),
        .XT_ADDR_W  (XT_ADDR_W),
        .D          (D),
        .PIPE_LAT   (PIPE_LAT),
        .ADDR_BITS  (ADDR_BITS),
        .LUT_FILE   (LUT_FILE),
        .S_ADDR_W   (S_ADDR_W),
        .G_FRAC_BITS(G_FRAC_BITS)
    ) dut (
        .clk           (clk),
        .rst_n         (rst_n),
        .s_axis_TVALID (s_axis_TVALID),
        .s_axis_TREADY (s_axis_TREADY),
        .g_axis_TVALID (g_axis_TVALID),
        .g_axis_TREADY (g_axis_TREADY),
        .g_axis_TDATA  (g_axis_TDATA),
        .y_axis_TVALID (y_axis_TVALID),
        .y_axis_TREADY (y_axis_TREADY),
        .y_axis_TDATA  (y_axis_TDATA)
    );
`endif
endmodule
