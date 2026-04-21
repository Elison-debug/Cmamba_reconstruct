// ============================================================
// requant_round_sat_engine.sv
// Shared requantization engine for vector lanes.
//
// Supported behaviors:
//   ROUND_MODE=0 : arithmetic shift / truncation
//   ROUND_MODE=1 : round-to-nearest, ties-to-even
//   SAT_MODE=0   : wrap to OUT_W bits
//   SAT_MODE=1   : clamp to OUT_W numeric range
//   USE_SCALE=0  : plain shift / round / cast
//   USE_SCALE=1  : multiply by per-lane scale_vec before shift / round / cast
//
// This module centralizes the common "shift + round + cast" path.
// With USE_SCALE=1, schedulers can supply per-output-channel scale
// factors using a packed row-tile scale memory.
// ============================================================
`timescale 1ns/1ps

module requant_round_sat_engine #(
    parameter int TILE_SIZE   = 4,
    parameter int IN_W        = 32,
    parameter int OUT_W       = 16,
    parameter int SHIFT       = 8,
    parameter int SCALE_W     = 16,
    parameter int SCALE_FRAC_BITS = 15,
    parameter bit SIGNED_IN   = 1,
    parameter bit SIGNED_OUT  = 1,
    parameter bit USE_SCALE   = 0,
    parameter int ROUND_MODE  = 0,
    parameter int SAT_MODE    = 0
)(
    input  logic [IN_W-1:0]  in_vec  [TILE_SIZE-1:0],
    input  logic [SCALE_W-1:0] scale_vec [TILE_SIZE-1:0],
    output logic [OUT_W-1:0] out_vec [TILE_SIZE-1:0]
);
    localparam int MUL_W = IN_W + SCALE_W + 2;
    localparam int TOTAL_SHIFT = SHIFT + SCALE_FRAC_BITS;
    localparam logic [SCALE_W-1:0] IDENTITY_SCALE = logic'(1) << SCALE_FRAC_BITS;

    function automatic logic signed [MUL_W-1:0] round_shift_value(
        input logic signed [MUL_W-1:0] x
    );
        logic signed [MUL_W-1:0] q;
        logic        [MUL_W-1:0] rem;
        logic        [MUL_W-1:0] half;
        begin
            if (TOTAL_SHIFT <= 0) begin
                round_shift_value = x;
            end else if (ROUND_MODE == 1) begin
                q    = x >>> TOTAL_SHIFT;
                rem  = x - (q <<< TOTAL_SHIFT);
                half = {{(MUL_W-1){1'b0}}, 1'b1} << (TOTAL_SHIFT - 1);

                if (rem > half)
                    q = q + 1'b1;
                else if ((rem == half) && q[0])
                    q = q + 1'b1;

                round_shift_value = q;
            end else begin
                round_shift_value = x >>> TOTAL_SHIFT;
            end
        end
    endfunction

    function automatic logic [OUT_W-1:0] cast_with_sat(
        input logic signed [MUL_W-1:0] x
    );
        logic signed [MUL_W-1:0] signed_min;
        logic signed [MUL_W-1:0] signed_max;
        logic signed [MUL_W-1:0] unsigned_min;
        logic signed [MUL_W-1:0] unsigned_max;
        begin
            if (SAT_MODE == 0) begin
                cast_with_sat = x[OUT_W-1:0];
            end else if (SIGNED_OUT) begin
                signed_min = -$signed({{(MUL_W-OUT_W){1'b0}}, {1'b1, {(OUT_W-1){1'b0}}}});
                signed_max =  $signed({{(MUL_W-OUT_W){1'b0}}, {1'b0, {(OUT_W-1){1'b1}}}});

                if (x < signed_min)
                    cast_with_sat = signed_min[OUT_W-1:0];
                else if (x > signed_max)
                    cast_with_sat = signed_max[OUT_W-1:0];
                else
                    cast_with_sat = x[OUT_W-1:0];
            end else begin
                unsigned_min = '0;
                unsigned_max = $signed({{(MUL_W-OUT_W){1'b0}}, {OUT_W{1'b1}}});

                if (x < unsigned_min)
                    cast_with_sat = unsigned_min[OUT_W-1:0];
                else if (x > unsigned_max)
                    cast_with_sat = unsigned_max[OUT_W-1:0];
                else
                    cast_with_sat = x[OUT_W-1:0];
            end
        end
    endfunction

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++) begin
            logic signed [MUL_W-1:0] x_ext;
            logic signed [MUL_W-1:0] scaled;
            logic signed [MUL_W-1:0] shifted;
            logic [SCALE_W-1:0]      scale_eff;

            if (SIGNED_IN)
                x_ext = $signed({{(MUL_W-IN_W){in_vec[i][IN_W-1]}}, in_vec[i]});
            else
                x_ext = $signed({{(MUL_W-IN_W){1'b0}}, in_vec[i]});

            if (USE_SCALE)
                scale_eff = scale_vec[i];
            else
                scale_eff = IDENTITY_SCALE;

            scaled     = x_ext * $signed({1'b0, scale_eff});
            shifted    = round_shift_value(scaled);
            out_vec[i] = cast_with_sat(shifted);
        end
    end

endmodule
