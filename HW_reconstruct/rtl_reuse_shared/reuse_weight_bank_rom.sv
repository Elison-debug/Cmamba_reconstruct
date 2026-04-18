`timescale 1ns/1ps
//---------------------------------------------------------------
// Module: reuse_weight_bank_rom
// Function:
//   Synchronous dual-read-port ROM backed by block RAM/ROM inference.
//   Used for deployment builds where weights/scales are fixed for a
//   relatively long time and should come up initialized from .mem files.
//
// Timing:
//   - 1 cycle read latency on each enabled port
//   - read-only during normal operation
//
// Notes:
//   - INIT_FILE can be different per instance, which makes multi-block
//     deployment straightforward: each block passes its own bank files.
//   - When INIT_FILE is empty, the ROM powers up as zero.
//---------------------------------------------------------------
module reuse_weight_bank_rom #(
    parameter int DEPTH = 1024,
    parameter int ADDR_W = $clog2(DEPTH),
    parameter int DATA_W = 256,
    parameter string INIT_FILE = ""
)(
    input  logic              clk,
    input  logic              en_a,
    input  logic [ADDR_W-1:0] addr_a,
    output logic [DATA_W-1:0] dout_a,
    input  logic              en_b,
    input  logic [ADDR_W-1:0] addr_b,
    output logic [DATA_W-1:0] dout_b
);
    (* rom_style = "block" *) logic [DATA_W-1:0] mem [0:DEPTH-1];

    initial begin : init_rom
        for (int i = 0; i < DEPTH; i++)
            mem[i] = '0;
        if (INIT_FILE != "")
            $readmemh(INIT_FILE, mem);
    end

    always_ff @(posedge clk) begin
        if (en_a)
            dout_a <= mem[addr_a];
        if (en_b)
            dout_b <= mem[addr_b];
    end
endmodule
