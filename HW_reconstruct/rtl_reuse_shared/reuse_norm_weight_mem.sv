//---------------------------------------------------------------
// Module: reuse_norm_weight_mem
// Function:
//   Simple synchronous norm-weight memory.
//   Each address stores one 4-lane packed Q8.8 gamma vector.
//---------------------------------------------------------------
module reuse_norm_weight_mem #(
    parameter int TILE_SIZE = 4,
    parameter int DATA_WIDTH = 16,
    parameter int DEPTH = 32,
    parameter int ADDR_W = $clog2(DEPTH),
    parameter string INIT_FILE = ""
)(
    input  logic clk,
    input  logic wr_en,
    input  logic [ADDR_W-1:0] wr_addr,
    input  logic signed [DATA_WIDTH-1:0] wr_data [TILE_SIZE-1:0],
    input  logic en,
    input  logic [ADDR_W-1:0] addr,
    output logic signed [DATA_WIDTH-1:0] rd_data [TILE_SIZE-1:0]
);
`ifndef SYNTHESIS
    logic [TILE_SIZE*DATA_WIDTH-1:0] mem_sim [DEPTH];
    logic [TILE_SIZE*DATA_WIDTH-1:0] wr_pack;
    logic [TILE_SIZE*DATA_WIDTH-1:0] q_d1;
    logic [TILE_SIZE*DATA_WIDTH-1:0] q;

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++)
            wr_pack[i*DATA_WIDTH +: DATA_WIDTH] = wr_data[i];
    end

    always_ff @(posedge clk) begin
        if (wr_en)
            mem_sim[wr_addr] <= wr_pack;
        if (en)
            q_d1 <= mem_sim[addr];
        q <= q_d1;
    end

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++)
            rd_data[i] = q[i*DATA_WIDTH +: DATA_WIDTH];
    end
`else
    logic [TILE_SIZE*DATA_WIDTH-1:0] wr_pack;
    logic [TILE_SIZE*DATA_WIDTH-1:0] q;

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++)
            wr_pack[i*DATA_WIDTH +: DATA_WIDTH] = wr_data[i];
    end

    norm_gamma_rom_ip u_gamma_ip (
        .clka (clk),
        .ena  (wr_en),
        .wea  (wr_en),
        .addra (wr_addr),
        .dina (wr_pack),
        .clkb (clk),
        .enb  (en),
        .addrb(addr),
        .doutb(q)
    );

    always_comb begin
        for (int i = 0; i < TILE_SIZE; i++)
            rd_data[i] = q[i*DATA_WIDTH +: DATA_WIDTH];
    end
`endif
endmodule
