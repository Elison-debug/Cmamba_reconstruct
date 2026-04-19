// ============================================================
// ewa_vec4.sv
// Element-wise add for 4 lanes
// Default: 16-bit + 16-bit -> 16-bit (with optional saturation later)
// ============================================================
module ewa_vec4 #(
    parameter int TILE_SIZE = 4,
    parameter int W         = 16,
    parameter bit SIGNED_IO = 1,
    parameter int ROUND_MODE = 0,
    parameter int SAT_MODE  = 0
)(
    input  logic clk,
    input  logic rst_n,

    input  logic in_valid,
    output logic in_ready,
    input  logic out_ready,
    output logic out_valid,

    input  logic [W-1:0] a_vec [TILE_SIZE-1:0],
    input  logic [W-1:0] b_vec [TILE_SIZE-1:0],
    output logic [W-1:0] y_vec [TILE_SIZE-1:0]
);

    assign in_ready = out_ready || !out_valid;

    logic [W-1:0] y_next [TILE_SIZE-1:0];
    logic signed [W:0] sum_vec [TILE_SIZE-1:0];
    logic [15:0] dummy_scale [TILE_SIZE-1:0];

    always_comb begin
        for (int i=0;i<TILE_SIZE;i++) begin
            logic signed [W:0] sum; // one extra bit
            if (SIGNED_IO)
                sum = $signed(a_vec[i]) + $signed(b_vec[i]);
            else
                sum = $signed({1'b0,a_vec[i]}) + $signed({1'b0,b_vec[i]});

            sum_vec[i] = sum;
        end
    end

    requant_round_sat_engine #(
        .TILE_SIZE       (TILE_SIZE),
        .IN_W            (W+1),
        .OUT_W           (W),
        .SHIFT           (0),
        .SCALE_W         (16),
        .SCALE_FRAC_BITS (0),
        .SIGNED_IN       (SIGNED_IO),
        .SIGNED_OUT      (SIGNED_IO),
        .USE_SCALE       (0),
        .ROUND_MODE      (ROUND_MODE),
        .SAT_MODE        (SAT_MODE)
    ) u_ewa_quant (
        .in_vec    (sum_vec),
        .scale_vec (dummy_scale),
        .out_vec   (y_next)
    );

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
