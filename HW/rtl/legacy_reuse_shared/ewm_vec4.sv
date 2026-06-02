// ============================================================
// ewm_vec4.sv
// Element-wise multiply for 4 lanes
// Default: 16x16 -> 32, then back to 16 (Q0.16) with truncation.
// You can later add rounding/saturation.
// ============================================================
module ewm_vec4 #(
    parameter int TILE_SIZE  = 4,
    parameter int IN_W       = 16,
    parameter int MID_W      = 32,
    parameter int OUT_W      = 16,
    parameter int FRAC_BITS  = 16,  // for Q0.16 * Q0.16 => shift right 16
    parameter bit SIGNED_A   = 0,   // lambda is unsigned
    parameter bit SIGNED_B   = 1,   // s/u can be signed
    parameter int ROUND_MODE = 0,
    parameter int SAT_MODE   = 0
)(
    input  logic clk,
    input  logic rst_n,

    // handshake
    input  logic in_valid,
    output logic in_ready,
    input  logic out_ready,
    output logic out_valid,

    // data
    input  logic [IN_W-1:0]  a_vec [TILE_SIZE-1:0],
    input  logic [IN_W-1:0]  b_vec [TILE_SIZE-1:0],
    output logic [OUT_W-1:0] y_vec [TILE_SIZE-1:0]
);

    // 这个模块本身 1-stage pipeline（可扩展）
    // 简化：永远 ready（由外部保证对齐），如需更强 backpressure 可改成 skid-buffer
    assign in_ready  = out_ready || !out_valid;

    logic [OUT_W-1:0] y_next [TILE_SIZE-1:0];
    logic [MID_W-1:0] prod_vec [TILE_SIZE-1:0];
    logic [15:0]      requant_dummy_scale [TILE_SIZE-1:0];

    // combinational multiply
    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++) begin
            logic signed [MID_W-1:0] prod_i;
            
            if (SIGNED_A && SIGNED_B)
                prod_i = $signed(a_vec[i]) * $signed(b_vec[i]);
            else if (SIGNED_A && !SIGNED_B)
                prod_i = $signed(a_vec[i]) * $signed({1'b0,b_vec[i]});
            else if (!SIGNED_A && SIGNED_B)
                prod_i = $signed({1'b0,a_vec[i]}) * $signed(b_vec[i]);
            else
                prod_i = $signed({1'b0,a_vec[i]}) * $signed({1'b0,b_vec[i]});

            prod_vec[i] = prod_i;
        end
    end

    requant_round_sat_engine #(
        .TILE_SIZE  (TILE_SIZE),
        .IN_W       (MID_W),
        .OUT_W      (OUT_W),
        .SHIFT      (FRAC_BITS),
        .SIGNED_IN  (1),
        .SIGNED_OUT (SIGNED_A || SIGNED_B),
        .USE_SCALE  (0),
        .ROUND_MODE (ROUND_MODE),
        .SAT_MODE   (SAT_MODE)
    ) u_requant (
        .in_vec  (prod_vec),
        .scale_vec(requant_dummy_scale),
        .out_vec (y_next)
    );

    // 1-deep output register with valid
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            out_valid <= 1'b0;
            for (int i=0;i<TILE_SIZE;i++) y_vec[i] <= '0;
        end else begin
            if (in_valid && in_ready) begin
                for (int i=0;i<TILE_SIZE;i++) y_vec[i] <= y_next[i];
                out_valid <= 1'b1;
            end else if (out_valid && out_ready) begin
                out_valid <= 1'b0;
            end
        end
    end

endmodule
