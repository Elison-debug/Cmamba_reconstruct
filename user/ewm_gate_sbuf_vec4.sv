// ============================================================
// ewm_gate_sbuf_vec4.sv
// Output gate: y = s ⊙ g
// - g: stream input (signed)
// - s: stream input (signed, wrapped with valid/ready)
// - s/g alignment via axis_vec_join2 (dual FIFO)
// ============================================================
module ewm_gate_sbuf_vec4 #(
    parameter int TILE_SIZE  = 4,
    parameter int W          = 16,
    parameter int FRAC_BITS  = 8,
    parameter int S_ADDR_W   = 6
)(
    input  logic clk,
    input  logic rst_n,

    // gate input stream
    input  logic                 g_valid,
    output logic                 g_ready,
    input  logic signed [W-1:0]  g_vec [TILE_SIZE-1:0],
    // s stream (from EW update output)
    input  logic                 s_valid,
    output logic                 s_ready,
    input  logic signed [W-1:0]  s_vec [TILE_SIZE-1:0],

    // output stream
    output logic                 y_valid,
    input  logic                 y_ready,
    output logic signed [W-1:0]  y_vec [TILE_SIZE-1:0]
);

    // ------------------------------------------------------------
    // 1) Align s and g via axis_vec_join2
    // ------------------------------------------------------------
    logic [W-1:0] s_vec_u [TILE_SIZE-1:0];
    logic [W-1:0] g_vec_u [TILE_SIZE-1:0];
    logic [W-1:0] s_aligned_u [TILE_SIZE-1:0];
    logic [W-1:0] g_aligned_u [TILE_SIZE-1:0];
    logic join_valid, join_ready;

    always_comb begin
        for (int i=0; i<TILE_SIZE; i++) begin
            s_vec_u[i] = s_vec[i];
            g_vec_u[i] = g_vec[i];
        end
    end

    axis_vec_join2 #(
        .TILE_SIZE (TILE_SIZE),
        .DATA_WIDTH(W)
    ) u_sg_join (
        .clk      (clk),
        .rst_n    (rst_n),
        .a_valid  (s_valid),
        .a_ready  (s_ready),
        .a_vec    (s_vec_u),
        .b_valid  (g_valid),
        .b_ready  (g_ready),
        .b_vec    (g_vec_u),
        .out_valid(join_valid),
        .out_ready(join_ready),
        .lam_vec  (s_aligned_u),
        .xt_vec   (g_aligned_u)
    );

    // ------------------------------------------------------------
    // 2) EWM: y = s * g (signed)
    // ------------------------------------------------------------
    logic [W-1:0] y_vec_u [TILE_SIZE-1:0];
    logic [W-1:0] s_aligned [TILE_SIZE-1:0];
    logic [W-1:0] g_aligned [TILE_SIZE-1:0];
    always_comb begin
        for (int i=0; i<TILE_SIZE; i++) begin
            s_aligned[i] = s_aligned_u[i];
            g_aligned[i] = g_aligned_u[i];
        end
    end

    ewm_vec4 #(
        .TILE_SIZE (TILE_SIZE),
        .IN_W      (W),
        .OUT_W     (W),
        .FRAC_BITS (FRAC_BITS),
        .SIGNED_A  (1),
        .SIGNED_B  (1)
    ) u_ewm_gate (
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (join_valid),
        .in_ready (join_ready),
        .out_ready(y_ready),
        .out_valid(y_valid),
        .a_vec    (g_aligned),
        .b_vec    (s_aligned),
        .y_vec    (y_vec_u)
    );

    always_comb begin
        for (int i=0; i<TILE_SIZE; i++) begin
            y_vec[i] = $signed(y_vec_u[i]);
        end
    end

endmodule
