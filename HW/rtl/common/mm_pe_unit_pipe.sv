`timescale 1ns/1ps

module mm_pe_unit_pipe #(
    parameter int DATA_WIDTH = 16,
    parameter int ACC_WIDTH  = 32,
    parameter int FRAC_BITS  = 8
)(
    input  logic                       clk,
    input  logic                       rst_n,
    input  logic                       valid_in,
    output logic                       valid_out,
    input  logic [1:0]                 mode,
    input  logic signed [DATA_WIDTH-1:0] a_in,
    input  logic signed [DATA_WIDTH-1:0] b_in,
    input  logic signed [ACC_WIDTH-1:0]  acc_in,
    output logic signed [ACC_WIDTH-1:0]  result_out
);
    localparam int SHIFTED_WIDTH = (DATA_WIDTH + 1) + FRAC_BITS;

    logic signed [ACC_WIDTH-1:0] mult_full;
    logic signed [DATA_WIDTH:0]  ewa_sum;
    logic signed [SHIFTED_WIDTH-1:0] ewa_shifted;
    logic signed [ACC_WIDTH-1:0] ewa_sum_aligned;
    logic signed [ACC_WIDTH-1:0] dsp_accum;
    logic signed [ACC_WIDTH-1:0] result_reg;
    logic                        valid_reg;

    assign mult_full = $signed(a_in) * $signed(b_in);
    assign ewa_sum   = a_in + b_in;
    assign ewa_shifted = $signed(ewa_sum) <<< FRAC_BITS;
    assign ewa_sum_aligned =
        {{(ACC_WIDTH - SHIFTED_WIDTH){ewa_shifted[SHIFTED_WIDTH-1]}}, ewa_shifted};

    always_comb begin
        unique case (mode)
            2'b00: dsp_accum = mult_full + acc_in;
            2'b01: dsp_accum = mult_full;
            2'b10: dsp_accum = ewa_sum_aligned;
            default: dsp_accum = '0;
        endcase
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            result_reg <= '0;
            valid_reg  <= 1'b0;
        end else begin
            if (valid_in) begin
                result_reg <= dsp_accum;
            end
            valid_reg <= valid_in;
        end
    end

    assign result_out = result_reg;
    assign valid_out  = valid_reg;
endmodule


