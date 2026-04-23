`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: reuse_u32_div_seq
// Function:
//   Synthesizable unsigned divider with chunked iterations.
//   It keeps exact restoring-division behavior, but executes
//   multiple iterations per cycle to reduce latency.
//---------------------------------------------------------------
module reuse_u32_div_seq #(
    parameter int DIV_W = 32,
    parameter int ITER_PER_CYCLE = 4   // 32/4 => 8-cycle latency
) (
    input  logic                 clk,
    input  logic                 rst_n,
    input  logic                 start,
    input  logic [DIV_W-1:0]     dividend,
    input  logic [DIV_W-1:0]     divisor,
    output logic                 busy,
    output logic                 done,
    output logic [DIV_W-1:0]     quotient
);
    localparam int STAGES = (DIV_W + ITER_PER_CYCLE - 1) / ITER_PER_CYCLE;
    localparam int CNT_W  = (STAGES <= 2) ? 2 : $clog2(STAGES + 1);

    logic [DIV_W-1:0] dividend_r;
    logic [DIV_W-1:0] divisor_r;
    logic [DIV_W-1:0] quotient_r;
    logic [DIV_W:0]   rem_r;
    logic [CNT_W-1:0] stage_left;

    logic [DIV_W-1:0] dividend_n;
    logic [DIV_W-1:0] quotient_n;
    logic [DIV_W:0]   rem_n;

    function automatic logic [2*DIV_W + DIV_W + 1 - 1:0] div_chunk(
        input logic [DIV_W:0]   rem_i,
        input logic [DIV_W-1:0] dividend_i,
        input logic [DIV_W-1:0] quotient_i,
        input logic [DIV_W-1:0] divisor_i
    );
        logic [DIV_W:0]   rem_t;
        logic [DIV_W-1:0] dividend_t;
        logic [DIV_W-1:0] quotient_t;
        logic [DIV_W:0]   rem_shift_t;
        logic [DIV_W:0]   rem_sub_t;
        logic             take_sub_t;
        begin
            rem_t = rem_i;
            dividend_t = dividend_i;
            quotient_t = quotient_i;
            for (int k = 0; k < ITER_PER_CYCLE; k++) begin
                rem_shift_t = {rem_t[DIV_W-1:0], dividend_t[DIV_W-1]};
                rem_sub_t   = rem_shift_t - {1'b0, divisor_i};
                take_sub_t  = (rem_shift_t >= {1'b0, divisor_i});
                rem_t       = take_sub_t ? rem_sub_t : rem_shift_t;
                dividend_t  = {dividend_t[DIV_W-2:0], 1'b0};
                quotient_t  = {quotient_t[DIV_W-2:0], take_sub_t};
            end
            div_chunk = {rem_t, dividend_t, quotient_t};
        end
    endfunction

    always_comb begin
        logic [2*DIV_W + DIV_W + 1 - 1:0] chunk_result;
        chunk_result = div_chunk(rem_r, dividend_r, quotient_r, divisor_r);
        rem_n = chunk_result[2*DIV_W + DIV_W + 1 - 1 -: (DIV_W+1)];
        dividend_n = chunk_result[DIV_W + DIV_W - 1 -: DIV_W];
        quotient_n = chunk_result[DIV_W-1:0];
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            busy       <= 1'b0;
            done       <= 1'b0;
            quotient   <= '0;
            dividend_r <= '0;
            divisor_r  <= '0;
            quotient_r <= '0;
            rem_r      <= '0;
            stage_left <= '0;
        end else begin
            done <= 1'b0;

            if (start && !busy) begin
                if (divisor == '0) begin
                    busy     <= 1'b0;
                    done     <= 1'b1;
                    quotient <= {DIV_W{1'b1}};
                end else begin
                    busy       <= 1'b1;
                    dividend_r <= dividend;
                    divisor_r  <= divisor;
                    quotient_r <= '0;
                    rem_r      <= '0;
                    stage_left <= STAGES[CNT_W-1:0];
                end
            end else if (busy) begin
                dividend_r <= dividend_n;
                quotient_r <= quotient_n;
                rem_r      <= rem_n;

                if (stage_left == {{(CNT_W-1){1'b0}},1'b1}) begin
                    busy     <= 1'b0;
                    done     <= 1'b1;
                    quotient <= quotient_n;
                end
                stage_left <= stage_left - {{(CNT_W-1){1'b0}},1'b1};
            end
        end
    end
endmodule
