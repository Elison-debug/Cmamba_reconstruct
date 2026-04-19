//---------------------------------------------------------------
// Module: reuse_norm_weight_mem
// Function:
//   Fixed RMSNorm gamma ROM.
//   - Initialization comes from INIT_FILE
//   - Read latency is 1 cycle, aligned with reuse_weight_bank_rom
//---------------------------------------------------------------
module reuse_norm_weight_mem #(
    parameter int TILE_SIZE = 4,
    parameter int DATA_WIDTH = 16,
    parameter int DEPTH = 32,
    parameter int ADDR_W = $clog2(DEPTH),
    parameter string INIT_FILE = ""
)(
    input  logic clk,
    input  logic en,
    input  logic [ADDR_W-1:0] addr,
    output logic signed [DATA_WIDTH-1:0] rd_data [TILE_SIZE-1:0]
);
// `ifndef SYNTHESIS
//     logic [TILE_SIZE*DATA_WIDTH-1:0] mem_sim [DEPTH];
//     logic [TILE_SIZE*DATA_WIDTH-1:0] q;
//     integer init_idx;

//     initial begin
//         for (init_idx = 0; init_idx < DEPTH; init_idx = init_idx + 1)
//             mem_sim[init_idx] = '0;
//         if (INIT_FILE != "")
//             $readmemh(INIT_FILE, mem_sim);
//     end

//     always_ff @(posedge clk) begin
//         if (en)
//             q <= mem_sim[addr];
//     end

//     always_comb begin
//         for (int i = 0; i < TILE_SIZE; i++)
//             rd_data[i] = q[i*DATA_WIDTH +: DATA_WIDTH];
//     end
// `else
    logic [TILE_SIZE*DATA_WIDTH-1:0] q;

    reuse_weight_bank_rom #(
        .DEPTH    (DEPTH),
        .ADDR_W   (ADDR_W),
        .DATA_W   (TILE_SIZE * DATA_WIDTH),
        .INIT_FILE(INIT_FILE)
    ) u_gamma_rom (
        .clk   (clk),
        .en_a  (en),
        .addr_a(addr),
        .dout_a(q),
        .en_b  (1'b0),
        .addr_b('0),
        .dout_b()
    );

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++)
            rd_data[i] = q[i*DATA_WIDTH +: DATA_WIDTH];
    end
//`endif
endmodule
