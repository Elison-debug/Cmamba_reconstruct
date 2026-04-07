`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: reuse_packed_scale_mem
// Function:
//   Simple synchronous packed scale memory.
//   Each address stores 4 lane scales as 4x16b packed into 64b.
//---------------------------------------------------------------
module reuse_packed_scale_mem #(
    parameter int DEPTH  = 64,
    parameter int ADDR_W = $clog2(DEPTH),
    parameter int DATA_W = 64
)(
    input  logic              clk,
    input  logic              en,
    input  logic [ADDR_W-1:0] addr,
    output logic [DATA_W-1:0] dout
);
    logic [DATA_W-1:0] mem [0:DEPTH-1];

    always_ff @(posedge clk) begin
        if (en)
            dout <= mem[addr];
    end
endmodule
