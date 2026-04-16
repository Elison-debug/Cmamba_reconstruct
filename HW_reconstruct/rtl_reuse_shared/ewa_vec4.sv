// ============================================================
// ewa_vec4.sv
// Element-wise add for 4 lanes
// Default: 16-bit + 16-bit -> 16-bit (with optional saturation later)
// ============================================================
module ewa_vec4 #(
    parameter int TILE_SIZE = 4,
    parameter int W         = 16,
    parameter bit SIGNED_IO = 1,
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

    always_comb begin
        for (int i=0;i<TILE_SIZE;i++) begin
            logic signed [W-1:0] sat_max;
            logic signed [W-1:0] sat_min;
            sat_max = {1'b0, {(W-1){1'b1}}};
            sat_min = {1'b1, {(W-1){1'b0}}};
            if (SAT_MODE == 0) begin
                y_next[i] = sum_vec[i][W-1:0];
            end else if (SIGNED_IO) begin
                if (sum_vec[i] > $signed(sat_max)) y_next[i] = sat_max;
                else if (sum_vec[i] < $signed(sat_min)) y_next[i] = sat_min;
                else y_next[i] = sum_vec[i][W-1:0];
            end else begin
                logic [W:0] sum_u;
                sum_u = $unsigned(sum_vec[i]);
                if (sum_u[W]) y_next[i] = {W{1'b1}};
                else y_next[i] = sum_u[W-1:0];
            end
        end
    end

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
