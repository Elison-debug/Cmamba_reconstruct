// ============================================================
// ewa_vec4.sv
// Element-wise add for 4 lanes
// Default: 16-bit + 16-bit -> 16-bit (with optional saturation later)
// ============================================================
module ewa_vec4 #(
    parameter int TILE_SIZE = 4,
    parameter int W         = 16,
    parameter bit SIGNED_IO = 1
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

    always_comb begin
        for (int i=0;i<TILE_SIZE;i++) begin
            logic signed [W:0] sum; // one extra bit
            if (SIGNED_IO)
                sum = $signed(a_vec[i]) + $signed(b_vec[i]);
            else
                sum = $signed({1'b0,a_vec[i]}) + $signed({1'b0,b_vec[i]});

            // TODO: saturation if needed
            y_next[i] = sum[W-1:0];
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
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
