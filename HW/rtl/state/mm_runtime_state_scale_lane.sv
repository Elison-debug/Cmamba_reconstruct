`timescale 1ns/1ps

module mm_runtime_state_scale_lane #(
    parameter int DATA_WIDTH = 16,
    parameter int SCALE_W = 32,
    parameter int SCALE_FRAC_BITS = 16
)(
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    input  logic signed [DATA_WIDTH-1:0] u_q88,
    output logic done,
    output logic [SCALE_W-1:0] u_to_state_q16,
    output logic [SCALE_W-1:0] state_to_q88_q16
);
    logic [DATA_WIDTH:0] abs_u;
    logic [DATA_WIDTH:0] abs_u_eff;

    always_comb begin
        if (u_q88[DATA_WIDTH-1]) begin
            if (u_q88 == {1'b1, {(DATA_WIDTH-1){1'b0}}}) begin
                abs_u = ({{DATA_WIDTH{1'b0}},1'b1} << (DATA_WIDTH-1));
            end else begin
                abs_u = -u_q88;
            end
        end else begin
            abs_u = u_q88;
        end
        abs_u_eff = (abs_u == '0) ? {{(DATA_WIDTH-8){1'b0}}, 9'd256} : abs_u;
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            done <= 1'b0;
            u_to_state_q16 <= '0;
            state_to_q88_q16 <= '0;
        end else begin
            done <= 1'b0;
            if (start) begin
                // First clean version: keep the scale stage explicit, but use
                // a closed-form combinational estimate. This makes the stage
                // boundary architectural rather than implementation-accidental.
                u_to_state_q16 <= ((32'd32767 << SCALE_FRAC_BITS) + abs_u_eff[DATA_WIDTH:1]) /
                                  {{(31-DATA_WIDTH){1'b0}}, abs_u_eff};
                state_to_q88_q16 <= (({15'd0, abs_u_eff} << SCALE_FRAC_BITS) + 32'd16383) / 32'd32767;
                done <= 1'b1;
            end
        end
    end
endmodule


