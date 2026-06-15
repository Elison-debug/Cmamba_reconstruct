`timescale 1ns/1ps

module mm_vec_fifo_axis #(
    parameter int TILE_SIZE = 4,
    parameter int DATA_WIDTH = 16
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
    logic full;
    logic signed [DATA_WIDTH-1:0] vec_buf [TILE_SIZE-1:0];

    assign in_ready = !full;
    assign out_valid = full;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            full <= 1'b0;
            for (int i = 0; i < TILE_SIZE; i++) begin
                vec_buf[i] <= '0;
            end
        end else begin
            if (in_valid && in_ready) begin
                full <= 1'b1;
                for (int i = 0; i < TILE_SIZE; i++) begin
                    vec_buf[i] <= in_vec[i];
                end
            end else if (out_valid && out_ready) begin
                full <= 1'b0;
            end
        end
    end

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++) begin
            out_vec[i] = vec_buf[i];
        end
    end
endmodule


