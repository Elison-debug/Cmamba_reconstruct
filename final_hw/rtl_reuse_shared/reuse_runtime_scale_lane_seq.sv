`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: reuse_runtime_scale_lane_seq
// Function:
//   Runtime scale calculator for one lane.
//   Computes:
//     u_to_state_q16   = ((32767<<16) + abs_u_eff/2) / abs_u_eff
//     state_to_q88_q16 = ((abs_u_eff<<16) + 16383)  / 32767
//   using sequential dividers for timing closure.
//---------------------------------------------------------------
module reuse_runtime_scale_lane_seq #(
    parameter int DATA_WIDTH = 16,
    parameter int SCALE_W = 32,
    parameter int SCALE_FRAC_BITS = 16
) (
    input  logic                         clk,
    input  logic                         rst_n,
    input  logic                         start,
    input  logic signed [DATA_WIDTH-1:0] u_q88,
    output logic                         busy,
    output logic                         done,
    output logic [SCALE_W-1:0]           u_to_state_q16,
    output logic [SCALE_W-1:0]           state_to_q88_q16
);
    logic [DATA_WIDTH:0] abs_u;
    logic [DATA_WIDTH:0] abs_u_eff;
    logic [31:0] num_u;
    logic [31:0] den_u;
    logic [31:0] num_s;
    logic [31:0] den_s;

    logic [31:0] q_u;
    logic [31:0] q_s;
    logic busy_u, done_u;
    logic busy_s, done_s;
    logic start_div;
    logic launched;

    always_comb begin
        if (u_q88[DATA_WIDTH-1]) begin
            if (u_q88 == {1'b1, {(DATA_WIDTH-1){1'b0}}})
                abs_u = ({{DATA_WIDTH{1'b0}},1'b1} << (DATA_WIDTH-1));
            else
                abs_u = -u_q88;
        end else begin
            abs_u = u_q88;
        end

        abs_u_eff = (abs_u == '0) ? {{(DATA_WIDTH-8){1'b0}}, 9'd256} : abs_u;

        num_u = (32'd32767 << SCALE_FRAC_BITS) + {16'd0, abs_u_eff[DATA_WIDTH:1]};
        den_u = {{(31-DATA_WIDTH){1'b0}}, abs_u_eff};

        num_s = ({15'd0, abs_u_eff} << SCALE_FRAC_BITS) + 32'd16383;
        den_s = 32'd32767;
    end

    reuse_u32_div_seq #(.DIV_W(32)) u_div_u2s (
        .clk      (clk),
        .rst_n    (rst_n),
        .start    (start_div),
        .dividend (num_u),
        .divisor  (den_u),
        .busy     (busy_u),
        .done     (done_u),
        .quotient (q_u)
    );

    reuse_u32_div_seq #(.DIV_W(32)) u_div_s2q (
        .clk      (clk),
        .rst_n    (rst_n),
        .start    (start_div),
        .dividend (num_s),
        .divisor  (den_s),
        .busy     (busy_s),
        .done     (done_s),
        .quotient (q_s)
    );

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            launched <= 1'b0;
            done <= 1'b0;
            u_to_state_q16 <= '0;
            state_to_q88_q16 <= '0;
        end else begin
            done <= 1'b0;

            if (start && !launched && !busy_u && !busy_s) begin
                launched <= 1'b1;
            end else if (launched && !busy_u && !busy_s) begin
                launched <= 1'b0;
                done <= 1'b1;
                u_to_state_q16 <= q_u[SCALE_W-1:0];
                state_to_q88_q16 <= q_s[SCALE_W-1:0];
            end
        end
    end

    assign start_div = start && !launched && !busy_u && !busy_s;
    assign busy = launched || busy_u || busy_s;
endmodule
