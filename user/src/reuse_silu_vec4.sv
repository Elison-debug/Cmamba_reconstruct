`timescale 1ns/1ps

module reuse_silu_vec4 #(
    parameter int TILE_SIZE  = 4,
    parameter int DATA_WIDTH = 16,
    parameter int FRAC_BITS  = 8,
    parameter int ADDR_BITS  = 11,
    parameter string LUT_FILE = "D:/Mamba/Cmamba_reconstruct/sigmoid_lut_q016_2048.hex"
)(
    input  logic clk,
    input  logic rst_n,

    input  logic                         in_valid,
    output logic                         in_ready,
    input  logic signed [DATA_WIDTH-1:0] in_vec [TILE_SIZE-1:0],

    output logic                         out_valid,
    input  logic                         out_ready,
    output logic signed [DATA_WIDTH-1:0] out_vec [TILE_SIZE-1:0]
);
    logic                         x_path_valid, x_path_ready;
    logic signed [DATA_WIDTH-1:0] x_path_vec [TILE_SIZE-1:0];
    logic                         sig_valid, sig_ready;
    logic [DATA_WIDTH-1:0]        sig_vec [TILE_SIZE-1:0];
    logic                         sig_join_ready, x_join_ready;
    logic                         join_valid, join_ready;
    logic [DATA_WIDTH-1:0]        x_join_vec [TILE_SIZE-1:0];
    logic [DATA_WIDTH-1:0]        sig_join_vec [TILE_SIZE-1:0];
    logic [DATA_WIDTH-1:0]        silu_u [TILE_SIZE-1:0];

    assign in_ready = x_path_ready && sig_ready;

    vec_fifo_axis_ip #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_x_fifo (
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (in_valid && in_ready),
        .in_ready (x_path_ready),
        .in_vec   (in_vec),
        .out_valid(x_path_valid),
        .out_ready(x_join_ready),
        .out_vec  (x_path_vec)
    );

    sigmoid4_vec #(
        .TILE_SIZE (TILE_SIZE),
        .IN_W      (DATA_WIDTH),
        .OUT_W     (DATA_WIDTH),
        .ADDR_BITS (ADDR_BITS),
        .LUT_FILE  (LUT_FILE)
    ) u_sigmoid (
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (in_valid && in_ready),
        .in_ready (sig_ready),
        .in_vec   (in_vec),
        .out_valid(sig_valid),
        .out_ready(sig_join_ready),
        .out_vec  (sig_vec)
    );

    axis_vec_join2 #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_join (
        .clk      (clk),
        .rst_n    (rst_n),
        .a_valid  (sig_valid),
        .a_ready  (sig_join_ready),
        .a_vec    (sig_vec),
        .b_valid  (x_path_valid),
        .b_ready  (x_join_ready),
        .b_vec    (x_path_vec),
        .out_valid(join_valid),
        .out_ready(join_ready),
        .lam_vec  (sig_join_vec),
        .xt_vec   (x_join_vec)
    );

    ewm_vec4 #(
        .TILE_SIZE (TILE_SIZE),
        .IN_W      (DATA_WIDTH),
        .OUT_W     (DATA_WIDTH),
        .FRAC_BITS (16),
        .SIGNED_A  (0),
        .SIGNED_B  (1)
    ) u_silu_mul (
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (join_valid),
        .in_ready (join_ready),
        .out_ready(out_ready),
        .out_valid(out_valid),
        .a_vec    (sig_join_vec),
        .b_vec    (x_join_vec),
        .y_vec    (silu_u)
    );

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++)
            out_vec[i] = $signed(silu_u[i]);
    end
endmodule
