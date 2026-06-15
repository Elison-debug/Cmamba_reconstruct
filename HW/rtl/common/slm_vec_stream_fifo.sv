`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: slm_vec_stream_fifo
// Function:
//   Small synchronous vector FIFO for tile-stream decoupling.
//   The module buffers one vector per entry and exposes a standard
//   valid/ready contract on both sides. It is used to decouple
//   adjacent stages without forcing an intermediate SRAM barrier.
//---------------------------------------------------------------
module slm_vec_stream_fifo #(
    parameter int TILE_SIZE = 4,
    parameter int DATA_WIDTH = 16,
    parameter int DEPTH = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic in_valid,
    output logic in_ready,
    input  logic signed [DATA_WIDTH-1:0] in_vec [TILE_SIZE-1:0],
    output logic out_valid,
    input  logic out_ready,
    output logic signed [DATA_WIDTH-1:0] out_vec [TILE_SIZE-1:0]
);
    localparam int PTR_W = (DEPTH > 1) ? $clog2(DEPTH) : 1;
    localparam int CNT_W = $clog2(DEPTH + 1);

    logic [PTR_W-1:0] wr_ptr;
    logic [PTR_W-1:0] rd_ptr;
    logic [CNT_W-1:0] count;
    logic push;
    logic pop;
    logic signed [DATA_WIDTH-1:0] mem [DEPTH-1:0][TILE_SIZE-1:0];

    assign in_ready = (count < DEPTH);
    assign out_valid = (count != 0);
    assign push = in_valid && in_ready;
    assign pop = out_valid && out_ready;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            count <= '0;
            for (int d = 0; d < DEPTH; d++) begin
                for (int i = 0; i < TILE_SIZE; i++) begin
                    mem[d][i] <= '0;
                end
            end
        end else begin
            if (push) begin
                for (int i = 0; i < TILE_SIZE; i++) begin
                    mem[wr_ptr][i] <= in_vec[i];
                end
                if (wr_ptr == DEPTH-1) begin
                    wr_ptr <= '0;
                end else begin
                    wr_ptr <= wr_ptr + 1'b1;
                end
            end

            if (pop) begin
                if (rd_ptr == DEPTH-1) begin
                    rd_ptr <= '0;
                end else begin
                    rd_ptr <= rd_ptr + 1'b1;
                end
            end

            case ({push, pop})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++) begin
            out_vec[i] = mem[rd_ptr][i];
        end
    end
endmodule
